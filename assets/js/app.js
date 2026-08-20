// ============================================================
// assets/js/app.js
// ============================================================
let ultimaAtualizacao = null;
document.addEventListener('DOMContentLoaded', function () {

    // ---- DataTables padrão ----------------------------------
    const dtDefaults = {
        language: {
            url: 'https://cdn.datatables.net/plug-ins/1.13.8/i18n/pt-BR.json'
        },
        pageLength: 25,
        order: [],
        responsive: true,
    };

    document.querySelectorAll('.datatable').forEach(function (el) {
        $(el).DataTable(dtDefaults);
    });

    // ---- Highlight de linha por status ----------------------
    document.querySelectorAll('[data-status]').forEach(function (tr) {
        const s = tr.dataset.status;
        if (s === 'vencido') tr.classList.add('row-vencido');
        if (s === 'critico') tr.classList.add('row-critico');
        if (s === 'atencao') tr.classList.add('row-atencao');
    });

    // ---- Máscara de CNPJ ------------------------------------
    document.querySelectorAll('.mask-cnpj').forEach(function (el) {
        el.addEventListener('input', function () {
            let v = this.value.replace(/\D/g, '').slice(0, 14);
            v = v.replace(/^(\d{2})(\d)/, '$1.$2');
            v = v.replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3');
            v = v.replace(/\.(\d{3})(\d)/, '.$1/$2');
            v = v.replace(/(\d{4})(\d)/, '$1-$2');
            this.value = v;
        });
    });

    // ---- Máscara de moeda -----------------------------------
    document.querySelectorAll('.mask-money').forEach(function (el) {
        el.addEventListener('blur', function () {
            let v = parseFloat(this.value.replace(',', '.'));
            if (!isNaN(v)) this.value = v.toFixed(2).replace('.', ',');
        });
    });

    // ---- Confirmação de exclusão ----------------------------
    document.querySelectorAll('[data-confirm]').forEach(function (el) {
        el.addEventListener('click', function (e) {
            if (!confirm(this.dataset.confirm || 'Confirma a exclusão?')) {
                e.preventDefault();
            }
        });
    });

    // ---- Preview de arquivo ---------------------------------
    const fileInput = document.getElementById('arquivo');
    if (fileInput) {
        fileInput.addEventListener('change', function () {
            const label = document.getElementById('file-label');
            if (label && this.files.length) {
                label.textContent = this.files[0].name;
            }
        });
    }

});

// ============================================================
// Dashboard TV — clock e auto-refresh
// ============================================================
function initTvClock() {
    const el = document.getElementById('tv-clock');
    if (!el) return;

    function tick() {
        const now = new Date();
        el.textContent = now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit', timeZone: 'America/Rio_Branco' });
    }
    tick();
    setInterval(tick, 1000);
}

function initTvScroll(tbodyId, pixelsPerSecond) {
    const tbody = document.getElementById(tbodyId);
    if (!tbody) return null;

    const pps = pixelsPerSecond || 45;
    let pos = 0;
    let lastTime = null;
    let paused = false;
    let pauseTimer = null;
    let rafId = null;

    function getMaxScroll() {
        const container = tbody.parentElement; // .tv-section-body
        if (!container) return 0;
        return Math.max(0, tbody.offsetHeight - container.clientHeight);
    }

    function step(timestamp) {
        if (!lastTime) lastTime = timestamp;
        if (!paused) {
            const delta = (timestamp - lastTime) / 1000;
            pos += pps * delta;
            const max = getMaxScroll();
            if (max <= 0) { lastTime = timestamp; rafId = requestAnimationFrame(step); return; }
            if (pos >= max) {
                pos = max;
                tbody.style.transform = 'translateY(-' + pos + 'px)';
                paused = true;
                clearTimeout(pauseTimer);
                pauseTimer = setTimeout(function () {
                    pos = 0;
                    tbody.style.transform = 'translateY(0)';
                    paused = false;
                    lastTime = null;
                }, 800);
            } else {
                tbody.style.transform = 'translateY(-' + pos + 'px)';
            }
        }
        lastTime = timestamp;
        rafId = requestAnimationFrame(step);
    }

    setTimeout(function () {
        if (getMaxScroll() > 0) rafId = requestAnimationFrame(step);
    }, 2000);

    return function reset() {
        cancelAnimationFrame(rafId);
        clearTimeout(pauseTimer);
        pos = 0; paused = false; lastTime = null;
        tbody.style.transform = 'translateY(0)';
        setTimeout(function () {
            if (getMaxScroll() > 0) rafId = requestAnimationFrame(step);
        }, 1000);
    };
}

