-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Tempo de geração: 18/08/2026 às 15:12
-- Versão do servidor: 8.0.30
-- Versão do PHP: 8.5.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `contratos_idaf`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `aditivos`
--

CREATE TABLE `aditivos` (
  `id` int NOT NULL,
  `contrato_id` int NOT NULL,
  `numero_aditivo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('prazo','valor','prazo_e_valor','objeto','rescisao') COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_assinatura` date NOT NULL,
  `nova_data_vencimento` date DEFAULT NULL,
  `valor_acrescimo` decimal(15,2) DEFAULT '0.00',
  `valor_reducao` decimal(15,2) DEFAULT '0.00',
  `justificativa` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `contratos`
--

CREATE TABLE `contratos` (
  `id` int NOT NULL,
  `numero` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_processo` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `licitacao_id` int DEFAULT NULL,
  `fornecedor_id` int DEFAULT NULL,
  `fornecedor_nome` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fornecedor_cnpj` char(18) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `objeto` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `modalidade` enum('pregao_eletronico','pregao_presencial','concorrencia','tomada_de_precos','convite','dispensa','inexigibilidade','chamamento_publico') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valor_total` decimal(15,2) NOT NULL,
  `saldo_atual` decimal(15,2) NOT NULL,
  `data_assinatura` date NOT NULL,
  `data_inicio` date NOT NULL,
  `data_vencimento` date NOT NULL,
  `status_manual` enum('ativo','encerrado','suspenso','rescindido') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gestor_nome` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gestor_matricula` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fiscal_nome` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fiscal_matricula` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dotacao_orcamentaria` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacoes` text COLLATE utf8mb4_unicode_ci,
  `origem` enum('manual','importacao','pdf') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `active` int NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `contratos`
--

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
(63, '2525/2025', '0052.013539.00126/2027-81', 3, NULL, 'JAVA LTDA', '', 'Testando o objeto', 'pregao_eletronico', 0.00, 0.00, '2022-12-12', '2025-02-22', '2026-08-17', NULL, '', '', '', '', '', '', 'manual', 1, '2026-07-21 09:10:08', '2026-07-21 09:10:08');

-- --------------------------------------------------------

--
-- Estrutura para tabela `controles`
--

CREATE TABLE `controles` (
  `id` int NOT NULL,
  `modal` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `velocidade_contrato_tranquilo` int NOT NULL DEFAULT '30',
  `velocidade_contrato_atencao` int NOT NULL DEFAULT '30',
  `velocidade_contrato_critico` int NOT NULL DEFAULT '30',
  `velocidade_licitacao_deserta` int NOT NULL DEFAULT '30',
  `velocidade_licitacao_andamento` int NOT NULL DEFAULT '30',
  `velocidade_licitacao_homologada` int NOT NULL DEFAULT '30',
  `transicao` int NOT NULL DEFAULT '60',
  `user_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `controles`
--

INSERT INTO `controles` (`id`, `modal`, `velocidade_contrato_tranquilo`, `velocidade_contrato_atencao`, `velocidade_contrato_critico`, `velocidade_licitacao_deserta`, `velocidade_licitacao_andamento`, `velocidade_licitacao_homologada`, `transicao`, `user_id`, `created_at`) VALUES
(1, 'licitacao_92-2025', 10, 10, 10, 10, 10, 10, 30, 1, '2026-07-21 13:33:04');

-- --------------------------------------------------------

--
-- Estrutura para tabela `documentos`
--

CREATE TABLE `documentos` (
  `id` int NOT NULL,
  `tipo` enum('contrato','licitacao','aditivo') COLLATE utf8mb4_unicode_ci NOT NULL,
  `referencia_id` int NOT NULL,
  `nome_original` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome_arquivo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `caminho` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tamanho_kb` int DEFAULT NULL,
  `origem` enum('manual','importacao','pdf_diario') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `dados_extraidos` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `fornecedores`
--

CREATE TABLE `fornecedores` (
  `id` int NOT NULL,
  `razao_social` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome_fantasia` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cnpj` char(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `importacoes_log`
--

CREATE TABLE `importacoes_log` (
  `id` int NOT NULL,
  `tipo` enum('csv','excel','pdf') COLLATE utf8mb4_unicode_ci NOT NULL,
  `nome_arquivo` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_linhas` int NOT NULL DEFAULT '0',
  `importados` int NOT NULL DEFAULT '0',
  `erros` int NOT NULL DEFAULT '0',
  `detalhes_erros` json DEFAULT NULL,
  `usuario_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `importacoes_log`
--

INSERT INTO `importacoes_log` (`id`, `tipo`, `nome_arquivo`, `total_linhas`, `importados`, `erros`, `detalhes_erros`, `usuario_id`, `created_at`) VALUES
(1, 'excel', 'contratos_idaf_para_importar (1).xlsx', 64, 61, 1, '[\"Linha 4: Data de vencimento inválida (Nº Contrato).\"]', 1, '2026-04-13 08:50:20');

-- --------------------------------------------------------

--
-- Estrutura para tabela `licitacoes`
--

CREATE TABLE `licitacoes` (
  `id` int NOT NULL,
  `numero_processo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_licitacao` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `objeto` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `objeto_resumido` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `modalidade` enum('pregao_eletronico','pregao_presencial','concorrencia','tomada_de_precos','convite','dispensa','inexigibilidade','chamamento_publico') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('em_andamento','aguardando_homologacao','homologada','deserta','fracassada','cancelada','suspensa') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'em_andamento',
  `valor_estimado` decimal(15,2) DEFAULT NULL,
  `data_abertura` date DEFAULT NULL,
  `data_prevista_conclusao` date DEFAULT NULL,
  `data_sessao` date DEFAULT NULL,
  `data_homologacao` date DEFAULT NULL,
  `responsavel` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `empresa_vencedora` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_portal` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observacoes` text COLLATE utf8mb4_unicode_ci,
  `origem` enum('manual','importacao','pdf') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'manual',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `licitacoes`
--

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
(18, '0053.013539.00126/2025-81', '362/2025', 'Compra de papeis de várias cores', 'Papeis coloridos.', 'pregao_eletronico', 'deserta', 12228.22, '2026-02-25', NULL, '2026-03-25', '2025-05-25', '', '', '', '', 'manual', '2026-05-11 08:58:21', '2026-05-21 10:39:27');

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int NOT NULL,
  `nome` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nivel` enum('admin','visualizador') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'visualizador',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `ultimo_acesso` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome`, `email`, `senha_hash`, `nivel`, `ativo`, `ultimo_acesso`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', 'admin@idaf.ac.gov.br', 'Idaf@2026', 'admin', 1, '2026-05-27 07:43:33', '2026-04-13 07:38:09', '2026-05-27 07:43:33'),
(2, 'Vlaydisson', 'vlaydisson@gmail.com', '$2y$12$XaOT9bwn8MpZ2Q01hfy.Oube1LJnEjMDp0ieEl3S36eARoqdbyq76', 'admin', 1, '2026-07-21 08:27:26', '2026-05-13 13:02:33', '2026-07-21 08:27:26');

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_contratos`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_contratos` (
`id` int
,`numero` varchar(50)
,`numero_processo` varchar(50)
,`licitacao_id` int
,`fornecedor_id` int
,`fornecedor_nome` varchar(255)
,`fornecedor_cnpj` char(18)
,`objeto` text
,`modalidade` enum('pregao_eletronico','pregao_presencial','concorrencia','tomada_de_precos','convite','dispensa','inexigibilidade','chamamento_publico')
,`valor_total` decimal(15,2)
,`saldo_atual` decimal(15,2)
,`data_assinatura` date
,`data_inicio` date
,`data_vencimento` date
,`status_manual` enum('ativo','encerrado','suspenso','rescindido')
,`gestor_nome` varchar(150)
,`gestor_matricula` varchar(50)
,`fiscal_nome` varchar(150)
,`fiscal_matricula` varchar(50)
,`dotacao_orcamentaria` varchar(100)
,`observacoes` text
,`origem` enum('manual','importacao','pdf')
,`active` int
,`created_at` datetime
,`updated_at` datetime
,`dias_para_vencer` int
,`status_vencimento` varchar(10)
,`fornecedor_display` varchar(255)
,`cnpj_display` varchar(18)
,`valor_executado` decimal(16,2)
,`percentual_executado` decimal(21,1)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_dashboard_resumo`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_dashboard_resumo` (
`total_contratos` bigint
,`vencido` decimal(23,0)
,`vencido_hid` decimal(23,0)
,`critico` decimal(23,0)
,`critico_hid` decimal(23,0)
,`atencao` decimal(23,0)
,`atencao_hid` decimal(23,0)
,`alerta` decimal(23,0)
,`alerta_hid` decimal(23,0)
,`regular` decimal(23,0)
,`regular_hid` decimal(23,0)
,`valor_total_carteira` decimal(37,2)
,`saldo_total_carteira` decimal(37,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vw_resumo_licitacao`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vw_resumo_licitacao` (
`total_licitacoes` bigint
,`em_andamento` decimal(23,0)
,`aguardando_homologacao` decimal(23,0)
,`homologada` decimal(23,0)
,`deserta` decimal(23,0)
,`fracassada` decimal(23,0)
,`cancelada` decimal(23,0)
,`suspensa` decimal(23,0)
);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `aditivos`
--
ALTER TABLE `aditivos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contrato_id` (`contrato_id`);

--
-- Índices de tabela `contratos`
--
ALTER TABLE `contratos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `licitacao_id` (`licitacao_id`),
  ADD KEY `fornecedor_id` (`fornecedor_id`);

--
-- Índices de tabela `controles`
--
ALTER TABLE `controles`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `fornecedores`
--
ALTER TABLE `fornecedores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cnpj` (`cnpj`);

--
-- Índices de tabela `importacoes_log`
--
ALTER TABLE `importacoes_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Índices de tabela `licitacoes`
--
ALTER TABLE `licitacoes`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `aditivos`
--
ALTER TABLE `aditivos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `contratos`
--
ALTER TABLE `contratos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de tabela `controles`
--
ALTER TABLE `controles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `documentos`
--
ALTER TABLE `documentos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `fornecedores`
--
ALTER TABLE `fornecedores`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `importacoes_log`
--
ALTER TABLE `importacoes_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `licitacoes`
--
ALTER TABLE `licitacoes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT de tabela `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_contratos`
--
DROP TABLE IF EXISTS `vw_contratos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_contratos`  AS SELECT `c`.`id` AS `id`, `c`.`numero` AS `numero`, `c`.`numero_processo` AS `numero_processo`, `c`.`licitacao_id` AS `licitacao_id`, `c`.`fornecedor_id` AS `fornecedor_id`, `c`.`fornecedor_nome` AS `fornecedor_nome`, `c`.`fornecedor_cnpj` AS `fornecedor_cnpj`, `c`.`objeto` AS `objeto`, `c`.`modalidade` AS `modalidade`, `c`.`valor_total` AS `valor_total`, `c`.`saldo_atual` AS `saldo_atual`, `c`.`data_assinatura` AS `data_assinatura`, `c`.`data_inicio` AS `data_inicio`, `c`.`data_vencimento` AS `data_vencimento`, `c`.`status_manual` AS `status_manual`, `c`.`gestor_nome` AS `gestor_nome`, `c`.`gestor_matricula` AS `gestor_matricula`, `c`.`fiscal_nome` AS `fiscal_nome`, `c`.`fiscal_matricula` AS `fiscal_matricula`, `c`.`dotacao_orcamentaria` AS `dotacao_orcamentaria`, `c`.`observacoes` AS `observacoes`, `c`.`origem` AS `origem`, `c`.`active` AS `active`, `c`.`created_at` AS `created_at`, `c`.`updated_at` AS `updated_at`, (to_days(`c`.`data_vencimento`) - to_days(curdate())) AS `dias_para_vencer`, (case when (`c`.`status_manual` is not null) then `c`.`status_manual` when (`c`.`data_vencimento` < curdate()) then 'vencido' when ((to_days(`c`.`data_vencimento`) - to_days(curdate())) <= 30) then 'critico' when ((to_days(`c`.`data_vencimento`) - to_days(curdate())) <= 90) then 'atencao' when ((to_days(`c`.`data_vencimento`) - to_days(curdate())) <= 180) then 'alerta' else 'regular' end) AS `status_vencimento`, coalesce(`f`.`razao_social`,`c`.`fornecedor_nome`) AS `fornecedor_display`, coalesce(`f`.`cnpj`,`c`.`fornecedor_cnpj`) AS `cnpj_display`, (`c`.`valor_total` - `c`.`saldo_atual`) AS `valor_executado`, round((((`c`.`valor_total` - `c`.`saldo_atual`) / `c`.`valor_total`) * 100),1) AS `percentual_executado` FROM (`contratos` `c` left join `fornecedores` `f` on((`f`.`id` = `c`.`fornecedor_id`))) ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_dashboard_resumo`
--
DROP TABLE IF EXISTS `vw_dashboard_resumo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_dashboard_resumo`  AS SELECT count(0) AS `total_contratos`, sum((case when ((`contratos`.`data_vencimento` < curdate()) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `vencido`, sum((case when ((`contratos`.`data_vencimento` < curdate()) and (`contratos`.`status_manual` is null) and (`contratos`.`active` = 0)) then 1 else 0 end)) AS `vencido_hid`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 0 and 30) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `critico`, sum((0 <> (case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 0 and 30) and (`contratos`.`status_manual` is null) and (`contratos`.`active` = 0)) then 1 else 0 end))) AS `critico_hid`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 31 and 90) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `atencao`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 31 and 90) and (`contratos`.`status_manual` is null) and (`contratos`.`active` = 0)) then 1 else 0 end)) AS `atencao_hid`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 91 and 180) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `alerta`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 91 and 180) and (`contratos`.`status_manual` is null) and (`contratos`.`active` = 0)) then 1 else 0 end)) AS `alerta_hid`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) > 180) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `regular`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) > 180) and (`contratos`.`status_manual` is null) and (`contratos`.`active` = 0)) then 1 else 0 end)) AS `regular_hid`, sum(`contratos`.`valor_total`) AS `valor_total_carteira`, sum(`contratos`.`saldo_atual`) AS `saldo_total_carteira` FROM `contratos` WHERE ((`contratos`.`status_manual` not in ('encerrado','rescindido')) OR (`contratos`.`status_manual` is null)) ;

