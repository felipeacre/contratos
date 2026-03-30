# Regras ProGuard para o TvKiosk
# Mantém a MainActivity (referenciada no manifest)
-keep class br.gov.idaf.tvkiosk.MainActivity { *; }

# Mantém interfaces do WebViewClient/WebChromeClient
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}

# Mantém anotações do AndroidX
-keepattributes *Annotation*

# Suprime avisos de bibliotecas de suporte
-dontwarn androidx.**
