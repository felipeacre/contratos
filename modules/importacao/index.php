<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db      = Database::get();
$errors  = [];
$sucesso = [];

// ============================================================
// PROCESSAR UPLOAD
// ============================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['arquivo'])) {
    $file     = $_FILES['arquivo'];
    $tipo_imp = $_POST['tipo_importacao'] ?? '';
    $entidade = $_POST['entidade'] ?? 'contratos'; // contratos | licitacoes

    if ($file['error'] !== UPLOAD_ERR_OK) {
        $errors[] = 'Erro no upload do arquivo.';
    } else {
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $allowed_csv  = ['csv'];
        $allowed_xlsx = ['xlsx', 'xls'];
        $allowed_pdf  = ['pdf'];

        if ($tipo_imp === 'pdf' && in_array($ext, $allowed_pdf)) {
            processar_pdf($file, $entidade, $db, $errors, $sucesso);
        } elseif (in_array($tipo_imp, ['csv','excel']) && (in_array($ext, $allowed_csv) || in_array($ext, $allowed_xlsx))) {
            processar_planilha($file, $ext, $entidade, $db, $errors, $sucesso);
        } else {
            $errors[] = 'Tipo de arquivo inválido para a importação selecionada.';
        }
    }
}

// ============================================================
// FUNÇÕES DE IMPORTAÇÃO
// ============================================================

function processar_pdf(array $file, string $entidade, PDO $db, array &$errors, array &$sucesso): void {
    // Salva PDF temporariamente
    $destino = UPLOAD_PDF_DIR . uniqid('pdf_') . '.pdf';
    if (!move_uploaded_file($file['tmp_name'], $destino)) {
        $errors[] = 'Falha ao salvar o PDF.';
        return;
    }

    // Chama o script Python
    $cmd    = escapeshellcmd(PYTHON_BIN . ' ' . PYTHON_SCRIPT . ' ' . escapeshellarg($destino));
    $output = shell_exec($cmd . ' 2>&1');

    if (!$output) {
        $errors[] = 'Script Python não retornou dados. Verifique a instalação do Python e pdfplumber.';
        @unlink($destino);
        return;
    }

    $dados = json_decode($output, true);

    if (!$dados || isset($dados['erro'])) {
        $errors[] = 'Erro na extração: ' . ($dados['erro'] ?? 'resposta inválida do Python.');
        @unlink($destino);
        return;
    }

    // Salva documento e redireciona para formulário de confirmação
    $_SESSION['pdf_extraido'] = $dados;
    $_SESSION['pdf_arquivo']  = $destino;
    $_SESSION['pdf_original'] = $file['name'];

    redirect(BASE_URL . '/modules/importacao/confirmar_pdf.php?entidade=' . urlencode($entidade));
}

