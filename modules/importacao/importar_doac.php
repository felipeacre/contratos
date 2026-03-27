<?php
// ============================================================
// modules/importacao/importar_doac.php
// Chama extrator_doac.py e permite importar licitações e
// publicações do IDAF extraídas do Diário Oficial do Acre.
// ============================================================
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db     = Database::get();
$etapa  = $_GET['etapa'] ?? 'upload';   // upload | revisar | salvar
$errors = [];
$aviso  = [];

// ────────────────────────────────────────────────────────────
// ETAPA 1 — Upload e extração
// ────────────────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $etapa === 'upload') {

    if (empty($_FILES['arquivo']) || $_FILES['arquivo']['error'] !== UPLOAD_ERR_OK) {
        $errors[] = 'Erro no upload do arquivo.';
    } else {
        $ext = strtolower(pathinfo($_FILES['arquivo']['name'], PATHINFO_EXTENSION));
        if ($ext !== 'pdf') {
            $errors[] = 'Apenas arquivos PDF são aceitos.';
        } else {
            $destino = UPLOAD_PDF_DIR . 'doac_' . date('Ymd_His') . '.pdf';
            move_uploaded_file($_FILES['arquivo']['tmp_name'], $destino);

            $modo  = $_POST['modo']  ?? 'ambos';
            $orgao = $_POST['orgao'] ?? 'IDAF';

            $cmd    = sprintf('%s %s %s --modo %s --orgao %s 2>&1',
                escapeshellcmd(PYTHON_BIN),
                escapeshellarg(BASE_PATH . '/python/extrator_doac.py'),
                escapeshellarg($destino),
                escapeshellarg($modo),
                escapeshellarg($orgao)
            );
            $output = shell_exec($cmd);

            if (!$output) {
                $errors[] = 'Script Python não retornou dados. Verifique a instalação do pdfplumber.';
            } else {
                $dados = json_decode($output, true);
                if (!$dados || isset($dados['erro']) && $dados['erro']) {
                    $errors[] = 'Erro na extração: ' . ($dados['erro'] ?? 'resposta inválida.');
                } else {
                    $_SESSION['doac_extraido']  = $dados;
                    $_SESSION['doac_arquivo']   = $destino;
                    $_SESSION['doac_original']  = $_FILES['arquivo']['name'];
                    redirect(BASE_URL . '/modules/importacao/importar_doac.php?etapa=revisar');
                }
            }
        }
    }
}

// ────────────────────────────────────────────────────────────
// ETAPA 2 — Revisão dos dados extraídos
// ────────────────────────────────────────────────────────────
if ($etapa === 'revisar' && empty($_SESSION['doac_extraido'])) {
    redirect(BASE_URL . '/modules/importacao/importar_doac.php');
}

$dados = $_SESSION['doac_extraido'] ?? [];

// ────────────────────────────────────────────────────────────
// ETAPA 3 — Salvar itens selecionados
// ────────────────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $etapa === 'salvar') {
    $selecionados = $_POST['selecionar'] ?? [];
    $importados   = 0;

    foreach ($selecionados as $chave) {
        // chave formato: "tipo|indice" ex: "licitacao|0", "portaria|2"
        [$tipo, $idx] = explode('|', $chave);
        $idx = (int)$idx;

        switch ($tipo) {
            case 'licitacao':
                $l = ($dados['licitacoes_sead'][$idx] ?? $dados['licitacoes'][$idx] ?? null);
                if ($l) importar_licitacao_doac($l, $db) && $importados++;
                break;

            case 'inexigibilidade':
                $i = $dados['inexigibilidades'][$idx] ?? null;
                if ($i) importar_inexigibilidade_doac($i, $db) && $importados++;
                break;

            case 'aditivo':
                $a = $dados['aditivos'][$idx] ?? null;
                if ($a) importar_aditivo_doac($a, $db) && $importados++;
                break;

            case 'portaria':
                // Portarias apenas atualizam gestor/fiscal de contrato existente
                $p = $dados['portarias'][$idx] ?? null;
                if ($p) importar_portaria_doac($p, $db) && $importados++;
                break;
        }
    }

    unset($_SESSION['doac_extraido'], $_SESSION['doac_arquivo'], $_SESSION['doac_original']);

    flash('success', "$importados registro(s) importado(s) do Diário Oficial.");
    redirect(BASE_URL . '/modules/importacao/index.php');
}

// ────────────────────────────────────────────────────────────
// FUNÇÕES DE IMPORTAÇÃO
// ────────────────────────────────────────────────────────────

