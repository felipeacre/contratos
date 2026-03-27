#!/usr/bin/env python3
"""
extrator_doac.py — Extrator do Diário Oficial do Acre calibrado para o IDAF
===========================================================================
Estratégia:
  1. Extrai todo o texto do PDF
  2. Localiza a(s) seção(ões) do IDAF pelo separador de órgão
  3. Dentro de cada seção, identifica os blocos de publicação por tipo:
       - Portaria (designação de gestor/fiscal)
       - Termo de Ratificação de Inexigibilidade
       - Extrato de Termo Aditivo
       - Aviso de Licitação / Aviso de Pregão
       - Contrato completo
  4. Extrai campos de cada bloco com regex calibrados no layout real
  5. Retorna JSON com listas separadas por tipo

Uso:
    python3 extrator_doac.py <caminho.pdf>
    python3 extrator_doac.py <caminho.pdf> --tipo contratos
    python3 extrator_doac.py <caminho.pdf> --tipo licitacoes
    python3 extrator_doac.py <caminho.pdf> --tipo todos   (padrão)
"""

import sys
import re
import json
import argparse
import os

try:
    import pdfplumber
except ImportError:
    print(json.dumps({
        "erro": "pdfplumber não instalado. Execute: pip install pdfplumber"
    }))
    sys.exit(1)


# ─────────────────────────────────────────────
# Padrões de separador de órgão no DOAC
# O órgão aparece como linha isolada em caixa alta entre publicações
# Ex: "\nIDAF\n" ou "\nIAPEN\n" etc.
# ─────────────────────────────────────────────
SEPARADORES_IDAF = [
    r'\nIDAF\n',
    r'\nIDAF/AC\n',
    r'\nINSTITUTO DE DEFESA AGROPECU[AÁ]RIA E FLORESTAL\s*[-–]\s*IDAF\n',
    r'\nINSTITUTO DE DEFESA AGROPECU[AÁ]RIA E FLORESTAL DO (ESTADO DO )?ACRE\s*[-–]\s*IDAF\n',
]

# Padrão para detectar início de OUTRO órgão (termina a seção do IDAF)
# Linhas isoladas de 3-10 chars em caixa alta = separador de órgão no DOAC
SEPARADOR_OUTRO_ORGAO = re.compile(
    r'\n([A-Z][A-Z0-9/]{2,15})\n(?!Portaria|Art\.|O PRESIDENTE|O INSTITUTO)',
    re.MULTILINE
)

# Limpeza de cabeçalho de página ("137\n137 Terça-feira...")
CABECALHO_PAGINA = re.compile(
    r'\d{1,4}\n\d{1,4}\s+(?:Segunda|Terça|Quarta|Quinta|Sexta|Sábado|Domingo)-feira.*?DIÁRIO OFICIAL\s*\n',
    re.IGNORECASE
)

MESES = {
    'janeiro':1,'fevereiro':2,'março':3,'abril':4,'maio':5,'junho':6,
    'julho':7,'agosto':8,'setembro':9,'outubro':10,'novembro':11,'dezembro':12,
    'marco':3,'maco':3,
}

MODALIDADE_MAP = {
    'pregão eletrônico':    'pregao_eletronico',
    'pregao eletronico':    'pregao_eletronico',
    'pregão presencial':    'pregao_presencial',
    'pregao presencial':    'pregao_presencial',
    'concorrência':         'concorrencia',
    'concorrencia':         'concorrencia',
    'tomada de preços':     'tomada_de_precos',
    'tomada de precos':     'tomada_de_precos',
    'dispensa':             'dispensa',
    'inexigibilidade':      'inexigibilidade',
    'chamamento público':   'chamamento_publico',
    'chamamento publico':   'chamamento_publico',
    'credenciamento':       'chamamento_publico',
}


# ─────────────────────────────────────────────
# UTILITÁRIOS
# ─────────────────────────────────────────────

def detectar_duas_colunas(pg) -> bool:
    """
    Heurística: se houver palavras suficientes em ambas as metades da página
    é layout 2 colunas. O DOAC usa 2 colunas em páginas de avisos da SEAD/SELIC.
    """
    try:
        palavras = pg.extract_words()
        if not palavras or len(palavras) < 20:
            return False
        x_centro = pg.width / 2
        esq = sum(1 for w in palavras if w['x0'] < x_centro)
        dir_ = sum(1 for w in palavras if w['x0'] > x_centro)
        total = esq + dir_
        return total > 20 and min(esq, dir_) / total > 0.25
    except Exception:
        return False


def extrair_texto_pagina(pg) -> str:
    """Extrai texto de uma página, tratando layout de 2 colunas quando necessário."""
    if detectar_duas_colunas(pg):
        largura = pg.width
        col_esq = pg.crop((0, 0, largura / 2, pg.height)).extract_text() or ""
        col_dir = pg.crop((largura / 2, 0, largura, pg.height)).extract_text() or ""
        return col_esq + "\n" + col_dir
    return pg.extract_text() or ""


