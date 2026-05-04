-- MySQL Schema for book_haven

CREATE DATABASE IF NOT EXISTS book_haven;
USE book_haven;

-- Drop table if exists
DROP TABLE IF EXISTS books;

-- Create Books Table
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    rent_price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(255) DEFAULT 'default_cover.jpg'
);

-- Insert Sample Data
INSERT INTO books (title, author, price, rent_price) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 12.99, 2.99),
('1984', 'George Orwell', 10.50, 1.99),
('Atomic Habits', 'James Clear', 18.00, 4.50),
('Quiet', 'Susan Cain', 14.25, 3.00),
('Sapiens', 'Yuval Noah Harari', 22.00, 5.50),
('Educated', 'Tara Westover', 15.99, 3.50);
