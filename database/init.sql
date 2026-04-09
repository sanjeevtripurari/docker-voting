CREATE DATABASE IF NOT EXISTS voting_app;

CREATE USER IF NOT EXISTS 'voting_user'@'%' IDENTIFIED BY 'vote_pass';

GRANT ALL PRIVILEGES ON voting_app.* TO 'voting_user'@'%';

FLUSH PRIVILEGES;

USE voting_app;

CREATE TABLE IF NOT EXISTS votes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vote_type ENUM('YES', 'NO') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);