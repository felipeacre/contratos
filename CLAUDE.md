# CLAUDE.md — Contratos IDAF/AC

Guia de contexto para o agente Claude Code trabalhar neste repositório.

---

## O que é este projeto

Sistema web de **controle de contratos administrativos** do Instituto de Defesa Agropecuária e Florestal do Acre (IDAF/AC).

Permite cadastrar, acompanhar e alertar sobre contratos próximos do vencimento, com dashboard em tempo real otimizado para exibição em TV.

---

## Stack tecnológica

| Camada       | Tecnologia                          |
|--------------|-------------------------------------|
| Back-end     | PHP 8.1+ (sem framework)            |
| Banco        | MySQL 8.0 via PDO                   |
| Front-end    | Bootstrap 5.3 + DataTables + JS puro|
| Upload PDF   | Python 3.8+ com `pdfplumber`        |
| Dependências | Composer (`phpoffice/phpspreadsheet`)|
| Dev local    | Laragon (Windows) ou Docker         |

---

## Estrutura de pastas

```
contratos/
├── assets/
│   ├── css/app.css          # Estilos globais + seção TV (comentário /* DASHBOARD TV */)
│   └── js/app.js            # JS global: initTvClock, initTvCarousel, initTvRefresh, updateTvData
├── config/
│   ├── config.php           # Constantes globais (DB, paths, faixas de alerta)
│   └── Database.php         # Singleton PDO
├── includes/
│   ├── bootstrap.php        # Entry-point: carrega config + sessão
│   ├── helpers.php          # Funções utilitárias (sanitize, etc.)
│   └── Auth.php             # Controle de sessão/login
├── modules/
│   ├── dashboard/
│   │   ├── index.php        # Dashboard principal (admin)
│   │   └── tv.php           # Painel TV (tela cheia, sem login)
│   ├── contratos/           # CRUD de contratos
│   ├── licitacoes/          # CRUD de licitações
│   ├── importacao/          # Import Excel/PDF
│   └── usuarios/            # Gestão de usuários
├── python/
│   └── extrator_pdf.py      # Extração de dados de PDF via pdfplumber
├── sql/
│   └── schema.sql           # DDL completo (tabelas + views + triggers)
├── uploads/
│   ├── pdfs/                # PDFs de contratos enviados
│   └── imports/             # Arquivos de importação temporários
├── Dockerfile
├── docker-compose.yml
└── composer.json
```

---

## Como rodar localmente

### Com Docker (recomendado)

```bash
# 1. Sobe todos os serviços (app + MySQL + phpMyAdmin)
docker compose up -d --build

# 2. Acesse
#    Sistema:     http://localhost:8080/contratos
#    phpMyAdmin:  http://localhost:8081
#    MySQL:       localhost:3307 (user: root / pass: root)

# 3. Para derrubar
docker compose down
```

O banco é inicializado automaticamente com `sql/schema.sql` na primeira execução.

### Com Laragon (Windows dev)

```
1. Clonar em C:\laragon\www\contratos
2. composer install
3. Criar banco: contratos_idaf
4. Rodar: sql/schema.sql
5. Acessar: http://localhost/contratos
```

---

## Variáveis de ambiente (Docker)

Configuradas no `docker-compose.yml` e lidas em `config/config.php`:

| Variável  | Padrão local | Valor Docker |
|-----------|-------------|--------------|
| `DB_HOST` | localhost   | db           |
| `DB_NAME` | contratos_idaf | contratos_idaf |
| `DB_USER` | root        | root         |
| `DB_PASS` | *(vazio)*   | root         |

---

## Painel TV (`modules/dashboard/tv.php`)

Página dedicada para exibição em televisão. Acesso sem autenticação.

- **Rota:** `/contratos/modules/dashboard/tv.php`
- **Atualização:** JSON automático a cada 60s via `initTvRefresh()`
- **Carrossel:** `initTvCarousel(id, intervaloMs, itensPorPagina)` — troca de páginas sem animação
- **3 seções:** CRÍTICOS (≤30d) · ATENÇÃO (31–90d) · TRANQUILO (>90d)
- **Cards:** número do contrato + fornecedor (max 25 chars) + badge de dias

Para mudar o tempo de troca das páginas do carrossel, editar os parâmetros em `tv.php`:

```javascript
initTvCarousel('tv-scroll-criticos',  8000, 6);  // 8s, 6 itens/página
initTvCarousel('tv-scroll-atencao',   9000, 6);
initTvCarousel('tv-scroll-tranquilo', 10000, 6);
```

---

## Banco de dados

- **View principal:** `vw_contratos` — já calcula `dias_para_vencer` e `status_vencimento`
- **Status possíveis:** `vencido` · `critico` · `atencao` · `alerta` · `regular`
- **Faixas:** definidas em `config.php` como `DIAS_CRITICO=30`, `DIAS_ATENCAO=90`, `DIAS_ALERTA=180`

---

## Comandos úteis

```bash
# Rebuild apenas o container da aplicação
docker compose up -d --build app

# Ver logs em tempo real
docker compose logs -f app

# Acessar shell do container
docker compose exec app bash

# Rodar script Python manualmente
docker compose exec app python3 python/extrator_pdf.py

# Dump do banco
docker compose exec db mysqldump -uroot -proot contratos_idaf > backup.sql
```

---

## Convenções do código

- Sem framework — PHP puro com includes manuais
- Toda saída HTML passa por `sanitize()` (htmlspecialchars wrapper)
- Queries via PDO com prepared statements
- CSS TV fica na seção `/* DASHBOARD TV */` do `assets/css/app.css`
- JS TV fica no bloco `/* ── TV ── */` do `assets/js/app.js`
- Não usar `echo` direto em HTML — usar `<?= sanitize(...) ?>`