/* ── Escalator: rola os cards de forma contínua como uma esteira ── */
function initTvEscalator(id, pixelsPerSecond) {
    var el  = document.getElementById(id);
    if (!el) return function() {};

    var pps         = pixelsPerSecond || 60;
    var originalHtml = el.innerHTML;   // conteúdo original (um conjunto)
    var pos         = 0;
    var halfH       = 0;
    var lastTime    = null;
    var rafId       = null;
    var running     = false;

    function start() {
        cancelAnimationFrame(rafId);
        running  = false;
        pos      = 0;
        lastTime = null;

        // Duplica o conteúdo para o loop ser contínuo sem salto
        el.innerHTML = originalHtml + originalHtml;
        el.style.transform = 'translateY(0)';

        // Aguarda layout renderizar para medir alturas reais
        requestAnimationFrame(function() {
            var container = el.parentElement;
            if (!container) return;
            halfH = el.scrollHeight / 2;   // altura de UM conjunto

            // Só anima se a lista for maior que a área visível
            if (halfH > container.clientHeight + 10) {
                running = true;
                rafId   = requestAnimationFrame(step);
            } else {
                // Cabe tudo na tela — remove a duplicação para não mostrar itens repetidos
                el.innerHTML = originalHtml;
                halfH = 0;
            }
        });
    }

    function step(ts) {
        if (!running) return;
        if (!lastTime) lastTime = ts;

        var dt = (ts - lastTime) / 1000;
        if (dt > 0.1) dt = 0.1;   // evita salto após aba ficar em background
        lastTime = ts;

        pos += pps * dt;
        if (halfH && pos >= halfH) pos -= halfH;   // loop sem salto visual

        el.style.transform = 'translateY(-' + pos.toFixed(1) + 'px)';
        rafId = requestAnimationFrame(step);
    }

    // Inicia após layout estabilizar
    setTimeout(start, 200);

    // Retorna reset: aceita HTML novo (chamado no refresh de dados)
    return function(newHtml) {
        if (newHtml !== undefined) originalHtml = newHtml;
        start();
    };
}

/* ── SSE: atualização em tempo real quando contrato é salvo ── */
function initTvSSE(url) {
    var lastTs = 0;

    function connect() {
        var es = new EventSource(url + '?since=' + lastTs);

        es.onmessage = function(e) {
            var data = JSON.parse(e.data);
            if (data.ts) lastTs = data.ts;
            if (data.update) {
                fetch(window.location.pathname + window.location.search.replace(/([?&])json=1/, '') + (window.location.search ? '&' : '?') + 'json=1')
                    .then(function(r) { return r.json(); })
                    .then(updateTvData)
                    .catch(function() {});
            }
        };

        es.onerror = function() {
            es.close();
            setTimeout(connect, 5000);   // tenta reconectar após 5s
        };
    }

    // Só conecta se o browser suporta SSE (todos os modernos suportam)
    if (typeof EventSource !== 'undefined') connect();
}