def extrair_texto_pdf(caminho: str, forcar_1col: bool = False) -> str:
    """
    Extrai texto do PDF.
    forcar_1col=True: ignora detecção de 2 colunas (use para seção IDAF onde o
    separador "\nIDAF\n" pode ser quebrado pela divisão de colunas).
    forcar_1col=False (padrão): detecta e trata 2 colunas automaticamente (use para SEAD).
    """
    texto = ""
    with pdfplumber.open(caminho) as pdf:
        for pg in pdf.pages:
            if forcar_1col:
                t = pg.extract_text() or ""
            else:
                t = extrair_texto_pagina(pg)
            if t:
                texto += t + "\n"
    return texto


def limpar_cabecalhos(texto: str) -> str:
    """Remove cabeçalhos repetidos de página e desfaz hifenização de fim de linha."""
    texto = CABECALHO_PAGINA.sub('\n', texto)
    # Desfaz hifenização: "empre-\nsa" → "empresa"
    texto = re.sub(r'-\n(\w)', r'\1', texto)
    # Normaliza pontos substituídos por caracteres especiais em fontes PDF
    # U+FFFD (replacement char), U+00B7 (ponto centrado) → ponto normal
    texto = re.sub(r'[\ufffd\u00b7]', '.', texto)
    # Colapsa "PREÇOS\nNº" → "PREÇOS Nº" (layout antigo do DOAC)
    texto = re.sub(r'(PREÇO[S]?)\n(N[Oº°])', r'\1 \2', texto)
    return texto


def normalizar_data(s: str | None) -> str | None:
    if not s:
        return None
    s = s.strip()
    # dd/mm/yyyy
    m = re.match(r'(\d{1,2})/(\d{2})/(\d{4})', s)
    if m:
        return f"{m.group(3)}-{m.group(2).zfill(2)}-{m.group(1).zfill(2)}"
    # dd de mês de yyyy
    m = re.match(r'(\d{1,2})\s+de\s+(\w+)\s+de\s+(\d{4})', s, re.IGNORECASE)
    if m:
        mes = MESES.get(m.group(2).lower().strip())
        if mes:
            return f"{m.group(3)}-{str(mes).zfill(2)}-{m.group(1).zfill(2)}"
    # yyyy-mm-dd (já normalizado)
    if re.match(r'\d{4}-\d{2}-\d{2}', s):
        return s
    return None


def normalizar_cnpj(s: str | None) -> str | None:
    if not s:
        return None
    d = re.sub(r'\D', '', s)
    if len(d) == 14:
        return f"{d[:2]}.{d[2:5]}.{d[5:8]}/{d[8:12]}-{d[12:]}"
    return s


def normalizar_valor(s: str | None) -> float | None:
    if not s:
        return None
    # Remove R$, pontos de milhar, troca vírgula por ponto
    v = re.sub(r'R\$\s*', '', s)
    v = re.sub(r'\.(?=\d{3})', '', v)
    v = v.replace(',', '.').strip()
    try:
        return float(v)
    except ValueError:
        return None


def normalizar_modalidade(s: str | None) -> str:
    if not s:
        return 'dispensa'
    key = s.lower().strip()
    for k, v in MODALIDADE_MAP.items():
        if k in key:
            return v
    return 'dispensa'


def primeiro_match(texto: str, patterns: list, flags=re.IGNORECASE | re.DOTALL) -> str | None:
    for p in patterns:
        m = re.search(p, texto, flags)
        if m:
            return m.group(1).strip()
    return None


def todos_matches(texto: str, pattern: str, grupo=1, flags=re.IGNORECASE) -> list:
    return [m.group(grupo).strip() for m in re.finditer(pattern, texto, flags)]


# ─────────────────────────────────────────────
# LOCALIZAR SEÇÃO DO IDAF
# ─────────────────────────────────────────────

def localizar_secoes_idaf(texto: str) -> list[str]:
    """
    Retorna lista de trechos de texto correspondentes às seções do IDAF.
    O DOAC pode ter o IDAF aparecendo mais de uma vez no mesmo dia (raro, mas possível).
    """
    secoes = []

    for sep_pattern in SEPARADORES_IDAF:
        for m in re.finditer(sep_pattern, texto, re.IGNORECASE):
            inicio = m.end()

            # Encontra o próximo separador de órgão
            # Procura linha isolada em caixa alta com 3-20 chars após o início da seção IDAF
            fim = len(texto)
            for m2 in re.finditer(
                r'\n([A-ZÁÉÍÓÚÀÂÊÔÃÕÜÇ][A-ZÁÉÍÓÚÀÂÊÔÃÕÜÇ0-9\s/]{2,30})\n',
                texto[inicio:],
                re.MULTILINE
            ):
                candidato = m2.group(1).strip()
                # Verifica se parece um separador de órgão (não é início de parágrafo normal)
                if (len(candidato) <= 25 and
                    candidato.isupper() and
                    candidato not in ('DO OBJETO', 'DO VALOR', 'DA VIGÊNCIA', 'RESOLVE',
                                      'DAS PARTES', 'CONTRATANTE', 'CONTRATADO') and
                    'IDAF' not in candidato):
                    fim = inicio + m2.start()
                    break

            secao = texto[inicio:fim].strip()
            if len(secao) > 100:  # ignora seções vazias
                secoes.append(secao)

    return secoes


