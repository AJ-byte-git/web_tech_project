# BookHaven - 3-Tier Web Application

This project is a dynamic book marketplace built using a **3-Tier Architecture** (Presentation, Logic, and Data) with **PHP**, **AJAX**, and **XML**.

## 🚀 Prerequisites

To run this application, you need:
- **PHP** (7.4 or higher with `pdo_pgsql` enabled)
- **PostgreSQL** (via Docker or local installation)
- **Web Server** (Built-in PHP server or Apache/XAMPP)

---

## 🛠️ Setup Instructions

### 1. Database Setup (MySQL)
1. Open your MySQL management tool (e.g., phpMyAdmin).
2. Create a new database named `book_haven`.
3. Import the schema and sample data:
   - File: `database/schema.sql`
   - Command line alternative: `mysql -u root -p book_haven < database/schema.sql`

### 2. Configure Connection
1. Open `api/db.php`.
2. Update the `$user` and `$password` if they differ from your setup.

### 3. Starting the Application

#### Option A: Using PHP's Built-in Server (Easiest)
1. Open your terminal in the project root directory.
2. Run the following command:
   ```bash
   php -S localhost:8000
   ```
3. Your application is now live at: `http://localhost:8000/UI/index.html`

#### Option B: Using XAMPP/Apache
1. Ensure the project folder is inside `htdocs`.
2. Start Apache from the XAMPP Control Panel.
3. Access the app at: `http://localhost/your_folder_name/UI/index.html`

---

## 🧪 Testing the Software

### 1. Test the Logic Tier (XML API)
Before testing the UI, verify that the backend is serving the correct data format:
- Open your browser and navigate to: `http://localhost/your_project_name/api/get_books.php`
- **Expected Result**: You should see an XML document containing the list of books from the database.

### 2. Test the Presentation Tier (AJAX)
- Navigate to: `http://localhost/your_project_name/UI/index.html`
- **Verification Steps**:
  - The "Discover Books" section should initially show "Loading books...".
  - Within a second, the book cards should appear dynamically, fetched from the MySQL database.
  - Check the **Network** tab in Browser DevTools (`F12`) to see the `get_books.php` request returning an XML response.

### 3. Test UI Features
- **Theme Toggle**: Click the moon/sun icon to switch between Dark and Light modes.
- **Scroll to Top**: Scroll down the page and verify the "Up" arrow appears and works.
- **Search**: (Experimental) Use the search bar to filter cards in real-time.

---

## 📂 Project Structure

- **/UI**: Presentation Layer (HTML, CSS, JS).
- **/api**: Logic Layer (PHP scripts serving XML).
- **/database**: Data Layer (SQL schema).
- **/exp2**: Experimental XML/XSLT files.

---

## 📖 Architecture Note
This software demonstrates a decoupled architecture where the **Frontend** never communicates with the **Database** directly. Instead, it requests **XML** data from the **PHP middle-tier**, which manages all database security and logic.
