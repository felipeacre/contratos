<?php
define('LIST_CONTRATOS', "SELECT numero, numero_processo, objeto, valor_total, data_assinatura, data_inicio, data_vencimento, fornecedor_display, fornecedor_nome, dias_para_vencer, status_vencimento
    FROM vw_contratos
    WHERE ((status_manual IS NULL OR status_manual = 'ativo') AND active = 1)
      AND status_vencimento IN ('vencido','critico','atencao','alerta','regular')
    ORDER BY dias_para_vencer ASC");

define('LIST_LICITAÇOES', "SELECT * FROM licitacoes ORDER BY data_homologacao, data_abertura");
define('STATUS_LICITACAO', [
  'em_andamento' => 'Em andamento',
  'aguardando_homologacao' => 'Aguardando homologação',
  'homologada' => 'Homologada',
  'deserta' => 'Deserta',
  'fracassada' => 'Fracassada',
  'cancelada' => 'Cancelada',
  'suspensa' => 'Suspensa',
]);
define('MODALIDADE_LICITACAO', [
  'pregao_eletronico' => 'Pregão eletrônico',
  'pregao_presencial' => 'Pregão presencial',
  'concorrencia' => 'Concorrência',
  'tomada_de_precos' => 'Tomada de preços',
  'convite' => 'Convite',
  'dispensa' => 'Dispensa',
  'inexigibilidade' => 'Inexigibilidade',
  'chamamento_publico' => 'Chamamento público',
]);