# Flutter Projesini Paketleme Script'i
# Bu script projenizi başka bir PC'ye taşımak için hazırlar

Write-Host "Flutter projesi paketleniyor..." -ForegroundColor Green

# Once temizlik yap
Write-Host "`n1. Proje temizleniyor (flutter clean)..." -ForegroundColor Yellow
flutter clean

# Cikis klasoru olustur
$outputDir = "c:\Users\ramiz\Desktop\IdrakLiseyiPackage"
if (Test-Path $outputDir) {
    Remove-Item -Recurse -Force $outputDir
}
New-Item -ItemType Directory -Path $outputDir | Out-Null

Write-Host "`n2. Dosyalar kopyalanıyor..." -ForegroundColor Yellow

# Kopyalanacak onemli dosya ve klasorler
$itemsToCopy = @(
    "lib",
    "android",
    "ios",
    "assets",
    "pubspec.yaml",
    "pubspec.lock",
    ".metadata",
    "analysis_options.yaml",
    ".gitignore",
    ".firebaserc"
)

# Firebase dosyalari kontrol et ve ekle
if (Test-Path "firebase.json") {
    $itemsToCopy += "firebase.json"
}

foreach ($item in $itemsToCopy) {
    $sourcePath = Join-Path (Get-Location) $item
    if (Test-Path $sourcePath) {
        Write-Host "  Kopyalaniyor: $item"
        if (Test-Path $sourcePath -PathType Container) {
            Copy-Item -Path $sourcePath -Destination $outputDir -Recurse -Force
        } else {
            Copy-Item -Path $sourcePath -Destination $outputDir -Force
        }
    } else {
        Write-Host "  Atlandi (bulunamadi): $item" -ForegroundColor DarkGray
    }
}

Write-Host "`n3. Gereksiz dosyalar temizleniyor..." -ForegroundColor Yellow

# Kopyalanan android klasöründeki build dosyalarını temizle
$androidBuildPaths = @(
    "$outputDir\android\.gradle",
    "$outputDir\android\build",
    "$outputDir\android\app\build",
    "$outputDir\android\.kotlin"
)

foreach ($path in $androidBuildPaths) {
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
        Write-Host "  Silindi: $path"
    }
}

Write-Host "`n4. README dosyasi olusturuluyor..." -ForegroundColor Yellow

# README dosyasi olustur
$readmeContent = @"
# IdrakLiseyi Flutter Projesi

## Yeni Bilgisayarda Kurulum Adımları

### 1. Gerekli Yazılımları Yükleyin
- Flutter SDK: https://docs.flutter.dev/get-started/install
- Android Studio: https://developer.android.com/studio
- Git (isteğe bağlı)

### 2. Flutter'ı Kurun ve Yapılandırın
``````
flutter doctor
``````

### 3. Projeyi Açın
Bu klasörü istediğiniz yere kopyalayın ve içinde terminali açın.

### 4. Bağımlılıkları İndirin
``````
flutter pub get
``````

### 5. Projeyi Çalıştırın
``````
flutter run
``````

## Önemli Notlar

✅ Firebase yapılandırması dahil edilmiştir (google-services.json)
✅ Signing key dahil edilmiştir (idrak-release-key.jks)
✅ Tüm bağımlılıklar pubspec.lock ile sabitlenmiştir

### Sorun Yaşarsanız

1. Önce temizlik yapın:
``````
flutter clean
flutter pub get
``````

2. Android Studio'da Tools > Flutter > Flutter Clean

3. Gradle sorunları için:
``````
cd android
.\gradlew clean
cd ..
``````

## İletişim
Proje Sahibi: Ramiz
"@

Set-Content -Path "$outputDir\README.md" -Value $readmeContent -Encoding UTF8

Write-Host "`n5. Zip dosyasi olusturuluyor..." -ForegroundColor Yellow

$zipPath = "c:\Users\ramiz\Desktop\IdrakLiseyi_Portable.zip"
if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Compress-Archive -Path "$outputDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

Write-Host "`nTAMAMLANDI!" -ForegroundColor Green
Write-Host "`nZip dosyası: $zipPath" -ForegroundColor Cyan
Write-Host "Klasör: $outputDir" -ForegroundColor Cyan

# Dosya boyutunu göster
$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host "`nZip dosyası boyutu: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Yellow

Write-Host "`nDIGER BILGISAYARDA YAPILACAKLAR:" -ForegroundColor Magenta
Write-Host "1. Zip dosyasini cikart"
Write-Host "2. Flutter SDK yukle (flutter.dev)"
Write-Host "3. flutter pub get komutunu calistir"
Write-Host "4. flutter run ile projeyi calistir"
Write-Host ""