# ─────────────────────────────────────────────
# DIVIDIR SEÇÃO EM BLOCOS DE PUBLICAÇÃO
# ─────────────────────────────────────────────

# Marcadores de início de cada tipo de publicação
INICIO_BLOCO = re.compile(
    r'(?=Portaria IDAF\s+N[Oº°]|'
    r'TERMO DE RATIFICA[ÇC][ÃA]O|'
    r'EXTRATO D[OA]\s+(?:\w+\s+)*TERMO ADITIVO|'
    r'EXTRATO DE CONTRATO|'
    r'AVISO DE LICITA[ÇC][ÃA]O|'
    r'AVISO DE PREG[ÃA]O|'
    r'EDITAL DE PREG[ÃA]O|'
    r'EDITAL DE LICITA[ÇC][ÃA]O|'
    r'CONTRATO N[Oº°])',
    re.IGNORECASE
)


def dividir_em_blocos(secao: str) -> list[str]:
    """Divide a seção do IDAF em blocos individuais de publicação."""
    posicoes = [m.start() for m in INICIO_BLOCO.finditer(secao)]
    if not posicoes:
        return [secao]
    blocos = []
    for i, pos in enumerate(posicoes):
        fim = posicoes[i+1] if i+1 < len(posicoes) else len(secao)
        blocos.append(secao[pos:fim].strip())
    return blocos


# ─────────────────────────────────────────────
# CLASSIFICAR BLOCO
# ─────────────────────────────────────────────

def classificar_bloco(bloco: str) -> str:
    bl = bloco[:200].upper()
    if re.search(r'PORTARIA IDAF', bl):         return 'portaria'
    if re.search(r'TERMO DE RATIFICA', bl):      return 'inexigibilidade'
    if re.search(r'TERMO ADITIVO', bl):          return 'aditivo'
    if re.search(r'EXTRATO DE CONTRATO', bl):    return 'contrato_extrato'
    if re.search(r'AVISO DE (LICITA|PREG)', bl): return 'licitacao_aviso'
    if re.search(r'EDITAL DE (LICITA|PREG)', bl):return 'licitacao_edital'
    if re.search(r'^CONTRATO N', bl):            return 'contrato_completo'
    return 'outros'


# ─────────────────────────────────────────────
# EXTRATORES POR TIPO
# ─────────────────────────────────────────────

def extrair_portaria(bloco: str) -> dict:
    """
    Portaria de designação de gestor/fiscal.
    Contém: número da portaria, número do contrato, empresa, objeto, processo SEI,
    gestor titular, fiscal titular.
    Exemplo real:
      Portaria IDAF Nº 95, DE 16 DE março DE 2026
      ...contratos nº 089/2023 celebrado entre ... e a Empresa KOA TURISMO...
      ...objeto: Contratação de...  Processo SEI de nº 0052.007858.00161/2023-97
    """
    r = {
        'tipo_publicacao': 'portaria',
        'numero_portaria': None,
        'data_portaria': None,
        'numero_contrato': None,
        'empresa': None,
        'cnpj_empresa': None,
        'data_assinatura_contrato': None,
        'objeto': None,
        'processo_sei': None,
        'gestor_titular': None,
        'gestor_substituto': None,
        'fiscal_titular': None,
        'fiscal_substituto': None,
    }

    # Número e data da portaria
    m = re.search(
        r'Portaria IDAF\s+N[Oº°]?\s*([\d]+)[,\s]+DE\s+(\d{1,2}\s+DE\s+\w+\s+DE\s+\d{4})',
        bloco, re.IGNORECASE
    )
    if m:
        r['numero_portaria'] = m.group(1).strip()
        r['data_portaria'] = normalizar_data(m.group(2))

    # Número do contrato
    r['numero_contrato'] = primeiro_match(bloco, [
        r'contratos?\s+n[Oº°]?\s*([\d]+/\d{4})',
        r'contrato\s+n[Oº°]?\s*([\d]+/\d{4})',
    ])

    # Empresa contratada e data de assinatura
    m = re.search(
        r'(?:Empresa|empresa)\s+(.+?)[,\s]+(?:assinado|o referido contrato foi assinado)\s+no dia\s+(\d{2}/\d{2}/\d{4})',
        bloco, re.IGNORECASE | re.DOTALL
    )
    if m:
        r['empresa'] = re.sub(r'\s+', ' ', m.group(1)).strip()
        r['data_assinatura_contrato'] = normalizar_data(m.group(2))

    # Objeto (após "objeto:")  — usa ponto final ou 2 quebras de linha como fim
    m = re.search(
        r'objeto:\s*(.+?)(?:Processo SEI|processo SEI|\n{2,}|I\s*[–-]\s*Gestor)',
        bloco, re.IGNORECASE | re.DOTALL
    )
    if m:
        obj = re.sub(r'\s+', ' ', m.group(1)).strip()
        r['objeto'] = obj[:400]

    # Processo SEI
    r['processo_sei'] = primeiro_match(bloco, [
        r'[Pp]rocesso\s+SEI\s+(?:de\s+)?n[Oº°]?\s*([\d\.]+/[\d-]+)',
        r'SEI\s+n[Oº°]?\s*([\d\.]+/[\d-]+)',
    ])

    # CNPJ da empresa (se aparecer)
    r['cnpj_empresa'] = normalizar_cnpj(primeiro_match(bloco, [
        r'CNPJ[:/\s]+([\d]{2}[\.\s]?[\d]{3}[\.\s]?[\d]{3}[/\s]?[\d]{4}[-\s]?[\d]{2})',
    ]))

    # Gestores e fiscais
    r['gestor_titular']     = primeiro_match(bloco, [r'Gestor Titular:\s*(.+?)(?:–|-)\s*Matr'])
    r['gestor_substituto']  = primeiro_match(bloco, [r'Gestor Substituto:\s*(.+?)(?:–|-)\s*Matr'])
    r['fiscal_titular']     = primeiro_match(bloco, [r'Fiscal Titular:\s*(.+?)(?:–|-)\s*Matr'])
    r['fiscal_substituto']  = primeiro_match(bloco, [r'Fiscal Substituto:\s*(.+?)(?:–|-)\s*Matr'])

    # Limpa nomes (remove quebras de linha)
    for campo in ('gestor_titular', 'gestor_substituto', 'fiscal_titular', 'fiscal_substituto', 'empresa'):
        if r[campo]:
            r[campo] = re.sub(r'\s+', ' ', r[campo]).strip()

    return r


