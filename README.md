# Controle de Contratos Administrativos — IDAF/AC

Sistema web para gestão de contratos administrativos e licitações,
com dashboard em tempo real para exibição em televisão.

---

## Stack

- **PHP 8.1+** (puro, sem framework)
- **MySQL 8.0+**
- **Bootstrap 5.3**
- **DataTables**
- **Python 3.8+** + pdfplumber (extração de PDF)
- **PhpSpreadsheet** (importação Excel)

---

## Instalação

### 1. Pré-requisitos

- XAMPP (Windows) ou Apache + PHP + MySQL (Linux)
- PHP com extensões: `pdo_mysql`, `mbstring`, `fileinfo`, `json`
- Composer
- Python 3 + pip

### 2. Clonar / copiar o projeto

```
/xampp/htdocs/contratos/        (Windows)
/var/www/html/contratos/        (Linux)
```

### 3. Banco de dados

```sql
-- No MySQL / phpMyAdmin:
SOURCE /caminho/para/sql/schema.sql;
```

Ou pelo terminal:
```bash
mysql -u root -p < sql/schema.sql
```

### 4. Configurar

Edite `config/config.php`:
```php
define('BASE_URL', 'http://localhost/contratos');  // ou IP da rede
define('DB_USER', 'root');
define('DB_PASS', 'sua_senha');
```

### 5. Instalar dependências PHP (para importação Excel)

```bash
cd /caminho/contratos
composer require phpoffice/phpspreadsheet
```

### 6. Instalar dependência Python (para extração de PDF)

```bash
pip install pdfplumber
# ou
pip3 install pdfplumber
```

Se o Python não estiver no PATH, ajuste `PYTHON_BIN` em `config/config.php`:
```php
define('PYTHON_BIN', '/usr/bin/python3');
```

### 7. Permissões (Linux)

```bash
chmod 755 uploads/pdfs uploads/imports
chown -R www-data:www-data uploads/
```

### 8. Primeiro acesso

- URL: `http://localhost/contratos/login.php`
- E-mail: `admin@idaf.ac.gov.br`
- **Senha padrão: altere imediatamente!**

Para definir a senha do admin:
```bash
php -r "echo password_hash('sua_nova_senha', PASSWORD_DEFAULT);"
```
Copie o hash gerado e execute no MySQL:
```sql
UPDATE usuarios SET senha_hash = 'hash_gerado' WHERE email = 'admin@idaf.ac.gov.br';
```

---

## Dashboard TV

Acesso público (sem login):
```
http://IP_DO_SERVIDOR/contratos/modules/dashboard/tv.php
```

Coloque essa URL em modo quiosque/tela cheia no browser da TV:
- **Chrome**: `chrome --kiosk http://...`
- **Firefox**: F11 após abrir a URL

Atualiza automaticamente a cada **60 segundos**.

---

## Importação de dados

### Planilha Excel/CSV

Colunas esperadas para **contratos**:
| Coluna | Obrigatório |
|---|---|
| numero | ✅ |
| objeto | ✅ |
| data_vencimento (dd/mm/yyyy) | ✅ |
| fornecedor | |
| cnpj | |
| valor_total | |
| saldo | |
| data_assinatura | |
| data_inicio | |

Colunas para **licitações**:
| Coluna | Obrigatório |
|---|---|
| numero_processo | ✅ |
| objeto | ✅ |
| modalidade | |
| status | |
| valor_estimado | |
| data_abertura | |

### PDF do Diário Oficial (DOAC)

O sistema usa `python/extrator_doac.py` — calibrado no layout real do DOAC.

**Dois cenários suportados:**

| Cenário | Onde fica no DOAC | O que extrai |
|---|---|---|
| Seção IDAF | Seção própria com separador `IDAF` | Portarias (gestor/fiscal), inexigibilidades, aditivos, extratos de contrato |
| Seção SEAD/SELIC | Páginas de avisos de licitação (layout 2 colunas) | Avisos de pregão, reabertura de prazo, prorrogação |

**Uso via linha de comando:**
```bash
# Tudo do IDAF (seção própria + licitações SEAD)
python3 extrator_doac.py diario.pdf --modo ambos --orgao IDAF

# Só portarias, aditivos, inexigibilidades
python3 extrator_doac.py diario.pdf --modo idaf

# Só avisos de licitação na seção SEAD
python3 extrator_doac.py diario.pdf --modo sead --orgao IDAF
```

**Via interface web:** Menu Importar → Importar do Diário Oficial

O script detecta automaticamente páginas de 2 colunas (layout SEAD/SELIC) e
extrai cada coluna separadamente para evitar mistura de texto entre avisos.

---

## Estrutura de pastas

```
contratos/
├── config/
│   ├── config.php          # Configurações
│   └── Database.php        # Conexão PDO
├── includes/
│   ├── bootstrap.php       # Autoload
│   ├── Auth.php            # Autenticação
│   ├── helpers.php         # Funções utilitárias
│   ├── header.php          # Layout header
│   └── footer.php          # Layout footer
├── modules/
│   ├── contratos/          # CRUD contratos + aditivos
│   ├── licitacoes/         # CRUD licitações
│   ├── importacao/
│   │   ├── index.php           # Hub de importação
│   │   ├── confirmar_pdf.php   # Revisão de contrato extraído
│   │   └── importar_doac.php   # Importação do Diário Oficial
│   ├── dashboard/          # Dashboard TV (público)
│   └── usuarios/           # Gestão de usuários
├── assets/
│   ├── css/app.css
│   └── js/app.js
├── uploads/
│   ├── pdfs/               # PDFs enviados
│   └── imports/            # Planilhas temporárias
├── python/
│   └── extrator_doac.py    # Extrator DOAC (seção IDAF + SEAD/SELIC)
├── sql/
│   └── schema.sql          # Schema MySQL completo
├── login.php
├── logout.php
├── index.php               # Painel de gestão
└── README.md
```

---

## Faixas de alerta

| Cor | Status | Critério |
|---|---|---|
| 🔴 Vermelho | Vencido | data_vencimento < hoje |
| 🟠 Laranja | Crítico | vence em até 30 dias |
| 🟡 Amarelo | Atenção | vence em até 90 dias |
| 🔵 Azul | Alerta | vence em até 180 dias |
| 🟢 Verde | Regular | vence em mais de 180 dias |

---

## Próximos passos sugeridos

- [ ] Alertas por e-mail (PHPMailer + cron job)
- [ ] Relatório PDF de contratos por período
- [ ] Módulo de fornecedores com cadastro completo
- [ ] Exportação Excel dos relatórios
- [ ] OCR para PDFs escaneados (Tesseract)
