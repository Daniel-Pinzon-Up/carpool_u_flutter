# Carpool UP móvil - Flutter

Aplicación móvil simplificada de Carpool UP, basada en el proyecto web original y en los mockups para celular.

## Inicio de sesión

No existen cuentas predeterminadas ni credenciales de prueba dentro de la aplicación. Para iniciar sesión, una persona debe crear primero su propia cuenta desde **Regístrate** y después ingresar con el correo y la contraseña que registró. En el modo local, esas cuentas se guardan únicamente en el dispositivo mediante almacenamiento local.


## Alcance de esta versión

### Autenticación
- Pantalla de bienvenida.
- Inicio de sesión.
- Registro simplificado sin documento ni verificación por correo en modo local.
- Inicio de sesión únicamente con cuentas creadas por el usuario.
- Cierre de sesión.

### Pasajero
- Buscar viajes por origen y destino.
- Elegir puestos y preferencias.
- Consultar detalle de viaje.
- Solicitar cupo.
- Consultar Mis viajes e historial.
- Calificar un viaje finalizado.
- Conversaciones y chat básico.
- Notificaciones.
- Perfil.

### Conductor
- Panel de inicio con requisitos y vehículo.
- Publicar un viaje desde un formulario simplificado.
- Consultar viajes publicados.
- Revisar solicitudes de pasajeros y aceptarlas o rechazarlas.
- Conversaciones y chat básico.
- Perfil.

## Simplificaciones frente al proyecto web

- El panel administrativo completo permanece en la aplicación web.
- El mapa en tiempo real se representa con una tarjeta visual de ruta para evitar integrar mapas/GPS en esta entrega.
- La publicación de viaje pasó de varios pasos a un único formulario móvil.
- Chat, notificaciones, reservas y solicitudes funcionan con datos locales.
- No se solicita documento durante el registro.
- No se exige verificación por correo en el modo local.
- No se implementaron pagos porque Carpool UP maneja aportes entre usuarios y no procesa dinero dentro de la app.

## Ejecutar en Android

1. Abrir esta carpeta en VS Code.
2. Encender un emulador Android o conectar un teléfono con depuración USB.
3. Ejecutar:

```powershell
flutter pub get
flutter devices
flutter run
```

Para un dispositivo concreto:

```powershell
flutter run -d <id-del-dispositivo>
```

## Acceso de usuarios

La aplicación ya no incluye cuentas predeterminadas de pasajero o conductor. Para entrar, cada persona debe crear su propia cuenta desde **Regístrate** y luego iniciar sesión con su correo y contraseña. En el modo local, esas cuentas quedan guardadas en el dispositivo.

## Estructura principal

```text
lib/
  main.dart
  app.dart
  models/
  pages/
    welcome_page.dart
    login_page.dart
    register_page.dart
    dashboard_page.dart
  services/
    carpool_service.dart
  utils/
  widgets/
assets/images/
android/
test/
```

`dashboard_page.dart` contiene el shell móvil y los módulos simplificados de pasajero y conductor. El servicio conserva un modo local para trabajar sin backend y la base para consumir la API cuando se quiera continuar la integración real. Las cuentas locales se crean desde el registro; no existen credenciales predeterminadas.

## Foto de perfil (v1.1)

La sección Perfil permite elegir una imagen de la galería o tomarla con la cámara. La foto se guarda localmente en el almacenamiento privado de la aplicación y se recuerda en ese dispositivo. Para una futura versión multi-dispositivo debe añadirse almacenamiento en backend/objetos y un campo de URL en el perfil.

## APK universal para celular

Esta versión elimina archivos generados/desactualizados y deja que `flutter pub get` regenere correctamente los plugins de Android. Para crear un APK compatible con teléfonos ARM de 32/64 bits y emuladores x64, en Windows ejecuta `BUILD_APK.bat`. Al terminar aparecerá `Carpool_UP.apk` en la raíz del proyecto.

Comando equivalente:

```powershell
flutter clean
flutter pub get
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
```

El APK generado por `flutter run` para un emulador puede estar compilado solo para x86_64 y no debe usarse como APK de entrega para un teléfono ARM. Usa siempre el APK generado por el script anterior.
<<<<<<< HEAD

## Flujo multiusuario para sustentación

La versión 1.2 agrega persistencia local compartida para demostrar interacción entre cuentas sin usuarios precargados:

1. Registrar una cuenta **Conductor** y publicar un viaje.
2. Cerrar sesión y registrar/iniciar una cuenta **Pasajero**.
3. En **Buscar**, actualizar y solicitar el viaje publicado.
4. Volver al conductor, abrir **Solicitudes** y aceptar al pasajero.
5. Desde **Mensajes**, conductor y pasajero pueden conversar en el mismo chat.
6. En **Mis viajes**, el conductor puede pulsar **Iniciar viaje**; el pasajero verá el estado **En curso** al actualizar.
7. El registro público solo permite **Pasajero** o **Conductor**. La administración usa una cuenta reservada que no puede crearse desde la app.

Los viajes, solicitudes y mensajes se guardan con `SharedPreferences`, por lo que permanecen al cerrar sesión en el mismo teléfono. Esta persistencia sirve para la demostración académica local; la versión de producción debe usar la API FastAPI y la base de datos compartida para sincronizar distintos dispositivos.


## Cuenta administrativa reservada

El rol Administrador no aparece en el registro público. Para la sustentación existe una única cuenta administrativa local reservada:

- Correo: `danipinqui1@gmail.com`
- Contraseña: `1234567890`

Esta cuenta permite abrir el panel administrativo local y revisar usuarios, viajes y solicitudes. Los usuarios normales solo pueden registrarse como Pasajero o Conductor.
=======
>>>>>>> 41950695084957e6af109babcd25a1d3eef53a78
