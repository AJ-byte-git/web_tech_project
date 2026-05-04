<?php
include 'db.php';

header('Content-Type: text/xml; charset=utf-8');

// In a real app, user_id comes from session. Using query param for demo.
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 1;

try {
    if (!isset($pdo)) {
        throw new Exception("Database connection not established.");
    }

    // User profile
    $stmt = $pdo->prepare(
        "SELECT id, first_name, last_name, email, phone, role, created_at FROM users WHERE id = ?"
    );
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo '<?xml version="1.0" encoding="UTF-8"?>';
        echo '<user><error>User not found.</error></user>';
        exit;
    }

    // Stats: total orders
    $stmtOrders = $pdo->prepare("SELECT COUNT(*) AS cnt FROM orders WHERE user_id = ?");
    $stmtOrders->execute([$user_id]);
    $order_count = $stmtOrders->fetchColumn();

    // Stats: active rentals
    $stmtRent = $pdo->prepare("SELECT COUNT(*) AS cnt FROM rentals WHERE user_id = ? AND status = 'issued'");
    $stmtRent->execute([$user_id]);
    $active_rentals = $stmtRent->fetchColumn();

    // Stats: books sold
    $stmtSold = $pdo->prepare("SELECT COUNT(*) AS cnt FROM sale_transactions WHERE user_id = ?");
    $stmtSold->execute([$user_id]);
    $books_sold = $stmtSold->fetchColumn();

    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<user>';
    echo '<id>'             . $user['id']                                  . '</id>';
    echo '<first_name>'     . htmlspecialchars($user['first_name'])        . '</first_name>';
    echo '<last_name>'      . htmlspecialchars($user['last_name'])         . '</last_name>';
    echo '<email>'          . htmlspecialchars($user['email'])             . '</email>';
    echo '<phone>'          . htmlspecialchars($user['phone'] ?? '')       . '</phone>';
    echo '<role>'           . $user['role']                                . '</role>';
    echo '<member_since>'   . date('M Y', strtotime($user['created_at'])) . '</member_since>';
    echo '<stats>';
    echo '<total_orders>'   . $order_count    . '</total_orders>';
    echo '<active_rentals>' . $active_rentals . '</active_rentals>';
    echo '<books_sold>'     . $books_sold     . '</books_sold>';
    echo '</stats>';
    echo '</user>';
} catch (Exception $e) {
    echo '<?xml version="1.0" encoding="UTF-8"?>';
    echo '<user><error>' . htmlspecialchars($e->getMessage()) . '</error></user>';
}
?>