function importar_licitacao_doac(array $l, PDO $db): bool {
    try {
        $db->prepare("
            INSERT INTO licitacoes
                (numero_processo, numero_licitacao, objeto, modalidade, status,
                 data_abertura, link_portal, observacoes, origem)
            VALUES (?,?,?,?,?,?,?,?,'pdf')
            ON DUPLICATE KEY UPDATE
                objeto = VALUES(objeto),
                status = VALUES(status),
                data_abertura = COALESCE(VALUES(data_abertura), data_abertura)
        ")->execute([
            $l['numero_sei']        ?? $l['numero_licitacao'] ?? null,
            $l['numero_licitacao']  ?? null,
            $l['objeto']            ?? '(objeto não extraído)',
            $l['modalidade']        ?? 'pregao_eletronico',
            $l['status']            ?? 'em_andamento',
            $l['data_limite_proposta'] ?? $l['data_abertura'] ?? null,
            $l['link_portal']       ?? null,
            'Importado do DOAC. Órgão: ' . ($l['orgao'] ?? '?') .
                '. COMPRASGOV: ' . ($l['numero_comprasgov'] ?? '?'),
        ]);
        return true;
    } catch (PDOException $e) {
        error_log('Erro importar licitação DOAC: ' . $e->getMessage());
        return false;
    }
}

function importar_inexigibilidade_doac(array $i, PDO $db): bool {
    try {
        // Cria como licitação do tipo inexigibilidade já homologada
        $db->prepare("
            INSERT INTO licitacoes
                (numero_processo, objeto, modalidade, status,
                 valor_estimado, data_abertura, data_homologacao, observacoes, origem)
            VALUES (?,?,?,?,?,?,?,?,'pdf')
            ON DUPLICATE KEY UPDATE objeto = VALUES(objeto)
        ")->execute([
            $i['processo_sei']    ?? null,
            $i['objeto']          ?? '(objeto não extraído)',
            'inexigibilidade',
            'homologada',
            $i['valor_total']     ?? null,
            $i['data_ratificacao'] ?? null,
            $i['data_ratificacao'] ?? null,
            'Inexigibilidade importada do DOAC. Empresa: ' . ($i['empresa'] ?? '?') .
                ' CNPJ: ' . ($i['cnpj_empresa'] ?? '?'),
        ]);
        return true;
    } catch (PDOException $e) {
        error_log('Erro importar inexigibilidade DOAC: ' . $e->getMessage());
        return false;
    }
}

function importar_aditivo_doac(array $a, PDO $db): bool {
    if (!$a['numero_contrato']) return false;
    try {
        // Busca o contrato pelo número
        $stmt = $db->prepare('SELECT id, data_vencimento, valor_total, saldo_atual FROM contratos WHERE numero = ? LIMIT 1');
        $stmt->execute([$a['numero_contrato']]);
        $contrato = $stmt->fetch();
        if (!$contrato) return false; // contrato não cadastrado ainda

        // Verifica se aditivo já existe
        $existe = $db->prepare('SELECT id FROM aditivos WHERE contrato_id = ? AND numero_aditivo = ? LIMIT 1');
        $existe->execute([$contrato['id'], $a['numero_aditivo_ordinal'] ?? 'DOAC']);
        if ($existe->fetch()) return false; // já importado

        $db->prepare("
            INSERT INTO aditivos
                (contrato_id, numero_aditivo, tipo, data_assinatura, valor_acrescimo, justificativa)
            VALUES (?,?,?,?,?,?)
        ")->execute([
            $contrato['id'],
            $a['numero_aditivo_ordinal'] ?? 'Aditivo DOAC',
            $a['tipo_aditivo']           ?? 'valor',
            $a['data_assinatura']        ?? date('Y-m-d'),
            $a['valor_total_novo']       ?? 0,
            'Importado automaticamente do DOAC. Empresa: ' . ($a['empresa'] ?? '?'),
        ]);
        return true;
    } catch (PDOException $e) {
        error_log('Erro importar aditivo DOAC: ' . $e->getMessage());
        return false;
    }
}

function importar_portaria_doac(array $p, PDO $db): bool {
    if (!$p['numero_contrato']) return false;
    try {
        // Atualiza gestor/fiscal no contrato se ele existir
        $stmt = $db->prepare('SELECT id FROM contratos WHERE numero = ? LIMIT 1');
        $stmt->execute([$p['numero_contrato']]);
        $contrato = $stmt->fetch();
        if (!$contrato) return false;

        $db->prepare("
            UPDATE contratos SET
                gestor_nome  = COALESCE(?, gestor_nome),
                fiscal_nome  = COALESCE(?, fiscal_nome)
            WHERE id = ?
        ")->execute([
            $p['gestor_titular'] ?? null,
            $p['fiscal_titular'] ?? null,
            $contrato['id'],
        ]);
        return true;
    } catch (PDOException $e) {
        error_log('Erro importar portaria DOAC: ' . $e->getMessage());
        return false;
    }
}