function updateTvData(data) {
    // ── Contadores do resumo ──
    ['vencidos', 'criticos', 'atencao', 'alerta', 'regulares'].forEach(function(k) {
        var el = document.getElementById('tv-num-' + k);
        if (el && data.resumo) el.textContent = data.resumo[k] != null ? data.resumo[k] : 0;
    });

    // ── Helpers de renderização ──
    function tvCardHtml(c) {
        var dias = parseInt(c.dias_para_vencer);
        var forn = (c.fornecedor_display || c.fornecedor_nome || '—').toUpperCase().substring(0, 25);
        var bc, bb, n, u;
        if (dias < 0)        { bc='bc-vencido';   bb='b-vencido';   n='VENC.'; u=''; }
        else if (dias <= 10) { bc='bc-urgente';   bb='b-urgente';   n=dias;    u='DIAS'; }
        else if (dias <= 30) { bc='bc-critico';   bb='b-critico';   n=dias;    u='DIAS'; }
        else if (dias <= 90) { bc='bc-atencao';   bb='b-atencao';   n=dias;    u='DIAS'; }
        else if (dias <= 180) { bc='bc-alerta';   bb='b-alerta';   n=dias;    u='DIAS'; }
        else                 { bc='bc-tranquilo'; bb='b-tranquilo'; n=dias;    u='DIAS'; }
        var unit = u ? '<span class="badge-unit">' + u + '</span>' : '';
        return '<div class="tv-card ' + bc + '">' +
            '<div class="tv-card-info">' +
                '<div class="tv-card-num">' + escHtml(c.numero) + '</div>' +
                '<div class="tv-card-forn">' + escHtml(forn) + '</div>' +
            '</div>' +
            '<div class="tv-card-badge ' + bb + '">' + n + unit + '</div>' +
            '</div>';
    }

    function renderCards(list, emptyMsg) {
        return list.length
            ? list.map(tvCardHtml).join('')
            : '<div class="tv-empty-msg">' + emptyMsg + '</div>';
    }

    // ── Atualiza escalators com novos dados ──
    if (data.contratos) {
        var criticos  = data.contratos.filter(function(c){ return parseInt(c.dias_para_vencer) <= 30; });
        var atencao   = data.contratos.filter(function(c){ var d=parseInt(c.dias_para_vencer); return d>30&&d<=90; });
        var tranquilo = data.contratos.filter(function(c){ return parseInt(c.dias_para_vencer) > 90; });

        var eC = document.getElementById('tv-count-criticos');  if (eC) eC.textContent = criticos.length;
        var eA = document.getElementById('tv-count-atencao');   if (eA) eA.textContent = atencao.length;
        var eT = document.getElementById('tv-count-tranquilo'); if (eT) eT.textContent = tranquilo.length;
    }
}

function escHtml(str) {
    const d = document.createElement('div');
    d.appendChild(document.createTextNode(str || ''));
    return d.innerHTML;
}

function modalidadeLabel(m) {
    const map = {
        pregao_eletronico: 'Pregão Eletr.',
        pregao_presencial: 'Pregão Pres.',
        concorrencia: 'Concorrência',
        dispensa: 'Dispensa',
        inexigibilidade: 'Inexigibilidade',
    };
    return map[m] || m;
}
                                                                                                           
function statusLicitacaoLabel(s) {
    const map = {
        em_andamento: '<span style="color:#48d1ee">Em Andamento</span>',
        aguardando_homologacao: '<span style="color:#ffd966">Aguard. Homol.</span>',
        homologada: '<span style="color:#5ce89a">Homologada</span>',
    };
    return map[s] || s;
}

function atualizarLista(categoria, tipo) {    
    fetch(`list-cards-tv.php?${categoria}=${tipo}`)
        .then(response => response.text())
        .then(html => {
            // Atualiza o conteúdo do container sem recarregar a página
            if(document.getElementById('tv-section-scroll-'+tipo+'')) document.getElementById('tv-section-scroll-'+tipo+'').innerHTML = html;
        })
        .catch(error => console.error('Erro:', error));
}

function atualizarModal(tipo, hidden = false) {
    const modais = document.querySelectorAll('.modal');
    
    if(!document.getElementById(tipo+'Modal') || hidden) {
        // Remove a classe 'show' e esconde as modais
        document.querySelectorAll('.modal.show').forEach(m => {
            m.classList.remove('show');
            m.style.display = 'none';
        });

        // Remove o fundo escuro (backdrop)
        document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());

        // Restaura o scroll do corpo da página
        document.body.classList.remove('modal-open');
        document.body.style.overflow = '';
        document.body.style.paddingRight = '';
        return;
    }

    const myModalEl = document.getElementById(tipo+'Modal');
    const myModal = new bootstrap.Modal(myModalEl, {
        backdrop: 'static', // Optional: prevents closing when clicking outside
        keyboard: false     // Optional: prevents closing with Esc key
    });

    // Initialize the modal instance
    // Show the modal manually
    myModal.show();
}

