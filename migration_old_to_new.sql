-- =============================================================
-- MIGRATION: contratos_idaf_old → contratos_idaf_new
-- Gerado em: 2026-08-20
-- Aplique no banco do servidor Proxmox (contratos_idaf)
-- =============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 1. Adiciona coluna `active` na tabela `contratos`
-- -------------------------------------------------------------
SET @col1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contratos' AND COLUMN_NAME = 'active');
SET @sql1 = IF(@col1 = 0,
  'ALTER TABLE `contratos` ADD COLUMN `active` int NOT NULL DEFAULT 1 AFTER `origem`',
  'SELECT "coluna active já existe, ignorando"');
PREPARE stmt1 FROM @sql1; EXECUTE stmt1; DEALLOCATE PREPARE stmt1;

-- -------------------------------------------------------------
-- 2. Adiciona novas colunas na tabela `licitacoes`
-- -------------------------------------------------------------
SET @col2 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'licitacoes' AND COLUMN_NAME = 'objeto_resumido');
SET @sql2 = IF(@col2 = 0,
  'ALTER TABLE `licitacoes` ADD COLUMN `objeto_resumido` text NOT NULL AFTER `objeto`',
  'SELECT "coluna objeto_resumido já existe, ignorando"');
PREPARE stmt2 FROM @sql2; EXECUTE stmt2; DEALLOCATE PREPARE stmt2;

SET @col3 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'licitacoes' AND COLUMN_NAME = 'data_sessao');
SET @sql3 = IF(@col3 = 0,
  'ALTER TABLE `licitacoes` ADD COLUMN `data_sessao` date DEFAULT NULL AFTER `data_prevista_conclusao`',
  'SELECT "coluna data_sessao já existe, ignorando"');
PREPARE stmt3 FROM @sql3; EXECUTE stmt3; DEALLOCATE PREPARE stmt3;

SET @col4 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'licitacoes' AND COLUMN_NAME = 'empresa_vencedora');
SET @sql4 = IF(@col4 = 0,
  'ALTER TABLE `licitacoes` ADD COLUMN `empresa_vencedora` varchar(200) DEFAULT NULL AFTER `responsavel`',
  'SELECT "coluna empresa_vencedora já existe, ignorando"');
PREPARE stmt4 FROM @sql4; EXECUTE stmt4; DEALLOCATE PREPARE stmt4;

-- -------------------------------------------------------------
-- 3. Cria tabela `controles` (configurações da TV)
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `controles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `modal` varchar(20) DEFAULT NULL,
  `velocidade_contrato_tranquilo` int NOT NULL DEFAULT '30',
  `velocidade_contrato_atencao` int NOT NULL DEFAULT '30',
  `velocidade_contrato_critico` int NOT NULL DEFAULT '30',
  `velocidade_licitacao_deserta` int NOT NULL DEFAULT '30',
  `velocidade_licitacao_andamento` int NOT NULL DEFAULT '30',
  `velocidade_licitacao_homologada` int NOT NULL DEFAULT '30',
  `transicao` int NOT NULL DEFAULT '60',
  `user_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- 4. Atualiza vw_contratos (inclui coluna `active`)
