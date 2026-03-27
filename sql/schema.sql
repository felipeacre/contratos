-- ============================================================
-- SISTEMA DE CONTROLE DE CONTRATOS ADMINISTRATIVOS
-- IDAF/AC — Schema MySQL
-- ============================================================

CREATE DATABASE IF NOT EXISTS contratos_idaf
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE contratos_idaf;

-- ------------------------------------------------------------
-- USUÁRIOS
-- ------------------------------------------------------------
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    nivel ENUM('admin', 'visualizador') NOT NULL DEFAULT 'visualizador',
    ativo TINYINT(1) NOT NULL DEFAULT 1,
    ultimo_acesso DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO usuarios (nome, email, senha_hash, nivel) VALUES
('Administrador', 'admin@idaf.ac.gov.br', '$2y$12$placeholder_trocar_no_primeiro_login', 'admin');

-- ------------------------------------------------------------
-- FORNECEDORES (tabela auxiliar para evitar duplicidade)
-- ------------------------------------------------------------
CREATE TABLE fornecedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255) NULL,
    cnpj CHAR(18) NOT NULL UNIQUE,
    telefone VARCHAR(20) NULL,
    email VARCHAR(150) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- LICITAÇÕES
-- ------------------------------------------------------------
CREATE TABLE licitacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_processo VARCHAR(50) NOT NULL,
    numero_licitacao VARCHAR(50) NULL,
    objeto TEXT NOT NULL,
    modalidade ENUM(
        'pregao_eletronico',
        'pregao_presencial',
        'concorrencia',
        'tomada_de_precos',
        'convite',
        'dispensa',
        'inexigibilidade',
        'chamamento_publico'
    ) NOT NULL,
    status ENUM(
        'em_andamento',
        'aguardando_homologacao',
        'homologada',
        'deserta',
        'fracassada',
        'cancelada',
        'suspensa'
    ) NOT NULL DEFAULT 'em_andamento',
    valor_estimado DECIMAL(15,2) NULL,
    data_abertura DATE NULL,
    data_prevista_conclusao DATE NULL,
    data_homologacao DATE NULL,
    responsavel VARCHAR(150) NULL,
    link_portal VARCHAR(500) NULL,
    observacoes TEXT NULL,
    origem ENUM('manual', 'importacao', 'pdf') NOT NULL DEFAULT 'manual',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- CONTRATOS
-- ------------------------------------------------------------
CREATE TABLE contratos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL,
    numero_processo VARCHAR(50) NULL,
    licitacao_id INT NULL,
    fornecedor_id INT NULL,
    -- fallback caso fornecedor não esteja cadastrado
    fornecedor_nome VARCHAR(255) NULL,
    fornecedor_cnpj CHAR(18) NULL,
    objeto TEXT NOT NULL,
    modalidade ENUM(
        'pregao_eletronico',
        'pregao_presencial',
        'concorrencia',
        'tomada_de_precos',
        'convite',
        'dispensa',
        'inexigibilidade',
        'chamamento_publico'
    ) NULL,
    valor_total DECIMAL(15,2) NOT NULL,
    saldo_atual DECIMAL(15,2) NOT NULL,
    data_assinatura DATE NOT NULL,
    data_inicio DATE NOT NULL,
    data_vencimento DATE NOT NULL,
    -- status calculado em runtime, mas pode ser sobrescrito manualmente
    status_manual ENUM('ativo', 'encerrado', 'suspenso', 'rescindido') NULL,
    gestor_nome VARCHAR(150) NULL,
    gestor_matricula VARCHAR(50) NULL,
    fiscal_nome VARCHAR(150) NULL,
    fiscal_matricula VARCHAR(50) NULL,
    dotacao_orcamentaria VARCHAR(100) NULL,
    observacoes TEXT NULL,
    origem ENUM('manual', 'importacao', 'pdf') NOT NULL DEFAULT 'manual',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (licitacao_id) REFERENCES licitacoes(id) ON DELETE SET NULL,
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- ADITIVOS (histórico de alterações do contrato)
-- ------------------------------------------------------------
CREATE TABLE aditivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    contrato_id INT NOT NULL,
    numero_aditivo VARCHAR(50) NOT NULL,
    tipo ENUM('prazo', 'valor', 'prazo_e_valor', 'objeto', 'rescisao') NOT NULL,
    data_assinatura DATE NOT NULL,
    nova_data_vencimento DATE NULL,
    valor_acrescimo DECIMAL(15,2) NULL DEFAULT 0.00,
    valor_reducao DECIMAL(15,2) NULL DEFAULT 0.00,
    justificativa TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contrato_id) REFERENCES contratos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- DOCUMENTOS (PDFs vinculados)
