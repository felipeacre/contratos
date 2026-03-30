package br.gov.idaf.tvkiosk

import android.annotation.SuppressLint
import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.KeyEvent
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.webkit.ConsoleMessage
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    companion object {
        private const val TARGET_URL = "http://10.26.9.11:1666/modules/dashboard/tv.php"
        private const val RETRY_DELAY_MS = 5_000L   // 5 segundos entre tentativas
        private const val RELOAD_INTERVAL_MS = 300_000L // 5 minutos: reload completo preventivo
    }

    private lateinit var webView: WebView
    private val handler = Handler(Looper.getMainLooper())

    // Runnable de retry quando a página falha
    private val retryRunnable = Runnable { loadPage() }

    // Runnable de reload periódico preventivo
    private val periodicReloadRunnable: Runnable = object : Runnable {
        override fun run() {
            if (isNetworkAvailable()) {
                webView.reload()
            }
            handler.postDelayed(this, RELOAD_INTERVAL_MS)
        }
    }

    private var isPageLoaded = false
    private var connectivityManager: ConnectivityManager? = null

    private val networkCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            // Rede voltou — tenta recarregar se a página não estava carregada
            handler.post {
                if (!isPageLoaded) {
                    handler.removeCallbacks(retryRunnable)
                    loadPage()
                }
            }
        }

        override fun onLost(network: Network) {
            // Rede perdida — marca como não carregada para forçar reload quando voltar
            handler.post {
                isPageLoaded = false
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Ciclo de vida
    // ─────────────────────────────────────────────────────────────────────────

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webView)

        enterFullscreen()
        setupWebView()
        registerNetworkCallback()

        if (savedInstanceState != null) {
            webView.restoreState(savedInstanceState)
        } else {
            loadPage()
        }

        // Inicia reload periódico preventivo
        handler.postDelayed(periodicReloadRunnable, RELOAD_INTERVAL_MS)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        webView.saveState(outState)
    }

    override fun onResume() {
        super.onResume()
        webView.onResume()
        enterFullscreen()
    }

    override fun onPause() {
        super.onPause()
        webView.onPause()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        unregisterNetworkCallback()
        webView.apply {
            stopLoading()
            clearHistory()
            destroy()
        }
        super.onDestroy()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Botão BACK — ignora para não fechar acidentalmente
    // Pressionar BACK 3x em menos de 2s encerra o app (saída de emergência)
    // ─────────────────────────────────────────────────────────────────────────

    private var backPressCount = 0
    private val resetBackRunnable = Runnable { backPressCount = 0 }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            backPressCount++
            handler.removeCallbacks(resetBackRunnable)
            if (backPressCount >= 3) {
                finish()
                return true
            }
            handler.postDelayed(resetBackRunnable, 2_000L)
            return true // consome o evento — não fecha na primeira pressão
        }
        return super.onKeyDown(keyCode, event)
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Fullscreen
    // ─────────────────────────────────────────────────────────────────────────

    private fun enterFullscreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.let { ctrl ->
                ctrl.hide(WindowInsets.Type.systemBars() or WindowInsets.Type.navigationBars())
                ctrl.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                )
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Configuração do WebView
    // ─────────────────────────────────────────────────────────────────────────

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView() {
        WebView.setWebContentsDebuggingEnabled(false)

        with(webView.settings) {
            javaScriptEnabled = true
            domStorageEnabled = true          // localStorage
            databaseEnabled = true
            cacheMode = WebSettings.LOAD_DEFAULT
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            mediaPlaybackRequiresUserGesture = false
            loadWithOverviewMode = true
            useWideViewPort = true
            setSupportZoom(false)
            builtInZoomControls = false
            displayZoomControls = false
            loadsImagesAutomatically = true
            blockNetworkLoads = false
            allowContentAccess = true
            allowFileAccess = false           // segurança: sem acesso ao sistema de arquivos
            userAgentString = "Mozilla/5.0 (Linux; Android 10; Android TV) " +
                "AppleWebKit/537.36 (KHTML, like Gecko) " +
                "Chrome/120.0.0.0 Safari/537.36 IDAF-TvKiosk/1.0"
        }

        webView.webViewClient = object : WebViewClient() {

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                isPageLoaded = true
                handler.removeCallbacks(retryRunnable)
            }

            override fun onReceivedError(
                view: WebView?,
                request: WebResourceRequest?,
                error: WebResourceError?
            ) {
                super.onReceivedError(view, request, error)
                // Só trata erro na URL principal, não em sub-recursos
                if (request?.isForMainFrame == true) {
                    isPageLoaded = false
                    scheduleRetry()
                }
            }

            @Deprecated("Kept for API < 23")
            override fun onReceivedError(
                view: WebView?,
                errorCode: Int,
                description: String?,
                failingUrl: String?
            ) {
                @Suppress("DEPRECATION")
                super.onReceivedError(view, errorCode, description, failingUrl)
                if (failingUrl == TARGET_URL) {
                    isPageLoaded = false
                    scheduleRetry()
                }
            }

            // Garante que todos os links abram no mesmo WebView
            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean = false
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean = true
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Carregamento e retry
    // ─────────────────────────────────────────────────────────────────────────

    private fun loadPage() {
        webView.loadUrl(TARGET_URL)
    }

    private fun scheduleRetry() {
        handler.removeCallbacks(retryRunnable)
        handler.postDelayed(retryRunnable, RETRY_DELAY_MS)
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Monitoramento de rede
    // ─────────────────────────────────────────────────────────────────────────

    private fun registerNetworkCallback() {
        connectivityManager =
            getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        connectivityManager?.registerNetworkCallback(request, networkCallback)
    }

    private fun unregisterNetworkCallback() {
        try {
            connectivityManager?.unregisterNetworkCallback(networkCallback)
        } catch (_: IllegalArgumentException) {
            // callback não registrado — ignora
        }
    }

    private fun isNetworkAvailable(): Boolean {
        val cm = connectivityManager ?: return false
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }
}
