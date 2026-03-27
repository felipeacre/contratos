<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

if (empty($_SESSION['pdf_extraido'])) {
    redirect(BASE_URL . '/modules/importacao/index.php');
}

$dados    = $_SESSION['pdf_extraido'];
$entidade = $_GET['entidade'] ?? 'contratos';
$db       = Database::get();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $f = $_POST;

    if ($entidade === 'contratos') {
        $valor = (float) str_replace(',', '.', $f['valor_total'] ?? 0);
        $db->prepare("
            INSERT INTO contratos
                (numero, numero_processo, objeto, fornecedor_nome, fornecedor_cnpj,
                 modalidade, valor_total, saldo_atual, data_assinatura, data_inicio,
                 data_vencimento, origem, observacoes)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,'pdf',?)
        ")->execute([
            $f['numero'], $f['numero_processo'], $f['objeto'],
            $f['fornecedor_nome'], preg_replace('/\D/','',$f['fornecedor_cnpj']),
            $f['modalidade'] ?: null, $valor, $valor,
            $f['data_assinatura'] ?: null,
            $f['data_inicio']     ?: null,
            $f['data_vencimento'] ?: null,
            'Importado via PDF: ' . ($_SESSION['pdf_original'] ?? ''),
        ]);
    }

    // Salva PDF definitivo
    if (!empty($_SESSION['pdf_arquivo']) && file_exists($_SESSION['pdf_arquivo'])) {
        $novo_nome = uniqid('contrato_') . '.pdf';
        rename($_SESSION['pdf_arquivo'], UPLOAD_PDF_DIR . $novo_nome);
    }

    unset($_SESSION['pdf_extraido'], $_SESSION['pdf_arquivo'], $_SESSION['pdf_original']);

    flash('success', 'Dados do PDF importados com sucesso. Revise e complete as informações.');
    redirect(BASE_URL . '/modules/contratos/index.php');
}

$page_title = 'Confirmar Importação de PDF';
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center gap-2 mb-3">
    <a href="index.php" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
    <h5 class="mb-0 fw-bold">Confirmar Dados Extraídos do PDF</h5>
</div>

<div class="alert alert-info">
    <i class="bi bi-robot"></i>
    Dados extraídos automaticamente do PDF <strong><?= sanitize($_SESSION['pdf_original'] ?? '') ?></strong>.
    Revise e corrija antes de salvar.
</div>

<div class="card shadow-sm">
<div class="card-body">
<form method="post" novalidate>
    <div class="row g-3">

        <div class="col-md-3">
            <label class="form-label fw-semibold">Nº do Contrato</label>
            <input type="text" name="numero" class="form-control" value="<?= sanitize($dados['numero'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Nº do Processo</label>
            <input type="text" name="numero_processo" class="form-control" value="<?= sanitize($dados['numero_processo'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Modalidade</label>
            <select name="modalidade" class="form-select">
                <option value="">-- Selecione --</option>
                <?php foreach (['pregao_eletronico'=>'Pregão Eletrônico','pregao_presencial'=>'Pregão Presencial','concorrencia'=>'Concorrência','dispensa'=>'Dispensa','inexigibilidade'=>'Inexigibilidade'] as $k=>$v): ?>
                <option value="<?= $k ?>" <?= ($dados['modalidade'] ?? '') === $k ? 'selected' : '' ?>><?= $v ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Valor Total (R$)</label>
            <input type="text" name="valor_total" class="form-control"
                   value="<?= number_format((float)($dados['valor_total'] ?? 0), 2, ',', '.') ?>">
        </div>

        <div class="col-12">
            <label class="form-label fw-semibold">Objeto</label>
            <textarea name="objeto" class="form-control" rows="3"><?= sanitize($dados['objeto'] ?? '') ?></textarea>
        </div>

        <div class="col-md-6">
            <label class="form-label fw-semibold">Fornecedor / Contratado</label>
            <input type="text" name="fornecedor_nome" class="form-control" value="<?= sanitize($dados['fornecedor_nome'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">CNPJ</label>
            <input type="text" name="fornecedor_cnpj" class="form-control mask-cnpj"
                   value="<?= sanitize($dados['fornecedor_cnpj'] ?? '') ?>">
        </div>

        <div class="col-md-3">
            <label class="form-label fw-semibold">Data de Assinatura</label>
            <input type="date" name="data_assinatura" class="form-control" value="<?= sanitize($dados['data_assinatura'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Início da Vigência</label>
            <input type="date" name="data_inicio" class="form-control" value="<?= sanitize($dados['data_inicio'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Vencimento</label>
            <input type="date" name="data_vencimento" class="form-control" value="<?= sanitize($dados['data_vencimento'] ?? '') ?>">
        </div>

        <div class="col-12 d-flex gap-2 justify-content-end mt-2">
            <a href="index.php" class="btn btn-outline-secondary">Cancelar</a>
            <button type="submit" class="btn btn-success px-4">
                <i class="bi bi-check-lg"></i> Confirmar e Salvar
            </button>
        </div>
    </div>
</form>
</div>
</div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
