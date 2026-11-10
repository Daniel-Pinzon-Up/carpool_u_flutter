$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
Write-Host 'Carpool UP - Generando APK universal Android...'
flutter clean
flutter pub get
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
$source = Join-Path $PSScriptRoot 'build\app\outputs\flutter-apk\app-release.apk'
$dest = Join-Path $PSScriptRoot 'Carpool_UP.apk'
Copy-Item $source $dest -Force
Write-Host "LISTO: $dest"