function atualizarResumo() {
    const statusLicitacao = {
        'em_andamento': 'Em andamento',
        'aguardando_homologacao': 'Aguardando homologação',
        'homologada': 'Homologada',
        'deserta': 'Deserta',
        'fracassada': 'Fracassada',
        'cancelada': 'Cancelada',
        'suspensa': 'Suspensa',
    };
    const modalidadeLicitacao = {
        'pregao_eletronico': 'Pregão eletrônico',
        'pregao_presencial': 'Pregão presencial',
        'concorrencia': 'Concorrência',
        'tomada_de_precos': 'Tomada de preços',
        'convite': 'Convite',
        'dispensa': 'Dispensa',
        'inexigibilidade': 'Inexigibilidade',
        'chamamento_publico': 'Chamamento público',
    };
    fetch( window.location.href + '?json=1')
        .then(response => response.json())
        .then(data => {
            var criticosHidden = (Number(data.resumo.vencido_hid) + Number(data.resumo.critico_hid));            
            var atencaoHidden = Number(data.resumo.atencao_hid);
            var tranquiloHidden = (Number(data.resumo.alerta_hid) + Number(data.resumo.regular_hid));

            var countColLic = 0;
            var countResLic = 0;
            countResLic = cardLicitacao(data.resumo_licitacoes.deserta, 'tv-stat-deserta', countResLic);
            countResLic = cardLicitacao(data.resumo_licitacoes.fracassada, 'tv-stat-fracassada', countResLic);
            //Se countResLic > 0, logo a deserta e a fracassada já são testadas
            countColLic = cardLicitacao(countResLic, 'tv-section-deserta', countColLic);
            countColLic = cardLicitacao(data.resumo_licitacoes.em_andamento, 'tv-section-andamento', countColLic);
            countColLic = cardLicitacao(data.resumo_licitacoes.homologada, 'tv-section-homologada', countColLic);

            countResLic = cardLicitacao(data.resumo_licitacoes.em_andamento, 'tv-stat-andamento', countResLic);
            countResLic = cardLicitacao(data.resumo_licitacoes.homologada, 'tv-stat-homologada', countResLic);

            if(countColLic){
                document.getElementById('tv-main-licitacao').className = 'item-licitacao tv-main-'+countColLic+'col';
            } else {
                document.getElementById('tv-main-licitacao').className = 'd-none';
            }

            if(countResLic){
                document.getElementById('tv-cards-resumo-licitacao').className = 'item-licitacao tv-cards-licitacao-'+countResLic+'col';
            } else {
                document.getElementById('tv-cards-resumo-licitacao').className = 'd-none';
            }

            document.getElementById('tv-num-vencidos').innerHTML = data.resumo.vencido || 0;
            document.getElementById('tv-num-criticos').innerHTML = data.resumo.critico || 0;
            document.getElementById('tv-num-atencao').innerHTML = data.resumo.atencao || 0;
            document.getElementById('tv-num-alerta').innerHTML = data.resumo.alerta || 0;
            document.getElementById('tv-num-regulares').innerHTML = data.resumo.regular || 0;

            document.getElementById('tv-num-fracassada').innerHTML = data.resumo_licitacoes.fracassada || 0;
            document.getElementById('tv-num-deserta').innerHTML = data.resumo_licitacoes.deserta || 0;
            document.getElementById('tv-num-andamento').innerHTML = data.resumo_licitacoes.em_andamento || 0;
            document.getElementById('tv-num-homologada').innerHTML = data.resumo_licitacoes.homologada || 0;

            document.getElementById('tv-count-criticos').innerHTML = (Number(data.resumo.vencido) + Number(data.resumo.critico)) || 0;
            document.getElementById('tv-count-criticos-hidden').innerHTML = criticosHidden > 0 ? '&nbsp;|&nbsp;<i class="bi bi-eye-slash"></i>' + criticosHidden : '';
            document.getElementById('tv-count-atencao').innerHTML = data.resumo.atencao || 0;
            document.getElementById('tv-count-atencao-hidden').innerHTML = atencaoHidden > 0 ? '&nbsp;|&nbsp;<i class="bi bi-eye-slash"></i>' + atencaoHidden : '';
            document.getElementById('tv-count-tranquilo').innerHTML = (Number(data.resumo.alerta) + Number(data.resumo.regular)) || 0;
            document.getElementById('tv-count-tranquilo-hidden').innerHTML = tranquiloHidden > 0 ? '&nbsp;|&nbsp;<i class="bi bi-eye-slash"></i>' + tranquiloHidden : '';

            document.getElementById('tv-count-deserta').innerHTML = (Number(data.resumo_licitacoes.deserta) + Number(data.resumo_licitacoes.fracassada)) || 0;
            document.getElementById('tv-count-andamento').innerHTML = data.resumo_licitacoes.em_andamento || 0;
            document.getElementById('tv-count-homologada').innerHTML = data.resumo_licitacoes.homologada || 0;
            
            document.getElementById('tv-section-scroll-tranquilo').style.setProperty('--time-tranquilo', data.controles.velocidade_contrato_tranquilo + 's');
            document.getElementById('tv-section-scroll-atencao').style.setProperty('--time-atencao', data.controles.velocidade_contrato_atencao + 's');
            document.getElementById('tv-section-scroll-critico').style.setProperty('--time-critico', data.controles.velocidade_contrato_critico + 's');
            document.getElementById('tv-section-scroll-critico').style.setProperty('--time-critico', data.controles.velocidade_contrato_critico + 's');
            document.getElementById('tv-cards-resumo-licitacao').style.setProperty('--time-transition', data.controles.transicao + 's');
            document.getElementById('tv-main-licitacao').style.setProperty('--time-transition', data.controles.transicao + 's');
            
            if((Number(data.resumo_licitacoes.homologada) >= 3)) document.getElementById('tv-section-scroll-homologada').style.setProperty('--time-homologada', data.controles.velocidade_licitacao_homologada + 's');
            else document.getElementById('tv-section-scroll-homologada').style.setProperty('--time-homologada', '0s');
            if((Number(data.resumo_licitacoes.em_andamento) >= 3)) document.getElementById('tv-section-scroll-andamento').style.setProperty('--time-andamento', data.controles.velocidade_licitacao_andamento + 's');
            else document.getElementById('tv-section-scroll-andamento').style.setProperty('--time-andamento', '0s');
            if((Number(data.resumo_licitacoes.deserta) + Number(data.resumo_licitacoes.fracassada) >= 3)) document.getElementById('tv-section-scroll-deserta').style.setProperty('--time-deserta', data.controles.velocidade_licitacao_deserta + 's');
            else document.getElementById('tv-section-scroll-deserta').style.setProperty('--time-deserta', '0s');
            
            verificaScroll(Number(data.resumo.vencido) + Number(data.resumo.critico) - Number(criticosHidden), 'critico', 'contrato');
            verificaScroll(Number(data.resumo.atencao) - Number(atencaoHidden), 'atencao', 'contrato');
            verificaScroll(Number(data.resumo.alerta) + Number(data.resumo.regular) - Number(tranquiloHidden), 'tranquilo', 'contrato');
            
            verificaScroll(Number(data.resumo_licitacoes.deserta) + Number(data.resumo_licitacoes.fracassada), 'deserta', 'licitacao');
            verificaScroll(Number(data.resumo_licitacoes.em_andamento), 'andamento', 'licitacao');
            verificaScroll(Number(data.resumo_licitacoes.homologada), 'homologada', 'licitacao');

            var tipo = (data.controles.modal).split("_");
            var time = data.controles.created_at;
            var hiddenModal = false;
            
            if(document.getElementById('num_contrato' + tipo[1]) && tipo[0] == 'contrato'){ //Referente a modal contrato
                document.getElementById('header-modal-contrato').setAttribute("class", "modal-header text-white " + document.getElementById('bg_contrato' + tipo[1]).innerHTML);
                if(convertTimeAddSeconds(time) >= currentTime()){
                    document.getElementById('num_contrato').innerHTML = document.getElementById('num_contrato' + tipo[1]).innerHTML;
                    document.getElementById('fornecedor_display').innerHTML = document.getElementById('fornecedor_display' + tipo[1]).innerHTML;
                    document.getElementById('numero_processo_contrato').innerHTML = document.getElementById('numero_processo_contrato' + tipo[1]).innerHTML;
                    document.getElementById('objeto_contrato').innerHTML = document.getElementById('objeto_contrato' + tipo[1]).innerHTML;
                    document.getElementById('valor_contrato').innerHTML = document.getElementById('valor_contrato' + tipo[1]).innerHTML;
                    document.getElementById('data_assinatura').innerHTML = document.getElementById('data_assinatura' + tipo[1]).innerHTML;
                    document.getElementById('dias_para_vencer').innerHTML = document.getElementById('dias_para_vencer' + tipo[1]).innerHTML;
                    document.getElementById('data_inicio').innerHTML = document.getElementById('data_inicio' + tipo[1]).innerHTML;
                    document.getElementById('data_vencimento').innerHTML = document.getElementById('data_vencimento' + tipo[1]).innerHTML;
                } else {
                    hiddenModal = true;
                }
            } else if(document.getElementById('num_licitacao' + tipo[1]) && tipo[0] == 'licitacao') { //Referente a modal licitacao
                document.getElementById('header-modal-licitacao').setAttribute("class", "modal-header text-white " + document.getElementById('bg_licitacao' + tipo[1]).innerHTML);
                if(convertTimeAddSeconds(time) >= currentTime()){
                    document.getElementById('num_licitacao').innerHTML = document.getElementById('num_licitacao' + tipo[1]).innerHTML;
                    document.getElementById('status').innerHTML = statusLicitacao[document.getElementById('status' + tipo[1]).innerHTML];
                    document.getElementById('modalidade').innerHTML = modalidadeLicitacao[document.getElementById('modalidade' + tipo[1]).innerHTML];
                    document.getElementById('num_licitacao').innerHTML = document.getElementById('num_licitacao' + tipo[1]).innerHTML;
                    document.getElementById('numero_processo_licitacao').innerHTML = document.getElementById('numero_processo_licitacao' + tipo[1]).innerHTML;
                    document.getElementById('objeto_licitacao').innerHTML = document.getElementById('objeto_licitacao' + tipo[1]).innerHTML;
                    document.getElementById('empresa_vencedora').innerHTML = document.getElementById('empresa_vencedora' + tipo[1]).innerHTML;
                    document.getElementById('valor_licitacao').innerHTML = document.getElementById('valor_licitacao' + tipo[1]).innerHTML;
                    document.getElementById('data_abertura').innerHTML = document.getElementById('data_abertura' + tipo[1]).innerHTML;
                    document.getElementById('data_sessao').innerHTML = document.getElementById('data_sessao' + tipo[1]).innerHTML;
                    document.getElementById('data_homologacao').innerHTML = document.getElementById('data_homologacao' + tipo[1]).innerHTML;
                } else {
                    hiddenModal = true;
                }
            } else {
                hiddenModal = true;
            }
            atualizarModal(tipo[0], hiddenModal);
        }).catch(error => console.error('Erro:', error));
}

