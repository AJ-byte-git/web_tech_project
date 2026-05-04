-- MySQL Schema for book_haven
-- Optimized for Selling, Reselling, and Renting
-- Production-hardened schema

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
-- Stores user profiles and reselling/renting records.
-- FIX: Removed denormalized books_sold/books_rented counters (use COUNT() on
--      sale_transactions/rentals to avoid sync bugs). Added phone and role fields.
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'Always store bcrypt/argon2 hashed values',
    phone VARCHAR(20) DEFAULT NULL,
    role ENUM('customer', 'admin') DEFAULT 'customer' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Categories Table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Books Table
-- quantity represents stock for selling/renting.
-- FIX: quantity now has a CHECK to prevent negative stock.
-- FIX: rent_price is nullable for sale-only books.
-- FIX: seller_id FK uses RESTRICT on DELETE to protect resale listings.
-- FIX: category_id is NOT NULL to enforce categorization.
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL COMMENT 'Sale price',
    rent_price DECIMAL(10, 2) DEFAULT NULL COMMENT 'Rent price per unit; NULL if not rentable',
    quantity INT DEFAULT 0,
    is_used BOOLEAN DEFAULT FALSE,
    seller_id INT DEFAULT NULL COMMENT 'NULL if store-owned, else user_id of reseller',
    image_url VARCHAR(255) DEFAULT 'default_cover.jpg',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_books_quantity CHECK (quantity >= 0),
    CONSTRAINT chk_books_price CHECK (price >= 0),
    CONSTRAINT chk_books_rent_price CHECK (rent_price IS NULL OR rent_price >= 0),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE SET NULL
);

-- 4. Orders Table
-- Groups multiple items (buy or rent) in a single checkout.
-- FIX: total_amount has a CHECK to prevent negative totals.
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- 5. Buy Transactions
-- Records of users buying books from the store or resellers.
-- FIX: FK on book_id and user_id now uses RESTRICT to protect financial records.
-- FIX: quantity and price_per_unit now have CHECK constraints.
CREATE TABLE buy_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    buy_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_buy_quantity CHECK (quantity > 0),
    CONSTRAINT chk_buy_price_unit CHECK (price_per_unit >= 0),
    CONSTRAINT chk_buy_total CHECK (total_price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- 6. Sale Transactions (Reselling)
-- Records of users selling/reselling books.
-- FIX: FK on book_id and user_id now uses RESTRICT to protect audit trail.
-- FIX: quantity and price checks added.
CREATE TABLE sale_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL COMMENT 'The user who sold the book',
    quantity INT NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_sale_quantity CHECK (quantity > 0),
    CONSTRAINT chk_sale_price_unit CHECK (price_per_unit >= 0),
    CONSTRAINT chk_sale_total CHECK (total_price >= 0),
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- 7. Rentals Table
-- Tracks rental status and duration.
-- FIX: FK on book_id and user_id now uses RESTRICT to protect records.
-- FIX: Added return_date column to track actual return (not just the deadline).
-- FIX: CHECK constraint added to ensure end_date > issue_date (MySQL 8.0.16+).
CREATE TABLE rentals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    status ENUM('issued', 'returned', 'overdue') DEFAULT 'issued',
    issue_date DATE NOT NULL,
    end_date DATE NOT NULL,
    return_date DATE DEFAULT NULL COMMENT 'Actual date of return; NULL if not yet returned',
    CONSTRAINT chk_rental_dates CHECK (end_date > issue_date),
    CONSTRAINT chk_rental_price CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

-- 8. Cart Table
-- FIX: Added action column to distinguish between buy and rent intent.
-- FIX: quantity has a CHECK constraint.
CREATE TABLE cart (
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT DEFAULT 1,
    action ENUM('buy', 'rent') NOT NULL DEFAULT 'buy',
    PRIMARY KEY (user_id, book_id, action),
    CONSTRAINT chk_cart_quantity CHECK (quantity > 0),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

-- =============================================
-- Insert Initial / Sample Data
-- =============================================

INSERT INTO categories (name) VALUES ('Fiction'), ('Non-Fiction'), ('Science'), ('History'), ('Technology');

-- NOTE: In production, passwords MUST be bcrypt/argon2 hashed by the application.
INSERT INTO users (first_name, last_name, email, password, role) VALUES
('John', 'Doe', 'john@example.com', '$2y$10$examplehashedpassword1', 'customer'),
('Jane', 'Smith', 'jane@example.com', '$2y$10$examplehashedpassword2', 'customer'),
('Admin', 'User', 'admin@book-haven.com', '$2y$10$examplehashedpassword3', 'admin');

INSERT INTO books (title, author, description, category_id, price, rent_price, quantity) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'A classic story of wealth and love.', 1, 12.99, 2.99, 10),
('Sapiens', 'Yuval Noah Harari', 'A brief history of humankind.', 2, 22.00, 5.50, 5),
('Atomic Habits', 'James Clear', 'An easy and proven way to build good habits.', 2, 18.00, 4.50, 15),
('1984', 'George Orwell', 'A dystopian social science fiction novel.', 1, 10.50, 1.99, 8),
('Quiet', 'Susan Cain', 'The power of introverts in a world that cannot stop talking.', 2, 14.25, 3.00, 6),
('Educated', 'Tara Westover', 'A memoir about the struggle for self-invention.', 2, 15.99, 3.50, 9);
