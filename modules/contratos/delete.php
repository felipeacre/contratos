<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_admin();

$id = (int)($_GET['id'] ?? 0);
if (!$id) redirect(BASE_URL . '/modules/contratos/index.php');

$db   = Database::get();
$stmt = $db->prepare('SELECT numero FROM contratos WHERE id = ?');
$stmt->execute([$id]);
$c = $stmt->fetch();

if (!$c) {
    flash('danger', 'Contrato não encontrado.');
    redirect(BASE_URL . '/modules/contratos/index.php');
}

// Aditivos são deletados em cascata pelo FK
$db->prepare('DELETE FROM contratos WHERE id = ?')->execute([$id]);
flash('success', 'Contrato ' . $c['numero'] . ' excluído.');
redirect(BASE_URL . '/modules/contratos/index.php');