-- --------------------------------------------------------

--
-- Estrutura para view `vw_resumo_licitacao`
--
DROP TABLE IF EXISTS `vw_resumo_licitacao`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_resumo_licitacao`  AS SELECT count(0) AS `total_licitacoes`, sum((case when (`licitacoes`.`status` = 'em_andamento') then 1 else 0 end)) AS `em_andamento`, sum((case when (`licitacoes`.`status` = 'aguardando_homologacao') then 1 else 0 end)) AS `aguardando_homologacao`, sum((case when (`licitacoes`.`status` = 'homologada') then 1 else 0 end)) AS `homologada`, sum((case when (`licitacoes`.`status` = 'deserta') then 1 else 0 end)) AS `deserta`, sum((case when (`licitacoes`.`status` = 'fracassada') then 1 else 0 end)) AS `fracassada`, sum((case when (`licitacoes`.`status` = 'cancelada') then 1 else 0 end)) AS `cancelada`, sum((case when (`licitacoes`.`status` = 'suspensa') then 1 else 0 end)) AS `suspensa` FROM `licitacoes` ;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `aditivos`
--
ALTER TABLE `aditivos`
  ADD CONSTRAINT `aditivos_ibfk_1` FOREIGN KEY (`contrato_id`) REFERENCES `contratos` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `contratos`
--
ALTER TABLE `contratos`
  ADD CONSTRAINT `contratos_ibfk_1` FOREIGN KEY (`licitacao_id`) REFERENCES `licitacoes` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `contratos_ibfk_2` FOREIGN KEY (`fornecedor_id`) REFERENCES `fornecedores` (`id`) ON DELETE SET NULL;

--
-- Restrições para tabelas `importacoes_log`
--
ALTER TABLE `importacoes_log`
  ADD CONSTRAINT `importacoes_log_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
