-- 📥 Complaints Table
-- Allows customers to report issues with service providers.

CREATE TABLE IF NOT EXISTS complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL, -- The Customer who is complaining
    provider_id INT NOT NULL, -- The Service Provider being complained about
    booking_id INT DEFAULT NULL, -- Optional: Link to a specific booking
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('pending', 'resolved', 'ignored') DEFAULT 'pending',
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
);
