// Vanilla JavaScript Features
const toast = (msg, type = 'success') => {
    const t = document.createElement('div');
    t.className = `toast ${type}`;
    t.innerHTML = `<i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i> ${msg}`;
    document.getElementById('toast-container').appendChild(t);
    setTimeout(() => t.remove(), 3000);
};

// Theme Manager
const toggleTheme = () => {
    const isDark = document.body.classList.toggle('dark-theme');
    localStorage.setItem('theme', isDark ? 'dark' : 'light');
    document.querySelector('.theme-toggle i').className = isDark ? 'fas fa-sun' : 'fas fa-moon';
};

document.querySelector('.theme-toggle')?.addEventListener('click', toggleTheme);
if (localStorage.getItem('theme') === 'dark') toggleTheme();

// Back to Top
const btt = document.querySelector('.back-to-top');
window.addEventListener('scroll', () => btt.style.display = window.scrollY > 300 ? 'flex' : 'none');
btt?.addEventListener('click', (e) => {
    e.preventDefault();
    window.scrollTo({ top: 0, behavior: 'smooth' });
});

// 3-Tier AJAX & XML Logic
const loadBooks = () => {
    const xhr = new XMLHttpRequest();
    xhr.open('GET', '../api/get_books.php', true);

    xhr.onreadystatechange = function () {
        if (this.readyState === 4) {
            const grid = document.getElementById('book-grid');
            if (this.status === 200) {
                const xml = this.responseXML;
                if (!xml) {
                    grid.innerHTML = '<div class="error-state">Error parsing data from server.</div>';
                    return;
                }

                const errorNode = xml.getElementsByTagName('error')[0];
                if (errorNode) {
                    grid.innerHTML = `<div class="error-state">Database Error: ${errorNode.textContent}</div>`;
                    toast("Database error occurred", "error");
                    return;
                }

                const books = xml.getElementsByTagName('book');
                grid.innerHTML = '';

                if (books.length === 0) {
                    grid.innerHTML = '<div class="empty-state">No books found in the database.</div>';
                    return;
                }

                for (let i = 0; i < books.length; i++) {
                    const title = books[i].getElementsByTagName('title')[0].textContent;
                    const author = books[i].getElementsByTagName('author')[0].textContent;
                    const price = books[i].getElementsByTagName('price')[0].textContent;
                    const rent = books[i].getElementsByTagName('rent_price')[0].textContent;

                    const card = `
                        <a href="book-details.html">
                            <div class="book-card">
                                <div class="book-img">Book Cover</div>
                                <div class="book-info">
                                    <h3>${title}</h3>
                                    <p class="book-author">${author}</p>
                                </div>
                                <div class="book-footer">
                                    <span class="price">$${price}</span>
                                    <span class="rent-tag">Rent $${rent}</span>
                                </div>
                                <div class="quick-add-btn"><i class="fas fa-cart-plus"></i></div>
                            </div>
                        </a>
                    `;
                    grid.innerHTML += card;
                }
            } else {
                grid.innerHTML = '<div class="error-state">Failed to connect to the server.</div>';
                toast("Server connection failed", "error");
            }
        }
    };
    xhr.send();
};

document.addEventListener('DOMContentLoaded', loadBooks);
