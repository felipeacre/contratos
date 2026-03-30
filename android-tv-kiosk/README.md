# IDAF TV Kiosk — Android TV WebView App

Aplicativo Android TV que exibe o painel de contratos do IDAF/AC em modo kiosk (tela cheia, sem UI de browser).

---

## Requisitos

| Ferramenta            | Versão mínima |
|-----------------------|---------------|
| Android Studio        | Hedgehog (2023.1) ou superior |
| JDK                   | 17 (bundled no Android Studio) |
| Gradle                | 8.4 (baixado automaticamente pelo wrapper) |
| Android Gradle Plugin | 8.2.2 |
| Kotlin                | 1.9.22 |
| minSdkVersion         | 21 (Android 5.0 Lollipop) |
| targetSdkVersion      | 34 (Android 14) |

---

## Estrutura do projeto

```
android-tv-kiosk/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── kotlin/br/gov/idaf/tvkiosk/
│   │   │   └── MainActivity.kt          # Toda a lógica: WebView, retry, fullscreen
│   │   └── res/
│   │       ├── drawable/
│   │       │   ├── ic_launcher.xml      # Ícone vetorial (108x108dp)
│   │       │   └── tv_banner.xml        # Banner TV launcher (320x180dp)
│   │       ├── layout/
│   │       │   └── activity_main.xml    # Layout simples: FrameLayout + WebView
│   │       └── values/
│   │           ├── colors.xml
│   │           ├── strings.xml
│   │           └── themes.xml
│   ├── build.gradle
│   └── proguard-rules.pro
├── gradle/wrapper/
│   └── gradle-wrapper.properties
├── build.gradle
└── settings.gradle
```

---

## Como compilar

### Opção 1 — Android Studio (recomendado)

1. Abra o Android Studio
2. **File → Open** → selecione a pasta `android-tv-kiosk/`
3. Aguarde a sincronização do Gradle
4. **Build → Build Bundle(s) / APK(s) → Build APK(s)**
5. O APK de debug fica em:
   `app/build/outputs/apk/debug/app-debug.apk`

### Opção 2 — Linha de comando (Windows)

```cmd
cd C:\laragon\www\contratos\android-tv-kiosk

# Debug APK
gradlew.bat assembleDebug

# Release APK (requer keystore configurado)
gradlew.bat assembleRelease
```

### Opção 3 — Linha de comando (Linux/macOS)

```bash
cd /path/to/android-tv-kiosk
chmod +x gradlew
./gradlew assembleDebug
```

---

## Como instalar na Android TV

### Via ADB (cabo USB ou Wi-Fi)

```bash
# 1. Ativar "Depuração USB" / "Depuração ADB via Wi-Fi" na TV
#    Configurações → Preferências do dispositivo → Sobre → Compilação (pressionar 7x)
#    Configurações → Preferências do dispositivo → Depuração

# 2. Conectar via Wi-Fi (substitua pelo IP da TV)
adb connect 192.168.1.XXX:5555

# 3. Instalar o APK
adb install app/build/outputs/apk/debug/app-debug.apk

# 4. Verificar se aparece no launcher da TV
#    O app deve aparecer como "IDAF Contratos TV"
```

### Via pendrive

1. Copie o APK para um pendrive FAT32
2. Conecte na Android TV
3. Use um gerenciador de arquivos (ex.: "Files" da Xiaomi, "FX File Explorer") para instalar

---

## Comportamento do app

| Funcionalidade       | Descrição |
|----------------------|-----------|
| URL alvo             | `http://10.26.9.11:1666/modules/dashboard/tv.php` |
| Fullscreen           | Imediato na abertura, restaurado após perda de foco |
| JavaScript           | Habilitado |
| localStorage         | Habilitado (domStorageEnabled) |
| Retry automático     | A cada **5 segundos** quando a página falha ou a rede cai |
| Reload preventivo    | A cada **5 minutos** para manter o conteúdo fresco |
| Botão BACK           | Ignorado nas 2 primeiras pressões; **3x em < 2s** encerra o app |
| Launcher TV          | Aparece na home da Android TV via `LEANBACK_LAUNCHER` |
| HTTP cleartext       | Permitido (`usesCleartextTraffic="true"`) para redes internas |

---

## Alterar a URL alvo

Edite a constante em `MainActivity.kt`:

```kotlin
private const val TARGET_URL = "http://10.26.9.11:1666/modules/dashboard/tv.php"
```

---

## Ajustar intervalos de retry/reload

Também em `MainActivity.kt`:

```kotlin
private const val RETRY_DELAY_MS    = 5_000L    // 5s entre tentativas após erro
private const val RELOAD_INTERVAL_MS = 300_000L // 5min para reload preventivo
```

---

## Gerar APK de release (produção)

1. Crie um keystore (uma única vez):

```bash
keytool -genkey -v \
  -keystore idaf-tvkiosk.jks \
  -alias idaf \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

2. Adicione em `app/build.gradle`:

```groovy
android {
    signingConfigs {
        release {
            storeFile file("idaf-tvkiosk.jks")
            storePassword "SUA_SENHA"
            keyAlias "idaf"
            keyPassword "SUA_SENHA"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}
```

3. Compile:

```bash
./gradlew assembleRelease
```

---

## Dicas de implantação

- **IP fixo no servidor:** configure o IP `10.26.9.11` como estático no servidor que roda o sistema de contratos, ou use um hostname DNS interno.
- **Autostart na TV:** a maioria das Android TVs reinicia o último app aberto após um boot. Para garantia, use apps de autostart disponíveis na Play Store.
- **Desativar proteção de tela:** Configurações → Preferências do dispositivo → Proteção de tela → Desativar.
- **Orientação:** o app força modo paisagem via `android:screenOrientation="landscape"` no manifest.