def extrair_inexigibilidade(bloco: str) -> dict:
    """
    Termo de Ratificação de Inexigibilidade.
    Exemplo real:
      TERMO DE RATIFICAÇÃO DE INEXIGIBILIDADE DE LICITAÇÃO
      ...Processo – SEI nº 0052.013535.00003/2026-25...
      ...contratação da empresa FullCycle Ltda, CNPJ nº 38.167.943/0001-86...
      ...no valor total de R$ 10.764,00...
      ...Rio Branco - AC 16 de Março de 2026
    """
    r = {
        'tipo_publicacao': 'inexigibilidade',
        'processo_sei': None,
        'empresa': None,
        'cnpj_empresa': None,
        'objeto': None,
        'valor_total': None,
        'data_ratificacao': None,
        'modalidade': 'inexigibilidade',
        'status': 'homologada',
    }

    r['processo_sei'] = primeiro_match(bloco, [
        r'SEI\s+n[Oº°]?\s*([\d\.]+\.[\d\.]+/[\d-]+)',
        r'[Pp]rocesso[:\s]+SEI\s+n[Oº°]?\s*([\w\.]+/[\d-]+)',
    ])

    # Empresa e CNPJ — dois padrões do DOAC:
    # 1) inline: "empresa FullCycle Ltda, CNPJ nº 38.167.943/0001-86"
    # 2) bloco: "contratação da empresa:\nFullCycle Ltda, inscrita com Cnpj/mf: ..."
    m = re.search(
        r'(?:contrata[çc][ãa]o da empresa[:\s]+|referente à contrata[çc][ãa]o da empresa\s+)'
        r'([\w][\w\s,\.&]+?)\s*[,\s]+(?:CNPJ|Cnpj)[/\s\w]*?[:\s]*([\d]{2}[\.\s]?[\d]{3}[\.\s]?[\d]{3}[/\s]?[\d]{4}[-\s]?[\d]{2})',
        bloco, re.IGNORECASE | re.DOTALL
    )
    if m:
        r['empresa'] = re.sub(r'\s+', ' ', m.group(1)).strip().rstrip(',')
        r['cnpj_empresa'] = normalizar_cnpj(m.group(2))
    else:
        # Fallback: empresa inline com CNPJ
        m = re.search(
            r'empresa\s+([\w][\w\s,\.&]+?)\s*[,\s]+(?:CNPJ|Cnpj)[/\s\w]*?[:\s]*([\d]{2}[\.\s]?[\d]{3}[\.\s]?[\d]{3}[/\s]?[\d]{4}[-\s]?[\d]{2})',
            bloco, re.IGNORECASE
        )
        if m:
            r['empresa'] = re.sub(r'\s+', ' ', m.group(1)).strip().rstrip(',')
            r['cnpj_empresa'] = normalizar_cnpj(m.group(2))

    # Objeto (o que vem após "para Contratação de" ou "objeto:")
    r['objeto'] = primeiro_match(bloco, [
        r'para\s+(Contrata[çc][ãa]o\s+de.+?)(?:\nResolve|\nRATIFICAR|$)',
        r'objeto[:\s]+(.+?)(?:\nResolve|\nRATIFICAR|CNPJ|$)',
    ])
    if r['objeto']:
        r['objeto'] = re.sub(r'\s+', ' ', r['objeto']).strip()[:400]

    r['valor_total'] = normalizar_valor(primeiro_match(bloco, [
        r'valor total de R\$\s*([\d\.,]+)',
        r'no valor de R\$\s*([\d\.,]+)',
    ]))

    # Data da ratificação
    r['data_ratificacao'] = normalizar_data(primeiro_match(bloco, [
        r'Rio Branco\s*[-,]\s*AC\s+(\d{1,2}\s+de\s+\w+\s+de\s+\d{4})',
        r'Rio Branco[,\s-]+AC[,\s]+(\d{2}/\d{2}/\d{4})',
    ]))

    return r