// ────────────────────────────────────────────────────────────
// VIEW
// ────────────────────────────────────────────────────────────
$page_title = 'Importar do Diário Oficial';
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center gap-2 mb-3">
    <a href="index.php" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
    <h5 class="mb-0 fw-bold">
        <i class="bi bi-newspaper text-danger"></i>
        Importar do Diário Oficial do Acre (DOAC)
    </h5>
</div>

<?php if ($errors): ?>
<div class="alert alert-danger">
    <ul class="mb-0"><?php foreach ($errors as $e): ?><li><?= sanitize($e) ?></li><?php endforeach; ?></ul>
</div>
<?php endif; ?>

<?php // ── ETAPA UPLOAD ── ?>
<?php if ($etapa === 'upload'): ?>

<div class="row g-3">
    <div class="col-lg-5">
        <div class="card shadow-sm">
            <div class="card-header bg-white fw-bold">
                <i class="bi bi-file-earmark-pdf text-danger"></i> Selecionar PDF do DOAC
            </div>
            <div class="card-body">
                <form method="post" enctype="multipart/form-data" novalidate>
                    <input type="hidden" name="etapa" value="upload">

                    <div class="mb-3">
                        <label class="form-label fw-semibold">PDF do Diário Oficial</label>
                        <input type="file" name="arquivo" class="form-control" accept=".pdf" required>
                        <div class="form-text">Aceita o PDF completo do DOAC (300+ páginas).</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">O que extrair?</label>
                        <select name="modo" class="form-select">
                            <option value="ambos">Seção IDAF + avisos SEAD/SELIC</option>
                            <option value="idaf">Apenas seção IDAF (portarias, aditivos...)</option>
                            <option value="sead">Apenas avisos de licitação (SEAD/SELIC)</option>
                        </select>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold">Filtrar por órgão (SEAD)</label>
                        <input type="text" name="orgao" class="form-control" value="IDAF"
                               placeholder="Ex: IDAF, SEAGRI, IAPEN">
                        <div class="form-text">Deixe em branco para extrair de todos os órgãos.</div>
                    </div>

                    <button type="submit" class="btn btn-danger w-100 fw-bold">
                        <i class="bi bi-magic"></i> Extrair Dados do PDF
                    </button>
                </form>
            </div>
        </div>
    </div>

    <div class="col-lg-7">
        <div class="card shadow-sm border-0 bg-light">
            <div class="card-body">
                <h6 class="fw-bold mb-3"><i class="bi bi-info-circle text-info"></i> Como funciona</h6>
                <p class="small text-muted mb-2">
                    O sistema chama um script Python (<code>extrator_doac.py</code>) que:
                </p>
                <ol class="small text-muted ps-3">
                    <li>Extrai o texto completo do PDF (incluindo páginas de 2 colunas)</li>
                    <li>Localiza a seção do IDAF pelo separador <code>IDAF</code></li>
                    <li>Identifica o tipo de cada publicação (portaria, aditivo, inexigibilidade...)</li>
                    <li>Varre a seção SEAD/SELIC filtrando avisos de pregão do órgão selecionado</li>
                    <li>Retorna um JSON estruturado para revisão antes de salvar</li>
                </ol>
                <div class="alert alert-warning py-2 small mb-0">
                    <i class="bi bi-exclamation-triangle"></i>
                    <strong>Atenção:</strong> Sempre revise os dados extraídos antes de confirmar.
                    A extração automática pode cometer erros em publicações com layout incomum.
                </div>
            </div>
        </div>
    </div>
</div>

<?php // ── ETAPA REVISÃO ── ?>
<?php elseif ($etapa === 'revisar' && $dados): ?>

<?php
$totais   = $dados['totais'] ?? [];
$total_it = array_sum($totais);
$arquivo  = $_SESSION['doac_original'] ?? '';
?>

<div class="alert alert-success d-flex align-items-center gap-2 py-2">
    <i class="bi bi-check-circle-fill fs-5"></i>
    <div>
        Extração concluída de <strong><?= sanitize($arquivo) ?></strong>.
        Encontrados: <?= $totais['portarias'] ?? 0 ?> portarias,
        <?= $totais['inexigibilidades'] ?? 0 ?> inexigibilidades,
        <?= $totais['aditivos'] ?? 0 ?> aditivos,
        <?= $totais['licitacoes_sead'] ?? 0 ?> avisos de licitação.
        <strong>Marque o que deseja importar e clique em Salvar.</strong>
    </div>
