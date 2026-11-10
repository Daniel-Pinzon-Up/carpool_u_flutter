@echo off
setlocal
cd /d "%~dp0"
echo ==============================================
echo   Carpool UP - Generar APK universal Android
echo ==============================================
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter no esta disponible en PATH.
  echo Abre esta carpeta desde el PC donde instalaste Flutter.
  pause
  exit /b 1
)
call flutter clean || goto :error
call flutter pub get || goto :error
call flutter build apk --release --target-platform android-arm,android-arm64,android-x64 || goto :error
if not exist "build\app\outputs\flutter-apk\app-release.apk" goto :error
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "Carpool_UP.apk" >nul
echo.
echo LISTO: APK creado en:
echo %CD%\Carpool_UP.apk
echo.
pause
exit /b 0
:error
echo.
echo ERROR: No se pudo generar el APK. Revisa el mensaje anterior.
pause
exit /b 1
