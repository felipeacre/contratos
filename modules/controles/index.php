<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$db = Database::get();
$stmt = $db->prepare('SELECT * FROM controles');
$controle = $db->query('SELECT * FROM controles')->fetch();
$modal = explode('_', $controle['modal']);
$ultimoPesquisado = empty($controle['modal']) ? 'Ex. 19/2024':'Último: ' . str_replace('-', '/', $modal[1]);
// SALVAR
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $f = $_POST;
    $data = [
        'velocidade_contrato_tranquilo' => empty($f['velocidade_contrato_tranquilo']) ? 30 : trim($f['velocidade_contrato_tranquilo']),
        'velocidade_contrato_atencao' => empty($f['velocidade_contrato_atencao']) ? 30 : trim($f['velocidade_contrato_atencao']),
        'velocidade_contrato_critico' => empty($f['velocidade_contrato_critico']) ? 30 : trim($f['velocidade_contrato_critico']),
        'velocidade_licitacao_homologada' => empty($f['velocidade_licitacao_homologada']) ? 30 : trim($f['velocidade_licitacao_homologada']),
        'velocidade_licitacao_andamento' => empty($f['velocidade_licitacao_andamento']) ? 30 : trim($f['velocidade_licitacao_andamento']),
        'velocidade_licitacao_deserta' => empty($f['velocidade_licitacao_deserta']) ? 30 : trim($f['velocidade_licitacao_deserta']),
        'transicao' => empty($f['transicao']) ? 60 : trim($f['transicao']),
    ];
    if(!empty($f['modal'])){
        $data['modal'] = $f['tipo'].'_'.trim(str_replace('/', '-', $f['modal']));
        $data['created_at'] = date('Y-m-d H:i:s');
    }
    try {
        //code...
        $set = implode(', ', array_map(fn($k) => "$k = :$k", array_keys($data)));
        $stmt = $db->prepare("UPDATE controles SET $set WHERE user_id = 1");
        $stmt->execute($data);
    } catch (\Throwable $th) {
       die($th->getMessage());
    }
    
    redirect(BASE_URL . '/modules/controles');
}

include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center gap-2 mb-3">
    <a href="index.php" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
    <h5 class="mb-0 fw-bold">Controles</h5>
</div>

<div class="card shadow-sm">
<div class="card-body">
<form method="post" novalidate>

    <div class="row g-3 align-items-end">
        <!-- Identificação -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1">Modals</h6></div>

        <div class="col-md-6">
            <label class="form-label fw-semibold">Tipo</label>
            <select name="tipo" class="form-select">
                <option value="">Selecione...</option>
                <option value="contrato" <?php if($modal[0] == 'contrato') echo 'selected' ?>>Contrato</option>
                <option value="licitacao" <?php if($modal[0] == 'licitacao') echo 'selected' ?>>Licitação</option>
            </select>
        </div>
        <div class="col-md-6">
            <label class="form-label fw-semibold">Número do Licitação ou Contrato</label>
            <input type="text" name="modal" class="form-control" placeholder="<?= $ultimoPesquisado ?>">
        </div>

        <!-- Velocidade -->
        <div class="col-12"><h6 class="text-muted border-bottom pb-1 mt-2">Velocidade</h6></div>
        
        <div class="row mt-3">
            <div class="col-12 mb-3">
                <label class="form-label fw-semibold">Velocidade (transição)</label>
                <input type="number" name="transicao" class="form-control" value="<?= $controle['transicao'] ?>">
            </div>
            <div class="col-md-4">
                <label class="form-label fw-semibold">Contrato (tranquilo)</label>
                <input type="number" name="velocidade_contrato_tranquilo" class="form-control" value="<?= $controle['velocidade_contrato_tranquilo'] ?>">
            </div>
            
            <div class="col-md-4">
                <label class="form-label fw-semibold">Contrato (atenção)</label>
                <input type="number" name="velocidade_contrato_atencao" class="form-control" value="<?= $controle['velocidade_contrato_atencao'] ?>">
            </div>
            
            <div class="col-md-4">
                <label class="form-label fw-semibold">Contrato (críticos)</label>
                <input type="number" name="velocidade_contrato_critico" class="form-control" value="<?= $controle['velocidade_contrato_critico'] ?>">
            </div>
        </div>        
        
        <div class="row mt-3">
            <div class="col-md-4">
                <label class="form-label fw-semibold">Licitação (fracassada / deserta)</label>
                <input type="number" name="velocidade_licitacao_deserta" class="form-control" value="<?= $controle['velocidade_licitacao_deserta'] ?>">
            </div>
            
            <div class="col-md-4">
                <label class="form-label fw-semibold">Licitação (em andamento)</label>
                <input type="number" name="velocidade_licitacao_andamento" class="form-control" value="<?= $controle['velocidade_licitacao_andamento'] ?>">
            </div>
            
            <div class="col-md-4">
                <label class="form-label fw-semibold">Licitação (homologada)</label>
                <input type="number" name="velocidade_licitacao_homologada" class="form-control" value="<?= $controle['velocidade_licitacao_homologada'] ?>">
            </div>
        </div>        

        <div class="col-12 d-flex gap-2 justify-content-end mt-2">
            <a href="index.php" class="btn btn-outline-secondary">Cancelar</a>
            <button type="submit" class="btn btn-primary px-4">
                <i class="bi bi-check-lg"></i> Salvar
            </button>
        </div>
    </div>

</form>
</div>
</div>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
