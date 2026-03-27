<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db = Database::get();
$id = (int)($_GET['id'] ?? 0);
$is_edit = $id > 0;

$contrato = [];
if ($is_edit) {
    $stmt = $db->prepare('SELECT * FROM contratos WHERE id = ?');
    $stmt->execute([$id]);
    $contrato = $stmt->fetch();
    if (!$contrato) {
        flash('danger', 'Contrato não encontrado.');
        redirect(BASE_URL . '/modules/contratos/index.php');
    }
}

// Fornecedores para select
$fornecedores = $db->query('SELECT id, razao_social, cnpj FROM fornecedores ORDER BY razao_social')->fetchAll();

// Licitações para vincular
$licitacoes = $db->query("SELECT id, numero_processo, objeto FROM licitacoes WHERE status = 'homologada' ORDER BY numero_processo DESC")->fetchAll();

// SALVAR
$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $f = $_POST;

    // Validações básicas
    if (empty($f['numero']))         $errors[] = 'Número do contrato é obrigatório.';
    if (empty($f['objeto']))         $errors[] = 'Objeto é obrigatório.';
    if (empty($f['data_assinatura']))$errors[] = 'Data de assinatura é obrigatória.';
    if (empty($f['data_inicio']))    $errors[] = 'Data de início é obrigatória.';
    if (empty($f['data_vencimento']))$errors[] = 'Data de vencimento é obrigatória.';
    if (!is_numeric(str_replace(',','.',$f['valor_total'] ?? ''))) $errors[] = 'Valor total inválido.';

    if (empty($errors)) {
        $valor_total  = (float) str_replace(',', '.', $f['valor_total']);
        $saldo_atual  = isset($f['saldo_atual']) && $f['saldo_atual'] !== ''
                        ? (float) str_replace(',', '.', $f['saldo_atual'])
                        : $valor_total;

        $data = [
            'numero'              => trim($f['numero']),
            'numero_processo'     => trim($f['numero_processo'] ?? ''),
            'licitacao_id'        => ($f['licitacao_id'] ?? '') ?: null,
            'fornecedor_id'       => ($f['fornecedor_id'] ?? '') ?: null,
            'fornecedor_nome'     => trim($f['fornecedor_nome'] ?? ''),
            'fornecedor_cnpj'     => preg_replace('/\D/', '', $f['fornecedor_cnpj'] ?? ''),
            'objeto'              => trim($f['objeto']),
            'modalidade'          => $f['modalidade'] ?? null,
            'valor_total'         => $valor_total,
            'saldo_atual'         => $saldo_atual,
            'data_assinatura'     => $f['data_assinatura'],
            'data_inicio'         => $f['data_inicio'],
            'data_vencimento'     => $f['data_vencimento'],
            'status_manual'       => ($f['status_manual'] ?? '') ?: null,
            'gestor_nome'         => trim($f['gestor_nome'] ?? ''),
            'gestor_matricula'    => trim($f['gestor_matricula'] ?? ''),
            'fiscal_nome'         => trim($f['fiscal_nome'] ?? ''),
            'fiscal_matricula'    => trim($f['fiscal_matricula'] ?? ''),
            'dotacao_orcamentaria'=> trim($f['dotacao_orcamentaria'] ?? ''),
            'observacoes'         => trim($f['observacoes'] ?? ''),
        ];

        if ($is_edit) {
            $set = implode(', ', array_map(fn($k) => "$k = :$k", array_keys($data)));
            $stmt = $db->prepare("UPDATE contratos SET $set WHERE id = :id");
            $data['id'] = $id;
            $stmt->execute($data);
            flash('success', 'Contrato atualizado com sucesso.');
        } else {
            $data['origem'] = 'manual';
            $cols = implode(', ', array_keys($data));
            $vals = implode(', ', array_map(fn($k) => ":$k", array_keys($data)));
            $stmt = $db->prepare("INSERT INTO contratos ($cols) VALUES ($vals)");
            $stmt->execute($data);
            flash('success', 'Contrato cadastrado com sucesso.');
        }
        redirect(BASE_URL . '/modules/contratos/index.php');
    }
    // Repopula campos com o que foi enviado
    $contrato = array_merge($contrato, $f);
}

