<?php
include 'db.php';

header('Content-Type: text/xml; charset=utf-8');

// In a real app, user_id comes from session. Using query param for demo.
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 1;

try {
    if (!isset($pdo)) {
        throw new Exception("Database connection not established.");
    }

    $stmt = $pdo->prepare(
        "SELECT c.user_id, c.book_id, c.quantity, c.action,
                b.title, b.author, b.price, b.rent_price, b.image_url
         FROM cart c
         JOIN books b ON c.book_id = b.id
         WHERE c.user_id = ?"
    );
    $stmt->execute([$user_id]);
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<cart>';
    echo '<user_id>' . $user_id . '</user_id>';

    $subtotal = 0;
    foreach ($items as $item) {
        $unit_price = $item['action'] === 'rent' ? (float)$item['rent_price'] : (float)$item['price'];
        $line_total  = $unit_price * (int)$item['quantity'];
        $subtotal   += $line_total;

        echo '<item>';
        echo '<book_id>'    . $item['book_id']                        . '</book_id>';
        echo '<title>'      . htmlspecialchars($item['title'])        . '</title>';
        echo '<author>'     . htmlspecialchars($item['author'])       . '</author>';
        echo '<action>'     . $item['action']                         . '</action>';
        echo '<quantity>'   . $item['quantity']                       . '</quantity>';
        echo '<unit_price>' . number_format($unit_price, 2)           . '</unit_price>';
        echo '<line_total>' . number_format($line_total, 2)           . '</line_total>';
        echo '<image_url>'  . htmlspecialchars($item['image_url'])    . '</image_url>';
        echo '</item>';
    }

    $tax      = round($subtotal * 0.08, 2); // 8% tax
    $total    = $subtotal + $tax;

    echo '<summary>';
    echo '<item_count>' . count($items)              . '</item_count>';
    echo '<subtotal>'   . number_format($subtotal, 2) . '</subtotal>';
    echo '<tax>'        . number_format($tax, 2)      . '</tax>';
    echo '<total>'      . number_format($total, 2)    . '</total>';
    echo '</summary>';

    echo '</cart>';
} catch (Exception $e) {
    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<cart><error>' . htmlspecialchars($e->getMessage()) . '</error></cart>';
}
?>
