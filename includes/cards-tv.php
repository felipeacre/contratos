<?php
function tv_card(array $c, string $mod = ''): string
{
    $dias = (int)($c['dias_para_vencer'] ?? 0);
    $diasParaVencer = $dias >= 0 ? $dias . ' dias' : 'VENCIDO';
    $num  = htmlspecialchars($c['numero'] ?? '', ENT_QUOTES);
    $numMod  = str_replace('/', '-', $num) . $mod;
    $valorTotal = $c['valor_total'] ? 'R$ ' . number_format($c['valor_total'], 2, ',', '.') : '—';
    $dataAssinatura = date('d/m/Y', strtotime($c['data_assinatura'] ?? ''));
    $dataInicio = date('d/m/Y', strtotime($c['data_inicio'] ?? ''));
    $dataVencimento = date('d/m/Y', strtotime($c['data_vencimento'] ?? ''));
    $fornRed = htmlspecialchars(
        mb_strtoupper(mb_substr(trim($c['fornecedor_display'] ?? $c['fornecedor_nome'] ?? '—'), 0, 25)),
        ENT_QUOTES
    );
    $forn = $c['fornecedor_display'];

    if ($dias < 0) {
        $bc = 'bc-vencido';
        $bb = 'b-vencido';
        $n = 'VENC.';
        $u = '';
    } elseif ($dias <= 10) {
        $bc = 'bc-urgente';
        $bb = 'b-urgente';
        $n = $dias;
        $u = 'DIAS';
    } elseif ($dias <= 30) {
        $bc = 'bc-critico';
        $bb = 'b-critico';
        $n = $dias;
        $u = 'DIAS';
    } elseif ($dias <= 90) {
        $bc = 'bc-atencao';
        $bb = 'b-atencao';
        $n = $dias;
        $u = 'DIAS';
    } elseif ($dias <= 180) {
        $bc = 'bc-alerta';
        $bb = 'b-alerta';
        $n = $dias;
        $u = 'DIAS';
    } else {
        $bc = 'bc-tranquilo';
        $bb = 'b-tranquilo';
        $n = $dias;
        $u = 'DIAS';
    }

    $unit = $u ? "<span class=\"badge-unit\">{$u}</span>" : '';

    return <<<HTML
<div class="tv-card {$bc}">
    <div class="tv-card-info">
        <div class="tv-card-num" id="num_contrato{$numMod}">{$num}</div>
        <div class="tv-card-forn">{$fornRed}</div>
    </div>
    <div class="tv-card-badge {$bb}"><span class="badge-text">{$n}</span>{$unit}</div>
    <div class="d-none" id="numero_processo_contrato{$numMod}">{$c['numero_processo']}</div>
    <div class="d-none" id="bg_contrato{$numMod}">{$bb}</div>
    <div class="d-none" id="fornecedor_display{$numMod}">{$forn}</div>
    <div class="d-none" id="objeto_contrato{$numMod}">{$c['objeto']}</div>
    <div class="d-none" id="valor_contrato{$numMod}">{$valorTotal}</div>
    <div class="d-none" id="dias_para_vencer{$numMod}">{$diasParaVencer}</div>
    <div class="d-none" id="data_assinatura{$numMod}">{$dataAssinatura}</div>
    <div class="d-none" id="data_inicio{$numMod}">{$dataInicio}</div>
    <div class="d-none" id="data_vencimento{$numMod}">{$dataVencimento}</div>
</div>
HTML;
}

