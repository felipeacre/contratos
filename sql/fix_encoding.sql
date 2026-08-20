-- ============================================================
-- fix_encoding.sql
--
-- Repara a acentuacao duplo-codificada (c -> A§) reescrevendo os
-- registros a partir da fonte limpa (migration_data.sql).
--
-- Usa INSERT ... ON DUPLICATE KEY UPDATE em vez de REPLACE INTO:
-- REPLACE faz DELETE+INSERT, e `aditivos.contrato_id` tem
-- ON DELETE CASCADE -- apagaria todos os aditivos.
--
-- IMPORTANTE: rodar com --default-character-set=utf8mb4.
-- Foi exatamente a falta disso que causou o problema.
-- ============================================================

SET NAMES utf8mb4;

-- ---------- contratos ----------
INSERT INTO `contratos` (`id`, `numero`, `numero_processo`, `licitacao_id`, `fornecedor_id`, `fornecedor_nome`, `fornecedor_cnpj`, `objeto`, `modalidade`, `valor_total`, `saldo_atual`, `data_assinatura`, `data_inicio`, `data_vencimento`, `status_manual`, `gestor_nome`, `gestor_matricula`, `fiscal_nome`, `fiscal_matricula`, `dotacao_orcamentaria`, `observacoes`, `origem`, `active`, `created_at`, `updated_at`) VALUES
(1, '16/2024', '', NULL, NULL, 'ATIVA CONSULTORIA ORGANIZACIONAL LTDA', '', 'SERVIÇO TERCERIZADO APOIO OPERACIONAL', NULL, 0.00, 0.00, '2026-02-13', '2026-02-13', '2026-06-01', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:51'),
(2, '07/2025', '', NULL, NULL, 'A.A.C ROCHA COMERCIO & SERVIÇO', '', 'Contratação de pessoa jurídica para o fornecimento de materiais de consumo (Água Mineral e Galão vazio, Gás de cozinha, botija de gás vazia ), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 1111.00, 0.00, '2026-02-13', '2026-02-13', '2026-04-02', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:45'),
(3, '19/2024', '21.256.222/001-22', NULL, NULL, 'TEC NEWS LTDA', '', 'SERVIÇO TERCERIZADO LIMPEZA', NULL, 123456.25, 0.00, '2026-02-13', '2026-02-13', '2026-04-02', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:46'),
(4, '08/2025', NULL, NULL, NULL, 'CONCORDIA S.A', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática, conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:52'),
(5, '09/2025', '', NULL, NULL, 'VALOR GESTÃO E SERVIÇOS TECNOLOGICOS', '', 'Contratação de Empresa para Prestação de Serviço de Administração e Gerenciamento Informatizado para Manutenção Preventiva e Corretiva de Veículos com Fornecimento de Peças e Acessórios.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-05-09', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:47'),
(6, '10/2025', NULL, NULL, NULL, 'M.A COMERCIO E SERVIÇOS', '', 'Contratação de pessoa jurídica para o fornecimento de materiais de consumo (KIT REGISTRO DE GÁS DE COZINHA REGULADOR, MANGUEIRA E ABRAÇADEIRA, CERTIFICADAS PELO INMETRO)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:54'),
(7, '11/2025', '', NULL, NULL, 'LICITAINFO LTDA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (Notebook), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-05-15', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:48'),
(8, '12/2025', NULL, NULL, NULL, 'SCORPION INFORMÁTICA LTDA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (HD STORAGE 16TB), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:15'),
(9, '13/2025', NULL, NULL, NULL, 'LDNTECH AUTOMAÇÃO COMERCIAL E TECNOLOGIA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (LEITOR BIOMÉTRICO), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:17'),
(10, '15/2025', '', NULL, NULL, 'POWER TECH SOLUCOES INDUSTRIAIS LTDA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (Bateria Nobreak), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-14', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:05'),
(11, '16/2025', NULL, NULL, NULL, 'FORTALEZA COMÉRCIO E SERVIÇOS LTDA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (Pendrive 64GB), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-05-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:50'),
(12, '047/2022', '', NULL, NULL, 'JWC MULTISERVIOS', '', 'SERVIÇOS OPERACIONAIS', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-05-28', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:56'),
(13, '04/2026', NULL, NULL, NULL, 'ESAFI - ESCOLA DE ADMINISTRACAO E TREINAMENTO LTDA', '', 'Curso Presencial Completo sobre Licitações e Contratação de Obras e Serviços de Engenharia', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:53'),
(14, '28/2024', NULL, NULL, NULL, 'PRB SERVIÇOS, COMÉRCIO E REPRESENTAÇÕES LTDA', '', 'Empresa de prestação de Serviços Chaveiros, Carimbos e Crachás', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:54'),
(15, '29/2024', '', NULL, NULL, 'GRUPO E IMPORTACAO E EXPORTACAO LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-05-17', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:06:49'),
(16, '30/2024', NULL, NULL, NULL, 'J. & J D\'PAULA E CIA LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:28'),
(17, '31/2024', NULL, NULL, NULL, 'G. S. SILVEIRA LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:26'),
(18, '32/2024', NULL, NULL, NULL, 'H.J.RODRIGUES FILHO', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:24'),
(19, '34/2024', NULL, NULL, NULL, 'COMERCIAL KALEDO LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:22'),
(20, '21/2025', NULL, NULL, NULL, 'KKD BATISTA LTDA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos (Geladeira), para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:20'),
(21, '22/2025', NULL, NULL, NULL, 'WILLIAN DA SILVA DE SOUZA', '', 'Contratação de pessoa jurídica para o Fornecimento de Equipamentos e Serviço de Conexão de Internet via Satélite, conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-06-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:18'),
(22, '23/2025', NULL, NULL, NULL, 'JEFF COMERCIO E SERVICOS LTDA', '', 'Aquisição de Gêneros Alimentícios (pó de café e açúcar, sachê de chá, Biscoito doce e biscoito salgado.), Conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:11'),
(23, '023/2021', NULL, NULL, NULL, 'INSTITUTO EVALDO LODI', '', 'ESTAGIÁRIO', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:09'),
(24, '24/2025', NULL, NULL, NULL, 'E.L.S VIEIRA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos (Lanterna Tática Militar), para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:07'),
(25, '26/2025', NULL, NULL, NULL, 'Ambi-Clean Limpeza e Higienização LTD', '', 'O presente contrato tem por objeto a contratação de empresa de engenharia para a execução do projeto, fornecimento e instalação de um Sistema de Energia Solar Fotovoltaico, a ser implementado na sede do Instituto de Defesa Agropecuária e Florestal do Acre - IDAF/AC', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:03'),
(26, '27/2025', NULL, NULL, NULL, 'MB IMPORTAÇÃO LTDA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (LICENÇA MICROSOFT OFFICE), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:40'),
(27, '040/2025', NULL, NULL, NULL, 'K.K.D BATISTA LTDA', '', 'Aquisição de Equipamentos de Informática (TECLADO USB)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-07-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:44'),
(28, '28/2025', NULL, NULL, NULL, 'BT COMÉRCIO INTELIGENTE LTDA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos ( Ar Condicionado de 18 Mil Btus)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-08-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:50'),
(29, '30/2025', NULL, NULL, NULL, 'A.WAGNER L. DA SILVA LTDA', '', 'Contratação de Pessoa Jurídica para Prestação de Serviços de Instalação, Desinstalação, Limpeza, Manutenção e Reparo de aparelho de Ar Condicionado com Fornecimento de Peças, Gás de Reposição e Componentes para Instalação', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-08-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-07-21 09:07:34'),
(30, '31/2025', NULL, NULL, NULL, 'AGROSAFETY MONITORAMENTO AGRÍCOLA LTDA', '', 'Serviço de Envio e Análise Multirresíduos de Ingredientes ativos de Agrotóxicos em Produtos Agrícolas', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-08-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(31, '32/2025', NULL, NULL, NULL, 'S V NOGUEIRA LTDA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos ( Aparelho de Ar condicionado 12.000 BTU)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-08-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(32, '39/2025', NULL, NULL, NULL, 'PAPELARIA MUNDO IMPORTAÇÃO E EXPORTAÇÃO LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-09-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(33, '34/2025', NULL, NULL, NULL, 'CÉLIO PEREIRA LTDA', '', 'COFFE BREAK', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-09-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(34, '35/2025', NULL, NULL, NULL, 'COMFORT RBO LTDA', '', 'Aquisição de Cortinas e Persianas', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-09-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(35, '36/2025', NULL, NULL, NULL, 'A. L. B. LUZ', '', 'Meios de Conservação de Amostras de Suspeitas de Doenças Vesiculares', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-09-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(36, '37/2025', NULL, NULL, NULL, 'SISTEL SISTEMA TELECOMUNICAÇÕES', '', 'manutenção preventiva e corretiva de rede lógica', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(37, '067/2023', NULL, NULL, NULL, 'ANSELMO RIBEIRO DO NASCIMENTO LTDA', '', 'vigilância eletrônica', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(38, '042/2025', NULL, NULL, NULL, 'J S CORDEIRO LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(39, '043/2025', NULL, NULL, NULL, 'EASYTECH SECURITY COMERCIO DE ELETRÔNICO LTDA', '', 'Aquisição de Equipamentos de Informática (KEYSTONE CAT 6 E KIT TECLADO E MOUSE SEM FIO)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(40, '045/2025', NULL, NULL, NULL, 'C. F. MIRANDA LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(41, '046/2025', NULL, NULL, NULL, 'BEEVOLT ENERGY LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(42, '047/2025', NULL, NULL, NULL, 'ECOPOWER EFICIENCIA ENERGETICA LTDA.', '', 'contratação de empresa de engenharia para a execução do projeto, fornecimento e instalação de um Sistema de Energia Solar Fotovoltaico', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-10-30', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(43, '073/2022', NULL, NULL, NULL, 'BIOLOGISTICA', '', 'SERVIÇOS DE TRANSPORTE DE AMOSTRA', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:19'),
(44, '051/2025', NULL, NULL, NULL, 'LAPTOP COMÉRCIO DE PRODUTOS DE INFORMÁTICA LTDA', '', 'Aquisição de Equipamentos de Informática (CABO DE REDE CAT 6)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:56'),
(45, '053/2025', NULL, NULL, NULL, 'MARIA V.C DA SILVA LTDA', '', 'Contratação de pessoa jurídica para o Fornecimento de Marmitex', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:52'),
(46, '055/2025', NULL, NULL, NULL, 'VILSON DA SILVA OLIVEIRA LTDA', '', 'aquisição de Água Mineral Natural, acondicionada em embalagem de 20 litros, com o intuito de atender as necessidades do Instituo de Defesa Agropecuária e Florestal - IDAF na regional do vale do Juruá e tarauacá/envira', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:46'),
(47, '056/2025', NULL, NULL, NULL, 'DISTRIBUIDORA DE GÁS CENTRAL LTDA', '', 'aquisição de Carga de gás liquefeito de Petróleo - GLP (P13), em regime de troca de botija (vazio pelo cheio)', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:42'),
(48, '043/2021', NULL, NULL, NULL, 'LINK CARD', '', 'INFORMATIZAÇÃO DE ABASTECIMENTO', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:38'),
(49, '057/2025', NULL, NULL, NULL, 'HPE AUTOMOTORES DO BRASIL LTDA', '', 'Aquisição veículos Tipo Pick-Up nov', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:50:24'),
(50, '60/2025', '0052.013539.00126/2025-81', NULL, NULL, 'PAPELARIA MUNDO IMPORTAÇÃO E EXPORTAÇÃO LTDA', '', 'Aquisição de materiais de limpeza, copa e descartáveis', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-17', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:51:56'),
(51, '63/2025', NULL, NULL, NULL, 'DL RAMOS', '', 'Aquisição de materiais de limpeza, copa e descartáveis,', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2026-12-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:49:55'),
(52, '02/2026', NULL, NULL, NULL, 'MS EMPREENDIMENTOS E REPRESENTAÇÕES LTDA', '', 'Empresa de Engenharia Para Execução de Serviços de Reforma Estrutural, Instalações Elétricas e Hidráulicas na sede do Instituto de Defesa Agropecuária e Florestal do Estado do Acre – IDAF,', NULL, 1524.66, 0.00, '2026-04-13', '2026-04-13', '2027-01-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-20 12:00:28'),
(53, '01/2025', NULL, NULL, NULL, 'ATIVA CONSULTORIA ORGANIZACIONAL LTDA', '', 'O presente Contrato tem por objeto a contratação de empresa para prestação de serviço terceirizado e continuado de apoio operacional e administrativo, com disponibilização de mão de obra em regime de dedicação exclusiva, a serem executados no âmbito do Instituto de Defesa Agropecuária e Florestal em Rio Branco', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-02-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(54, '089/2023', NULL, NULL, NULL, 'KOA TURISMO E INTERCÂMBIO LTDA', '', 'passagem aérea', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-02-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(55, '10/2024', NULL, NULL, NULL, 'DUX COMERCIO REPRESENTAÇÕES IMPORTAÇÃO E EXPORTAÇÃO EIREL', '', 'objeto a contratação de empresa especializada no serviço de impressão (outsourcing de impressão), na modalidade franquia mínima mensal de páginas e valor fixo de páginas excedentes pelo prazo de 48 (quarenta e oito) meses', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-02-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(56, '11/2024', NULL, NULL, NULL, 'CRUZEIRO MOTORS', '', 'objeto empresa especializada na prestação de serviços de manutenção preventiva e corretiva de motosserras, roçadeiras manuais, motopodas, lavadoras de alta pressão, pulverizadores incluindo fornecimento de materiais, peças novas e mão de obra Na Na Regional Purus, Juruá e Tarauacá - Envira..', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-02-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:51:41'),
(57, '01/2026', NULL, NULL, NULL, 'MOVESA MOVEIS PLANEJADOS LTDA', '', 'Contração de Pessoa jurídica Para Fornecimento e Instalações de Moveis Planejados Por m²,', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-02-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:51:23'),
(58, '13/2024', NULL, NULL, NULL, 'J.V NOGUEIRA IMPORTAÇÃO E EXPORTAÇÃO - ME', '', 'serviços de manutenção corretiva e preventiva de bens móveis: mesas, cadeiras e armarios, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF em suas unidades da capital e interior do estado.', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-02-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(59, '06/2023', NULL, NULL, NULL, 'NP TECNOLOGIA E GESTAO DE DADOS LTDA / BANCO DE PREÇO', '', 'BANCO DE PREÇOS', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2027-03-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-04-13 08:50:20'),
(60, '04/2025', NULL, NULL, NULL, 'AZ COMÉRCIO, SERV. E REP. IMP. EXP. LTDA', '', 'Contratação de empresa de engenharia para prestação de serviços comuns de engenharia de forma continuada, por demanda, para execução de manutenção predial e reformas de pouca relevância material, serviços de adequação, adaptação, reparação ou revitalização em prédio e logradouros públicos', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2030-02-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', 1, '2026-04-13 08:50:20', '2026-05-22 12:51:17'),
(61, '18/2025', '', NULL, NULL, 'RADIONET LTDA', '', 'Contratação de serviços de rastreamento de veículos via GPRS, incluindo sistema l-boton, compreendendo a instalação e desinstalação, em comodato, de módulos rastreadores e a disponibilização de software de gerenciamento com acesso via Web, com a finalidade de controle de toda a frota de veículos do Instituto de Defesa Agropecuária e Florestal do Estado do Acre - unidades da Capital e as ULDAG\'s do interior do Estado', NULL, 0.00, 0.00, '2026-04-13', '2026-04-13', '2029-05-26', NULL, '', '', '', '', '', '', 'importacao', 1, '2026-04-13 08:50:20', '2026-04-28 08:38:44'),
(62, '75/2026', '0052.013539.00666/2026-66', NULL, NULL, 'GOVERNO DO ESTADO DO ACRE', '', 'Teste do pregão eletrônico a mostrar na TV.', 'pregao_eletronico', 12550.33, 1111.33, '2026-05-12', '2026-10-11', '2026-12-12', NULL, '', '', '', '', '', '', 'manual', 1, '2026-05-22 08:13:26', '2026-05-22 12:50:34'),
(63, '2525/2025', '0052.013539.00126/2027-81', 3, NULL, 'JAVA LTDA', '', 'Testando o objeto', 'pregao_eletronico', 0.00, 0.00, '2022-12-12', '2025-02-22', '2026-08-17', NULL, '', '', '', '', '', '', 'manual', 1, '2026-07-21 09:10:08', '2026-07-21 09:10:08')
ON DUPLICATE KEY UPDATE
    `numero` = VALUES(`numero`),
    `numero_processo` = VALUES(`numero_processo`),
    `licitacao_id` = VALUES(`licitacao_id`),
    `fornecedor_id` = VALUES(`fornecedor_id`),
    `fornecedor_nome` = VALUES(`fornecedor_nome`),
    `fornecedor_cnpj` = VALUES(`fornecedor_cnpj`),
    `objeto` = VALUES(`objeto`),
    `modalidade` = VALUES(`modalidade`),
    `valor_total` = VALUES(`valor_total`),
    `saldo_atual` = VALUES(`saldo_atual`),
    `data_assinatura` = VALUES(`data_assinatura`),
    `data_inicio` = VALUES(`data_inicio`),
    `data_vencimento` = VALUES(`data_vencimento`),
    `status_manual` = VALUES(`status_manual`),
    `gestor_nome` = VALUES(`gestor_nome`),
    `gestor_matricula` = VALUES(`gestor_matricula`),
    `fiscal_nome` = VALUES(`fiscal_nome`),
    `fiscal_matricula` = VALUES(`fiscal_matricula`),
    `dotacao_orcamentaria` = VALUES(`dotacao_orcamentaria`),
    `observacoes` = VALUES(`observacoes`),
    `origem` = VALUES(`origem`),
    `active` = VALUES(`active`),
    `created_at` = VALUES(`created_at`),
    `updated_at` = VALUES(`updated_at`);

-- ---------- licitacoes ----------
INSERT INTO `licitacoes` (`id`, `numero_processo`, `numero_licitacao`, `objeto`, `objeto_resumido`, `modalidade`, `status`, `valor_estimado`, `data_abertura`, `data_prevista_conclusao`, `data_sessao`, `data_homologacao`, `responsavel`, `empresa_vencedora`, `link_portal`, `observacoes`, `origem`, `created_at`, `updated_at`) VALUES
(1, '0052.013539.00126/2025-81', '94/2026', 'Tecidos e copos', 'Tecidos e resumo', 'tomada_de_precos', 'fracassada', 13333.15, '2026-05-14', NULL, '2025-11-11', NULL, '', '', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-21 13:05:44'),
(2, '0052.013539.00126/2025-81', '192/2026', 'aguardando_homologacao', 'Licitação resumida', 'tomada_de_precos', 'fracassada', 32552.24, '2026-05-21', NULL, NULL, '2026-05-06', '', 'Bem Fica LTDA', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-21 11:54:50'),
(3, '0052.013539.00126/2025-81', '92/2026', 'Objetivo teste', 'Homologada de sacolas', 'tomada_de_precos', 'homologada', 99123.99, '2026-05-29', NULL, NULL, '2026-04-01', '', 'Fonte de Renda Limitada ME', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:44:42'),
(4, '0052.013539.00126/2025-81', '292/2026', 'deserta', 'Licitação em andamento Tinta Licitação em andamento Tinta', 'tomada_de_precos', 'homologada', 96325.33, '2026-04-11', NULL, NULL, '2026-05-01', '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-20 11:11:44'),
(5, '0052.013539.00126/2025-81', '392/2026', 'Objetivo teste', 'Andamento de marmitas', 'tomada_de_precos', 'em_andamento', 98569.77, '2026-05-02', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:45:17'),
(6, '0052.013539.00126/2025-81', '152/2026', 'aguardando_homologacao', 'Copo descartável.', 'tomada_de_precos', 'em_andamento', 4545.33, '2025-12-22', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:45:54'),
(7, '0052.013539.00126/2025-81', '332/2026', 'Objetivo teste', '', 'tomada_de_precos', 'em_andamento', 9632.33, '2026-06-12', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:46:02'),
(8, '0052.013539.00126/2025-81', '885/2026', 'deserta', 'Modalidade tomada de preços', 'tomada_de_precos', 'homologada', 95863.00, '2026-05-04', NULL, NULL, '2026-05-25', '', 'Supermercado Araújo S.A', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:46:10'),
(9, '0052.013539.00126/2025-81', '90/2026', 'Objetivo teste', 'Capacete de bombeiro', 'tomada_de_precos', 'em_andamento', 78965.33, '2025-11-18', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:46:18'),
(10, '0052.013539.00126/2025-81', '192/2026', 'aguardando_homologacao', 'Homologação de café', 'tomada_de_precos', 'homologada', 36985.33, '2026-06-30', NULL, NULL, '2026-04-02', '', 'Canecas Ilustradas Elegantes LTDA', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:46:25'),
(11, '0052.013539.00126/2025-81', '92/2025', 'Objetivo teste', 'Compra de ouro', 'tomada_de_precos', 'homologada', 124578.00, '2026-06-18', NULL, NULL, '2026-05-02', '', 'Chaves de Ouro Vermelho LTDA', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:46:36'),
(12, '0052.013539.00126/2025-81', '69/2026', 'deserta', 'Homologa fios de lã', 'tomada_de_precos', 'homologada', 52526.33, '2026-05-30', NULL, NULL, '2026-03-01', '', 'Empresa de Fachada Fechada LTDA', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:47:00'),
(13, '0052.013539.00126/2025-81', '55/2025', 'Objetivo teste', 'Anda de carro', 'tomada_de_precos', 'em_andamento', 96586.33, '2026-04-22', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:47:08'),
(14, '0052.013539.00126/2025-81', '33/2026', 'Esta objeto será detalhado o máximo possível para tomar bastante espaço para aparecer na modal', 'Papel carbono', 'tomada_de_precos', 'homologada', 33669.33, '2026-06-29', '2026-05-20', '2026-05-28', '2026-05-06', '', 'Facebook Empresa do Brasil', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-20 13:13:39'),
(15, '0052.013539.00126/2025-81', '963/2026', 'Objetivo teste', '', 'tomada_de_precos', 'em_andamento', 45781.33, '2026-07-22', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:47:36'),
(16, '0052.013539.00126/2025-81', '258/2026', 'deserta', 'Escolhidos do fone de ouvido', 'tomada_de_precos', 'homologada', 58612.66, '2026-07-17', '2026-02-01', NULL, '2026-01-01', '', 'Favelas Carnaval 2027 EIRELI', '', '', 'manual', '2026-04-13 09:10:50', '2026-05-11 08:47:51'),
(17, '0052.013539.00126/2025-81', '753/2027', 'Objetivo teste fracassada', 'Objeto de uma fracassada', 'tomada_de_precos', 'homologada', 96325.71, '2026-05-14', NULL, NULL, NULL, '', NULL, '', '', 'manual', '2026-04-13 09:10:50', '2026-05-20 11:11:55'),
(18, '0053.013539.00126/2025-81', '362/2025', 'Compra de papeis de várias cores', 'Papeis coloridos.', 'pregao_eletronico', 'deserta', 12228.22, '2026-02-25', NULL, '2026-03-25', '2025-05-25', '', '', '', '', 'manual', '2026-05-11 08:58:21', '2026-05-21 10:39:27')
ON DUPLICATE KEY UPDATE
    `numero_processo` = VALUES(`numero_processo`),
    `numero_licitacao` = VALUES(`numero_licitacao`),
    `objeto` = VALUES(`objeto`),
    `objeto_resumido` = VALUES(`objeto_resumido`),
    `modalidade` = VALUES(`modalidade`),
    `status` = VALUES(`status`),
    `valor_estimado` = VALUES(`valor_estimado`),
    `data_abertura` = VALUES(`data_abertura`),
    `data_prevista_conclusao` = VALUES(`data_prevista_conclusao`),
    `data_sessao` = VALUES(`data_sessao`),
    `data_homologacao` = VALUES(`data_homologacao`),
    `responsavel` = VALUES(`responsavel`),
    `empresa_vencedora` = VALUES(`empresa_vencedora`),
    `link_portal` = VALUES(`link_portal`),
    `observacoes` = VALUES(`observacoes`),
    `origem` = VALUES(`origem`),
    `created_at` = VALUES(`created_at`),
    `updated_at` = VALUES(`updated_at`);

-- ---------- importacoes_log ----------
INSERT INTO `importacoes_log` (`id`, `tipo`, `nome_arquivo`, `total_linhas`, `importados`, `erros`, `detalhes_erros`, `usuario_id`, `created_at`) VALUES
(1, 'excel', 'contratos_idaf_para_importar (1).xlsx', 64, 61, 1, '["Linha 4: Data de vencimento inválida (Nº Contrato)."]', 1, '2026-04-13 08:50:20')
ON DUPLICATE KEY UPDATE
    `tipo` = VALUES(`tipo`),
    `nome_arquivo` = VALUES(`nome_arquivo`),
    `total_linhas` = VALUES(`total_linhas`),
    `importados` = VALUES(`importados`),
    `erros` = VALUES(`erros`),
    `detalhes_erros` = VALUES(`detalhes_erros`),
    `usuario_id` = VALUES(`usuario_id`),
    `created_at` = VALUES(`created_at`);

-- Conferencia: nao deve sobrar nenhuma sequencia duplo-codificada
SELECT COUNT(*) AS ainda_quebrados FROM contratos
  WHERE HEX(objeto) REGEXP 'C38[23](C[23]|E2)';
SELECT id, LEFT(objeto, 45) AS amostra FROM contratos ORDER BY id LIMIT 5;
