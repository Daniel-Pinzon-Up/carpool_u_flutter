# Foto de perfil y uso en celular

## Foto de perfil

La pantalla **Perfil** permite agregar una foto desde la galería o tomar una nueva con la cámara.
La foto se copia al almacenamiento privado de la aplicación y se recuerda localmente en el mismo dispositivo.
En esta versión académica no se sube al backend, por lo que no se sincroniza entre teléfonos.

### Probar

1. Inicia sesión.
2. Abre **Perfil**.
3. Pulsa **Agregar foto** o el icono de cámara sobre el avatar.
4. Elige **Galería** o **Cámara**.
5. Selecciona/toma la foto.
6. La imagen aparecerá en el avatar y seguirá allí cuando vuelvas a abrir la app en ese dispositivo.
7. Usa el botón de papelera si deseas quitarla.

## Ejecutar en un teléfono Android por USB

1. En el teléfono, abre **Ajustes > Acerca del teléfono** y pulsa varias veces **Número de compilación** hasta activar Opciones de desarrollador.
2. En **Opciones de desarrollador**, activa **Depuración USB**.
3. Conecta el teléfono al computador mediante cable USB de datos.
4. Acepta en el teléfono la autorización de depuración.
5. Desde la raíz del proyecto ejecuta `flutter devices`.
6. Identifica el ID del teléfono y ejecuta `flutter run -d ID_DEL_TELEFONO`.

## Uso básico

### Pasajero

Inicio > Iniciar sesión > Buscar > seleccionar viaje > Solicitar cupo > Mis viajes. También puede entrar a Mensajes, Avisos y Perfil.

### Conductor

Inicio > Iniciar sesión > Inicio del conductor > Publicar > completar formulario > Mis viajes. Desde Inicio puede revisar solicitudes y aceptarlas o rechazarlas. También dispone de Mensajes y Perfil.