def extrair_aditivo(bloco: str) -> dict:
    """
    Extrato de Termo Aditivo.
    Exemplo real:
      EXTRATO DO SEXTO TERMO ADITIVO AO CONTRATO N° 47/2022
      PROCESSO Nº: 0052.007858.00018/2026-48
      DAS PARTES: IDAF E A EMPRESA JWC MULTISERVIÇOS LTDA.
      ...REPACTUAÇÃO...valor...
      LOCAL E DATA DA ASSINATURA: RIO BRANCO - AC, 13 DE MARÇO DE 2026.
    """
    r = {
        'tipo_publicacao': 'aditivo',
        'numero_aditivo_ordinal': None,
        'numero_contrato': None,
        'processo': None,
        'empresa': None,
        'tipo_aditivo': None,
        'objeto_aditivo': None,
        'valor_total_novo': None,
        'data_assinatura': None,
    }

    # "EXTRATO DO SEXTO TERMO ADITIVO AO CONTRATO N° 47/2022"
    m = re.search(
        r'EXTRATO D[OA]\s+([\w\s]+?)\s+TERMO ADITIVO\s+AO\s+CONTRATO\s+N[Oº°]\s*([\d]+/\d{4})',
        bloco, re.IGNORECASE
    )
    if m:
        r['numero_aditivo_ordinal'] = m.group(1).strip().upper()
        r['numero_contrato'] = m.group(2).strip()

    r['processo'] = primeiro_match(bloco, [
        r'PROCESSO\s+N[Oº°]?[:\s]+([\w\.]+/[\d-]+)',
    ])

    # Empresa (após "DAS PARTES: IDAF E A EMPRESA ")
    m = re.search(
        r'DAS PARTES:.+?(?:IDAF|Instituto).+?E\s+A\s+EMPRESA\s+(.+?)(?:\.|$)',
        bloco, re.IGNORECASE | re.MULTILINE
    )
    if m:
        r['empresa'] = re.sub(r'\s+', ' ', m.group(1)).strip()

    # Tipo do aditivo
    for tipo, palavras in {
        'prazo_e_valor': ['prazo e valor', 'valor e prazo'],
        'prazo':         ['prorrogação', 'prazo'],
        'valor':         ['repactuação', 'acréscimo', 'valor'],
        'rescisao':      ['rescisão', 'rescisao'],
    }.items():
        for p in palavras:
            if p.lower() in bloco.lower():
                r['tipo_aditivo'] = tipo
                break
        if r['tipo_aditivo']:
            break

    # Valor total anual (última ocorrência de TOTAL GERAL)
    matches_valor = re.findall(
        r'TOTAL GERAL.+?R\$\s*([\d\.,]+)',
        bloco, re.IGNORECASE
    )
    if matches_valor:
        r['valor_total_novo'] = normalizar_valor(matches_valor[-1])
    else:
        r['valor_total_novo'] = normalizar_valor(primeiro_match(bloco, [
            r'valor\s+(?:total|global)\s+(?:de\s+)?R\$\s*([\d\.,]+)',
        ]))

    r['data_assinatura'] = normalizar_data(primeiro_match(bloco, [
        r'(?:LOCAL E DATA|DATA)\s+DA ASSINATURA[:\s]+.+?(\d{1,2}\s+DE\s+\w+\s+DE\s+\d{4})',
        r'(?:LOCAL E DATA|DATA)\s+DA ASSINATURA[:\s]+.+?(\d{2}/\d{2}/\d{4})',
        r'Rio Branco\s*[-,]\s*AC[,\s]+(\d{1,2}\s+DE\s+\w+\s+DE\s+\d{4})',
        r'Rio Branco[,\s-]+AC[,\s]+(\d{2}/\d{2}/\d{4})',
    ]))

    return r


