<?php
namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Services\GoogleCloudStorageService;
use PDO;

class UploadController {
    private $db;
    private $gcs;

    public function __construct() {
        $this->db = \App\Core\Database::getInstance()->getConnection();
        $this->gcs = new GoogleCloudStorageService();
    }

    public function uploadProfileImage() {
        $userId = $_SESSION['user_id'] ?? null;
        $role = $_SESSION['role'] ?? null;

        if (!$userId) {
            Response::error('Unauthorized', 401);
        }

        if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
            Response::error('No valid image file uploaded.', 400);
        }

        $file = $_FILES['image'];
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        
        // Detect mime type reliably
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        
        // Ensure it's an image
        if (strpos($mime, 'image/') !== 0) {
            Response::error("Invalid file type ($mime). Only images are allowed.", 400);
        }

        $destinationName = "profiles/user_{$userId}_" . time() . ".{$ext}";
        
        // Upload to GCS
        $publicUrl = $this->gcs->uploadFile($file['tmp_name'], $destinationName, $mime);

        if (!$publicUrl) {
            Response::error('Failed to upload image to Cloud Storage. Please try again later.', 500);
        }

        // Update database
        if ($role === 'provider') {
            $stmt = $this->db->prepare("UPDATE service_providers SET logo_url = ? WHERE user_id = ?");
        } else {
            $stmt = $this->db->prepare("UPDATE customers SET profile_image = ? WHERE user_id = ?");
        }
        $stmt->execute([$publicUrl, $userId]);

        Response::success('Profile image updated successfully', [
            'url' => $publicUrl
        ]);
    }

    public function uploadServiceMedia() {
        $userId = $_SESSION['user_id'] ?? null;
        $role = $_SESSION['role'] ?? null;

        if (!$userId || $role !== 'provider') {
            Response::error('Unauthorized. Only providers can upload service media.', 401);
        }

        $body = Request::getBody();
        $serviceId = $body['service_id'] ?? null;
        $serviceType = $body['service_type'] ?? null;

        if (!$serviceId || !$serviceType) {
            Response::error('Missing service_id or service_type.', 400);
        }

        if (!isset($_FILES['images']) || empty($_FILES['images']['name'][0])) {
            Response::error('No valid images uploaded.', 400);
        }

        $uploadedUrls = [];
        $files = $_FILES['images'];
        $count = count($files['name']);

        // Check if there's already a thumbnail for this service
        $stmtCheck = $this->db->prepare("SELECT COUNT(*) FROM media WHERE service_id = ? AND service_type = ? AND is_thumbnail = 1");
        $stmtCheck->execute([$serviceId, $serviceType]);
        $hasThumbnail = $stmtCheck->fetchColumn() > 0;

        for ($i = 0; $i < $count; $i++) {
            if ($files['error'][$i] === UPLOAD_ERR_OK) {
                $ext = pathinfo($files['name'][$i], PATHINFO_EXTENSION);
                
                // Detect mime type reliably
                $finfo = finfo_open(FILEINFO_MIME_TYPE);
                $mime = finfo_file($finfo, $files['tmp_name'][$i]);
                finfo_close($finfo);

                if (strpos($mime, 'image/') !== 0) continue;

                $destinationName = "services/{$serviceType}/{$serviceId}_" . time() . "_{$i}.{$ext}";
                
                $publicUrl = $this->gcs->uploadFile($files['tmp_name'][$i], $destinationName, $mime);

                if ($publicUrl) {
                    $isThumbnail = (!$hasThumbnail && $i === 0) ? 1 : 0;

                    $stmt = $this->db->prepare("INSERT INTO media (service_type, service_id, file_url, is_thumbnail) VALUES (?, ?, ?, ?)");
                    $stmt->execute([$serviceType, $serviceId, $publicUrl, $isThumbnail]);
                    
                    $uploadedUrls[] = $publicUrl;
                }
            }
        }

        if (empty($uploadedUrls)) {
            Response::error('Failed to upload any images.', 500);
        }

        Response::success('Service media uploaded successfully', [
            'urls' => $uploadedUrls
        ]);
    }

    public function deleteImage() {
        $userId = $_SESSION['user_id'] ?? null;
        if (!$userId) {
            Response::error('Unauthorized', 401);
        }

        $body = Request::getBody();
        $imageUrl = $body['url'] ?? null;
        if (!$imageUrl) {
            Response::error('Missing image URL.', 400);
        }

        // Extract object name from URL
        // Format: https://storage.googleapis.com/bucket-name/object-name
        $parts = explode('/', $imageUrl);
        // parts[0]=https:, parts[1]='', parts[2]=storage.googleapis.com, parts[3]=bucket-name, parts[4...]=object-name
        if (count($parts) < 5) {
            Response::error('Invalid image URL format.', 400);
        }

        $objectName = implode('/', array_slice($parts, 4));

        if ($this->gcs->deleteFile($objectName)) {
            // If it was a profile image or service media, you might want to remove it from DB too.
            // For now, we'll just delete from GCS.
            Response::success('Image deleted successfully from storage.');
        } else {
            Response::error('Failed to delete image from storage.', 500);
        }
    }
}