function verificaScroll(value, tipo, modalidade) {
    if(modalidade == 'contrato') {
        if(value < 8) {
            document.getElementById('tv-section-scroll-' + tipo).classList.remove('tv-section-scroll-' + tipo);
        } else {
            document.getElementById('tv-section-scroll-' + tipo).classList.add('tv-section-scroll-' + tipo);
        }
    } else if(modalidade == 'licitacao') {
        if(value < 4) {
            document.getElementById('tv-section-scroll-' + tipo).classList.remove('tv-section-scroll-' + tipo);
        } else {
            document.getElementById('tv-section-scroll-' + tipo).classList.add('tv-section-scroll-' + tipo);
        }
    }
    
    
}

function atualizarListas() {
    setInterval(() => {
        atualizarResumo();
        atualizarLista('contrato', 'critico');
        atualizarLista('contrato', 'atencao');
        atualizarLista('contrato', 'tranquilo');
        atualizarLista('licitacao', 'deserta');
        atualizarLista('licitacao', 'homologada');
        atualizarLista('licitacao', 'andamento');
    }, 5000);
}

function currentTime() {
    return new Date();
}

function convertTimeAddSeconds(stringData, secondsToAdd = 35) {
    const convertedDate = new Date(stringData.replace(" ", "T"));
    convertedDate.setSeconds(convertedDate.getSeconds() + secondsToAdd);
    return convertedDate;
}

function cardLicitacao(qtd, id, count) {
    if(Number(qtd)){
        document.getElementById(id).classList.remove('d-none');
        count++;
    } else {
        document.getElementById(id).classList.add('d-none');
    }
    return count;
    
}