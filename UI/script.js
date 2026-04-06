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
