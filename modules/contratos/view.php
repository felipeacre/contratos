<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db = Database::get();
$id = (int)($_GET['id'] ?? 0);
if (!$id) redirect(BASE_URL . '/modules/contratos/index.php');

$stmt = $db->prepare('SELECT * FROM vw_contratos WHERE id = ?');
$stmt->execute([$id]);
$c = $stmt->fetch();
if (!$c) { flash('danger', 'Contrato não encontrado.'); redirect(BASE_URL . '/modules/contratos/index.php'); }

// Aditivos
$aditivos = $db->prepare('SELECT * FROM aditivos WHERE contrato_id = ? ORDER BY data_assinatura DESC');
$aditivos->execute([$id]);
$aditivos = $aditivos->fetchAll();

// Documentos
$docs = $db->prepare("SELECT * FROM documentos WHERE tipo = 'contrato' AND referencia_id = ? ORDER BY created_at DESC");
$docs->execute([$id]);
$docs = $docs->fetchAll();

// Salvar novo aditivo
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['acao']) && $_POST['acao'] === 'aditivo') {
    $a = $_POST;
    if (!empty($a['numero_aditivo']) && !empty($a['tipo']) && !empty($a['data_assinatura'])) {
        $nova_data = ($a['nova_data_vencimento'] ?? '') ?: null;
        $db->prepare("
            INSERT INTO aditivos (contrato_id, numero_aditivo, tipo, data_assinatura, nova_data_vencimento, valor_acrescimo, valor_reducao, justificativa)
            VALUES (?,?,?,?,?,?,?,?)
        ")->execute([
            $id,
            trim($a['numero_aditivo']),
            $a['tipo'],
            $a['data_assinatura'],
            $nova_data,
            (float) str_replace(',','.', $a['valor_acrescimo'] ?? 0),
            (float) str_replace(',','.', $a['valor_reducao']   ?? 0),
            trim($a['justificativa'] ?? ''),
        ]);

        // Atualiza vencimento se o aditivo alterou o prazo
        if ($nova_data) {
            $db->prepare('UPDATE contratos SET data_vencimento = ? WHERE id = ?')->execute([$nova_data, $id]);
        }

        // Atualiza valor total se houver acréscimo/redução
        $acrescimo = (float) str_replace(',','.', $a['valor_acrescimo'] ?? 0);
        $reducao   = (float) str_replace(',','.', $a['valor_reducao']   ?? 0);
        if ($acrescimo > 0 || $reducao > 0) {
            $db->prepare('UPDATE contratos SET valor_total = valor_total + ? - ?, saldo_atual = saldo_atual + ? - ? WHERE id = ?')
               ->execute([$acrescimo, $reducao, $acrescimo, $reducao, $id]);
        }

        flash('success', 'Aditivo registrado com sucesso.');
        redirect(BASE_URL . '/modules/contratos/view.php?id=' . $id);
    }
}

$page_title = 'Contrato ' . $c['numero'];
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center gap-2 mb-3 flex-wrap">
    <a href="index.php" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
    <h5 class="mb-0 fw-bold">Contrato <?= sanitize($c['numero']) ?></h5>
    <?= badge_status($c['status_vencimento']) ?>
    <div class="ms-auto d-flex gap-2">
        <a href="form.php?id=<?= $id ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i> Editar</a>
    </div>
</div>

