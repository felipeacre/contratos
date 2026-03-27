<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_admin();

$db = Database::get();

// Salvar novo usuário
$errors = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nome  = trim($_POST['nome']  ?? '');
    $email = trim($_POST['email'] ?? '');
    $senha = $_POST['senha']  ?? '';
    $nivel = $_POST['nivel']  ?? 'visualizador';
    $id_edit = (int)($_POST['id_edit'] ?? 0);

    if (!$nome)  $errors[] = 'Nome obrigatório.';
    if (!$email) $errors[] = 'E-mail obrigatório.';
    if (!$id_edit && !$senha) $errors[] = 'Senha obrigatória para novo usuário.';
    if ($senha && strlen($senha) < 8) $errors[] = 'Senha deve ter ao menos 8 caracteres.';

    if (empty($errors)) {
        if ($id_edit) {
            if ($senha) {
                $db->prepare('UPDATE usuarios SET nome=?, email=?, senha_hash=?, nivel=? WHERE id=?')
                   ->execute([$nome, $email, password_hash($senha, PASSWORD_DEFAULT), $nivel, $id_edit]);
            } else {
                $db->prepare('UPDATE usuarios SET nome=?, email=?, nivel=? WHERE id=?')
                   ->execute([$nome, $email, $nivel, $id_edit]);
            }
            flash('success', 'Usuário atualizado.');
        } else {
            $db->prepare('INSERT INTO usuarios (nome, email, senha_hash, nivel) VALUES (?,?,?,?)')
               ->execute([$nome, $email, password_hash($senha, PASSWORD_DEFAULT), $nivel]);
            flash('success', 'Usuário criado.');
        }
        redirect(BASE_URL . '/modules/usuarios/index.php');
    }
}

// Toggle ativo
if (isset($_GET['toggle']) && is_numeric($_GET['toggle'])) {
    $db->prepare('UPDATE usuarios SET ativo = 1 - ativo WHERE id = ?')->execute([(int)$_GET['toggle']]);
    redirect(BASE_URL . '/modules/usuarios/index.php');
}

$usuarios = $db->query('SELECT * FROM usuarios ORDER BY nome')->fetchAll();

$page_title = 'Usuários';
include __DIR__ . '/../../includes/header.php';
?>

<div class="d-flex align-items-center justify-content-between mb-3">
    <h5 class="mb-0 fw-bold"><i class="bi bi-people text-primary"></i> Usuários</h5>
    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalUsuario">
        <i class="bi bi-plus-lg"></i> Novo Usuário
    </button>
</div>

<?php if ($errors): ?>
<div class="alert alert-danger"><ul class="mb-0"><?php foreach ($errors as $e): ?><li><?= sanitize($e) ?></li><?php endforeach; ?></ul></div>
<?php endif; ?>

<div class="card shadow-sm">
    <div class="card-body p-0">
        <table class="table table-hover mb-0">
            <thead class="table-light">
                <tr><th>Nome</th><th>E-mail</th><th>Nível</th><th>Último Acesso</th><th>Status</th><th class="text-center">Ações</th></tr>
            </thead>
            <tbody>
            <?php foreach ($usuarios as $u): ?>
            <tr>
                <td><?= sanitize($u['nome']) ?></td>
                <td><?= sanitize($u['email']) ?></td>
                <td><span class="badge <?= $u['nivel'] === 'admin' ? 'bg-danger' : 'bg-secondary' ?>"><?= $u['nivel'] ?></span></td>
                <td><?= $u['ultimo_acesso'] ? data_br($u['ultimo_acesso']) : 'Nunca' ?></td>
                <td><?= $u['ativo'] ? '<span class="badge bg-success">Ativo</span>' : '<span class="badge bg-secondary">Inativo</span>' ?></td>
                <td class="text-center text-nowrap">
                    <button class="btn btn-sm btn-outline-primary"
                            onclick="preencherModalEdicao(<?= htmlspecialchars(json_encode($u), ENT_QUOTES) ?>)">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <?php if ($u['id'] !== (int)$_SESSION['usuario_id']): ?>
                    <a href="?toggle=<?= $u['id'] ?>" class="btn btn-sm btn-outline-secondary"
                       data-confirm="<?= $u['ativo'] ? 'Desativar' : 'Ativar' ?> o usuário <?= sanitize($u['nome']) ?>?">
                        <i class="bi bi-<?= $u['ativo'] ? 'pause' : 'play' ?>"></i>
                    </a>
                    <?php endif; ?>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal -->
<div class="modal fade" id="modalUsuario" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" novalidate>
                <input type="hidden" name="id_edit" id="modal-id-edit" value="0">
                <div class="modal-header">
                    <h5 class="modal-title" id="modal-titulo">Novo Usuário</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Nome</label>
                        <input type="text" name="nome" id="modal-nome" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">E-mail</label>
                        <input type="email" name="email" id="modal-email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Senha <span id="senha-hint" class="text-muted small">(obrigatória)</span></label>
                        <input type="password" name="senha" id="modal-senha" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Nível</label>
                        <select name="nivel" id="modal-nivel" class="form-select">
                            <option value="visualizador">Visualizador</option>
                            <option value="admin">Administrador</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Salvar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<?php
$extra_js = <<<JS
<script>
function preencherModalEdicao(u) {
    document.getElementById('modal-titulo').textContent = 'Editar Usuário';
    document.getElementById('modal-id-edit').value = u.id;
    document.getElementById('modal-nome').value    = u.nome;
    document.getElementById('modal-email').value   = u.email;
    document.getElementById('modal-nivel').value   = u.nivel;
    document.getElementById('modal-senha').value   = '';
    document.getElementById('senha-hint').textContent = '(deixe em branco para manter)';
    new bootstrap.Modal(document.getElementById('modalUsuario')).show();
}
</script>
JS;
?>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
