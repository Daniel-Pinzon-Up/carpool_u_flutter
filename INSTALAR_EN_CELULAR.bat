@echo off
setlocal
cd /d "%~dp0"
if not exist "Carpool_UP.apk" (
  echo Primero ejecuta BUILD_APK.bat para generar Carpool_UP.apk
  pause
  exit /b 1
)
where adb >nul 2>nul
if errorlevel 1 (
  echo ADB no esta en PATH. Usa flutter devices y flutter install, o agrega platform-tools al PATH.
  pause
  exit /b 1
)
adb devices
adb install -r "Carpool_UP.apk"
pause
