<?php
// ============================================================
// config/config.php — Configurações globais do sistema
// ============================================================

define('APP_NAME', 'Contratos IDAF/AC');
define('APP_VERSION', '1.0.0');
// Detecta automaticamente o host (funciona com localhost e acesso por IP na rede)
define('BASE_URL', (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http')
    . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost') . '/contratos');
define('BASE_PATH', dirname(__DIR__));

// Banco de dados — lê variáveis de ambiente (Docker) ou usa padrão local
define('DB_HOST',    getenv('DB_HOST') ?: 'localhost');
define('DB_NAME',    getenv('DB_NAME') ?: 'contratos_idaf');
define('DB_USER',    getenv('DB_USER') ?: 'root');
define('DB_PASS',    getenv('DB_PASS') ?: '');
define('DB_CHARSET', 'utf8mb4');

// Upload
define('UPLOAD_PDF_DIR', BASE_PATH . '/uploads/pdfs/');
define('UPLOAD_IMPORT_DIR', BASE_PATH . '/uploads/imports/');
define('UPLOAD_MAX_MB', 20);

// Python
define('PYTHON_BIN', 'python3');     // ou caminho absoluto: '/usr/bin/python3'
define('PYTHON_SCRIPT', BASE_PATH . '/python/extrator_pdf.py');

// Sessão
define('SESSION_LIFETIME', 3600 * 8); // 8 horas

// Faixas de alerta (dias)
define('DIAS_CRITICO', 30);
define('DIAS_ATENCAO', 90);
define('DIAS_ALERTA', 180);

// Timezone
date_default_timezone_set('America/Rio_Branco');