def extrair_licitacao_aviso(bloco: str) -> dict:
    """
    Aviso de Licitação / Aviso de Pregão — tanto da seção própria do IDAF
    quanto da seção SEAD/SELIC onde ficam licitações de todos os órgãos.
    
    Formato do cabeçalho da linha do pregão no DOAC:
      PREGÃO ELETRÔNICO SRP Nº 055/2026 – COMPRASGOV Nº 90055/2026 – CGE – 4004.017436.00106/2024-10
      PREGÃO ELETRÔNICO Nº 094/2026 - COMPRASGOV Nº 90094/2026 - PGE – SEI Nº 0056.007883.00004/2026-87
    """
    # Colapsa quebras de linha para facilitar extração de datas que quebram linha
    bloco_col = re.sub(r'\n', ' ', bloco)

    r = {
        'tipo_publicacao':    'aviso_licitacao',
        'tipo_aviso':         None,   # 'licitacao' | 'reabertura' | 'prorrogacao'
        'numero_licitacao':   None,   # ex: 055/2026
        'numero_comprasgov':  None,   # ex: 90055/2026
        'orgao':              None,   # ex: CGE, IDAF, ITERACRE
        'numero_sei':         None,   # ex: 4004.017436.00106/2024-10
        'modalidade':         'pregao_eletronico',
        'objeto':             None,
        'valor_estimado':     None,
        'data_publicacao':    None,
        'data_limite_proposta': None, # data até quando recebe propostas
        'data_prorrogada':    None,   # nova data se for prorrogação
        'link_portal':        None,
        'status':             'em_andamento',
    }

    # Tipo de aviso
    tipo_m = re.search(
        r'(AVISO DE LICITA[ÇC][ÃA]O|AVISO DE REABERTURA DE PRAZO|AVISO DE PRORROGAÇÃO DE PRAZO)',
        bloco, re.IGNORECASE
    )
    if tipo_m:
        t = tipo_m.group(1).upper()
        if 'REABERTURA' in t:   r['tipo_aviso'] = 'reabertura'
        elif 'PRORROG' in t:    r['tipo_aviso'] = 'prorrogacao'
        else:                   r['tipo_aviso'] = 'licitacao'

    # Cabeçalho do pregão — dois formatos do DOAC:
    # Formato 2023: "PREGÃO ... PELO SISTEMA DE REGISTRO DE PREÇOS\nNº 099/2023 - IDAF"
    # Formato 2026: "PREGÃO ELETRÔNICO SRP Nº 055/2026 – COMPRASGOV Nº 90055/2026 – CGE – ..."
    # Padrão unificado: busca "Nº NNN/AAAA - ORGAO" em qualquer parte do bloco
    cab = re.search(
        r'N[Oº°]\s*([\d]+/\d{4})\s*[-–]\s*'
        r'(?:COMPRASGOV\s+N[Oº°]\s*[\d]+/\d{4}\s*[-–]\s*)?'
        r'([A-Z][A-Z0-9]{1,15})',
        bloco, re.IGNORECASE
    )
    if cab:
        r['numero_licitacao'] = cab.group(1)
        orgao = cab.group(2).strip()
        r['orgao'] = orgao if orgao not in ('COMPRASGOV', 'SEI', 'SRP') else None

    # COMPRASGOV (formato 2026)
    m_cgov = re.search(r'COMPRASGOV\s+N[Oº°]\s*([\d]+/\d{4})', bloco, re.IGNORECASE)
    r['numero_comprasgov'] = m_cgov.group(1) if m_cgov else None

    # SEI — aceita pontos normais E U+FFFD/U+00B7 (chars especiais em PDFs)
    m_sei = re.search(
        r'SEI\s+N[Oº°]\s*([\d][\d\.\ufffd\u00b7]{4,}/[\d-]+)',
        bloco, re.IGNORECASE
    )
    if m_sei:
        r['numero_sei'] = re.sub(r'[\ufffd\u00b7]', '.', m_sei.group(1))


    # Objeto — captura tudo entre "Objeto:" e "Edital"
    obj_m = re.search(r'[Oo]bjeto:\s*(.+?)(?:Edital e Informa|$)', bloco_col, re.IGNORECASE)
    if obj_m:
        r['objeto'] = re.sub(r'\s+', ' ', obj_m.group(1)).strip()[:500]

    # Data de publicação/disponibilidade do edital
    pub_m = re.search(r'a partir do dia\s+(\d{2}/\d{2}/\d{4})', bloco_col, re.IGNORECASE)
    if pub_m:
        r['data_publicacao'] = normalizar_data(pub_m.group(1))

    # Data da Abertura (formato antigo DOAC 2023)
    aber_m = re.search(r'Data da Abertura:\s*(\d{2}/\d{2}/\d{4})', bloco_col, re.IGNORECASE)
    if aber_m:
        r['data_limite_proposta'] = normalizar_data(aber_m.group(1))

    # Data limite de propostas — "do dia DD/MM/YYYY" ou última data do bloco
    if not r['data_limite_proposta']:
        prop_m = re.search(r'propostas.*?dia\s+(\d{2}/\d{2}/\d{4})', bloco_col, re.IGNORECASE)
        if prop_m:
            r['data_limite_proposta'] = normalizar_data(prop_m.group(1))

    if not r['data_limite_proposta'] and not r['data_publicacao']:
        todas_datas = re.findall(r'(\d{2}/\d{2}/\d{4})', bloco_col)
        if len(todas_datas) >= 2:
            r['data_limite_proposta'] = normalizar_data(todas_datas[-1])
        elif len(todas_datas) == 1:
            r['data_publicacao'] = normalizar_data(todas_datas[0])

    # Prorrogação — nova data de abertura
    prorr = re.search(
        r'prorrogada.*?(?:para o )?dia\s+(\d{2}/\d{2}/\d{4})',
        bloco_col, re.IGNORECASE
    )
    if prorr:
        r['data_prorrogada']    = normalizar_data(prorr.group(1))
        r['data_limite_proposta'] = r['data_prorrogada']

    # Link portal
    link = re.search(r'(https?://[^\s,]+)', bloco)
    if not link:
        link = re.search(r'(www\.[^\s,]+)', bloco)
    if link:
        r['link_portal'] = link.group(1).rstrip('.')

    return r


