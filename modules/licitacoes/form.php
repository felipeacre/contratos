<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db = Database::get();
$id = (int)($_GET['id'] ?? 0);
$is_edit = $id > 0;

$licitacao = [];
if ($is_edit) {
    $stmt = $db->prepare('SELECT * FROM licitacoes WHERE id = ?');
    $stmt->execute([$id]);
    $licitacao = $stmt->fetch();
    if (!$licitacao) {
        flash('danger', 'Licitação não encontrada.');
        redirect(BASE_URL . '/modules/licitacoes/index.php');
    }
}

$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $f = $_POST;

    if (empty($f['numero_processo'])) $errors[] = 'Número do processo é obrigatório.';
    if (empty($f['objeto']))          $errors[] = 'Objeto é obrigatório.';
    if (empty($f['modalidade']))      $errors[] = 'Modalidade é obrigatória.';

    if (empty($errors)) {
        $data = [
            'numero_processo'        => trim($f['numero_processo']),
            'numero_licitacao'       => trim($f['numero_licitacao'] ?? ''),
            'objeto'                 => trim($f['objeto']),
            'modalidade'             => $f['modalidade'],
            'status'                 => $f['status'] ?? 'em_andamento',
            'valor_estimado'         => ($f['valor_estimado'] ?? '') !== ''
                                        ? (float) str_replace(',', '.', $f['valor_estimado'])
                                        : null,
            'data_abertura'          => ($f['data_abertura'] ?? '') ?: null,
            'data_prevista_conclusao'=> ($f['data_prevista_conclusao'] ?? '') ?: null,
            'data_homologacao'       => ($f['data_homologacao'] ?? '') ?: null,
            'responsavel'            => trim($f['responsavel'] ?? ''),
            'link_portal'            => trim($f['link_portal'] ?? ''),
            'observacoes'            => trim($f['observacoes'] ?? ''),
        ];

        if ($is_edit) {
            $set  = implode(', ', array_map(fn($k) => "$k = :$k", array_keys($data)));
            $stmt = $db->prepare("UPDATE licitacoes SET $set WHERE id = :id");
            $data['id'] = $id;
            $stmt->execute($data);
            flash('success', 'Licitação atualizada com sucesso.');
        } else {
            $data['origem'] = 'manual';
            $cols = implode(', ', array_keys($data));
            $vals = implode(', ', array_map(fn($k) => ":$k", array_keys($data)));
            $db->prepare("INSERT INTO licitacoes ($cols) VALUES ($vals)")->execute($data);
            flash('success', 'Licitação cadastrada com sucesso.');
        }
        redirect(BASE_URL . '/modules/licitacoes/index.php');
    }
    $licitacao = array_merge($licitacao, $f);
}

$page_title = $is_edit ? 'Editar Licitação' : 'Nova Licitação';
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

        <div class="col-12"><h6 class="text-muted border-bottom pb-1">Identificação</h6></div>

        <div class="col-md-4">
            <label class="form-label fw-semibold">Nº do Processo <span class="text-danger">*</span></label>
            <input type="text" name="numero_processo" class="form-control" required
                   value="<?= sanitize($licitacao['numero_processo'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Nº da Licitação</label>
            <input type="text" name="numero_licitacao" class="form-control"
                   value="<?= sanitize($licitacao['numero_licitacao'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Modalidade <span class="text-danger">*</span></label>
            <select name="modalidade" class="form-select" required>
                <option value="">-- Selecione --</option>
                <?php foreach ([
                    'pregao_eletronico'=>'Pregão Eletrônico',
                    'pregao_presencial'=>'Pregão Presencial',
                    'concorrencia'=>'Concorrência',
                    'tomada_de_precos'=>'Tomada de Preços',
                    'convite'=>'Convite',
                    'dispensa'=>'Dispensa',
                    'inexigibilidade'=>'Inexigibilidade',
                    'chamamento_publico'=>'Chamamento Público',
                ] as $k => $v): ?>
                <option value="<?= $k ?>" <?= ($licitacao['modalidade'] ?? '') === $k ? 'selected' : '' ?>><?= $v ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label fw-semibold">Status</label>
            <select name="status" class="form-select">
                <?php foreach ([
                    'em_andamento'=>'Em Andamento',
                    'aguardando_homologacao'=>'Aguard. Homologação',
                    'homologada'=>'Homologada',
                    'deserta'=>'Deserta',
                    'fracassada'=>'Fracassada',
                    'cancelada'=>'Cancelada',
                    'suspensa'=>'Suspensa',
                ] as $k => $v): ?>
                <option value="<?= $k ?>" <?= ($licitacao['status'] ?? 'em_andamento') === $k ? 'selected' : '' ?>><?= $v ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <div class="col-12">
            <label class="form-label fw-semibold">Objeto <span class="text-danger">*</span></label>
            <textarea name="objeto" class="form-control" rows="2" required><?= sanitize($licitacao['objeto'] ?? '') ?></textarea>
        </div>

        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Datas e Valores</h6></div>

        <div class="col-md-3">
            <label class="form-label fw-semibold">Data de Abertura</label>
            <input type="date" name="data_abertura" class="form-control"
                   value="<?= sanitize($licitacao['data_abertura'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Previsão de Conclusão</label>
            <input type="date" name="data_prevista_conclusao" class="form-control"
                   value="<?= sanitize($licitacao['data_prevista_conclusao'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Data de Homologação</label>
            <input type="date" name="data_homologacao" class="form-control"
                   value="<?= sanitize($licitacao['data_homologacao'] ?? '') ?>">
        </div>
        <div class="col-md-3">
            <label class="form-label fw-semibold">Valor Estimado (R$)</label>
            <input type="text" name="valor_estimado" class="form-control mask-money"
                   value="<?= $licitacao['valor_estimado'] ? number_format((float)$licitacao['valor_estimado'], 2, ',', '') : '' ?>">
        </div>

        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Informações Adicionais</h6></div>

        <div class="col-md-4">
            <label class="form-label fw-semibold">Responsável / Pregoeiro</label>
            <input type="text" name="responsavel" class="form-control"
                   value="<?= sanitize($licitacao['responsavel'] ?? '') ?>">
        </div>
        <div class="col-md-8">
            <label class="form-label fw-semibold">Link no Portal da Transparência / PNCP</label>
            <input type="url" name="link_portal" class="form-control"
                   value="<?= sanitize($licitacao['link_portal'] ?? '') ?>">
        </div>

        <div class="col-12">
            <label class="form-label fw-semibold">Observações</label>
            <textarea name="observacoes" class="form-control" rows="2"><?= sanitize($licitacao['observacoes'] ?? '') ?></textarea>
        </div>

        <div class="col-12 d-flex gap-2 justify-content-end mt-2">
            <a href="index.php" class="btn btn-outline-secondary">Cancelar</a>
            <button type="submit" class="btn btn-primary px-4">
                <i class="bi bi-check-lg"></i> <?= $is_edit ? 'Salvar Alterações' : 'Cadastrar Licitação' ?>
            </button>
        </div>

    </div>
</form>
</div>
</div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
