<?php
namespace App\Services;

class GoogleCloudStorageService {
    private $credentialsPath;
    private $bucketName;

    public function __construct() {
        // Place credentials.json in the config folder (we'll tell the user to do this)
        $this->credentialsPath = __DIR__ . '/../../config/credentials.json';
        $this->bucketName = 'mabrouk'; // Updated from screenshot
    }

    /**
     * Uploads a file to Google Cloud Storage
     *
     * @param string $localFilePath The absolute path of the file to upload
     * @param string $destinationName The name of the file in the bucket (e.g., 'profiles/user_1.jpg')
     * @param string $mimeType The MIME type of the file
     * @return string|false The public URL on success, or false on failure
     */
    public function uploadFile($localFilePath, $destinationName, $mimeType = 'image/jpeg') {
        if (!file_exists($this->credentialsPath)) {
            error_log("GCS Upload Error: credentials.json not found at {$this->credentialsPath}");
            return false;
        }

        $token = $this->getAccessToken();
        if (!$token) {
            error_log("GCS Upload Error: Failed to obtain access token.");
            return false;
        }

        $fileContent = file_get_contents($localFilePath);
        $fileSize = filesize($localFilePath);

        $url = "https://storage.googleapis.com/upload/storage/v1/b/{$this->bucketName}/o?uploadType=media&name=" . urlencode($destinationName);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fileContent);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Authorization: Bearer {$token}",
            "Content-Type: {$mimeType}",
            "Content-Length: {$fileSize}"
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode >= 200 && $httpCode < 300) {
            return "https://storage.googleapis.com/{$this->bucketName}/{$destinationName}";
        } else {
            error_log("GCS Upload Error HTTP {$httpCode}: {$response}");
            return false;
        }
    }

    /**
     * Deletes a file from Google Cloud Storage
     *
     * @param string $objectName The name of the file in the bucket (e.g., 'profiles/user_1.jpg')
     * @return bool True on success, or false on failure
     */
    public function deleteFile($objectName) {
        if (!file_exists($this->credentialsPath)) {
            error_log("GCS Delete Error: credentials.json not found at {$this->credentialsPath}");
            return false;
        }

        $token = $this->getAccessToken();
        if (!$token) {
            error_log("GCS Delete Error: Failed to obtain access token.");
            return false;
        }

        $url = "https://storage.googleapis.com/storage/v1/b/{$this->bucketName}/o/" . urlencode($objectName);

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Authorization: Bearer {$token}"
        ]);

        curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        return ($httpCode === 204 || $httpCode === 200);
    }

    private function getAccessToken() {
        $creds = json_decode(file_get_contents($this->credentialsPath), true);
        if (!$creds) return false;

        $clientEmail = $creds['client_email'];
        $privateKey = $creds['private_key'];

        $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
        $now = time();
        $claim = json_encode([
            'iss' => $clientEmail,
            'scope' => 'https://www.googleapis.com/auth/devstorage.read_write',
            'aud' => 'https://oauth2.googleapis.com/token',
            'exp' => $now + 3600,
            'iat' => $now
        ]);

        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlClaim = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($claim));

        $signatureInput = $base64UrlHeader . '.' . $base64UrlClaim;
        
        $signature = '';
        if (!openssl_sign($signatureInput, $signature, $privateKey, OPENSSL_ALGO_SHA256)) {
            error_log("GCS Upload Error: Failed to sign JWT.");
            return false;
        }

        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        $jwt = $signatureInput . '.' . $base64UrlSignature;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'https://oauth2.googleapis.com/token');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt
        ]));

        $response = curl_exec($ch);
        curl_close($ch);

        $res = json_decode($response, true);
        $token = $res['access_token'] ?? false;
        
        return $token;
    }
}
