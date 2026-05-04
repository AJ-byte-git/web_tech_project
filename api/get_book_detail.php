<?php
include 'db.php';

header('Content-Type: text/xml; charset=utf-8');

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;

try {
    if (!isset($pdo)) {
        throw new Exception("Database connection not established.");
    }
    if ($id <= 0) {
        throw new Exception("Invalid book ID.");
    }

    $stmt = $pdo->prepare(
        "SELECT b.*, c.name AS category_name,
                CONCAT(u.first_name, ' ', u.last_name) AS seller_name
         FROM books b
         JOIN categories c ON b.category_id = c.id
         LEFT JOIN users u ON b.seller_id = u.id
         WHERE b.id = ?"
    );
    $stmt->execute([$id]);
    $book = $stmt->fetch(PDO::FETCH_ASSOC);

    echo '<?xml version="1.0" encoding="UTF-8"?>';

    if (!$book) {
        echo '<book><error>Book not found.</error></book>';
    } else {
        echo '<book>';
        echo '<id>'            . $book['id']                                    . '</id>';
        echo '<title>'         . htmlspecialchars($book['title'])               . '</title>';
        echo '<author>'        . htmlspecialchars($book['author'])              . '</author>';
        echo '<description>'   . htmlspecialchars($book['description'])         . '</description>';
        echo '<category>'      . htmlspecialchars($book['category_name'])       . '</category>';
        echo '<price>'         . $book['price']                                 . '</price>';
        echo '<rent_price>'    . ($book['rent_price'] ?? '')                    . '</rent_price>';
        echo '<quantity>'      . $book['quantity']                              . '</quantity>';
        echo '<is_used>'       . ($book['is_used'] ? 'true' : 'false')         . '</is_used>';
        echo '<seller>'        . htmlspecialchars($book['seller_name'] ?? 'BookHaven') . '</seller>';
        echo '<image_url>'     . htmlspecialchars($book['image_url'])           . '</image_url>';
        echo '<created_at>'    . $book['created_at']                           . '</created_at>';
        echo '</book>';
    }
} catch (Exception $e) {
    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<book><error>' . htmlspecialchars($e->getMessage()) . '</error></book>';
}
?>
