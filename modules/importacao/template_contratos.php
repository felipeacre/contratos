<?php
// modules/importacao/template_contratos.php
// Serve o download do modelo Excel de contratos
require_once __DIR__ . '/../../includes/bootstrap.php';
Auth::require_login();

$arquivo = BASE_PATH . '/uploads/imports/template_contratos.xlsx';

// Gera o template via Python se não existir
if (!file_exists($arquivo)) {
    $script = BASE_PATH . '/python/gerar_templates.py';
    if (file_exists($script)) {
        shell_exec(escapeshellcmd(PYTHON_BIN . ' ' . escapeshellarg($script)) . ' 2>&1');
    }
}

if (!file_exists($arquivo)) {
    flash('danger', 'Template não encontrado. Contate o administrador.');
    redirect(BASE_URL . '/modules/importacao/index.php');
}

header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="modelo_contratos_idaf.xlsx"');
header('Content-Length: ' . filesize($arquivo));
header('Cache-Control: no-cache');
readfile($arquivo);
exit;