function processar_planilha(array $file, string $ext, string $entidade, PDO $db, array &$errors, array &$sucesso): void {
    // Verifica PhpSpreadsheet
    $autoload = BASE_PATH . '/vendor/autoload.php';
    if (!file_exists($autoload)) {
        $errors[] = 'PhpSpreadsheet não instalado. Execute: composer require phpoffice/phpspreadsheet';
        return;
    }
    require_once $autoload;

    $destino = UPLOAD_IMPORT_DIR . uniqid('imp_') . '.' . $ext;
    if (!move_uploaded_file($file['tmp_name'], $destino)) {
        $errors[] = 'Falha ao salvar o arquivo.';
        return;
    }

    try {
        $reader = \PhpOffice\PhpSpreadsheet\IOFactory::createReaderForFile($destino);
        $reader->setReadDataOnly(true);
        $spreadsheet = $reader->load($destino);
        $sheet       = $spreadsheet->getActiveSheet();
        $rows        = $sheet->toArray(null, true, true, false);
    } catch (\Exception $e) {
        $errors[] = 'Erro ao ler planilha: ' . $e->getMessage();
        @unlink($destino);
        return;
    }

    if (count($rows) < 2) {
        $errors[] = 'Planilha vazia ou sem dados (apenas cabeçalho).';
        @unlink($destino);
        return;
    }

    // Detecta a linha real do cabeçalho — suporta planilhas com 1, 2 ou 3 linhas de cabeçalho
    // Procura a primeira linha que contenha "numero", "objeto" ou "nº do contrato"
    $cabecalho_idx = 0;
    foreach ($rows as $idx => $row_check) {
        $linha_lower = array_map(fn($v) => strtolower(trim((string)($v ?? ''))), $row_check);
        if (in_array('numero', $linha_lower) || in_array('objeto', $linha_lower)
                || in_array('nº do contrato', $linha_lower) || in_array('n° do contrato', $linha_lower)
                || in_array('nº do contrato', $linha_lower)) {
            $cabecalho_idx = $idx;
            break;
        }
    }

    $cabecalho = array_map(fn($v) => strtolower(trim((string)($v ?? ''))), $rows[$cabecalho_idx]);
    $importados = 0;
    $erros_linhas = [];

    for ($i = $cabecalho_idx + 1; $i < count($rows); $i++) {
        $linha = $i + 1;
        // Pula linhas completamente vazias
        if (!array_filter($rows[$i], fn($v) => $v !== null && $v !== '')) continue;
        $row   = array_combine($cabecalho, array_slice($rows[$i], 0, count($cabecalho)));

        if ($entidade === 'contratos') {
            $res = importar_contrato($row, $linha, $db);
        } else {
            $res = importar_licitacao($row, $linha, $db);
        }

        if ($res === true) {
            $importados++;
        } else {
            $erros_linhas[] = "Linha $linha: $res";
        }
    }

    $sucesso[] = "$importados registro(s) importado(s) com sucesso.";
    if ($erros_linhas) {
        foreach (array_slice($erros_linhas, 0, 10) as $e) $errors[] = $e;
        if (count($erros_linhas) > 10) $errors[] = '... e mais ' . (count($erros_linhas) - 10) . ' erros.';
    }

    // Log
    $db->prepare("INSERT INTO importacoes_log (tipo, nome_arquivo, total_linhas, importados, erros, detalhes_erros, usuario_id) VALUES (?,?,?,?,?,?,?)")
            ->execute([
                    $ext === 'csv' ? 'csv' : 'excel',
                    $file['name'],
                    count($rows) - 1,
                    $importados,
                    count($erros_linhas),
                    $erros_linhas ? json_encode($erros_linhas) : null,
                    $_SESSION['usuario_id'],
            ]);

    @unlink($destino);
}

function importar_contrato(array $row, int $linha, PDO $db): true|string {
    // sv(): converte null para string vazia com segurança (PHP 8.3+)
    $sv = fn($v) => trim((string)($v ?? ''));

    $numero = $sv($row['numero'] ?? $row['número'] ?? $row['nro_contrato'] ?? null);
    $objeto = $sv($row['objeto'] ?? null);

    if (!$numero || !$objeto) return "Número e objeto são obrigatórios.";

    $venc = normalizar_data_import($sv($row['data_vencimento'] ?? $row['vencimento'] ?? null));
    if (!$venc) return "Data de vencimento inválida ($numero).";

    $valor_raw = $sv($row['valor_total'] ?? $row['valor'] ?? '0');
    $valor = (float) str_replace(['.','R$',' '], ['','',''], str_replace(',', '.', $valor_raw ?: '0'));

    $saldo_raw = $sv($row['saldo'] ?? $row['saldo_atual'] ?? null);
    $saldo = $saldo_raw ? (float) str_replace(['.','R$',' '], ['','',''], str_replace(',', '.', $saldo_raw)) : $valor;

    try {
        $db->prepare("
            INSERT INTO contratos
                (numero, objeto, fornecedor_nome, fornecedor_cnpj, valor_total, saldo_atual,
                 data_assinatura, data_inicio, data_vencimento, origem)
            VALUES (?,?,?,?,?,?,?,?,?,'importacao')
            ON DUPLICATE KEY UPDATE
                objeto          = VALUES(objeto),
                fornecedor_nome = VALUES(fornecedor_nome),
                data_vencimento = VALUES(data_vencimento)
        ")->execute([
                $numero,
                $objeto,
                $sv($row['fornecedor'] ?? $row['razao_social'] ?? null),
                preg_replace('/\D/', '', $sv($row['cnpj'] ?? null)),
                $valor,
                $saldo,
                normalizar_data_import($sv($row['data_assinatura'] ?? null)) ?: date('Y-m-d'),
                normalizar_data_import($sv($row['data_inicio'] ?? null)) ?: date('Y-m-d'),
                $venc,
        ]);
        return true;
    } catch (PDOException $e) {
        return 'Erro BD: ' . $e->getMessage();
    }
}