$page_title = $is_edit ? 'Editar Contrato' : 'Novo Contrato';
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center gap-2 mb-3">
    <a href="index.php" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
    <h5 class="mb-0 fw-bold"><?= $page_title ?></h5>
</div>

<?php if ($errors): ?>
<div class="alert alert-danger">
    <ul class="mb-0"><?php foreach ($errors as $e): ?><li><?= sanitize($e) ?></li><?php endforeach; ?></ul>
</div>
<?php endif; ?>

<div class="card shadow-sm">
<div class="card-body">
<form method="post" novalidate>

    <div class="row g-3">
        <!-- Identificação -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1">Identificação</h6></div>

        <div class="col-md-3">
            <label class="form-label fw-semibold">Nº do Contrato <span class="text-danger">*</span></label>
            <input type="text" name="numero" class="form-control" required
                   value="<?= sanitize($contrato['numero'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Nº do Processo</label>
            <input type="text" name="numero_processo" class="form-control"
                   value="<?= sanitize($contrato['numero_processo'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Modalidade</label>
            <select name="modalidade" class="form-select">
                <option value="">-- Selecione --</option>
                <?php foreach (['pregao_eletronico'=>'Pregão Eletrônico','pregao_presencial'=>'Pregão Presencial','concorrencia'=>'Concorrência','tomada_de_precos'=>'Tomada de Preços','convite'=>'Convite','dispensa'=>'Dispensa','inexigibilidade'=>'Inexigibilidade','chamamento_publico'=>'Chamamento Público'] as $k=>$v): ?>
                <option value="<?= $k ?>" <?= ($contrato['modalidade'] ?? '') === $k ? 'selected' : '' ?>><?= $v ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Licitação Vinculada</label>
            <select name="licitacao_id" class="form-select">
                <option value="">-- Nenhuma --</option>
                <?php foreach ($licitacoes as $l): ?>
                <option value="<?= $l['id'] ?>" <?= ($contrato['licitacao_id'] ?? '') == $l['id'] ? 'selected' : '' ?>>
                    <?= sanitize($l['numero_processo'] . ' — ' . mb_substr($l['objeto'], 0, 40)) ?>
                </option>
                <?php endforeach; ?>
            </select>
        </div>

        <div class="col-12">
            <label class="form-label fw-semibold">Objeto <span class="text-danger">*</span></label>
            <textarea name="objeto" class="form-control" rows="2" required><?= sanitize($contrato['objeto'] ?? '') ?></textarea>
        </div>

        <!-- Fornecedor -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Fornecedor</h6></div>

        <div class="col-md-4">
            <label class="form-label fw-semibold">Fornecedor Cadastrado</label>
            <select name="fornecedor_id" class="form-select">
                <option value="">-- Buscar no cadastro --</option>
                <?php foreach ($fornecedores as $f): ?>
                <option value="<?= $f['id'] ?>" <?= ($contrato['fornecedor_id'] ?? '') == $f['id'] ? 'selected' : '' ?>>
                    <?= sanitize($f['razao_social']) ?>
                </option>
                <?php endforeach; ?>
            </select>
            <div class="form-text">ou preencha manualmente abaixo</div>
        </div>
        <div class="col-md-5">
            <label class="form-label fw-semibold">Razão Social (manual)</label>
            <input type="text" name="fornecedor_nome" class="form-control"
                   value="<?= sanitize($contrato['fornecedor_nome'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">CNPJ (manual)</label>
            <input type="text" name="fornecedor_cnpj" class="form-control mask-cnpj"
                   value="<?= sanitize(cnpj_format($contrato['fornecedor_cnpj'] ?? '')) ?>">
        </div>

        <!-- Valores -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Valores</h6></div>

        <div class="col-md-4">
            <label class="form-label fw-semibold">Valor Total (R$) <span class="text-danger">*</span></label>
            <input type="text" name="valor_total" class="form-control mask-money" required
                   value="<?= number_format((float)($contrato['valor_total'] ?? 0), 2, ',', '') ?>">
        </div>
        <div class="col-md-4">
            <label class="form-label fw-semibold">Saldo Atual (R$)</label>
            <input type="text" name="saldo_atual" class="form-control mask-money"
                   value="<?= number_format((float)($contrato['saldo_atual'] ?? 0), 2, ',', '') ?>">
            <div class="form-text">Deixe em branco para usar o valor total.</div>
        </div>
        <div class="col-md-4">
            <label class="form-label fw-semibold">Dotação Orçamentária</label>
            <input type="text" name="dotacao_orcamentaria" class="form-control"
                   value="<?= sanitize($contrato['dotacao_orcamentaria'] ?? '') ?>">
        </div>

        <!-- Datas -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Vigência</h6></div>

        <div class="col-md-3">
            <label class="form-label fw-semibold">Data de Assinatura <span class="text-danger">*</span></label>
            <input type="date" name="data_assinatura" class="form-control" required
                   value="<?= sanitize($contrato['data_assinatura'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Início da Vigência <span class="text-danger">*</span></label>
            <input type="date" name="data_inicio" class="form-control" required
                   value="<?= sanitize($contrato['data_inicio'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Vencimento <span class="text-danger">*</span></label>
            <input type="date" name="data_vencimento" class="form-control" required
                   value="<?= sanitize($contrato['data_vencimento'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Status Manual</label>
            <select name="status_manual" class="form-select">
                <option value="">-- Automático --</option>
                <option value="ativo"      <?= ($contrato['status_manual'] ?? '') === 'ativo'      ? 'selected' : '' ?>>Ativo</option>
                <option value="encerrado"  <?= ($contrato['status_manual'] ?? '') === 'encerrado'  ? 'selected' : '' ?>>Encerrado</option>
                <option value="suspenso"   <?= ($contrato['status_manual'] ?? '') === 'suspenso'   ? 'selected' : '' ?>>Suspenso</option>
                <option value="rescindido" <?= ($contrato['status_manual'] ?? '') === 'rescindido' ? 'selected' : '' ?>>Rescindido</option>
            </select>
        </div>

        <!-- Responsáveis -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Responsáveis</h6></div>

        <div class="col-md-4">
            <label class="form-label fw-semibold">Gestor do Contrato</label>
            <input type="text" name="gestor_nome" class="form-control"
                   value="<?= sanitize($contrato['gestor_nome'] ?? '') ?>">
        </div>
        <div class="col-md-2">
            <label class="form-label fw-semibold">Matrícula</label>
            <input type="text" name="gestor_matricula" class="form-control"
                   value="<?= sanitize($contrato['gestor_matricula'] ?? '') ?>">
        </div>
        <div class="col-md-4">
            <label class="form-label fw-semibold">Fiscal do Contrato</label>
            <input type="text" name="fiscal_nome" class="form-control"
                   value="<?= sanitize($contrato['fiscal_nome'] ?? '') ?>">
        </div>
        <div class="col-md-2">
            <label class="form-label fw-semibold">Matrícula</label>
            <input type="text" name="fiscal_matricula" class="form-control"
                   value="<?= sanitize($contrato['fiscal_matricula'] ?? '') ?>">
        </div>

        <!-- Observações -->
        <div class="col-12">
            <label class="form-label fw-semibold">Observações</label>
            <textarea name="observacoes" class="form-control" rows="3"><?= sanitize($contrato['observacoes'] ?? '') ?></textarea>
        </div>

        <div class="col-12 d-flex gap-2 justify-content-end mt-2">
            <a href="index.php" class="btn btn-outline-secondary">Cancelar</a>
            <button type="submit" class="btn btn-primary px-4">
                <i class="bi bi-check-lg"></i> <?= $is_edit ? 'Salvar Alterações' : 'Cadastrar Contrato' ?>
            </button>
        </div>
    </div>

</form>
</div>
</div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
