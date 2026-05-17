<?php
// 📂 File Management Service
// Logic for handling file uploads, validation, and deletion.

namespace App\Services;

use Exception;

class FileService {
    private static $uploadDir = __DIR__ . '/../../public/uploads/';
    private static $allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    private static $maxSize = 5 * 1024 * 1024; // 5MB

    public static function upload($file) {
        if ($file['error'] !== UPLOAD_ERR_OK) {
            throw new Exception("File upload failed with error code: " . $file['error']);
        }

        if ($file['size'] > self::$maxSize) {
            throw new Exception("File size too large (max 5MB)");
        }

        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mimeType, self::$allowedTypes)) {
            throw new Exception("Invalid file type (JPG, PNG, WEBP only)");
        }

        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $fileName = uniqid('img_', true) . '.' . $extension;
        $targetPath = self::$uploadDir . $fileName;

        if (!is_dir(self::$uploadDir)) {
            mkdir(self::$uploadDir, 0777, true);
        }

        if (move_uploaded_file($file['tmp_name'], $targetPath)) {
            return $fileName;
        }

        throw new Exception("Could not save file to disk");
    }

    public static function delete($fileName) {
        $path = self::$uploadDir . $fileName;
        if (file_exists($path)) {
            unlink($path);
        }
    }
}
