<?php
include 'db.php';

header('Content-Type: text/xml; charset=utf-8');

// In a real app, user_id comes from session. Using query param for demo.
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 1;

try {
    if (!isset($pdo)) {
        throw new Exception("Database connection not established.");
    }

    // Fetch orders with book titles concatenated
    $stmt = $pdo->prepare(
        "SELECT o.id, o.order_date, o.total_amount, o.status,
                GROUP_CONCAT(b.title ORDER BY b.title SEPARATOR ', ') AS book_titles,
                COUNT(bt.id) AS item_count
         FROM orders o
         LEFT JOIN buy_transactions bt ON bt.order_id = o.id
         LEFT JOIN books b ON bt.book_id = b.id
         WHERE o.user_id = ?
         GROUP BY o.id
         ORDER BY o.order_date DESC"
    );
    $stmt->execute([$user_id]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<orders>';
    echo '<user_id>' . $user_id . '</user_id>';

    foreach ($orders as $order) {
        echo '<order>';
        echo '<id>'          . $order['id']                                        . '</id>';
        echo '<order_date>'  . date('M d, Y', strtotime($order['order_date']))     . '</order_date>';
        echo '<total>'       . number_format($order['total_amount'], 2)            . '</total>';
        echo '<status>'      . htmlspecialchars($order['status'])                  . '</status>';
        echo '<item_count>'  . $order['item_count']                                . '</item_count>';
        echo '<books>'       . htmlspecialchars($order['book_titles'] ?? 'N/A')    . '</books>';
        echo '</order>';
    }

    echo '</orders>';
} catch (Exception $e) {
    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<orders><error>' . htmlspecialchars($e->getMessage()) . '</error></orders>';
}
?>
