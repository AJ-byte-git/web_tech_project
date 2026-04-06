$(function() {
    // Form Enhancement
    $('input').on('focus', function() { $(this).css('transform', 'scale(1.02)'); });
    $('input').on('blur', function() { $(this).css('transform', 'scale(1)'); });

    // Live Search
    $('.search-container input').on('keyup', function() {
        const val = $(this).val().toLowerCase();
        $('.book-card').each(function() {
            const match = $(this).text().toLowerCase().includes(val);
            $(this).parent().toggle(match);
        });
    });

    // Quick Add Notification
    $('.quick-add-btn').on('click', function(e) {
        e.preventDefault();
        const title = $(this).closest('.book-card').find('h3').text();
        toast(`Added "${title}" to cart!`, 'success');
    });

    // Simple Form Validation
    $('form').on('submit', function(e) {
        let valid = true;
        $(this).find('input[required]').each(function() {
            if (!$(this).val()) {
                $(this).addClass('input-error').fadeOut(100).fadeIn(100);
                valid = false;
            } else { $(this).removeClass('input-error'); }
        });
        if (!valid) e.preventDefault();
        else toast('Form submitted successfully!', 'success');
    });
});