function importar_licitacao(array $row, int $linha, PDO $db): true|string {
    $sv = fn($v) => trim((string)($v ?? ''));
    $processo = $sv($row['numero_processo'] ?? $row['processo'] ?? null);
    $objeto   = $sv($row['objeto'] ?? null);
    if (!$processo || !$objeto) return "Número do processo e objeto são obrigatórios.";

    $status_raw = strtolower($sv($row['status'] ?? 'em_andamento'));
    $status_map = ['em andamento'=>'em_andamento','homologada'=>'homologada','cancelada'=>'cancelada','deserta'=>'deserta'];
    $status = $status_map[$status_raw] ?? 'em_andamento';

    try {
        $db->prepare("
            INSERT INTO licitacoes
                (numero_processo, objeto, modalidade, status, valor_estimado, data_abertura, origem)
            VALUES (?,?,?,?,?,?,'importacao')
            ON DUPLICATE KEY UPDATE objeto = VALUES(objeto)
        ")->execute([
                $processo, $objeto,
                $row['modalidade'] ?? 'pregao_eletronico',
                $status,
                (float) str_replace(['.','R$',' '], ['','',''], str_replace(',', '.', $row['valor_estimado'] ?? '0')),
                normalizar_data_import($row['data_abertura'] ?? '') ?: null,
        ]);
        return true;
    } catch (PDOException $e) {
        return 'Erro BD: ' . $e->getMessage();
    }
}

function normalizar_data_import(string $d): string|null {
    $d = trim($d);
    if (!$d) return null;
    if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $d)) return $d;
    if (preg_match('/^(\d{1,2})\/(\d{2})\/(\d{4})$/', $d, $m)) return "$m[3]-$m[2]-" . str_pad($m[1],2,'0',STR_PAD_LEFT);
    return null;
}

// ============================================================
// VIEW
// ============================================================
$log = $db->query('SELECT * FROM importacoes_log ORDER BY created_at DESC LIMIT 20')->fetchAll();

$page_title = 'Importar Dados';
include __DIR__ . '/../../includes/header.php';
?>

    <div class="d-flex align-items-center gap-2 mb-3">
        <h5 class="mb-0 fw-bold"><i class="bi bi-upload text-primary"></i> Importar Dados</h5>
    </div>

<?php if ($errors): ?>
    <div class="alert alert-danger">
        <strong>Atenção:</strong>
        <ul class="mb-0 mt-1"><?php foreach ($errors as $e): ?><li><?= sanitize($e) ?></li><?php endforeach; ?></ul>
    </div>
<?php endif; ?>

<?php if ($sucesso): ?>
    <div class="alert alert-success">
        <?php foreach ($sucesso as $s): ?><p class="mb-0"><?= sanitize($s) ?></p><?php endforeach; ?>
    </div>
