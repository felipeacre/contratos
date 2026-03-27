<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db = Database::get();

$where  = ['1=1'];
$params = [];

$status_f = $_GET['status'] ?? '';
if ($status_f) {
    $where[] = 'status = ?';
    $params[] = $status_f;
}

$busca = trim($_GET['busca'] ?? '');
if ($busca) {
    $where[] = '(numero_processo LIKE ? OR objeto LIKE ?)';
    $like = '%' . $busca . '%';
    $params[] = $like;
    $params[] = $like;
}

$sql  = 'SELECT * FROM licitacoes WHERE ' . implode(' AND ', $where) . ' ORDER BY created_at DESC';
$stmt = $db->prepare($sql);
$stmt->execute($params);
$licitacoes = $stmt->fetchAll();

$page_title = 'Licitações';
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
    <h5 class="mb-0 fw-bold"><i class="bi bi-clipboard2-data text-info"></i> Licitações</h5>
    <div class="d-flex gap-2">
        <a href="form.php" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg"></i> Nova Licitação</a>
        <a href="<?= BASE_URL ?>/modules/importacao/index.php" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-upload"></i> Importar
        </a>
    </div>
</div>

<!-- Filtros rápidos -->
<div class="d-flex gap-2 mb-3 flex-wrap">
    <a href="index.php" class="btn btn-sm <?= !$status_f ? 'btn-dark' : 'btn-outline-secondary' ?>">Todas</a>
    <a href="?status=em_andamento"           class="btn btn-sm <?= $status_f==='em_andamento'           ? 'btn-primary'   : 'btn-outline-primary' ?>">Em Andamento</a>
    <a href="?status=aguardando_homologacao" class="btn btn-sm <?= $status_f==='aguardando_homologacao' ? 'btn-warning'   : 'btn-outline-warning' ?>">Aguard. Homologação</a>
    <a href="?status=homologada"             class="btn btn-sm <?= $status_f==='homologada'             ? 'btn-success'   : 'btn-outline-success' ?>">Homologadas</a>
    <a href="?status=cancelada"              class="btn btn-sm <?= $status_f==='cancelada'              ? 'btn-danger'    : 'btn-outline-danger'  ?>">Canceladas</a>
    <a href="?status=deserta"                class="btn btn-sm <?= $status_f==='deserta'                ? 'btn-secondary' : 'btn-outline-secondary' ?>">Desertas</a>
</div>

<div class="card shadow-sm">
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover datatable mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Processo</th>
                        <th>Nº Licitação</th>
                        <th>Objeto</th>
                        <th>Modalidade</th>
                        <th>Valor Estimado</th>
                        <th>Abertura</th>
                        <th>Previsão Conclusão</th>
                        <th>Status</th>
                        <th class="text-center">Ações</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($licitacoes as $l): ?>
                <tr>
                    <td class="fw-semibold"><?= sanitize($l['numero_processo']) ?></td>
                    <td><?= sanitize($l['numero_licitacao'] ?? '—') ?></td>
                    <td class="text-truncate" style="max-width:220px" title="<?= sanitize($l['objeto']) ?>">
                        <?= sanitize($l['objeto']) ?>
                    </td>
                    <td><?= sanitize(modalidade_label($l['modalidade'])) ?></td>
                    <td><?= $l['valor_estimado'] ? moeda($l['valor_estimado']) : '—' ?></td>
                    <td><?= data_br($l['data_abertura']) ?></td>
                    <td><?= data_br($l['data_prevista_conclusao']) ?></td>
                    <td><?= badge_licitacao($l['status']) ?></td>
                    <td class="text-center text-nowrap">
                        <a href="form.php?id=<?= (int)$l['id'] ?>" class="btn btn-sm btn-outline-primary" title="Editar">
                            <i class="bi bi-pencil"></i>
                        </a>
                        <?php if (Auth::is_admin()): ?>
                        <a href="delete.php?id=<?= (int)$l['id'] ?>"
                           class="btn btn-sm btn-outline-danger"
                           data-confirm="Confirma a exclusão da licitação <?= sanitize($l['numero_processo']) ?>?">
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