<div class="row g-3">

    <!-- Dados principais -->
    <div class="col-lg-8">
        <div class="card shadow-sm mb-3">
            <div class="card-header bg-white fw-bold"><i class="bi bi-info-circle text-primary"></i> Dados do Contrato</div>
            <div class="card-body">
                <div class="row g-2">
                    <div class="col-sm-4"><span class="text-muted small">Processo</span><div><?= sanitize($c['numero_processo'] ?? '—') ?></div></div>
                    <div class="col-sm-4"><span class="text-muted small">Modalidade</span><div><?= sanitize(modalidade_label($c['modalidade'] ?? '')) ?></div></div>
                    <div class="col-sm-4"><span class="text-muted small">Origem</span><div><?= sanitize($c['origem']) ?></div></div>
                    <div class="col-12"><span class="text-muted small">Objeto</span><div class="fw-semibold"><?= sanitize($c['objeto']) ?></div></div>
                    <div class="col-sm-6"><span class="text-muted small">Fornecedor</span><div><?= sanitize($c['fornecedor_display'] ?? '—') ?></div></div>
                    <div class="col-sm-6"><span class="text-muted small">CNPJ</span><div><?= sanitize(cnpj_format($c['cnpj_display'] ?? '')) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">Assinatura</span><div><?= data_br($c['data_assinatura']) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">Início</span><div><?= data_br($c['data_inicio']) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">Vencimento</span><div class="fw-bold"><?= data_br($c['data_vencimento']) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">Dias p/ Vencer</span>
                        <div>
                        <?php
                        $dias = (int)$c['dias_para_vencer'];
                        if ($dias < 0) echo '<span class="text-danger fw-bold">Vencido há ' . abs($dias) . ' dias</span>';
                        else           echo '<span class="fw-bold">' . $dias . ' dias</span>';
                        ?>
                        </div>
                    </div>
                    <div class="col-sm-3"><span class="text-muted small">Valor Total</span><div class="fw-bold text-primary"><?= moeda($c['valor_total']) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">Valor Executado</span><div><?= moeda($c['valor_executado'] ?? 0) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">Saldo Atual</span><div class="fw-bold text-success"><?= moeda($c['saldo_atual']) ?></div></div>
                    <div class="col-sm-3"><span class="text-muted small">% Executado</span>
                        <div>
                            <div class="progress" style="height:8px;margin-top:6px">
                                <div class="progress-bar bg-info" style="width:<?= min(100, $c['percentual_executado'] ?? 0) ?>%"></div>
                            </div>
                            <small><?= number_format($c['percentual_executado'] ?? 0, 1) ?>%</small>
                        </div>
                    </div>
                    <?php if ($c['gestor_nome']): ?>
                    <div class="col-sm-6"><span class="text-muted small">Gestor</span><div><?= sanitize($c['gestor_nome']) ?> <?= $c['gestor_matricula'] ? '(' . sanitize($c['gestor_matricula']) . ')' : '' ?></div></div>
                    <?php endif; ?>
                    <?php if ($c['fiscal_nome']): ?>
                    <div class="col-sm-6"><span class="text-muted small">Fiscal</span><div><?= sanitize($c['fiscal_nome']) ?> <?= $c['fiscal_matricula'] ? '(' . sanitize($c['fiscal_matricula']) . ')' : '' ?></div></div>
                    <?php endif; ?>
                    <?php if ($c['dotacao_orcamentaria']): ?>
                    <div class="col-12"><span class="text-muted small">Dotação Orçamentária</span><div><?= sanitize($c['dotacao_orcamentaria']) ?></div></div>
                    <?php endif; ?>
                    <?php if ($c['observacoes']): ?>
                    <div class="col-12"><span class="text-muted small">Observações</span><div class="text-muted"><?= nl2br(sanitize($c['observacoes'])) ?></div></div>
                    <?php endif; ?>
                </div>
            </div>
        </div>

        <!-- Aditivos -->
        <div class="card shadow-sm">
            <div class="card-header bg-white d-flex align-items-center justify-content-between">
                <span class="fw-bold"><i class="bi bi-plus-slash-minus text-warning"></i> Aditivos</span>
                <button class="btn btn-sm btn-outline-warning" data-bs-toggle="collapse" data-bs-target="#form-aditivo">
                    <i class="bi bi-plus-lg"></i> Registrar Aditivo
                </button>
            </div>

            <!-- Form aditivo colapsável -->
            <div class="collapse" id="form-aditivo">
                <div class="card-body border-bottom bg-light">
                    <form method="post" novalidate>
                        <input type="hidden" name="acao" value="aditivo">
                        <div class="row g-2">
                            <div class="col-md-3">
                                <label class="form-label small fw-semibold">Nº do Aditivo</label>
                                <input type="text" name="numero_aditivo" class="form-control form-control-sm" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small fw-semibold">Tipo</label>
                                <select name="tipo" class="form-select form-select-sm">
                                    <option value="prazo">Prazo</option>
                                    <option value="valor">Valor</option>
                                    <option value="prazo_e_valor">Prazo e Valor</option>
                                    <option value="objeto">Objeto</option>
                                    <option value="rescisao">Rescisão</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small fw-semibold">Data de Assinatura</label>
                                <input type="date" name="data_assinatura" class="form-control form-control-sm" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small fw-semibold">Novo Vencimento</label>
                                <input type="date" name="nova_data_vencimento" class="form-control form-control-sm">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small fw-semibold">Valor Acréscimo (R$)</label>
                                <input type="text" name="valor_acrescimo" class="form-control form-control-sm mask-money" value="0,00">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small fw-semibold">Valor Redução (R$)</label>
                                <input type="text" name="valor_reducao" class="form-control form-control-sm mask-money" value="0,00">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-semibold">Justificativa</label>
                                <input type="text" name="justificativa" class="form-control form-control-sm">
                            </div>
                            <div class="col-12 text-end">
                                <button type="submit" class="btn btn-sm btn-warning">
                                    <i class="bi bi-check-lg"></i> Salvar Aditivo
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card-body p-0">
                <?php if (empty($aditivos)): ?>
                <p class="text-muted text-center py-3 mb-0">Nenhum aditivo registrado.</p>
                <?php else: ?>
                <table class="table table-sm mb-0">
                    <thead class="table-light">
                        <tr><th>Nº</th><th>Tipo</th><th>Assinatura</th><th>Novo Vencimento</th><th>Acréscimo</th><th>Redução</th><th>Justificativa</th></tr>
                    </thead>
                    <tbody>
                    <?php foreach ($aditivos as $a): ?>
                    <tr>
                        <td><?= sanitize($a['numero_aditivo']) ?></td>
                        <td><?= sanitize(ucfirst(str_replace('_',' ',$a['tipo']))) ?></td>
                        <td><?= data_br($a['data_assinatura']) ?></td>
                        <td><?= $a['nova_data_vencimento'] ? data_br($a['nova_data_vencimento']) : '—' ?></td>
                        <td class="text-success"><?= $a['valor_acrescimo'] > 0 ? moeda($a['valor_acrescimo']) : '—' ?></td>
                        <td class="text-danger"><?= $a['valor_reducao'] > 0 ? moeda($a['valor_reducao']) : '—' ?></td>
                        <td><?= sanitize($a['justificativa'] ?? '—') ?></td>
                    </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Sidebar: documentos + saldo -->
    <div class="col-lg-4">
        <!-- Saldo visual -->
        <div class="card shadow-sm mb-3">
            <div class="card-header bg-white fw-bold"><i class="bi bi-pie-chart text-info"></i> Saldo do Contrato</div>
            <div class="card-body text-center">
                <?php
                $perc = min(100, (float)($c['percentual_executado'] ?? 0));
                $cor  = $perc >= 90 ? '#dc3545' : ($perc >= 70 ? '#fd7e14' : '#0dcaf0');
                ?>
                <div style="position:relative;display:inline-block;margin:8px 0">
                    <svg viewBox="0 0 120 120" width="130" height="130">
                        <circle cx="60" cy="60" r="50" fill="none" stroke="#e9ecef" stroke-width="14"/>
                        <circle cx="60" cy="60" r="50" fill="none" stroke="<?= $cor ?>" stroke-width="14"
                                stroke-dasharray="<?= round($perc * 3.14159) ?> 314.159"
                                stroke-linecap="round"
                                transform="rotate(-90 60 60)"/>
                        <text x="60" y="55" text-anchor="middle" font-size="18" font-weight="bold" fill="#333"><?= number_format($perc,0) ?>%</text>
                        <text x="60" y="72" text-anchor="middle" font-size="9" fill="#888">executado</text>
                    </svg>
                </div>
                <div class="row text-center mt-2 g-1">
                    <div class="col-6">
                        <div class="small text-muted">Valor Total</div>
                        <div class="fw-bold"><?= moeda($c['valor_total']) ?></div>
                    </div>
                    <div class="col-6">
                        <div class="small text-muted">Saldo</div>
                        <div class="fw-bold text-success"><?= moeda($c['saldo_atual']) ?></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Documentos -->
        <div class="card shadow-sm">
            <div class="card-header bg-white fw-bold"><i class="bi bi-paperclip"></i> Documentos</div>
            <div class="card-body p-0">
                <?php if (empty($docs)): ?>
                <p class="text-muted text-center py-3 mb-0 small">Nenhum documento anexado.</p>
                <?php else: ?>
                <ul class="list-group list-group-flush">
                    <?php foreach ($docs as $doc): ?>
                    <li class="list-group-item d-flex align-items-center justify-content-between py-2">
                        <span class="small text-truncate me-2"><?= sanitize($doc['nome_original']) ?></span>
                        <a href="<?= BASE_URL ?>/uploads/pdfs/<?= sanitize($doc['nome_arquivo']) ?>" target="_blank"
                           class="btn btn-sm btn-outline-secondary py-0 px-1">
                            <i class="bi bi-download"></i>
                        </a>
                    </li>
                    <?php endforeach; ?>
                </ul>
                <?php endif; ?>
            </div>
        </div>
    </div>

</div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