-- ------------------------------------------------------------
CREATE TABLE documentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('contrato', 'licitacao', 'aditivo') NOT NULL,
    referencia_id INT NOT NULL,
    nome_original VARCHAR(255) NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    caminho VARCHAR(500) NOT NULL,
    tamanho_kb INT NULL,
    origem ENUM('manual', 'importacao', 'pdf_diario') NOT NULL DEFAULT 'manual',
    dados_extraidos JSON NULL, -- dados brutos extraídos pelo Python
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- LOG DE IMPORTAÇÕES
-- ------------------------------------------------------------
CREATE TABLE importacoes_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('csv', 'excel', 'pdf') NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    total_linhas INT NOT NULL DEFAULT 0,
    importados INT NOT NULL DEFAULT 0,
    erros INT NOT NULL DEFAULT 0,
    detalhes_erros JSON NULL,
    usuario_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- VIEWS ÚTEIS
-- ------------------------------------------------------------

-- View de contratos com status calculado automaticamente
CREATE OR REPLACE VIEW vw_contratos AS
SELECT
    c.*,
    DATEDIFF(c.data_vencimento, CURDATE()) AS dias_para_vencer,
    CASE
        WHEN c.status_manual IS NOT NULL THEN c.status_manual
        WHEN c.data_vencimento < CURDATE() THEN 'vencido'
        WHEN DATEDIFF(c.data_vencimento, CURDATE()) <= 30  THEN 'critico'
        WHEN DATEDIFF(c.data_vencimento, CURDATE()) <= 90  THEN 'atencao'
        WHEN DATEDIFF(c.data_vencimento, CURDATE()) <= 180 THEN 'alerta'
        ELSE 'regular'
    END AS status_vencimento,
    COALESCE(f.razao_social, c.fornecedor_nome) AS fornecedor_display,
    COALESCE(f.cnpj, c.fornecedor_cnpj) AS cnpj_display,
    (c.valor_total - c.saldo_atual) AS valor_executado,
    ROUND((c.valor_total - c.saldo_atual) / c.valor_total * 100, 1) AS percentual_executado
FROM contratos c
LEFT JOIN fornecedores f ON f.id = c.fornecedor_id;

-- View de resumo para dashboard
CREATE OR REPLACE VIEW vw_dashboard_resumo AS
SELECT
    COUNT(*) AS total_contratos,
    SUM(CASE WHEN data_vencimento < CURDATE() AND status_manual IS NULL THEN 1 ELSE 0 END) AS vencidos,
    SUM(CASE WHEN DATEDIFF(data_vencimento, CURDATE()) BETWEEN 0 AND 30  AND status_manual IS NULL THEN 1 ELSE 0 END) AS criticos,
    SUM(CASE WHEN DATEDIFF(data_vencimento, CURDATE()) BETWEEN 31 AND 90 AND status_manual IS NULL THEN 1 ELSE 0 END) AS atencao,
    SUM(CASE WHEN DATEDIFF(data_vencimento, CURDATE()) BETWEEN 91 AND 180 AND status_manual IS NULL THEN 1 ELSE 0 END) AS alerta,
    SUM(CASE WHEN DATEDIFF(data_vencimento, CURDATE()) > 180 AND status_manual IS NULL THEN 1 ELSE 0 END) AS regulares,
    SUM(valor_total) AS valor_total_carteira,
    SUM(saldo_atual) AS saldo_total_carteira
FROM contratos
WHERE status_manual NOT IN ('encerrado', 'rescindido') OR status_manual IS NULL;
