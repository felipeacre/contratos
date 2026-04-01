// ============================================================
// assets/js/app.js
// ============================================================

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

function initTvRefresh(intervalSeconds) {
    const indicator = document.getElementById('tv-refresh-indicator');

    setInterval(function () {
        if (indicator) {
            indicator.classList.add('refreshing');
            setTimeout(function () { indicator.classList.remove('refreshing'); }, 700);
        }

        fetch(window.location.href + '?json=1')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                updateTvData(data);
            })
            .catch(function (e) { console.warn('Refresh falhou:', e); });

    }, intervalSeconds * 1000);
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

        // Passa HTML novo para o escalator — ele re-duplica e reinicia suave
        if (typeof scrollReset !== 'undefined') {
            if (scrollReset['criticos'])  scrollReset['criticos'](renderCards(criticos,  '&#10003; Nenhum crítico'));
            if (scrollReset['atencao'])   scrollReset['atencao'](renderCards(atencao,    '&#10003; Nenhum'));
            if (scrollReset['tranquilo']) scrollReset['tranquilo'](renderCards(tranquilo,'&#10003; Nenhum'));
        }
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