function tv_card_licitacao(array $c, string $mod = ''): string
{
    $status = $c['status'];
    $num  = htmlspecialchars($c['numero_licitacao'] ?? '', ENT_QUOTES);
    $objetoRes = htmlspecialchars(mb_strtoupper(mb_substr(trim($c['objeto_resumido'] ?? '—'), 0, 50)), ENT_QUOTES);
    $numMod  = str_replace('/', '-', $num) . $mod;
    if ($c['valor_estimado']) {
        $c['valor_estimado'] = 'R$ ' . number_format($c['valor_estimado'], 2, ',', '.');
    }
    $dataAbertura = date('d/m/Y', strtotime($c['data_abertura'] ?? ''));
    $dataSessao = date('d/m/Y', strtotime($c['data_sessao'] ?? ''));
    $dataHomologacao = date('d/m/Y', strtotime($c['data_homologacao'] ?? ''));

    if ($status == 'fracassada') {
        $bc = 'bc-vencido';
        $bb = 'b-vencido';
        $n = ['text-white text-opacity-50', 'text-white', 'Abertura', 'vencido'];
        $u = date('d/m/Y', strtotime($c['data_abertura'] ?? ''));
        $v = $c['valor_estimado'];
        $empresa = '';
    } elseif ($status == 'deserta') {
        $bc = 'bc-atencao';
        $bb = 'b-atencao';
        $n = ['text-dark text-opacity-50', 'text-dark', 'Abertura', 'atencao'];
        $u = date('d/m/Y', strtotime($c['data_abertura'] ?? ''));
        $v = $c['valor_estimado'];
        $empresa = '';
    } elseif ($status == 'em_andamento') {
        $bc = 'bc-alerta';
        $bb = 'b-alerta';
        $n = ['text-dark text-opacity-50', 'text-dark', 'Abertura', 'alerta'];
        $u = date('d/m/Y', strtotime($c['data_abertura'] ?? ''));
        $v = $c['valor_estimado'];
        $empresa = '';
    } elseif ($status == 'homologada') {
        $bc = 'bc-tranquilo';
        $bb = 'b-tranquilo';
        $n = ['tv-card-num', 'text-white', 'Homologação', 'tranquilo'];
        $u = date('d/m/Y', strtotime($c['data_homologacao'] ?? ''));
        $v = $c['valor_estimado'];
        $empresa = '<div class="tv-card-empresa p-2 ' . $bb . '"><div class="' . $n[0] . ' fw-bold fs-5">Empresa vencedora:</div>' . $c['empresa_vencedora'] . '</div>';
    } else {
        $bc = 'bc-tranquilo';
        $bb = 'b-tranquilo';
        $n = '';
        $u = 'status';
        $empresa = '';
    }

    return <<<HTML
<div class="tv-card-licitacao {$bc}">
    {$empresa}
    <div class="tv-card-badge-licitacao p-3">
        <div class="">
            <span class="tv-card-num">Licitação:</span> <span id="num_licitacao{$numMod}">{$num}</span>
        </div>
        <div class="">
            <span class="tv-card-num">Processo:</span> <span id="numero_processo_licitacao{$numMod}">{$c['numero_processo']}</span>
        </div>
        <div class="tv-card-obj text-center">
            <div class="tv-card-num fw-bold fs-5">Objeto:</div>
            <div class="{$n[3]}">{$objetoRes}</div>            
        </div>
    </div>
    <div class="tv-card-text-bottom {$bb} p-2">
        <span class="badge-unit text-center">
            <div class="{$n[0]} fw-bold fs-5">{$n[2]}:</div>
            <div class="{$n[1]} fs-3">{$u}</div>
        </span>
        <span class="badge-unit text-center">
            <div class="{$n[0]} fw-bold fs-5">Valor:</div>
            <div class="{$n[1]} fs-3" id="valor_licitacao{$numMod}">{$v}</div>
        </span>
        <div class="d-none" id="objeto_licitacao{$numMod}">{$c['objeto']}</div>
        <div class="d-none" id="modalidade{$numMod}">{$c['modalidade']}</div>
        <div class="d-none" id="bg_licitacao{$numMod}">{$bb}</div>
        <div class="d-none" id="empresa_vencedora{$numMod}">{$c['empresa_vencedora']}</div>
        <div class="d-none" id="status{$numMod}">{$c['status']}</div>
        <div class="d-none" id="valor_estimado{$numMod}">{$c['valor_estimado']}</div>
        <div class="d-none" id="data_abertura{$numMod}">{$dataAbertura}</div>
        <div class="d-none" id="data_prevista_conclusao{$numMod}">{$c['data_prevista_conclusao']}</div>
        <div class="d-none" id="data_sessao{$numMod}">{$dataSessao}</div>
        <div class="d-none" id="data_homologacao{$numMod}">{$dataHomologacao}</div>
    </div>
</div>
HTML;
}
