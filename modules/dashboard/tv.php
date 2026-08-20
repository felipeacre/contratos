<?php
// ============================================================
// modules/dashboard/tv.php — Painel TV (leitura a 3 metros)
// ============================================================
require_once __DIR__ . '/../../includes/bootstrap.php';
$db = Database::get();
// print_r($_SESSION);exit;
$json_mode = !empty($_GET['json']);

// Resumo
$resumo = $db->query('SELECT * FROM vw_dashboard_resumo')->fetch() ?: [];
$controles = $db->query('SELECT * FROM controles')->fetch() ?: [];
$resumoLicitacoes = $db->query('SELECT * FROM vw_resumo_licitacao')->fetch() ?: [];
// print_r(json_encode($controles));exit;

// Todos os contratos ativos
$contratos = $db->query(LIST_CONTRATOS)->fetchAll();
$licitacoes = $db->query(LIST_LICITAÇOES)->fetchAll();

// Divide nos 3 grupos
$tv_criticos  = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] <= 30));
$tv_atencao   = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] > 30 && (int)$c['dias_para_vencer'] <= 90));
$tv_tranquilo = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] > 90));

$tv_fracassadas_desertas  = array_values(array_filter($licitacoes, fn($c) => $c['status'] == 'fracassada' || $c['status'] == 'deserta'));
$tv_homologadas   = array_values(array_filter($licitacoes, fn($c) => $c['status'] == 'homologada'));
$tv_em_andamento = array_values(array_filter($licitacoes, fn($c) => $c['status'] == 'em_andamento'));

$countColLic = 0;
$countResLic = 0;
$showLicitacao = 'd-none';
$showLicitacaoFracassadaDeserta = 'd-none';
$showLicitacaoDeserta = 'd-none';
$showLicitacaoFracassada = 'd-none';
$showLicitacaoAndamento = 'd-none';
$showLicitacaoHomologada = 'd-none';
$timeTransition = '';
if(!empty($resumoLicitacoes['fracassada']) || !empty($resumoLicitacoes['deserta'])){
    if(!empty($resumoLicitacoes['fracassada'])){
        $countResLic++;
        $showLicitacaoFracassada = '';
    }
    if(!empty($resumoLicitacoes['deserta'])){
        $countResLic++;
        $showLicitacaoDeserta = '';
    }
    $countColLic++;
    $showLicitacaoFracassadaDeserta = '';
}
if(!empty($resumoLicitacoes['homologada'])){
    $countColLic++;
    $countResLic++;
    $showLicitacaoHomologada = '';
}
if(!empty($resumoLicitacoes['em_andamento'])){
    $countColLic++;
    $countResLic++;
    $showLicitacaoAndamento = '';
}
if(!empty($countColLic)){
    $showLicitacao = 'item-licitacao';
    $timeTransition = "--time-transition: " . ($controles['transicao'] ?? 60) . "s;";
} 
// echo $countColLic;exit;

// Licitações em andamento
// $licitacoes = $db->query("
//     SELECT numero_processo, objeto, status
//     FROM licitacoes
//     WHERE status IN ('em_andamento','aguardando_homologacao')
//     ORDER BY data_abertura DESC
//     LIMIT 15
// ")->fetchAll();

