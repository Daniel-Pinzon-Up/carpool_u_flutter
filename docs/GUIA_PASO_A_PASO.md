# Guía rápida - Carpool UP móvil

## 1. Abrir el proyecto
En VS Code abre la carpeta `carpool_up_movil`. Debes ver `pubspec.yaml`, `lib/`, `android/` y `assets/`.

## 2. Preparar dependencias
En la terminal:

```powershell
flutter pub get
flutter doctor
```

## 3. Ejecutar en emulador
Enciende un dispositivo desde Android Studio > Device Manager y comprueba:

```powershell
flutter devices
flutter run
```

## 4. Ejecutar en un celular Android
1. Activa Opciones de desarrollador en el teléfono.
2. Activa Depuración USB.
3. Conecta el teléfono con un cable de datos.
4. Acepta la autorización de depuración en el teléfono.
5. Ejecuta `flutter devices`.
6. Ejecuta `flutter run -d <id-del-telefono>`.

## 5. Recorrido de pasajero
Usa:


Recorrido sugerido:

1. Buscar viaje.
2. Abrir un resultado.
3. Solicitar cupo.
4. Revisar Mis viajes.
5. Abrir Mensajes y enviar un mensaje.
6. Revisar Avisos.
7. Abrir Perfil.

## 6. Recorrido de conductor
Usa:


Recorrido sugerido:

1. Revisar el panel de conductor.
2. Abrir solicitudes y aceptar/rechazar.
3. Publicar un viaje.
4. Ver el nuevo viaje en Mis viajes.
5. Revisar Mensajes.
6. Abrir Perfil.

## 7. Registro
Desde el login pulsa `Regístrate`. El registro se simplificó a datos personales, rol y confirmación. No solicita documento ni código de correo en el modo local.

## 8. Organización del código

- `main.dart`: inicia Flutter.
- `app.dart`: navegación de autenticación y creación del servicio.
- `welcome_page.dart`: bienvenida.
- `login_page.dart`: inicio de sesión.
- `register_page.dart`: registro.
- `dashboard_page.dart`: navegación móvil y funciones de pasajero/conductor.
- `carpool_service.dart`: autenticación local y base para API.
- `app_theme.dart`: colores y estilos.

## 9. Qué se simplificó
La aplicación web tiene mapas, tiempo real, administración, moderación y flujos extensos. Para móvil se priorizaron las acciones principales del usuario y se usaron datos locales donde una integración completa requeriría servicios adicionales.