def extrair_licitacoes_sead(texto: str, orgao_filtro: str | None = None) -> list[dict]:
    """
    Varre a seção SEAD/SELIC do DOAC e extrai TODOS os avisos de licitação,
    opcionalmente filtrando por órgão (ex: orgao_filtro='IDAF').
    
    Essa seção NÃO tem separador de órgão — os avisos de vários órgãos ficam
    misturados sob o cabeçalho SEAD/SELIC.
    
    A identificação do órgão de cada pregão vem na linha do cabeçalho:
      PREGÃO ELETRÔNICO SRP Nº 055/2026 – COMPRASGOV Nº 90055/2026 – CGE – ...
                                                                        ^^^
    """
    texto_limpo = re.sub(r'-\n(\w)', r'\1', texto)  # desfaz hifenização

    resultados = []

    # Divide em blocos por tipo de aviso
    INICIO_AVISO = re.compile(
        r'(?=AVISO DE (?:LICITA[ÇC][ÃA]O|REABERTURA DE PRAZO|PRORROGAÇÃO DE PRAZO))',
        re.IGNORECASE
    )

    posicoes = [m.start() for m in INICIO_AVISO.finditer(texto_limpo)]
    for i, pos in enumerate(posicoes):
        fim = posicoes[i+1] if i+1 < len(posicoes) else len(texto_limpo)
        bloco = texto_limpo[pos:fim].strip()

        licitacao = extrair_licitacao_aviso(bloco)

        # Filtro por órgão (case insensitive)
        if orgao_filtro:
            orgao_bloco = (licitacao.get('orgao') or '').upper()
            if orgao_filtro.upper() not in orgao_bloco:
                # Tenta também no texto do bloco (alguns não têm sigla no cabeçalho)
                if orgao_filtro.upper() not in bloco.upper():
                    continue

        resultados.append(licitacao)

    return resultados


def extrair_contrato_extrato(bloco: str) -> dict:
    """
    Extrato de contrato publicado no Diário.
    """
    r = {
        'tipo_publicacao': 'contrato_extrato',
        'numero_contrato': None,
        'processo': None,
        'empresa': None,
        'cnpj_empresa': None,
        'objeto': None,
        'modalidade': None,
        'valor_total': None,
        'data_assinatura': None,
        'data_inicio': None,
        'data_vencimento': None,
    }

    r['numero_contrato'] = primeiro_match(bloco, [
        r'EXTRATO DE CONTRATO\s+N[Oº°]\s*([\d]+/\d{4})',
        r'CONTRATO\s+N[Oº°]\s*([\d]+/\d{4})',
    ])

    r['processo'] = primeiro_match(bloco, [
        r'PROCESSO\s+N[Oº°]?[:\s]+([\w\.]+/[\d-]+)',
    ])

    # Empresa/CNPJ
    m = re.search(
        r'(?:CONTRATAD[AO]|EMPRESA)[:\s]+(.+?)[,\s]+CNPJ[:\s]+([\d\.\/\-]+)',
        bloco, re.IGNORECASE | re.DOTALL
    )
    if m:
        r['empresa'] = re.sub(r'\s+', ' ', m.group(1)).strip()
        r['cnpj_empresa'] = normalizar_cnpj(m.group(2))

    r['objeto'] = primeiro_match(bloco, [
        r'OBJETO[:\s]+(.+?)(?:VALOR|VIGÊNCIA|DATA|\n[A-Z]{4,})',
    ])
    if r['objeto']:
        r['objeto'] = re.sub(r'\s+', ' ', r['objeto']).strip()[:400]

    r['valor_total'] = normalizar_valor(primeiro_match(bloco, [
        r'VALOR[:\s]+R\$\s*([\d\.,]+)',
        r'valor\s+(?:total|global)\s+de\s+R\$\s*([\d\.,]+)',
    ]))

    r['data_assinatura'] = normalizar_data(primeiro_match(bloco, [
        r'DATA\s+(?:DE\s+)?ASSINATURA[:\s]+(\d{2}/\d{2}/\d{4})',
        r'assinado\s+em[:\s]+(\d{2}/\d{2}/\d{4})',
    ]))

    return r


# ─────────────────────────────────────────────
# ORQUESTRADOR PRINCIPAL
# ─────────────────────────────────────────────

