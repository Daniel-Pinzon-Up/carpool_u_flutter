# Cambios realizados para la versión móvil completa

## 1. Objetivo
Convertir la experiencia principal de Carpool UP, originalmente web, en una aplicación móvil Flutter sencilla de ejecutar, explicar y ampliar.

## 2. Funciones conservadas
Se conservaron los flujos de uso diario de pasajero y conductor: autenticación, registro, búsqueda, detalle de viaje, solicitud de cupo, mis viajes, publicación, solicitudes, mensajes, notificaciones, perfil y calificación.

## 3. Funciones simplificadas
- Mapa/GPS: reemplazado por una representación visual de la ruta.
- Publicación: un formulario en lugar de un asistente largo.
- Chat: mensajes locales sin WebSocket.
- Reservas y solicitudes: estado local para modo local.
- Notificaciones: lista local.
- Vehículo y licencia: resumen de estado dentro del panel del conductor.

## 4. Funciones que permanecen en web
El panel administrativo avanzado (usuarios, moderación, emergencias, configuración y aprobaciones masivas) se deja en la aplicación web. Esto reduce el alcance móvil y evita duplicar tareas de gestión que normalmente realiza el personal desde escritorio.

## 5. Por qué se simplificó
La finalidad de esta versión es entregar una aplicación móvil funcional y clara. Las integraciones de mapas en tiempo real, WebSocket, almacenamiento de documentos y administración completa requieren más infraestructura y no son necesarias para demostrar los flujos fundamentales de Carpool UP.

## 6. Compatibilidad con celular
El proyecto conserva la carpeta `android/` de Flutter y usa widgets adaptables con scroll. Puede ejecutarse en emulador o en un teléfono Android conectado mediante USB con depuración habilitada.
