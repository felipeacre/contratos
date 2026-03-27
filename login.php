<?php
require_once __DIR__ . '/includes/bootstrap.php';

if (Auth::check()) {
    redirect(BASE_URL . '/index.php');
}

$erro = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $senha = $_POST['senha'] ?? '';

    if (Auth::login($email, $senha)) {
        redirect(BASE_URL . '/index.php');
    } else {
        $erro = 'E-mail ou senha incorretos.';
    }
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Acesso — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/app.css">
    <style>
        body { background: linear-gradient(135deg, #0a1628, #1a3c5e); min-height: 100vh; display:flex; align-items:center; }
        .login-card {
            background: rgba(255,255,255,.97);
            border-radius: 18px;
            box-shadow: 0 20px 60px rgba(0,0,0,.35);
            padding: 2.5rem 2.5rem 2rem;
            width: 100%;
            max-width: 420px;
        }
        .login-logo { color: var(--idaf-primary); font-size: 2.5rem; }
    </style>
</head>
<body>
<div class="container d-flex justify-content-center">
    <div class="login-card">
        <div class="text-center mb-4">
            <i class="bi bi-file-earmark-text-fill login-logo"></i>
            <h1 class="fs-4 fw-bold mt-2" style="color:var(--idaf-primary)"><?= APP_NAME ?></h1>
            <p class="text-muted small">IDAF/AC — Sistema de Gestão de Contratos</p>
        </div>

        <?php if ($erro): ?>
        <div class="alert alert-danger py-2"><?= sanitize($erro) ?></div>
        <?php endif; ?>

        <form method="post" novalidate>
            <div class="mb-3">
                <label class="form-label fw-semibold">E-mail</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" name="email" class="form-control" required
                           value="<?= sanitize($_POST['email'] ?? '') ?>" autofocus>
                </div>
            </div>
            <div class="mb-4">
                <label class="form-label fw-semibold">Senha</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                    <input type="password" name="senha" class="form-control" required>
                </div>
            </div>
            <button type="submit" class="btn btn-primary w-100 fw-bold py-2"
                    style="background:var(--idaf-primary);border-color:var(--idaf-primary)">
                <i class="bi bi-box-arrow-in-right"></i> Entrar
            </button>
        </form>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
