<?php
// ============================================================
// includes/helpers.php
// ============================================================

function moeda(float $valor): string {
    return 'R$ ' . number_format($valor, 2, ',', '.');
}

function data_br(?string $data): string {
    if (!$data) return '—';
    return date('d/m/Y', strtotime($data));
}

function dias_para_vencer(string $data_vencimento): int {
    $hoje  = new DateTime('today');
    $vence = new DateTime($data_vencimento);
    return (int) $hoje->diff($vence)->days * ($vence >= $hoje ? 1 : -1);
}

function badge_status(string $status): string {
    $map = [
        'vencido'  => ['danger',  'Vencido'],
        'critico'  => ['warning', 'Crítico'],
        'atencao'  => ['atencao', 'Atenção'], // cor custom
        'alerta'   => ['info',    'Alerta'],
        'regular'  => ['success', 'Regular'],
        'ativo'    => ['success', 'Ativo'],
        'encerrado'=> ['secondary','Encerrado'],
        'suspenso' => ['warning', 'Suspenso'],
        'rescindido'=> ['danger', 'Rescindido'],
    ];
    $s = $map[$status] ?? ['secondary', ucfirst($status)];
    return "<span class=\"badge bg-{$s[0]}\">{$s[1]}</span>";
}

function badge_licitacao(string $status): string {
    $map = [
        'em_andamento'          => ['primary',   'Em Andamento'],
        'aguardando_homologacao'=> ['warning',   'Aguard. Homologação'],
        'homologada'            => ['success',   'Homologada'],
        'deserta'               => ['secondary', 'Deserta'],
        'fracassada'            => ['danger',    'Fracassada'],
        'cancelada'             => ['danger',    'Cancelada'],
        'suspensa'              => ['warning',   'Suspensa'],
    ];
    $s = $map[$status] ?? ['secondary', ucfirst($status)];
    return "<span class=\"badge bg-{$s[0]}\">{$s[1]}</span>";
}

function modalidade_label(string $m): string {
    $map = [
        'pregao_eletronico'  => 'Pregão Eletrônico',
        'pregao_presencial'  => 'Pregão Presencial',
        'concorrencia'       => 'Concorrência',
        'tomada_de_precos'   => 'Tomada de Preços',
        'convite'            => 'Convite',
        'dispensa'           => 'Dispensa',
        'inexigibilidade'    => 'Inexigibilidade',
        'chamamento_publico' => 'Chamamento Público',
    ];
    return $map[$m] ?? $m;
}

function sanitize(string $str): string {
    return htmlspecialchars(trim($str), ENT_QUOTES, 'UTF-8');
}

function redirect(string $url): void {
    header('Location: ' . $url);
    exit;
}

function flash(string $tipo, string $msg): void {
    $_SESSION['flash'] = ['tipo' => $tipo, 'msg' => $msg];
}

function get_flash(): ?array {
    $f = $_SESSION['flash'] ?? null;
    unset($_SESSION['flash']);
    return $f;
}

function json_response(mixed $data, int $code = 200): void {
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function cnpj_format(string $cnpj): string {
    $cnpj = preg_replace('/\D/', '', $cnpj);
    if (strlen($cnpj) !== 14) return $cnpj;
    return substr($cnpj,0,2).'.'.substr($cnpj,2,3).'.'.substr($cnpj,5,3).'/'.substr($cnpj,8,4).'-'.substr($cnpj,12,2);
}
