<?php
require_once __DIR__ . '/includes/bootstrap.php';
Auth::require_login();

$db = Database::get();

// Resumo
$resumo = $db->query('SELECT * FROM vw_dashboard_resumo')->fetch();

// Contratos críticos (vencidos + críticos + atenção)
$criticos = $db->query("
    SELECT numero, objeto, fornecedor_display, fornecedor_cnpj, data_vencimento,
           dias_para_vencer, status_vencimento, valor_total, saldo_atual
    FROM vw_contratos
    WHERE status_vencimento IN ('vencido','critico','atencao')
      AND (status_manual IS NULL OR status_manual = 'ativo')
    ORDER BY dias_para_vencer ASC
    LIMIT 20
")->fetchAll();

// Licitações em andamento
$licitacoes = $db->query("
    SELECT numero_processo, objeto, modalidade, status, data_abertura, data_prevista_conclusao
    FROM licitacoes
    WHERE status IN ('em_andamento','aguardando_homologacao')
    ORDER BY data_abertura DESC
    LIMIT 15
")->fetchAll();

// Contratos por mês de vencimento (próximos 12 meses)
$por_mes = $db->query("
    SELECT DATE_FORMAT(data_vencimento,'%Y-%m') AS mes,
           DATE_FORMAT(data_vencimento,'%b/%Y') AS mes_label,
           COUNT(*) AS total
    FROM contratos
    WHERE data_vencimento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 12 MONTH)
      AND (status_manual IS NULL OR status_manual = 'ativo')
    GROUP BY DATE_FORMAT(data_vencimento,'%Y-%m'), DATE_FORMAT(data_vencimento,'%b/%Y')
    ORDER BY DATE_FORMAT(data_vencimento,'%Y-%m')
")->fetchAll();

$page_title = 'Painel';
include __DIR__ . '/includes/header.php';
?>

<div class="row g-3 mb-4">

    <!-- Cards de status -->
    <div class="col-6 col-sm-4 col-lg-2">
        <div class="card card-status card-vencido h-100 p-3">
            <div class="text-danger display-4 fw-bold"><?= $resumo['vencidos'] ?? 0 ?></div>
            <div class="text-muted small mt-1"><i class="bi bi-exclamation-circle-fill text-danger"></i> Vencidos</div>
        </div>
    </div>
    <div class="col-6 col-sm-4 col-lg-2">
        <div class="card card-status card-critico h-100 p-3">
            <div class="text-warning display-4 fw-bold"><?= $resumo['criticos'] ?? 0 ?></div>
            <div class="text-muted small mt-1"><i class="bi bi-exclamation-triangle-fill text-warning"></i> Críticos (30d)</div>
        </div>
    </div>
    <div class="col-6 col-sm-4 col-lg-2">
        <div class="card card-status card-atencao h-100 p-3">
            <div style="color:#fd7e14" class="display-4 fw-bold"><?= $resumo['atencao'] ?? 0 ?></div>
            <div class="text-muted small mt-1"><i class="bi bi-clock-fill" style="color:#fd7e14"></i> Atenção (90d)</div>
        </div>
    </div>
    <div class="col-6 col-sm-4 col-lg-2">
        <div class="card card-status card-alerta h-100 p-3">
            <div class="text-info display-4 fw-bold"><?= $resumo['alerta'] ?? 0 ?></div>
            <div class="text-muted small mt-1"><i class="bi bi-info-circle-fill text-info"></i> Alerta (180d)</div>
        </div>
    </div>
    <div class="col-6 col-sm-4 col-lg-2">
        <div class="card card-status card-regular h-100 p-3">
            <div class="text-success display-4 fw-bold"><?= $resumo['regulares'] ?? 0 ?></div>
            <div class="text-muted small mt-1"><i class="bi bi-check-circle-fill text-success"></i> Regulares</div>
        </div>
    </div>
    <div class="col-6 col-sm-4 col-lg-2">
        <div class="card card-status h-100 p-3">
            <div class="fw-bold fs-5 text-primary"><?= moeda($resumo['saldo_total_carteira'] ?? 0) ?></div>
            <div class="text-muted small mt-1"><i class="bi bi-currency-dollar"></i> Saldo Total</div>
            <div class="text-muted" style="font-size:.7rem">Carteira: <?= moeda($resumo['valor_total_carteira'] ?? 0) ?></div>
        </div>
    </div>

</div>

<div class="row g-3">

    <!-- Contratos críticos -->
    <div class="col-12 col-xl-7">
        <div class="card shadow-sm">
            <div class="card-header d-flex align-items-center gap-2 bg-white border-bottom">
                <i class="bi bi-exclamation-triangle-fill text-warning"></i>
                <strong>Contratos que precisam de atenção</strong>
                <span class="badge bg-secondary ms-auto"><?= count($criticos) ?></span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-sm mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Nº</th>
                                <th>Objeto</th>
                                <th>Fornecedor</th>
                                <th>Vencimento</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($criticos as $c): ?>
                        <tr data-status="<?= sanitize($c['status_vencimento']) ?>">
                            <td>
                                <a href="<?= BASE_URL ?>/modules/contratos/view.php?id=<?= urlencode($c['numero']) ?>"
                                   class="text-decoration-none fw-semibold">
                                    <?= sanitize($c['numero']) ?>
                                </a>
                            </td>
                            <td class="text-truncate" style="max-width:160px" title="<?= sanitize($c['objeto']) ?>">
                                <?= sanitize($c['objeto']) ?>
                            </td>
                            <td class="text-truncate" style="max-width:130px">
                                <?= sanitize($c['fornecedor_display'] ?? '—') ?>
                            </td>
                            <td><?= data_br($c['data_vencimento']) ?></td>
                            <td>
                                <?php
                                $dias = (int)$c['dias_para_vencer'];
                                if ($dias < 0) {
                                    echo '<span class="badge bg-danger">Vencido há ' . abs($dias) . 'd</span>';
                                } elseif ($dias <= 30) {
                                    echo '<span class="badge bg-warning text-dark">Vence em ' . $dias . 'd</span>';
                                } else {
                                    echo '<span class="badge bg-atencao">Vence em ' . $dias . 'd</span>';
                                }
                                ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($criticos)): ?>
                        <tr><td colspan="5" class="text-center text-muted py-4">
                            <i class="bi bi-check-circle text-success fs-3 d-block mb-2"></i>
                            Nenhum contrato crítico no momento.
                        </td></tr>
                        <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer bg-white text-end">
                <a href="<?= BASE_URL ?>/modules/contratos/index.php" class="btn btn-sm btn-outline-primary">
                    Ver todos os contratos <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </div>
    </div>

    <!-- Licitações em andamento -->
    <div class="col-12 col-xl-5">
        <div class="card shadow-sm">
            <div class="card-header d-flex align-items-center gap-2 bg-white border-bottom">
                <i class="bi bi-clipboard2-data text-info"></i>
                <strong>Licitações em Andamento</strong>
                <span class="badge bg-secondary ms-auto"><?= count($licitacoes) ?></span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover table-sm mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Processo</th>
                                <th>Objeto</th>
                                <th>Modalidade</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($licitacoes as $l): ?>
                        <tr>
                            <td class="fw-semibold"><?= sanitize($l['numero_processo']) ?></td>
                            <td class="text-truncate" style="max-width:150px" title="<?= sanitize($l['objeto']) ?>">
                                <?= sanitize($l['objeto']) ?>
                            </td>
                            <td><?= sanitize(modalidade_label($l['modalidade'])) ?></td>
                            <td><?= badge_licitacao($l['status']) ?></td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($licitacoes)): ?>
                        <tr><td colspan="4" class="text-center text-muted py-4">
                            Nenhuma licitação em andamento.
                        </td></tr>
                        <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer bg-white text-end">
                <a href="<?= BASE_URL ?>/modules/licitacoes/index.php" class="btn btn-sm btn-outline-info">
                    Ver todas <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </div>
    </div>

</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
