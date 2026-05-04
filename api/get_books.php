<?php
include 'db.php';

header('Content-Type: text/xml; charset=utf-8');

try {
    // Check if PDO is initialized
    if (!isset($pdo)) {
        throw new Exception("Database connection not established.");
    }

    $stmt = $pdo->query("SELECT * FROM books");
    $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<books>';

    foreach ($books as $row) {
        echo '<book>';
        echo '<id>' . $row['id'] . '</id>';
        echo '<title>' . htmlspecialchars($row['title']) . '</title>';
        echo '<author>' . htmlspecialchars($row['author']) . '</author>';
        echo '<price>' . $row['price'] . '</price>';
        echo '<rent_price>' . $row['rent_price'] . '</rent_price>';
        echo '<image_url>' . htmlspecialchars($row['image_url']) . '</image_url>';
        echo '</book>';
    }

    echo '</books>';
} catch (Exception $e) {
    // Return an error XML if something goes wrong
    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<books>';
    echo '<error>' . htmlspecialchars($e->getMessage()) . '</error>';
    echo '</books>';
}
?>