// ── JSON para atualização automática ────────────────────────
if ($json_mode) {
    json_response([
        'resumo'     => $resumo,
        'resumo_licitacoes' => $resumoLicitacoes,
        'controles' => $controles,
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
    <!-- Bootstrap 5 -->
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/bootstrap.min.css">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/bootstrap-icons.min.css">
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/app.css">
    <style>
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html {
            height: 100%;
        }

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
        (function() {
            var BASE_W = 1920;

            function applyScale() {
                var scale = window.innerWidth / BASE_W;
                document.body.style.transform = 'scale(' + scale + ')';
                document.body.style.width = BASE_W + 'px';
                document.body.style.height = (window.innerHeight / scale) + 'px';
            }
            document.addEventListener('DOMContentLoaded', applyScale);
            window.addEventListener('resize', applyScale);
        })();
    </script>
</head>

<body class="tv-mode">
    <header class="tv-header">
        <!-- esquerda: logo -->
        <div class="tv-header-logo">
            <div class="logo-text">
                <span style="color:#f39c12">&#9632;</span>
                IDAF/AC &mdash; Controle de Contratos e Licitações
            </div>
            <div class="logo-sub">Instituto de Defesa Agropecuária e Florestal do Acre</div>
        </div>
        <!-- centro: relógio -->
        <div class="tv-header-clock">
            <div class="clock" id="tv-clock">--:--:--</div>
        </div>
        <!-- direita: data -->
        <?php
        $sem = [
            'Sunday' => 'Domingo',
            'Monday' => 'Segunda-feira',
            'Tuesday' => 'Terça-feira',
            'Wednesday' => 'Quarta-feira',
            'Thursday' => 'Quinta-feira',
            'Friday' => 'Sexta-feira',
            'Saturday' => 'Sábado'
        ];
        $mes = [
            'January' => 'Janeiro',
            'February' => 'Fevereiro',
            'March' => 'Março',
            'April' => 'Abril',
            'May' => 'Maio',
            'June' => 'Junho',
            'July' => 'Julho',
            'August' => 'Agosto',
            'September' => 'Setembro',
            'October' => 'Outubro',
            'November' => 'Novembro',
            'December' => 'Dezembro'
        ];
        $data_pt = ($sem[date('l')] ?? date('l')) . ', ' . date('d') . ' de ' . ($mes[date('F')] ?? date('F')) . ' de ' . date('Y');
        $criticosHidden = (int)$resumo['vencido_hid'] + (int)$resumo['critico_hid'];
        $atencaoHidden =  (int)$resumo['atencao_hid'];
        $tranquiloHidden = (int)$resumo['alerta_hid'] + (int)$resumo['regular_hid'];

        $qtdDesertaFracassada = $resumoLicitacoes['deserta'] + $resumoLicitacoes['fracassada'];
        $qtdAndamento = $resumoLicitacoes['em_andamento'];
        $qtdHomologada = $resumoLicitacoes['homologada'];

        $styleDesertaFracassada = '';
        $styleAndamento = '';
        $styleHomologada = '';
        if($qtdDesertaFracassada >= 3) $styleDesertaFracassada = "--time-deserta: " . ($controles['velocidade_licitacao_deserta'] ?? 30) . "s;";
        if($qtdAndamento >= 3) $styleAndamento = "--time-andamento: " . ($controles['velocidade_licitacao_andamento'] ?? 30) . "s;";
        if($qtdHomologada >= 3) $styleHomologada = "--time-homologada: " . ($controles['velocidade_licitacao_homologada'] ?? 30) . "s;";
        ?>
        <div class="tv-header-date">
            <div class="tv-date"><?= $data_pt ?></div>
        </div>
    </header>
    <!-- ── RESUMO ─────────────────────────────────────────── -->
    <div class="tv-cards" id="tv-cards-resumo">
        <div class="tv-stat s-vencido">
            <div class="num" id="tv-num-vencidos"><?= $resumo['vencido'] ?? 0 ?></div>
            <div class="label">Vencidos</div>
        </div>
        <div class="tv-stat s-critico">
            <div class="num" id="tv-num-criticos"><?= $resumo['critico'] ?? 0 ?></div>
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
            <div class="num" id="tv-num-regulares"><?= $resumo['regular'] ?? 0 ?></div>
            <div class="label">Regulares</div>
        </div>
    </div>

    <div class="tv-cards-licitacao-<?=$countResLic?>col <?= $showLicitacao ?>" id="tv-cards-resumo-licitacao" style="margin-top: -164px; <?= $timeTransition ?>">
        <div class="tv-stat s-vencido <?= $showLicitacaoFracassada ?>" id="tv-stat-fracassada">
            <div class="num" id="tv-num-fracassada"><?= $resumoLicitacoes['fracassada'] ?? 0 ?></div>
            <div class="label">Fracassada</div>
        </div>
        <div class="tv-stat s-atencao <?= $showLicitacaoDeserta ?>" id="tv-stat-deserta">
            <div class="num" id="tv-num-deserta"><?= $resumoLicitacoes['deserta'] ?? 0 ?></div>
            <div class="label">Deserta</div>
        </div>
        <div class="tv-stat s-alerta <?= $showLicitacaoAndamento ?>" id="tv-stat-andamento">
            <div class="num" id="tv-num-andamento"><?= $resumoLicitacoes['em_andamento'] ?? 0 ?></div>
            <div class="label">Em Andamento</div>
        </div>
        <div class="tv-stat s-regular <?= $showLicitacaoHomologada ?>" id="tv-stat-homologada">
            <div class="num" id="tv-num-homologada"><?= $resumoLicitacoes['homologada'] ?? 0 ?></div>
            <div class="label">Homologadas</div>
        </div>
    </div>

    <!-- ── PAINÉIS ────────────────────────────────────────── -->
    <div class="tv-main-3col" id="tv-main-contrato">
        <!-- 🔴 CRÍTICOS -->
        <div class="tv-section">
            <div class="tv-section-header sh-criticos">
                <span>&#128308; Críticos</span>
                <span class="sec-count">
                    <span id="tv-count-criticos"><?= $resumo['vencido'] + $resumo['critico'] ?></span>
                    <span id="tv-count-criticos-hidden">
                        <?php if ($criticosHidden > 0): ?>
                            &nbsp;|&nbsp;<i class="bi bi-eye-slash"></i><?= $criticosHidden ?>
                        <?php endif ?>
                    </span>
                </span>
            </div>
            <div class="tv-section-body">
                <div class="tv-section-scroll" id="tv-section-scroll-critico" style="--time-critico: <?=$controles['velocidade_contrato_critico'] ?? 30?>s;">
                    <?php if (empty($tv_criticos)): ?>
                        <div class="tv-empty-msg">&#10003; Nenhum contrato crítico</div>
                    <?php else:
                        foreach ($tv_criticos as $c):
                            echo tv_card($c);
                        endforeach;

                        foreach ($tv_criticos as $c):
                            echo tv_card($c, '-copy');
                        endforeach;
                    endif; ?>
                </div>
            </div>
        </div>
        <!-- 🟡 ATENÇÃO -->
        <div class="tv-section">
            <div class="tv-section-header sh-atencao">
                <span>&#128993; Atenção</span>
                <span class="sec-count">
                    <span id="tv-count-atencao"><?= $resumo['atencao'] ?></span>
                    <span id="tv-count-atencao-hidden">
                        <?php if ($atencaoHidden > 0): ?>
                            &nbsp;|&nbsp;<i class="bi bi-eye-slash"></i><?= $atencaoHidden ?>
                        <?php endif ?>
                    </span>
                </span>
            </div>
            <div class="tv-section-body">
                <div class="tv-section-scroll" id="tv-section-scroll-atencao" style="--time-atencao: <?=$controles['velocidade_contrato_atencao'] ?? 30?>s;">
                    <?php if (empty($tv_atencao)): ?>
                        <div class="tv-empty-msg">&#10003; Nenhum</div>
                    <?php else:
                        foreach ($tv_atencao as $c):
                            echo tv_card($c);
                        endforeach;

                        foreach ($tv_atencao as $c):
                            echo tv_card($c, '-copy');
                        endforeach;
                    endif; ?>
                </div>
            </div>
        </div>
        <!-- 🟢 TRANQUILO -->
        <div class="tv-section">
            <div class="tv-section-header sh-tranquilo">
                <span>&#128994; Tranquilo</span>
                <span class="sec-count">
                    <span id="tv-count-tranquilo"><?= $resumo['alerta'] + $resumo['regular'] ?></span>
                    <span id="tv-count-tranquilo-hidden">
                        <?php if ($tranquiloHidden > 0): ?>
                            &nbsp;|&nbsp;<i class="bi bi-eye-slash"></i><?= $tranquiloHidden ?>
                        <?php endif ?>
                    </span>
                </span>
            </div>
            <div class="tv-section-body">
                <div class="tv-section-scroll" id="tv-section-scroll-tranquilo" style="--time-tranquilo: <?=$controles['velocidade_contrato_tranquilo'] ?? 30?>s;">
                    <?php if (!empty($tv_tranquilo)):
                        foreach ($tv_tranquilo as $c):
                            echo tv_card($c);
                        endforeach;

                        foreach ($tv_tranquilo as $c):
                            echo tv_card($c, '-copy');
                        endforeach;
                    endif; ?>
                </div>
            </div>
        </div>
    </div>

    <div class="<?= $showLicitacao ?> tv-main-<?= $countColLic ?>col" id="tv-main-licitacao" style="position: absolute; top: 250px; <?= $timeTransition ?>">
        <!-- 🔵 FRACASSADA/DESERTA -->
        <div class="tv-section <?= $showLicitacaoFracassadaDeserta ?>" id="tv-section-deserta">
            <div class="tv-section-header sh-criticos">
                <span class="sh-criticos">Fracassadas / Deserta</span>
                <span class="sec-count">
                    <span id="tv-count-deserta"><?= $qtdDesertaFracassada ?></span>
                </span>
            </div>
            <div class="tv-section-body">
                <div class="tv-section-scroll" id="tv-section-scroll-deserta" style="<?= $styleDesertaFracassada ?>">
                    <?php if (!empty($tv_fracassadas_desertas)):
                        foreach ($tv_fracassadas_desertas as $c):
                            echo tv_card_licitacao($c);
                        endforeach;
                        if(count($tv_fracassadas_desertas) >= 3){
                            foreach ($tv_fracassadas_desertas as $c):
                                echo tv_card_licitacao($c);
                            endforeach;
                        }
                    endif; ?>
                </div>
            </div>
        </div>

        <!-- 🔵 EM ANDAMENTO -->
        <div class="tv-section <?= $showLicitacaoAndamento ?>" id="tv-section-andamento">
            <div class="tv-section-header sh-alerta">
                <span>🔵 Em Andamento</span>
                <span class="sec-count">
                    <span id="tv-count-andamento"><?= $qtdAndamento ?></span>
                </span>
            </div>
            <div class="tv-section-body">
                <div class="tv-section-scroll" id="tv-section-scroll-andamento" style="<?= $styleAndamento ?>">
                    <?php
                        foreach ($tv_em_andamento as $c):
                            echo tv_card_licitacao($c);
                        endforeach;
                        foreach ($tv_em_andamento as $c):
                            echo tv_card_licitacao($c);
                        endforeach; ?>
                </div>
            </div>
        </div>

        <!-- 🟢 HOMOLOGADA -->
        <div class="tv-section <?= $showLicitacaoHomologada ?>" id="tv-section-homologada">
            <div class="tv-section-header sh-tranquilo">
                <span>&#128994; Homologadas</span>
                <span class="sec-count">
                    <span id="tv-count-homologada"><?= $qtdHomologada ?></span>
                </span>
            </div>
            <div class="tv-section-body">
                <div class="tv-section-scroll" id="tv-section-scroll-homologada" style="<?= $styleHomologada ?>">
                    <?php 
                        foreach ($tv_homologadas as $c):
                            echo tv_card_licitacao($c);
                        endforeach;

                        foreach ($tv_homologadas as $c):
                            echo tv_card_licitacao($c);
                        endforeach;?>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Contrato -->
    <div class="modal fade text-dark" id="contratoModal" tabindex="-1" aria-labelledby="contratoModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content">
                <div class="modal-header text-white" id="header-modal-contrato">
                    <h4 class="modal-title" id="contratoModalLabel">Detalhe do contrato</h4>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-12 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Vence em:</div>
                            <div class="fs-3 text-danger fw-bold" id="dias_para_vencer"></div>                            
                        </div>
                    </div>
                    <div class="row mt-3 text-center">
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Número:</div>
                            <div class="fs-3" id="num_contrato"></div>
                        </div>
                        <div class="col-4"></div>
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Processo:</div>
                            <div class="fs-3" id="numero_processo_contrato"></div>
                        </div>
                        <div class="col-12 mt-3 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Objeto:</div>
                            <div class="fs-3" id="objeto_contrato"></div>
                        </div>
                        <div class="col-12 border-bottom my-3"></div>
                    </div>
                    <div class="row text-center">
                        <div class="col-6">
                            <div class="fs-4 opacity-50 fw-bold">Fornecedor:</div>
                            <div class="fs-3" id="fornecedor_display"></div>
                        </div>
                        <div class="col-6">
                            <div class="fs-4 opacity-50 fw-bold">Valor:</div>
                            <div class="fs-3" id="valor_contrato"></div>
                        </div>
                        <div class="col-12 border-bottom my-3"></div>
                    </div>
                    <div class="row text-center">
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Data da assinatura:</div>
                            <div class="fs-3" id="data_assinatura"></div>
                        </div>
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Data da vigência:</div>
                            <div class="fs-3" id="data_inicio"></div>
                        </div>
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Vencimento:</div>
                            <div class="fs-3" id="data_vencimento"></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Licitacao -->
    <div class="modal fade text-dark" id="licitacaoModal" tabindex="-1" aria-labelledby="licitacaoModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content">
                <div class="modal-header text-white" id="header-modal-licitacao">
                    <h4 class="modal-title" id="licitacaoModalLabel">Detalhe da Licitacao</h4>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-4 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Status:</div>
                            <div class="fs-3 text-danger fw-bold" id="status"></div>                            
                        </div>
                        <div class="col-4 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Valor:</div>
                            <div class="fs-3" id="valor_licitacao"></div>
                        </div>
                        <div class="col-4 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Modalidade:</div>
                            <div class="fs-3 text-danger fw-bold" id="modalidade"></div>                            
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-12 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Empresa vencedora:</div>
                            <div class="fs-3 text-success fw-bold" id="empresa_vencedora"></div>                            
                        </div>
                    </div>
                    <div class="row mt-3 text-center mt-3">
                        <div class="col-6">
                            <div class="fs-4 opacity-50 fw-bold">Número:</div>
                            <div class="fs-3" id="num_licitacao"></div>
                        </div>
                        <div class="col-6">
                            <div class="fs-4 opacity-50 fw-bold">Processo:</div>
                            <div class="fs-3" id="numero_processo_licitacao"></div>
                        </div>
                        <div class="col-12 mt-3 text-center">
                            <div class="fs-4 opacity-50 fw-bold">Objeto:</div>
                            <div class="fs-3" id="objeto_licitacao"></div>
                        </div>
                        <div class="col-12 border-bottom my-3"></div>
                    </div>
                    <div class="row text-center">
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Data de abertura:</div>
                            <div class="fs-3" id="data_abertura"></div>
                        </div>
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Data de sessão:</div>
                            <div class="fs-3" id="data_sessao"></div>
                        </div>
                        <div class="col-4">
                            <div class="fs-4 opacity-50 fw-bold">Data de homologação:</div>
                            <div class="fs-3" id="data_homologacao"></div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                </div>
            </div>
        </div>
    </div>

    <script src="<?= BASE_URL ?>/assets/js/jquery-3.7.1.min.js"></script>
    <script src="<?= BASE_URL ?>/assets/js/bootstrap.bundle.min.js"></script>
    <script src="<?= BASE_URL ?>/assets/js/app.js"></script>
    <script>
        atualizarListas();
    </script>

    <script>
        initTvClock();

        // ── Tela cheia automática ──────────────────────────────────────
        // Android TV pode bloquear requestFullscreen sem gesto do usuário.
        // Tenta no carregamento; se falhar, aguarda o primeiro toque/clique.
        function goFullscreen() {
            var el = document.documentElement;
            var fn = el.requestFullscreen ||
                el.webkitRequestFullscreen // Safari / WebView antigo
                ||
                el.mozRequestFullScreen ||
                el.msRequestFullscreen;
            if (fn) fn.call(el);
        }

        // Tentativa 1: direto no load (funciona se o browser permitir)
        window.addEventListener('load', function() {
            try {
                goFullscreen();
            } catch (e) {}
        });

        // Tentativa 2: primeiro gesto do usuário (necessário em muitos Android TV)
        var _fsOnce = false;

        function _fsGesture() {
            if (_fsOnce) return;
            _fsOnce = true;
            try {
                goFullscreen();
            } catch (e) {}
            document.removeEventListener('click', _fsGesture);
            document.removeEventListener('touchstart', _fsGesture);
            document.removeEventListener('keydown', _fsGesture);
        }
        document.addEventListener('click', _fsGesture);
        document.addEventListener('touchstart', _fsGesture);
        document.addEventListener('keydown', _fsGesture);

        // Tentativa 3: volta ao fullscreen se o usuário sair sem querer
        document.addEventListener('fullscreenchange', function() {
            if (!document.fullscreenElement) {
                setTimeout(function() {
                    try {
                        goFullscreen();
                    } catch (e) {}
                }, 2000);
            }
        });
    </script>
</body>

</html>