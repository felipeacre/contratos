<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_admin();

$id = (int)($_GET['id'] ?? 0);
if (!$id) redirect(BASE_URL . '/modules/licitacoes/index.php');

$db   = Database::get();
$stmt = $db->prepare('SELECT numero_processo FROM licitacoes WHERE id = ?');
$stmt->execute([$id]);
$l = $stmt->fetch();

if (!$l) {
    flash('danger', 'Licitação não encontrada.');
    redirect(BASE_URL . '/modules/licitacoes/index.php');
}

$db->prepare('DELETE FROM licitacoes WHERE id = ?')->execute([$id]);
flash('success', 'Licitação ' . $l['numero_processo'] . ' excluída.');
redirect(BASE_URL . '/modules/licitacoes/index.php');
