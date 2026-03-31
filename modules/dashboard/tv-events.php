<?php
// ============================================================
// modules/dashboard/tv-events.php — Server-Sent Events para TV
// A TV se conecta aqui; quando um contrato/licitação é salvo,
// o servidor empurra um evento e a TV atualiza os dados.
// ============================================================
require_once __DIR__ . '/../../includes/bootstrap.php';

// Libera a sessão imediatamente para não bloquear outras requisições
session_write_close();

$flagFile  = BASE_PATH . '/uploads/tv_last_update.txt';
$lastKnown = isset($_GET['since']) ? (int) $_GET['since'] : 0;

// Headers SSE
header('Content-Type: text/event-stream');
header('Cache-Control: no-cache');
header('Connection: keep-alive');
header('X-Accel-Buffering: no');   // nginx: desabilita buffer para SSE fluir

// Sem limite de tempo de execução para conexão longa
set_time_limit(0);
ignore_user_abort(false);

// Envia timestamp atual para o cliente saber o "último evento conhecido"
$current = file_exists($flagFile) ? (int) file_get_contents($flagFile) : time();
echo "data: " . json_encode(['ts' => $current]) . "\n\n";
ob_flush(); flush();

$timeout = time() + 28;   // reconecta a cada ~30s (evita timeout de proxies)

while (time() < $timeout && !connection_aborted()) {
    $ts = file_exists($flagFile) ? (int) file_get_contents($flagFile) : 0;

    if ($ts > $lastKnown) {
        $lastKnown = $ts;
        echo "data: " . json_encode(['ts' => $ts, 'update' => true]) . "\n\n";
        ob_flush(); flush();
    } else {
        // Heartbeat — mantém conexão viva em proxies/firewalls
        echo ": ping\n\n";
        ob_flush(); flush();
    }

    sleep(3);
}

// Fim do ciclo — cliente vai reconectar automaticamente (comportamento padrão do EventSource)