def processar_doac(caminho: str, tipo_filtro: str = 'todos') -> dict:
    if not os.path.exists(caminho):
        return {"erro": f"Arquivo não encontrado: {caminho}"}

    try:
        texto_bruto = extrair_texto_pdf(caminho, forcar_1col=True)  # seção IDAF
    except Exception as e:
        return {"erro": f"Erro ao abrir PDF: {str(e)}"}

    if not texto_bruto.strip():
        return {"erro": "PDF sem texto extraível."}

    texto = limpar_cabecalhos(texto_bruto)

    # Localiza seções do IDAF
    secoes = localizar_secoes_idaf(texto)

    if not secoes:
        return {
            "erro": None,
            "aviso": "Nenhuma seção do IDAF encontrada neste PDF.",
            "total_chars_pdf": len(texto),
            "portarias": [],
            "inexigibilidades": [],
            "aditivos": [],
            "licitacoes": [],
            "contratos_extratos": [],
            "outros": [],
        }

    resultado = {
        "erro": None,
        "arquivo": os.path.basename(caminho),
        "secoes_idaf_encontradas": len(secoes),
        "portarias":          [],
        "inexigibilidades":   [],
        "aditivos":           [],
        "licitacoes":         [],
        "contratos_extratos": [],
        "outros":             [],
    }

    for secao in secoes:
        blocos = dividir_em_blocos(secao)
        for bloco in blocos:
            tipo = classificar_bloco(bloco)

            if tipo == 'portaria':
                resultado['portarias'].append(extrair_portaria(bloco))

            elif tipo == 'inexigibilidade':
                resultado['inexigibilidades'].append(extrair_inexigibilidade(bloco))

            elif tipo == 'aditivo':
                resultado['aditivos'].append(extrair_aditivo(bloco))

            elif tipo in ('licitacao_aviso', 'licitacao_edital'):
                resultado['licitacoes'].append(extrair_licitacao_aviso(bloco))

            elif tipo == 'contrato_extrato':
                resultado['contratos_extratos'].append(extrair_contrato_extrato(bloco))

            else:
                if len(bloco) > 50:
                    resultado['outros'].append({
                        'tipo_publicacao': 'outros',
                        'trecho': bloco[:300],
                    })

    # Totais
    resultado['totais'] = {
        'portarias':          len(resultado['portarias']),
        'inexigibilidades':   len(resultado['inexigibilidades']),
        'aditivos':           len(resultado['aditivos']),
        'licitacoes':         len(resultado['licitacoes']),
        'contratos_extratos': len(resultado['contratos_extratos']),
        'outros':             len(resultado['outros']),
    }

    # Filtro por tipo
    if tipo_filtro == 'contratos':
        return {
            "arquivo": resultado["arquivo"],
            "secoes_idaf_encontradas": resultado["secoes_idaf_encontradas"],
            "portarias":          resultado["portarias"],
            "inexigibilidades":   resultado["inexigibilidades"],
            "aditivos":           resultado["aditivos"],
            "contratos_extratos": resultado["contratos_extratos"],
            "totais": resultado["totais"],
        }
    elif tipo_filtro == 'licitacoes':
        return {
            "arquivo": resultado["arquivo"],
            "secoes_idaf_encontradas": resultado["secoes_idaf_encontradas"],
            "licitacoes": resultado["licitacoes"],
            "totais": {"licitacoes": resultado["totais"]["licitacoes"]},
        }

    return resultado


# ─────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Extrator DOAC — seção IDAF e SEAD/SELIC')
    parser.add_argument('pdf', help='Caminho para o PDF do Diário Oficial')
    parser.add_argument(
        '--tipo',
        choices=['todos', 'contratos', 'licitacoes'],
        default='todos',
        help='Filtrar tipo de publicação (padrão: todos)'
    )
    parser.add_argument(
        '--modo',
        choices=['idaf', 'sead', 'ambos'],
        default='ambos',
        help=(
            'idaf  = busca só na seção própria do IDAF (portarias, aditivos, inexigibilidades);\n'
            'sead  = varre seção SEAD/SELIC filtrando avisos de licitação do IDAF;\n'
            'ambos = os dois (padrão)'
        )
    )
    parser.add_argument(
        '--orgao',
        default='IDAF',
        help='Sigla do órgão para filtrar na seção SEAD (padrão: IDAF)'
    )
    args = parser.parse_args()

    if not os.path.exists(args.pdf):
        print(json.dumps({"erro": f"Arquivo não encontrado: {args.pdf}"}))
        sys.exit(1)

    try:
        texto_bruto = extrair_texto_pdf(args.pdf, forcar_1col=False)  # SEAD detecta 2 colunas
    except Exception as e:
        print(json.dumps({"erro": f"Erro ao abrir PDF: {str(e)}"}))
        sys.exit(1)

    texto = limpar_cabecalhos(texto_bruto)

    saida = {
        "erro": None,
        "arquivo": os.path.basename(args.pdf),
        "modo": args.modo,
    }

    if args.modo in ('idaf', 'ambos'):
        resultado_idaf = processar_doac(args.pdf, args.tipo)
        saida.update({
            "secoes_idaf_encontradas": resultado_idaf.get("secoes_idaf_encontradas", 0),
            "portarias":               resultado_idaf.get("portarias", []),
            "inexigibilidades":        resultado_idaf.get("inexigibilidades", []),
            "aditivos":                resultado_idaf.get("aditivos", []),
            "contratos_extratos":      resultado_idaf.get("contratos_extratos", []),
        })

    if args.modo in ('sead', 'ambos'):
        lics_sead = extrair_licitacoes_sead(texto, orgao_filtro=args.orgao)
        saida["licitacoes_sead"] = lics_sead

    if args.modo == 'idaf':
        saida["licitacoes_idaf"] = resultado_idaf.get("licitacoes", [])

    # Totais consolidados
    saida["totais"] = {
        "portarias":          len(saida.get("portarias", [])),
        "inexigibilidades":   len(saida.get("inexigibilidades", [])),
        "aditivos":           len(saida.get("aditivos", [])),
        "contratos_extratos": len(saida.get("contratos_extratos", [])),
        "licitacoes_sead":    len(saida.get("licitacoes_sead", [])),
    }

    print(json.dumps(saida, ensure_ascii=False, indent=2))
