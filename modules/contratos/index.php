<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db = Database::get();

// Filtros
$status_filtro  = $_GET['status'] ?? '';
$busca          = trim($_GET['busca'] ?? '');

$where  = ['1=1'];
$params = [];

if ($status_filtro && in_array($status_filtro, ['vencido','critico','atencao','alerta','regular'])) {
    switch ($status_filtro) {
        case 'vencido':
            $where[] = 'data_vencimento < CURDATE() AND (status_manual IS NULL OR status_manual = "ativo")'; break;
        case 'critico':
            $where[] = 'DATEDIFF(data_vencimento, CURDATE()) BETWEEN 0 AND 30 AND (status_manual IS NULL OR status_manual = "ativo")'; break;
        case 'atencao':
            $where[] = 'DATEDIFF(data_vencimento, CURDATE()) BETWEEN 31 AND 90 AND (status_manual IS NULL OR status_manual = "ativo")'; break;
        case 'alerta':
            $where[] = 'DATEDIFF(data_vencimento, CURDATE()) BETWEEN 91 AND 180 AND (status_manual IS NULL OR status_manual = "ativo")'; break;
        case 'regular':
            $where[] = 'DATEDIFF(data_vencimento, CURDATE()) > 180 AND (status_manual IS NULL OR status_manual = "ativo")'; break;
    }
}

if ($busca !== '') {
    $where[] = '(numero LIKE ? OR objeto LIKE ? OR fornecedor_display LIKE ? OR fornecedor_cnpj LIKE ?)';
    $like = '%' . $busca . '%';
    array_push($params, $like, $like, $like, $like);
}

$sql = 'SELECT * FROM vw_contratos WHERE ' . implode(' AND ', $where) . ' ORDER BY dias_para_vencer ASC';
$stmt = $db->prepare($sql);
$stmt->execute($params);
$contratos = $stmt->fetchAll();

$page_title = 'Contratos';
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
    <h5 class="mb-0 fw-bold"><i class="bi bi-file-earmark-check text-primary"></i> Contratos</h5>
    <div class="d-flex gap-2 flex-wrap">
        <a href="form.php" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg"></i> Novo Contrato
        </a>
        <a href="<?= BASE_URL ?>/modules/importacao/index.php" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-upload"></i> Importar
        </a>
    </div>
</div>

<!-- Filtros rápidos -->
<div class="d-flex gap-2 mb-3 flex-wrap">
    <a href="index.php" class="btn btn-sm <?= !$status_filtro ? 'btn-dark' : 'btn-outline-secondary' ?>">Todos</a>
    <a href="?status=vencido" class="btn btn-sm <?= $status_filtro==='vencido' ? 'btn-danger' : 'btn-outline-danger' ?>">
        <i class="bi bi-x-circle"></i> Vencidos
    </a>
    <a href="?status=critico" class="btn btn-sm <?= $status_filtro==='critico' ? 'btn-warning' : 'btn-outline-warning' ?>">
        Críticos &lt;30d
    </a>
    <a href="?status=atencao" class="btn btn-sm <?= $status_filtro==='atencao' ? 'btn-warning' : 'btn-outline-warning' ?>">
        Atenção &lt;90d
    </a>
    <a href="?status=alerta" class="btn btn-sm <?= $status_filtro==='alerta' ? 'btn-info' : 'btn-outline-info' ?>">
        Alerta &lt;180d
    </a>
    <a href="?status=regular" class="btn btn-sm <?= $status_filtro==='regular' ? 'btn-success' : 'btn-outline-success' ?>">
        <i class="bi bi-check-circle"></i> Regulares
    </a>
</div>

<div class="card shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover datatable mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Nº Contrato</th>
                        <th>Objeto</th>
                        <th>Fornecedor</th>
                        <th>CNPJ</th>
                        <th>Valor Total</th>
                        <th>Saldo</th>
                        <th>Vencimento</th>
                        <th>Status</th>
                        <th class="text-center">Ações</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($contratos as $c): ?>
                <tr data-status="<?= sanitize($c['status_vencimento']) ?>">
                    <td class="fw-semibold"><?= sanitize($c['numero']) ?></td>
                    <td class="text-truncate" style="max-width:200px" title="<?= sanitize($c['objeto']) ?>">
                        <?= sanitize($c['objeto']) ?>
                    </td>
                    <td><?= sanitize($c['fornecedor_display'] ?? '—') ?></td>
                    <td><?= sanitize(cnpj_format($c['cnpj_display'] ?? '')) ?></td>
                    <td><?= moeda($c['valor_total']) ?></td>
                    <td><?= moeda($c['saldo_atual']) ?></td>
                    <td><?= data_br($c['data_vencimento']) ?></td>
                    <td><?= badge_status($c['status_vencimento'] ?? 'regular') ?></td>
                    <td class="text-center text-nowrap">
                        <a href="view.php?id=<?= (int)$c['id'] ?>" class="btn btn-sm btn-outline-secondary" title="Ver">
                            <i class="bi bi-eye"></i>
                        </a>
                        <a href="form.php?id=<?= (int)$c['id'] ?>" class="btn btn-sm btn-outline-primary" title="Editar">
                            <i class="bi bi-pencil"></i>
                        </a>
                        <?php if (Auth::is_admin()): ?>
                        <a href="delete.php?id=<?= (int)$c['id'] ?>"
                           class="btn btn-sm btn-outline-danger"
                           data-confirm="Confirma a exclusão do contrato <?= sanitize($c['numero']) ?>?"
                           title="Excluir">
                            <i class="bi bi-trash"></i>
                        </a>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
