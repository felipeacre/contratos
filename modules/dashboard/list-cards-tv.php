<?php
require_once __DIR__ . '/../../includes/bootstrap.php';

$db = Database::get();

$contratos = $db->query(LIST_CONTRATOS)->fetchAll();
$licitacoes = $db->query(LIST_LICITAÇOES)->fetchAll();

$tv_critico  = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] <= 30));
$tv_atencao   = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] > 30 && (int)$c['dias_para_vencer'] <= 90));
$tv_tranquilo = array_values(array_filter($contratos, fn($c) => (int)$c['dias_para_vencer'] > 90));

$tv_fracassadas_desertas  = array_values(array_filter($licitacoes, fn($c) => $c['status'] == 'fracassada' || $c['status'] == 'deserta'));
$tv_homologadas   = array_values(array_filter($licitacoes, fn($c) => $c['status'] == 'homologada'));
$tv_em_andamento = array_values(array_filter($licitacoes, fn($c) => $c['status'] == 'em_andamento'));

$tipoContrato = [
    'critico' => $tv_critico,
    'atencao' => $tv_atencao,
    'tranquilo' => $tv_tranquilo,
];

$tipoLicitacao = [
    'deserta' => $tv_fracassadas_desertas,
    'homologada' => $tv_homologadas,
    'andamento' => $tv_em_andamento,
];

if(isset($_GET['contrato'])){
    foreach ($tipoContrato[$_GET['contrato']] as $c):
        echo tv_card($c);
    endforeach;

    foreach ($tipoContrato[$_GET['contrato']] as $c):
        echo tv_card($c);
    endforeach;
} elseif(isset($_GET['licitacao'])){
    foreach ($tipoLicitacao[$_GET['licitacao']] as $c):
        echo tv_card_licitacao($c);
    endforeach;
    if(count($tipoLicitacao[$_GET['licitacao']]) >= 3):
        foreach ($tipoLicitacao[$_GET['licitacao']] as $c):
            echo tv_card_licitacao($c);
        endforeach;
    endif;
}
