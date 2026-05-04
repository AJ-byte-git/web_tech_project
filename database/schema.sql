-- MySQL Schema for book_haven
-- Optimized for Selling, Reselling, and Renting

CREATE DATABASE IF NOT EXISTS book_haven;
USE book_haven;

-- Disable foreign key checks to allow dropping tables in any order
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS sale_transactions;
DROP TABLE IF EXISTS buy_transactions;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Users Table
-- Stores user profiles and reselling/renting records
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    books_sold INT DEFAULT 0,
    books_rented INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Categories Table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Books Table
-- quantity represents stock for selling/renting
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT,
    price DECIMAL(10, 2) NOT NULL COMMENT 'Sale price',
    rent_price DECIMAL(10, 2) NOT NULL COMMENT 'Rent price per unit',
    quantity INT DEFAULT 0,
    is_used BOOLEAN DEFAULT FALSE,
    seller_id INT DEFAULT NULL COMMENT 'NULL if store-owned, else user_id of reseller',
    image_url VARCHAR(255) DEFAULT 'default_cover.jpg',
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 4. Orders Table
-- Groups multiple items in a single checkout
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Buy (Purchase Transactions)
-- Records of users buying books from the store or resellers
CREATE TABLE buy_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    buy_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. Sold (Sale/Resell Transactions)
-- Records of users selling books (reselling)
CREATE TABLE sale_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL COMMENT 'The user who sold the book',
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 7. Rented Table
-- Tracks rental status and duration
CREATE TABLE rentals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    status ENUM('issued', 'returned', 'overdue') DEFAULT 'issued',
    issue_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 8. Cart Table
CREATE TABLE cart (
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT DEFAULT 1,
    PRIMARY KEY (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- Insert Initial Data
INSERT INTO categories (name) VALUES ('Fiction'), ('Non-Fiction'), ('Science'), ('History'), ('Technology');

INSERT INTO users (first_name, last_name, email, password) VALUES 
('John', 'Doe', 'john@example.com', 'hashed_password_1'),
('Jane', 'Smith', 'jane@example.com', 'hashed_password_2');

INSERT INTO books (title, author, description, category_id, price, rent_price, quantity) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'A classic story of wealth and love.', 1, 12.99, 2.99, 10),
('Sapiens', 'Yuval Noah Harari', 'A brief history of humankind.', 2, 22.00, 5.50, 5),
('Atomic Habits', 'James Clear', 'An easy and proven way to build good habits.', 2, 18.00, 4.50, 15);
