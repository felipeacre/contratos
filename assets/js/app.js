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
        el.textContent = now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
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

function initTvCarousel(scrollId, intervalMs) {
    var scroll = document.getElementById(scrollId);
    if (!scroll) return null;

    var body    = scroll.parentElement; // .tv-section-body
    var itv     = intervalMs || 8000;
    var perPage = 0;   // calculado na 1ª build (elementos visíveis)
    var timer   = null;
    var advance = null;

    function pauseCarousel() { clearInterval(timer); }
    function resumeCarousel() { if (advance) timer = setInterval(advance, itv); }

    function build() {
        clearInterval(timer);
        advance = null;

        // Remove carrossel anterior
        var old = body.querySelector('.tv-carousel-wrap');
        if (old) {
            old.removeEventListener('mouseenter', pauseCarousel);
            old.removeEventListener('mouseleave', resumeCarousel);
            old.remove();
        }

        // Itens fixos por página
        if (!perPage) {
            perPage = 6;
        }

        var cards = Array.from(scroll.querySelectorAll('.tv-card'));

        // Se couber tudo numa página, exibe direto sem carrossel
        if (!cards.length || cards.length <= perPage) {
            scroll.style.display = '';
            return;
        }
        scroll.style.display = 'none';

        // Divide em páginas
        var chunks = [];
        for (var i = 0; i < cards.length; i += perPage) {
            chunks.push(cards.slice(i, i + perPage));
        }
        var total = chunks.length;

        // Monta DOM do carrossel
        var wrap  = document.createElement('div');
        wrap.className = 'tv-carousel-wrap';

        var track = document.createElement('div');
        track.className = 'tv-carousel-track';

        chunks.forEach(function(chunk) {
            var page = document.createElement('div');
            page.className = 'tv-carousel-page';
            chunk.forEach(function(card) { page.appendChild(card.cloneNode(true)); });
            track.appendChild(page);
        });

        var ind = document.createElement('div');
        ind.className = 'tv-page-indicator';

        wrap.appendChild(track);
        wrap.appendChild(ind);
        body.appendChild(wrap);

        var cur = 0;

        function goTo(i) {
            cur = ((i % total) + total) % total;
            track.style.transform = 'translateX(-' + (cur * 100) + '%)';
            ind.textContent = (cur + 1) + ' / ' + total;
        }
        goTo(0);

        advance = function() { goTo(cur + 1); };
        timer   = setInterval(advance, itv);

        wrap.addEventListener('mouseenter', pauseCarousel);
        wrap.addEventListener('mouseleave', resumeCarousel);
    }

    // 1ª build: aguarda layout estabilizar (scroll ainda visível)
    setTimeout(function() {
        build();
        // Se só 1 página, scroll fica visível — oculta o div fonte
        if (scroll.style.display !== '') scroll.style.display = 'none';
    }, 150);

    // Retorna função de reset (chamada após refresh de dados)
    return function() { build(); };
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

    // ── 1. Atualiza divs-fonte (ocultos) com novos dados ──
    if (data.contratos) {
        var criticos  = data.contratos.filter(function(c){ return parseInt(c.dias_para_vencer) <= 30; });
        var atencao   = data.contratos.filter(function(c){ var d=parseInt(c.dias_para_vencer); return d>30&&d<=90; });
        var tranquilo = data.contratos.filter(function(c){ return parseInt(c.dias_para_vencer) > 90; });

        var sC = document.getElementById('tv-scroll-criticos');
        if (sC) sC.innerHTML = renderCards(criticos, '&#10003; Nenhum crítico');
        var sA = document.getElementById('tv-scroll-atencao');
        if (sA) sA.innerHTML = renderCards(atencao, '&#10003; Nenhum');
        var sT = document.getElementById('tv-scroll-tranquilo');
        if (sT) sT.innerHTML = renderCards(tranquilo, '&#10003; Nenhum');

        var eC = document.getElementById('tv-count-criticos');  if (eC) eC.textContent = criticos.length;
        var eA = document.getElementById('tv-count-atencao');   if (eA) eA.textContent = atencao.length;
        var eT = document.getElementById('tv-count-tranquilo'); if (eT) eT.textContent = tranquilo.length;
    }

    // ── 2. Reconstrói carrosséis com dados novos ──
    if (typeof scrollReset !== 'undefined') {
        ['criticos', 'atencao', 'tranquilo'].forEach(function(k) {
            if (scrollReset[k]) scrollReset[k]();
        });
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