-- -------------------------------------------------------------
DROP VIEW IF EXISTS `vw_contratos`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_contratos` AS
SELECT
  `c`.`id`,
  `c`.`numero`,
  `c`.`numero_processo`,
  `c`.`licitacao_id`,
  `c`.`fornecedor_id`,
  `c`.`fornecedor_nome`,
  `c`.`fornecedor_cnpj`,
  `c`.`objeto`,
  `c`.`modalidade`,
  `c`.`valor_total`,
  `c`.`saldo_atual`,
  `c`.`data_assinatura`,
  `c`.`data_inicio`,
  `c`.`data_vencimento`,
  `c`.`status_manual`,
  `c`.`gestor_nome`,
  `c`.`gestor_matricula`,
  `c`.`fiscal_nome`,
  `c`.`fiscal_matricula`,
  `c`.`dotacao_orcamentaria`,
  `c`.`observacoes`,
  `c`.`origem`,
  `c`.`active`,
  `c`.`created_at`,
  `c`.`updated_at`,
  (TO_DAYS(`c`.`data_vencimento`) - TO_DAYS(CURDATE())) AS `dias_para_vencer`,
  (CASE
    WHEN (`c`.`status_manual` IS NOT NULL) THEN `c`.`status_manual`
    WHEN (`c`.`data_vencimento` < CURDATE()) THEN 'vencido'
    WHEN ((TO_DAYS(`c`.`data_vencimento`) - TO_DAYS(CURDATE())) <= 30) THEN 'critico'
    WHEN ((TO_DAYS(`c`.`data_vencimento`) - TO_DAYS(CURDATE())) <= 90) THEN 'atencao'
    WHEN ((TO_DAYS(`c`.`data_vencimento`) - TO_DAYS(CURDATE())) <= 180) THEN 'alerta'
    ELSE 'regular'
  END) AS `status_vencimento`,
  COALESCE(`f`.`razao_social`, `c`.`fornecedor_nome`) AS `fornecedor_display`,
  COALESCE(`f`.`cnpj`, `c`.`fornecedor_cnpj`) AS `cnpj_display`,
  (`c`.`valor_total` - `c`.`saldo_atual`) AS `valor_executado`,
  ROUND((((`c`.`valor_total` - `c`.`saldo_atual`) / `c`.`valor_total`) * 100), 1) AS `percentual_executado`
FROM (`contratos` `c`
  LEFT JOIN `fornecedores` `f` ON (`f`.`id` = `c`.`fornecedor_id`));

-- -------------------------------------------------------------
-- 5. Atualiza vw_dashboard_resumo (nova lógica com _hid)
-- -------------------------------------------------------------
DROP VIEW IF EXISTS `vw_dashboard_resumo`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_dashboard_resumo` AS
SELECT
  COUNT(0) AS `total_contratos`,
  SUM(CASE WHEN (`contratos`.`data_vencimento` < CURDATE()) AND (`contratos`.`status_manual` IS NULL) THEN 1 ELSE 0 END) AS `vencido`,
  SUM(CASE WHEN (`contratos`.`data_vencimento` < CURDATE()) AND (`contratos`.`status_manual` IS NULL) AND (`contratos`.`active` = 0) THEN 1 ELSE 0 END) AS `vencido_hid`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) BETWEEN 0 AND 30) AND (`contratos`.`status_manual` IS NULL) THEN 1 ELSE 0 END) AS `critico`,
  SUM(0 <> (CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) BETWEEN 0 AND 30) AND (`contratos`.`status_manual` IS NULL) AND (`contratos`.`active` = 0) THEN 1 ELSE 0 END)) AS `critico_hid`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) BETWEEN 31 AND 90) AND (`contratos`.`status_manual` IS NULL) THEN 1 ELSE 0 END) AS `atencao`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) BETWEEN 31 AND 90) AND (`contratos`.`status_manual` IS NULL) AND (`contratos`.`active` = 0) THEN 1 ELSE 0 END) AS `atencao_hid`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) BETWEEN 91 AND 180) AND (`contratos`.`status_manual` IS NULL) THEN 1 ELSE 0 END) AS `alerta`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) BETWEEN 91 AND 180) AND (`contratos`.`status_manual` IS NULL) AND (`contratos`.`active` = 0) THEN 1 ELSE 0 END) AS `alerta_hid`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) > 180) AND (`contratos`.`status_manual` IS NULL) THEN 1 ELSE 0 END) AS `regular`,
  SUM(CASE WHEN ((TO_DAYS(`contratos`.`data_vencimento`) - TO_DAYS(CURDATE())) > 180) AND (`contratos`.`status_manual` IS NULL) AND (`contratos`.`active` = 0) THEN 1 ELSE 0 END) AS `regular_hid`,
  SUM(`contratos`.`valor_total`) AS `valor_total_carteira`,
  SUM(`contratos`.`saldo_atual`) AS `saldo_total_carteira`
FROM `contratos`
WHERE (`contratos`.`status_manual` NOT IN ('encerrado', 'rescindido')) OR (`contratos`.`status_manual` IS NULL);

-- -------------------------------------------------------------
-- 6. Cria vw_resumo_licitacao (view nova)
-- -------------------------------------------------------------
DROP VIEW IF EXISTS `vw_resumo_licitacao`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_resumo_licitacao` AS
SELECT
  COUNT(0) AS `total_licitacoes`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'em_andamento') THEN 1 ELSE 0 END) AS `em_andamento`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'aguardando_homologacao') THEN 1 ELSE 0 END) AS `aguardando_homologacao`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'homologada') THEN 1 ELSE 0 END) AS `homologada`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'deserta') THEN 1 ELSE 0 END) AS `deserta`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'fracassada') THEN 1 ELSE 0 END) AS `fracassada`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'cancelada') THEN 1 ELSE 0 END) AS `cancelada`,
  SUM(CASE WHEN (`licitacoes`.`status` = 'suspensa') THEN 1 ELSE 0 END) AS `suspensa`
FROM `licitacoes`;

SET FOREIGN_KEY_CHECKS = 1;