</div>

<form method="post" action="?etapa=salvar">
<input type="hidden" name="etapa" value="salvar">

<?php // ── AVISOS DE LICITAÇÃO (SEAD) ── ?>
<?php $lics = $dados['licitacoes_sead'] ?? []; ?>
<?php if ($lics): ?>
<div class="card shadow-sm mb-3">
    <div class="card-header bg-white d-flex align-items-center gap-2">
        <i class="bi bi-clipboard2-data text-info"></i>
        <strong>Avisos de Licitação — SEAD/SELIC</strong>
        <span class="badge bg-info ms-auto"><?= count($lics) ?></span>
        <button type="button" class="btn btn-sm btn-outline-secondary"
                onclick="toggleAll('chk-lic')">Marcar todos</button>
    </div>
    <div class="card-body p-0">
        <table class="table table-sm table-hover mb-0">
            <thead class="table-light">
                <tr>
                    <th width="40"><input type="checkbox" onclick="toggleAll('chk-lic', this)"></th>
                    <th>Tipo</th><th>Pregão</th><th>Órgão</th><th>Objeto</th><th>Limite Proposta</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($lics as $idx => $l): ?>
            <tr>
                <td><input type="checkbox" name="selecionar[]"
                           class="chk-lic"
                           value="licitacao|<?= $idx ?>"></td>
                <td>
                    <?php
                    $ta = $l['tipo_aviso'] ?? '';
                    $badge = match($ta) {
                        'licitacao'   => 'bg-primary',
                        'reabertura'  => 'bg-warning text-dark',
                        'prorrogacao' => 'bg-info text-dark',
                        default       => 'bg-secondary',
                    };
                    echo '<span class="badge ' . $badge . '">' . sanitize(ucfirst($ta ?: 'aviso')) . '</span>';
                    ?>
                </td>
                <td><?= sanitize($l['numero_licitacao'] ?? '—') ?></td>
                <td><span class="badge bg-secondary"><?= sanitize($l['orgao'] ?? '?') ?></span></td>
                <td class="text-truncate" style="max-width:220px"
                    title="<?= sanitize($l['objeto'] ?? '') ?>">
                    <?= sanitize(mb_substr($l['objeto'] ?? '—', 0, 80)) ?>
                </td>
                <td><?= $l['data_limite_proposta'] ? data_br(str_replace('-','/',$l['data_limite_proposta'])) : '—' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php // ── INEXIGIBILIDADES ── ?>
<?php $inexs = $dados['inexigibilidades'] ?? []; ?>
<?php if ($inexs): ?>
<div class="card shadow-sm mb-3">
    <div class="card-header bg-white d-flex align-items-center gap-2">
        <i class="bi bi-file-earmark-check text-warning"></i>
        <strong>Inexigibilidades / Dispensas</strong>
        <span class="badge bg-warning text-dark ms-auto"><?= count($inexs) ?></span>
    </div>
    <div class="card-body p-0">
        <table class="table table-sm table-hover mb-0">
            <thead class="table-light">
                <tr>
                    <th width="40"><input type="checkbox" onclick="toggleAll('chk-inex', this)"></th>
                    <th>Processo SEI</th><th>Empresa</th><th>CNPJ</th><th>Objeto</th><th>Valor</th><th>Data</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($inexs as $idx => $i): ?>
            <tr>
                <td><input type="checkbox" name="selecionar[]"
                           class="chk-inex"
                           value="inexigibilidade|<?= $idx ?>"></td>
                <td><?= sanitize($i['processo_sei'] ?? '—') ?></td>
                <td><?= sanitize($i['empresa'] ?? '—') ?></td>
                <td><?= sanitize($i['cnpj_empresa'] ?? '—') ?></td>
                <td class="text-truncate" style="max-width:180px"><?= sanitize(mb_substr($i['objeto'] ?? '—', 0, 60)) ?></td>
                <td><?= $i['valor_total'] ? moeda($i['valor_total']) : '—' ?></td>
                <td><?= $i['data_ratificacao'] ? data_br(str_replace('-','/',$i['data_ratificacao'])) : '—' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php // ── ADITIVOS ── ?>
