<?php
// ============================================================
// modules/dashboard/tv.php — Painel TV (leitura a 3 metros)
// ============================================================
require_once __DIR__ . '/../../includes/bootstrap.php';

$db = Database::get();

$json_mode = !empty($_GET['json']);

// Resumo
$resumo = $db->query('SELECT * FROM vw_dashboard_resumo')->fetch();

// Todos os contratos ativos
$contratos = $db->query("
    SELECT numero, fornecedor_display, fornecedor_nome, dias_para_vencer, status_vencimento
    FROM vw_contratos
    WHERE (status_manual IS NULL OR status_manual = 'ativo')
      AND status_vencimento IN ('vencido','critico','atencao','alerta','regular')
    ORDER BY dias_para_vencer ASC
    LIMIT 60
")->fetchAll();

// Divide nos 3 grupos
$tv_criticos  = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] <= 30));
$tv_atencao   = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] > 30 && (int)$c['dias_para_vencer'] <= 90));
$tv_tranquilo = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] > 90));

// Licitações em andamento
$licitacoes = $db->query("
    SELECT numero_processo, objeto, status
    FROM licitacoes
    WHERE status IN ('em_andamento','aguardando_homologacao')
    ORDER BY data_abertura DESC
    LIMIT 15
")->fetchAll();

// ── Helpers de renderização ──────────────────────────────────
function tv_card(array $c): string {
    $dias = (int)($c['dias_para_vencer'] ?? 0);
    $num  = htmlspecialchars($c['numero'] ?? '', ENT_QUOTES);
    $forn = htmlspecialchars(
        mb_strtoupper(mb_substr(trim($c['fornecedor_display'] ?? $c['fornecedor_nome'] ?? '—'), 0, 25)),
        ENT_QUOTES
    );

    if ($dias < 0)        { $bc='bc-vencido';   $bb='b-vencido';   $n='VENC.';  $u=''; }
    elseif ($dias <= 10)  { $bc='bc-urgente';   $bb='b-urgente';   $n=$dias;    $u='DIAS'; }
    elseif ($dias <= 30)  { $bc='bc-critico';   $bb='b-critico';   $n=$dias;    $u='DIAS'; }
    elseif ($dias <= 90)  { $bc='bc-atencao';   $bb='b-atencao';   $n=$dias;    $u='DIAS'; }
    else                  { $bc='bc-tranquilo'; $bb='b-tranquilo'; $n=$dias;    $u='DIAS'; }

    $unit = $u ? "<span class=\"badge-unit\">{$u}</span>" : '';

    return <<<HTML
<div class="tv-card {$bc}">
    <div class="tv-card-info">
        <div class="tv-card-num">{$num}</div>
        <div class="tv-card-forn">{$forn}</div>
    </div>
    <div class="tv-card-badge {$bb}">{$n}{$unit}</div>
</div>
HTML;
}

function tv_lic_card(array $l): string {
    $num = htmlspecialchars($l['numero_processo'] ?? '', ENT_QUOTES);
    $obj = htmlspecialchars(mb_strtoupper(mb_substr(trim($l['objeto'] ?? ''), 0, 28)), ENT_QUOTES);
    $st  = $l['status'] ?? '';
    if ($st === 'em_andamento') {
        $status = '<span style="color:#33ccee">EM ANDAMENTO</span>';
    } elseif ($st === 'aguardando_homologacao') {
        $status = '<span style="color:#ffcc00">AG. HOMOLOGAÇÃO</span>';
    } else {
        $status = htmlspecialchars(strtoupper($st), ENT_QUOTES);
    }
    return <<<HTML
<div class="tv-lic-card">
    <div class="tv-lic-num">{$num}</div>
    <div class="tv-lic-obj">{$obj}</div>
    <div class="tv-lic-status">{$status}</div>
</div>
HTML;
}

// ── JSON para atualização automática ────────────────────────
if ($json_mode) {
    json_response([
        'resumo'     => $resumo,
        'contratos'  => $contratos,
        'licitacoes' => $licitacoes,
        'ts'         => date('H:i:s'),
    ]);
}
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><?= APP_NAME ?> — Painel TV</title>
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/app.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { height: 100%; }
        body {
            height: 100%;
            overflow: hidden;
            /* zoom aplicado via JS abaixo para escalar 1920px em qualquer TV */
            transform-origin: top left;
        }
    </style>
    <script>
        /* Escala o layout proporcionalmente ao viewport real da TV.
           O CSS foi desenhado para 1920px de largura.
           Em Android TV (DPR=2) o viewport real costuma ser 960px —
           este script aplica zoom para que 1920 CSS px caibam na tela. */
        (function () {
            var BASE_W = 1920;
            function applyScale() {
                var scale = window.innerWidth / BASE_W;
                document.body.style.transform = 'scale(' + scale + ')';
                document.body.style.width      = BASE_W + 'px';
                document.body.style.height     = (window.innerHeight / scale) + 'px';
            }
            document.addEventListener('DOMContentLoaded', applyScale);
            window.addEventListener('resize', applyScale);
        })();
    </script>
</head>
<body class="tv-mode">

<!-- ── HEADER ─────────────────────────────────────────── -->
<header class="tv-header">
    <!-- esquerda: logo -->
    <div class="tv-header-logo">
        <div class="logo-text">
            <span style="color:#f39c12">&#9632;</span>
            IDAF/AC &mdash; Controle de Contratos
        </div>
        <div class="logo-sub">Instituto de Defesa Agropecuária e Florestal do Acre</div>
    </div>
    <!-- centro: relógio -->
    <div class="tv-header-clock">
        <div class="clock" id="tv-clock">--:--:--</div>
    </div>
    <!-- direita: data -->
    <?php
    $sem = ['Sunday'=>'Domingo','Monday'=>'Segunda-feira','Tuesday'=>'Terça-feira',
            'Wednesday'=>'Quarta-feira','Thursday'=>'Quinta-feira',
            'Friday'=>'Sexta-feira','Saturday'=>'Sábado'];
    $mes = ['January'=>'Janeiro','February'=>'Fevereiro','March'=>'Março',
            'April'=>'Abril','May'=>'Maio','June'=>'Junho','July'=>'Julho',
            'August'=>'Agosto','September'=>'Setembro','October'=>'Outubro',
            'November'=>'Novembro','December'=>'Dezembro'];
    $data_pt = ($sem[date('l')] ?? date('l')) . ', ' . date('d') . ' de ' . ($mes[date('F')] ?? date('F')) . ' de ' . date('Y');
    ?>
    <div class="tv-header-date">
        <div class="tv-date"><?= $data_pt ?></div>
    </div>
</header>

<!-- ── RESUMO ─────────────────────────────────────────── -->
<div class="tv-cards">
    <div class="tv-stat s-vencido">
        <div class="num" id="tv-num-vencidos"><?= $resumo['vencidos'] ?? 0 ?></div>
        <div class="label">Vencidos</div>
    </div>
    <div class="tv-stat s-critico">
        <div class="num" id="tv-num-criticos"><?= $resumo['criticos'] ?? 0 ?></div>
        <div class="label">Críticos<br>&lt;30 dias</div>
    </div>
    <div class="tv-stat s-atencao">
        <div class="num" id="tv-num-atencao"><?= $resumo['atencao'] ?? 0 ?></div>
        <div class="label">Atenção<br>&lt;90 dias</div>
    </div>
    <div class="tv-stat s-alerta">
        <div class="num" id="tv-num-alerta"><?= $resumo['alerta'] ?? 0 ?></div>
        <div class="label">Alerta<br>&lt;180 dias</div>
    </div>
    <div class="tv-stat s-regular">
        <div class="num" id="tv-num-regulares"><?= $resumo['regulares'] ?? 0 ?></div>
        <div class="label">Regulares</div>
    </div>
</div>

<!-- ── PAINÉIS ────────────────────────────────────────── -->
<div class="tv-main">

    <!-- 🔴 CRÍTICOS -->
    <div class="tv-section">
        <div class="tv-section-header sh-criticos">
            <span>&#128308; Críticos</span>
            <span class="sec-count" id="tv-count-criticos"><?= count($tv_criticos) ?></span>
        </div>
        <div class="tv-section-body">
            <div class="tv-section-scroll" id="tv-scroll-criticos">
                <?php if (empty($tv_criticos)): ?>
                    <div class="tv-empty-msg">&#10003; Nenhum contrato crítico</div>
                <?php else: foreach ($tv_criticos as $c): echo tv_card($c); endforeach; endif; ?>
            </div>
        </div>
    </div>

    <!-- 🟡 ATENÇÃO -->
    <div class="tv-section">
        <div class="tv-section-header sh-atencao">
            <span>&#128993; Atenção</span>
            <span class="sec-count" id="tv-count-atencao"><?= count($tv_atencao) ?></span>
        </div>
        <div class="tv-section-body">
            <div class="tv-section-scroll" id="tv-scroll-atencao">
                <?php if (empty($tv_atencao)): ?>
                    <div class="tv-empty-msg">&#10003; Nenhum</div>
                <?php else: foreach ($tv_atencao as $c): echo tv_card($c); endforeach; endif; ?>
            </div>
        </div>
    </div>

    <!-- 🟢 TRANQUILO -->
    <div class="tv-section">
        <div class="tv-section-header sh-tranquilo">
            <span>&#128994; Tranquilo</span>
            <span class="sec-count" id="tv-count-tranquilo"><?= count($tv_tranquilo) ?></span>
        </div>
        <div class="tv-section-body">
            <div class="tv-section-scroll" id="tv-scroll-tranquilo">
                <?php if (empty($tv_tranquilo)): ?>
                    <div class="tv-empty-msg">&#10003; Nenhum</div>
                <?php else: foreach ($tv_tranquilo as $c): echo tv_card($c); endforeach; endif; ?>
            </div>
        </div>
    </div>

</div>

<script src="<?= BASE_URL ?>/assets/js/app.js"></script>
<script>
    initTvClock();

    var scrollReset = {};
    // Velocidade em pixels/segundo — aumente para rolar mais rápido
    scrollReset['criticos']  = initTvEscalator('tv-scroll-criticos',  55);
    scrollReset['atencao']   = initTvEscalator('tv-scroll-atencao',   50);
    scrollReset['tranquilo'] = initTvEscalator('tv-scroll-tranquilo', 45);

    initTvRefresh(60);

    // ── Tela cheia automática ──────────────────────────────────────
    // Android TV pode bloquear requestFullscreen sem gesto do usuário.
    // Tenta no carregamento; se falhar, aguarda o primeiro toque/clique.
    function goFullscreen() {
        var el = document.documentElement;
        var fn = el.requestFullscreen
               || el.webkitRequestFullscreen   // Safari / WebView antigo
               || el.mozRequestFullScreen
               || el.msRequestFullscreen;
        if (fn) fn.call(el);
    }

    // Tentativa 1: direto no load (funciona se o browser permitir)
    window.addEventListener('load', function() {
        try { goFullscreen(); } catch(e) {}
    });

    // Tentativa 2: primeiro gesto do usuário (necessário em muitos Android TV)
    var _fsOnce = false;
    function _fsGesture() {
        if (_fsOnce) return;
        _fsOnce = true;
        try { goFullscreen(); } catch(e) {}
        document.removeEventListener('click',      _fsGesture);
        document.removeEventListener('touchstart', _fsGesture);
        document.removeEventListener('keydown',    _fsGesture);
    }
    document.addEventListener('click',      _fsGesture);
    document.addEventListener('touchstart', _fsGesture);
    document.addEventListener('keydown',    _fsGesture);

    // Tentativa 3: volta ao fullscreen se o usuário sair sem querer
    document.addEventListener('fullscreenchange', function() {
        if (!document.fullscreenElement) {
            setTimeout(function() { try { goFullscreen(); } catch(e) {} }, 2000);
        }
    });
</script>
</body>
</html>
