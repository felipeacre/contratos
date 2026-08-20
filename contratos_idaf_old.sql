-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Tempo de geração: 20-Ago-2026 às 14:15
-- Versão do servidor: 8.0.45
-- versão do PHP: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de dados: `contratos_idaf`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `aditivos`
--

CREATE TABLE `aditivos` (
  `id` int NOT NULL,
  `contrato_id` int NOT NULL,
  `numero_aditivo` varchar(50) NOT NULL,
  `tipo` enum('prazo','valor','prazo_e_valor','objeto','rescisao') NOT NULL,
  `data_assinatura` date NOT NULL,
  `nova_data_vencimento` date DEFAULT NULL,
  `valor_acrescimo` decimal(15,2) DEFAULT '0.00',
  `valor_reducao` decimal(15,2) DEFAULT '0.00',
  `justificativa` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `contratos`
--

CREATE TABLE `contratos` (
  `id` int NOT NULL,
  `numero` varchar(50) NOT NULL,
  `numero_processo` varchar(50) DEFAULT NULL,
  `licitacao_id` int DEFAULT NULL,
  `fornecedor_id` int DEFAULT NULL,
  `fornecedor_nome` varchar(255) DEFAULT NULL,
  `fornecedor_cnpj` char(18) DEFAULT NULL,
  `objeto` text NOT NULL,
  `modalidade` enum('pregao_eletronico','pregao_presencial','concorrencia','tomada_de_precos','convite','dispensa','inexigibilidade','chamamento_publico') DEFAULT NULL,
  `valor_total` decimal(15,2) NOT NULL,
  `saldo_atual` decimal(15,2) NOT NULL,
  `data_assinatura` date NOT NULL,
  `data_inicio` date NOT NULL,
  `data_vencimento` date NOT NULL,
  `status_manual` enum('ativo','encerrado','suspenso','rescindido') DEFAULT NULL,
  `gestor_nome` varchar(150) DEFAULT NULL,
  `gestor_matricula` varchar(50) DEFAULT NULL,
  `fiscal_nome` varchar(150) DEFAULT NULL,
  `fiscal_matricula` varchar(50) DEFAULT NULL,
  `dotacao_orcamentaria` varchar(100) DEFAULT NULL,
  `observacoes` text,
  `origem` enum('manual','importacao','pdf') NOT NULL DEFAULT 'manual',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Extraindo dados da tabela `contratos`
--

INSERT INTO `contratos` (`id`, `numero`, `numero_processo`, `licitacao_id`, `fornecedor_id`, `fornecedor_nome`, `fornecedor_cnpj`, `objeto`, `modalidade`, `valor_total`, `saldo_atual`, `data_assinatura`, `data_inicio`, `data_vencimento`, `status_manual`, `gestor_nome`, `gestor_matricula`, `fiscal_nome`, `fiscal_matricula`, `dotacao_orcamentaria`, `observacoes`, `origem`, `created_at`, `updated_at`) VALUES
(1, '16/2024', '', NULL, NULL, 'ATIVA CONSULTORIA ORGANIZACIONAL LTDA', '', 'SERVIÇO TERCERIZADO APOIO OPERACIONAL', 'pregao_presencial', 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-04-01', NULL, '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-03-31 18:21:08'),
(2, '07/2025', '', NULL, NULL, 'A.A.C ROCHA COMERCIO & SERVIÇO', '', 'Contratação de pessoa jurídica para o fornecimento de materiais de consumo (Água Mineral e Galão vazio, Gás de cozinha, botija de gás vazia ), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', 'pregao_eletronico', 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-04-02', NULL, '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-04-01 12:56:33'),
(5, '09/2025', '', NULL, NULL, 'VALOR GESTÃO E SERVIÇOS TECNOLOGICOS', '', 'Contratação de Empresa para Prestação de Serviço de Administração e Gerenciamento Informatizado para Manutenção Preventiva e Corretiva de Veículos com Fornecimento de Peças e Acessórios.', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-04-11', NULL, '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-04-08 13:01:26'),
(12, '047/2022', '', NULL, NULL, 'JWC MULTISERVIOS', '', 'SERVIÇOS OPERACIONAIS', 'pregao_presencial', 595.05, 0.00, '2026-05-21', '2026-05-31', '2027-05-31', 'ativo', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-05-27 17:37:38'),
(14, '28/2024', '', NULL, NULL, 'PRB SERVIÇOS, COMÉRCIO E REPRESENTAÇÕES LTDA', '', 'Empresa de prestação de Serviços Chaveiros, Carimbos e Crachás', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-06-11', NULL, '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:16'),
(15, '29/2024', '', NULL, NULL, 'GRUPO E IMPORTACAO E EXPORTACAO LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-17', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:25'),
(16, '30/2024', '', NULL, NULL, 'J. & J D\'PAULA E CIA LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-17', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:35'),
(17, '31/2024', '', NULL, NULL, 'G. S. SILVEIRA LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-17', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:40'),
(18, '32/2024', '', NULL, NULL, 'H.J.RODRIGUES FILHO', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-17', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:45'),
(19, '34/2024', '', NULL, NULL, 'COMERCIAL KALEDO LTDA', '', 'Contratação de Empresa para Fornecimento de Material Gráfico, Visual, Permanente e de Malharia', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-17', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:50'),
(20, '21/2025', '', NULL, NULL, 'KKD BATISTA LTDA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos (Geladeira), para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-18', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-06-23 13:45:54'),
(21, '22/2025', '', NULL, NULL, 'WILLIAN DA SILVA DE SOUZA', '', 'Contratação de pessoa jurídica para o Fornecimento de Equipamentos e Serviço de Conexão de Internet via Satélite, conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-06-26', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-07-06 13:31:46'),
(22, '23/2025', '', NULL, NULL, 'JEFF COMERCIO E SERVICOS LTDA', '', 'Aquisição de Gêneros Alimentícios (pó de café e açúcar, sachê de chá, Biscoito doce e biscoito salgado.), Conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento.', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-07-07', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 13:59:24'),
(23, '023/2021', '', NULL, NULL, 'INSTITUTO EVALDO LODI', '', 'ESTAGIÁRIO', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-07-07', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 13:59:48'),
(24, '24/2025', '', NULL, NULL, 'E.L.S VIEIRA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos (Lanterna Tática Militar), para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-07-10', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 13:59:55'),
(25, '26/2025', '', NULL, NULL, 'Ambi-Clean Limpeza e Higienização LTD', '', 'O presente contrato tem por objeto a contratação de empresa de engenharia para a execução do projeto, fornecimento e instalação de um Sistema de Energia Solar Fotovoltaico, a ser implementado na sede do Instituto de Defesa Agropecuária e Florestal do Acre - IDAF/AC', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-07-18', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 14:00:04'),
(26, '27/2025', '', NULL, NULL, 'MB IMPORTAÇÃO LTDA', '', 'Contratação de empresa para Aquisição de Equipamentos de Informática (LICENÇA MICROSOFT OFFICE), conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-07-25', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 14:00:16'),
(27, '040/2025', '', NULL, NULL, 'K.K.D BATISTA LTDA', '', 'Aquisição de Equipamentos de Informática (TECLADO USB)', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-07-25', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 14:00:10'),
(28, '28/2025', '', NULL, NULL, 'BT COMÉRCIO INTELIGENTE LTDA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos ( Ar Condicionado de 18 Mil Btus)', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-08-05', 'encerrado', '', '', '', '', '', '', 'importacao', '2026-03-27 18:55:59', '2026-08-12 14:00:21'),
(29, '30/2025', NULL, NULL, NULL, 'A.WAGNER L. DA SILVA LTDA', '', 'Contratação de Pessoa Jurídica para Prestação de Serviços de Instalação, Desinstalação, Limpeza, Manutenção e Reparo de aparelho de Ar Condicionado com Fornecimento de Peças, Gás de Reposição e Componentes para Instalação', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-08-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(30, '31/2025', NULL, NULL, NULL, 'AGROSAFETY MONITORAMENTO AGRÍCOLA LTDA', '', 'Serviço de Envio e Análise Multirresíduos de Ingredientes ativos de Agrotóxicos em Produtos Agrícolas', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-08-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(31, '32/2025', NULL, NULL, NULL, 'S V NOGUEIRA LTDA', '', 'Aquisição de Bens Permanentes, Móveis e Utensílios e Equipamentos ( Aparelho de Ar condicionado 12.000 BTU)', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-08-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(32, '39/2025', NULL, NULL, NULL, 'PAPELARIA MUNDO IMPORTAÇÃO E EXPORTAÇÃO LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-09-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(33, '34/2025', NULL, NULL, NULL, 'CÉLIO PEREIRA LTDA', '', 'COFFE BREAK', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-09-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(34, '35/2025', NULL, NULL, NULL, 'COMFORT RBO LTDA', '', 'Aquisição de Cortinas e Persianas', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-09-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(35, '36/2025', NULL, NULL, NULL, 'A. L. B. LUZ', '', 'Meios de Conservação de Amostras de Suspeitas de Doenças Vesiculares', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-09-19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(36, '37/2025', NULL, NULL, NULL, 'SISTEL SISTEMA TELECOMUNICAÇÕES', '', 'manutenção preventiva e corretiva de rede lógica', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(37, '067/2023', NULL, NULL, NULL, 'ANSELMO RIBEIRO DO NASCIMENTO LTDA', '', 'vigilância eletrônica', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(38, '042/2025', NULL, NULL, NULL, 'J S CORDEIRO LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(39, '043/2025', NULL, NULL, NULL, 'EASYTECH SECURITY COMERCIO DE ELETRÔNICO LTDA', '', 'Aquisição de Equipamentos de Informática (KEYSTONE CAT 6 E KIT TECLADO E MOUSE SEM FIO)', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(40, '045/2025', NULL, NULL, NULL, 'C. F. MIRANDA LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(41, '046/2025', NULL, NULL, NULL, 'BEEVOLT ENERGY LTDA', '', 'Aquisição de material de expediente', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(42, '047/2025', NULL, NULL, NULL, 'ECOPOWER EFICIENCIA ENERGETICA LTDA.', '', 'contratação de empresa de engenharia para a execução do projeto, fornecimento e instalação de um Sistema de Energia Solar Fotovoltaico', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-10-30', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(43, '073/2022', NULL, NULL, NULL, 'BIOLOGISTICA', '', 'SERVIÇOS DE TRANSPORTE DE AMOSTRA', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-11-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(44, '051/2025', NULL, NULL, NULL, 'LAPTOP COMÉRCIO DE PRODUTOS DE INFORMÁTICA LTDA', '', 'Aquisição de Equipamentos de Informática (CABO DE REDE CAT 6)', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(45, '053/2025', NULL, NULL, NULL, 'MARIA V.C DA SILVA LTDA', '', 'Contratação de pessoa jurídica para o Fornecimento de Marmitex', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(46, '055/2025', NULL, NULL, NULL, 'VILSON DA SILVA OLIVEIRA LTDA', '', 'aquisição de Água Mineral Natural, acondicionada em embalagem de 20 litros, com o intuito de atender as necessidades do Instituo de Defesa Agropecuária e Florestal - IDAF na regional do vale do Juruá e tarauacá/envira', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(47, '056/2025', NULL, NULL, NULL, 'DISTRIBUIDORA DE GÁS CENTRAL LTDA', '', 'aquisição de Carga de gás liquefeito de Petróleo - GLP (P13), em regime de troca de botija (vazio pelo cheio)', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(48, '043/2021', NULL, NULL, NULL, 'LINK CARD', '', 'INFORMATIZAÇÃO DE ABASTECIMENTO', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(49, '057/2025', NULL, NULL, NULL, 'HPE AUTOMOTORES DO BRASIL LTDA', '', 'Aquisição veículos Tipo Pick-Up nov', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(50, '60/2025', NULL, NULL, NULL, 'PAPELARIA MUNDO IMPORTAÇÃO E EXPORTAÇÃO LTDA', '', 'Aquisição de materiais de limpeza, copa e descartávei', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(51, '63/2025', NULL, NULL, NULL, 'DL RAMOS', '', 'Aquisição de materiais de limpeza, copa e descartáveis,', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2026-12-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(52, '02/2026', NULL, NULL, NULL, 'MS EMPREENDIMENTOS E REPRESENTAÇÕES LTDA', '', 'Empresa de Engenharia Para Execução de Serviços de Reforma Estrutural, Instalações Elétricas e Hidráulicas na sede do Instituto de Defesa Agropecuária e Florestal do Estado do Acre – IDAF,', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-01-27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(53, '01/2025', NULL, NULL, NULL, 'ATIVA CONSULTORIA ORGANIZACIONAL LTDA', '', 'O presente Contrato tem por objeto a contratação de empresa para prestação de serviço terceirizado e continuado de apoio operacional e administrativo, com disponibilização de mão de obra em regime de dedicação exclusiva, a serem executados no âmbito do Instituto de Defesa Agropecuária e Florestal em Rio Branco', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-02-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(54, '089/2023', NULL, NULL, NULL, 'KOA TURISMO E INTERCÂMBIO LTDA', '', 'passagem aérea', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-02-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(55, '10/2024', NULL, NULL, NULL, 'DUX COMERCIO REPRESENTAÇÕES IMPORTAÇÃO E EXPORTAÇÃO EIREL', '', 'objeto a contratação de empresa especializada no serviço de impressão (outsourcing de impressão), na modalidade franquia mínima mensal de páginas e valor fixo de páginas excedentes pelo prazo de 48 (quarenta e oito) meses', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-02-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(56, '11/2024', NULL, NULL, NULL, 'CRUZEIRO MOTORS', '', 'objeto empresa especializada na prestação de serviços de manutenção preventiva e corretiva de motosserras, roçadeiras manuais, motopodas, lavadoras de alta pressão, pulverizadores incluindo fornecimento de materiais, peças novas e mão de obra Na Na Regional Purus, Juruá e Tarauacá - Envira..', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-02-07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(57, '01/2026', NULL, NULL, NULL, 'MOVESA MOVEIS PLANEJADOS LTDA', '', 'Contração de Pessoa jurídica Para Fornecimento e Instalações de Moveis Planejados Por m²,', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-02-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(58, '13/2024', NULL, NULL, NULL, 'J.V NOGUEIRA IMPORTAÇÃO E EXPORTAÇÃO - ME', '', 'serviços de manutenção corretiva e preventiva de bens móveis: mesas, cadeiras e armarios, para atender as necessidades deste Instituto de Defesa Agropecuária e Florestal do Acre – IDAF em suas unidades da capital e interior do estado.', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-02-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(59, '06/2023', NULL, NULL, NULL, 'NP TECNOLOGIA E GESTAO DE DADOS LTDA / BANCO DE PREÇO', '', 'BANCO DE PREÇOS', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2027-03-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(60, '04/2025', NULL, NULL, NULL, 'AZ COMÉRCIO, SERV. E REP. IMP. EXP. LTDA', '', 'Contratação de empresa de engenharia para prestação de serviços comuns de engenharia de forma continuada, por demanda, para execução de manutenção predial e reformas de pouca relevância material, serviços de adequação, adaptação, reparação ou revitalização em prédio e logradouros públicos', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2030-02-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:55:59', '2026-03-27 18:55:59'),
(61, '18/2025', NULL, NULL, NULL, 'RADIONET LTDA', '', 'Contratação de serviços de rastreamento de veículos via GPRS, incluindo sistema l-boton, compreendendo a instalação e desinstalação, em comodato, de módulos rastreadores e a disponibilização de software de gerenciamento com acesso via Web, com a finalidade de controle de toda a frota de veículos do Instituto de Defesa Agropecuária e Florestal do Estado do Acre - unidades da Capital e as ULDAG\'s do interior do Estado', NULL, 0.00, 0.00, '2026-03-27', '2026-03-27', '2030-05-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'importacao', '2026-03-27 18:56:00', '2026-03-27 18:56:00'),
(62, '03/2026', '0052.013538.00015/2025-76', NULL, NULL, 'D R LIMA COMERCIO & SERVIÇOS LTDA', '15525591000113', 'Contratação de Empresa para Prestação de Serviços Terceirizados de \"Agente de Portaria Noturno\", Conforme condições, quantidades, exigências e estimativas, estabelecidas neste instrumento', 'pregao_eletronico', 844.80, 0.00, '2026-02-26', '2026-02-26', '2027-02-26', 'ativo', 'Deivid Borges Wassem', '', 'Antônio Joaquim Neto', '', '', '', 'manual', '2026-04-16 14:55:08', '2026-04-16 14:55:08'),
(63, '05/2026', '0052.013538.00015/2025-76', NULL, NULL, 'C.ARAUJO BOMFIM SOUSA LTDA', '13743704000104', 'Contratação de Empresa para Prestação de Serviços Terceirizados \"Servente de Limpeza Predial\", destinados ao suporte às ações desenvolvidas pelo Instituto de Defesa Agropecuária e Florestal do Acre - IDAF.', 'pregao_eletronico', 1285920.00, 0.00, '2026-04-01', '2026-04-01', '2027-04-01', 'ativo', 'Patrizzia Barbosa Lopes', '', 'Ana Carolina Ferreira de Holanda', '', '', '', 'manual', '2026-04-16 15:01:36', '2026-04-16 15:01:36'),
(64, '06/2026', '0052.013537.00033/2025-59', NULL, NULL, 'GRUPO E - IMP EXP LTDA', '17410071000165', 'Contratação de empresa para Aquisição de Uniformes Funcionais em Geral, com a finalidade de atender o Instituto de Defesa Agropecuária e Florestal do Estado do Acre - IDAF nas unidades da Capital e as ULDAF\'s do interior do Estado.', 'pregao_eletronico', 17268.00, 0.00, '2026-04-15', '2026-04-15', '2027-04-15', 'ativo', 'Carlos Douglas da Silva Costa', '', 'Willimis Alves Pereira -', '', '', '', 'manual', '2026-04-16 15:07:41', '2026-04-16 15:07:41');

-- --------------------------------------------------------

--
-- Estrutura da tabela `documentos`
--

CREATE TABLE `documentos` (
  `id` int NOT NULL,
  `tipo` enum('contrato','licitacao','aditivo') NOT NULL,
  `referencia_id` int NOT NULL,
  `nome_original` varchar(255) NOT NULL,
  `nome_arquivo` varchar(255) NOT NULL,
  `caminho` varchar(500) NOT NULL,
  `tamanho_kb` int DEFAULT NULL,
  `origem` enum('manual','importacao','pdf_diario') NOT NULL DEFAULT 'manual',
  `dados_extraidos` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `fornecedores`
--

CREATE TABLE `fornecedores` (
  `id` int NOT NULL,
  `razao_social` varchar(255) NOT NULL,
  `nome_fantasia` varchar(255) DEFAULT NULL,
  `cnpj` char(18) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `importacoes_log`
--

CREATE TABLE `importacoes_log` (
  `id` int NOT NULL,
  `tipo` enum('csv','excel','pdf') NOT NULL,
  `nome_arquivo` varchar(255) NOT NULL,
  `total_linhas` int NOT NULL DEFAULT '0',
  `importados` int NOT NULL DEFAULT '0',
  `erros` int NOT NULL DEFAULT '0',
  `detalhes_erros` json DEFAULT NULL,
  `usuario_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Extraindo dados da tabela `importacoes_log`
--

INSERT INTO `importacoes_log` (`id`, `tipo`, `nome_arquivo`, `total_linhas`, `importados`, `erros`, `detalhes_erros`, `usuario_id`, `created_at`) VALUES
(1, 'excel', 'PLANILHA PARA A TI.xlsx', 61, 0, 61, '[\"Linha 2: Número e objeto são obrigatórios.\", \"Linha 3: Número e objeto são obrigatórios.\", \"Linha 4: Número e objeto são obrigatórios.\", \"Linha 5: Número e objeto são obrigatórios.\", \"Linha 6: Número e objeto são obrigatórios.\", \"Linha 7: Número e objeto são obrigatórios.\", \"Linha 8: Número e objeto são obrigatórios.\", \"Linha 9: Número e objeto são obrigatórios.\", \"Linha 10: Número e objeto são obrigatórios.\", \"Linha 11: Número e objeto são obrigatórios.\", \"Linha 12: Número e objeto são obrigatórios.\", \"Linha 13: Número e objeto são obrigatórios.\", \"Linha 14: Número e objeto são obrigatórios.\", \"Linha 15: Número e objeto são obrigatórios.\", \"Linha 16: Número e objeto são obrigatórios.\", \"Linha 17: Número e objeto são obrigatórios.\", \"Linha 18: Número e objeto são obrigatórios.\", \"Linha 19: Número e objeto são obrigatórios.\", \"Linha 20: Número e objeto são obrigatórios.\", \"Linha 21: Número e objeto são obrigatórios.\", \"Linha 22: Número e objeto são obrigatórios.\", \"Linha 23: Número e objeto são obrigatórios.\", \"Linha 24: Número e objeto são obrigatórios.\", \"Linha 25: Número e objeto são obrigatórios.\", \"Linha 26: Número e objeto são obrigatórios.\", \"Linha 27: Número e objeto são obrigatórios.\", \"Linha 28: Número e objeto são obrigatórios.\", \"Linha 29: Número e objeto são obrigatórios.\", \"Linha 30: Número e objeto são obrigatórios.\", \"Linha 31: Número e objeto são obrigatórios.\", \"Linha 32: Número e objeto são obrigatórios.\", \"Linha 33: Número e objeto são obrigatórios.\", \"Linha 34: Número e objeto são obrigatórios.\", \"Linha 35: Número e objeto são obrigatórios.\", \"Linha 36: Número e objeto são obrigatórios.\", \"Linha 37: Número e objeto são obrigatórios.\", \"Linha 38: Número e objeto são obrigatórios.\", \"Linha 39: Número e objeto são obrigatórios.\", \"Linha 40: Número e objeto são obrigatórios.\", \"Linha 41: Número e objeto são obrigatórios.\", \"Linha 42: Número e objeto são obrigatórios.\", \"Linha 43: Número e objeto são obrigatórios.\", \"Linha 44: Número e objeto são obrigatórios.\", \"Linha 45: Número e objeto são obrigatórios.\", \"Linha 46: Número e objeto são obrigatórios.\", \"Linha 47: Número e objeto são obrigatórios.\", \"Linha 48: Número e objeto são obrigatórios.\", \"Linha 49: Número e objeto são obrigatórios.\", \"Linha 50: Número e objeto são obrigatórios.\", \"Linha 51: Número e objeto são obrigatórios.\", \"Linha 52: Número e objeto são obrigatórios.\", \"Linha 53: Número e objeto são obrigatórios.\", \"Linha 54: Número e objeto são obrigatórios.\", \"Linha 55: Número e objeto são obrigatórios.\", \"Linha 56: Número e objeto são obrigatórios.\", \"Linha 57: Número e objeto são obrigatórios.\", \"Linha 58: Número e objeto são obrigatórios.\", \"Linha 59: Número e objeto são obrigatórios.\", \"Linha 60: Número e objeto são obrigatórios.\", \"Linha 61: Número e objeto são obrigatórios.\", \"Linha 62: Número e objeto são obrigatórios.\"]', 1, '2026-03-27 18:55:20'),
(2, 'excel', 'contratos_idaf_para_importar (1).xlsx', 64, 61, 1, '[\"Linha 4: Data de vencimento inválida (Nº Contrato).\"]', 1, '2026-03-27 18:56:00');

-- --------------------------------------------------------

--
-- Estrutura da tabela `licitacoes`
--

CREATE TABLE `licitacoes` (
  `id` int NOT NULL,
  `numero_processo` varchar(50) NOT NULL,
  `numero_licitacao` varchar(50) DEFAULT NULL,
  `objeto` text NOT NULL,
  `modalidade` enum('pregao_eletronico','pregao_presencial','concorrencia','tomada_de_precos','convite','dispensa','inexigibilidade','chamamento_publico') NOT NULL,
  `status` enum('em_andamento','aguardando_homologacao','homologada','deserta','fracassada','cancelada','suspensa') NOT NULL DEFAULT 'em_andamento',
  `valor_estimado` decimal(15,2) DEFAULT NULL,
  `data_abertura` date DEFAULT NULL,
  `data_prevista_conclusao` date DEFAULT NULL,
  `data_homologacao` date DEFAULT NULL,
  `responsavel` varchar(150) DEFAULT NULL,
  `link_portal` varchar(500) DEFAULT NULL,
  `observacoes` text,
  `origem` enum('manual','importacao','pdf') NOT NULL DEFAULT 'manual',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Extraindo dados da tabela `licitacoes`
--

INSERT INTO `licitacoes` (`id`, `numero_processo`, `numero_licitacao`, `objeto`, `modalidade`, `status`, `valor_estimado`, `data_abertura`, `data_prevista_conclusao`, `data_homologacao`, `responsavel`, `link_portal`, `observacoes`, `origem`, `created_at`, `updated_at`) VALUES
(1, '0052.013539.00126/2025-81', 'Nº 092/2026', 'Contração de Pessoa jurídica para o Fornecimento de Móveis como Cadeiras, Poltronas e Sofás para as novas Instalações do Instituto de Defesa Agropecuária e Florestal do Estado do Acre (IDAF).', 'pregao_eletronico', 'em_andamento', 459936.50, '2026-03-26', '2026-04-30', NULL, 'Aline Leoncini Souto.', 'Id contratação PNCP: 16958425000148-1-000115/2026', 'Análise e emissão de parecer técnico – Pregão Eletrônico SRP nº 092/2026.', 'manual', '2026-04-07 19:01:09', '2026-04-13 13:58:11'),
(2, '0052.013537.00015/2026-58', '', 'Abertura de Processo Eletrônico - Objetivando a Aquisição de equipamentos e materiais de consumo destinados ao atendimento emergencial das ações do Programa Estadual de Sanidade Suídea (PESS) e do Programa Estadual de Sanidade Avícola (PESA), no âmbito do Instituto de Defesa Agropecuária e Florestal do Acre – IDAF.', 'dispensa', 'em_andamento', 0.00, '2026-04-08', '2026-06-30', NULL, '', '', '', 'manual', '2026-04-16 15:10:29', '2026-04-16 15:10:29');

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int NOT NULL,
  `nome` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `nivel` enum('admin','visualizador') NOT NULL DEFAULT 'visualizador',
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `ultimo_acesso` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Extraindo dados da tabela `usuarios`
--

INSERT INTO `usuarios` (`id`, `nome`, `email`, `senha_hash`, `nivel`, `ativo`, `ultimo_acesso`, `created_at`, `updated_at`) VALUES
(1, 'Administrador', 'admin@idaf.ac.gov.br', '$2y$10$naZqRsPrBquC8E2g1bXn9.qoOesmQGbwQ/q3hHkdgDYo8719/vQtu', 'admin', 1, '2026-08-12 13:57:10', '2026-03-27 16:06:56', '2026-08-12 13:57:10');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vw_contratos`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vw_contratos` (
`cnpj_display` varchar(18)
,`created_at` datetime
,`data_assinatura` date
,`data_inicio` date
,`data_vencimento` date
,`dias_para_vencer` int
,`dotacao_orcamentaria` varchar(100)
,`fiscal_matricula` varchar(50)
,`fiscal_nome` varchar(150)
,`fornecedor_cnpj` char(18)
,`fornecedor_display` varchar(255)
,`fornecedor_id` int
,`fornecedor_nome` varchar(255)
,`gestor_matricula` varchar(50)
,`gestor_nome` varchar(150)
,`id` int
,`licitacao_id` int
,`modalidade` enum('pregao_eletronico','pregao_presencial','concorrencia','tomada_de_precos','convite','dispensa','inexigibilidade','chamamento_publico')
,`numero` varchar(50)
,`numero_processo` varchar(50)
,`objeto` text
,`observacoes` text
,`origem` enum('manual','importacao','pdf')
,`percentual_executado` decimal(21,1)
,`saldo_atual` decimal(15,2)
,`status_manual` enum('ativo','encerrado','suspenso','rescindido')
,`status_vencimento` varchar(10)
,`updated_at` datetime
,`valor_executado` decimal(16,2)
,`valor_total` decimal(15,2)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `vw_dashboard_resumo`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `vw_dashboard_resumo` (
`alerta` decimal(23,0)
,`atencao` decimal(23,0)
,`criticos` decimal(23,0)
,`regulares` decimal(23,0)
,`saldo_total_carteira` decimal(37,2)
,`total_contratos` bigint
,`valor_total_carteira` decimal(37,2)
,`vencidos` decimal(23,0)
);

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `aditivos`
--
ALTER TABLE `aditivos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contrato_id` (`contrato_id`);

--
-- Índices para tabela `contratos`
--
ALTER TABLE `contratos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `licitacao_id` (`licitacao_id`),
  ADD KEY `fornecedor_id` (`fornecedor_id`);

--
-- Índices para tabela `documentos`
--
ALTER TABLE `documentos`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `fornecedores`
--
ALTER TABLE `fornecedores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cnpj` (`cnpj`);

--
-- Índices para tabela `importacoes_log`
--
ALTER TABLE `importacoes_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Índices para tabela `licitacoes`
--
ALTER TABLE `licitacoes`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de tabelas despejadas
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `licitacoes`
--
ALTER TABLE `licitacoes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

-- --------------------------------------------------------

--
-- Estrutura para vista `vw_contratos`
--
DROP TABLE IF EXISTS `vw_contratos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_contratos`  AS SELECT `c`.`id` AS `id`, `c`.`numero` AS `numero`, `c`.`numero_processo` AS `numero_processo`, `c`.`licitacao_id` AS `licitacao_id`, `c`.`fornecedor_id` AS `fornecedor_id`, `c`.`fornecedor_nome` AS `fornecedor_nome`, `c`.`fornecedor_cnpj` AS `fornecedor_cnpj`, `c`.`objeto` AS `objeto`, `c`.`modalidade` AS `modalidade`, `c`.`valor_total` AS `valor_total`, `c`.`saldo_atual` AS `saldo_atual`, `c`.`data_assinatura` AS `data_assinatura`, `c`.`data_inicio` AS `data_inicio`, `c`.`data_vencimento` AS `data_vencimento`, `c`.`status_manual` AS `status_manual`, `c`.`gestor_nome` AS `gestor_nome`, `c`.`gestor_matricula` AS `gestor_matricula`, `c`.`fiscal_nome` AS `fiscal_nome`, `c`.`fiscal_matricula` AS `fiscal_matricula`, `c`.`dotacao_orcamentaria` AS `dotacao_orcamentaria`, `c`.`observacoes` AS `observacoes`, `c`.`origem` AS `origem`, `c`.`created_at` AS `created_at`, `c`.`updated_at` AS `updated_at`, (to_days(`c`.`data_vencimento`) - to_days(curdate())) AS `dias_para_vencer`, (case when (`c`.`status_manual` is not null) then `c`.`status_manual` when (`c`.`data_vencimento` < curdate()) then 'vencido' when ((to_days(`c`.`data_vencimento`) - to_days(curdate())) <= 30) then 'critico' when ((to_days(`c`.`data_vencimento`) - to_days(curdate())) <= 90) then 'atencao' when ((to_days(`c`.`data_vencimento`) - to_days(curdate())) <= 180) then 'alerta' else 'regular' end) AS `status_vencimento`, coalesce(`f`.`razao_social`,`c`.`fornecedor_nome`) AS `fornecedor_display`, coalesce(`f`.`cnpj`,`c`.`fornecedor_cnpj`) AS `cnpj_display`, (`c`.`valor_total` - `c`.`saldo_atual`) AS `valor_executado`, round((((`c`.`valor_total` - `c`.`saldo_atual`) / `c`.`valor_total`) * 100),1) AS `percentual_executado` FROM (`contratos` `c` left join `fornecedores` `f` on((`f`.`id` = `c`.`fornecedor_id`))) ;

-- --------------------------------------------------------

--
-- Estrutura para vista `vw_dashboard_resumo`
--
DROP TABLE IF EXISTS `vw_dashboard_resumo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_dashboard_resumo`  AS SELECT count(0) AS `total_contratos`, sum((case when ((`contratos`.`data_vencimento` < curdate()) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `vencidos`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 0 and 30) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `criticos`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 31 and 90) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `atencao`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) between 91 and 180) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `alerta`, sum((case when (((to_days(`contratos`.`data_vencimento`) - to_days(curdate())) > 180) and (`contratos`.`status_manual` is null)) then 1 else 0 end)) AS `regulares`, sum(`contratos`.`valor_total`) AS `valor_total_carteira`, sum(`contratos`.`saldo_atual`) AS `saldo_total_carteira` FROM `contratos` WHERE ((`contratos`.`status_manual` not in ('encerrado','rescindido')) OR (`contratos`.`status_manual` is null)) ;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `aditivos`
--
ALTER TABLE `aditivos`
  ADD CONSTRAINT `aditivos_ibfk_1` FOREIGN KEY (`contrato_id`) REFERENCES `contratos` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `contratos`
--
ALTER TABLE `contratos`
  ADD CONSTRAINT `contratos_ibfk_1` FOREIGN KEY (`licitacao_id`) REFERENCES `licitacoes` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `contratos_ibfk_2` FOREIGN KEY (`fornecedor_id`) REFERENCES `fornecedores` (`id`) ON DELETE SET NULL;

--
-- Limitadores para a tabela `importacoes_log`
--
ALTER TABLE `importacoes_log`
  ADD CONSTRAINT `importacoes_log_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