<?php $adits = $dados['aditivos'] ?? []; ?>
<?php if ($adits): ?>
<div class="card shadow-sm mb-3">
    <div class="card-header bg-white d-flex align-items-center gap-2">
        <i class="bi bi-plus-slash-minus text-danger"></i>
        <strong>Termos Aditivos</strong>
        <span class="badge bg-danger ms-auto"><?= count($adits) ?></span>
    </div>
    <div class="card-body p-0">
        <table class="table table-sm table-hover mb-0">
            <thead class="table-light">
                <tr>
                    <th width="40"><input type="checkbox" onclick="toggleAll('chk-adit', this)"></th>
                    <th>Contrato</th><th>Aditivo</th><th>Empresa</th><th>Tipo</th><th>Valor Novo</th><th>Assinatura</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($adits as $idx => $a): ?>
            <tr>
                <td><input type="checkbox" name="selecionar[]"
                           class="chk-adit"
                           value="aditivo|<?= $idx ?>"></td>
                <td class="fw-semibold"><?= sanitize($a['numero_contrato'] ?? '—') ?></td>
                <td><?= sanitize($a['numero_aditivo_ordinal'] ?? '—') ?></td>
                <td><?= sanitize($a['empresa'] ?? '—') ?></td>
                <td><?= sanitize($a['tipo_aditivo'] ?? '—') ?></td>
                <td><?= $a['valor_total_novo'] ? moeda($a['valor_total_novo']) : '—' ?></td>
                <td><?= $a['data_assinatura'] ? data_br(str_replace('-','/',$a['data_assinatura'])) : '—' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php // ── PORTARIAS ── ?>
<?php $ports = $dados['portarias'] ?? []; ?>
<?php if ($ports): ?>
<div class="card shadow-sm mb-3">
    <div class="card-header bg-white d-flex align-items-center gap-2">
        <i class="bi bi-person-badge text-secondary"></i>
        <strong>Portarias (Gestor/Fiscal)</strong>
        <span class="badge bg-secondary ms-auto"><?= count($ports) ?></span>
        <span class="text-muted small">— atualiza gestor/fiscal em contratos existentes</span>
    </div>
    <div class="card-body p-0">
        <table class="table table-sm table-hover mb-0">
            <thead class="table-light">
                <tr>
                    <th width="40"><input type="checkbox" onclick="toggleAll('chk-port', this)"></th>
                    <th>Portaria</th><th>Contrato</th><th>Empresa</th><th>Gestor</th><th>Fiscal</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($ports as $idx => $p): ?>
            <?php
            // Verifica se o contrato existe no sistema
            $stmt = $db->prepare('SELECT id FROM contratos WHERE numero = ? LIMIT 1');
            $stmt->execute([$p['numero_contrato'] ?? '']);
            $existe_contrato = (bool) $stmt->fetch();
            ?>
            <tr class="<?= !$existe_contrato && $p['numero_contrato'] ? 'table-warning' : '' ?>">
                <td><input type="checkbox" name="selecionar[]"
                           class="chk-port"
                           value="portaria|<?= $idx ?>"
                           <?= !$existe_contrato ? 'disabled' : '' ?>></td>
                <td>Nº <?= sanitize($p['numero_portaria'] ?? '—') ?></td>
                <td>
                    <?= sanitize($p['numero_contrato'] ?? '—') ?>
                    <?php if ($p['numero_contrato'] && !$existe_contrato): ?>
                        <span class="badge bg-warning text-dark" title="Contrato não cadastrado">não cadastrado</span>
                    <?php endif; ?>
                </td>
                <td class="text-truncate" style="max-width:150px"><?= sanitize($p['empresa'] ?? '—') ?></td>
                <td><?= sanitize($p['gestor_titular'] ?? '—') ?></td>
                <td><?= sanitize($p['fiscal_titular'] ?? '—') ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php if ($total_it === 0): ?>
<div class="alert alert-warning">
    <i class="bi bi-search"></i> Nenhuma publicação do IDAF encontrada neste PDF.
    Verifique se o arquivo é o Diário Oficial correto e se o órgão está cadastrado.
</div>
<?php endif; ?>

<div class="d-flex gap-2 justify-content-end mt-3">
    <a href="importar_doac.php" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Voltar
    </a>
    <button type="submit" class="btn btn-success px-4 fw-bold" <?= $total_it === 0 ? 'disabled' : '' ?>>
        <i class="bi bi-cloud-arrow-down"></i> Importar Selecionados
    </button>
</div>

</form>

<?php endif; ?>

<script>
function toggleAll(cls, master) {
    const checks = document.querySelectorAll('.' + cls + ':not([disabled])');
    const state = master ? master.checked : !checks[0]?.checked;
    checks.forEach(c => c.checked = state);
}
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