<?php endif; ?>

    <div class="row g-3">

        <!-- Formulário de upload -->
        <div class="col-lg-5">
            <div class="card shadow-sm">
                <div class="card-header bg-white"><strong>Novo Import</strong></div>
                <div class="card-body">
                    <form method="post" enctype="multipart/form-data" novalidate>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Tipo de Dados</label>
                            <select name="entidade" class="form-select" id="sel-entidade">
                                <option value="contratos">Contratos</option>
                                <option value="licitacoes">Licitações</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Formato</label>
                            <div class="d-flex gap-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="tipo_importacao" value="excel" id="fmt-xlsx" checked>
                                    <label class="form-check-label" for="fmt-xlsx"><i class="bi bi-file-earmark-excel text-success"></i> Excel (.xlsx)</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="tipo_importacao" value="csv" id="fmt-csv">
                                    <label class="form-check-label" for="fmt-csv"><i class="bi bi-filetype-csv text-primary"></i> CSV</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="tipo_importacao" value="pdf" id="fmt-pdf">
                                    <label class="form-check-label" for="fmt-pdf"><i class="bi bi-file-earmark-pdf text-danger"></i> PDF (Diário Oficial)</label>
                                </div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Arquivo</label>
                            <input class="form-control" type="file" name="arquivo" id="arquivo" required
                                   accept=".xlsx,.xls,.csv,.pdf">
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-cloud-upload"></i> Importar
                        </button>
                    </form>
                </div>
            </div>

            <!-- Importar DOAC -->
            <div class="card shadow-sm mt-3 border-danger">
                <div class="card-header bg-white text-danger fw-bold">
                    <i class="bi bi-newspaper"></i> Importar do Diário Oficial
                </div>
                <div class="card-body">
                    <p class="small text-muted">
                        Extrai automaticamente licitações, portarias e aditivos do IDAF
                        publicados no PDF do DOAC usando o extrator Python.
                    </p>
                    <a href="importar_doac.php" class="btn btn-danger w-100">
                        <i class="bi bi-magic"></i> Importar do DOAC
                    </a>
                </div>
            </div>

            <!-- Templates -->
            <div class="card shadow-sm mt-3">
                <div class="card-header bg-white"><strong>Modelos de Planilha</strong></div>
                <div class="card-body">
                    <p class="text-muted small">Baixe o modelo para preencher corretamente:</p>
                    <a href="<?= BASE_URL ?>/modules/importacao/template_contratos.php" class="btn btn-sm btn-outline-success w-100 mb-2">
                        <i class="bi bi-file-earmark-excel"></i> Modelo — Contratos (.xlsx)
                    </a>
                    <a href="<?= BASE_URL ?>/modules/importacao/template_licitacoes.php" class="btn btn-sm btn-outline-primary w-100">
                        <i class="bi bi-file-earmark-excel"></i> Modelo — Licitações (.xlsx)
                    </a>
                </div>
            </div>
        </div>

        <!-- Histórico -->
        <div class="col-lg-7">
            <div class="card shadow-sm">
                <div class="card-header bg-white"><strong>Histórico de Importações</strong></div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-sm table-hover mb-0">
                            <thead class="table-light">
                            <tr>
                                <th>Data</th>
                                <th>Arquivo</th>
                                <th>Tipo</th>
                                <th class="text-center">Importados</th>
                                <th class="text-center">Erros</th>
                            </tr>
                            </thead>
                            <tbody>
                            <?php foreach ($log as $l): ?>
                                <tr>
                                    <td><?= data_br($l['created_at']) ?></td>
                                    <td class="text-truncate" style="max-width:180px"><?= sanitize($l['nome_arquivo']) ?></td>
                                    <td><span class="badge bg-secondary"><?= strtoupper($l['tipo']) ?></span></td>
                                    <td class="text-center text-success fw-bold"><?= $l['importados'] ?></td>
                                    <td class="text-center <?= $l['erros'] > 0 ? 'text-danger fw-bold' : 'text-muted' ?>"><?= $l['erros'] ?></td>
                                </tr>
                            <?php endforeach; ?>
                            <?php if (empty($log)): ?>
                                <tr><td colspan="5" class="text-center text-muted py-3">Nenhuma importação realizada.</td></tr>
                            <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>