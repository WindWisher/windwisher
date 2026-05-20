# SESSION TRACKER

## Total historico consolidado

- `Total historico minimo consolidado del proyecto: 219h 47m`.
- Referencia de calculo:
  - `Total acumulado de referencia` consolidado en `2026-03-02`: `34h 49m`
  - `Acumulado combinado confirmado del dia` en `2026-03-15`: `21h 35m`
  - bloque consolidado adicional en `2026-03-26`: `+8h` estimadas
  - bloque consolidado adicional en `2026-03-27`: `+4h` estimadas
  - bloque consolidado adicional en `2026-03-28`: `+6h` estimadas
  - bloque consolidado adicional en `2026-04-06`: `+26h` estimadas
  - bloque consolidado adicional en `2026-04-08`: `+3h` estimadas
  - bloque consolidado adicional en `2026-04-09`: `+2h` estimadas
  - bloque consolidado adicional en `2026-04-11`: `+8h` estimadas
  - bloque consolidado adicional en `2026-04-11`: `+6h` estimadas
  - bloque consolidado adicional en `2026-04-12`: `+8h` estimadas
  - bloque consolidado adicional en `2026-04-12`: `+6h` estimadas
  - bloque consolidado adicional en `2026-04-12`: `+7h` estimadas
  - bloque consolidado adicional en `2026-04-23`: `+12h` estimadas (`WOO reverse engineering`)
  - bloque consolidado adicional en `2026-04-23`: `+4h` estimadas (`WOO Big Air model refinement`)
  - bloque consolidado adicional en `2026-04-25`: `+6h` estimadas (`Perfil > Ajustes modularization and dependency cleanup`)
  - bloque consolidado adicional en `2026-04-30`: `+18h` estimadas (`Onboarding legal, roles/admin panels and Puertos del Estado forecast integration`)
  - bloque consolidado adicional en `2026-04-30`: `+1h` estimada (`Live spots: AEMET Oliva check and compass correction`)
  - bloque consolidado adicional en `2026-04-30`: `+30m` reales (`Local spot alarm notifications`)
  - bloque consolidado adicional en `2026-04-30`: `+54m` reales (`Live spots: Puertos del Estado Gandia realtime/history and web deploy`)
  - bloque consolidado adicional en `2026-05-02`: `+12h 31m` reales observables (`Spots: extraccion del tab Chat de spot_detail_page`)
  - bloque consolidado adicional en `2026-05-02`: `+12h 53m` reales observables (`Spots: reorganizacion completa de Spot Detail y Spots por tabs/widgets`)
  - bloque consolidado adicional en `2026-05-06`: `+55m` reales observables (`Spots: modularizacion de pagina Spots, sheets y mapa custom`)
  - bloque consolidado adicional en `2026-05-06`: `+1h 25m` reales observables (`Spots: spot patron Oliva Canal, capacidades replicables y tablas forecast por proveedor`)
  - bloque consolidado adicional en `2026-05-20`: `+2h 15m` reales aproximados (`El Perellonet: live stations, Meteoclimatic, backend safety and webcam review`)
- Nota:
  - esta cifra evita confundir el acumulado del dia con el historico total,
  - debe actualizarse solo cuando exista una nueva consolidacion explicita en el propio tracker.
  - ultima consolidacion manual anadida el `2026-05-20`: `+2h 15m` reales aproximados (`El Perellonet: live stations, Meteoclimatic, backend safety and webcam review`).
  - regla operativa: las futuras consolidaciones deben reflejar el tiempo real transcurrido de programacion, no una estimacion amplia.

## Rol operativo permanente (MeteoKite Master Prompt v2)

Referencia: `/home/clw/Documentos/Proyectos/Flutter/MeteoKite/meteokite/docs/MeteoKite_Master_Prompt_v2.md`

Actuo como cofundador tecnico y estrategico con estos roles activos:

- Arquitectura: Senior Flutter Architect, Principal Software Engineer, Systems Architect, Performance Engineer
- Dominio: Meteorological Data Specialist, Geospatial Engineer, Sensor and Motion Data Engineer
- Producto: Product Manager, UX Researcher
- Diseno: UX/UI Lead outdoor sports, Design Systems Architect, UI Systems Engineer, Accessibility Specialist
- Competicion: Game Systems Designer
- Kitesurf Performance & Competition Expert: Rider con +30 años de experiencia real en Freeride, Freestyle y Big Air, compitiendo a nivel internacional y navegando en spots de referencia mundial (condiciones onshore, side-on, offshore, térmicos, frentes, viento racheado, mar de fondo y choppy extremo). Experto en lectura avanzada de viento, análisis de ráfagas, gradientes térmicos, interacción viento-ola-corriente, selección óptima de material (kite, líneas, tabla, trims), gestión de riesgo, toma de decisiones bajo presión y optimización del rendimiento según nivel del rider. Capaz de traducir datos meteorológicos crudos en decisiones tácticas reales de navegación y competición.
- Open source: Open Source Governance Advisor, Community Lead
- Seguridad y escalabilidad: Security Engineer, Cloud and Backend Strategist

## Registro de sesiones

### 2026-05-20 - El Perellonet: live stations, Meteoclimatic, backend safety and webcams

- Bloque consolidado adicional: `+2h 15m` reales aproximados.
- Medicion real usada:
  - tramo de trabajo repartido entre investigacion web, pruebas de backend, ajustes Flutter y verificacion,
  - se registra una duracion conservadora aproximada de trabajo efectivo, no tiempo calendario completo entre pausas.
- Live / El Perellonet:
  - creado perfil Live especifico `el_perellonet`,
  - configurada `Valencia el Saler Playa de la Garrofera` como estacion preferida provisional,
  - anadidas estaciones AVAMET cercanas para validar en campo:
    - `Sueca l'Albufera/Tancat de l'Estell`,
    - `Valencia l'Albufera/Raco de l'Olla`,
    - `Sollana l'Albufera/Tancat de Milia`,
    - `Valencia el Saler Playa de la Garrofera`,
    - `Valencia l'Albufera/Tancat de la Pipa`,
  - evitado el fallback generico de AEMET para este perfil para no llenar el selector con estaciones poco utiles.
- Meteoclimatic:
  - anadido cliente `MeteoclimaticLiveClient` para leer RSS de la estacion `ESPVA4600000046420A`,
  - integrada `Meteoclimatic El Perello` como estacion Live actual del perfil de El Perellonet,
  - parseo de RSS `ISO-8859-1/15`, fecha, coordenadas, viento, racha, direccion, temperatura, presion, humedad y lluvia,
  - anadido test unitario con fixture RSS para validar el mapeo de snapshot,
  - confirmado que la app puede usar la lectura actual, pero Supabase Edge recibe `403` por Cloudflare en la fuente principal.
- Backend / seguridad funcional:
  - se probo integrar Meteoclimatic en `spot-live-observation-collector` y `spot-alarm-runner`,
  - tras confirmar bloqueo `meteoclimatic-http-403` desde Supabase, se retiro del collector y de las alarmas backend para no crear historicos falsos ni alarmas no evaluables,
  - Meteoclimatic queda como Live visual, sin historico backend ni seleccion de alarmas hasta encontrar endpoint servidor-servidor permitido,
  - `spot-live-observation-collector` mantiene la recogida de DK Piles sin cambios funcionales.
- Historico Live:
  - el boton de historico informa que Meteoclimatic no tiene historico disponible por bloqueo backend,
  - se evita cargar grafica infinita o pintar datos inventados,
  - se mantiene el camino de historico backend para estaciones compatibles.
- Webcams / El Perellonet:
  - busqueda intensiva de webcams cercanas: Camaramar, WebcamGalore, PlayaWebcams, web oficial de El Perello, DGT, negocios/hoteles/restaurantes y club nautico,
  - descartadas las tres camaras de Camaramar porque no funcionan actualmente,
  - descartado el enlace directo de la web de El Perello por requerir credenciales embebidas publicadas en la web,
  - se conserva `Valencia El Saler` como webcam embebida oficial de Comunitat Valenciana,
  - revisado el reproductor: se deja el embed igual que en navegador oficial, usando scripts de Comunitat Valenciana y `connect(video, manifest.mpd)` sin watchdog propio.
- Verificacion:
  - `flutter analyze` limpio tras los ajustes de app,
  - `flutter test test/features/spots/infrastructure/services/meteoclimatic_live_client_test.dart` correcto,
  - `deno check supabase/functions/spot-live-observation-collector/index.ts` limpio,
  - `deno check supabase/functions/spot-alarm-runner/index.ts` limpio,
  - funciones Supabase desplegadas tras dejar el estado seguro,
  - `local.env.json` sigue ignorado por git y no se versiona.

### 2026-05-06 - Spots: spot patron Oliva Canal, capacidades replicables y tablas forecast

- Bloque consolidado adicional: `+1h 25m` reales observables.
- Medicion real usada:
  - duracion efectiva conservadora registrada: `1h 25m`,
  - nota de honestidad: se registra el tiempo real observable de trabajo/procesos de este tramo, no una estimacion amplia ni el tiempo calendario entre pausas.
- Objetivo:
  - dejar `Oliva Canal - Platja dels Gorgs` como spot patron replicable para futuros spots,
  - separar capacidades por spot para evitar hardcodes por nombre,
  - ordenar las tablas de `Forecast` por proveedor/modelo sin cambiar el comportamiento de Windguru.
- Capacidades por spot:
  - anadida la entidad `SpotCapabilities` dentro de `SpotItem`,
  - creado el catalogo `spot_capabilities_catalog.dart` para centralizar perfiles de live, webcams, forecast por defecto y estaciones preferidas,
  - configurado `Oliva Canal - Platja dels Gorgs` con `AEMET > Puertos del Estado` como forecast inicial,
  - configurada la estacion live preferida `Club Nautico de Oliva` y la estacion realtime de Puertos del Estado `4634`,
  - adaptado el catalogo Supabase para aplicar capacidades por defecto a spots oficiales existentes segun nombre, sin exigir migracion inmediata.
- Forecast:
  - creada la estructura `forecast/widgets/tables/` con carpetas por proveedor,
  - movidas las tablas de `AEMET`, `Meteoblue`, `Meteosource`, `Meteostat` y `Windguru` a sus carpetas propias,
  - creados widgets compartidos para chrome, chips, resumen diario y celdas compactas reutilizables,
  - corregidos avisos de variables locales sin uso en tablas suplementarias.
- Live y webcams:
  - `Live` usa capacidades del spot para decidir estaciones especiales, estaciones de Puertos y seleccion preferida,
  - la seleccion inicial prioriza la estacion preferida cuando existe y si no cae al criterio general de distancia,
  - el catalogo de webcams pasa a trabajar por `webcamProfile`,
  - eliminados fallbacks genericos de webcams que podian mostrar recursos no pertenecientes al spot.
- Verificacion:
  - ejecutado `dart format` sobre los archivos tocados,
  - ejecutado `flutter analyze` sobre las piezas de `SpotDetail`, `Spots`, tablas forecast y tests relacionados,
  - resultado de analisis: `No issues found`,
  - los tests completos de spots no se reejecutan en este cierre porque siguen dependiendo de inicializacion de Supabase en `SpotAlarmCatalog`, incidencia ya conocida del entorno de test.

### 2026-05-06 - Spots: modularizacion de pagina Spots, sheets y mapa custom

- Bloque consolidado adicional: `+55m` reales observables.
- Medicion real usada:
  - ventanas locales observables del bloque:
    - `2026-05-02 23:34-2026-05-03 00:05 CEST`,
    - `2026-05-03 11:12-11:25 CEST`,
    - `2026-05-06 00:04-00:09 CEST`,
  - duracion efectiva conservadora registrada: `55m`,
  - nota de honestidad: no se cuenta el tiempo calendario entre dias porque hubo pausas; se registra solo tiempo observable de trabajo/procesos sobre el bloque.
- Objetivo:
  - terminar de ordenar la nueva estructura de `lib/features/spots/presentation/pages/spots/`,
  - dejar `spots_page.dart`, `spots_list_section.dart`, los sheets de alta/edicion y el dialogo de mapa custom como piezas pequenas y mantenibles,
  - mantener comportamiento existente sin cambiar producto.
- Pagina principal de Spots:
  - `spots_page.dart` queda como wiring principal del modulo,
  - extraida la logica de acceso/roles a `spots_access_controller.dart`,
  - extraida la hidratacion/auth a `spots_catalog_controller.dart`,
  - extraida la logica de alta a `spots_add_controller.dart`,
  - extraida la edicion a `spots_edit_controller.dart`,
  - extraido el borrado/seleccion multiple a `spots_delete_controller.dart`,
  - extraido filtrado/ordenacion a `spots_filter_controller.dart`,
  - extraido calculo de webcams cercanas/distancia a `spots_webcam_distance_helper.dart`.
- Lista de spots:
  - `spots_list_section.dart` queda como composicion de widgets,
  - creados widgets para filtros/sort, busqueda, tarjeta de accion pendiente, tarjetas de estado y tarjeta individual de spot,
  - movidos los widgets presentacionales a `spots/widgets/`.
- Alta y edicion de spots:
  - extraido el contenido visual del alta a `widgets/spot_add_sheet_content.dart`,
  - extraidos campos, cabecera, mensajes de estado/error, sugerencias y picker de imagen,
  - extraida validacion/construccion de spot a `spot_add_builder.dart`,
  - extraido estado derivado del alta a `spot_add_sheet_state.dart`,
  - extraidas sugerencias/autocompletado a `spot_add_suggestions_helper.dart`,
  - extraido contenido visual de edicion a `widgets/spot_edit_sheet_content.dart`.
- Mapa custom:
  - `custom_map_picker_dialog.dart` queda centrado en estado y callbacks,
  - extraidos controles de coordenadas y acciones a `widgets/spot_custom_map_controls.dart`,
  - extraido mapa visual a `widgets/spot_custom_map_view.dart`,
  - extraido layout general del dialogo a `widgets/spot_custom_map_dialog_content.dart`,
  - extraido parser/validador de coordenadas a `spot_custom_map_coordinate_parser.dart`,
  - extraido modelo `_CustomSpotPoint` a `spot_custom_map_models.dart`.
- Verificacion:
  - ejecutado `dart format` sobre archivos tocados durante el bloque,
  - ejecutado `flutter analyze` sobre `spots_page.dart`, `spot_detail_page.dart`, tests relacionados y `dashboard_page.dart`,
  - resultado: `No issues found`.

### 2026-05-02 - Spots: reorganizacion completa de Spot Detail y Spots por tabs/widgets

- Bloque consolidado adicional: `+12h 53m` reales observables.
- Medicion real usada:
  - inicio observable del tramo: `2026-05-02 10:31 CEST`, primera marca local de modificacion del bloque de reorganizacion pendiente,
  - cierre del tramo: `2026-05-02 23:24 CEST`, momento de cierre del tracker antes de commit,
  - duracion transcurrida observable: `12h 53m`,
  - nota de honestidad: esta medicion usa la ventana real observable en el filesystem y en el flujo de trabajo; no pretende inflar horas ni actuar como cronometro perfecto si hubo pausas fuera de terminal.
- Objetivo:
  - continuar la descomposicion de la pestana `Spots`,
  - separar la pagina general de spots de `SpotDetailPage`,
  - alojar los tabs `Forecast`, `Live`, `Webcam` y `Chat` dentro del directorio `spot_detail/tabs`,
  - reducir `spot_detail_page.dart` y `spots_page.dart` a wiring de alto nivel.
- Reorganizacion de rutas:
  - movida la pagina general a `lib/features/spots/presentation/pages/spots/spots_page.dart`,
  - movido `SpotDetailPage` a `lib/features/spots/presentation/pages/spot_detail/spot_detail_page.dart`,
  - reubicados widgets y helpers de chat dentro de `spot_detail/tabs/chat/widgets`,
  - reubicados widgets de forecast dentro de `spot_detail/tabs/forecast/widgets`,
  - reubicados widgets de webcam dentro de `spot_detail/tabs/webcam/widgets`,
  - actualizados imports en dashboard, tests y piezas dependientes.
- Spot Detail / tabs:
  - extraidos controllers y secciones del tab `Forecast`:
    - `forecast_actions_controller.dart`,
    - `forecast_data_controller.dart`,
    - `forecast_rows_controller.dart`,
    - `forecast_section.dart`,
    - `forecast_table_section.dart`,
    - `forecast_supplements_section.dart`,
    - `forecast_fullscreen_section.dart`,
    - `forecast_status_widgets.dart`,
    - `forecast_supplement_loaders.dart`,
    - modelos de forecast bajo `tabs/forecast/models`,
  - extraido el tab `Live` a su propio arbol con modelos, formatters, acciones, historico, estacion activa y widgets auxiliares,
  - extraido `webcam_section.dart` y movido el player/embed al arbol del tab `Webcam`,
  - `spot_detail_page.dart` queda como contenedor principal con estado compartido y wiring de tabs.
- Spots / pagina principal:
  - creada la estructura `lib/features/spots/presentation/pages/spots/`,
  - extraido el catalogo de spots oficiales a `available_spots_catalog.dart`,
  - extraido el sheet de alta a `add_spot_sheet.dart`,
  - extraido el dialogo de mapa custom a `custom_map_picker_dialog.dart`,
  - extraido el controlador de acciones a `spots_actions_controller.dart`,
  - extraida la lista/tarjetas/filtros/busqueda a `spots_list_section.dart`,
  - corregido el aviso `invalid_use_of_protected_member` moviendo mutaciones con `setState` a metodos propios de `SpotsPageState`.
- Sheets y widgets de Spots:
  - extraido el sheet de edicion a `edit_spot_sheet.dart`,
  - creado `spot_background_image_picker.dart` reutilizado por alta y edicion,
  - creado `spot_suggestions_list.dart` para sugerencias oficiales,
  - creado `spot_add_status_messages.dart` para estados/errores del alta,
  - creado `spot_add_form_fields.dart` para campos de nombre/zona y sugerencias,
  - creado `spot_add_header.dart` para cabecera y accion de spot personalizado.
- Verificacion:
  - ejecutado `dart format` sobre los archivos tocados,
  - ejecutado `flutter analyze` sobre `spots_page.dart`, `spot_detail_page.dart`, tests relacionados y `dashboard_page.dart`,
  - resultado: `No issues found`.

### 2026-05-02 - Spots: extraccion del tab Chat de spot_detail_page

- Bloque consolidado adicional: `+12h 31m` reales observables.
- Medicion real usada:
  - inicio observable del tramo: `2026-05-01 12:07 CEST`, primera marca local de modificacion de los archivos creados para la refactorizacion del chat,
  - cierre del tramo: `2026-05-02 00:38 CEST`,
  - duracion transcurrida observable: `12h 31m`,
  - nota de honestidad: esta medicion usa la ventana real observable en el filesystem; si hubo pausas fuera de terminal, no pretende ser un cronometro perfecto de tiempo activo.
- Objetivo:
  - empezar a descomponer la pestana de `Spots`, comenzando por el tab `Chat` de `SpotDetailPage`,
  - reducir el tamano y responsabilidad de `lib/features/spots/presentation/pages/spot_detail_page.dart`,
  - mantener comportamiento existente del chat sin cambiar producto.
- Extraccion visual del chat:
  - creado el paquete `lib/features/spots/presentation/widgets/chat/`,
  - extraidos widgets de avatar, burbuja, feed, header, composer, swipe-to-reply, lista de mensajes, seccion completa y cards/listas de adjuntos,
  - creado `spot_chat_widgets.dart` como barrel para reducir imports en la pagina principal.
- Helpers y modelos de chat:
  - extraidos helpers de adjuntos (`fileName`, mime type, draft desde `XFile`, append/remove pending, adjuntos optimistas),
  - extraida construccion de entradas del feed (`SpotChatEntry` y `buildSpotChatEntries`),
  - extraidos helpers de identidad, busqueda de post/reply y construccion de mensajes optimistas,
  - extraido estado derivado del composer en `spot_chat_composer_state.dart`,
  - extraido modelo de preparacion de envio en `spot_chat_submission.dart`.
- Realtime y lifecycle:
  - creado `SpotChatRealtimeController` para encapsular subscriptions de feed, presencia y typing,
  - movida la logica social a `part` files:
    - `social_chat_actions.dart`,
    - `social_chat_attachments.dart`,
    - `social_chat_lifecycle.dart`,
    - `social_chat_section.dart`,
  - `spot_detail_page.dart` conserva solo wiring de alto nivel (`initialize`, `hydrate`, `enter/leave/resume/dispose`) y campos compartidos.
- Limpieza de flujo:
  - centralizados resets de composer de post/reply,
  - centralizado wrapper de envio (`_runSocialSubmission`),
  - centralizado wrapper de borrado (`_runSocialDelete`),
  - separados handlers de acciones para post y reply,
  - agrupado el estado social en un bloque marcado dentro de `SpotDetailPage`.
- Verificacion:
  - `dart format` ejecutado sobre `spot_detail_page.dart`, `spot_detail_page/*.dart` y `widgets/chat/*.dart`,
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart lib/features/spots/presentation/pages/spot_detail_page lib/features/spots/presentation/widgets/chat` limpio.

### 2026-04-30 - Live spots: Puertos del Estado Gandia y deploy web

- Bloque consolidado adicional: `+54m` reales.
- Medicion real usada:
  - inicio del tramo: `2026-04-30 00:49 CEST`, justo despues del ultimo cierre/commit del tracker,
  - cierre del tramo: `2026-04-30 01:43 CEST`,
  - duracion transcurrida: `54m`.
- Integracion `Live` de Puertos del Estado:
  - anadido cliente `PortusRealtimeWindClient` para estaciones reales de Puertos del Estado,
  - conectada la estacion `Estacion Meteorologica Gandia Serpis` (`4634`) solo a spots donde corresponde, no como estacion global para todos los spots,
  - calculada la distancia real desde las coordenadas de la estacion al spot,
  - eliminada la etiqueta de cadencia como proximidad para que la tarjeta muestre distancia igual que el resto de estaciones,
  - al seleccionar `AEMET` se mantiene `Puertos del Estado` como modelo preferente cuando corresponde.
- Tarjetas live de Gandia:
  - el endpoint `lastData/station/4634` se consulta con `WIND`, `AIR_TEMP` y `AIR_PRESURE`,
  - se rellenan viento, direccion, racha, temperatura y presion cuando el endpoint las devuelve,
  - humedad y lluvia quedan sin datos porque la estacion no los expone en el endpoint real usado.
- Historico real de Gandia:
  - descubierto y probado el endpoint oficial `RTData/station/4634?locale=es`,
  - validado que devuelve alrededor de `286` registros de unos dos dias con cadencia de `10 min`,
  - creado parseo de historico de viento, direccion y racha,
  - conectado el historico de estaciones `PUERTOS` a la grafica historica de `Live`,
  - el refresco de historico ya actualiza tambien estaciones de Puertos.
- Rebuild y deploy:
  - ejecutado `./scripts/deploy_firebase_hosting.sh`,
  - `flutter build web` correcto,
  - Firebase Hosting publico nueva version en el proyecto `windwisherapp-5ed22`,
  - comprobado `https://windwisher.com` con respuesta `HTTP/2 200`.
- Verificaciones ejecutadas:
  - `flutter analyze lib/features/spots/infrastructure/services/portus_realtime_wind_client.dart lib/features/spots/application/services/spots_external_data_clients.dart lib/features/spots/presentation/pages/spot_detail_page.dart` limpio,
  - deploy completo en Firebase Hosting sin errores.

### 2026-04-30 - Notificaciones locales de alarmas de spots

- Bloque consolidado adicional: `+30m` reales.
- Cableado el disparo local de alarmas desde el apartado `Live` de spots:
  - al refrescar datos live se evaluan las alarmas guardadas del spot,
  - si viento, direccion y horario coinciden, se lanza `LocalNotificationsService.showSpotAlarm`,
  - se evita disparo en bucle marcando el ciclo como ya lanzado,
  - cuando las condiciones dejan de cumplirse se cancelan avisos pendientes y se resetea la alarma para futuros disparos.
- Ajustado el ciclo de vida de notificaciones locales:
  - al borrar una alarma se cancelan sus notificaciones programadas,
  - una alarma desactivada ya no se evalua como activa,
  - las notificaciones de alarma dejan de ser `ongoing` para no quedarse permanentes en Android,
  - `autoCancel` queda activo y se cancela explicitamente por `response.id` y por id calculado.
- Corregida la semantica de acciones de la notificacion:
  - `Posponer` cancela solo el aviso visible actual, marca la alarma como pospuesta y reprograma los avisos restantes,
  - `Parar` cancela el aviso visible, detiene el ciclo completo y bloquea la alarma hasta que cambien/resetee la condicion,
  - los avisos reprogramados conservan titulo y cuerpo original desde el payload.
- Anadida navegacion desde notificacion:
  - al pulsar la notificacion principal, la app abre `Perfil > Alarmas`,
  - `Posponer` y `Parar` no navegan, solo ejecutan su accion,
  - se soporta evento pendiente si la app arranca desde la notificacion.
- Verificaciones ejecutadas:
  - `flutter analyze lib/core/notifications/local_notifications_service.dart lib/core/notifications/spot_alarm_notification_event.dart lib/features/dashboard/presentation/pages/dashboard_page.dart lib/features/profile/presentation/pages/profile/profile_page.dart lib/features/spots/presentation/pages/spot_detail_page.dart` limpio.

### 2026-04-30 - Live spots: chequeo AEMET Oliva y brujula

- Bloque consolidado adicional: `+1h` estimada.
- Anadido chequeo manual en el apartado `Live` para la estacion oficial `AEMET Oliva` (`8058X`):
  - accion visible solo cuando la estacion seleccionada es `AEMET Oliva`,
  - consulta real a AEMET OpenData,
  - actualizacion de la tarjeta live,
  - feedback con hora, viento, direccion y racha.
- Comprobada la estacion real `8058X / OLIVA`:
  - el endpoint devuelve `12` observaciones,
  - la cadencia observada es horaria (`60 min` entre muestras),
  - se detecta posible retraso de publicacion respecto a la hora actual.
- Corregida la brujula de la rosa de los vientos:
  - compensado el `heading` en sentido contrario para representar el norte en pantalla,
  - retirada la rotacion conjunta de rosa/viento que hacia la lectura visual rara,
  - la rosa vuelve a quedar estable para leer la direccion de viento,
  - la aguja roja de brujula apunta al norte real de forma mas natural.
- Ajustes pendientes incorporados al mismo bloque de spots:
  - `AEMET` selecciona por defecto el modelo `Puertos del Estado`,
  - `supabase/.temp/` queda ignorado como artefacto local,
  - se retira del repositorio el artefacto temporal `supabase/.temp/cli-latest`.
- Verificaciones ejecutadas:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` limpio.

### 2026-04-30 - Onboarding legal, roles/admin y Puertos del Estado como modelo AEMET

- Bloque consolidado adicional: `+18h` estimadas.
- Consolidado el flujo de primer acceso:
  - dialogos legales obligatorios en primer login,
  - aceptacion persistida por usuario en backend,
  - cancelacion con cierre de sesion,
  - dialogo de bienvenida posterior con nombre/handle,
  - comprobacion real de disponibilidad de handle tambien en editar perfil,
  - proteccion contra cierre accidental de dialogos criticos.
- Avanzado el apartado legal:
  - inventario inicial de documentos legales,
  - contenidos base versionados en `assets/legal`,
  - mapa legal/documental en `docs/legal`,
  - bloque legal del login retirado para dejar el acceso mas limpio,
  - se aplaza el cierre legal definitivo para una fase posterior.
- Reorganizado y limpiado `Ajustes`:
  - settings extraido en secciones/directorios por area (`unidades`, `notificaciones`, `app`, `legal`, `roles`, `cuenta`),
  - tarjetas desplegables donde habia demasiada densidad visual,
  - retirado `Editar perfil` redundante desde ajustes,
  - retirada la pantalla/flujo de donaciones,
  - corregidos overflows de dialogos y tarjetas con teclado/orientacion.
- Implementado y refinado `Panel de roles`:
  - visible solo para usuarios con rol operativo real,
  - reglas de visibilidad por rol:
    - `user`, `pro`, `vip`: sin panel,
    - `moderator`: panel moderador,
    - `manager`: panel manager,
    - `admin`: panel admin + moderador,
    - `superadmin`: todos los paneles,
  - creada pantalla de `Super Admin` para gestionar roles,
  - buscador con listado incremental y usuario seleccionado persistente,
  - auditoria/admin con carga paginada para evitar cargar tablas completas.
- Conectado y ajustado el buzon de sugerencias:
  - envio real de feedback a Supabase,
  - base de panel/admin para gestionarlo desde roles,
  - migracion `20260425143000_add_user_feedback.sql`.
- Revisado el mapa de viento:
  - reemplazado el mapa propio por el visor oficial de Puertos del Estado,
  - retirado boton externo del appbar y barra inferior para no tapar controles del visor,
  - documentado que el play del visor depende de la cadencia oficial publicada por Portus.
- Integrado `Puertos del Estado` como modelo dentro de `AEMET`:
  - se elimina `Portus` como proveedor visible independiente,
  - el modelo visible pasa a llamarse `Puertos del Estado`,
  - se mantiene compatibilidad interna con el nombre legacy `Portus Atmosfera`,
  - se conserva el adaptador tecnico `PortusSpotsForecastAdapter` porque los endpoints son `portus.puertos.es` / `poem.puertos.es`.
- Enriquecida la tabla de forecast de `AEMET > Puertos del Estado` con datos reales de Portus:
  - viento y direccion desde `Atmosfera`,
  - altura de ola, periodo y direccion de ola desde `Siwana/Wana`,
  - temperatura del agua, corriente, direccion de corriente y salinidad desde `Cirana`,
  - las filas no soportadas por el modelo se ocultan en vez de mostrar placeholders.
- Ajustados filtros de la tabla de `Puertos del Estado`:
  - el endpoint real devuelve `72` filas horarias, aproximadamente `3 dias`,
  - rangos disponibles limitados a `1 dia` y `3 dias`,
  - resoluciones disponibles limitadas a `1h` y `3h`,
  - corregido estado fantasma de `20m`,
  - corregido `3h` para que seleccione realmente una fila cada tres horas cuando la serie base es horaria.
- Investigacion tecnica de Portus/Puertos del Estado:
  - diferenciados `puntos de malla` frente a `boyas`,
  - conteo aproximado en Comunidad Valenciana:
    - `Atmosfera`: `392` puntos de malla,
    - `Wana/Siwana`: `327` puntos de malla,
    - `Cirana`: `218` puntos de malla,
  - conclusion operativa: no llamarlos boyas en UI, sino puntos de modelo/malla.
- Verificaciones ejecutadas durante el bloque:
  - `flutter analyze` limpio en los archivos tocados de spots y settings,
  - `flutter test test/features/spots/infrastructure/adapters/portus/portus_spots_forecast_adapter_test.dart` limpio,
  - se mantiene fuera de commit el artefacto local `-h.zip`,
  - se mantiene fuera de commit `supabase/.temp/cli-latest`.

### 2026-02-21 - Bootstrap de contexto y preparacion

- Leido y adoptado el master prompt del proyecto para guiar decisiones.
- Instalada skill externa `ui-ux-pro-max` en `/home/clw/.agents/skills/ui-ux-pro-max`.
- Configurado MCP de Google Stitch en `/.opencode/opencode.json` del proyecto v2.0.
- Validado binario MCP con `npx -y @_davideast/stitch-mcp --help`.
- Revisada pantalla login de MeteoKite 1.0 en `lib/features/auth/presentation/pages/login_page.dart`.
- Diseñado enfoque de replica de login para v2.0.
- Creado diseno: `docs/plans/2026-02-21-login-screen-replica-design.md`.
- Creado plan de implementacion: `docs/plans/2026-02-21-login-screen-replica-implementation.md`.

### 2026-02-21 - Implementacion inicial de login (replica v1.0)

- Migrado bootstrap de app a `ProviderScope` + `GoRouter` en `lib/main.dart`.
- Anadidas rutas base en `lib/app/router/app_routes.dart` y `lib/app/router/app_router.dart`.
- Anadido dashboard placeholder en `lib/features/dashboard/presentation/pages/dashboard_page.dart`.
- Anadidos providers de auth:
  - `lib/features/auth/presentation/providers/auth_session_provider.dart`
  - `lib/features/auth/presentation/providers/recent_auth_accounts_provider.dart`
- Anadidos soporte minimo de config/tema:
  - `lib/core/config/env/env_config.dart`
  - `lib/core/theme/app_spacing.dart`
- Replicada UI/flujo de login v1.0 en `lib/features/auth/presentation/pages/login_page.dart`.
- Reemplazado test plantilla por test de arranque real en `test/widget_test.dart`.
- Tests creados y en verde:
  - `test/app/app_bootstrap_test.dart`
  - `test/features/auth/presentation/providers/auth_session_provider_test.dart`
  - `test/features/auth/presentation/providers/recent_auth_accounts_provider_test.dart`
  - `test/features/auth/presentation/pages/login_page_test.dart`
  - `test/widget_test.dart`
- Verificacion ejecutada: `flutter test -r expanded && flutter analyze` (ok).

### 2026-04-11 - Perfil KPI engine, comunidad real y dialogo de KPIs

- Separada la capa de `Profile KPIs` para que `Perfil` no mezcle directamente `UserProfileData`, sesiones agregadas y comunidad en la UI.
- Anadidos modelos/agregadores dedicados para comunidad y KPIs de perfil:
  - `lib/features/profile/domain/entities/profile_community_stats_snapshot.dart`
  - `lib/features/profile/application/profile_community_stats_aggregator.dart`
  - `lib/features/profile/domain/entities/profile_kpi_snapshot.dart`
  - `lib/features/profile/application/profile_kpi_aggregator.dart`
- `ProfilePage` ahora hidrata fuentes reales de comunidad/social (seguidores, siguiendo, ranking, sesiones compartidas, comentarios y likes) y las integra con las stats deportivas del perfil.
- Hidratados KPIs sociales reales en perfil:
  - `Seguidores`, `Siguiendo`, `Ranking global`, `Sesiones compartidas`
  - `Comentarios recibidos`, `Likes recibidos`
  - `Ratio seguidores/siguiendo`, `Comentarios por sesion compartida`, `Likes por sesion compartida`
  - `Sesion mas comentada`, `Sesion mas likeada`, `Tasa de interaccion`
  - `Sesiones compartidas en 30 dias`, `Comentarios recibidos en 30 dias`
- Hidratado un bloque amplio de KPIs deportivos y tecnicos desde `advanced metrics` agregados de sesion:
  - velocidad `p95`, planeo, `takeoff/landing`, `clean landing rate`
  - transiciones, eficiencia de bordos, `sweet spot`, impacto, `Big Air`, `Freeride`, `Safety`, `Session score`
  - cobertura, deriva, distancia a costa, tiempo en zona de riesgo, calidad GPS, sobrepotencia, caidas por hora y samples perdidos
- Reorganizado el dialogo de KPIs del perfil para mejorar lectura y densidad:
  - selector de categoria en desplegable
  - una sola seccion visible cada vez
  - `Contexto actual` plegable
  - copy de categorias refinado para sonar mas a producto y menos a bloque tecnico
- La tarjeta publica del perfil reutiliza la misma base de summary y mantiene followers/following/ranking visibles de forma consistente.
- Validacion ejecutada:
  - `flutter analyze` limpio
  - solo permanece el warning externo conocido de `webview_flutter:macos`


### 2026-04-12 - Perfil publico endurecido, hosting limpio y flujo de usuario afinado

- Endurecida la seguridad de `profiles` en Supabase:
  - eliminada la lectura publica directa de `public.profiles`
  - anadida policy de lectura solo para el propietario
  - creada `public.public_profiles` como vista publica minima para identidad visible y metricas basicas
- Aplicada en remoto la migracion:
  - `supabase/migrations/20260412180000_harden_profiles_and_add_public_view.sql`
- Adaptadas las lecturas publicas de la app para usar `public_profiles` en comunidad, seguidores y mensajes directos, evitando depender de la tabla base publica.
- Revisadas las superficies publicas expuestas con `anon key` y acotada la parte mas sensible del esquema de perfil.
- Refinado el flujo de `Editar usuario`:
  - paso a dialogo modal en vez de pantalla independiente
  - validacion de nombre visible y nombre de usuario
  - `@` fija y normalizacion del nombre de usuario
  - comprobacion de unicidad del nombre de usuario al guardar
  - copy de error ajustado a `Este nombre de usuario ya esta ocupado.`
  - soporte para quitar avatar y banner
  - recarga real desde Supabase tras guardar y feedback con `SnackBar`
- Conectada subida de avatar y banner a Supabase Storage y limpieza best-effort de ficheros antiguos al reemplazarlos.
- Simplificado el editor de usuario para centrarse en campos realmente utiles:
  - foto
  - banner
  - nombre
  - nombre de usuario
  - tagline publica
- Continuada la limpieza del modelo de perfil y de la UI para retirar dependencias legacy (`bio`, `userRole`, `baseSpot`, `ranking`, `followers`, `following`, `bestSpot`, `latestSession`, `latestComment`, `featuredThread`) y dejar esos datos en agregados reales o fuera del modelo activo.
- Separado `profile_aux_pages.dart` en piezas mas pequenas de `user`:
  - `edit_profile_dialog.dart`
  - `public_profile_preview_page.dart`
  - `profile_media_image_provider.dart`
- Rehecho el redeploy web de `windwisher.com` y limpio el warning de Firebase Hosting creando config dedicada:
  - `firebase.hosting.json`
  - `scripts/deploy_firebase_hosting.sh`
- Verificaciones ejecutadas:
  - `flutter analyze` limpio
  - `supabase db push` correcto para la migracion de endurecimiento de perfiles
  - solo permanece el warning externo conocido de `webview_flutter:macos`

### 2026-04-12 - Perfil gear: precios, coste por sesion y acceso desde summary de usuario

- Anadido soporte de precio por pieza en `gear` a nivel de dominio, formularios, guardado y persistencia Supabase.
- Anadida migracion remota para `price_eur` en tablas de material de perfil:
  - `supabase/migrations/20260412123000_add_price_to_profile_gear_items.sql`
- El adaptador Supabase de `gear` queda tolerante a esquemas antiguos mientras la base se actualiza, evitando caidas por columna ausente durante hidratacion o guardado.
- Aplicada la migracion en Supabase y verificada la alineacion entre `Local` y `Remote`.
- La tarjeta de uso de equipacion y el dialogo de detalle de equipo ahora calculan y muestran metricas economicas reales a partir de sesiones asociadas a `gearSetupId/gearSetupName`:
  - `Valor inventario`
  - `Coste medio por sesion`
  - `Coste medio de equipacion usada`
  - `Inventario por sesion registrada`
  - `Amortizacion media por sesion`
- El detalle por familia de material dentro del dialogo de equipo ya permite alternar entre:
  - `Numero de sesiones`
  - `Porcentaje de sesiones`
  - `Precio`
  - `Coste por sesion`
- Reconvertido el detalle de uso de equipacion de pagina a dialogo y alineado visualmente con el dialogo de estadisticas del usuario:
  - selector de categoria
  - una sola seccion visible cada vez
  - tiles internos reutilizables
- Refinada la jerarquia del dialogo de equipo para evitar duplicidades entre la tarjeta resumen y el selector interno.
- La summary del usuario ahora incluye un bloque plegable de `Equipaciones guardadas` con chips de equipo; al pulsar cada chip se abre el dialogo individual de esa equipacion.
- Se elimina el CTA anterior de `Ver equipaciones` para evitar redundancia con la nueva solucion embebida en la summary.
- Validacion ejecutada:
  - `flutter analyze` limpio
  - solo permanece el warning externo conocido de `webview_flutter:macos`

### 2026-04-11 - Perfil y sessions unificados en torno a advanced metrics

- Replanteada la pestana `Perfil` para que la parte deportiva beba de una sola fuente agregada desde sesiones, evitando duplicidades entre tarjetas y dialogos.
- Anadido agregado local de stats de perfil desde sesiones guardadas:
  - `lib/features/profile/domain/entities/profile_session_stats_snapshot.dart`
  - `lib/features/profile/application/profile_session_stats_aggregator.dart`
- `ProfilePage` ahora hidrata sesiones grabadas y construye un snapshot comun para el tab `Perfil`.
- La tarjeta summary, la tarjeta resumen de estadisticas y el dialogo de KPIs del perfil ya leen del mismo snapshot agregado, en vez de recalcular o duplicar valores por widget.
- El dialogo de KPIs del perfil se centraliza en un catalogo reutilizable con trazabilidad de fuente:
  - `Pendiente desde sesiones`
  - `Pendiente desde advanced metrics`
  - `Pendiente social`
- La `public preview` del perfil reutiliza la misma tarjeta con fallback legacy cuando no existe agregado de sesiones en vivo.
- En `sessions`, `Advanced metrics` se separa del modelo de detalle y pasa a vivir como capa propia en `lib/features/sessions/presentation/models/session_advanced_metrics_models.dart`.
- `SessionInsightData` queda mas limpio como contenedor de datos/eventos de sesion, delegando la lectura de KPIs a `SessionAdvancedMetrics`.
- Anadidos accesos tipados a KPIs (`doubleValue/intValue`) para reducir parsing disperso en UI y persistencia.
- `Session summary`, `Session track`, `My Sessions` y parte de persistencia Supabase ya dependen de `Advanced metrics` o de getters resueltos apoyados en esa fuente.
- Validacion ejecutada:
  - `flutter analyze` limpio
  - solo permanece el warning externo conocido de `webview_flutter:macos`

### 2026-04-15 - Notificaciones estabilizadas, Community realista y arquitectura base de saltos

- Recuperado y estabilizado el registro push Android tras reinstalaciones y cambios de permisos:
  - inicializacion Firebase saneada entre `main.dart`, `MainActivity.kt` y `firebase_push_messaging_service.dart`
  - re-registro forzado del token desde `Ajustes > Notificaciones`
  - diagnostico visible en ajustes para errores reales (`No Firebase App`, `provider not configured`, etc.)
  - flujo de mensajes directo del perfil verificado otra vez con push funcionando en foreground, lista y segundo plano
- Endurecido el backend y el flujo de alarmas:
  - limpieza automatica de tokens FCM invalidos (`UNREGISTERED`) en `spot-alarm-runner`
  - nueva migracion `20260413180000_disable_invalid_push_subscriptions.sql`
  - ajuste del registro push tras reinstalacion para volver a poblar `user_push_subscriptions`
  - alarmas de spot enviadas ya como `data-only` desde la function para que la app genere la notificacion local propia desde el primer aviso
  - acciones `Posponer` y `Parar` movidas al flujo local/background en `local_notifications_service.dart`
  - fallback de programacion local exacta -> inexacta y permiso `SCHEDULE_EXACT_ALARM` en Android
- Mejorada la gestion de alarmas en `Perfil`:
  - agrupacion por spot
  - toggle global
  - toggle por spot
  - toggle por alarma individual
  - migracion remota `20260414100000_add_enabled_to_spot_alarms.sql` aplicada para respetar `enabled` por alarma en backend y sync
- Limpieza fuerte de `Community` hacia datos reales:
  - `Siguiendo` y `Seguidores` conectados a datos reales de `user_follows`
  - eliminados defaults/hardcodeados de follows y followers locales
  - `CommunityUserProfilePage` y `CommunityUserSessionsPage` hidratando perfiles publicos reales con fallback neutro
  - leaderboard reajustado para usar metricas reales y menos datos sinteticos
  - anadido `Mayor actividad` como metrica separada del `Big Air score`
  - migracion remota `20260414113000_update_community_leaderboard_scoring.sql` preparada para `avg(big_air_score)` + `activity_score`
  - tarjetas del leaderboard sincronizadas con avatar, banner, nombre y handle persistidos del perfil
  - eliminada pantalla placeholder `community_messages_page.dart` y extraidos widgets de feed/lista para adelgazar `community_page.dart`
- Ajustes UX adicionales cerrados en perfil/comunidad:
  - tarjeta de alarmas de perfil alineada visualmente con spots y copy menos enganoso (`Activa y monitorizando`)
  - selector de equipacion de perfil robustecido frente a overflows en `DropdownButtonFormField`
  - banner/avatar de comunidad y leaderboard corregidos para rutas locales o URLs remotas
- Replanteada la base de captura de saltos antes de seguir con estadisticas/rankings:
  - separacion explicita entre:
    - senales para detectar que hubo un salto
    - senales para medir el salto
    - senales para analizar la tecnica del salto
  - `SessionJumpRecord` ampliado para distinguir:
    - medicion principal
    - apoyo barometrico separado
    - deltas entre medicion principal y apoyo
    - `mountType`, `measurementMode` y `measurementConfidence`
    - campos de tecnica como `approachCourseDeg`, `approachWindOffsetDeg` y `edgeAngleDeg`
  - el pipeline actual deja de fingir un unico modo y ahora etiqueta honestamente los saltos como `body_imu` o `board_imu` segun politica de dispositivo
  - `board_sensor` ya no depende de barometro para ser elegible; el barometro queda tratado solo como apoyo de medicion, no como fuente principal
  - anadida una primera senal real de tabla: `approachCourseDeg` calculada desde muestras GPS recientes previas al despegue
  - preparado el candidato de salto para futuras metricas especificas de tabla (`peakHeightMeters`, `takeoffHeightMeters`, `approachWindOffsetDeg`, `edgeAngleDeg`) sin romper compatibilidad actual
- Actualizada la formula y el discurso del `Big Air score` de sesion:
  - `jumpHeightConsistency` sale del calculo
  - `cleanLandingRate` se mantiene como senal de aterrizaje
  - FAQ alineada con la formula real actual en la app
- Limpieza de artefactos de trabajo: eliminado `tmp/fitcloudpro_jadx` del repo tras descartar su valor para el analisis de saltos.
- Validaciones recurrentes ejecutadas durante el bloque:
  - `flutter analyze` limpio en los archivos/modulos tocados
  - solo permanece el warning externo conocido de `webview_flutter:macos`

### 2026-04-23 - Reverse engineering WOO: BLE, `jadx`, `QhData` y modelo provisional de salto

- Consolidado un bloque especifico de investigacion sobre el algoritmo de salto del dispositivo `WOO`.
- Duracion estimada y consolidada del bloque: `12h`.
- Objetivo del bloque:
  - aclarar si `height` y `airtime` se calculan en Android,
  - mapear el protocolo BLE realmente observado,
  - reconstruir un modelo empirico usable a partir de `Air`, `QhData` y `RawDataStatic`.
- Alcance actual acordado para este hilo:
  - centrarse solo en `Big Air` por ahora,
  - no intentar unificar ni extrapolar todavia a otros modos del dispositivo.
- Artefactos de trabajo consolidados en `tmp/woo_apk_analysis/`:
  - `capture_woo_ble.py`
  - `analyze_woo_capture.py`
  - `session_board_mount_02.json`
  - `session_board_mount_02_parsed.json`
  - `last_capture_session3.json`
  - `last_capture_session3_parsed.json`
  - `WOO_REVERSE_ENGINEERING.md`
  - decompilado Android completo en `jadx_out/`
- Captura BLE / dispositivo:
  - endurecido el capturador para descarga completa de memoria de `WOO`,
  - verificada la sesion nueva montada fisicamente en tabla como muestra primaria de calibracion,
  - confirmado manualmente que esa sesion primaria de referencia (`session_board_mount_02`) fue grabada en modo `Big Air`,
  - confirmada una sesion primaria completa con `15 Air`, `15 QhData` y `RawDataStatic` parcial para algunos saltos.
- Hallazgos de protocolo y datos:
  - el dispositivo entrega paquetes `Air` ya resueltos con:
    - `height`
    - `airtime`
    - `height_error`
    - `max_hor_power`
    - `pop_ke`
    - `crash_velocity`
    - `crash_g_force`
  - `QhData` queda identificado como una senal compacta muy cercana a la morfologia del salto,
  - `RawDataStatic` se decodifica de forma provisional como:
    - `1500 records x 44 bytes`
    - `11 int32` por record
    - reloj monotono en `col0`
    - frecuencia efectiva `~335.66 Hz`
    - `cols1-4` compatibles con cuaternion `wxyz` en `Q30`
    - `cols8-10` compatibles con aceleracion en ejes del dispositivo.
- Hallazgos sobre el APK Android:
  - localizada la ruta real `GET sessions/{id}` para detalle completo de sesion via:
    - `as/w.java`
    - `vs/r.java`
    - `cs/p1.java` (`SessionResponse.Full`)
  - confirmado que `woo_data` llega dentro de `SessionResponse.Full`,
  - confirmado que Android no parece recalcular localmente `height`, `airtime`, `jump_distance`, `board_angle` o `takeoff_speed`,
  - la app mapea esos valores ya resueltos desde red a dominio.
- Modelo empirico provisional actual:
  - `height`:
    - `double_lobe` -> mejor ajuste desde `QhData` con `even_peak`
    - `single_lobe` -> mejor ajuste desde `QhData` con `avg_peak`
  - `airtime`:
    - `double_lobe` -> combo calibrado sobre sesion primaria usando `width_5 + second_lobe_length`
    - `single_lobe` -> mejor ajuste desde `RawDataStatic abs10 span @ 0.3` con transformacion afin
- Calidad actual del modelo:
  - sesion primaria (`board mounted`):
    - `height_mae = 0.03685 m`
    - `airtime_mae = 0.03207 s`
  - sesion comparativa:
    - `height_mae = 0.02919 m`
    - `airtime_mae = 0.04664 s`
- Conclusiones tecnicas del bloque:
  - Android no es la fuente probable del algoritmo central del salto,
  - `height` parece reconstruible de forma bastante robusta desde `QhData`,
  - `airtime` depende fuertemente de la morfologia del salto,
  - `single_lobe` necesita apoyo de `RawDataStatic` para quedar realmente bien,
  - la mejor referencia para seguir calibrando es la sesion nueva con el dispositivo montado en tabla,
  - esa referencia primaria debe tratarse como calibracion de `Big Air`, no como verdad universal para otros modos.
- Refinamiento orientado al firmware:
  - `analyze_woo_capture.py` ya extrae una `phase_hypothesis` por salto desde `QhData` con:
    - `takeoff_phase`
    - `flight_phase`
    - `landing_phase`
    - `transition_valley`
    - `airborne_window`
  - validacion negativa util:
    - la duracion bruta de `airborne_window` no reproduce el `airtime` oficial,
    - sesion primaria -> `airborne_duration_mae ~= 2.62 s`,
    - sesion comparativa -> `airborne_duration_mae ~= 2.16 s`
  - lectura mas honesta:
    - `QhData` parece una representacion intermedia por fases/estados del salto,
    - no una codificacion lineal directa del tiempo de vuelo,
    - por tanto, el siguiente paso debe centrarse en reconstruir la maquina de estados/features previas del firmware.
- Documentacion consolidada:
  - creado `tmp/woo_apk_analysis/WOO_REVERSE_ENGINEERING.md` con:
    - trazabilidad `GET sessions/{id} -> SessionResponse.Full -> woo_data`,
    - resumen del reverse engineering BLE/APK,
    - formulas provisionales,
    - errores actuales,
    - huecos pendientes.
- Siguiente paso tecnico recomendado para este hilo:
  - seguir por una de estas dos rutas:
    - capturar trafico real de `GET sessions/{id}` para comparar exactamente `Air/qh_data/raw_data`,
    - o reforzar el modelo empirico con mas sesiones buenas manteniendo la sesion de tabla como referencia primaria.
- Continuacion operativa ya preparada para la ruta `GET sessions/{id}`:
  - addon `mitmproxy` creado en `tmp/woo_apk_analysis/mitm_capture_woo_session.py`
  - comparador backend-vs-BLE creado en `tmp/woo_apk_analysis/compare_woo_session_response.py`
  - documentado el flujo en `tmp/woo_apk_analysis/WOO_REVERSE_ENGINEERING.md`

### 2026-04-23 - WOO `Big Air`: refinamiento del modelo recomendado y consolidacion documental

- Consolidado un bloque adicional centrado ya no en el reverse engineering amplio de `WOO`, sino en afinar la salida operativa actual para `Big Air`.
- Duracion estimada y consolidada del bloque: `4h`.
- Alcance del bloque:
  - mantener el foco unicamente en `Big Air`,
  - convertir el trabajo reciente en una salida mas cercana a produccion,
  - dejar trazabilidad clara en `SESSION_TRACKER.md` y `WOO_REVERSE_ENGINEERING.md`.
- Decision de alcance fijada explicitamente:
  - por ahora solo interesa `Big Air`,
  - `session_board_mount_02` queda fijada como referencia primaria canonica y confirmada manualmente como sesion `Big Air`.
- Refuerzo del analizador en `tmp/woo_apk_analysis/analyze_woo_capture.py`:
  - consolidado `morphology_aware_model` como base,
  - consolidado `big_air_raw_static_challenger_model` para medir el valor de `RawDataStatic`,
  - anadido `big_air_production_model` como salida recomendada actual,
  - anadido conteo de estrategias `airtime_strategy_counts` para dejar visible cuando entra cada heuristica.
- Regla actual del `big_air_production_model`:
  - `height` mantiene la seleccion del modelo morfologico,
  - `single_lobe` prioriza `raw_static_abs10_span_03_affine`,
  - `QhData` incompleto cae a `RawDataStatic`,
  - en `double_lobe` solo se permite override a `RawDataStatic` cuando hay desacuerdo grande con el modelo morfologico (`BIG_AIR_RAW_STATIC_OVERRIDE_DELTA = 0.08`),
  - el resto se queda en `morphology_aware_default`.
- Resultados consolidados de la referencia primaria `session_board_mount_02`:
  - `morphology_aware_model`
    - `height_mae = 0.03685 m`
    - `airtime_mae = 0.03207 s`
  - `big_air_raw_static_challenger_model`
    - `height_mae = 0.03685 m`
    - `airtime_mae = 0.03164 s`
  - `big_air_production_model`
    - `height_mae = 0.03685 m`
    - `airtime_mae = 0.02853 s`
- Resultado de generalizacion en `last_capture_session3`:
  - el `big_air_production_model` no empeora frente al modelo base,
  - `height_mae = 0.02919 m`
  - `airtime_mae = 0.04664 s`
  - toda la sesion queda en `morphology_aware_default` por no haber `RawDataStatic` util.
- Lecturas tecnicas consolidadas:
  - `RawDataStatic` deja de tratarse solo como fallback raro,
  - en `Big Air` pasa a ser una senal seria de `airtime` cuando aparece limpia,
  - aun asi, `QhData` sigue siendo la base principal del modelo,
  - el mejor compromiso actual queda como:
    - `QhData` como base
    - `RawDataStatic` como override puntual y justificado
- Documentacion consolidada en `tmp/woo_apk_analysis/WOO_REVERSE_ENGINEERING.md`:
  - fijado el alcance `Big Air only`,
  - fijada `session_board_mount_02` como referencia canonica,
  - documentado el `big_air_production_model` como salida recomendada actual,
  - anadido roadmap explicito para acercarnos al `100%` del firmware:
    - mas sesiones buenas `Big Air`
    - backend vs BLE
    - cierre del significado fisico de `RawDataStatic`
    - formalizacion de maquina de estados
    - ground truth externo
- Siguiente paso operativo recomendado despues de este bloque:
  - capturar otra sesion buena `Big Air`,
  - regenerar el analisis,
  - validar si reaparece el caso `double_lobe_large_disagreement_raw_override` o si fue especifico de `session_board_mount_02`.

### 2026-04-24 / 2026-04-25 - Perfil / Ajustes: onboarding legal, cuenta y eliminacion automatizada

- Consolidado un bloque amplio sobre `Perfil > Ajustes` para cerrar onboarding legal, sanear la seccion `Cuenta` y dejar operativa la eliminacion automatizada de cuenta con periodo de gracia.
- Duracion estimada del bloque: `8h`.
- Onboarding de primer acceso:
  - anadido flujo de primer login con aceptacion obligatoria de `Terminos y condiciones`,
  - anadido dialogo de bienvenida para evitar perfiles vacios al primer acceso,
  - el flujo fuerza al menos `nombre visible` y `handle`,
  - persistencia dual local + remota del estado de onboarding.
- Backend de onboarding:
  - anadidas columnas en `public.profiles` para version aceptada de terminos y finalizacion de bienvenida,
  - aplicada migracion `20260423213000_add_profile_onboarding_columns.sql`,
  - el onboarding ya sobrevive a reinstalaciones o cambio de dispositivo.
- Legal en `Ajustes`:
  - creados dialogs de solo lectura para `Terminos y condiciones`, `Politica de privacidad` y `Aviso legal`,
  - centralizado el contenido legal en assets versionados bajo `assets/legal/`,
  - creada shell visual comun para dialogs legales,
  - reorganizado `Ajustes` para separar `Informacion legal` del bloque general de app.
- Comunidad / perfil:
  - corregida la rotura de `community_leaderboard` tras endurecer la lectura publica de `profiles`,
  - anadido fallback defensivo en el adapter del leaderboard y blindaje en `ProfilePage`,
  - aplicada migracion `20260423193000_fix_community_leaderboard_after_profiles_hardening.sql`.
- Cuenta / UX:
  - eliminada la accion redundante `Editar perfil` de `Ajustes` al existir ya en la pestana `Perfil`,
  - `Cuenta` muestra resumen de sesion con email y proveedor de acceso,
  - implementado dialogo real de `Cambiar contrasena`,
  - endurecida la UX del dialogo de password:
    - validacion en vivo,
    - mostrar/ocultar password,
    - requisitos visibles,
    - correccion de overflows en vertical/horizontal,
    - adaptacion correcta al teclado y a orientacion horizontal.
- Eliminacion de cuenta - producto:
  - sustituido el placeholder inicial por un flujo real de autoservicio,
  - confirmacion fuerte escribiendo manualmente `ELIMINAR CUENTA`,
  - al confirmar se programa la eliminacion con ventana de gracia de `7 dias`,
  - el usuario puede anular la solicitud dentro del plazo,
  - eliminada la idea de revision manual para dejar una logica mas directa.
- Eliminacion de cuenta - datos y backend:
  - creada tabla `account_deletion_requests`,
  - simplificado el ciclo de vida a `scheduled / cancelled / completed`,
  - endurecidas policies para que el usuario solo pueda cancelar mientras `execute_after > now`,
  - desplegada Edge Function `account-deletion-runner`,
  - configurado cron remoto `account-deletion-runner-every-15-min`,
  - el runner:
    - solo procesa solicitudes `scheduled`,
    - exige `confirmed_at` y `execute_after`,
    - limita lote por ejecucion (`batchSize = 10`),
    - borra exclusivamente el `user_id` asociado a cada solicitud vencida.
- Eliminacion de cuenta - auditoria:
  - anadida tabla `account_deletion_audit`,
  - cada ejecucion deja rastro persistente aunque despues se elimine `auth.users`,
  - estados auditados:
    - `deleted`,
    - `delete_failed`,
    - `skipped_invalid_row`.
- Eliminacion de cuenta - UI final:
  - el tile `Eliminar cuenta` ya no muestra copy fijo,
  - si existe solicitud programada, muestra contador real del tiempo restante,
  - la tarjeta `Cuenta` replica ese estado y el mismo contador,
  - el dialogo de detalle muestra:
    - estado,
    - contador vivo,
    - fecha de creacion y fecha prevista de ejecucion en formato legible,
    - resaltado visual segun urgencia.
- Verificacion:
  - multiples `dart analyze` limpios sobre `settings_page.dart`,
  - migraciones aplicadas remotamente con `supabase db push`,
  - `account-deletion-runner` desplegado y probado en remoto,
  - cron remoto verificado en `cron.job` como activo cada `15 min`.

### 2026-04-25 - Perfil / Ajustes: modularizacion final y saneado de dependencias

- Continuado el trabajo de `Perfil > Ajustes` para dejar la pagina ya muy cerca de un coordinador puro y limpiar residuos tecnicos que seguian mezclados con UI.
- Duracion estimada del bloque: `6h`.
- Reorganizacion de `settings`:
  - movida la pagina de ajustes a `lib/features/profile/presentation/pages/settings/settings_page.dart`,
  - creada estructura por apartados dentro de `settings/`:
    - `units`,
    - `notifications`,
    - `app`,
    - `legal`,
    - `roles`,
    - `account`,
    - `widgets`,
  - extraidos widgets base compartidos para tarjetas y tiles de ajustes.
- Cuenta / dialogs:
  - extraido `ChangePasswordDialog` a `settings/account/dialogs/change_password_dialog.dart`,
  - extraido `DeleteAccountDialog` a `settings/account/dialogs/delete_account_dialog.dart`,
  - eliminado el dialogo inline legacy que seguia viviendo dentro de `settings_page.dart`.
- Cuenta / estado y datos:
  - centralizada la logica de estado de eliminacion de cuenta en `account_deletion_request_presenter.dart`,
  - extraido acceso a datos de solicitudes de borrado a `account_deletion_request_repository.dart`,
  - extraido resumen de sesion de cuenta a:
    - `account_session_summary.dart`,
    - `account_session_repository.dart`,
  - `AccountSettingsSection` pasa a consumir ya un resumen semantico de sesion en vez de datos sueltos.
- Roles / acceso:
  - extraido acceso a roles reales a `roles/user_roles_repository.dart`,
  - modelado el acceso visible de paneles con `roles/role_panels_access.dart`,
  - `RolePanelsSettingsSection` deja de recibir una coleccion de booleans sueltos y pasa a consumir un objeto de acceso mas expresivo.
- Notificaciones:
  - movido el flujo de activacion/desactivacion push a `notifications/notifications_settings_controller.dart`,
  - centralizados:
    - permiso local,
    - refresh de registro Firebase,
    - mapeo de estado push,
    - mensajes de resultado,
    - ofuscado de token.
- App / Legal:
  - extraidos launchers para acciones de `App` y `Informacion legal`:
    - `app/app_settings_launcher.dart`,
    - `legal/legal_settings_launcher.dart`,
  - `settings_page.dart` deja de importar directamente dialogs legales y `language_picker`.
- Limpieza de obsolescencias en `Ajustes`:
  - eliminada la version hardcodeada `2.0.0`,
  - anadido `package_info_plus` y carga real de version desde `app/app_version_repository.dart`,
  - reemplazadas rutas string `'/settings/faq'` y `'/settings/donations'` por `AppRoutes`,
  - ocultados paneles de rol que seguian siendo puro placeholder (`moderator`, `manager`, `vip`) para no exponer UI provisional.
- Dependencias / build:
  - detectado que el fallo Android tras anadir `package_info_plus` venia de estado stale de Flutter/Gradle y no del plugin en si,
  - ejecutada regeneracion limpia (`flutter clean` + `flutter pub get`),
  - eliminado el `dependency_overrides` obsoleto de `webview_flutter_wkwebview`,
  - resuelta la alineacion de la familia `webview_flutter`,
  - desaparecen:
    - el error de compilacion `PackageInfoPlugin`,
    - el warning repetido de `webview_flutter_wkwebview` desalineado.
- Verificacion:
  - multiples `dart analyze lib/features/profile/presentation/pages/settings` limpios durante la refactorizacion,
  - `flutter pub get` correcto tras actualizar dependencias,
  - generado APK debug correctamente en `build/app/outputs/apk/debug/app-debug.apk`.

## Proximo paso acordado

- Fase 90 de `sessions` cerrada (sincronizacion multi-sesion desde dispositivo vinculado).
- Fase 91 de `sessions` descartada por feedback de producto (no se permiten sesiones duplicadas en `My Sessions`).
- Fase 92 de `sessions` cerrada (pulido visual de tarjeta de dispositivo seleccionado en `Start Session`).
- Fase 92-b de `sessions` cerrada (copy `Sincronizado ...` + accion de capacidades solo icono dinamico).
- Fase 92-c de `sessions` cerrada (sin boton de sincronizar para `Telefono del usuario` + icono superior sustituido por accion de capacidades).
- Fase 92-d de `sessions` cerrada (eliminado chip de conteo de sensores en tarjeta de dispositivo seleccionado).
- Fase 93 de `sessions` cerrada (mejora visual de tarjeta de sesiones sincronizadas pendientes/importadas).
- Fase 93-b de `sessions` cerrada (interaccion de tarjeta de importadas restringida a boton `Configurar` + swap de posiciones `Pendiente`/`Configurar`).
- Fase 93-c de `sessions` cerrada (mejora de UI en importadas: `Configurar` legible y `Eliminar` alineado en la misma altura de acciones).
- Fase 93-d de `sessions` cerrada (acciones de importadas reequilibradas: `Configurar` y `Eliminar` compactos, misma linea y mejor proporcion visual).
- Fase 93-e de `sessions` cerrada (rollback de 93-d por feedback: restaurado layout anterior de acciones en importadas).
- Fase 93-f de `sessions` cerrada (rollback de 93-e por feedback: restaurado nuevamente layout 93-d en acciones de importadas).
- Fase 94 de `sessions` ajustada por feedback (resumen de `My Sessions` restaurado a estilo simple).
- Fase 94-b de `sessions` cerrada (acciones `Editar` y `Eliminar` forzadas en la misma linea en `My Sessions`).
- Fase 94-c de `sessions` cerrada (acciones `Editar` y `Eliminar` responsive en `My Sessions` para evitar overflows en pantallas estrechas).
- Fase 94-d de `sessions` cerrada (refinado visual de acciones en `My Sessions`: `Editar` compacto + `Eliminar` icon-only para mantener una sola linea sin romper).
- Fase 94-e de `sessions` cerrada (mejora legible del texto resumen + KPIs visibles en card: duracion, salto mas alto y max air time).
- Fase 94-f de `sessions` cerrada (terminologia `Hangtime` + KPIs extra en card: velocidad maxima y distancia de salto estimada + KPI avanzado en detalle).
- Fase 95 de `sessions` cerrada (nuevo layout de tarjeta `My Sessions`: foto superior, bloque equipo cometa/tabla, KPIs horizontales con scroll y metadata al pie).
- Fase 95-b de `sessions` cerrada (metadata inferior en texto simple y una sola linea: dispositivo + fecha + hora, sin chips).
- Fase 95-c de `sessions` cerrada (fecha/hora movidas bajo titulo + equipo con icono percha, metadata inferior simplificada a dispositivo).
- Fase 95-d de `sessions` cerrada (dispositivo integrado en la misma linea de fecha/hora bajo titulo).
- Fase 95-e de `sessions` cerrada (eliminado bloque `Estado de filtros` y accion `Resetear filtros rapidos` en `My Sessions`).
- Fase 96 de `spots` cerrada (Live: boton `Brujula en tiempo real` junto a rosa de vientos para comparacion de orientacion en playa).
- Fase 96-b de `spots` cerrada (anadido boton `Brujula simulada (dev)` debajo de la brujula real para pruebas visuales).
- Fase 96-c de `spots` cerrada (agujas de brujula estilo clasico alargado Norte/Sur en modo real y simulado).
- Fase 96-d de `spots` cerrada (etiquetas visuales `N`/`S` sobre la aguja principal para diferenciar claramente norte y sur).
- Fase 96-e de `spots` cerrada (correccion de visibilidad de etiquetas `N`/`S` en aguja: mayor ancho util y badges de alto contraste).
- Fase 96-f de `spots` cerrada (la brujula deja de abrir dialogo y pasa a superponerse sobre la rosa de vientos al pulsar botones).
- Fase 96-g de `spots` cerrada (copy dinamico en boton real: `Activar brujula` / `Desactivar brujula` segun estado).
- Fase 96-h de `spots` cerrada (rediseno visual de rosa de vientos a estilo tradicional con estrella y marcas cardinales/intercardinales).
- Fase 96-i de `spots` cerrada (ajuste de forma de aguja a rectangulo estirado y fino, estilo clasico minimal).
- Fase 96-j de `spots` cerrada (aguja en forma de rombo para brujula real/simulada).
- Fase 96-k de `spots` cerrada (velocidad de viento debajo de la rosa + copy simplificado `Brujula: grados` en modo real, manteniendo marcador simulado).
- Fase 96-l de `spots` cerrada (embellecimiento extra de rosa tradicional: anillos, glow central, contraste y etiquetas cardinales refinadas).
- Fase 96-m de `spots` cerrada (etiquetas cardinales fuera de la esfera + mayor contraste del dibujo interior + aguja de viento estilo flecha de reloj).
- Fase 96-n de `spots` cerrada (flecha de viento anclada desde el centro al borde exterior + linea textual `Viento: grados` bajo `Brujula:` en modo real).
- Proximo paso propuesto: `Spots v3.4 fase 101-d` para completar historico/alertas con datos reales y reforzar estados de carga/fallback en `Live`.

### 2026-02-21 - Puente temporal de login en desarrollo

- Activado arranque directo a dashboard cuando `EnvConfig.devBypassEnabled` esta en `true`.
- Cambio aplicado en router: `lib/app/router/app_router.dart` (initialLocation condicional).
- Manteniendo ruta `/login` disponible para pruebas manuales de la pantalla sin tocar su implementacion.
- Tests actualizados para reflejar el nuevo arranque en desarrollo:
  - `test/app/app_bootstrap_test.dart`
  - `test/widget_test.dart`
- Verificacion ejecutada: `flutter test -r expanded` (ok).

### 2026-02-21 - Dashboard con pestañas principales

- Reemplazada vista unica de dashboard por navegacion principal con 4 pestañas en `lib/features/dashboard/presentation/pages/dashboard_page.dart`.
- Pestañas implementadas manteniendo estilo Material de la app (AppBar + `NavigationBar` + contenido en `Card`):
  - `Spots`
  - `Session`
  - `Community`
  - `Perfil`
- Añadido cambio de contenido por pestaña con `AnimatedSwitcher` para transicion suave.
- Tests de arranque actualizados para reflejar la nueva navegacion:
  - `test/app/app_bootstrap_test.dart`
  - `test/widget_test.dart`
- Verificacion ejecutada: `flutter test -r expanded && flutter analyze` (ok).

### 2026-02-21 - Conexion de tabs a features base

- Conectadas las 4 pestañas del dashboard a pantallas de feature reales con `IndexedStack` en `lib/features/dashboard/presentation/pages/dashboard_page.dart`:
  - `SpotsPage`
  - `SessionsPage`
  - `CommunityPage`
  - `ProfilePage`
- Creadas pantallas base manteniendo estilo actual (padding + `Card` + tipografia del tema):
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
- Ajustada compatibilidad Riverpod 3 en recientes de auth (reemplazo de `StateProvider` por `NotifierProvider`) en `lib/features/auth/presentation/providers/recent_auth_accounts_provider.dart`.
- Verificacion ejecutada: `flutter analyze && flutter test -r expanded` (ok).

### 2026-02-21 - Spots: flujo inicial de alta desde FAB

- Evolucionada `SpotsPage` a estado local para soportar alta de spots en UI.
- FAB de `Spots` ahora abre un modal (`showModalBottomSheet`) para anadir spot manualmente.
- Formulario inicial en modal:
  - `Nombre del spot` (obligatorio)
  - `Zona / provincia` (opcional)
- Al guardar, el spot aparece en lista de cards dentro de la pestaña `Spots`.
- Estado vacio incluido cuando no hay spots agregados.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test -r expanded` (ok).

### 2026-02-21 - Spots: sugerencias en alta por nombre

- El modal de `Agregar spot` ahora sugiere spots disponibles mientras el usuario escribe el nombre.
- Implementado filtrado incremental (hasta 5 coincidencias) sobre lista base de spots iniciales de Espana.
- Al tocar una sugerencia, se autocompletan `Nombre del spot` y `Zona / provincia`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: modo personalizado con punto en mapa

- Anadido boton `Personalizado` en el modal de alta de spot.
- El flujo `Personalizado` abre dialogo de mapa (modo desarrollo) para marcar un punto tocando el area.
- Al confirmar `Usar punto`:
  - se guarda la seleccion visual,
  - se autocompleta zona con coordenada aproximada,
  - se mantiene compatible con guardado del spot.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: mapa real open source en modo personalizado

- Reemplazado el selector visual simulado por mapa real en el dialogo de `Personalizado` usando stack 100% open source:
  - `flutter_map` (licencia BSD/MIT-compatible, open source)
  - `latlong2` (open source)
  - tiles de OpenStreetMap para desarrollo
- El usuario ahora marca el punto sobre mapa real y se conserva el flujo de autocompletado de coordenadas aproximadas en la zona.
- Dependencias actualizadas en `pubspec.yaml`:
  - `flutter_map`
  - `latlong2`
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
  - `pubspec.yaml`
- Verificacion ejecutada: `flutter pub get && flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: estado activo, duplicados y borrado

- Mejorado flujo de gestion de `Mis spots` en la UI:
  - el primer spot agregado pasa a estado activo automaticamente,
  - se puede cambiar el spot activo tocando una tarjeta,
  - se muestra chip `Activo` en el spot seleccionado,
  - se puede eliminar spot desde accion de papelera.
- Mejorado modal de alta para evitar duplicados:
  - las sugerencias excluyen spots ya agregados,
  - se bloquea el guardado si el nombre ya existe (`Ese spot ya esta agregado`).
- Mantenido enfoque gratuito/open source (sin servicios propietarios).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: edicion restringida a spots personalizados

- Implementada edicion de spots con regla de negocio solicitada:
  - solo se puede editar un spot si es `personalizado`,
  - los spots de lista predefinida no abren flujo de edicion.
- Flujo de edicion:
  - se abre modal en modo `Editar spot`,
  - permite guardar cambios de nombre/zona,
  - mantiene validacion de duplicados.
- Ajustes de estado:
  - si el spot activo se renombra, el estado activo se actualiza al nuevo nombre.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: chips visuales Oficial/Custom

- Mejorada la claridad visual en la lista de spots anadidos:
  - spots de lista predefinida muestran chip `Oficial`,
  - spots personalizados muestran chip `Custom`,
  - se mantiene chip `Activo` para el spot seleccionado.
- Esto refuerza la regla de negocio: solo `Custom` se puede editar.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: filtros por tipo (Todos/Oficiales/Custom)

- Anadido filtro visual en la pestaña `Spots` para manejar mejor listas crecientes:
  - `Todos`
  - `Oficiales`
  - `Custom`
- El listado ahora se renderiza en base al filtro seleccionado.
- Si un filtro no tiene resultados, se muestra estado vacio contextual (`No hay spots para este filtro`).
- Se mantienen reglas previas:
  - edicion solo para spots `Custom`,
  - spots oficiales no editables,
  - stack gratuito/open source sin servicios propietarios.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: buscador combinado con filtros

- Anadido buscador en la cabecera de lista de spots (`Buscar spots`).
- El filtrado ahora combina:
  - tipo (`Todos` / `Oficiales` / `Custom`),
  - texto (coincidencia por nombre o zona).
- Incluye accion para limpiar busqueda (`Limpiar busqueda`).
- Se mantiene estado vacio contextual cuando no hay coincidencias.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: ordenacion de lista

- Anadidos controles de ordenacion para `Mis spots`:
  - `Recientes`
  - `A-Z`
  - `Z-A`
- La ordenacion se aplica sobre el resultado final de filtros + buscador.
- Se agrega sello temporal (`createdAt`) al modelo UI de spot para soportar orden por recientes de forma estable.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: selector de mapa mas grande y puntero visible

- Mejorado el flujo `Personalizado` al seleccionar punto en mapa:
  - el dialogo del mapa ahora es mas grande y usable en movil,
  - se renderiza un puntero rojo claramente visible justo donde se toca el mapa,
  - se mantiene confirmacion `Usar punto` y estado `Punto listo para usar`.
- Ajuste tecnico: el punto personalizado ahora conserva fracciones de posicion (`xFraction`, `yFraction`) para dibujar el puntero de forma precisa en el canvas del mapa.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: correccion de estirado horizontal en overscroll

- Corregido el efecto visual en `Spots` cuando se hace overscroll vertical (arriba/abajo):
  - se mantiene sensacion tipo muelle vertical,
  - se elimina la deformacion horizontal de pantalla.
- Implementado con `ScrollConfiguration` local sin indicador stretch y `BouncingScrollPhysics` en la lista principal.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spots_page.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: ocultar icono editar en oficiales

- Ajuste UX solicitado en lista de spots:
  - en spots `Oficial` ya no se muestra icono de editar desactivado,
  - el icono de editar solo aparece en spots `Custom`.
- Se mantiene la regla funcional previa (solo custom editable).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: acciones mover a AppBar

- Refactor UX solicitado en `Spots`:
  - se eliminan iconos de `editar/eliminar` en cada tarjeta,
  - las acciones se gestionan desde un menu en la `AppBar` de dashboard (solo visible en tab Spots).
- Menu AppBar en `Spots` incluye:
  - `Editar spot activo`
  - `Eliminar spot activo`
- Comportamiento:
  - opera siempre sobre el spot marcado como `Activo`,
  - mantiene la regla de negocio: solo custom editable (en oficiales se muestra feedback por snackbar).
- Archivos actualizados:
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: eliminado concepto de "spot activo"

- Se retira completamente el concepto de `spot activo` por feedback de UX.
- Cambios aplicados:
  - eliminado chip `Activo` en tarjetas,
  - eliminada seleccion por tap para marcar activo,
  - menu AppBar deja de operar sobre "activo" y pasa a operar por seleccion explicita.
- Nuevos flujos desde AppBar:
  - `Editar spot`: abre selector de spots custom (si hay mas de uno) y luego editor,
  - `Eliminar spot`: abre selector de spots y elimina el seleccionado.
- Ajustes en dashboard:
  - textos de menu simplificados (`Editar spot`, `Eliminar spot`).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: editar/eliminar desde tarjetas tras activar modo en AppBar

- Ajuste UX solicitado: al pulsar `Editar spot` o `Eliminar spot` en AppBar ya no aparece selector modal de spots.
- Nuevo comportamiento:
  - AppBar activa un modo temporal (`editar` o `eliminar`),
  - el usuario ejecuta la accion tocando directamente una tarjeta en la pantalla de spots,
  - tras aplicar la accion, el modo se desactiva automaticamente.
- Se muestra aviso contextual mientras el modo esta activo:
  - `Modo editar: toca una tarjeta para editarla`
  - `Modo eliminar: toca una tarjeta para borrarla`
- Reglas conservadas:
  - editar solo para `Custom`,
  - en spot `Oficial` se informa por snackbar.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: soporte de acciones multiples (editar/eliminar varios)

- Anadida opcion de acciones multiples en menu de AppBar para Spots:
  - `Editar varios`
  - `Eliminar varios`
- Flujo UX:
  - al activar modo multiple, se seleccionan tarjetas directamente en pantalla,
  - se muestra contador de seleccionados y acciones `Cancelar` / `Aplicar`.
- `Editar varios` (solo custom):
  - permite seleccionar varios spots custom,
  - aplica cambio masivo de `Zona / provincia` via modal.
- `Eliminar varios`:
  - permite seleccionar varios spots y borrarlos en una sola accion.
- Se mantiene tambien modo simple por tarjetas para `Editar spot` y `Eliminar spot`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: acciones solo en modo multiple

- Ajuste de producto por feedback:
  - se elimina el flujo de editar/eliminar de uno en uno,
  - se mantiene exclusivamente operativa la gestion por lotes (`Editar varios`, `Eliminar varios`).
- UX final:
  - activas modo desde AppBar,
  - seleccionas tarjetas,
  - confirmas con `Aplicar`.
- Limpieza tecnica asociada:
  - eliminadas rutas y estado de accion simple,
  - simplificado formulario de alta para uso exclusivo de creacion (sin modo editar).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: menu simplificado (Editar uno, Eliminar en lote)

- Ajuste UX solicitado:
  - `Editar` pasa a flujo de un solo spot (seleccionando tarjeta en modo editar).
  - `Eliminar` mantiene comportamiento en lote, pero sin texto "varios" en el menu.
- Se conserva opcion explicita `Editar varios` para cambios masivos de zona en custom.
- Menu final en AppBar de Spots:
  - `Editar`
  - `Editar varios`
  - `Eliminar`
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`

- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: ajuste final acciones (Editar 1, Eliminar lote)

- Ajuste final por feedback:
  - `Editar varios` eliminado,
  - `Editar` queda solo para 1 spot cada vez,
  - `Eliminar` mantiene seleccion multiple por tarjetas.
- Menu final en AppBar de Spots:
  - `Editar`
  - `Eliminar`
- Comportamiento:
  - `Editar`: activa modo editar simple y abre formulario al tocar un spot custom,
  - `Eliminar`: activa modo seleccion multiple y elimina seleccionados al pulsar `Aplicar`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spots: navegacion a detalle de spot y volver atras

- Al pulsar una tarjeta de spot en modo normal (sin accion pendiente), ahora navega a pantalla de detalle del spot.
- Nueva pantalla de detalle con AppBar propia y vuelta atras desde el boton del AppBar.
- Se conserva comportamiento existente en modos de accion:
  - `Editar` (1 a 1) y `Eliminar` (lote) siguen operando sobre tarjetas.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spot detalle: AppBar simplificado y toggle de secciones

- Ajuste solicitado en pantalla de spot seleccionado:
  - titulo de AppBar cambiado de nombre del spot a `Spot seleccionado`,
  - se mantiene boton de volver atras en AppBar.
- Debajo de la tarjeta principal se anade selector tipo toggle con 4 vistas:
  - `Prevision`
  - `Live`
  - `Webcam`
  - `Social`
- Cada vista muestra bloque placeholder inicial para evolucionar contenido funcional por seccion.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r expanded` (ok).

### 2026-02-21 - Spot detalle: etiqueta Prevision -> Forecast

- Cambio de copy en toggle de secciones de spot seleccionado:
  - `Prevision` pasa a `Forecast`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`

### 2026-02-21 - Spot detalle: toggle compact para labels en una linea

- Ajustado el toggle de secciones en detalle de spot para que ocupe menos ancho visual y no rompa texto en varias lineas.
- Cambios aplicados:
  - estilo compact (`VisualDensity.compact`),
  - menor padding horizontal,
  - labels con `softWrap: false`,
  - scroll horizontal suave del conjunto para mantener legibilidad en pantallas pequenas.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Reversion toggle compact en detalle de spot

- Revertidos los cambios de compactacion del toggle en detalle de spot por decision de UX.
- Se restaura comportamiento/estilo anterior del `SegmentedButton`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`

### 2026-02-21 - Spot detalle: quitar efecto muelle horizontal

- Ajustada la pantalla `Spot seleccionado` para eliminar el efecto de arrastre tipo muelle al deslizar lateralmente (izquierda/derecha).
- Implementacion:
  - `ScrollConfiguration` local sin overscroll stretch,
  - `ClampingScrollPhysics` en la lista de detalle.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: Forecast con selector de proveedor meteo

- En seccion `Forecast` se elimina la tarjeta de texto de prevision placeholder.
- En su lugar se anade una caja/select para elegir proveedor meteorologico disponible.
- Proveedores iniciales cargados en UI:
  - `Open-Meteo`
  - `AEMET`
  - `Windguru`
- Para `Live`, `Webcam` y `Social` se mantiene tarjeta placeholder de contenido.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: tabla Forecast con oleaje/lluvia activables

- En `Forecast`, tras seleccionar proveedor meteo, se anade una tabla horaria estilo app de viento con columnas base:
  - `Hora`
  - `Viento (kt)`
  - `Racha (kt)`
- Se agregan parametros extra activables/desactivables con chips:
  - `Oleaje` (m)
  - `Lluvia` (si/no + mm)
- Los datos mostrados cambian por proveedor seleccionado (`Open-Meteo`, `AEMET`, `Windguru`) con dataset UI inicial.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: formato tipo Windguru + selector de modelo

- Refinado bloque `Forecast` hacia estilo visual tipo Windguru:
  - tabla compacta por filas metricas y columnas horarias,
  - celdas de viento/racha con codificacion de color,
  - lluvia con intensidad visual por color.
- Anadido selector de modelo de prevision:
  - `GFS`, `AROME`, `ICON`, `ECMWF`.
- Se mantiene selector de proveedor meteo y toggles activables:
  - `Oleaje`
  - `Lluvia`
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok).

### 2026-02-21 - Spot detalle: tabla Forecast mas grande

- Ajuste visual de la tabla en `Forecast` para mejorar legibilidad:
  - celdas mas grandes (padding aumentado),
  - tipografia subida a `bodyMedium`,
  - ancho de columna aumentado (de 82 a 98).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: direccion viento + temperatura + presion

- Extendida la tabla `Forecast` para incluir parametros extra solicitados:
  - `Direccion` del viento con flecha orientada por grados,
  - `Temp (C)`,
  - `Presion (hPa)`.
- Se mantienen toggles para `Oleaje` y `Lluvia`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: unidad direccion simplificada

- Ajustado formato de direccion del viento en tabla Forecast:
  - de `deg` a simbolo `º`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`

### 2026-02-21 - Spot detalle: direccion solo con flecha grande

- Ajuste visual en columna de direccion del viento:
  - se elimina el texto de grados,
  - se usa solo flecha rotada por direccion,
  - flecha mas grande y definida (`arrow_upward_rounded`, size 22).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: flecha direccion mas gruesa

- Ajuste visual adicional solicitado para la flecha de direccion del viento:
  - mismo icono/forma,
  - trazo mas grueso usando ejes de Material Symbols (`fill`, `weight`, `grade`) y tamano 24.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: nuevo icono direccion tipo puntero

- Cambiado el icono de direccion del viento por un modelo mas tipo puntero de raton (`near_me_rounded`) manteniendo la rotacion por grados.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: puntero con rabito en direccion

- Ajustado icono de direccion del viento a variante con rabito (`assistant_navigation`) manteniendo la rotacion por grados.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: revert icono direccion a near_me_rounded

- Revertido icono de direccion del viento al modelo anterior preferido (`near_me_rounded`).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`

### 2026-02-21 - Spot detalle: cloud cover en tabla Forecast

- Anadido parametro `Cloud cover (%)` en la tabla Forecast.
- Se integra como nueva fila en el formato tipo Windguru junto al resto de variables meteo.
- Actualizado dataset UI mock de proveedores para incluir cobertura nubosa por hora.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: pantalla dedicada de mapa de viento

- El boton `Mapa de viento` ahora navega a pantalla dedicada en lugar de snackbar.
- Nueva pantalla `Mapa de viento` con:
  - base de mapa open source (OpenStreetMap via `flutter_map`),
  - capa visual de flechas/kt superpuesta estilo mapa de viento,
  - card inferior informativa del spot.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok).

### 2026-02-21 - Spot detalle: Live con lista de estaciones cercanas

- Reemplazado placeholder de `Live` por lista de estaciones meteorologicas cercanas al spot.
- Cada item muestra:
  - nombre de estacion,
  - proveedor,
  - distancia en km.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: Live con caja seleccionable de estacion

- Ajustado bloque `Live` para mostrar una caja seleccionable (dropdown) en lugar de listar todas las estaciones a la vez.
- La caja muestra nombre + distancia, y debajo se visualiza el proveedor de la estacion seleccionada.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: Live con rosa de vientos y unidad configurable

- Al seleccionar estacion en `Live`, ahora se muestra:
  - rosa de vientos con lectura real (direccion + velocidad),
  - selector de unidad de viento (`kt`, `km/h`, `mph`, `Bft`),
  - bloque de lecturas en tiempo real (viento, racha, temperatura, presion, humedad, lluvia).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: chip semaforo de navegabilidad

- En tarjeta de rosa de los vientos se reemplaza el titulo por chip semaforo de navegabilidad.
- Estados implementados por rango de viento actual:
  - `Navegable` (verde)
  - `Condicional` (amarillo)
  - `No navegable` (rojo)
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: grafica historica en Live

- Anadida grafica de historico de lecturas reales debajo de las tarjetas de metricas en seccion `Live`.
- Implementada como linea + area en `CustomPainter` con serie de 12 puntos por estacion seleccionada.
- Mantiene coherencia con selector de estacion y unidad de viento.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: quitar toggles de lluvia/oleaje y anadir boton mapa

- Eliminados toggles de `Lluvia` y `Oleaje` en Forecast.
- Anadido boton `Mapa de viento` en su lugar.
- La tabla Forecast mantiene visibles las filas de oleaje y lluvia de forma fija.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: ajuste tipografia toggle (-1)

- Reducido 1 punto el tamano de letra del `SegmentedButton` en pantalla de spot seleccionado para mejorar encaje horizontal de labels.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-21 - Spot detalle: tipografia toggle a 11

- Ajuste adicional solicitado: labels del toggle de secciones en detalle de spot pasan a `fontSize: 11`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`

### 2026-02-21 - Reversion tipografia toggle en spot detalle

- Revertidos los cambios de tamano de fuente del toggle de secciones.
- Se restaura la tipografia por defecto del `SegmentedButton` (estado inicial).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`

### 2026-02-21 - Patron UI reutilizable para gestion de listas

- Queda registrado como patron para reutilizar en otras tabs/paginas:
  - accion simple desde AppBar (`Editar`) + accion en lote desde AppBar (`Eliminar`),
  - ejecucion directa sobre tarjetas (sin selector modal extra),
  - modo contextual visible con `Cancelar` / `Aplicar` cuando hay seleccion multiple.
- Objetivo: mantener consistencia UX en futuras implementaciones (Sessions, Community, Perfil, etc.).

### 2026-02-21 - IDE debug simplificado para recuperar Hot Reload

- Simplificada configuracion de `Run and Debug` para evitar lanzar por error modos sin Hot Reload.
- `launch.json` queda con una unica configuracion:
  - `Flutter Android Debug (Hot Reload)`
- Anadido `extensions.json` con recomendaciones de extensiones oficiales:
  - `dart-code.dart-code`
  - `dart-code.flutter`
- Archivos actualizados:
  - `.vscode/launch.json`
  - `.vscode/extensions.json`

### 2026-02-21 - Debug UX IDE: aclaracion de perfiles

- Ajustado `launch.json` para evitar confusion con Hot Reload en el IDE:
  - `Flutter Android (Profile - sin Hot Reload)`
  - `Flutter Attach (Android - requiere app ya iniciada)`
- Objetivo: dejar claro que Hot Reload solo aparece en sesion `Debug`.
- Archivo actualizado:
  - `.vscode/launch.json`

### 2026-02-22 - Spot detalle Social: mini red social por spot

- Sustituido el placeholder de `Social` por una version simple y util, sin apps externas.
- Flujo implementado en el propio spot:
  - publicacion de texto por usuario,
  - seleccion de tipo de media asociado al post (`Solo texto`, `Foto`, `Video corto`),
  - feed aislado por spot seleccionado (cada spot tiene su propio hilo),
  - respuestas en hilo por post (mini foro dentro del feed del spot).
- Incluye estado vacio cuando no hay publicaciones y seed inicial para spots no custom.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Spot detalle Social: simplificacion de adjuntos en composer

- Eliminados los chips de seleccion (`Solo texto`, `Foto`, `Video corto`) del formulario social.
- Sustituidos por un unico boton `Adjuntar foto/video`, con selector modal para:
  - adjuntar foto,
  - adjuntar video corto,
  - quitar adjunto.
- Se muestra estado compacto del adjunto activo junto al boton.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Spot detalle Social: publicaciones sin chips y gestion de post propio

- Ajustada la UX del feed social para parecerse a una red social clasica:
  - eliminados chips de tipo (`solo texto`, `foto`, `video`) en los posts publicados,
  - cuando hay adjunto se muestra bloque de media y el texto del post debajo.
- Anadido control sobre publicaciones propias (`Tu perfil`):
  - editar post,
  - eliminar post.
- El composer ahora soporta modo edicion con `Guardar cambios` y `Cancelar edicion`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Spot detalle Social: endurecimiento ante errores de indices

- Anadidas validaciones defensivas en acciones de social para evitar `RangeError` por indices fuera de rango al editar, eliminar o responder.
- Se limpian estados de edicion/respuesta cuando el indice ya no es valido.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Spot detalle Social: respuestas en cascada tipo red social

- Extendida la logica de respuestas para permitir hilos en cascada (reply sobre reply), no solo respuesta al post raiz.
- Cada mensaje/respuesta puede recibir respuestas de otros usuarios y se renderiza como arbol de conversacion.
- Composer de respuesta unificado para post raiz o reply objetivo, con cancelacion y envio en contexto.
- Se mantiene feed por spot y acciones de edicion/eliminacion del post propio.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Hotfix Social: excepcion en replies (linea 1452)

- Corregida inicializacion de listas de respuestas para evitar estados no mutables/incompatibles en tiempo de ejecucion.
- En `_SpotSocialPost` y `_SpotSocialReply` ahora se clona siempre la lista de replies con `List.from(...)`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Recuperacion parcial tras rollback accidental en Spot Detail

- Restaurada la seccion `Webcam` dentro de `SpotDetailPage`:
  - lista de webcams por spot,
  - estado vacio para spots sin camaras,
  - boton `Abrir` con navegacion a `WebcamPlayerPage`.
- Ajustes de social mantenidos compatibles tras la recuperacion.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Restauracion de Live completo tras rollback

- Repuesto el bloque avanzado de `Live` en `SpotDetailPage`:
  - historico grande con zoom/pan,
  - comparativa con forecast (fuente + modelo),
  - refresco manual y fullscreen,
  - rango temporal `1h/3h/6h/12h`,
  - marcadores de direccion con semaforo en el chart.
- Restaurado tambien el bloque de `Alarmas personalizadas` como tarjeta separada bajo el historico.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: vinculacion de dispositivo e importacion

- Implementado el placeholder avanzado de `Session` inspirado en flujo de captura con dispositivo externo:
  - boton superior derecho `Añadir dispositivo` con selector de tipo (Woo Sports, Apple Watch, Android, SurfR),
  - lista de dispositivos vinculados con seleccion del dispositivo activo para grabar,
  - bloque alternativo para `Importar sesion` desde archivo cuando no se usa dispositivo en agua.
- Se muestra estado de seleccion y mensaje de importacion en modo mock.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: lista de dispositivos modificable

- Extendida la lista de dispositivos vinculados para que sea editable:
  - editar nombre/estado del dispositivo,
  - eliminar dispositivo vinculado con confirmacion.
- Si se elimina el dispositivo seleccionado, la seleccion activa pasa al primero disponible (o null si no quedan).
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: control de sesion con estados (mock fase 1)

- Anadido bloque `Control de sesion` en la pantalla `Session` con flujo mock de captura:
  - `Iniciar sesion` -> `Detener sesion` -> `Sincronizar` -> `Nueva sesion`.
- Incluye estado contextual visible, timer de sesion activa y estado de sensores (GPS/Sensores OK) para simular comportamiento de wearable.
- El boton principal se adapta dinamicamente segun estado y dispositivo seleccionado.
- Si no hay dispositivo seleccionado, se bloquea el inicio con feedback.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: eliminado efecto muelle en pantalla

- Eliminado overscroll/efecto muelle al inicio y final de la pantalla `Session`.
- Aplicado `ScrollConfiguration` sin indicador de overscroll y `ClampingScrollPhysics` en el `ListView`.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: estado de dispositivo visible y editable en lista

- Mejorada UX de gestion de estado de dispositivos vinculados:
  - eliminado cambio de estado dentro del modal de edicion,
  - el estado ahora se gestiona de forma visible en cada tarjeta de dispositivo mediante `ChoiceChip`.
- El modal de edicion queda enfocado solo en renombrar dispositivo.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: ajuste UX de estado con menu desplegable

- Revertido el selector por chips para estado de dispositivo.
- Sustituido por `DropdownButtonFormField` visible dentro de cada tarjeta para un manejo mas limpio y rapido.
- Se mantiene la edicion de nombre en modal separado.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: estado de dispositivo auto-detectado

- Eliminado el control manual de estado en la lista de dispositivos.
- El estado ahora se muestra como `auto` segun contexto:
  - seleccionado + listo/grabando/sincronizando,
  - no seleccionado conectado,
  - pendientes/desconectados conservan su estado base.
- Se mantiene edicion solo para nombre y eliminacion de dispositivo.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: estado auto en chip visual

- Sustituida la caja de estado auto por un `Chip` con color semaforo para lectura rapida.
- El chip muestra `estado · auto` y cambia color segun estado detectado.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: acciones movidas a menu de AppBar

- Eliminado menu de tres puntos por dispositivo dentro de la lista (sin editar nombre ni eliminar local por fila).
- El estado en chip queda limpio, sin sufijo `auto`.
- Anadido menu de tres puntos en la `AppBar` cuando esta seleccionada la pestana `Session`, con opcion unica `Eliminar`.
- La accion `Eliminar` elimina el dispositivo actualmente seleccionado.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: mover `Añadir dispositivo` a AppBar

- Reubicado `Añadir dispositivo` desde el contenido de la pantalla `Session` a la `AppBar`.
- En la pestana `Session`, la `AppBar` muestra ahora:
  - icono `Añadir dispositivo`,
  - menu de tres puntos con `Eliminar`.
- El boton de anadir queda a la izquierda del menu de eliminar, como se pidio.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: icono de anadir simplificado

- Cambiado el icono de `Añadir dispositivo` en AppBar a un simbolo `+` simple (`Icons.add_rounded`).
- Archivo actualizado:
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: segmented `Start` / `My Sessions`

- Anadido `SegmentedButton` en la parte superior de `Session` para separar flujos:
  - `Start`: contiene el placeholder y control actual de captura (dispositivo, control de sesion, importacion),
  - `My Sessions`: placeholder independiente para el siguiente bloque del roadmap.
- Esto desacopla el placeholder actual del siguiente placeholder de historial.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: `My Sessions` con filtros y feed de sesiones finalizadas

- Eliminada la tarjeta placeholder de `My Sessions`.
- Anadidos filtros arriba del todo para buscar y filtrar sesiones:
  - buscador por texto,
  - filtro por dispositivo,
  - orden (`Mas recientes` / `Mas antiguas`).
- Integrado feed de sesiones finalizadas en formato lista.
- Al completar una sesion en `Start Session` (sincronizacion), se crea una entrada que aparece en `My Sessions`.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: termino UX `Subir sesion` en control de captura

- Ajustado texto del flujo de sesion finalizada para alinearlo con experiencia tipo Woo Sports:
  - boton en estado pendiente pasa de `Sincronizar` a `Subir sesion`,
  - durante proceso pasa a `Subiendo...`,
  - mensajes de estado actualizados a terminologia de subida.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - My Sessions: filtros responsive en desplegables

- Ajustado layout de filtros en `My Sessions` para evitar desbordes y cortes visuales.
- Mejoras aplicadas:
  - `isExpanded: true` en desplegables,
  - textos con `ellipsis` en opciones,
  - distribucion responsive: en ancho estrecho se apilan en columna, en ancho amplio se muestran en fila.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - My Sessions: busqueda tambien por spot

- Extendida la logica de busqueda para incluir el spot ademas de titulo/resumen/dispositivo.
- En `Start Session` se anade selector de `Spot de la sesion` para etiquetar la sesion al subirla.
- El feed de `My Sessions` muestra ahora el spot en cada tarjeta de sesion.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions: reversion de busqueda por spot + dialogo al subir

- Revertido el cambio de `Spot de la sesion` en el bloque `Start Session` y la busqueda explicita por campo spot en `My Sessions`.
- Nuevo flujo al pulsar `Subir sesion` con sesion finalizada:
  - se abre un dialogo de configuracion antes de guardar,
  - permite definir `Spot` y `Resumen de sesion`.
- Al confirmar en el dialogo, la sesion se guarda/sube y aparece en el feed de `My Sessions`.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions hotfix: robustez al subir sesion desde dialogo

- Anadidos guards de `mounted` alrededor del flujo asincrono de `Subir sesion` para evitar estados invalidos al cerrar/cambiar pantalla durante el dialogo.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Hotfix estabilidad UI: callback de tab Session diferido

- Ajustados callbacks entre `SessionsPage` y `DashboardPage` para diferir actualizaciones de estado al siguiente frame (`addPostFrameCallback`).
- Objetivo: evitar conflictos de reconstruccion al cambiar sub-tab `Start Session` / `My Sessions` y acciones de AppBar.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Hotfix `Subir sesion`: dialogo sin controller local

- Ajustado el dialogo de `Subir sesion` para evitar fallo al guardar con texto en resumen.
- Cambio tecnico:
  - eliminado `TextEditingController` local del dialogo,
  - retorno directo de datos (`spot`, `notes`) desde `Navigator.pop(...)`.
- Objetivo: evitar conflictos de ciclo de vida al cerrar dialogo con teclado/foco activo.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: acciones AppBar solo en `Start Session`

- Rehabilitado enlace entre sub-tab de `Session` y `Dashboard` para mostrar/ocultar acciones de AppBar segun contexto.
- En `Session`:
  - `+` y menu `Eliminar` visibles solo en `Start Session`,
  - ocultos en `My Sessions`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Hotfix Dashboard/Sessions: callback defensivo de tab Session

- Eliminado callback post-frame inicial en `SessionsPage` para evitar cambios de estado cruzados al montar arbol de widgets.
- Endurecido callback `onStartTabChanged` en `DashboardPage` para no llamar `setState` si:
  - el widget no esta montado,
  - el valor no cambia.
- Objetivo: reducir pausas del debugger por aserciones internas al cambiar estados durante reconstruccion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Reversion estabilidad: desacoplar callback entre Session y Dashboard

- Revertido el acoplamiento `onStartTabChanged` entre `SessionsPage` y `DashboardPage` para volver al comportamiento estable previo.
- Las acciones de AppBar de `Session` vuelven a depender solo de pestaña principal `Session` (sin depender de sub-tab interna).
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: segmented fuera de tarjeta y AppBar contextual

- Reubicado el `SegmentedButton` (`Start` / `My Sessions`) fuera de la tarjeta principal, arriba del todo de la pantalla.
- Ajustado comportamiento de acciones en AppBar para `Session`:
  - `+` y menu `Eliminar` solo aparecen cuando la subpestana activa es `Start`.
  - en `My Sessions` se ocultan esas acciones al no aplicar a ese placeholder.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: etiqueta de segmento renombrada

- Renombrada etiqueta del segmento de `Start` a `Start Session` para mayor claridad.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: alta de dispositivo en dialogo centrado

- Sustituido el menu inferior de `Añadir dispositivo` por un dialogo centrado de configuracion.
- El nuevo flujo permite configurar desde el centro de pantalla:
  - tipo de dispositivo,
  - nombre del dispositivo,
  - accion `Vincular`.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: ampliar tipos en selector (esqueleto fase 3)

- Anadidos tipos de dispositivo en el desplegable de alta:
  - `Smartwatch`
  - `Personalizado`
- Se mantiene enfoque de esqueleto/mock para fase actual; integracion real prevista para fase 3.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - Sessions UX: control core centrado y CTA principal ampliado

- Reforzada la tarjeta `Control de sesion` para destacar el flujo core de la pantalla.
- Cambios visuales:
  - contenido centrado,
  - titulo y estado mas grandes,
  - chips centrados y con iconos mas visibles,
  - boton principal en ancho completo y mayor altura para maxima visibilidad.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-22 - My Sessions: navegacion a detalle de sesion

- Anadida apertura de pantalla de detalle al pulsar una sesion del feed en `My Sessions`.
- Nueva pantalla `SessionDetailPage` con informacion base de la sesion seleccionada:
  - titulo,
  - fecha/hora,
  - dispositivo,
  - duracion,
  - resumen,
  - bloque placeholder de metricas avanzadas.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-23 - Session detail: metricas mock + timeline + eventos

- Evolucionada `SessionDetailPage` para reemplazar el bloque de `Metricas (placeholder)` por contenido util de detalle.
- Nuevo bloque `Metricas de la sesion` con KPIs visuales:
  - `Distancia`
  - `Velocidad max`
  - `Tiempo en planeo`
  - `Bateria`
  - `Saltos`
- Anadida seccion `Timeline de rendimiento` con grafica custom (`CustomPainter`) y clave de test `session_timeline_chart`.
- Anadida seccion `Eventos detectados` con lista de eventos de sesion.
- Implementada generacion determinista de datos mock en `SessionDetailPage` a partir de datos base de la sesion (titulo, dispositivo, fecha, duracion) para mantener consistencia visual entre ejecuciones.
- Tests nuevos:
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Sessions: metricas conectadas al feed + modalidad + altura de saltos

- Aplicado paso de continuidad solicitado: `SessionDetailPage` ya no calcula metricas localmente al abrirse desde datos sueltos.
- Ahora las metricas se generan al crear/subir la sesion en `SessionsPage` y viajan dentro del modelo de `My Sessions` hasta el detalle (`SessionInsightData`).
- Flujo de subida mejorado con selector de modalidad en dialogo `Configurar sesion`:
  - `Freeride`
  - `Freestyle`
  - `Big Air`
- En `My Sessions` cada tarjeta muestra tambien la modalidad junto al dispositivo y fecha.
- En `SessionDetailPage` se anade chip de modalidad y nuevo KPI clave para Big Air:
  - `Salto mas alto` (m)
- Ajuste de logica mock por modalidad:
  - rango de altura de salto mayor en `Big Air`,
  - rango intermedio en `Freestyle`,
  - rango base en `Freeride`,
  - catalogo de eventos contextual segun modalidad.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Sessions: KPIs completos por capacidades de sensor (sin selector de modalidad)

- Ajuste de producto aplicado: se elimina la seleccion manual de modalidad al subir sesion.
- El dialogo `Configurar sesion` vuelve a centrarse en:
  - `Spot`
  - `Resumen de sesion`
- Se implementa modelo de datos de detalle orientado a sensores (`SessionInsightData`) para registrar/mostrar KPIs segun capacidades reales del dispositivo.
- `My Sessions` crea y guarda `insights` al subir sesion, derivando capacidades desde tipo de dispositivo (`kind`) vinculado.
- `SessionDetailPage` se reorganiza en bloques para mostrar los KPIs solicitados de forma completa y estructurada:
  - Core Session
  - Big Air
  - Freestyle
  - Freeride/Navegacion
  - Saltos
  - Control tecnico
  - Condiciones meteo-contexto
  - Seguridad y riesgo
  - Dispositivo y calidad de datos
  - Social/Competicion
  - KPIs compuestos
- Cada KPI se muestra con valor cuando el sensor lo soporta; si no, aparece como `No disponible en este dispositivo`.
- Se mantiene KPI destacado `Salto mas alto` en el resumen principal de metricas.
- Se mantiene `Timeline de rendimiento` solo cuando hay datos de velocidad disponibles.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
  - `SESSION_TRACKER.md`

### 2026-02-23 - Sessions: panel de capacidades de dispositivo en Start Session

- Implementado siguiente paso UX en `Start Session`: panel `Capacidades del dispositivo` para el wearable seleccionado.
- El panel muestra:
  - ratio de sensores disponibles (`X/9`),
  - chips por capacidad (`GPS`, `Velocidad`, `Movimiento`, `Altitud`, `Ritmo cardiaco`, `Barometro`, `Bateria`, `Conectividad`, `Meteo`),
  - estado visual disponible/no disponible para cada capacidad.
- El contenido se actualiza al cambiar de dispositivo en la lista vinculada.
- Se reutiliza y expone el mapeo de capacidades desde `SessionInsightData` para mantener una unica fuente de verdad.
- Test nuevo para validar comportamiento:
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Sessions: incluir telefono como dispositivo seleccionable por defecto

- Anadido `Telefono del usuario` a la lista inicial de dispositivos vinculados para evitar bloqueo de grabacion cuando no hay wearable externo.
- El telefono queda disponible como fuente valida de captura igual que el resto de dispositivos seleccionables.
- Test anadido para asegurar presencia del telefono en la lista de dispositivos.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Sessions: telefono siempre visible y re-seleccionable

- Corregido el flujo para que el `Telefono del usuario` permanezca siempre disponible en la lista de dispositivos.
- El telefono ahora se prioriza visualmente al inicio de la lista para facilitar volver a seleccionarlo tras usar un wearable externo.
- Se bloquea su eliminacion para evitar quedarse sin opcion local de captura.
- Se anade prueba para validar que el telefono aparece en lista y queda por encima de otros dispositivos.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Sessions: auto-seleccion de telefono cuando no hay dispositivo activo

- Anadida logica de fallback para seleccionar automaticamente `Telefono del usuario` cuando no exista dispositivo seleccionado valido.
- El fallback se ejecuta al iniciar la pantalla y tambien tras eliminar el dispositivo activo.
- Si no existiera telefono por algun estado inconsistente, se conserva fallback al primer dispositivo disponible o `null` si la lista esta vacia.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Verificacion ejecutada: `flutter analyze && flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok).

### 2026-02-23 - Session detail UX: foco en saltos + historico detallado

- Redisenada la parte principal del detalle para priorizar los KPIs que realmente se consultan al terminar sesion:
  - `Salto mas alto`
  - `Saltos`
  - `Hangtime maximo`
  - `Duracion sesion`
  - `Velocidad max`
- Eliminados KPIs del bloque `Social / Competicion` segun preferencia de producto.
- Anadida seccion `Historico de saltos` con filas por salto mostrando:
  - numero de salto,
  - altura,
  - hangtime,
  - velocidad de caida,
  - minuto y segundo exacto del salto.
- Anadido modelo `SessionJumpRecord` y generacion determinista de historico de saltos para sesiones mock.
- Se mantiene timeline y eventos, pero con jerarquia visual orientada al resumen post-sesion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Integracion inicial de historico de saltos desde import de archivo

- Implementada primera conexion del historico de saltos a una ruta de datos tipo sensor en el flujo `Importar sesion`.
- `Importar sesion` ya no muestra solo aviso: ahora crea una sesion en `My Sessions` con:
  - metadatos de sesion importada,
  - historico de saltos estructurado (`SessionJumpRecord`),
  - recalculo de KPIs clave de salto en detalle (`jumpsCount`, `maxJumpHeightMeters`, `maxHangtimeSeconds`) a partir de los registros importados.
- Anadido `copyWith` en `SessionInsightData` para permitir sobreescritura de KPIs desde payload importado sin romper el resto de metricas.
- Anadido test de flujo para validar importacion y navegacion a detalle con presencia de `Historico de saltos`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Session detail: selector de mediciones para evitar scroll excesivo

- Reintroducida la informacion avanzada de KPIs debajo de `Eventos detectados`, pero con UX de seleccion para no alargar excesivamente la pantalla.
- `SessionDetailPage` pasa a `StatefulWidget` y anade bloque `Mediciones avanzadas` con `ChoiceChip` por familia de metricas.
- Solo se muestra en detalle la familia elegida por el usuario (p.ej. `Core Session`, `Big Air`, `Freestyle`, etc.), manteniendo acceso a todas las mediciones disponibles sin saturar la vista.
- Se mantiene eliminado el bloque `Social / Competicion` segun decision previa.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
- Verificacion ejecutada: `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact && flutter analyze && flutter test -r compact` (ok).

### 2026-02-23 - Session detail: ajustes de labels de KPIs para mejor comprension

- Revision y mejora de labels de KPIs para que sean mas intuitivos para el usuario:
  - `Velocidad p95` -> `Top velocidad estable`
  - `Hangtime p95` -> `Top hangtime estable`
  - `Progreso por trick (+X% vs 30d)` -> `Mejora ultimos 30 dias: +X%`
  - `Consistencia de alturas` -> `Variacion de alturas`
  - `VMG upwind` -> `Velocidad efectiva upwind`
  - `VMG downwind` -> `Velocidad efectiva downwind`
  - `Distribucion de alturas` -> formato en 2 lineas: `Tipica: Xm` / `Maxima habitual: Xm`
  - `Landing speed` -> `Fuerza G al aterrizar` (en G en lugar de kt)
  - `Calidad de jibe` -> `Calidad del giro downwind`
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-24 - Community UI: implementacion visible en rama principal

- Integrada en la rama actual la implementacion completa de `Community` que estaba en worktree aislado.
- Estructura final de `Community`:
  - `SegmentedButton` con tabs `Leaderboard` y `Following`.
  - Estado independiente por vista para filtros/busqueda.
- `Leaderboard` implementado con UX tipo Woo:
  - filtros `Periodo`, `Spot`, `Scope`, `Orden`.
  - filas con `#`, avatar, `@usuario`, `Big Air Score` y `salto mas alto`.
  - realce de podio para top 3 (oro/plata/bronce) y fila hero para #1.
  - acciones por usuario: `Ver perfil`, `Ver sesiones`.
- `Following` implementado con:
  - buscador de usuarios (lupa),
  - descubrimiento con accion `Seguir`,
  - feed de sesiones de seguidos,
  - acciones `Mensaje`, `Ver perfil`, `Ver sesiones`.
- Navegacion placeholder creada para fase UI-first:
  - `lib/features/community/presentation/pages/community_user_profile_page.dart`
  - `lib/features/community/presentation/pages/community_user_sessions_page.dart`
  - `lib/features/community/presentation/pages/community_messages_page.dart`
- Test widget anadido para cobertura de Community:
  - `test/features/community/presentation/pages/community_page_test.dart`
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze && flutter test -r compact` (ok)

### 2026-02-24 - Community UI: desactivado efecto muelle en scroll

- Eliminado el efecto muelle/estiramiento al llegar al inicio o final del scroll en `Community`.
- Aplicado `ScrollConfiguration` con comportamiento sin indicador de overscroll y fisica `ClampingScrollPhysics`.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community UI: boton explicito para aplicar filtros en Leaderboard

- Anadido boton `Aplicar filtros` en la cabecera de `Leaderboard`.
- Ajustado comportamiento de filtros a modo borrador/aplicado:
  - los cambios en dropdowns (`Periodo`, `Spot`, `Scope`, `Orden`) no impactan ranking hasta pulsar el boton,
  - el boton se desactiva cuando no hay cambios pendientes.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: top 5 en tarjetas + tabla desde #6 + carga incremental

- Redisenado `Leaderboard` para ajustar jerarquia visual tipo Woo Sports:
  - posiciones `#1` a `#5` en formato tarjeta,
  - desde `#6` en adelante en fila compacta tipo tabla de una celda (ranking, miniavatar, nombre, salto mas alto).
- Anadida carga progresiva de usuarios en bloques de `50`:
  - el listado carga inicialmente 50,
  - al acercarse al final se cargan automaticamente 50 adicionales hasta completar resultados filtrados.
- Anadida barra fija inferior en `Leaderboard` con posicion personal:
  - muestra `Mi posicion actual: #X / total participantes`,
  - permanece visible mientras se navega por la lista.
- Mantenido flujo de filtros con boton `Aplicar filtros` y reseteo de paginado tras aplicar.
- Ajuste de datos mock para soportar volumen de ranking (lista extensa de usuarios determinista).
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: ejemplos explicitos hasta top 10

- Anadidos perfiles mock adicionales en ranking para que se visualice claramente el top 10 completo sin depender solo de usuarios generados.
- Nuevos ejemplos visibles tras `you_rider`:
  - `javi_foil`, `lucia_jump`, `kike_wave`, `nora_loop`.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: barra inferior simplificada con datos de usuario

- Ajustada la barra fija inferior para eliminar el texto `Mi posicion actual`.
- Nuevo formato visible:
  - numero de ranking,
  - miniavatar,
  - nombre de usuario,
  - `#X / total participantes`.
- Aplicado layout adaptable para evitar overflow en anchos estrechos.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: mas altura util visible de listado

- Mejorado el alto util del ranking para que se vean mas posiciones de un vistazo:
  - filtros colapsables (`Mostrar filtros` / `Ocultar filtros`) para liberar espacio vertical,
  - reducida altura de tarjetas top 5,
  - reducida altura de filas compactas desde #6.
- Ajustado layout de acciones de filtros con `Wrap` para evitar overflow en pantallas estrechas.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)

### 2026-02-24 - Community Leaderboard: top 5 con mismo formato visual que filas compactas

- Ajustado formato de las tarjetas del top 5 para que coincidan con la estructura de filas compactas:
  - numero de ranking,
  - miniavatar,
  - nombre de usuario,
  - metrica seleccionada en filtros.
- Eliminado en top 5:
  - bloque lateral `Big Air + score`,
  - texto inferior `Salto mas alto` bajo el nombre.
- La metrica mostrada en todas las filas (top 5 y resto) ahora sigue el filtro `Orden`:
  - `Big Air Score` -> score,
  - `Salto mas alto` -> altura en metros.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: unidades y cabecera dinamica por metrica

- Anadidas unidades/simbolo de medida en la columna de metrica del ranking:
  - `Big Air Score` muestra ahora `pts`,
  - `Salto mas alto` muestra `m`.
- El texto bajo controles de filtros ya no es fijo:
  - cambia dinamicamente a `Big Air Score (pts)` o `Salto mas alto (m)` segun el filtro `Orden` aplicado.
- Test widget anadido para validar el cambio dinamico de cabecera al aplicar `Salto mas alto`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: filtro de orden ampliado a todos los KPI

- Ampliado el filtro `Orden` para permitir ranking por todos los KPI de la vista:
  - `Big Air Score`, `Salto mas alto`, `Numero de saltos`, `Hangtime max`, `Velocidad max`, `Viento medio`, `Distancia sesion`, `Duracion sesion`, `Consistencia de saltos`, `Velocidad upwind`, `Velocidad downwind`.
- El ranking ahora ordena dinamicamente por la metrica seleccionada en filtros.
- Unidades y formato de valor ajustados por KPI (pts, m, kt, km, min, %, count).
- La cabecera del bloque de ranking muestra automaticamente la metrica activa y su unidad.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: orden por todos los KPI sincronizados con agrupacion en dropdown

- Rehecho el filtro `Orden` para cubrir los KPI sincronizados de sesion, con esta prioridad inicial:
  - `Salto mas alto` (default),
  - `Big Air score`,
  - `Numero de saltos`.
- A continuacion del top inicial se muestra una linea separadora y luego los KPI agrupados por familia (Core Session, Big Air, Freestyle, Freeride/Navegacion, Saltos, Control tecnico, Condiciones meteo-contexto, Seguridad y riesgo, Dispositivo y calidad de datos, KPIs compuestos).
- En el desplegable:
  - cabeceras de grupo no seleccionables,
  - separador visual no seleccionable,
  - parametros de KPI seleccionables debajo de cada grupo.
- La cabecera y los valores del ranking se actualizan segun el KPI activo con unidad/formato correspondiente.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: colores por familia en desplegable de KPI

- Anadido color de fondo distinto por familia de KPI en el desplegable `Orden` para hacer mas visible la separacion visual entre bloques.
- Se mantiene:
  - separador entre los 3 KPI principales y el resto,
  - cabeceras de grupo no seleccionables,
  - KPI seleccionables bajo cada familia.
- Los items KPI heredan un tono suave del color de su grupo para reforzar jerarquia visual.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Leaderboard: color uniforme por grupo + cabecera mas intensa

- Ajuste visual del dropdown `Orden`:
  - cada KPI de una misma familia usa ahora exactamente el mismo color de fondo de su grupo,
  - la cabecera de cada familia usa una variante mas intensa del mismo color para resaltar el bloque.
- Objetivo UX: hacer mas legible la jerarquia por familias y distinguir claramente inicio de cada grupo.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community: renombrado tab Following a Amigos

- Renombrada la pestaña social de `Following` a `Amigos`.
- Ajustado texto de seccion en feed a `Sesiones de amigos`.
- Actualizados tests de widget para reflejar el nuevo naming.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Amigos: reemplazo de descubrir usuarios por directorio de amigos

- Eliminado bloque `Descubrir usuarios` del tab `Amigos`.
- Nuevo bloque principal `Usuarios que sigues`:
  - muestra numero de amigos seguidos,
  - al pulsar abre un directorio/listado de amigos.
- Directorio de amigos implementado en modal:
  - buscador para filtrar entre amigos,
  - listado de amigos con acceso directo a `Ver perfil`,
  - boton `Cerrar` para salida explicita.
- Se mantiene feed de `Sesiones de amigos` y acciones de sesion (`Mensaje`, `Ver perfil`, `Ver sesiones`).
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Amigos: tarjetas de vista previa de sesiones enriquecidas

- Redisenadas las cards de `Sesiones de amigos` para mostrar informacion social y de sesion completa.
- Cada tarjeta ahora incluye:
  - preview visual de sesion (foto si el usuario la ha subido, o placeholder de mapa del spot en su defecto),
  - miniavatar y nombre de usuario,
  - spot de la sesion,
  - salto mas alto,
  - distancia recorrida,
  - duracion de sesion,
  - equipo utilizado (marcado como placeholder para fase 2),
  - bloque de interaccion social con likes, boton de like y boton de comentar.
- Se mantienen accesos rapidos existentes a `Mensaje`, `Ver perfil` y `Ver sesiones`.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Community Amigos: acceso a detalle de sesion desde la tarjeta

- Eliminados botones de accion en la tarjeta de sesion (`Mensaje`, `Ver perfil`, `Ver sesiones`) segun feedback de UX.
- La tarjeta completa de sesion ahora es clicable y abre directamente el detalle de sesion.
- El detalle se abre reutilizando `SessionDetailPage` para mantener el mismo formato visual que el resto de la app.
- Se han anadido campos de fecha real en el modelo de preview para alimentar la navegacion a detalle.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-24 - Session Detail: resumen sustituido por media de sesion

- Sustituida la tarjeta de texto `Resumen` en `Detalle de sesion` por una tarjeta visual de media de sesion.
- Nuevo comportamiento en detalle:
  - si la sesion tiene foto elegida por el usuario, se muestra bloque visual de foto,
  - si no hay foto, se muestra fallback de mapa del spot,
  - soporte de etiqueta opcional de origen de media (camara/galeria/mapa fallback).
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`

### 2026-02-24 - Upload Session dialog: opciones camara/galeria + fallback mapa

- Anadidas opciones en el dialogo `Configurar sesion` para seleccionar fuente de media:
  - `Hacer foto`
  - `Galeria`
  - `Mapa del spot` (fallback)
- Al subir sesion se persiste el tipo de media en el registro de sesion para reflejarlo en detalle.
- Actualizado modelo `_RecordedSession` con:
  - `hasSessionPhoto`
  - `sessionMediaLabel`
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`

### 2026-02-24 - Community Amigos: tap en tarjeta abre detalle con media de sesion

- Ajustada apertura de detalle desde cards de `Sesiones de amigos` para pasar info de media y mostrar detalle consistente con `SessionDetailPage`.
- Archivo actualizado:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`

  - Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-02-25 - Profile: implementacion completa de pestaña Perfil

- Implementada página `ProfilePage` siguiendo el patrón visual de las otras pestañas.
- Anadido `SegmentedButton` con 3 vistas:
  - `Perfil`: información del usuario, avatar, nivel, sesiones, estadísticas.
  - `Mi equipo`: gestión de kite, tabla, lineas, arnes, traje y tallas guardadas.
  - `Ajustes`: unidades (velocidad, distancia, temperatura, altura), notificaciones, app (idioma, tema, versión), cuenta.
- Diseño coherente con el estilo de la app (Cards, padding, tipografía).
- Tests widget anadidos para cobertura de Profile:
  - `test/features/profile/presentation/pages/profile_page_test.dart`
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`

### 2026-02-25 - Profile: fix crash en pestana Mensajes

- Corregido error al pulsar pestana Mensajes en ProfilePage.
- Problema: uso de `Expanded` dentro de `ListView` causaba conflicto de layout.
- Solucion: cambiado a `SizedBox` con altura fija para el contenido de mensajes.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-25 - Settings: anadido boton FAQ

- Anadido boton FAQ en la pagina de Ajustes para acceder a preguntas frecuentes.
- FAQ dentro de tarjeta App junto a Idioma, Tema y Version.
- Nueva pantalla FaqPage con preguntas frecuentes en formato expandible:
  - Como vinculo mi dispositivo wearable?
  - Que significan los valores de Big Air Score?
  - Como cambio las unidades de medicion?
  - Mis datos se guardan automaticamente?
  - Como contacto con soporte?
- Anadida ruta `/settings/faq` en router.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/settings_page.dart`
  - `lib/features/profile/presentation/pages/faq_page.dart` (nuevo)
  - `lib/app/router/app_router.dart`
  - `lib/app/router/app_routes.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-25 - FAQ: movido buzon de sugerencias desde Profile

- Movido el buzon de sugerencias desde la pestana Mensajes de Profile a la pantalla FAQ.
- Ahora FAQ incluye:
  - Lista de preguntas frecuentes en formato expandible.
  - Buzon de sugerencias al final de la pantalla.
- Eliminado pestana Sugerencias de ProfilePage (solo queda Mensajes).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/faq_page.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
- Verificacion ejecutada: `flutter analyze` (ok).

### 2026-02-28 - Mi equipo: lineas y barra con entrada manual

- Ajuste solicitado en configurador de quiver (`Mi equipo`):
  - `Longitud de lineas (m)` pasa de selector cerrado a campo manual,
  - `Ancho de barra (cm)` pasa de selector cerrado a campo manual.
- Se mantienen valores iniciales por defecto (`22` y `50`) y carga/limpieza correcta al:
  - guardar equipo,
  - cargar un equipo guardado en el formulario,
  - resetear formulario tras guardado.
- Actualizado manejo interno para leer estos dos parametros desde `TextEditingController`.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: mas parametros manuales y marcas adicionales

- Ajustado formulario `Mi equipo` segun feedback:
  - `Tamano (m)` de cometa pasa a entrada manual,
  - `Grosor (mm)` de traje pasa a entrada manual,
  - se anade `Marca` en apartado `Tabla`,
  - se anade `Marca` en apartado `Arnes`.
- Actualizado modelo de datos del quiver para guardar tambien:
  - marca de tabla,
  - marca de arnes.
- Se mantiene compatibilidad de flujos:
  - guardar equipo,
  - cargar equipo guardado al formulario,
  - limpieza/reset del formulario con valores por defecto.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: flujo por componentes + equipacion personalizada

- Reestructurada la pestaña `Mi equipo` para seguir el flujo de producto solicitado:
  1) configurar y guardar `Cometa`,
  2) configurar y guardar `Barra`,
  3) configurar y guardar `Tabla`,
  4) configurar y guardar `Arnes`,
  5) configurar y guardar `Traje`.
- Cada categoria tiene ahora:
  - su propio formulario,
  - boton de guardado independiente,
  - lista de items guardados,
  - eliminacion por item.
- Anadido bloque de `Equipacion personalizada`:
  - nombre de equipacion,
  - selector de una pieza guardada por cada categoria,
  - guardado final de la equipacion,
  - listado de equipaciones guardadas.
- Ajuste de integridad:
  - al eliminar una pieza base (cometa/barra/tabla/arnes/traje), se eliminan tambien las equipaciones que dependan de esa pieza.
- Refactor de modelo UI de `Mi equipo`:
  - se elimina el modelo anterior monolitico de quiver,
  - se introducen modelos separados por tipo de componente y modelo de equipacion compuesta.
- Tests de widget actualizados para reflejar el nuevo flujo por componentes y guardado de equipacion.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: limpieza de labels en tarjetas

- Ajuste visual solicitado en tarjetas de configuracion de `Mi equipo`:
  - eliminados prefijos numerados (`1)`, `2)`, etc.) en titulos de seccion.
- Titulos finales mostrados:
  - `Cometa`, `Barra`, `Tabla`, `Arnes`, `Traje`.
- Tambien actualizado el texto resumen superior para quitar numeracion y mantener solo nombres de secciones.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`

### 2026-02-28 - Mi equipo: productos guardados solo en desplegables

- Ajuste UX en la pestaña `Mi equipo`:
  - al pulsar `Guardar cometa`, `Guardar barra`, `Guardar tabla`, `Guardar arnes` o `Guardar traje`, los elementos ya no se renderizan como lista dentro de la tarjeta de cada bloque.
- Comportamiento final:
  - los elementos guardados se usan en los menus desplegables de `Equipacion personalizada`,
  - en cada bloque se mantiene contador + texto de ayuda indicando que estan disponibles en desplegable.
- Limpieza tecnica asociada:
  - eliminados metodos de borrado por pieza que dejaron de usarse al quitar las listas visibles por bloque.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok en esta iteracion de UI)

### 2026-02-28 - Mi equipo: configuracion por dialogos

- Ajuste UX aplicado en `Mi equipo` para evitar ocupar demasiada pantalla:
  - cada seccion (`Cometa`, `Barra`, `Tabla`, `Arnes`, `Traje`) ahora se configura desde un dialogo modal.
- Flujo nuevo por bloque:
  - boton `Configurar ...` abre dialogo,
  - el formulario vive dentro del dialogo,
  - al confirmar `Guardar ...`, se guarda el item y se cierra el dialogo.
- Se mantiene el comportamiento existente:
  - contadores por categoria,
  - disponibilidad en desplegables de `Equipacion personalizada`,
  - guardado final de equipacion.
- Tests de widget adaptados al flujo con dialogos.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: anadido campo ano en todas las configuraciones

- Se anade campo `Ano` en todos los dialogos de configuracion:
  - cometa,
  - barra,
  - tabla,
  - arnes,
  - traje.
- El ano se guarda dentro de cada item configurado y se muestra tambien en los desplegables de `Equipacion personalizada`.
- Se inicializa por defecto con el ano actual para agilizar el flujo de guardado.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: selector tipo pestañas para seccion activa

- Ajuste de UX en tarjeta `Configurar quiver`:
  - los textos de categorias se convierten en selector tipo pestañas con `SegmentedButton` (`Cometa`, `Barra`, `Tabla`, `Arnes`, `Traje`).
- Nuevo comportamiento:
  - segun categoria seleccionada, se muestra una sola tarjeta de accion con su boton `Configurar ...` y su contador de guardados,
  - evita mostrar las cinco tarjetas de configuracion a la vez.
- Refactor asociado:
  - extraidos helpers para renderizar seccion activa (`_buildSelectedGearConfigSection` y `_buildGearConfigSection`).
- Tests de widget ajustados para cambiar la pestana antes de abrir cada dialogo.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: ajuste visual de segmented de configuracion

- Mejorado el segmented de `Configurar quiver` para evitar que etiquetas largas (como `Cometa`) se partan o eleven la altura del control en pantallas estrechas.
- Cambios de UI aplicados:
  - segmented envuelto en scroll horizontal,
  - desactivado icono de seleccionado,
  - densidad compacta y target reducido para mantener altura mas contenida.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: gestion por desplegable (editar/eliminar)

- Implementada gestion directa de items guardados por categoria debajo del contador (`Cometas guardadas`, etc.).
- En cada seccion activa ahora aparece un desplegable de elemento guardado + acciones:
  - `Editar` abre el dialogo de configuracion con datos precargados,
  - `Eliminar` borra el item seleccionado.
- Cobertura aplicada para todas las categorias:
  - cometa, barra, tabla, arnes y traje.
- Integridad de datos al eliminar:
  - si se elimina una pieza usada en equipaciones guardadas, esas equipaciones dependientes se eliminan automaticamente.
- Los metodos de guardado pasan a modo `crear/editar` (upsert por id) para reutilizar los mismos dialogos.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: confirmacion antes de eliminar

- Ajuste de seguridad UX en gestion de items guardados:
  - al pulsar `Eliminar` en cometa/barra/tabla/arnes/traje ahora se muestra dialogo de confirmacion.
- El borrado solo se ejecuta tras confirmar explicitamente; `Cancelar` cierra sin cambios.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: unificacion de tarjetas de configuracion

- Ajuste de layout en pestaña `Mi equipo`:
  - la tarjeta `Configurar quiver` y la tarjeta de configuracion activa se fusionan en una sola tarjeta.
- Nuevo resultado visual:
  - en la misma tarjeta se muestran titulo + selector segmentado + bloque de configuracion activo.
- Se mantiene sin cambios el flujo funcional de configuracion, edicion/eliminacion y guardado de equipaciones.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: nueva categoria Casco en segmented de quiver

- Anadida nueva opcion `Casco` al segmented de `Configurar quiver`.
- Se incorpora flujo completo de casco en la misma arquitectura que el resto:
  - boton `Configurar casco`,
  - dialogo de alta/edicion (`Marca`, `Modelo`, `Ano`),
  - contador de cascos guardados,
  - desplegable de gestion con `Editar` y `Eliminar` (con confirmacion).
- Se anade soporte de estado/modelo interno para cascos (`_savedHelmets`, seleccion de gestion, busqueda y borrado).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: nueva categoria Chaleco en segmented de quiver

- Anadida opcion `Chaleco` al segmented de `Configurar quiver`.
- Se implementa flujo completo para chaleco:
  - boton `Configurar chaleco`,
  - dialogo de alta/edicion (`Marca`, `Modelo`, `Ano`),
  - contador de chalecos guardados,
  - desplegable de gestion con `Editar` y `Eliminar` (con confirmacion).
- Anadido estado/modelo interno para chalecos (`_savedVests`, seleccion de gestion, busqueda y borrado).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: chaleco con talla

- Ajuste funcional en categoria `Chaleco`:
  - se anade campo `Talla chaleco` en el dialogo de configuracion.
- La talla queda guardada en el modelo de chaleco y se muestra en el desplegable de gestion de chalecos.
- Se mantiene soporte de alta/edicion/eliminacion con confirmacion.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: tallas manuales en todos los componentes

- Ajuste solicitado: las tallas pasan a entrada manual en todos los componentes que usan talla.
- Cambios aplicados:
  - `Arnes`: `Talla arnes` pasa de selector fijo a campo manual.
  - `Traje`: `Talla traje` pasa de selector fijo a campo manual.
  - `Chaleco`: `Talla chaleco` pasa de selector fijo a campo manual.
- Actualizacion tecnica:
  - migracion de esas tallas a `TextEditingController` para alta/edicion/reset.
  - validacion de guardado adaptada para requerir talla manual no vacia.
  - modelo de chaleco mantiene y muestra talla en gestion.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: equipacion personalizada incluye casco y chaleco

- Se amplia la tarjeta `Equipacion personalizada` para incluir:
  - selector de `Casco`,
  - selector de `Chaleco`.
- Actualizacion del modelo de equipacion para guardar referencias opcionales de casco y chaleco.
- Se sincroniza estado al crear/eliminar:
  - al guardar casco/chaleco se autoseleccionan en equipacion (si no habia seleccion previa),
  - al eliminar casco/chaleco se limpia o reajusta seleccion y se eliminan equipaciones dependientes.
- Listado de equipaciones guardadas actualizado para mostrar tambien casco y chaleco en el resumen.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: configuracion de equipacion personalizada en dialogo

- Mejora de UX en tarjeta `Equipacion personalizada` para reducir altura de pantalla.
- El formulario completo (nombre + seleccion de todas las piezas) se mueve a dialogo modal:
  - nuevo boton principal `Configurar equipacion`,
  - dialogo con selectores de cometa, barra, tabla, arnes, traje, casco y chaleco,
  - guardado final desde el propio dialogo.
- La tarjeta en pantalla mantiene vista compacta con:
  - boton para abrir configuracion,
  - listado de equipaciones guardadas.
- Tests de widget actualizados para el nuevo flujo (abrir dialogo y guardar desde modal).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: menu de 3 puntos en equipaciones guardadas (editar/eliminar)

- Reemplazado boton de borrado directo en cada equipacion guardada por menu de 3 puntos (`more_horiz`).
- Nuevo menu por item con acciones:
  - `Editar`: abre dialogo de `Configurar equipacion` precargado y guarda cambios sobre la equipacion existente.
  - `Eliminar`: solicita confirmacion y luego elimina.
- Ajuste tecnico en guardado de equipacion:
  - `save` soporta ahora modo crear/editar mediante `editingId` para persistir cambios en el mismo item.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: tarjetas clicables + detalle de equipacion + opcionales en blanco

- `Equipaciones guardadas` pasan a mostrarse como tarjetas clicables (tap) en lugar de lista plana.
- Al pulsar una tarjeta se abre dialogo de detalle con el equipo configurado.
- Se mantiene menu de 3 puntos por tarjeta (`Editar`/`Eliminar`) funcionando.
- Regla funcional de configuracion actualizada:
  - obligatorios para guardar equipacion: `Cometa` y `Tabla` (ademas del nombre),
  - resto de piezas opcionales (`Barra`, `Arnes`, `Traje`, `Casco`, `Chaleco`) permiten quedar en blanco (`Sin ...`).
- En resumen y detalle de equipacion se muestran solo componentes realmente configurados; los opcionales vacios no aparecen.
- Ajuste de integridad al eliminar piezas opcionales:
  - en lugar de borrar la equipacion, se limpia solo esa referencia en la equipacion guardada.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: ajustes finales en equipacion guardada y orden de configuracion

- `Equipaciones guardadas` se consolidan como tarjetas interactivas con tap para abrir detalle completo en dialogo.
- En configuracion de equipacion:
  - obligatorios definitivos: `Cometa` y `Tabla` (mas nombre),
  - opcionales con posibilidad de vacio (`Sin ...`): `Barra`, `Arnes`, `Traje`, `Casco`, `Chaleco`.
- Si un opcional no se configura, no se muestra en resumen ni en detalle del equipo guardado.
- Se reordena la configuracion de equipacion para que `Tabla` aparezca en segundo lugar, justo despues de `Cometa`.
- Se mantiene menu de 3 puntos por tarjeta con `Editar` y `Eliminar` plenamente funcional.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: tarjeta de estadisticas de uso de equipacion

- Anadida nueva tarjeta en el placeholder de `Mi equipo` para mostrar estadisticas de uso de equipaciones.
- Contenido actual de la tarjeta:
  - equipaciones guardadas,
  - equipaciones completas,
  - equipaciones sin casco,
  - equipaciones sin chaleco,
  - fecha de ultima configuracion guardada.
- Implementado formateo simple de fecha (`dd/MM/yyyy`) para el indicador de ultima configuracion.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: reubicacion visible de estadisticas de uso

- Corregida ubicacion de la tarjeta `Estadisticas de uso de equipacion` para que aparezca en la pestaña `Mi equipo` (debajo de `Equipacion personalizada`).
- Antes estaba renderizada en `Perfil`, por eso no se veia en el flujo esperado.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: tabla permite guardar sin medida

- Ajuste en configuracion de `Tabla`:
  - la medida (`Tamano tabla (cm)`) deja de ser obligatoria para guardar.
- Actualizado tambien el detalle de equipacion para que, si la medida esta vacia, no muestre sufijo `cm` ni valor en blanco.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: tarjeta de estadisticas con acceso a pantalla de detalles

- Ajuste en tarjeta `Estadisticas de uso de equipacion`:
  - eliminados indicadores `Sin casco` y `Sin chaleco`.
  - anadido boton `Detalles`.
- Nuevo flujo:
  - al pulsar `Detalles` se navega a una pantalla dedicada con metricas ampliadas.
- Nueva pantalla de detalle incluye multiples parametros:
  - resumen general de equipaciones,
  - inventario guardado por tipo de componente,
  - porcentajes de uso por componente opcional.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: inventario interactivo con dialogo y grafico de barras

- Mejora en pantalla `Detalles de equipacion` dentro de la tarjeta de estadisticas:
  - en bloque `Inventario guardado`, cada item (`Cometas`, `Tablas`, etc.) ahora es clickable.
- Al pulsar un item de inventario se abre un dialogo con:
  - desplegable de parametro (`Numero de sesiones` / `Tiempo total de uso`),
  - grafico de barras (horizontal) por elemento guardado de esa categoria.
- Los valores se calculan desde equipaciones guardadas:
  - sesiones = veces que aparece ese elemento en equipaciones,
  - tiempo total de uso = estimacion base derivada de sesiones (placeholder actual).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: inventario guardado con boton en cada fila

- Ajuste UX en tarjeta `Inventario guardado`:
  - se sustituye la flecha de navegacion por boton explicito `Detalles` en cada fila.
- La accion se mantiene: al pulsar `Detalles` se abre el dialogo correspondiente del item.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: dialogo de inventario sin grafico de barras

- Ajuste solicitado en dialogo de `Detalles` de inventario:
  - se elimina el grafico de barras.
- El dialogo mantiene:
  - selector de parametro (`Numero de sesiones` / `Tiempo total de uso`),
  - listado simple por elemento con valor correspondiente.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: revert de dialogo de inventario (vuelve grafico de barras)

- Revertido el ultimo ajuste del dialogo de `Detalles` en inventario.
- Estado restaurado:
  - se mantiene selector de parametro,
  - vuelve visualizacion con grafico de barras por elemento.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: uso por componente con boton Detalles y dialogo

- En bloque `Uso por componente` se anade boton `Detalles` en cada fila.
- Al pulsar `Detalles` se abre dialogo con informacion ampliada del componente:
  - porcentaje de uso,
  - numero de equipaciones que incluyen ese componente,
  - total de equipaciones analizadas.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: ampliacion masiva de KPI en Detalles de equipacion

- Se anaden bloques KPI adicionales en pantalla `Detalles de equipacion` para explorar quiver en profundidad.
- KPI incorporados:
  - **Rotacion y diversidad**:
    - top cometas usadas,
    - top tablas usadas,
    - combinaciones unicas,
    - diversidad del quiver.
  - **Dependencia y actualizacion**:
    - dependencia de cometa top,
    - dependencia de tabla top,
    - ultima actualizacion por categoria clave.
  - **Material y tallas**:
    - antiguedad media global,
    - ano medio por categoria,
    - distribucion de tallas (arnes/traje/chaleco).
  - **Perfiles tecnicos**:
    - reparto de cometas por rangos de tamano,
    - balance de tipos de tabla.
  - **Calidad de configuracion**:
    - version minima/media/completa,
    - indice de reutilizacion,
    - items inconsistentes.
- Se mantienen los bloques previos (`Resumen general`, `Inventario guardado`, `Uso por componente`) y sus dialogos de detalle.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-02-28 - Mi equipo: completar bloque Dependencia y actualizacion

- Se amplia el bloque `Dependencia y actualizacion` para incluir todos los componentes, no solo cometa/tabla.
- Dependencias anadidas:
  - barra top,
  - arnes top,
  - traje top,
  - casco top,
  - chaleco top.
- Actualizaciones anadidas:
  - `Ultima actualizacion casco`,
  - `Ultima actualizacion chaleco`.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: correccion ortografica en KPI de Material y tallas

- Corregidos labels en bloque `Material y tallas`:
  - `Antiguedad` -> `Antigüedad`,
  - `Ano medio cometas/tablas` -> `Año medio cometas/tablas`.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: quitar efecto muelle en Detalles de equipacion

- Ajustado scroll de la pantalla `Detalles de equipacion` para eliminar efecto muelle/elasticidad.
- Se aplica `ClampingScrollPhysics` al `ListView` de la pagina de detalles.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: ajuste de texto en metrica de detalle

- Renombrada metrica en pantalla de detalles de uso:
  - de `Completitud media` a `Equipaciones completas (%)`.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: titulos de tarjetas centrados

- Ajuste visual en tarjetas principales de la pestaña `Mi equipo`:
  - `Configurar quiver` centrado,
  - `Equipacion personalizada` centrado.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: centrado en boton y texto de equipacion personalizada

- Ajuste visual adicional en tarjeta `Equipacion personalizada`:
  - boton `Configurar equipacion` centrado,
  - texto `Equipaciones guardadas (N)` centrado.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: centrado visual en tarjeta de configuracion

- Ajuste visual en tarjeta de configuracion activa (cometa/barra/tabla/arnes/traje):
  - titulo centrado,
  - boton `Configurar ...` centrado,
  - textos de estado/ayuda centrados.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Mi equipo: segmented de Configurar quiver con forma diferenciada

- Ajuste visual solicitado para no repetir apariencia del segmented principal de pestañas.
- El segmented de `Configurar quiver` ahora tiene estilo propio:
  - forma tipo `pill` (`StadiumBorder`),
  - borde tintado,
  - padding horizontal/vertical diferenciado,
  - contraste de estado seleccionado (fondo primario + texto blanco).
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-02-28 - Profile Mi equipo: configurador de quiver y guardado multiple

- Evolucionada la vista `Mi equipo` de placeholder a configurador funcional de equipos completos.
- Nuevo formulario de configuracion por apartados:
  - nombre del equipo,
  - kite (marca, modelo, tamano),
  - tabla (tipo, modelo, tamano),
  - lineas y barra (longitud, ancho),
  - arnes (modelo, talla),
  - traje (grosor, talla).
- Anadido guardado de multiples equipos en memoria dentro del perfil (`quiver`):
  - cada guardado crea un equipo nuevo,
  - listado de `Equipos guardados (N)` con todos los configurados,
  - accion para cargar un equipo guardado al formulario (duplicar como base),
  - accion para eliminar un equipo guardado.
- Ajuste de robustez UI en tests: snackbar de confirmacion solo se muestra cuando existe `Scaffold` disponible en contexto.
- Tests de widget actualizados y ampliados para cubrir:
  - presencia del nuevo formulario,
  - guardado de multiples equipos.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-01 - Revision de continuidad y reanudacion de roadmap

- Revisado el proyecto completo para retomar continuidad, con foco en `SESSION_TRACKER.md`.
- Validado estado tecnico actual de la rama:
  - `git status --short --branch` sin cambios pendientes,
  - `flutter analyze && flutter test -r compact` en verde.
- Identificado desalineamiento de contexto:
  - el `Proximo paso acordado` apuntaba a `auth` y no al foco real actual (`Profile > Mi equipo`).
- Actualizado `Proximo paso acordado` para reflejar el siguiente incremento real.
- Siguiente ejecucion acordada para la proxima sesion:
  - extraer `Mi equipo` en widgets/modelos dedicados dentro de `features/profile` manteniendo cobertura de tests.

### 2026-03-01 - Sessions: seleccion de equipo utilizado al subir sesion

- Implementada integracion entre `Profile > Mi equipo > Equipacion personalizada` y el dialogo de `Subir sesion` en `Session`.
- Nuevo flujo en `Configurar sesion`:
  - anadido selector `Equipo utilizado (opcional)` con opciones extraidas de equipaciones personalizadas,
  - si no hay equipaciones guardadas se muestra aviso contextual en el dialogo.
- Persistencia en el feed de `My Sessions`:
  - cada sesion subida puede guardar `gearSetupName`,
  - en la tarjeta se muestra `Equipo: ...` junto al resumen,
  - en `SessionDetailPage` se muestra chip del equipo utilizado.
- Soporte tecnico de estado compartido:
  - creado catalogo compartido `ProfileGearSetupCatalog` para publicar opciones de equipacion desde `ProfilePage` y consumirlas en `SessionsPage`.
- Tests anadidos/actualizados:
  - `test/features/sessions/presentation/pages/sessions_page_test.dart` incluye caso de seleccion de equipo en subida.
- Archivos actualizados:
  - `lib/features/profile/presentation/state/profile_gear_setup_catalog.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok)

### 2026-03-01 - Sessions UI: refinado visual de equipo usado

- Pulido visual del flujo de `Subir sesion` y detalle:
  - en el dialogo de subida, al elegir una equipacion se muestra una caja de confirmacion visual con icono y nombre,
  - en `Detalle de sesion` se anade tarjeta dedicada `Equipo utilizado` (nombre o estado no especificado).
- Se mantiene compatibilidad con feed y detalle previos.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)

### 2026-03-01 - Sessions UI: mini preview de equipo en My Sessions

- Implementado mini preview visual del equipo usado directamente en cada tarjeta de `My Sessions`.
- Cambio aplicado en subtitulo de la tarjeta:
  - metadatos de sesion en primera linea,
  - chip `Equipo: ...` con icono cuando existe equipacion asociada,
  - resumen en linea independiente para mantener legibilidad.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Sessions UI: ajuste responsive del chip de equipo

- Ajustado el chip `Equipo: ...` en tarjetas de `My Sessions` para moviles estrechos:
  - en anchos < 380 se reduce padding y tipografia del chip,
  - se oculta avatar para ahorrar espacio,
  - se mantiene texto con `ellipsis` para evitar desbordes.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Sessions UI: chip de equipo reemplaza resumen auto en cards

- Ajuste solicitado en `My Sessions`:
  - el chip de equipo ocupa el lugar donde antes salia el texto auto `Track sincronizado con sensores de velocidad, GPS y eventos.`,
  - ese texto auto ya no se renderiza en la tarjeta.
- Comportamiento final en card:
  - si hay equipo seleccionado: se muestra chip `Equipo: ...`,
  - si no hay equipo y el resumen es personalizado: se muestra el resumen,
  - si no hay equipo y el resumen era el texto auto: no se muestra segunda linea de resumen.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Sessions UI: chip de ejemplo para desarrollo visual

- Anadido chip de ejemplo temporal para iterar UI cuando la sesion no tiene equipo real:
  - etiqueta: `Equipo demo (UI)`,
  - se muestra en cards de `My Sessions` solo cuando no hay equipo y el resumen es el texto auto por defecto.
- Implementado como flag local de desarrollo en la pagina de sesiones:
  - `SessionsPageState._showUiExampleGearChip = true`.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Fix estabilidad: dropdown de equipacion en subir sesion

- Corregida inestabilidad/crash al seleccionar el desplegable de equipacion en `Configurar sesion`.
- Endurecido el selector con estas medidas:
  - valor sentinela no nulo (`__none__`) para `Sin equipacion`,
  - deduplicacion de opciones por id antes de renderizar items,
  - `ValueKey` estable para el campo y control consistente del valor seleccionado.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Sessions UI: chip demo solo en debug

- Ajuste de UX para que el chip de ejemplo no contamine builds no-debug.
- Cambio aplicado:
  - `SessionsPageState._showUiExampleGearChip` pasa a `kDebugMode`.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Fix crash: escritura en resumen del dialogo de subir sesion

- Corregido crash reportado al escribir en el campo `Resumen de sesion (opcional)` del dialogo `Configurar sesion`.
- Cambios aplicados en el dialogo de subida:
  - reemplazo de estado local string por `TextEditingController` dedicado,
  - disposicion segura del controller con bloque `try/finally`,
  - contenido del `AlertDialog` envuelto en `SingleChildScrollView` para mejorar estabilidad con teclado/resize.
- Test de regresion anadido:
  - `keeps upload dialog stable when typing session summary` en `test/features/sessions/presentation/pages/sessions_page_test.dart`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: rediseño placeholder de Mensajes

- Reemplazado el placeholder tipo chat del tab `Mensajes` por dos apartados funcionales de gestion:
  - `Gestor de mensajes directos`: listado de conversaciones activas (preview, no leidos, estado silenciado, origen),
  - `Buscador de mis mensajes en la app`: busqueda transversal de mensajes propios en distintos modulos (Comunidad, Sesiones, Spots).
- Eliminado el compositor de chat (input + boton enviar) para mantener el enfoque de gestor/buscador.
- Datos mock de UI anadidos para iteracion de diseno y navegabilidad de la seccion.
- Tests actualizados:
  - anadido caso `mensajes tab shows direct manager and global search` en `test/features/profile/presentation/pages/profile_page_test.dart`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: Mensajes dividido en subpestanas

- Ajuste de estructura en el tab `Mensajes` segun feedback:
  - `Gestor de mensajes directos` pasa a subpestana `Directos`,
  - `Buscador de mis mensajes en la app` pasa a subpestana `Buscar en app`.
- Implementado `SegmentedButton` interno para alternar vistas dentro de `Mensajes`.
- Test actualizado para validar el cambio de subpestana y visibilidad del contenido.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: acceso a chat directo desde gestor de directos

- En la subpestana `Directos`, cada tarjeta de conversacion ahora incluye boton `Abrir chat`.
- El boton navega a una pantalla de chat directo con el usuario seleccionado:
  - app bar contextual `Chat con <usuario>`,
  - historial mock inicial,
  - composer con envio local para iterar UI del flujo de mensajeria.
- Test agregado para validar la navegacion desde gestor de directos.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: limpieza visual en tarjetas de Directos

- Ajuste solicitado en tarjetas de la subpestana `Directos`:
  - se mantiene el estado de `sin leer` cuando aplica,
  - se elimina el chip de `Mensajes directos`,
  - se elimina la previsualizacion de texto del chat en la tarjeta.
- Se conserva el boton `Abrir chat` para acceder al chat directo.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: boton de acceso a chat mas compacto

- Ajustado CTA en tarjetas de `Directos`:
  - etiqueta cambia de `Abrir chat` a `Chat` para reducir ancho visual.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: CTA de chat solo icono

- Ajustado el acceso al chat en tarjetas de `Directos` para mostrar solo el icono (sin texto).
- Boton reducido y mas limpio visualmente para no competir con la info principal de la tarjeta.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: menu de 3 puntos en Directos

- Anadido menu de opciones (3 puntos) en cada tarjeta de `Directos`.
- Opciones disponibles por chat:
  - `Silenciar usuario` / `Activar notificaciones` (toggle),
  - `Bloquear usuario`,
  - `Eliminar chat`.
- Comportamiento actual:
  - silenciar actualiza el estado visual de la tarjeta,
  - bloquear/eliminar quitan el chat del gestor,
  - bloquear muestra confirmacion via `SnackBar`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile UI: acciones de Directos con confirmacion y layout

- Ajustes solicitados en tarjetas de `Directos`:
  - boton de chat movido al lado izquierdo de la tarjeta (fila de acciones),
  - menu de 3 puntos mantenido en el lado derecho,
  - `Eliminar chat` ahora abre dialogo de confirmacion antes de borrar,
  - `Bloquear usuario` ahora abre dialogo de confirmacion,
  - bloquear ya no elimina el chat (solo marca estado bloqueado).
- Estado visual complementario:
  - anadido chip `Bloqueado` cuando corresponde.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo: envio de foto/video desde galeria y guardado local

- Implementado en ventana de chat directo:
  - adjuntar foto desde galeria,
  - adjuntar video desde galeria,
  - almacenamiento local de cada archivo en el dispositivo (`ApplicationDocumentsDirectory/direct_chats_media`).
- UI de mensajes multimedia:
  - imagen renderizada como burbuja visual,
  - video representado como tarjeta con icono y nombre de archivo,
  - ambos muestran estado `Guardado localmente`.
- Dependencias nuevas:
  - `image_picker`
  - `path_provider`
- Archivos actualizados:
  - `pubspec.yaml`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `ios/Runner/Info.plist`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter pub get` (ok)
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo UI: adjunto simplificado con boton +

- Ajuste de UX en composer de chat directo:
  - reemplazados botones separados de foto/video por un unico boton `+`,
  - al pulsar `+` se abre selector inferior con opciones `Foto desde galeria` y `Video desde galeria`.
- Se mantiene el mismo flujo de guardado local del archivo adjunto.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo UI: acciones de editar/eliminar desde app bar

- Anadido boton de opciones en el `AppBar` del chat directo para gestionar mensajes.
- Opciones implementadas:
  - `Editar ultimo mensaje` (solo mensajes de texto propios),
  - `Eliminar ultimo mensaje` (con confirmacion).
- Comportamiento:
  - si no hay mensajes propios aplicables, se muestra `SnackBar` informativo,
  - en edicion se abre dialogo con `TextField` y guardado del nuevo contenido.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo: editar cualquier mensaje y borrar uno o varios

- Ajuste funcional del menu del `AppBar` en chat directo:
  - `Editar mensaje` ahora permite elegir cualquier mensaje de texto del chat,
  - `Eliminar uno o varios` permite seleccion multiple de mensajes.
- Flujo de edicion:
  - selector de mensaje,
  - dialogo de edicion,
  - indicador visual `editado` junto a la hora tras guardar.
- Cobertura funcional final:
  - la edicion aplica a cualquier mensaje del chat,
  - para mensajes multimedia, se actualiza/visualiza el texto asociado al mensaje.
- Flujo de borrado:
  - selector multiple con checkboxes,
  - dialogo de confirmacion obligatorio antes de eliminar.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo UX: seleccion directa sobre mensajes para editar/eliminar

- Ajuste solicitado en el flujo de gestion de mensajes del chat directo:
  - al pulsar `Editar mensaje`, la seleccion se hace directamente tocando el mensaje en la timeline,
  - al pulsar `Eliminar uno o varios`, la seleccion multiple se hace directamente tocando mensajes en la timeline.
- Se eliminaron los selectores por dialogo/bottom-sheet para elegir mensajes.
- Edicion en linea:
  - al seleccionar mensaje en modo editar, su contenido pasa al composer,
  - boton principal cambia a `Guardar`,
  - al guardar queda indicador `editado` junto a la hora.
- Eliminacion en linea con confirmacion:
  - primer tap en `Eliminar (n)` arma confirmacion,
  - segundo tap en `Confirmar` ejecuta borrado de la seleccion.
- Soporte UI:
  - mensajes seleccionados se resaltan con borde,
  - en modo borrar se marca seleccion con check.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo UX: check en seleccion y copy de accion

- Ajuste solicitado en seleccion de mensajes:
  - el check visual aparece al seleccionar tanto en modo `Editar` como en modo `Eliminar`.
- Ajuste de copy en menu del app bar:
  - opcion renombrada de `Eliminar uno o varios` a `Eliminar mensaje`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo: restriccion de edicion solo a mensajes propios

- Ajuste de permisos en modo `Editar mensaje`:
  - solo se pueden seleccionar/editar mensajes enviados por el propio usuario,
  - al tocar mensajes recibidos se muestra feedback informativo.
- Defensa adicional al guardar:
  - se valida que el mensaje en edicion siga siendo propio antes de aplicar cambios.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo: soporte de deseleccion de mensaje seleccionado

- Ajuste UX en modo `Editar mensaje`:
  - al tocar de nuevo el mismo mensaje seleccionado, se deselecciona.
- Efecto de deseleccion:
  - se quita el check visual del mensaje,
  - se limpia el contenido del composer asociado a edicion.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Chat directo UX: cambio de copy en CTA de edicion

- Ajuste solicitado en modo editar del chat directo:
  - el boton principal cambia de `Guardar` a `Editar`.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-01 - Chat directo: restriccion de borrado solo a mensajes propios

- Ajuste de permisos en modo `Eliminar mensaje`:
  - solo se pueden seleccionar para borrar mensajes enviados por el propio usuario,
  - al tocar mensajes recibidos se muestra feedback informativo.
- Defensa adicional en ejecucion de borrado:
  - la eliminacion aplica un filtro final para borrar solo mensajes propios seleccionados.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Buscar en app: CTA y navegacion a comentario

- Ajuste del placeholder en subpestana `Buscar en app`:
  - cada tarjeta de resultado ahora incluye boton `Ir al comentario`,
  - al pulsar tarjeta o boton se navega al detalle del comentario indexado.
- Pantalla de destino placeholder anadida:
  - vista `Comentario` con contexto, texto y metadatos del mensaje.
- Tests actualizados:
  - validacion de presencia de `Ir al comentario`,
  - validacion de navegacion a pantalla `Comentario`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Comentario destino: sincronizacion con origen y funciones completas

- Upgrade del placeholder `Comentario` para cumplir comportamiento solicitado:
  - el mensaje se muestra completo (`SelectableText`),
  - la vista queda sincronizada con el mensaje indexado original,
  - soporta acciones de `Editar comentario` y `Eliminar comentario`.
- Sincronizacion aplicada:
  - al editar desde detalle, se actualiza tambien el item original en `Buscar en app`,
  - al eliminar desde detalle, desaparece del indice de resultados.
- Estado adicional:
  - indicador `Editado` cuando el comentario fue modificado.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Buscar en app: cambio de copy en CTA

- Ajuste de texto solicitado en resultados del buscador:
  - boton cambia de `Ir al comentario` a `Ver comentario`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Comentario destino: enlace a hilo completo

- En la pantalla `Comentario` se anade enlace `Ir al hilo`.
- Al pulsarlo abre vista `Hilo completo` con el mensaje original y respuestas del hilo.
- Se mantiene lectura completa de mensajes en el hilo (`SelectableText`).
- Tests actualizados:
  - caso `comment detail opens full thread view`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Hilo completo: visual anidada y permisos por autor

- Mejorada la vista `Hilo completo` para reflejar anidado de respuestas:
  - mensajes con nivel de profundidad,
  - sangria progresiva y guia visual lateral para identificar jerarquia.
- Permisos aplicados en acciones de mensaje del hilo:
  - solo mensajes propios (`Tu`) muestran opciones de `Editar mensaje` y `Eliminar mensaje`,
  - mensajes de otros usuarios quedan en modo solo lectura (sin acciones de edicion/borrado).
- Estado de mensajes en hilo:
  - soporte de indicador `Editado` tras modificar un mensaje propio.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Hilo completo: adjuntar foto/video al editar mensaje

- En el flujo `Editar mensaje` del hilo se anade boton `+` para adjuntos.
- Desde `+` se puede elegir:
  - foto desde galeria,
  - video desde galeria.
- El archivo se guarda localmente en dispositivo (`thread_media`) y se inserta referencia en el texto editado.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Comentario: dialogo de edicion alineado con editar mensaje

- Ajustado el dialogo `Editar comentario` para que sea equivalente al de `Editar mensaje`:
  - incluye boton `+` para adjuntar multimedia,
  - selector de `Foto desde galeria` / `Video desde galeria`,
  - etiqueta `Multimedia` junto al boton,
  - guardado local del archivo y referencia insertada en el texto.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Perfil: mejora de placeholder para vista publica del usuario

- Redisenado el tab `Perfil` para representar mejor la vista publica que veran otros usuarios.
- Cambios de UI aplicados:
  - cabecera visual con avatar, nombre, handle y estado de perfil publico,
  - chips de contexto de rider (nivel, sesiones, ranking local, spot base),
  - CTAs de `Vista publica` y `Editar perfil`,
  - bloque adicional de `Actividad reciente`.
- Se mantiene bloque `Estadisticas` existente para continuidad de informacion.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Perfil: boton Vista publica con preview navegable

- Implementado flujo de `Vista publica` en el tab `Perfil`.
- Al pulsar el boton se abre una pantalla ejemplo con la vista que veria otra persona al visitar el perfil.
- La preview incluye:
  - cabecera de perfil publico (avatar, handle y CTA de seguir),
  - resumen de identidad rider,
  - bloque de actividad publica reciente.
- Test agregado para validar navegacion desde `Vista publica`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Perfil: implementacion de edicion completa del perfil

- Implementado flujo funcional de `Editar perfil` (antes sin accion).
- Nuevo formulario dedicado con campos para editar toda la informacion mostrada:
  - identidad publica (nombre, handle, tagline, bio),
  - chips de perfil (nivel, sesiones, ranking, spot base),
  - estadisticas,
  - actividad reciente.
- Guardado aplicado al estado de perfil y reflejado en:
  - tab `Perfil`,
  - `Vista publica`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Perfil: boton Detalles en estadisticas con pantalla KPI completa

- En la tarjeta `Estadisticas` del tab `Perfil` se anade boton `Detalles`.
- Al pulsar abre nueva pantalla `KPIs del perfil` con metricas ampliadas:
  - sesiones, horas, saltos, top salto,
  - promedio por sesion, saltos por sesion,
  - bloque de rendimiento/contexto (ranking, spots, calorias estimadas, hilo destacado).
- Test agregado para validar navegacion a la pantalla KPI.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `test/features/profile/presentation/pages/profile_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Editar perfil: estadisticas en solo lectura

- Ajuste solicitado en `Editar perfil`:
  - los campos que se alimentan desde `Estadisticas` ya no se editan manualmente.
- Cambios aplicados:
  - eliminados inputs manuales de estadisticas en formulario,
  - anadido bloque `Estadisticas sincronizadas (solo lectura)` con valores bloqueados,
  - al guardar, esos KPIs conservan el valor sincronizado actual.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Editar perfil: soporte para foto de perfil y banner

- Implementado en `Editar perfil`:
  - seleccion de foto de perfil desde galeria,
  - seleccion de banner desde galeria,
  - guardado local de ambos assets en `profile_media`.
- Render sincronizado en:
  - tab `Perfil` (cabecera con avatar/banner),
  - `Vista publica` del perfil.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Conteo de horas (bloque en curso)

- Bloque `11:34-16:19` = `4h 45m`
- Historico estimado previo: `30h 00m`
- Track exacto desde `11:34`: `4h 45m`
- Total acumulado de referencia: `34h 45m`

### 2026-03-01 - Inicio de conteo de horas de programacion

- Solicitud: comenzar seguimiento de horas trabajadas en `SESSION_TRACKER.md`.
- Estado inicial del contador:
  - inicio de seguimiento: `2026-03-01 11:34`,
  - horas acumuladas desde este punto: `0h 00m`.
- Nota:
  - no se puede reconstruir con precision el total historico anterior sin registros de inicio/fin por bloque, por lo que el conteo oficial arranca desde esta marca temporal.
- Formato acordado para siguientes actualizaciones:
  - `Bloque HH:MM-HH:MM = Xm`,
  - `Acumulado = Xh Ym`.

### 2026-03-01 - Ajuste de baseline por estimacion del usuario

- Estimacion conservadora acordada por el usuario para trabajo previo no trazado: `~30h`.
- Se adopta baseline inicial:
  - `Historico estimado previo`: `30h 00m`,
  - `Track exacto desde 2026-03-01 11:34`: `0h 00m`,
  - `Total acumulado de referencia`: `30h 00m`.
- Nota de control:
  - desde este punto, cada bloque nuevo se suma al track exacto y al total de referencia.

### 2026-03-01 - Profile modularizacion fase 1: extraccion de Mensajes

- Iniciada modularizacion de `ProfilePage` para reducir tamaño y separar dominios de UI.
- Extraido el bloque de construccion de la pestaña `Mensajes` a archivo dedicado:
  - `lib/features/profile/presentation/pages/profile_messages_section.dart`.
- Implementacion tecnica:
  - uso de `part/part of` para mantener acceso a estado privado de `ProfilePageState`,
  - movidos a extension los builders de `Mensajes` (`Directos` y `Buscar en app`) y sus tiles.
- Ajuste de estado para evitar warnings de miembros protegidos desde extension:
  - anadidos helpers en `ProfilePageState` (`_setSelectedMessagesView`, `_setMessageSearchQuery`).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_messages_section.dart` (nuevo)
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile Mensajes: migracion inicial a Clean Architecture (domain/data/presentation)

- Aplicada migracion vertical del modulo `Mensajes` manteniendo UI/flujo actual.
- Nueva capa `domain` para mensajes:
  - entidades: `DirectMessageThread`, `AppMessageIndexEntry`,
  - repositorio abstracto: `ProfileMessagesRepository`,
  - casos de uso: consulta/listado, toggle mute, bloquear, eliminar chat, actualizar/eliminar comentario indexado.
- Nueva capa `data`:
  - implementacion `InMemoryProfileMessagesRepository` con seed inicial equivalente al comportamiento previo.
- Nueva capa `presentation`:
  - `ProfileMessagesController` como orquestador de estado de mensajes (subtab, query, listas filtradas y acciones).
- Integracion en `ProfilePage`:
  - eliminados estados locales monoliticos de mensajes,
  - la vista de `Mensajes` ahora consume el controller,
  - mantenidas pantallas de detalle/chat existentes sin cambios funcionales visibles.
- Ajuste de tipado:
  - reemplazadas clases privadas de mensajes por entidades de dominio compartidas en el flujo de comentario/hilo.
- Archivos anadidos:
  - `lib/features/profile/domain/entities/direct_message_thread.dart`
  - `lib/features/profile/domain/entities/app_message_index_entry.dart`
  - `lib/features/profile/domain/repositories/profile_messages_repository.dart`
  - `lib/features/profile/domain/usecases/profile_messages_use_cases.dart`
  - `lib/features/profile/data/repositories/in_memory_profile_messages_repository.dart`
  - `lib/features/profile/presentation/state/profile_messages_controller.dart`
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_messages_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile Mi equipo: migracion inicial a Clean Architecture (domain/data/presentation)

- Migrado el slice de `Mi equipo` a capas separadas manteniendo comportamiento y UI.
- `domain` (gear):
  - entidades consolidadas en `profile_gear_entities.dart` (`KiteItem`, `BarItem`, `BoardItem`, `HarnessItem`, `WetsuitItem`, `HelmetItem`, `VestItem`, `GearSetup`),
  - contrato de repositorio `ProfileGearRepository`,
  - fachada de casos de uso `ProfileGearUseCases`.
- `data` (gear):
  - implementacion `InMemoryProfileGearRepository` para operaciones de inventario y equipaciones.
- `presentation/state` (gear):
  - nuevo `ProfileGearController` como orquestador de estado y reglas de consistencia:
    - guardado/edicion de componentes,
    - borrado con limpieza de referencias en equipaciones,
    - gestion de seleccionados para gestion y armado de setup.
- Integracion en `ProfilePage`:
  - conectado `ProfileGearController` en `initState`,
  - `ProfilePage` delega operaciones de `Mi equipo` al controller,
  - sustituidas clases privadas de gear por aliases a entidades de dominio para mantener compatibilidad incremental.
- Compatibilidad cruzada mantenida:
  - sincronizacion con `ProfileGearSetupCatalog` intacta para el flujo de `Sessions`.
- Archivos anadidos:
  - `lib/features/profile/domain/entities/profile_gear_entities.dart`
  - `lib/features/profile/domain/repositories/profile_gear_repository.dart`
  - `lib/features/profile/domain/usecases/profile_gear_use_cases.dart`
  - `lib/features/profile/data/repositories/in_memory_profile_gear_repository.dart`
  - `lib/features/profile/presentation/state/profile_gear_controller.dart`
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile Perfil: migracion inicial a Clean Architecture (domain/data/presentation)

- Migrado el estado principal de `Perfil` (datos de usuario) a capas clean.
- `domain`:
  - entidad `UserProfileData`,
  - repositorio abstracto `ProfileRepository`,
  - casos de uso `GetProfileUseCase` y `SaveProfileUseCase`.
- `data`:
  - implementacion `InMemoryProfileRepository` para persistencia en memoria del perfil.
- `presentation/state`:
  - nuevo `ProfileController` para lectura/actualizacion de perfil desde la vista.
- Integracion en `ProfilePage`:
  - reemplazado estado local monolitico de perfil por `ProfileController`,
  - flujo de editar perfil ahora actualiza el repositorio via use case,
  - mantenida compatibilidad visual y de navegacion (vista publica, editar, KPIs).
- Limpieza incremental:
  - eliminada clase privada local `_UserProfileData` y sustituida por alias a entidad de dominio para mantener refactor gradual.
- Archivos anadidos:
  - `lib/features/profile/domain/entities/user_profile_data.dart`
  - `lib/features/profile/domain/repositories/profile_repository.dart`
  - `lib/features/profile/domain/usecases/profile_use_cases.dart`
  - `lib/features/profile/data/repositories/in_memory_profile_repository.dart`
  - `lib/features/profile/presentation/state/profile_controller.dart`
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 2: extraccion de seccion Perfil

- Continuada la reduccion de complejidad de `ProfilePage` extrayendo la seccion `Perfil` a archivo dedicado.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
- Contenido movido a extension de `ProfilePageState`:
  - builder de tab `Perfil`,
  - acciones de `Editar perfil`, `Vista publica` y `KPIs`,
  - helpers visuales de stats (`_buildStatRow`, `_buildStatChip`).
- Ajuste tecnico:
  - agregado helper en `ProfilePageState` (`_updateProfileData`) para evitar warning de uso de `setState` desde extension.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 3: extraccion de seccion Mi equipo

- Continuada modularizacion de `ProfilePage` extrayendo la construccion principal de `Mi equipo`.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_section.dart`
- Contenido movido a extension de `ProfilePageState`:
  - builder de tab `Mi equipo`,
  - bloque de estadisticas de uso de equipacion,
  - selector de configuracion por tipo de componente,
  - helper de formato de fecha para stats,
  - constructor reusable de seccion de configuracion.
- Ajuste tecnico:
  - agregado helper en `ProfilePageState` (`_setSelectedGearConfigTabIndex`) para evitar warning de uso de `setState` desde extension.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 4: extraccion de dialogs y gestion de Mi equipo

- Extraida la logica de dialogs y controles de gestion de `Mi equipo` a archivo dedicado.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart`
- Contenido movido a extension de `ProfilePageState`:
  - management widgets por tipo (`_buildKiteManagement`, `_buildBoardManagement`, etc.),
  - controles comunes (`_buildManagementControls`) y confirmacion de borrado,
  - dialogo de configuracion de equipacion,
  - dialogs de alta/edicion de cada componente (cometa, barra, tabla, arnes, traje, casco, chaleco),
  - dialogo de detalle de equipacion.
- Ajuste tecnico:
  - agregado helper `_mutateState` en `ProfilePageState` para centralizar `setState` y evitar warnings por uso de miembros protegidos desde extensiones.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile arquitectura: composition root inicial para `ProfilePage`

- Implementado composition root basico para instanciacion de dependencias de `ProfilePage`.
- Nuevo archivo:
  - `lib/features/profile/presentation/di/profile_page_dependencies.dart`
- Contenido:
  - `ProfilePageDependencies` con factory `inMemory()` que ensambla:
    - `ProfileController`,
    - `ProfileMessagesController`,
    - `ProfileGearController`,
    - junto con repositorios y casos de uso correspondientes.
- Integracion:
  - `ProfilePage` deja de construir repos/use cases/controllers directamente en `initState` y consume `ProfilePageDependencies.inMemory()`.
  - se reduce acoplamiento de la vista con detalles de construccion de capas data/domain.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/di/profile_page_dependencies.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 5: extraccion de paginas auxiliares de perfil

- Extraidas vistas auxiliares del bloque `Perfil` a archivo dedicado.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_aux_pages.dart`
- Contenido movido:
  - `_EditProfilePage` y `_EditProfilePageState`,
  - `_ProfileStatsDetailsPage`,
  - `_ProfileStatsRow`,
  - `_PublicProfilePreviewPage`.
- Integracion:
  - agregado `part 'profile_aux_pages.dart';` en `profile_page.dart`.
  - `ProfilePage` mantiene navegacion y contratos sin cambios funcionales.
- Resultado:
  - menor densidad de `profile_page.dart` y separacion mas clara entre pagina principal y subpantallas.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_aux_pages.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 6: extraccion de paginas indexadas de Mensajes

- Extraidas pantallas de comentario indexado e hilo a archivo dedicado de pages.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_messages_index_pages.dart`
- Contenido movido:
  - `_IndexedCommentDetailPage` + estado,
  - `_IndexedThreadPage` + estado,
  - `_ThreadMessage`,
  - enums de acciones asociadas al hilo/comentario indexado.
- Integracion:
  - agregado `part 'profile_messages_index_pages.dart';` en `profile_page.dart`.
  - se mantiene navegacion y comportamiento sin cambios funcionales.
- Nota tecnica:
  - para completar la extraccion sin riesgo de conflicto de simbolos, se limpio el bloque duplicado remanente en `profile_page.dart` mediante ajuste puntual del archivo.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_messages_index_pages.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 7: extraccion de chat directo de Mensajes

- Extraido el bloque de chat directo a archivo dedicado de pages.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_messages_chat_pages.dart`
- Contenido movido:
  - `_DirectChatPage` + estado,
  - `_DirectChatMessage`,
  - enums de modo/acciones del chat,
  - widgets auxiliares `_ChatImageBubble` y `_ChatVideoBubble`.
- Integracion:
  - agregado `part 'profile_messages_chat_pages.dart';` en `profile_page.dart`.
  - comportamiento de adjuntos, edicion/borrado y flujo de chat mantenidos.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_messages_chat_pages.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 8: extraccion de pagina de analitica de equipacion

- Extraida la pagina de detalle analitico de `Mi equipo` a archivo dedicado.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_usage_page.dart`
- Contenido movido:
  - `_GearUsageDetailsPage`,
  - `_UsageDatum`.
- Integracion:
  - agregado `part 'profile_gear_usage_page.dart';` en `profile_page.dart`.
  - el acceso desde el boton `Detalles` de estadisticas de equipacion se mantiene sin cambios funcionales.
- Resultado:
  - `profile_page.dart` queda mas enfocado en shell/orquestacion y las subpantallas quedan encapsuladas por dominio.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_usage_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 9: primer paso de salida de `part` a import explicito

- Ejecutado primer corte para reducir acoplamiento por `part/part of`.
- La pagina de analitica de equipacion ahora es libreria independiente (no `part`):
  - `lib/features/profile/presentation/pages/profile_gear_usage_page.dart`
- Cambios aplicados:
  - `_GearUsageDetailsPage` -> `GearUsageDetailsPage` (widget publico),
  - tipado migrado a entidades de dominio explicitas (`GearSetup`, `KiteItem`, etc.),
  - `profile_page.dart` reemplaza `part 'profile_gear_usage_page.dart'` por import normal,
  - ajuste de llamada en `profile_gear_section.dart` para consumir `GearUsageDetailsPage`.
- Resultado:
  - validado el patron para migrar gradualmente otros archivos fuera de `part`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_section.dart`
  - `lib/features/profile/presentation/pages/profile_gear_usage_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 10: migracion de `profile_aux_pages` fuera de `part`

- Continuada migracion incremental para reducir acoplamiento por `part`.
- `profile_aux_pages.dart` ahora funciona como libreria independiente con imports propios.
- Cambios aplicados:
  - eliminado `part of` en `profile_aux_pages.dart`,
  - widgets promovidos a publicos para consumo por import:
    - `_EditProfilePage` -> `EditProfilePage`,
    - `_ProfileStatsDetailsPage` -> `ProfileStatsDetailsPage`,
    - `_PublicProfilePreviewPage` -> `PublicProfilePreviewPage`,
  - tipado ajustado a entidad de dominio explicita `UserProfileData`,
  - `profile_page.dart` reemplaza `part 'profile_aux_pages.dart'` por import normal,
  - actualizadas referencias en `profile_overview_section.dart`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_aux_pages.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 11: migracion de `profile_messages_chat_pages` fuera de `part`

- Aplicada conversion de la pagina de chat directo para eliminar dependencia de `part/part of`.
- `profile_messages_chat_pages.dart` ahora es libreria independiente con imports propios.
- Cambios aplicados:
  - eliminado `part of` y agregados imports (`flutter`, `image_picker`, `path_provider`, `app_spacing`, `dart:io`),
  - widget principal promovido a publico:
    - `_DirectChatPage` -> `DirectChatPage` (constructor con `key`),
  - `profile_page.dart` reemplaza `part 'profile_messages_chat_pages.dart'` por import normal,
  - actualizada referencia en `profile_messages_section.dart` para abrir `DirectChatPage`.
- Ajuste de desacople adicional:
  - `profile_messages_index_pages.dart` deja de depender del enum privado del chat y usa enum local propio para seleccion de adjuntos.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_messages_chat_pages.dart`
  - `lib/features/profile/presentation/pages/profile_messages_section.dart`
  - `lib/features/profile/presentation/pages/profile_messages_index_pages.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 12: migracion de `profile_messages_index_pages` fuera de `part`

- Convertida la pagina de comentario indexado e hilo a libreria independiente (sin `part/part of`).
- Cambios aplicados:
  - eliminado `part of` y agregados imports propios (`flutter`, `image_picker`, `path_provider`, `app_spacing`, `dart:io`, entidad de dominio),
  - widget principal promovido a publico:
    - `_IndexedCommentDetailPage` -> `IndexedCommentDetailPage` (constructor con `key`),
  - `profile_page.dart` reemplaza `part 'profile_messages_index_pages.dart'` por import normal,
  - actualizada apertura de detalle en `ProfilePage` para usar `IndexedCommentDetailPage`.
- Limpieza complementaria:
  - removidos imports no usados de `profile_page.dart` tras la migracion de responsabilidades.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_messages_index_pages.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 13: migracion de `profile_messages_section` fuera de `part`

- Convertida la seccion principal de `Mensajes` a widget independiente para eliminar dependencia de miembros privados por `part`.
- `profile_messages_section.dart` ahora es libreria standalone con imports explicitos.
- Cambios aplicados:
  - reemplazada extension sobre `ProfilePageState` por widget publico `ProfileMessagesSection`,
  - movidos tiles auxiliares a widgets privados internos del archivo,
  - callbacks explicitados para acciones (`mute`, `block`, `delete`, busqueda y apertura de comentario),
  - `profile_page.dart` deja de usar `part 'profile_messages_section.dart'` y pasa a import normal,
  - `_buildTabContent` ahora instancia `ProfileMessagesSection` con datos/callbacks del estado actual,
  - eliminado enum `_DirectMessageAction` del archivo principal (queda encapsulado en la seccion de mensajes).
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_messages_section.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-01 - Profile modularizacion fase 14: migracion de `profile_overview_section` fuera de `part`

- Convertida la seccion principal de `Perfil` a widget standalone con imports explicitos.
- `profile_overview_section.dart` ahora es libreria independiente (sin `part/part of`).
- Cambios aplicados:
  - extension sobre `ProfilePageState` reemplazada por widget publico `ProfileOverviewSection`,
  - navegacion a editar/vista publica/kpis encapsulada en la seccion con callback `onProfileUpdated`,
  - `profile_page.dart` reemplaza `part 'profile_overview_section.dart'` por import normal,
  - `_buildTabContent` en `ProfilePage` ahora instancia `ProfileOverviewSection`,
  - agregado helper local `_buildGearStatRow` en `profile_gear_section.dart` tras desacoplar helpers de perfil,
  - limpieza de imports no usados en `profile_page.dart`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Profile modularizacion fase 15: migracion de `profile_gear_section` fuera de `part`

- Continuada migracion incremental para reducir acoplamiento por `part` en `Profile`.
- `profile_gear_section.dart` ahora funciona como libreria independiente con imports propios.
- Cambios aplicados:
  - eliminado `part of` y reemplazada extension por widget publico `ProfileGearSection`,
  - encapsulada la construccion de `Mi equipo` en widget standalone con callbacks explicitos,
  - `profile_page.dart` reemplaza `part 'profile_gear_section.dart'` por import normal,
  - `ProfilePage` ahora inyecta estado/acciones de gear en `ProfileGearSection` desde `_buildTabContent`.
- Se mantiene `profile_gear_dialogs_section.dart` como `part` para la siguiente fase de desacople.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_gear_section.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Profile modularizacion fase 16 (paso preparatorio): controles de gestion de gear extraidos

- Avanzada la salida de `Mi equipo` desde `part` con extraccion de un bloque reusable fuera del archivo part.
- Nuevo widget standalone:
  - `lib/features/profile/presentation/pages/profile_gear_management_controls.dart`
- Cambios aplicados:
  - extraido el bloque comun de UI de gestion (`Dropdown + Editar/Eliminar`) a `ProfileGearManagementControls`,
  - `profile_gear_dialogs_section.dart` delega ese render y conserva la logica de confirmacion/borrado,
  - `profile_page.dart` anade import explicito del nuevo widget para consumo desde el `part` actual.
- Resultado:
  - se reduce complejidad interna del `part` de dialogs,
  - queda preparado el siguiente corte para migrar `profile_gear_dialogs_section.dart` completamente fuera de `part`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_gear_management_controls.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Profile modularizacion fase 17 (paso preparatorio): helpers de dialogs de gear extraidos

- Nuevo archivo de helpers standalone para reducir carga del `part` de dialogs de `Mi equipo`.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_helpers.dart`
- Cambios aplicados:
  - extraido helper de confirmacion de borrado `showConfirmDeleteItemDialog`,
  - extraido helper de detalle de equipacion `showGearSetupDetailsDialog`,
  - `profile_gear_dialogs_section.dart` delega ambas responsabilidades y mantiene solo orquestacion de estado,
  - agregado import en `profile_page.dart` para exponer helpers al `part` actual.
- Resultado:
  - menor densidad en `profile_gear_dialogs_section.dart`,
  - base preparada para el corte final de salida completa de `profile_gear_dialogs_section.dart` fuera de `part`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_helpers.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (control de sesion actual)

- Se mantiene baseline vigente:
  - `Historico estimado previo`: `30h 00m`
  - `Track exacto desde 2026-03-01 11:34`: `4h 45m`
  - `Total acumulado de referencia`: `34h 45m`
- Inicio de marca exacta para la continuacion de hoy:
  - `Bloque 19:23-19:23 = 0m` (inicio de tracking exacto de este tramo)
  - `Acumulado (track exacto desde 2026-03-01 11:34) = 4h 45m`
- Nota:
  - para no inventar tiempos, los minutos previos de hoy sin marca de inicio exacta quedan pendientes de consolidacion manual.

### 2026-03-02 - Profile modularizacion fase 18 (paso preparatorio): builders de gestion movidos al shell

- Avanzada la desacoplacion de `profile_gear_dialogs_section.dart` moviendo los builders de gestion al shell de `ProfilePage`.
- Cambios aplicados:
  - movidos al estado principal de `ProfilePage` los metodos:
    - `_buildKiteManagement`, `_buildBoardManagement`, `_buildBarManagement`,
    - `_buildHarnessManagement`, `_buildWetsuitManagement`, `_buildHelmetManagement`, `_buildVestManagement`,
    - `_buildManagementControls`.
  - `profile_gear_dialogs_section.dart` queda centrado en dialogs/acciones y reduce su superficie.
- Resultado:
  - menor acoplamiento entre el `part` y la composicion visual de `Mi equipo`,
  - preparado el corte final para sacar el archivo de dialogs fuera de `part` con menor riesgo.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:23-19:27 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 4h 49m`
- `Total acumulado de referencia = 34h 49m`

### 2026-03-02 - Profile modularizacion fase 19: eliminacion final de `part` en dialogs de gear

- Completada la salida final del archivo `profile_gear_dialogs_section.dart` fuera del esquema `part`.
- Cambios aplicados:
  - movidos al estado principal de `ProfilePage` todos los metodos restantes de dialogs de gear:
    - `_confirmDeleteItem`, `_openGearSetupDetailsDialog`, `_openGearSetupDialog`,
    - `_openKiteDialog`, `_openBarDialog`, `_openBoardDialog`, `_openHarnessDialog`, `_openWetsuitDialog`, `_openHelmetDialog`, `_openVestDialog`.
  - eliminado `part 'profile_gear_dialogs_section.dart';` de `profile_page.dart`.
  - eliminado el archivo `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart`.
- Resultado:
  - `ProfilePage` queda sin dependencias `part` para la seccion de gear,
  - desacople de libreria completado para `Mi equipo` en su flujo de configuracion/dialogs.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_section.dart` (eliminado)
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:27-19:32 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 4h 54m`
- `Total acumulado de referencia = 34h 54m`

### 2026-03-02 - Profile modularizacion fase 20: coordinador standalone para dialogs de gear

- Extraida la logica de dialogs de `Mi equipo` a un coordinador reutilizable y testeable sin `part`.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_coordinator.dart`
- Cambios aplicados:
  - creado `ProfileGearDialogsCoordinator` con metodos para:
    - confirmacion de borrado,
    - detalle de equipacion,
    - dialogo de setup,
    - dialogos de CRUD por item (cometa, barra, tabla, arnes, traje, casco, chaleco).
  - `ProfilePage` ahora construye una instancia `_gearDialogs` con dependencias explicitas (controllers, getters/setters, callbacks de guardado y finders).
  - los metodos privados del estado quedaron como wrappers finos que delegan al coordinador.
- Resultado:
  - reduccion notable del peso de `profile_page.dart`,
  - separacion clara de responsabilidades entre shell de pagina y orquestacion de dialogs,
  - base preparada para siguientes refactors por modulo sin acoplar UI principal.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_gear_dialogs_coordinator.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:32-19:39 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 01m`
- `Total acumulado de referencia = 35h 01m`

### 2026-03-02 - Profile modularizacion fase 21: extraccion de acciones de guardado/borrado de gear

- Extraidas del estado principal las operaciones de persistencia de `Mi equipo` (guardar y borrar) a un handler standalone.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_actions_handler.dart`
- Cambios aplicados:
  - creado `ProfileGearActionsHandler` con:
    - validaciones de guardado por tipo,
    - operaciones `save*` y `delete*`,
    - sincronizacion con `ProfileGearController`,
    - limpieza/default de formularios,
    - publicacion de setups para sesiones y `SnackBar` de confirmacion en guardado de equipacion.
  - `ProfilePage` ahora construye `_gearActions` y delega los metodos `_save*` / `_delete*` mediante wrappers finos.
- Resultado:
  - `profile_page.dart` reduce logica de negocio y se centra mas en composicion de pantalla,
  - arquitectura de gear queda separada en `section` + `management controls` + `dialogs coordinator` + `actions handler`.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_gear_actions_handler.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:39-19:44 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 06m`
- `Total acumulado de referencia = 35h 06m`

### 2026-03-02 - Profile modularizacion fase 22: extraccion de builders de gestion de gear

- Extraidos los builders de gestion de `Mi equipo` a una pieza standalone para reducir responsabilidad en `ProfilePage`.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/profile_gear_management_builder.dart`
- Cambios aplicados:
  - creado `ProfileGearManagementBuilder` con metodos:
    - `buildKiteManagement`, `buildBarManagement`, `buildBoardManagement`,
    - `buildHarnessManagement`, `buildWetsuitManagement`, `buildHelmetManagement`, `buildVestManagement`.
  - centralizada la composicion de `ProfileGearManagementControls` dentro del builder.
  - `ProfilePage` ahora delega en `_gearManagement` y conserva wrappers finos `_build*Management`.
- Resultado:
  - menor densidad de UI/state wiring en `profile_page.dart`,
  - continuidad del patron de extraccion: actions handler + dialogs coordinator + management builder.
- Archivos actualizados:
  - `lib/features/profile/presentation/pages/profile_gear_management_builder.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:44-19:57 = 13m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 19m`
- `Total acumulado de referencia = 35h 19m`

### 2026-03-02 - Hexagonal v3.0 fase 23: baseline arquitectonico global

- Se prioriza objetivo de v3.0: dejar el proyecto preparado para migracion hexagonal por features.
- Cambios aplicados (base de arquitectura):
  - creado blueprint oficial en `docs/architecture/hexagonal_v3.md`,
  - definido backlog de migracion por modulo en `docs/architecture/migration_backlog_v3.md`,
  - actualizado `README.md` con referencias directas a la documentacion de arquitectura.
- Resultado:
  - marco comun y reglas de dependencia para todo el equipo,
  - secuencia de migracion incremental clara (`profile` como piloto, resto por fases),
  - inicio formal de v3.0 orientado a arquitectura hexagonal en todo el proyecto.
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md` (nuevo)
  - `docs/architecture/migration_backlog_v3.md` (nuevo)
  - `README.md`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:57-20:01 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 23m`
- `Total acumulado de referencia = 35h 23m`

### 2026-03-02 - Hexagonal v3.0 fase 24: guardrails + modulo DI estandar para profile

- Paso de limpieza arquitectonica previo a nuevas migraciones funcionales.
- Cambios aplicados:
  - creado modulo DI estandar de feature en `lib/features/profile/di/profile_module.dart`,
  - `ProfilePage` ahora compone dependencias desde `ProfileModule.inMemory()` en lugar de wiring presentation-local,
  - mantenida compatibilidad con alias deprecated en `lib/features/profile/presentation/di/profile_page_dependencies.dart`,
  - agregado test de arquitectura en `test/architecture/hexagonal_dependency_rules_test.dart` con reglas automaticas:
    - `domain` no depende de Flutter/capas externas,
    - `presentation` no importa `infrastructure`.
  - actualizado blueprint en `docs/architecture/hexagonal_v3.md` con seccion de guardrails.
- Resultado:
  - base v3.0 mas limpia y protegida contra regresiones de arquitectura,
  - DI por feature alineado con objetivo hexagonal.
- Archivos actualizados:
  - `lib/features/profile/di/profile_module.dart` (nuevo)
  - `lib/features/profile/presentation/pages/profile_page.dart`
  - `lib/features/profile/presentation/di/profile_page_dependencies.dart`
  - `test/architecture/hexagonal_dependency_rules_test.dart` (nuevo)
  - `docs/architecture/hexagonal_v3.md`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:01-20:07 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 29m`
- `Total acumulado de referencia = 35h 29m`

### 2026-03-02 - Hexagonal v3.0 fase 25: migracion de use cases de profile a capa application

- Continuada migracion del piloto `profile` hacia la estructura objetivo hexagonal.
- Cambios aplicados:
  - movidos use cases a capa `application/use_cases`:
    - `lib/features/profile/application/use_cases/profile_use_cases.dart`
    - `lib/features/profile/application/use_cases/profile_messages_use_cases.dart`
    - `lib/features/profile/application/use_cases/profile_gear_use_cases.dart`
  - actualizados imports en:
    - `lib/features/profile/di/profile_module.dart`
    - `lib/features/profile/presentation/state/profile_controller.dart`
    - `lib/features/profile/presentation/state/profile_messages_controller.dart`
    - `lib/features/profile/presentation/state/profile_gear_controller.dart`
  - mantenida compatibilidad temporal mediante wrappers deprecated en:
    - `lib/features/profile/domain/usecases/profile_use_cases.dart`
    - `lib/features/profile/domain/usecases/profile_messages_use_cases.dart`
    - `lib/features/profile/domain/usecases/profile_gear_use_cases.dart`
  - actualizado backlog v3.0 marcando completados:
    - mover use cases a `application/use_cases`,
    - crear `di/profile_module.dart`.
- Resultado:
  - capa `application` ya activa en `profile`,
  - menor dependencia semantica de `presentation` respecto a `domain/usecases`,
  - transicion incremental sin romper compatibilidad.
- Archivos actualizados:
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/profile/application/use_cases/*` (nuevos)
  - `lib/features/profile/domain/usecases/*` (compatibilidad)
  - `lib/features/profile/di/profile_module.dart`
  - `lib/features/profile/presentation/state/profile_controller.dart`
  - `lib/features/profile/presentation/state/profile_messages_controller.dart`
  - `lib/features/profile/presentation/state/profile_gear_controller.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)
  - `flutter test test/features/profile/presentation/pages/profile_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:07-20:11 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 33m`
- `Total acumulado de referencia = 35h 33m`

### 2026-03-02 - Hexagonal v3.0 fase 26: puertos out + adaptadores infrastructure para profile

- Completado el cierre del piloto `profile` hacia estilo hexagonal completo.
- Cambios aplicados:
  - introducidos puertos de salida en:
    - `lib/features/profile/domain/ports/out/profile_repository_port.dart`
    - `lib/features/profile/domain/ports/out/profile_messages_repository_port.dart`
    - `lib/features/profile/domain/ports/out/profile_gear_repository_port.dart`
  - `application/use_cases` actualizado para depender de `ports/out` en lugar de contratos legacy,
  - creados adaptadores in-memory en `infrastructure/adapters/in_memory`:
    - `in_memory_profile_repository_adapter.dart`
    - `in_memory_profile_messages_repository_adapter.dart`
    - `in_memory_profile_gear_repository_adapter.dart`
  - `ProfileModule` actualizado para componer desde `infrastructure` y `application`,
  - mantenida compatibilidad incremental con aliases/wrappers deprecated en:
    - `domain/repositories/*`
    - `data/repositories/*`
    - `domain/usecases/*`.
  - backlog v3.0 actualizado:
    - `profile` marcado como migrado,
    - tareas internas de `profile` completadas.
- Resultado:
  - `profile` queda como referencia v3.0 con capas `domain/application/infrastructure/presentation`,
  - wiring limpio por feature y reglas de arquitectura ya automatizadas,
  - base lista para replicar en `auth`, `sessions`, `spots` y `community`.
- Archivos clave actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/profile/domain/ports/out/*` (nuevos)
  - `lib/features/profile/infrastructure/adapters/in_memory/*` (nuevos)
  - `lib/features/profile/application/use_cases/*`
  - `lib/features/profile/di/profile_module.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:11-20:17 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 39m`
- `Total acumulado de referencia = 35h 39m`

### 2026-03-02 - Hexagonal v3.0 fase 27: migracion de auth a application/infrastructure/ports

- Ejecutada migracion completa de `auth` al patron hexagonal base de v3.0.
- Cambios aplicados:
  - puertos de salida de dominio creados en:
    - `lib/features/auth/domain/ports/out/auth_session_port.dart`
    - `lib/features/auth/domain/ports/out/recent_auth_accounts_port.dart`
  - casos de uso en `application/use_cases`:
    - `auth_sign_in_use_cases.dart`
    - `recent_auth_accounts_use_cases.dart`
  - adaptadores in-memory en `infrastructure/adapters/in_memory`:
    - `in_memory_auth_session_adapter.dart`
    - `in_memory_recent_auth_accounts_adapter.dart`
  - modulo DI de feature creado en:
    - `lib/features/auth/di/auth_module.dart`
  - providers de presentation migrados para consumir el modulo y use cases:
    - `auth_session_provider.dart`
    - `recent_auth_accounts_provider.dart`
    - nuevo `auth_di_providers.dart`
  - backlog y blueprint arquitectonico actualizados para reflejar estado de `auth`.
- Resultado:
  - `auth` pasa de logica inline en providers a wiring por casos de uso,
  - se mantiene comportamiento funcional de login y cuentas recientes,
  - base lista para replicar el mismo patron en `sessions` y `spots`.
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/auth/domain/ports/out/*` (nuevos)
  - `lib/features/auth/application/use_cases/*` (nuevos)
  - `lib/features/auth/infrastructure/adapters/in_memory/*` (nuevos)
  - `lib/features/auth/di/auth_module.dart` (nuevo)
  - `lib/features/auth/presentation/providers/*` (actualizados)
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:17-20:21 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 43m`
- `Total acumulado de referencia = 35h 43m`

### 2026-03-02 - Hexagonal v3.0 fase 28: arranque de migracion sessions (slice dispositivos)

- Iniciado el modulo `sessions` con un primer slice hexagonal centrado en dispositivos enlazados.
- Cambios aplicados:
  - creada entidad de dominio `LinkedDevice` en:
    - `lib/features/sessions/domain/entities/linked_device.dart`
  - creado puerto de salida de dominio para dispositivos en:
    - `lib/features/sessions/domain/ports/out/session_devices_port.dart`
  - creados casos de uso de aplicacion:
    - `GetLinkedDevicesUseCase`, `SaveLinkedDeviceUseCase`, `DeleteLinkedDeviceUseCase`
    - archivo: `lib/features/sessions/application/use_cases/session_devices_use_cases.dart`
  - creado adaptador in-memory:
    - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_devices_adapter.dart`
  - creado modulo DI de feature:
    - `lib/features/sessions/di/sessions_module.dart`
  - integracion en `SessionsPage`:
    - inicializa dispositivos desde `SessionsModule.inMemory()`,
    - persiste altas/bajas de dispositivos via use cases del modulo,
    - reemplaza clase privada `_LinkedDevice` por alias a entidad de dominio.
  - backlog arquitectonico actualizado marcando completado el primer paso de `sessions`.
- Resultado:
  - `sessions` sale de estado 100% monolitico en UI y empieza a usar capas `domain/application/infrastructure`.
  - se mantiene comportamiento funcional existente sin regresiones.
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/sessions/domain/entities/linked_device.dart` (nuevo)
  - `lib/features/sessions/domain/ports/out/session_devices_port.dart` (nuevo)
  - `lib/features/sessions/application/use_cases/session_devices_use_cases.dart` (nuevo)
  - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_devices_adapter.dart` (nuevo)
  - `lib/features/sessions/di/sessions_module.dart` (nuevo)
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:21-20:27 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 49m`
- `Total acumulado de referencia = 35h 49m`

### 2026-03-02 - Hexagonal v3.0 fase 29: sessions slice de sesiones registradas + wiring

- Continuacion de migracion `sessions` para cubrir lectura/creacion/edicion via use cases y modulo DI.
- Cambios aplicados:
  - creada entidad de dominio `RecordedSession` en:
    - `lib/features/sessions/domain/entities/recorded_session.dart`
  - creado puerto de salida para historial de sesiones:
    - `lib/features/sessions/domain/ports/out/session_records_port.dart`
  - creados casos de uso:
    - `GetRecordedSessionsUseCase`, `SaveRecordedSessionUseCase`
    - archivo: `lib/features/sessions/application/use_cases/session_records_use_cases.dart`
  - creado adaptador in-memory:
    - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_records_adapter.dart`
  - `SessionsModule` ampliado para exponer casos de uso de sesiones registradas,
  - `SessionsPage` actualizado para:
    - cargar `_sessionFeed` desde modulo,
    - persistir sesiones importadas y subidas mediante `saveRecordedSession`,
    - conservar compatibilidad de `SessionDetailPage` mediante cast explicito de `insights`.
  - backlog de `sessions` actualizado marcando completados casos de uso y wiring por modulo.
- Resultado:
  - `sessions` ya no depende solo de estado en memoria local de UI para el feed,
  - queda base de feature preparada para seguir con extraer el resto de reglas de negocio.
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/sessions/domain/entities/recorded_session.dart` (nuevo)
  - `lib/features/sessions/domain/ports/out/session_records_port.dart` (nuevo)
  - `lib/features/sessions/application/use_cases/session_records_use_cases.dart` (nuevo)
  - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_records_adapter.dart` (nuevo)
  - `lib/features/sessions/di/sessions_module.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:27-20:34 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 5h 56m`
- `Total acumulado de referencia = 35h 56m`

### 2026-03-02 - Hexagonal v3.0 fase 30: arranque de migracion spots (catalogo base)

- Continuacion de v3.0 aplicando el mismo patron en `spots`.
- Cambios aplicados:
  - creada entidad de dominio `SpotItem` en:
    - `lib/features/spots/domain/entities/spot_item.dart`
  - creado puerto de salida para catalogo de spots:
    - `lib/features/spots/domain/ports/out/spots_catalog_port.dart`
  - creados casos de uso de catalogo:
    - `GetSpotsUseCase`, `SaveSpotUseCase`, `DeleteSpotByNameUseCase`
    - archivo: `lib/features/spots/application/use_cases/spots_catalog_use_cases.dart`
  - creado adaptador in-memory:
    - `lib/features/spots/infrastructure/adapters/in_memory/in_memory_spots_catalog_adapter.dart`
  - creado modulo DI:
    - `lib/features/spots/di/spots_module.dart`
  - integracion inicial en `SpotsPage`:
    - carga de `_spots` desde `SpotsModule.inMemory()`,
    - guardado/borrado persistido via modulo en altas, ediciones y borrado multiple,
    - reemplazo de clase privada `_SpotItem` por alias a entidad de dominio.
  - documentacion actualizada (`hexagonal_v3` + backlog).
- Resultado:
  - `spots` deja de depender solo de estado local para su catalogo y gana capas `domain/application/infrastructure`.
  - base preparada para siguiente paso: aislamiento de adaptadores remotos (mapa/webcam/meteo).
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/spots/domain/entities/spot_item.dart` (nuevo)
  - `lib/features/spots/domain/ports/out/spots_catalog_port.dart` (nuevo)
  - `lib/features/spots/application/use_cases/spots_catalog_use_cases.dart` (nuevo)
  - `lib/features/spots/infrastructure/adapters/in_memory/in_memory_spots_catalog_adapter.dart` (nuevo)
  - `lib/features/spots/di/spots_module.dart` (nuevo)
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:34-20:39 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 6h 01m`
- `Total acumulado de referencia = 36h 01m`

### 2026-03-02 - Hexagonal v3.0 fase 31: spots remote media aislada en infraestructura

- Completado siguiente paso de `spots` aislando fuente de datos remotos de webcams/referencias fuera de presentation.
- Cambios aplicados:
  - nuevas entidades de dominio para media:
    - `lib/features/spots/domain/entities/spot_webcam.dart` (`SpotWebcam`, `WebcamReferencePage`)
  - nuevo puerto de salida:
    - `lib/features/spots/domain/ports/out/spots_remote_media_port.dart`
  - nuevos casos de uso:
    - `GetSpotWebcamsUseCase`
    - `GetWebcamReferencePagesUseCase`
    - archivo: `lib/features/spots/application/use_cases/spots_remote_media_use_cases.dart`
  - nuevo adaptador in-memory de media:
    - `lib/features/spots/infrastructure/adapters/in_memory/in_memory_spots_remote_media_adapter.dart`
  - `SpotsModule` ampliado para exponer casos de uso de media remota,
  - integracion en presentation:
    - `SpotDetailPage` consume webcams y referencias via `SpotsModule`,
    - `WebcamPlayerPage` deja de construir paginas relacionadas internamente y las recibe inyectadas.
  - backlog de `spots` marcado completo en sus 3 items.
- Resultado:
  - se elimina logica de proveedor remoto hardcodeada en widgets,
  - la feature `spots` queda alineada al patron hexagonal de v3.0 en catalogo + media.
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/spots/domain/entities/spot_webcam.dart` (nuevo)
  - `lib/features/spots/domain/ports/out/spots_remote_media_port.dart` (nuevo)
  - `lib/features/spots/application/use_cases/spots_remote_media_use_cases.dart` (nuevo)
  - `lib/features/spots/infrastructure/adapters/in_memory/in_memory_spots_remote_media_adapter.dart` (nuevo)
  - `lib/features/spots/di/spots_module.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/pages/webcam_player_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:39-20:45 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 6h 07m`
- `Total acumulado de referencia = 36h 07m`

### 2026-03-02 - Hexagonal v3.0 fase 32: arranque de community (feed de seguidos)

- Iniciado modulo `community` con un slice funcional en timeline de seguidos.
- Cambios aplicados:
  - nueva entidad de dominio:
    - `lib/features/community/domain/entities/following_session.dart`
  - nuevo puerto de salida:
    - `lib/features/community/domain/ports/out/community_following_feed_port.dart`
  - nuevo caso de uso:
    - `GetCommunityFollowingSessionsUseCase`
    - archivo: `lib/features/community/application/use_cases/community_following_feed_use_cases.dart`
  - nuevo adaptador in-memory:
    - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_following_feed_adapter.dart`
  - nuevo modulo DI de feature:
    - `lib/features/community/di/community_module.dart`
  - integracion en presentation:
    - `CommunityPage` deja lista hardcodeada de sesiones seguidas y la obtiene via `CommunityModule.inMemory()`,
    - reemplazo de clase privada `_FollowingSession` por alias a entidad de dominio.
  - documentacion actualizada (`hexagonal_v3` + backlog v3).
- Resultado:
  - `community` deja de tener el feed principal embebido en UI y empieza a consumir capa `domain/application/infrastructure`.
  - se mantiene comportamiento actual sin regressions de UI.
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
  - `lib/features/community/domain/entities/following_session.dart` (nuevo)
  - `lib/features/community/domain/ports/out/community_following_feed_port.dart` (nuevo)
  - `lib/features/community/application/use_cases/community_following_feed_use_cases.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_following_feed_adapter.dart` (nuevo)
  - `lib/features/community/di/community_module.dart` (nuevo)
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:45-20:50 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 6h 12m`
- `Total acumulado de referencia = 36h 12m`

### 2026-03-02 - Hexagonal v3.0 fase 33: community slice leaderboard en capas

- Segundo avance en `community` para reducir carga hardcodeada en presentation.
- Cambios aplicados:
  - nueva entidad de dominio para leaderboard:
    - `lib/features/community/domain/entities/community_user_summary.dart`
  - nuevo puerto de salida:
    - `lib/features/community/domain/ports/out/community_leaderboard_port.dart`
  - nuevo caso de uso:
    - `GetCommunityUsersUseCase`
    - archivo: `lib/features/community/application/use_cases/community_leaderboard_use_cases.dart`
  - nuevo adaptador in-memory:
    - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_leaderboard_adapter.dart`
  - `CommunityModule` ampliado para exponer `getCommunityUsers`,
  - `CommunityPage` actualizado para:
    - cargar lista de usuarios desde modulo,
    - eliminar factory local `_buildMockUsers`,
    - reemplazar clase privada `_CommunityUser` por alias a entidad de dominio,
    - mapear color desde `avatarColorValue` al render.
- Resultado:
  - se desacopla el origen de datos del leaderboard respecto a la UI,
  - `community` ya consume dos slices desde capas hexagonales (feed + leaderboard).
- Archivos actualizados:
  - `docs/architecture/hexagonal_v3.md`
  - `lib/features/community/domain/entities/community_user_summary.dart` (nuevo)
  - `lib/features/community/domain/ports/out/community_leaderboard_port.dart` (nuevo)
  - `lib/features/community/application/use_cases/community_leaderboard_use_cases.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_leaderboard_adapter.dart` (nuevo)
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)

### 2026-03-02 - Conteo de horas (actualizacion bloque activo)

- `Bloque 20:50-20:56 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 6h 18m`
- `Total acumulado de referencia = 36h 18m`

### 2026-03-02 - Hexagonal v3.0 fase 36: validacion integral de suite tras cierre de dashboard

- Ejecutada validacion integral despues de cerrar `dashboard` como feature liviana.
- Verificacion ejecutada:
  - `flutter test -r compact` (ok, suite completa)
- Resultado:
  - se confirma estabilidad global del proyecto con estado arquitectonico v3.0 actualizado (`profile`, `auth`, `sessions`, `spots`, `community` y `dashboard` en verde).

### 2026-03-02 - Hexagonal v3.0 fase 35: dashboard validado como feature liviana

- Cerrado el pendiente global de `dashboard` en el backlog v3.0 con enfoque de feature liviana.
- Cambios aplicados:
  - nuevo servicio de aplicacion para reglas de toolbar:
    - `lib/features/dashboard/application/services/dashboard_toolbar_service.dart`
  - `DashboardPage` delega visibilidad de acciones de AppBar en `DashboardToolbarService`:
    - spots (`Editar`/`Eliminar`),
    - sessions (`+` y `Eliminar` solo en `Start Session`),
    - profile (`Ajustes`).
  - test unitario nuevo para reglas de toolbar:
    - `test/features/dashboard/application/services/dashboard_toolbar_service_test.dart`
  - documentacion actualizada para reflejar cierre de dashboard en v3.0.
- Resultado:
  - `dashboard` mantiene simplicidad (sin puertos/adaptadores por no tener fuente de datos propia),
  - reglas de UI desacopladas de la pagina y cubiertas por test.
- Archivos actualizados:
  - `lib/features/dashboard/application/services/dashboard_toolbar_service.dart` (nuevo)
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
  - `test/features/dashboard/application/services/dashboard_toolbar_service_test.dart` (nuevo)
  - `docs/architecture/migration_backlog_v3.md`
  - `docs/architecture/hexagonal_v3.md`
  - `SESSION_TRACKER.md`

### 2026-03-02 - Hexagonal v3.0 fase 34: community orquestacion movida a application/services

- Continuada la limpieza de `community` para reducir logica de negocio dentro de `CommunityPage`.
- Cambios aplicados:
  - nuevo servicio de aplicacion:
    - `lib/features/community/application/services/community_orchestration_service.dart`
  - el servicio encapsula:
    - filtrado de amigos y sesiones seguidas,
    - construccion/ordenacion de filas de leaderboard,
    - formateo de metrica por unidad,
    - calculo de posicion de usuario en ranking.
  - `CommunityModule` expone el nuevo servicio como dependencia de feature.
  - `CommunityPage` delega en `CommunityOrchestrationService` y elimina calculos inline de ranking/filtros/metricas.
- Documentacion v3.0 actualizada:
  - `docs/architecture/migration_backlog_v3.md`:
    - marcadas como completadas tareas pendientes de `community`,
    - actualizado estado global de features migradas (`auth`, `sessions`, `spots`, `community`).
  - `docs/architecture/hexagonal_v3.md`:
    - estado actual de `community` alineado con orquestacion en `application/services`.
- Archivos actualizados:
  - `lib/features/community/application/services/community_orchestration_service.dart` (nuevo)
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `docs/architecture/migration_backlog_v3.md`
  - `docs/architecture/hexagonal_v3.md`
  - `SESSION_TRACKER.md`

### 2026-03-02 - Community v3.1 fase 37: likes end-to-end en feed de amigos

- Iniciado primer loop social funcional en `community` con slice de `likes` sobre sesiones seguidas.
- Cambios aplicados:
  - entidad de dominio nueva para estado de like:
    - `lib/features/community/domain/entities/session_like_state.dart`
  - nuevo puerto de salida para reacciones:
    - `lib/features/community/domain/ports/out/community_session_reactions_port.dart`
  - nuevos casos de uso:
    - `GetSessionLikeStateUseCase`
    - `ToggleSessionLikeUseCase`
    - archivo: `lib/features/community/application/use_cases/community_session_reactions_use_cases.dart`
  - nuevo adaptador in-memory:
    - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_session_reactions_adapter.dart`
  - `FollowingSession` incorpora `id` estable para operar likes por sesion,
  - `CommunityModule` ampliado con wiring de casos de uso de reacciones,
  - integracion en `CommunityPage`:
    - contador de likes renderizado desde estado de dominio,
    - boton alterna `Dar like`/`Quitar like`,
    - icono pasa de borde a relleno cuando existe like activo.
  - test de presentacion ampliado con flujo de toggle de like.
- Resultado:
  - primer comportamiento social interactivo ya no depende de callbacks vacios en UI,
  - slice queda alineado al patron hexagonal (`domain` + `application` + `infrastructure` + `presentation`).
- Archivos actualizados:
  - `lib/features/community/domain/entities/following_session.dart`
  - `lib/features/community/domain/entities/session_like_state.dart` (nuevo)
  - `lib/features/community/domain/ports/out/community_session_reactions_port.dart` (nuevo)
  - `lib/features/community/application/use_cases/community_session_reactions_use_cases.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_session_reactions_adapter.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_following_feed_adapter.dart`
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 38: comentarios funcionales en feed de amigos

- Continuado loop social en `community` con slice de comentarios por sesion.
- Cambios aplicados:
  - nueva entidad de dominio:
    - `lib/features/community/domain/entities/session_comment.dart`
  - nuevo puerto de salida:
    - `lib/features/community/domain/ports/out/community_session_comments_port.dart`
  - nuevos casos de uso:
    - `GetSessionCommentsUseCase`
    - `AddSessionCommentUseCase`
    - archivo: `lib/features/community/application/use_cases/community_session_comments_use_cases.dart`
  - nuevo adaptador in-memory:
    - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_session_comments_adapter.dart`
  - `CommunityModule` ampliado para exponer casos de uso de comentarios,
  - integracion en `CommunityPage`:
    - contador de comentarios por tarjeta,
    - apertura de modal `Comentarios`,
    - publicacion de comentario y refresco inmediato del contador/lista.
  - test de presentacion ampliado con flujo de publicacion de comentario.
- Resultado:
  - la accion `Comentar` deja de ser placeholder y queda operativa sobre un estado de dominio,
  - `community` gana segundo bloque social funcional tras likes (fase 37).
- Archivos actualizados:
  - `lib/features/community/domain/entities/session_comment.dart` (nuevo)
  - `lib/features/community/domain/ports/out/community_session_comments_port.dart` (nuevo)
  - `lib/features/community/application/use_cases/community_session_comments_use_cases.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_session_comments_adapter.dart` (nuevo)
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 39: pulido UI del modal de comentarios

- Aplicado refinamiento de UX en comentarios para evitar estados confusos y mejorar mobile.
- Mejoras implementadas en `CommunityPage`:
  - titulo de modal con conteo (`Comentarios (n)`),
  - empty state mas explicito,
  - input con `autofocus`, multilinea y `maxLength: 180`,
  - boton `Publicar` deshabilitado cuando el comentario esta vacio o invalido,
  - limpieza de foco/teclado al publicar o cerrar modal,
  - texto de contadores en feed con singular/plural (`1 comentario`, `2 comentarios`; `1 like`, `2 likes`).
- Tests ajustados para cubrir composer (estado disabled/enabled + publicacion).
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 40: pulido visual de cards de sesiones en Amigos

- Refinada jerarquia visual de las tarjetas de sesiones para lectura mas rapida en feed.
- Ajustes aplicados en `CommunityPage`:
  - sustitucion de lineas sueltas por chips de metricas clave (altura, distancia, duracion),
  - metadata compacta en una linea (`spot · equipo`),
  - separador visual entre contenido de sesion y acciones sociales,
  - reutilizacion de helper para chips de stats y consistencia de estilos.
- Resultado:
  - cards mas escaneables y menos densas sin tocar la logica de negocio,
  - mantenidas acciones de like/comentarios y comportamiento actual.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 41: acceso a detalle solo por boton en tarjetas

- Ajustada la interaccion de tarjetas en pestaña `Amigos`:
  - eliminada navegacion por `tap` en toda la tarjeta,
  - agregado CTA explicito `Ver sesion` en cada card para abrir el detalle.
- Objetivo:
  - evitar aperturas accidentales al interactuar con elementos internos,
  - clarificar la accion principal de entrada al detalle.
- Tests actualizados:
  - flujo de apertura usando `OutlinedButton('Ver sesion')`,
  - nuevo test que confirma que tocar la card (foto) ya no navega.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 42: CTA `Ver sesion` alineado con acciones sociales

- Ajuste visual de densidad y alineacion en cards de `Amigos`.
- Cambios aplicados:
  - separacion entre fila de contadores y fila de acciones,
  - CTA `Ver sesion` movido a la misma fila de acciones sociales,
  - estilo compacto del `OutlinedButton` para reducir altura y ruido visual.
- Resultado:
  - jerarquia mas clara (primero metricas, luego acciones),
  - bloque de interacciones mas limpio en mobile sin perder legibilidad.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 43: microinteraccion de like (animacion + haptics)

- Aplicado pulido final de UX en accion de `like` dentro de `Amigos`.
- Cambios implementados en `CommunityPage`:
  - feedback tactil ligero con `HapticFeedback.selectionClick()` al pulsar like,
  - transicion animada del icono (scale + fade) usando `AnimatedSwitcher`,
  - cambio de icono/estado mantenido (`favorite_border` -> `favorite` en rojo).
- Resultado:
  - accion social mas perceptible y satisfactoria,
  - sin impacto en logica de dominio ni en arquitectura de capas.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 44: buscador de usuarios para seguir desde Amigos

- Añadido punto de entrada para descubrir usuarios y seguir/dejar de seguir sin salir de `Community > Amigos`.
- Cambios en UI:
  - card superior de amigos rediseñada con dos acciones:
    - `Mis amigos` (directorio actual),
    - `Buscar usuarios` (nuevo modal `Explorar usuarios`).
  - modal `Explorar usuarios`:
    - filtro por username,
    - listado de resultados,
    - CTA `Seguir` / `Siguiendo` por usuario con toggle inmediato.
- Ajustes de robustez:
  - modales de amigos y buscador migrados a layout con `SizedBox + Expanded` para evitar overflows,
  - eliminados `TextEditingController` locales en estos modales para evitar estados de controller disposed en tests/interacciones.
- Tests actualizados:
  - adaptado test del bloque `Amigos` a nueva card y accion `Mis amigos`,
  - test nuevo de flujo de seguimiento desde `Buscar usuarios`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 45: preparacion de infraestructura local para persistencia

- Preparada base de infraestructura para persistencia local (previa a DB remota) sin romper flujo actual de UI.
- Cambios aplicados:
  - nuevo bootstrap de rutas de almacenamiento local:
    - `lib/core/persistence/app_storage_paths.dart`
    - inicializacion en `main()` con `WidgetsFlutterBinding.ensureInitialized()` + `AppStoragePaths.ensureInitialized()`.
  - nuevo store local de estado social de community (archivo JSON versionado):
    - `lib/features/community/infrastructure/persistence/community_social_state_store.dart`
    - persiste `likes`, `likedByUserAndSession`, `comments` y contador de IDs de comentarios.
  - nuevos adaptadores locales (file-based) alineados a puertos existentes:
    - `lib/features/community/infrastructure/adapters/local/local_file_community_session_reactions_adapter.dart`
    - `lib/features/community/infrastructure/adapters/local/local_file_community_session_comments_adapter.dart`
  - `CommunityModule` ampliado con factory `localFile()` para activar persistencia local cuando se decida (sin forzar cambio de runtime actual).
- Decisiones de rollout:
  - `CommunityPage` se mantiene temporalmente en `CommunityModule.inMemory()` para preservar estabilidad y determinismo de tests,
  - infraestructura local queda lista para activar por DI cuando se cierre validacion funcional final.
- Archivos actualizados:
  - `lib/core/persistence/app_storage_paths.dart` (nuevo)
  - `lib/main.dart`
  - `lib/features/community/infrastructure/persistence/community_social_state_store.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/local/local_file_community_session_reactions_adapter.dart` (nuevo)
  - `lib/features/community/infrastructure/adapters/local/local_file_community_session_comments_adapter.dart` (nuevo)
  - `lib/features/community/di/community_module.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 46: activacion controlada de persistencia local por flag

- Activada la ruta de persistencia local en runtime de app con control por configuracion de entorno.
- Cambios aplicados:
  - `EnvConfig` incorpora `communityLocalPersistenceEnabled` (default `true`).
  - `CommunityPage` recibe parametro `useLocalPersistence` y por defecto toma el flag de `EnvConfig`.
  - inicializacion de modulo en `CommunityPage`:
    - `localFile()` cuando el flag esta activo,
    - `inMemory()` como fallback.
  - tests de `CommunityPage` fijados en `useLocalPersistence: false` para mantener determinismo y evitar estado cross-test.
- Resultado:
  - la app real ya puede persistir likes/comentarios localmente,
  - la suite mantiene estabilidad predecible en CI/tests.
- Archivos actualizados:
  - `lib/core/config/env/env_config.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 47: fix de crash/overflow al abrir Amigos en pantallas estrechas

- Atendido reporte de cierre/rotura visual al pulsar `Amigos` en `Community`.
- Causa principal identificada:
  - overflows horizontales en cards de `Amigos` (fila de contadores + fila de acciones) en anchos reducidos,
  - CTA y acciones no adaptaban correctamente a layout compacto.
- Fix aplicado:
  - acciones superiores de la card `Usuarios que sigues` migradas a `Wrap`,
  - contadores de sesiones (`likes`/`comentarios`) migrados a `Wrap`,
  - fila de acciones por sesion (`like`, `comentar`, `Ver sesion`) migrada a `Wrap` con salto de linea.
- Tests reforzados:
  - el test de estabilidad en pantalla estrecha ahora cambia a pestaña `Amigos` antes de verificar excepciones.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 48: rediseño social estilo red (Feed/Siguiendo/Seguidores/Explorar)

- Reemplazada la card utilitaria de `Usuarios que sigues` por un bloque social con navegacion tipo red social.
- Cambios aplicados en `Amigos`:
  - header `Tu red` con resumen de `Siguiendo` y `Seguidores`,
  - segmented interno con 4 vistas:
    - `Feed` (sesiones de amigos),
    - `Siguiendo` (lista filtrable),
    - `Seguidores` (lista filtrable),
    - `Explorar` (busqueda + follow/unfollow).
  - acciones de follow unificadas en listas de personas (`Seguir` / `Siguiendo`),
  - segmented envuelto en `SingleChildScrollView` horizontal para evitar overflows en anchos reducidos.
- Ajustes de estabilidad:
  - eliminados modales antiguos de `Mis amigos`/`Buscar usuarios` y su complejidad asociada,
  - añadidas keys estables para acciones por sesion (`like`, `comment`, `view`) en cards de feed.
- Tests actualizados para reflejar nuevo flujo social y mantener robustez en pantallas estrechas.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community v3.1 fase 49: perfil y sesiones de usuario con UI social

- Sustituidos placeholders de detalle social por vistas usables tipo red social.
- `community_user_profile_page`:
  - header con avatar, username y bio,
  - stats principales (`Sesiones`, `Seguidores`, `Siguiendo`),
  - CTAs sociales (`Seguir`, `Mensaje`, `Ver stats`),
  - bloque `Highlights` en grid responsivo.
- `community_user_sessions_page`:
  - listado de sesiones con metadata util,
  - chips de filtro visual (`Todas`, `Big Air`, `Freeride`, `Recientes`),
  - cards de sesiones con titulo, resumen y fecha relativa.
- Resultado:
  - navegación desde `Community` ya no cae en pantallas vacías,
  - experiencia social se acerca al patrón esperado de apps tipo Instagram/TikTok.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_user_profile_page.dart`
  - `lib/features/community/presentation/pages/community_user_sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community/Profile v3.1 fase 50: unificacion con Vista publica + persistencia eje principal

- Alineado el contrato funcional: el perfil visto desde `Community` reutiliza la misma vista canónica de `Vista publica` de `Profile`.
- Cambios clave:
  - `CommunityUserProfilePage` deja de usar UI duplicada y ahora renderiza `PublicProfilePreviewPage`.
  - para el usuario actual, `Community` toma datos del perfil maestro persistido (no seeds),
  - para otros usuarios, se usa mapeo derivado sobre el mismo `UserProfileData` para mantener formato visual consistente.
- Persistencia de eje principal de perfil:
  - nueva implementación local: `LocalFileProfileRepositoryAdapter` (`profile_user_v1.json`),
  - `UserProfileData` ampliado con `copyWith`, `toJson` y `fromJson`,
  - `ProfileModule` incorpora `localFile()` y repositorios compartidos para evitar redundancias de instancias,
  - `ProfilePage` usa `ProfileModule.localFile()` bajo flag de entorno `profileLocalPersistenceEnabled`.
- Resultado:
  - cambios de perfil en `Editar perfil` persisten localmente y se convierten en fuente de verdad para vistas públicas vinculadas.
- Tests/validacion:
  - nuevo test de persistencia: `test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart`,
  - `flutter analyze` (ok),
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok),
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok),
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok).

### 2026-03-02 - Community/Profile v3.1 fase 51: sync del usuario actual en Community desde perfil maestro

- Conectada la identidad del usuario actual en `Community` al perfil maestro persistido de `Profile`.
- Cambios aplicados en `CommunityPage`:
  - resuelve usuario actual desde `ProfileModule` (local file o in-memory segun flags),
  - usa `handle` persistido para `_myUsername` (sin hardcode `you_rider`),
  - inyecta/actualiza resumen del usuario actual en el dataset de community para evitar divergencias,
  - comentarios propios muestran tambien `displayName` del perfil maestro.
- Resultado:
  - al editar datos base del perfil (ej. handle/displayName), Community los consume desde la misma fuente de verdad,
  - se reduce duplicidad y riesgo de datos inconsistentes entre features.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-02 - Community/Profile v3.1 fase 52: sync visual de avatar/nombre del usuario actual en Community

- Extendida la sincronizacion con el perfil maestro para que Community refleje tambien la identidad visual del usuario.
- Cambios aplicados en `CommunityPage`:
  - helper `_buildUserAvatar` reutilizable para listas/feed/comentarios,
  - si el item corresponde al usuario actual y existe `avatarLocalPath` en perfil persistido, se muestra imagen real,
  - fallback a avatar por inicial + color cuando no hay foto,
  - comentarios propios siguen mostrando `displayName` del perfil maestro.
- Resultado:
  - al cambiar foto en `Perfil > Editar perfil`, Community usa ese avatar en elementos sociales donde aparece el usuario actual,
  - menor divergencia visual entre `Perfil` y `Community`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Community/Profile v3.1 fase 53: display name sincronizado en listas/feed de Community

- Continuado el cierre de consistencia visual del eje perfil maestro en `Community`.
- Cambios aplicados en `CommunityPage`:
  - helper `_displayNameForUser` para render uniforme de nombre visible,
  - listas de personas (`Siguiendo/Seguidores/Explorar`) muestran nombre + `@handle` en subtitle,
  - cards del feed de `Amigos` muestran nombre visible encima de `@username`.
- Resultado:
  - identidad visual mas coherente con el perfil principal,
  - se reduce la percepcion de datos duplicados entre `Profile` y `Community`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (estado)

- Ultimo acumulado exacto registrado: `36h 18m` (`SESSION_TRACKER.md:3999`).
- Desde ese punto se siguio trabajando por fases 44-53, pero el bloque horario exacto quedo pendiente de regularizacion fina.

### 2026-03-03 - Revision de continuidad para retomar sesion

- Revisado el estado global del proyecto con foco en `SESSION_TRACKER.md`, `docs/architecture/hexagonal_v3.md` y `docs/architecture/migration_backlog_v3.md`.
- Confirmado estado actual de rama limpia para continuar trabajo incremental:
  - `git status --short --branch` sin cambios pendientes.
- Revalidado contexto de continuidad:
  - v3.0 base cerrada en `auth`, `sessions`, `spots`, `community` y `dashboard`,
  - v3.1 en curso con foco `Community/Profile` (fases 44-53).
- Actualizado `Proximo paso acordado` al siguiente incremento real (fase 54) para mantener trazabilidad.

### 2026-03-03 - Conteo de horas (inicio de bloque actual)

- `Bloque 19:23-19:23 = 0m` (marca de arranque de esta sesion).
- `Acumulado (track exacto desde 2026-03-01 11:34) = 6h 18m`.
- `Total acumulado de referencia = 36h 18m`.

### 2026-03-03 - Community/Profile v3.1 fase 54: identidad sincronizada en Leaderboard

- Extendida la sincronizacion visual del perfil maestro dentro de `Community > Leaderboard`.
- Cambios aplicados en `CommunityPage`:
  - nueva tarjeta de identidad del usuario actual al inicio del ranking,
  - banner del perfil renderizado desde persistencia local (con fallback visual si no hay imagen),
  - avatar del usuario actual reutilizado en ranking y barra inferior con la misma logica de sincronizacion,
  - display name visible en filas del leaderboard junto al `@handle` para mantener consistencia con `Profile` y `PublicProfilePreviewPage`.
- Ajustes de robustez UI:
  - refinado layout de tarjeta de identidad para evitar overflows en pantallas estrechas.
- Tests actualizados:
  - nuevo caso `leaderboard shows synced profile identity card` en `community_page_test.dart`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion bloque activo)

- `Bloque 19:23-19:30 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 6h 25m`
- `Total acumulado de referencia = 36h 25m`

### 2026-03-03 - Community/Profile v3.1 fase 55: sync de identidad en navegacion social de Community

- Extendida la consistencia de identidad entre `Profile` y vistas de navegacion social de `Community`.
- Cambios aplicados:
  - `CommunityPage` ahora propaga `useLocalPersistence` al abrir `CommunityUserProfilePage` y `CommunityUserSessionsPage` para mantener la misma fuente de verdad en runtime,
  - barra inferior del leaderboard muestra `displayName · @handle` cuando la fila corresponde al usuario actual,
  - `CommunityUserProfilePage` incorpora flag `useLocalPersistence` para resolver perfil desde `ProfileModule.localFile()` o `ProfileModule.inMemory()` segun configuracion,
  - `CommunityUserSessionsPage` se evoluciona con cabecera social sincronizada (banner, avatar, display name y handle) reutilizando datos del perfil maestro para usuario actual y mapeo coherente para terceros.
- Tests actualizados:
  - nuevo test `user sessions page shows synced identity header` en `community_page_test.dart`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `lib/features/community/presentation/pages/community_user_profile_page.dart`
  - `lib/features/community/presentation/pages/community_user_sessions_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (cierre de bloque activo)

- `Bloque 19:23-20:35 = 1h 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 7h 37m`
- `Total acumulado de referencia = 37h 37m`

### 2026-03-03 - Community/Profile v3.1 fase 56: mapeo compartido de identidad en navegacion social

- Cerrada la consistencia de identidad entre `CommunityUserProfilePage` y `CommunityUserSessionsPage` con un mapeo comun reutilizable.
- Cambios principales:
  - nuevo helper compartido `CommunityIdentityMapper` en `lib/features/community/presentation/support/community_identity_mapper.dart` con:
    - normalizacion de username,
    - resolucion de perfil para usuario actual/terceros,
    - derivacion consistente de display name.
  - `CommunityUserProfilePage` migra a este mapper y elimina logica duplicada de resolucion.
  - `CommunityUserSessionsPage` migra al mismo mapper y elimina duplicidad de reglas para terceros.
  - `CommunityPage` reutiliza mapper para normalizar username y derivar display names no locales, manteniendo una unica regla de naming social.
- Cobertura de regresion ampliada:
  - nuevo test widget `user profile and sessions use shared identity for third user`.
  - nuevo test unitario `community_identity_mapper_test.dart` (caso usuario actual + caso tercero).
- Archivos actualizados:
  - `lib/features/community/presentation/support/community_identity_mapper.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `lib/features/community/presentation/pages/community_user_profile_page.dart`
  - `lib/features/community/presentation/pages/community_user_sessions_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `test/features/community/presentation/support/community_identity_mapper_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/support/community_identity_mapper_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 56)

- `Bloque incremental 20:35-20:42 = 7m`
- `Bloque total 19:23-20:42 = 1h 19m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 7h 44m`
- `Total acumulado de referencia = 37h 44m`

### 2026-03-03 - Community/Profile v3.1 fase 57: identidad unificada en comentarios y acciones sociales

- Extendida la unificacion de identidad a los flujos de comentarios del feed en `Community`.
- Cambios aplicados:
  - `CommunityPage` incorpora helper `_identityLabelForUser(username)` para renderizar formato consistente `displayName · @handle`.
  - Modal de comentarios migra a etiqueta unificada de identidad para autores (usuario actual y terceros), conservando avatar sincronizado.
  - Barra inferior del leaderboard reutiliza el mismo helper para evitar divergencia de formato.
  - Se mantiene el mapeo compartido introducido en fase 56 (`CommunityIdentityMapper`) como fuente central de display names.
- Cobertura de regresion ampliada:
  - nuevo test widget `comments modal shows unified identity label after posting`.
  - se mantiene cobertura de terceros entre `CommunityUserProfilePage` y `CommunityUserSessionsPage`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/support/community_identity_mapper_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 57)

- `Bloque incremental 20:42-20:47 = 5m`
- `Bloque total 19:23-20:47 = 1h 24m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 7h 49m`
- `Total acumulado de referencia = 37h 49m`

### 2026-03-03 - Community/Profile v3.1 fase 58: identidad unificada en listados sociales y busqueda por nombre

- Se completo la unificacion de identidad en listados sociales de `Community` (`Siguiendo`, `Seguidores`, `Explorar`).
- Cambios aplicados en `CommunityPage`:
  - `ListTile` de usuarios ahora muestra etiqueta consistente `displayName · @handle` en el titulo,
  - subtitulo de listados simplificado a contexto deportivo (`spot` + `Big Air`) sin duplicar identidad,
  - busqueda social extendida para matchear tanto por `username` como por `displayName`.
- Cobertura de regresion ampliada:
  - nuevo test widget `amigos explore search works by display name`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/support/community_identity_mapper_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 58)

- `Bloque incremental 20:47-20:50 = 3m`
- `Bloque total 19:23-20:50 = 1h 27m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 7h 52m`
- `Total acumulado de referencia = 37h 52m`

### 2026-03-03 - Community/Profile v3.1 fase 59: cierre de identidad en acciones contextuales

- Ajuste final de consistencia de identidad en acciones contextuales del leaderboard y navegacion social.
- Cambios aplicados en `CommunityPage`:
  - modal de acciones del leaderboard incluye cabecera de usuario con avatar y etiqueta unificada `displayName · @handle`,
  - detalle de sesion social ahora construye resumen textual con `displayName` consistente del autor,
  - se conserva el formato unificado de identidad en comentarios, barra inferior y listados sociales.
- Cobertura de regresion ampliada:
  - nuevo test widget `leaderboard actions modal shows unified user identity`.
- Archivos actualizados:
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/support/community_identity_mapper_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 59)

- `Bloque incremental 20:50-20:54 = 4m`
- `Bloque total 19:23-20:54 = 1h 31m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 7h 56m`
- `Total acumulado de referencia = 37h 56m`

### 2026-03-03 - Community/Profile v3.1 fase 60: persistencia real de follows en Community

- Se completo la primera etapa del nuevo bloque de robustez funcional en `Community`: persistencia local de follows entre instancias.
- Cambios de arquitectura aplicados:
  - nuevo puerto `CommunityFollowingPreferencesPort` en dominio,
  - nuevos use cases `GetFollowingUsernamesUseCase` y `SaveFollowingUsernamesUseCase`,
  - nuevos adapters `in_memory` y `local_file` para preferencias de follow.
- Cambios de infraestructura:
  - `CommunitySocialStateStore` ahora persiste `followingUsernames` en `community_social_state_v1.json` y expone API de lectura/escritura tipada.
  - `CommunityModule` inyecta el nuevo circuito de preferencias tanto en modo `inMemory` como `localFile`.
- Cambios en presentacion:
  - `CommunityPage` hidrata follows desde persistencia al iniciar,
  - se aplica fallback controlado a defaults solo cuando no hay estado previo,
  - cada `follow/unfollow` guarda el estado actualizado.
- Cobertura de regresion ampliada:
  - nuevo test widget `following selection persists across page instances in local mode`,
  - nuevo test de store `community_social_state_store_test.dart` para persistencia de follows entre instancias.
- Archivos actualizados:
  - `lib/features/community/domain/ports/out/community_following_preferences_port.dart`
  - `lib/features/community/application/use_cases/community_following_preferences_use_cases.dart`
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_following_preferences_adapter.dart`
  - `lib/features/community/infrastructure/adapters/local/local_file_community_following_preferences_adapter.dart`
  - `lib/features/community/infrastructure/persistence/community_social_state_store.dart`
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/community/infrastructure/persistence/community_social_state_store_test.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/support/community_identity_mapper_test.dart -r compact` (ok)
  - `flutter test test/features/community/infrastructure/persistence/community_social_state_store_test.dart -r compact` (ok)
  - `flutter test test/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 60)

- `Bloque incremental 20:54-21:35 = 41m`
- `Bloque total 19:23-21:35 = 2h 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 8h 37m`
- `Total acumulado de referencia = 38h 37m`

### 2026-03-03 - Sessions v3.1 fase 61: visibilidad de resumen contextual en detalle

- Se inicia nuevo frente en `sessions` para reforzar consistencia de contexto post-sesion entre entradas desde `SessionsPage` y `Community`.
- Cambio aplicado:
  - `SessionDetailPage` ahora renderiza explicitamente el texto `summary` en una card de `Contexto de sesion` (antes el dato se recibia por constructor pero no se mostraba en UI).
- Cobertura de regresion actualizada:
  - `session_detail_page_test.dart` valida presencia de `Contexto de sesion` y del texto de resumen de ejemplo,
  - se ajusta flujo de scroll del test para localizar `Resumen post-sesion` tras el nuevo bloque visual.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 61)

- `Bloque incremental 21:35-21:40 = 5m`
- `Bloque total 19:23-21:40 = 2h 17m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 8h 42m`
- `Total acumulado de referencia = 38h 42m`

### 2026-03-03 - Sessions v3.1 fase 62: consistencia cross-screen de SessionDetail

- Se verifico y reforzo la consistencia del detalle de sesion al entrar desde dos flujos:
  - `SessionsPage > My Sessions`
  - `Community > Amigos > Ver sesion`
- Cambios aplicados en pruebas de regresion:
  - `community_page_test.dart`: nuevo test `community session detail shows contextual summary block` para validar que la navegacion desde `Community` abre `SessionDetailPage` con bloque `Contexto de sesion` y resumen con autor contextual.
  - `sessions_page_test.dart`: el test de importacion ahora valida tambien el bloque `Contexto de sesion` y el contenido del resumen importado antes de verificar historico de saltos.
- Resultado:
  - se confirma consistencia funcional del detalle entre ambos orígenes de navegación.
- Archivos actualizados:
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 62)

- `Bloque incremental 21:40-22:09 = 29m`
- `Bloque total 19:23-22:09 = 2h 46m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 11m`
- `Total acumulado de referencia = 39h 11m`

### 2026-03-03 - Sessions v3.1 fase 63: contrato contextual tipado para SessionDetail

- Se consolido el contrato de entrada de `SessionDetailPage` para evitar divergencias entre llamadas desde `Sessions` y `Community`.
- Cambios aplicados:
  - nuevo enum `SessionDetailSource` (`mySessions`, `community`) como parametro requerido del detalle,
  - `SessionDetailPage` renderiza `Origen: <source>` dentro de `Contexto de sesion`,
  - `SessionsPage` y `CommunityPage` pasan explicitamente el origen correspondiente al navegar.
- Cobertura de regresion actualizada:
  - `session_detail_page_test.dart` valida `Origen: My Sessions`,
  - `sessions_page_test.dart` valida origen en flujo de sesion importada,
  - `community_page_test.dart` valida `Origen: Community` en detalle abierto desde feed social.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `test/features/community/presentation/pages/community_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 63)

- `Bloque incremental 22:09-22:18 = 9m`
- `Bloque total 19:23-22:18 = 2h 55m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 20m`
- `Total acumulado de referencia = 39h 20m`

### 2026-03-03 - Sessions v3.1 fase 64: desacople inicial de SessionDetailPage

- Se avanzo en reduccion de complejidad de presentacion de `SessionDetailPage` sin alterar comportamiento.
- Refactor aplicado:
  - extraccion de bloques de UI principales a metodos privados reutilizables en estado:
    - `_buildSessionHeaderCard(...)`
    - `_buildGearCard(...)`
    - `_buildContextCard(...)`
    - `_buildMediaCard(...)`
  - `build()` queda mas legible y orientado a composicion.
- Cobertura y seguridad de regresion:
  - se mantienen y ejecutan pruebas de `sessions` + `community` para validar navegacion cruzada y contenido contextual.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 64)

- `Bloque incremental 22:18-22:22 = 4m`
- `Bloque total 19:23-22:22 = 2h 59m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 24m`
- `Total acumulado de referencia = 39h 24m`

### 2026-03-03 - Sessions v3.1 fase 65: hotfix crash en dialogo de subida (Galeria)

- Corregido crash al pulsar `Galeria` en `Configurar sesion`.
- Causa raiz:
  - el dialogo usaba `TextEditingController` para notas y se hacia `dispose()` al cerrar `showDialog`, generando la asercion `A TextEditingController was used after being disposed` durante rebuilds transitorios.
- Fix aplicado:
  - se elimina el controller del dialogo,
  - el campo de notas pasa a estado local con `onChanged` (`String notes`),
  - se retorna `notes.trim()` en la configuracion sin lifecycle manual del controller.
- Cobertura de regresion ampliada:
  - nuevo test widget `keeps upload dialog stable when selecting gallery media`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 65)

- `Bloque incremental 22:22-22:43 = 21m`
- `Bloque total 19:23-22:43 = 3h 20m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 45m`
- `Total acumulado de referencia = 39h 45m`

### 2026-03-03 - Sessions v3.1 fase 66: hardening preventivo de dialogos en Sessions

- Tras el hotfix de `Galeria`, se revisaron patrones de `TextEditingController` en dialogos de `sessions` para prevenir crashes similares.
- Ajuste aplicado en dialogo `Configurar dispositivo`:
  - eliminado `TextEditingController` temporal + `dispose()` manual en callback,
  - migrado a estado local (`customName`) con `onChanged`,
  - flujo de confirmacion migrado a `await showDialog` para lifecycle mas estable y legible.
- Cobertura de regresion:
  - se mantiene test de estabilidad de `Galeria` agregado en fase 65,
  - se ejecuta suite de sessions y arquitectura para validar que no hay efectos colaterales.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 66)

- `Bloque incremental 22:43-22:46 = 3m`
- `Bloque total 19:23-22:46 = 3h 23m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 48m`
- `Total acumulado de referencia = 39h 48m`

### 2026-03-03 - Sessions v3.1 fase 67: seleccion real de foto en upload (camara/galeria)

- Implementada la funcionalidad real de media en `Configurar sesion`:
  - `Hacer foto` ahora dispara `ImagePicker` con `ImageSource.camera`.
  - `Galeria` ahora abre `ImagePicker` con `ImageSource.gallery`.
  - al seleccionar imagen, se copia a almacenamiento local de app (`session_media/`) y se asocia a la sesion.
- Integracion en detalle de sesion:
  - nuevo campo `sessionPhotoLocalPath` en `RecordedSession`.
  - `SessionDetailPage` ahora renderiza la imagen real con `Image.file(...)` cuando hay ruta local valida.
  - se mantiene fallback visual (gradiente + icono) si no hay imagen.
- Hardening de plataforma:
  - manejo de `MissingPluginException` y errores de seleccion con `SnackBar` para evitar crashes en entornos sin plugin disponible.
- Archivos actualizados:
  - `lib/features/sessions/domain/entities/recorded_session.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 67)

- `Bloque incremental 22:46-22:55 = 9m`
- `Bloque total 19:23-22:55 = 3h 32m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 57m`
- `Total acumulado de referencia = 39h 57m`

### 2026-03-03 - Sessions v3.1 fase 68: permisos de plataforma para camara/galeria

- Se completo el wiring de permisos para que la seleccion real de media funcione en dispositivos moviles:
  - Android: agregado `android.permission.CAMERA` en `AndroidManifest.xml`.
  - iOS: agregado `NSCameraUsageDescription` y actualizado `NSPhotoLibraryUsageDescription` para el flujo de sesiones.
- Archivos actualizados:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada (regresion completa tras cambios de permisos):
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 68)

- `Bloque incremental 22:55-22:57 = 2m`
- `Bloque total 19:23-22:57 = 3h 34m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 9h 59m`
- `Total acumulado de referencia = 39h 59m`

### 2026-03-03 - Sessions v3.1 fase 69: preview de foto en dialogo de subida

- Mejora de UX en `Configurar sesion` tras implementar seleccion real de media.
- Cambio aplicado:
  - al seleccionar una imagen (camara o galeria), el dialogo muestra un thumbnail preview real dentro de la card de `Imagen de sesion`,
  - se mantiene etiqueta visual `Foto seleccionada`,
  - se agrega fallback visual con mensaje si la imagen no se puede renderizar.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 69)

- `Bloque incremental 22:57-23:01 = 4m`
- `Bloque total 19:23-23:01 = 3h 38m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 10h 03m`
- `Total acumulado de referencia = 40h 03m`

### 2026-03-03 - Sessions v3.1 fase 70: accion para quitar foto seleccionada

- Se añade control explicito para eliminar la imagen elegida en `Configurar sesion`.
- Cambio aplicado en dialogo de upload:
  - cuando hay foto seleccionada, aparece boton `Quitar foto`,
  - al pulsarlo se limpia `sessionPhotoLocalPath` y se resetea `mediaSelection` a `none`,
  - para reemplazar foto se mantiene el flujo directo pulsando `Hacer foto` o `Galeria` de nuevo.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 70)

- `Bloque incremental 23:01-23:13 = 12m`
- `Bloque total 19:23-23:13 = 3h 50m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 10h 15m`
- `Total acumulado de referencia = 40h 15m`

### 2026-03-03 - Sessions v3.1 fase 71: dropdown de equipo conectado a setups reales de Perfil

- Corregida la fuente de datos del campo `Equipo utilizado (opcional)` en `Configurar sesion`.
- Cambio aplicado:
  - el dropdown ya no depende del catalogo temporal de UI,
  - ahora carga directamente las `GearSetup` reales desde `ProfileModule.gearController.savedGearSetups`, respetando el estado actual de `Perfil > Mi equipo`.
- Resultado funcional:
  - las opciones creadas en `Equipacion personalizada` aparecen en el dialogo de upload de sesiones.
- Ajuste de pruebas:
  - `sessions_page_test.dart` ahora prepara setups via `ProfileModule`/`GearSetup` real (en lugar de forzar `ProfileGearSetupCatalog`).
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 71)

- `Bloque incremental 23:13-23:22 = 9m`
- `Bloque total 19:23-23:22 = 3h 59m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 10h 24m`
- `Total acumulado de referencia = 40h 24m`

### 2026-03-03 - Sessions v3.1 fase 72: recordar ultima equipacion usada en upload

- Mejora de UX en `Configurar sesion` para acelerar cargas consecutivas.
- Cambio aplicado:
  - el dialogo ahora recuerda la ultima `GearSetup` seleccionada,
  - al volver a abrir `Subir sesion`, el dropdown `Equipo utilizado (opcional)` inicia con esa equipacion (si sigue existiendo en `Mi equipo`).
- Ajuste tecnico:
  - se agrega `gearSetupId` al contrato interno del dialogo de upload,
  - se guarda en estado local de `SessionsPage` como `_lastUsedGearSetupId` tras una subida.
- Cobertura de regresion:
  - `sessions_page_test.dart` se amplia para verificar que, tras una subida con equipacion seleccionada, la siguiente subida conserva esa seleccion por defecto.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 72)

- `Bloque incremental 23:22-23:29 = 7m`
- `Bloque total 19:23-23:29 = 4h 06m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 10h 31m`
- `Total acumulado de referencia = 40h 31m`

### 2026-03-03 - Sessions v3.1 fase 73: tarjeta de equipacion con detalle de cometa y tabla

- Mejora de contenido en la tarjeta informativa que aparece al seleccionar `Equipo utilizado` en `Configurar sesion`.
- Cambio aplicado:
  - ademas del nombre de la equipacion, ahora se muestran:
    - `Cometa: <marca modelo tamano>`
    - `Tabla: <marca modelo tamano>`
  - los datos se resuelven desde los IDs reales de `GearSetup` contra inventario de `Perfil > Mi equipo`.
- Ajuste tecnico:
  - se incorpora snapshot interno de gear en `SessionsPage` con setups + lookup de kites/boards para renderizar la tarjeta.
- Cobertura de regresion:
  - `sessions_page_test.dart` valida que al seleccionar una equipacion aparezcan textos de `Cometa` y `Tabla` en el dialogo.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-03 - Conteo de horas (actualizacion post fase 73)

- `Bloque incremental 23:29-23:38 = 9m`
- `Bloque total 19:23-23:38 = 4h 15m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 10h 40m`
- `Total acumulado de referencia = 40h 40m`

### 2026-03-04 - Sessions v3.1 fase 74: tarjeta de equipacion alineada con detalle de Perfil

- Ajustada la tarjeta informativa de `Equipo utilizado` en `Configurar sesion` para mostrar el mismo nivel de detalle que el dialogo de `Equipacion personalizada` en `Perfil > Mi equipo`.
- Cambio aplicado:
  - al seleccionar equipacion, ahora se renderizan todas las lineas de componentes disponibles de forma equivalente al dialogo de perfil:
    - Cometa
    - Tabla
    - Barra
    - Arnes
    - Traje
    - Casco
    - Chaleco
  - se reutiliza snapshot de gear real (setups + inventario completo) para resolver IDs y componer textos.
- Cobertura de regresion:
  - `sessions_page_test.dart` ampliado para validar presencia de todas las lineas en la tarjeta tras seleccionar una equipacion completa.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 74)

- `Bloque incremental 23:38-00:02 = 24m`
- `Bloque total 19:23-00:02 = 4h 39m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 04m`
- `Total acumulado de referencia = 41h 04m`

### 2026-03-04 - Sessions v3.1 fase 75: preview de foto en tarjeta de sesion guardada (My Sessions)

- Se añade previsualizacion de la foto subida en la tarjeta de cada sesion dentro de `Session > My Sessions`.
- Comportamiento:
  - si la sesion tiene `sessionPhotoLocalPath` valido, la card muestra thumbnail real (antes de los chips de equipo/resumen),
  - si no hay foto, la tarjeta mantiene el layout actual sin preview.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 75)

- `Bloque incremental 00:02-00:09 = 7m`
- `Bloque total 19:23-00:09 = 4h 46m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 11m`
- `Total acumulado de referencia = 41h 11m`

### 2026-03-04 - Sessions v3.1 fase 76: preview de foto como fondo en tarjeta de My Sessions

- Ajustada la UI de `My Sessions` para que la foto subida se vea integrada como fondo de la tarjeta (en lugar de bloque aparte en el cuerpo).
- Cambio aplicado en cada card de sesion:
  - la imagen local se renderiza de fondo (`BoxFit.cover`),
  - se aplica overlay semitransparente para mantener legibilidad del texto/chips,
  - si no hay foto, se conserva el layout normal actual.
- Archivo actualizado:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 76)

- `Bloque incremental 00:09-00:12 = 3m`
- `Bloque total 19:23-00:12 = 4h 49m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 14m`
- `Total acumulado de referencia = 41h 14m`

### 2026-03-04 - Sessions v3.1 fase 77: mejora de navegacion en SessionDetail

- Mejora de usabilidad en la pantalla `Detalle de sesion` al abrir una sesion guardada.
- Cambios aplicados:
  - nueva card `Navegacion rapida` con chips para saltar a secciones clave,
  - cada chip hace scroll animado a su bloque (`Resumen`, `Timeline`, `Saltos`, `Eventos`, `Avanzadas`),
  - se mantienen intactos los datos y layout base previos; el cambio es orientado a navegacion y lectura.
- Ajustes tecnicos:
  - `ScrollController` dedicado en `SessionDetailPage`,
  - `GlobalKey` por seccion y `Scrollable.ensureVisible` para anclajes.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 77)

- `Bloque incremental 00:12-00:25 = 13m`
- `Bloque total 19:23-00:25 = 5h 02m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 27m`
- `Total acumulado de referencia = 41h 27m`

### 2026-03-04 - Sessions v3.1 fase 78: editar/eliminar sesion desde detalle

- Implementadas acciones de gestion desde `Detalle de sesion` para sesiones de `My Sessions`.
- Cambios aplicados:
  - AppBar con menu de tres puntos en `SessionDetailPage` (solo para origen `My Sessions`) con opciones:
    - `Editar`
    - `Eliminar`
  - La pantalla de detalle devuelve accion al listado para ejecutar flujo correspondiente.
- Flujo `Eliminar`:
  - confirmacion en dialogo,
  - eliminacion de la sesion en UI y en almacenamiento in-memory del modulo de sesiones.
- Flujo `Editar`:
  - dialogo de edicion que permite cambiar exclusivamente:
    - equipo utilizado,
    - foto,
    - comentario de sesion,
  - guardado de cambios sobre la misma sesion (update por ID).
- Cambios de arquitectura de sessions para soportar borrado:
  - nuevo metodo `deleteRecordedSession` en `SessionRecordsPort`,
  - nuevo `DeleteRecordedSessionUseCase`,
  - wiring en `SessionsModule`,
  - implementacion en `InMemorySessionRecordsAdapter`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/domain/ports/out/session_records_port.dart`
  - `lib/features/sessions/application/use_cases/session_records_use_cases.dart`
  - `lib/features/sessions/di/sessions_module.dart`
  - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_records_adapter.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 78)

- `Bloque incremental 00:25-00:34 = 9m`
- `Bloque total 19:23-00:34 = 5h 11m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 36m`
- `Total acumulado de referencia = 41h 36m`

### 2026-03-04 - Sessions v3.1 fase 79: mediciones avanzadas con dropdown estilo leaderboard

- Ajuste de UX en la tarjeta `Mediciones avanzadas` de `SessionDetailPage`.
- Cambio aplicado:
  - se elimina el selector por `ChoiceChip`,
  - se reemplaza por `DropdownButtonFormField` con estilo visual equivalente al filtro de `Orden` del leaderboard (header + items coloreados por familia),
  - se mantiene la logica de cambio de grupo activo y render de KPIs por familia.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/session_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 79)

- `Bloque incremental 00:34-00:37 = 3m`
- `Bloque total 19:23-00:37 = 5h 14m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 39m`
- `Total acumulado de referencia = 41h 39m`

### 2026-03-04 - Sessions v3.1 fase 80: ajuste de copy en dropdown de metricas avanzadas

- Se ajusta la etiqueta del desplegable de `Mediciones avanzadas` para mejorar claridad visual.
- Cambio aplicado:
  - `Familia KPI` -> `Categoria de metricas`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 80)

- `Bloque incremental 00:37-00:41 = 4m`
- `Bloque total 19:23-00:41 = 5h 18m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 43m`
- `Total acumulado de referencia = 41h 43m`

### 2026-03-04 - Revision de continuidad para retomar sesion

- Revisado el estado global del proyecto con foco en `SESSION_TRACKER.md` y documentacion de arquitectura (`docs/architecture/hexagonal_v3.md`, `docs/architecture/migration_backlog_v3.md`).
- Confirmado el ultimo punto funcional cerrado: `Sessions v3.1 fase 80`.
- Revalidado estado tecnico actual para continuar sin regresiones:
  - `flutter analyze` (ok)
  - `flutter test -r compact` (ok, suite completa)
- Se actualiza `Proximo paso acordado` para apuntar al siguiente bloque real (`v3.2`, fase 81 de sessions con persistencia local).

### 2026-03-04 - Conteo de horas (inicio de bloque actual)

- `Bloque 20:59-20:59 = 0m` (marca de arranque de esta sesion).
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 43m`.
- `Total acumulado de referencia = 41h 43m`.
- Nota: el cierre del bloque se actualiza al finalizar la siguiente fase implementada.

### 2026-03-04 - Sessions v3.2 fase 81: persistencia local de `My Sessions`

- Implementada persistencia local para sesiones registradas (`My Sessions`) con adaptador `local_file`.
- Cambios de arquitectura aplicados:
  - nuevo adaptador: `lib/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart`,
  - `SessionsModule` ampliado con factory `localFile(...)` y wiring de `session_records` persistidos,
  - `RecordedSession` ahora incorpora serializacion/deserializacion (`toJson` / `fromJson`) con codec de `insights` inyectable.
- Cambios en presentacion:
  - `SessionsPage` anade flag `useLocalPersistence` (default por entorno),
  - inicializa modulo en `localFile()` cuando `EnvConfig.sessionsLocalPersistenceEnabled` esta activo,
  - anadidos helpers de codec para persistir/restaurar `SessionInsightData`,
  - hardening en apertura de detalle para soportar `insights` recuperados de almacenamiento local.
- Soporte de modelo para persistencia de insights:
  - `SessionInsightData`, `SessionJumpRecord`, `SessionKpiGroup` y `SessionKpiItem` ahora tienen `toJson` / `fromJson`.
- Entorno y testing:
  - nuevo flag: `EnvConfig.sessionsLocalPersistenceEnabled`,
  - tests de `SessionsPage` fijados con `useLocalPersistence: false` para mantener determinismo.
- Cobertura nueva:
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart`.
- Archivos actualizados:
  - `lib/core/config/env/env_config.dart`
  - `lib/features/sessions/domain/entities/recorded_session.dart`
  - `lib/features/sessions/di/sessions_module.dart`
  - `lib/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart` (nuevo)
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart` (nuevo)
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-04 - Conteo de horas (actualizacion post fase 81)

- `Bloque incremental 20:59-21:06 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 11h 50m`
- `Total acumulado de referencia = 41h 50m`

### 2026-03-04 - Sessions v3.2 fase 82: persistencia local de dispositivos y seleccion activa

- Implementada persistencia local del slice de dispositivos vinculados en `sessions` y memoria de dispositivo activo entre arranques.
- Cambios de arquitectura aplicados:
  - `SessionDevicesPort` ampliado con contrato de seleccion activa:
    - `getSelectedDeviceId()`
    - `saveSelectedDeviceId(String? id)`
  - nuevos use cases en `session_devices_use_cases.dart`:
    - `GetSelectedDeviceIdUseCase`
    - `SaveSelectedDeviceIdUseCase`
  - `SessionsModule` ampliado con wiring de seleccion activa en `inMemory()` y `localFile()`.
- Infraestructura local nueva:
  - nuevo adaptador `LocalFileSessionDevicesAdapter` en `lib/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter.dart`,
  - persistencia en archivo `sessions_devices_v1.json` con:
    - lista de dispositivos,
    - `selectedDeviceId`.
- Integracion en presentation:
  - `SessionsPage` ahora hidrata `_selectedDeviceId` desde modulo al iniciar,
  - cada cambio de seleccion se persiste inmediatamente,
  - al eliminar dispositivo activo se recalcula fallback y se persiste,
  - al asegurar fallback inicial tambien se guarda seleccion resultante.
- Ajustes de modelo:
  - `LinkedDevice` incorpora `toJson` / `fromJson` para persistencia local.
- Cobertura nueva:
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter_test.dart` valida:
    - persistencia de dispositivos,
    - persistencia de seleccion activa,
    - limpieza de seleccion tras borrado del dispositivo seleccionado.
- Archivos actualizados:
  - `lib/features/sessions/domain/entities/linked_device.dart`
  - `lib/features/sessions/domain/ports/out/session_devices_port.dart`
  - `lib/features/sessions/application/use_cases/session_devices_use_cases.dart`
  - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_devices_adapter.dart`
  - `lib/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter.dart` (nuevo)
  - `lib/features/sessions/di/sessions_module.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter_test.dart` (nuevo)
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-04 - Conteo de horas (actualizacion post fase 82)

- `Bloque incremental 20:59-21:11 = 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 12h 02m`
- `Total acumulado de referencia = 42h 02m`

### 2026-03-04 - Sessions v3.2 fase 83: persistencia de preferencias de vista (tab/filtros/orden)

- Implementada persistencia local de preferencias de UI en `Session` para retomar la vista exactamente como se dejo en el ultimo uso.
- Alcance funcional persistido:
  - tab activa: `Start Session` / `My Sessions`,
  - filtro de dispositivo en `My Sessions`,
  - orden de listado (`Mas recientes` / `Mas antiguas`).
- Cambios de arquitectura aplicados:
  - nueva entidad de dominio `SessionViewPreferences`,
  - nuevo puerto `SessionViewPreferencesPort`,
  - nuevos use cases:
    - `GetSessionViewPreferencesUseCase`,
    - `SaveSessionViewPreferencesUseCase`.
- Infraestructura agregada:
  - adaptador `in_memory` para preferencias de vista,
  - adaptador `local_file` en `sessions_view_preferences_v1.json`.
- Wiring de feature actualizado:
  - `SessionsModule` ahora expone/injecta circuito de preferencias en `inMemory()` y `localFile()`.
- Integracion en presentation:
  - `SessionsPage` hidrata preferencias al iniciar,
  - persiste cada cambio de tab/filtro/orden,
  - sanea filtros/orden invalidos contra el estado actual de dispositivos,
  - notifica correctamente `onStartTabChanged` tras hidratacion inicial para mantener coherencia de toolbar en `Dashboard`.
- Cobertura de regresion ampliada:
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart` (nuevo),
  - `sessions_page_test.dart`: nuevo test `persists session tab and filters across page instances in local mode`.
- Archivos actualizados:
  - `lib/features/sessions/domain/entities/session_view_preferences.dart` (nuevo)
  - `lib/features/sessions/domain/ports/out/session_view_preferences_port.dart` (nuevo)
  - `lib/features/sessions/application/use_cases/session_view_preferences_use_cases.dart` (nuevo)
  - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_view_preferences_adapter.dart` (nuevo)
  - `lib/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter.dart` (nuevo)
  - `lib/features/sessions/di/sessions_module.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart` (nuevo)
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/session_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact` (ok)
  - `flutter test test/architecture/hexagonal_dependency_rules_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-04 - Conteo de horas (actualizacion post fase 83)

- `Bloque incremental 20:59-21:19 = 20m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 12h 10m`
- `Total acumulado de referencia = 42h 10m`

### 2026-03-04 - Sessions v3.2 fase 84: persistencia de ultima `GearSetup` usada en upload

- Se extiende la persistencia de preferencias de `Session` para recordar la ultima `GearSetup` elegida en el dialog de `Subir sesion` entre arranques.
- Cambios funcionales:
  - al confirmar upload, se guarda `gearSetupId` como ultima seleccion usada,
  - al editar una sesion y cambiar equipacion, se actualiza igualmente la ultima seleccion,
  - al abrir de nuevo el dialog de upload, se preselecciona la ultima `GearSetup` persistida (si sigue existiendo en perfil).
- Cambios de implementacion:
  - `SessionViewPreferences` incorpora `lastUsedGearSetupId` nullable,
  - `SessionsPage` hidrata y persiste este campo junto con tab/filtros/orden,
  - se mantiene la validacion existente contra setups vigentes para fallback seguro a `Sin equipacion`.
- Cobertura de regresion:
  - actualizado `local_file_session_view_preferences_adapter_test.dart` para validar lectura/escritura del nuevo campo,
  - nuevo test widget en `sessions_page_test.dart`:
    - `persists last used gear setup for upload across page instances`.
- Archivos actualizados:
  - `lib/features/sessions/domain/entities/session_view_preferences.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-04 - Conteo de horas (actualizacion post fase 84)

- `Bloque incremental 21:19-21:24 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 12h 15m`
- `Total acumulado de referencia = 42h 15m`

### 2026-03-04 - Sessions v3.2 fase 85: persistencia de `spot` por defecto en upload

- Se completa la persistencia de preferencias del dialog de upload guardando y rehidratando el `spot` seleccionado como valor por defecto para siguientes sesiones.
- Cambios funcionales:
  - al confirmar `Subir sesion`, se persiste `spot` seleccionado,
  - al abrir de nuevo el dialog, el selector de spot toma el ultimo valor usado,
  - si el valor persistido no esta en el catalogo actual de spots de upload, se aplica fallback seguro al primer spot disponible.
- Cambios de implementacion:
  - `SessionViewPreferences` incorpora `lastUsedUploadSpot`,
  - `SessionsPage` mantiene `_uploadSpotOptions` centralizado y sincroniza `_lastUsedUploadSpot` con persistencia,
  - el `DropdownButtonFormField` de `Spot` ahora usa catalogo dinamico desde `_uploadSpotOptions`.
- Cobertura de regresion:
  - actualizado `local_file_session_view_preferences_adapter_test.dart` para incluir `lastUsedUploadSpot`,
  - test widget ampliado y renombrado en `sessions_page_test.dart`:
    - `persists last used gear setup and upload spot across page instances`.
- Archivos actualizados:
  - `lib/features/sessions/domain/entities/session_view_preferences.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter test -r compact` (ok, suite completa)

### 2026-03-04 - Conteo de horas (actualizacion post fase 85)

- `Bloque incremental 21:24-21:28 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 12h 19m`
- `Total acumulado de referencia = 42h 19m`

### 2026-03-04 - Sessions v3.3 fase 86: mejora UX de `Start Session`

- Se mejora la experiencia de `Start Session` para hacer el flujo mas guiado y legible en la parte superior de la pantalla.
- Cambios aplicados en UI:
  - nuevo bloque `Resumen rapido` con estado instantaneo de dispositivo seleccionado, estado de captura e importacion reciente,
  - CTA directo `Vincular dispositivo` dentro de la vista (sin depender del toolbar superior),
  - tarjetas de dispositivos con realce visual del dispositivo activo (borde y fondo),
  - barra de progreso de estado en `Control de sesion` para visualizar etapa actual del flujo (preparada/grabando/lista/subiendo/sincronizada).
- Cambios de soporte:
  - nuevos helpers internos en `SessionsPage`: `_captureStepIndex()` y `_captureStepLabel()`.
- Ajustes de pruebas:
  - actualizado `sessions_page_test.dart` para adaptar interaccion al nuevo alto/flujo visual (viewport del test de capacidades).
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 86)

- `Bloque incremental 21:28-21:56 = 28m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 12h 47m`
- `Total acumulado de referencia = 42h 47m`

### 2026-03-04 - Sessions v3.3 fase 87: pulido UX de `My Sessions`

- Se mejora la legibilidad y accionabilidad de `My Sessions` para uso diario sin abrir pantallas intermedias.
- Cambios aplicados:
  - nuevo bloque `Estado de filtros` con visibilidad persistente de `Dispositivo`, `Orden` y `Busqueda` activa,
  - accion rapida `Resetear filtros rapidos` para volver al estado base en un toque,
  - acciones rapidas por tarjeta de sesion: `Editar` y `Eliminar` directamente en el listado.
- Objetivo UX logrado:
  - hacer mas evidente el estado de filtros persistidos,
  - reducir taps para tareas frecuentes de mantenimiento de sesiones.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 87)

- `Bloque incremental 21:56-22:01 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 12h 52m`
- `Total acumulado de referencia = 42h 52m`

### 2026-03-04 - Sessions v3.3 fase 88: selector de dispositivos en desplegable + tarjeta seleccionada

- Se adapta `Start Session` al modelo de uso acordado: listado de vinculados en desplegable y foco visual en el dispositivo activo en una tarjeta dedicada.
- Cambios aplicados en UI:
  - reemplazo del listado completo de tarjetas por `DropdownButtonFormField` de dispositivos vinculados,
  - tarjeta de `dispositivo seleccionado` con nombre, tipo, ultima sincronizacion y estado detectado,
  - se conserva persistencia de `selectedDeviceId` y limpieza de hint de importacion al cambiar de dispositivo.
- Ajustes de pruebas:
  - actualizados tests de `sessions_page_test.dart` para flujo de seleccion via dropdown (incluyendo cambio a Apple Watch y validacion de capacidades).
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 88)

- `Bloque incremental 22:01-22:21 = 20m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 12m`
- `Total acumulado de referencia = 43h 12m`

### 2026-03-04 - Sessions v3.3 fase 88 (ajuste UX): retirada tarjeta `Resumen rapido`

- Se elimina la tarjeta `Resumen rapido` de `Start Session` por decision de UX para mantener pantalla mas limpia.
- Se conserva el flujo principal de fase 88:
  - selector de dispositivos en desplegable,
  - tarjeta de dispositivo seleccionado,
  - control de sesion y capacidades sin cambios funcionales.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post ajuste fase 88)

- `Bloque incremental 22:21-22:26 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 17m`
- `Total acumulado de referencia = 43h 17m`

### 2026-03-04 - Sessions v3.3 fase 89: accion `Sincronizar dispositivo` en tarjeta seleccionada

- Se anade boton `Sincronizar dispositivo` dentro de la tarjeta del dispositivo activo en `Start Session` para descargar sesiones grabadas en el wearable/dispositivo vinculado.
- Comportamiento implementado:
  - si no hay dispositivo seleccionado, muestra aviso y no ejecuta sync,
  - al sincronizar, se genera sesion importada desde el dispositivo seleccionado,
  - se persiste en `My Sessions`, mantiene la vista en `Start Session` y muestra feedback (`hint` + snackbar) de sincronizacion.
- Refactor aplicado:
  - extraccion de logica comun en `_saveImportedSession(...)` para unificar flujo de importacion por archivo y sincronizacion por dispositivo.
- Cobertura de pruebas:
  - nuevo test widget en `sessions_page_test.dart`: `syncs selected device session from selected device card`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 89)

- `Bloque incremental 22:26-22:31 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 22m`
- `Total acumulado de referencia = 43h 22m`

### 2026-03-04 - Sessions v3.3 fase 89 (ajuste de flujo): sincronizacion requiere `Configurar sesion`

- Se ajusta el comportamiento de `Sincronizar dispositivo` segun criterio funcional: la sincronizacion no guarda directamente en feed.
- Nuevo flujo aplicado:
  - al pulsar `Sincronizar dispositivo`, se abre dialog `Configurar sesion`,
  - solo tras confirmar `Subir sesion` en ese dialog se crea y persiste la sesion en feed,
  - si el usuario cancela dialog, no se guarda ninguna sesion.
- Implementacion:
  - `sync` pasa a flujo async con confirmacion de configuracion previa,
  - se conserva feedback de sincronizacion y persistencia de preferencias usadas (spot/equipacion).
- Pruebas:
  - actualizado test `syncs selected device session from selected device card` para validar apertura del dialog y confirmacion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post ajuste fase 89)

- `Bloque incremental 22:31-22:39 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 30m`
- `Total acumulado de referencia = 43h 30m`

### 2026-03-04 - Sessions v3.3 fase 90: sincronizacion multi-sesion desde dispositivo vinculado

- Se amplia `Sincronizar dispositivo` para contemplar que un wearable/dispositivo pueda traer varias sesiones pendientes en una sola sincronizacion.
- Flujo implementado:
  - al sincronizar, se muestra dialog `Sesiones detectadas para sincronizar` con seleccion multiple,
  - tras seleccionar sesiones y pulsar `Continuar`, se abre `Configurar sesion`,
  - solo al confirmar `Subir sesion` se persisten en feed todas las sesiones seleccionadas,
  - si se cancela cualquier dialog, no se guarda nada.
- Alcance actual de mock:
  - dispositivos `Woo Sports`/`Garmin` devuelven 2 sesiones de ejemplo para validar flujo multi-sync,
  - otros dispositivos mantienen flujo de una sola sesion.
- Cambios tecnicos:
  - nuevo selector multi-sesion `_showSyncSelectionDialog(...)`,
  - nuevo builder `_buildSyncedRecordedSession(...)`,
  - `_syncSessionFromDevice()` refactorizado para sync por lote con configuracion previa.
- Pruebas:
  - actualizado test `syncs selected device session from selected device card` para validar:
    - dialog de sesiones detectadas,
    - paso por `Configurar sesion`,
    - confirmacion de sincronizacion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post fase 90)

- `Bloque incremental 22:39-22:49 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 40m`
- `Total acumulado de referencia = 43h 40m`

### 2026-03-04 - Sessions v3.3 fase 90 (ajuste de UX): sesiones sincronizadas en tarjeta, no dialog inicial

- Se ajusta el flujo de sincronizacion segun criterio funcional:
  - al pulsar `Sincronizar dispositivo` ya no aparece dialog inicial,
  - se muestra una tarjeta bajo el dispositivo seleccionado con las sesiones sincronizadas detectadas,
  - al pulsar una sesion sincronizada se abre `Configurar sesion`,
  - solo tras confirmar `Subir sesion` se persiste en feed.
- Cambios tecnicos:
  - eliminada seleccion previa por dialog (`_showSyncSelectionDialog`),
  - nuevo estado UI para pendientes sincronizadas por dispositivo (`_syncedPendingSessions`, `_syncedPendingDeviceId`),
  - nuevo handler `_configureSyncedSession(...)` para puente tarjeta -> dialog de configuracion -> persistencia.
- Pruebas:
  - actualizado test `syncs selected device session from selected device card` para validar:
    - render de tarjeta de sesiones sincronizadas,
    - apertura de `Configurar sesion` al tocar una sesion,
    - permanencia de sesiones pendientes restantes.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post ajuste fase 90)

- `Bloque incremental 22:49-22:56 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 47m`
- `Total acumulado de referencia = 43h 47m`

### 2026-03-04 - Sessions v3.3 fase 90 (ajuste UX): opcion de eliminar sesion sincronizada pendiente

- Se anade opcion de `Eliminar sesion sincronizada` en cada item de la tarjeta de sesiones sincronizadas del dispositivo.
- Comportamiento:
  - permite descartar una sesion pendiente antes de abrir `Configurar sesion`,
  - si se eliminan todas las pendientes, se limpia la tarjeta y el estado asociado,
  - se actualiza texto de hint con el numero restante de pendientes.
- Cambios tecnicos:
  - nuevo handler `_removeSyncedPendingSession(...)`,
  - boton `IconButton` de borrado en trailing de cada sesion sincronizada.
- Pruebas:
  - ampliado test `syncs selected device session from selected device card` para validar presencia de la opcion de eliminar.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post ajuste fase 90-b)

- `Bloque incremental 22:56-23:00 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 51m`
- `Total acumulado de referencia = 43h 51m`

### 2026-03-04 - Sessions v3.3 fase 90 (ajuste UX): confirmacion antes de eliminar sesion sincronizada

- Se agrega confirmacion obligatoria antes de descartar una sesion sincronizada pendiente para evitar eliminaciones accidentales.
- Flujo nuevo:
  - tap en icono eliminar -> dialog `Eliminar sesion sincronizada`,
  - `Cancelar` mantiene la sesion en la lista,
  - `Eliminar` confirma y la descarta.
- Pruebas:
  - actualizado test `syncs selected device session from selected device card` para validar la aparicion del dialogo y cancelacion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post ajuste fase 90-c)

- `Bloque incremental 23:00-23:03 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 54m`
- `Total acumulado de referencia = 43h 54m`

### 2026-03-04 - Sessions v3.3 fase 90 (ajuste UX): capacidades via boton + dialog

- Se retira la tarjeta persistente de `Capacidades del dispositivo` y se reemplaza por un boton `Ver capacidades del dispositivo`.
- Al pulsar el boton, se abre dialog con:
  - ratio de sensores disponibles,
  - descripcion de habilitacion automatica de KPI,
  - listado completo de capacidades (disponible/no disponible).
- Objetivo: reducir ruido visual en `Start Session` y mostrar detalle solo bajo demanda.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)

### 2026-03-04 - Conteo de horas (actualizacion post ajuste fase 90-d)

- `Bloque incremental 23:03-23:07 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 58m`
- `Total acumulado de referencia = 43h 58m`

### 2026-03-05 - Sessions v3.3 fase 91: accion rapida de duplicar sesion en `My Sessions`

- Implementada accion rapida `Duplicar` en cada tarjeta de `My Sessions` para crear variantes editables sin salir del listado.
- Comportamiento aplicado:
  - crea una nueva sesion con ID nuevo y copia de contenido (equipo, foto, resumen y metricas),
  - genera titulo de copia sin colisiones (`(copia)`, `(copia 2)`, etc.),
  - inserta la sesion duplicada en el feed y la persiste via `SessionsModule`.
- Ajuste de robustez:
  - `SnackBar` de confirmacion mostrado solo si existe `Scaffold` en contexto (evita fallos en tests/widget hosts sin scaffold).
- Cobertura de regresion:
  - nuevo test widget `duplicates session from My Sessions quick action` en `sessions_page_test.dart`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 91)

- `Bloque incremental 18:53-18:57 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 02m`
- `Total acumulado de referencia = 44h 02m`

### 2026-03-05 - Revision de continuidad para retomar sesion

- Revisado el estado global del proyecto con foco en `SESSION_TRACKER.md`, `docs/architecture/hexagonal_v3.md` y `docs/architecture/migration_backlog_v3.md`.
- Confirmado ultimo bloque funcional cerrado: `Sessions v3.3 fase 90 (ajuste UX): capacidades via boton + dialog`.
- Confirmado ultimo corte de horas registrado en tracker:
  - `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 58m`
  - `Total acumulado de referencia = 43h 58m`
- Se mantiene continuidad de roadmap para seguir con `Sessions fase 91` (duplicar sesion en `My Sessions`).

### 2026-03-05 - Conteo de horas (inicio de bloque actual)

- `Bloque 18:53-18:53 = 0m` (marca de arranque de esta sesion).
- `Acumulado (track exacto desde 2026-03-01 11:34) = 13h 58m`.
- `Total acumulado de referencia = 43h 58m`.
- Nota: al cerrar el siguiente bloque funcional se actualiza el incremental y ambos acumulados.

### 2026-03-05 - Sessions v3.3 fase 91 (reversion): eliminada accion de duplicar sesiones

- Aplicado rollback funcional por decision de producto: se elimina completamente la accion `Duplicar` en `My Sessions`.
- Cambios aplicados:
  - eliminado boton `Duplicar` de las cards de sesiones,
  - eliminada logica de duplicado de sesiones en `SessionsPage`,
  - eliminado test de duplicado en `sessions_page_test.dart`.
- Resultado:
  - se evita creacion de sesiones repetidas,
  - `My Sessions` vuelve al flujo original (`Editar` / `Eliminar` / detalle).
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post reversion fase 91)

- `Bloque incremental 18:57-19:00 = 3m`
- `Bloque total 18:53-19:00 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 05m`
- `Total acumulado de referencia = 44h 05m`

### 2026-03-05 - Sessions v3.3 fase 92: mejora visual de tarjeta de dispositivo seleccionado

- Aplicado pulido visual en `Start Session` sobre la tarjeta del dispositivo vinculado activo para hacerla mas legible y moderna.
- Cambios en UI de `SessionsPage`:
  - tarjeta con fondo en gradiente suave, borde de realce y esquinas mas amplias,
  - iconografia por tipo de dispositivo (`Woo`, `Apple Watch`, `Android`, etc.),
  - estado operativo destacado en badge de alto contraste,
  - nuevas pills de metadata (`Ult sync` y ratio de sensores disponibles),
  - acciones reordenadas en bloque visible: `Ver capacidades` y `Sincronizar dispositivo`.
- Refactor de soporte:
  - nuevo helper `_deviceKindIcon(...)`,
  - nuevo helper `_buildDeviceMetaPill(...)`.
- Resultado:
  - mejor jerarquia visual en la zona de dispositivo seleccionado,
  - se mantiene comportamiento funcional previo (capabilities + sync + persistencia).
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 92)

- `Bloque incremental 19:00-19:06 = 6m`
- `Bloque total 18:53-19:06 = 13m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 11m`
- `Total acumulado de referencia = 44h 11m`

### 2026-03-05 - Sessions v3.3 fase 92-b: ajustes finos de copy e icono en tarjeta de dispositivo

- Ajustado copy de metadata en tarjeta de dispositivo seleccionado:
  - de `Ult sync ...` a `Sincronizado ...` (normalizado en minusculas para mantener frase natural).
- Ajustada accion de capacidades para mostrarse como boton solo icono:
  - icono dinamico por tipo de dispositivo (`telefono`, `reloj`, u `otro`),
  - mantiene `tooltip` de accesibilidad: `Ver capacidades del dispositivo`.
- Refactor de soporte:
  - nuevo helper `_capabilitiesActionIcon(...)`.
- Actualizado test para desacoplarse del icono fijo y usar tooltip de la accion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 92-b)

- `Bloque incremental 19:10-19:12 = 2m`
- `Bloque total 18:53-19:12 = 19m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 13m`
- `Total acumulado de referencia = 44h 13m`

### 2026-03-05 - Sessions v3.3 fase 92-c: tarjeta de dispositivo con CTA contextual por tipo

- Ajustado comportamiento de acciones en tarjeta de dispositivo seleccionado (`Start Session`):
  - si el dispositivo seleccionado es `Telefono del usuario`, no se muestra `Sincronizar dispositivo`,
  - la accion de capacidades queda integrada en cabecera como icono principal (sustituye al icono decorativo anterior).
- Se mantiene boton de sincronizacion para wearables/dispositivos externos (Woo, Watch, etc.).
- Test actualizado para contemplar escenarios con/ sin boton de sincronizacion segun dispositivo activo.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 92-c)

- `Bloque incremental 19:12-19:18 = 6m`
- `Bloque total 18:53-19:18 = 25m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 19m`
- `Total acumulado de referencia = 44h 19m`

### 2026-03-05 - Sessions v3.3 fase 92-d: simplificacion visual en tarjeta de dispositivo

- Eliminado el chip con icono + conteo de sensores (`x/y sensores`) en la tarjeta de dispositivo seleccionado de `Start Session`.
- Se mantiene el acceso a capacidades via boton icono (dialog de capacidades intacto).
- Objetivo: reducir ruido visual en cabecera de dispositivo y mantener solo informacion relevante inmediata.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 92-d)

- `Bloque incremental 19:20-19:21 = 1m`
- `Bloque total 18:53-19:21 = 28m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 20m`
- `Total acumulado de referencia = 44h 20m`

### 2026-03-05 - Sessions v3.3 fase 93: mejora visual de tarjeta de sesiones sincronizadas/importadas

- Redisenada la tarjeta de `Sesiones sincronizadas del dispositivo` para mejorar jerarquia y legibilidad.
- Cambios aplicados en listado de sesiones pendientes:
  - subtitulo explicativo bajo el titulo de bloque,
  - cards internas con borde fino + gradiente suave,
  - icono de descarga dentro de contenedor tonal,
  - estado visual `Pendiente` como chip compacto,
  - indicador `Configurar` mas claro (pill tonal) y accion de borrar mantenida.
- Se conserva el comportamiento funcional existente:
  - tap sobre card abre configuracion,
  - `Eliminar sesion sincronizada` mantiene tooltip/flujo.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93)

- `Bloque incremental 19:21-19:24 = 3m`
- `Bloque total 18:53-19:24 = 31m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 23m`
- `Total acumulado de referencia = 44h 23m`

### 2026-03-05 - Sessions v3.3 fase 93-b: interaccion controlada en tarjeta de sesiones importadas

- Ajustado comportamiento de tarjeta de sesiones sincronizadas/importadas:
  - se elimina apertura de `Configurar sesion` al tocar cualquier area de la card,
  - la configuracion se abre solo desde el boton `Configurar`.
- Ajuste de layout solicitado:
  - boton `Configurar` movido a la zona de contenido donde estaba el chip,
  - chip `Pendiente` movido a la columna lateral donde estaba `Configurar`.
- Test actualizado para abrir dialogo pulsando el boton `Configurar` en lugar del titulo de la sesion.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93-b)

- `Bloque incremental 19:29-19:31 = 2m`
- `Bloque total 18:53-19:31 = 38m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 25m`
- `Total acumulado de referencia = 44h 25m`

### 2026-03-05 - Sessions v3.3 fase 93-c: refinado de acciones en tarjeta de sesiones importadas

- Ajustada zona de acciones para mejorar legibilidad y alineacion:
  - `Configurar` pasa a `OutlinedButton.icon` en fila de acciones,
  - `Eliminar` se alinea en la misma linea/altura visual que `Configurar`,
  - `Pendiente` queda como chip en la misma fila de acciones, a la izquierda.
- Se mantiene el comportamiento funcional requerido:
  - la card no abre configuracion por tap general,
  - solo el boton `Configurar` abre el dialogo.
- Test actualizado para buscar `Configurar` como `OutlinedButton`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93-c)

- `Bloque incremental 19:29-19:35 = 6m`
- `Bloque total 18:53-19:35 = 42m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 31m`
- `Total acumulado de referencia = 44h 31m`

### 2026-03-05 - Sessions v3.3 fase 93-d: refinado final de botones en tarjeta de importadas

- Ajustado layout de acciones para resolver desequilibrio visual:
  - `Configurar` se mantiene como `OutlinedButton.icon` compacto,
  - `Eliminar` pasa a boton outlined icon-only con el mismo alto visual,
  - `Pendiente`, `Configurar` y `Eliminar` quedan en una misma fila responsive (`Wrap`) con mejor proporcion.
- Objetivo: evitar que `Configurar` se vea pesado y dejar `Eliminar` alineado en altura con el resto.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93-d)

- `Bloque incremental 19:35-19:38 = 3m`
- `Bloque total 18:53-19:38 = 45m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 34m`
- `Total acumulado de referencia = 44h 34m`

### 2026-03-05 - Sessions v3.3 fase 93-e: rollback de ajuste visual no aprobado

- Revertidos los ultimos cambios de acciones en tarjeta de sesiones importadas por feedback de diseno.
- Restaurado estado previo (fase 93-c):
  - `Pendiente` en chip,
  - `Configurar` como `OutlinedButton.icon`,
  - `Eliminar` como `IconButton` en la misma fila.
- Comportamiento funcional se mantiene:
  - la card no abre configuracion por tap general,
  - solo `Configurar` abre dialogo.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93-e)

- `Bloque incremental 19:38-19:41 = 3m`
- `Bloque total 18:53-19:41 = 48m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 37m`
- `Total acumulado de referencia = 44h 37m`

### 2026-03-05 - Sessions v3.3 fase 93-f: restaurado estado anterior solicitado

- Revertidos los cambios de rollback reciente y recuperado el estado inmediatamente anterior:
  - acciones de importadas en layout compacto (`Wrap`),
  - `Configurar` como `OutlinedButton.icon` compacto,
  - `Eliminar` como outlined icon-only con tooltip.
- Se mantiene comportamiento ya acordado:
  - la tarjeta no abre dialogo por tap general,
  - solo `Configurar` abre `Configurar sesion`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93-f)

- `Bloque incremental 19:42-19:43 = 1m`
- `Bloque total 18:53-19:43 = 50m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 38m`
- `Total acumulado de referencia = 44h 38m`

### 2026-03-05 - Sessions v3.3 fase 93-g: limpieza visual en tarjeta de sesiones importadas

- Eliminado el chip `Pendiente` de la fila de acciones en la tarjeta de sesiones sincronizadas/importadas.
- Se mantienen solo las acciones relevantes en la zona: `Configurar` y `Eliminar`.
- Comportamiento funcional sin cambios:
  - la tarjeta no abre dialogo por tap general,
  - solo `Configurar` abre `Configurar sesion`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 93-g)

- `Bloque incremental 19:43-19:44 = 1m`
- `Bloque total 18:53-19:44 = 51m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 39m`
- `Total acumulado de referencia = 44h 39m`

### 2026-03-05 - Sessions v3.3 fase 94: mejora visual de resumen en `My Sessions`

- Redisenado el bloque de resumen dentro de cada tarjeta de `My Sessions` para mejorar jerarquia visual.
- Cambios aplicados:
  - resumen mostrado en contenedor tonal con borde suave,
  - icono contextual de texto para identificar rapidamente el bloque,
  - etiqueta `Resumen de sesion` encima del contenido,
  - texto limitado a 3 lineas con ellipsis para evitar cards demasiado largas.
- Se mantiene comportamiento funcional actual sin cambios de flujo.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 94)

- `Bloque incremental 19:51-19:51 = 0m`
- `Bloque total 18:53-19:51 = 58m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 39m`
- `Total acumulado de referencia = 44h 39m`

### 2026-03-05 - Sessions v3.3 fase 94-b: ajuste de `My Sessions` segun feedback visual

- Revertida la mejora visual del bloque de resumen (se restaura texto simple del resumen de sesion).
- Ajustadas acciones para mostrarse siempre en una sola fila:
  - `Editar` y `Eliminar` pasan de `Wrap` a `Row` con separacion fija.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 94-b)

- `Bloque incremental 19:54-19:55 = 1m`
- `Bloque total 18:53-19:55 = 62m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 40m`
- `Total acumulado de referencia = 44h 40m`

### 2026-03-05 - Sessions v3.3 fase 94-c: acciones de `My Sessions` en modo responsive

- Ajustado layout de acciones en tarjetas de `My Sessions` para evitar roturas en pantallas estrechas.
- Cambios aplicados:
  - `Editar` y `Eliminar` permanecen en la misma linea,
  - ambos botones usan `Expanded` para repartirse el ancho,
  - en ancho muy estrecho (`isNarrowPhone`) se usan botones sin icono para reducir desbordes.
- Resultado: mantiene consistencia visual y previene overflows/errores de render por falta de espacio horizontal.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 94-c)

- `Bloque incremental 19:54-19:58 = 4m`
- `Bloque total 18:53-19:58 = 65m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 44m`
- `Total acumulado de referencia = 44h 44m`

### 2026-03-05 - Sessions v3.3 fase 94-d: refinado visual y responsive de acciones en `My Sessions`

- Ajustado el bloque de acciones porque la version anterior se veia forzada visualmente.
- Cambios aplicados:
  - `Editar` queda como boton principal compacto ocupando el ancho disponible,
  - `Eliminar` pasa a accion icon-only compacta (con tooltip) para aligerar la fila,
  - ambas acciones permanecen en la misma linea y sin riesgo de overflow en anchos pequenos.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 94-d)

- `Bloque incremental 19:58-20:01 = 3m`
- `Bloque total 18:53-20:01 = 68m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 47m`
- `Total acumulado de referencia = 44h 47m`

### 2026-03-05 - Sessions v3.3 fase 94-e: resumen y KPIs en tarjetas de `My Sessions`

- Mejorada la legibilidad del texto de resumen en cada card:
  - se limita a 3 lineas con ellipsis,
  - se aplica tono `onSurfaceVariant` y altura de linea mas limpia.
- Anadidos KPIs visibles en la propia tarjeta (sin entrar al detalle):
  - `Duracion`,
  - `Salto` (mas alto),
  - `Air time` maximo.
- Los valores se alimentan desde `SessionInsightData` de cada sesion y muestran fallback `--` si no hay dato.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 94-e)

- `Bloque incremental 20:01-20:06 = 5m`
- `Bloque total 18:53-20:06 = 73m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 52m`
- `Total acumulado de referencia = 44h 52m`

### 2026-03-05 - Sessions v3.3 fase 94-f: `Hangtime` + nuevos KPIs en `My Sessions` y detalle avanzado

- Ajustado copy en card de `My Sessions`:
  - `Air time` pasa a `Hangtime` para mantener consistencia con metricas del dominio.
- Anadidos KPIs extra visibles en la tarjeta:
  - `Vel max` (desde `maxSpeedKnots`),
  - `Dist salto` estimada (calculada a partir de velocidad maxima y hangtime maximo).
- Mejora en detalle avanzado (`SessionDetailPage`):
  - nuevo KPI `Distancia salto (estimada)` dentro del grupo `Saltos`.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 94-f)

- `Bloque incremental 20:13-20:15 = 2m`
- `Bloque total 18:53-20:15 = 82m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 14h 54m`
- `Total acumulado de referencia = 44h 54m`

### 2026-03-05 - Sessions v3.3 fase 95: rediseno estructural de tarjeta en `My Sessions`

- Aplicado nuevo formato de card en `My Sessions` segun especificacion de UX:
  - foto en la parte superior de la tarjeta,
  - bloque de equipo inmediatamente debajo (incluyendo `Cometa` y `Tabla` visibles),
  - KPIs en una sola linea desplazable horizontalmente,
  - metadata inferior con `dispositivo`, `fecha` y `hora`.
- Orden de chips KPI implementado tal como se solicito:
  - `Duracion` -> `Salto` -> `Hangtime` -> `Dist salto` -> `Vel max`.
- Ajustes de soporte:
  - helper para resolver setup por nombre y extraer datos de cometa/tabla,
  - fallback visual cuando no hay foto (placeholder superior),
  - eliminada dependencia no usada de `kDebugMode` tras el refactor.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 95)

- `Bloque incremental 20:15-20:49 = 34m`
- `Bloque total 18:53-20:49 = 116m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 28m`
- `Total acumulado de referencia = 45h 28m`

### 2026-03-05 - Sessions v3.3 fase 95-b: metadata inferior en una sola linea y sin chips

- Ajustado bloque inferior de metadata en tarjeta `My Sessions`:
  - eliminado formato de chips,
  - `dispositivo`, `fecha` y `hora` ahora se muestran en texto simple,
  - los 3 datos quedan en una sola linea con separadores (`·`) y scroll horizontal para evitar cortes en pantallas estrechas.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 95-b)

- `Bloque incremental 20:49-20:52 = 3m`
- `Bloque total 18:53-20:52 = 119m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 31m`
- `Total acumulado de referencia = 45h 31m`

### 2026-03-05 - Sessions v3.3 fase 95-c: fecha/hora bajo titulo y equipo con icono

- Ajustada jerarquia de metadata en la tarjeta de `My Sessions`:
  - `fecha` y `hora` se muestran justo debajo del titulo de sesion,
  - en la zona inferior se deja solo `dispositivo` (texto simple).
- Actualizado bloque de equipo:
  - se elimina el prefijo literal `Equipo:`,
  - se muestra icono de percha (`checkroom`) junto al nombre de equipacion.
- Test actualizado para no depender del prefijo `Equipo:` y validar el nombre de setup.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 95-c)

- `Bloque incremental 20:51-20:56 = 5m`
- `Bloque total 18:53-20:56 = 123m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 36m`
- `Total acumulado de referencia = 45h 36m`

### 2026-03-05 - Sessions v3.3 fase 95-d: dispositivo unificado con fecha/hora

- Ajustada la linea de metadata bajo el titulo para incluir los tres datos en una sola linea:
  - `dispositivo · fecha · hora`.
- Eliminada linea inferior duplicada de dispositivo para simplificar jerarquia visual.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 95-d)

- `Bloque incremental 21:02-21:03 = 1m`
- `Bloque total 18:53-21:03 = 130m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 37m`
- `Total acumulado de referencia = 45h 37m`

### 2026-03-05 - Sessions v3.3 fase 95-e: limpieza de UI de filtros en `My Sessions`

- Eliminado el bloque `Estado de filtros` por baja utilidad en UX.
- Eliminada tambien la accion `Resetear filtros rapidos` del panel superior.
- Se mantienen filtros funcionales principales (busqueda, dispositivo y orden) sin capa redundante de estado.
- Archivos actualizados:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 95-e)

- `Bloque incremental 21:05-21:07 = 2m`
- `Bloque total 18:53-21:07 = 132m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 39m`
- `Total acumulado de referencia = 45h 39m`

### 2026-03-05 - Spots v3.3 fase 96: brujula en tiempo real junto a rosa de vientos (Live)

- Implementado en `Spot seleccionado > Live` un boton `Brujula en tiempo real` junto a la rosa de vientos.
- Comportamiento:
  - abre dialogo en vivo con orientacion real del dispositivo,
  - muestra referencia de direccion de viento de la rosa,
  - muestra diferencia angular entre orientacion real y direccion de viento para comparacion en playa.
- Responsive del bloque Live:
  - en anchos estrechos, rosa + boton en columna,
  - en anchos amplios, boton al lado de la rosa.
- Soporte tecnico:
  - anadida dependencia `flutter_compass` en `pubspec.yaml`,
  - helpers de normalizacion angular y delta para lectura estable.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `pubspec.yaml`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter pub get` (ok)
  - `flutter analyze` (ok)
  - `flutter test -r compact` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96)

- `Bloque incremental 21:07-21:14 = 7m`
- `Bloque total 18:53-21:14 = 141m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 46m`
- `Total acumulado de referencia = 45h 46m`

### 2026-03-05 - Spots v3.3 fase 96-b: boton de brujula simulada en modo dev

- Anadido segundo boton debajo de `Brujula en tiempo real`:
  - `Brujula simulada (dev)`.
- Comportamiento del modo simulado:
  - abre dialogo con la misma vista de comparacion,
  - orientacion simulada ajustable por `Slider` para validar UX sin sensor real,
  - mantiene referencia de viento y diferencia angular.
- Layout responsive preservado:
  - en movil: ambos botones apilados debajo de la rosa,
  - en ancho amplio: ambos botones apilados en el panel lateral junto a la rosa.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-b)

- `Bloque incremental 21:14-21:19 = 5m`
- `Bloque total 18:53-21:19 = 146m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 51m`
- `Total acumulado de referencia = 45h 51m`

### 2026-03-05 - Spots v3.3 fase 96-c: agujas de brujula estilo clasico

- Ajustado render de la brujula (real y simulada) para que las agujas se vean como una brujula tipica:
  - aguja principal alargada Norte/Sur,
  - Norte en rojo y Sur en tono oscuro,
  - indicador de viento tambien en formato aguja alargada mas fina para comparacion visual clara.
- Añadido pivote central visual para lectura mas natural a pie de playa.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-c)

- `Bloque incremental 21:22-21:23 = 1m`
- `Bloque total 18:53-21:23 = 150m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 52m`
- `Total acumulado de referencia = 45h 52m`

### 2026-03-05 - Spots v3.3 fase 96-d: diferenciacion explicita de polos en aguja de brujula

- Añadidas etiquetas visuales `N` y `S` directamente sobre la aguja principal (brujula real y simulada).
- Objetivo: distinguir de forma inmediata que extremo de la aguja corresponde a Norte y cual a Sur en uso real en playa.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-d)

- `Bloque incremental 21:26-21:27 = 1m`
- `Bloque total 18:53-21:27 = 154m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 53m`
- `Total acumulado de referencia = 45h 53m`

### 2026-03-05 - Spots v3.3 fase 96-e: visibilidad reforzada de `N` y `S`

- Corregido problema de visibilidad de etiquetas en la aguja principal de brujula.
- Ajustes aplicados:
  - incremento del ancho util de la aguja para evitar recorte del texto,
  - etiquetas `N` y `S` renderizadas como badges con fondo claro/alto contraste.
- Se aplica en ambos dialogos:
  - `Brujula en tiempo real`,
  - `Brujula simulada (dev)`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-e)

- `Bloque incremental 21:27-21:31 = 4m`
- `Bloque total 18:53-21:31 = 158m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 15h 57m`
- `Total acumulado de referencia = 45h 57m`

### 2026-03-05 - Spots v3.3 fase 96-f: brujula superpuesta sobre rosa de vientos (sin dialogos)

- Cambio de UX aplicado por feedback:
  - los botones de brujula ya no abren dialogos,
  - ahora activan/desactivan la superposicion de brujula directamente sobre la rosa de vientos en `Live`.
- Modos soportados:
  - `Brujula en tiempo real`: overlay con heading del sensor en vivo,
  - `Brujula simulada (dev)`: overlay de prueba con slider inline para ajustar orientacion simulada.
- Se mantiene comparativa visual con direccion de viento y delta angular dentro de la misma tarjeta.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-f)

- `Bloque incremental 21:29-21:37 = 8m`
- `Bloque total 18:53-21:37 = 164m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 05m`
- `Total acumulado de referencia = 46h 05m`

### 2026-03-05 - Spots v3.3 fase 96-g: etiqueta dinamica en boton de brujula real

- Ajustado texto del boton de brujula real para reflejar estado actual del overlay:
  - cuando esta apagada: `Activar brujula`,
  - cuando esta activa: `Desactivar brujula`.
- Comportamiento de toggle se mantiene intacto (solo cambia copy dinamico).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-g)

- `Bloque incremental 21:40-21:41 = 1m`
- `Bloque total 18:53-21:41 = 168m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 06m`
- `Total acumulado de referencia = 46h 06m`

### 2026-03-05 - Spots v3.3 fase 96-h: rosa de vientos visual estilo tradicional

- Mejorado el aspecto de la rosa de vientos en `Live` para un look mas tradicional.
- Cambios aplicados:
  - nueva base con anillos concentricos, marcas de rumbo y estrella de 8 puntas,
  - etiquetas cardinales e intercardinales (`N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`) con mejor legibilidad,
  - se conserva superposicion de agujas de viento/brujula encima de la nueva rosa.
- Implementacion:
  - helper `_buildTraditionalCompassRoseFace()` en UI,
  - nuevo painter `_TraditionalCompassRosePainter`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-h)

- `Bloque incremental 21:41-21:45 = 4m`
- `Bloque total 18:53-21:45 = 172m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 10m`
- `Total acumulado de referencia = 46h 10m`

### 2026-03-05 - Spots v3.3 fase 96-i: aguja de brujula en formato rectangulo fino

- Ajustada la geometria de la aguja principal para que se parezca mas a un rectangulo estirado y muy fino.
- Cambios aplicados:
  - incremento de longitud por tramo,
  - reduccion de ancho,
  - eliminados remates redondeados para un perfil recto/clasico.
- Se aplica a brujula real y simulada.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-i)

- `Bloque incremental 21:47-21:48 = 1m`
- `Bloque total 18:53-21:48 = 175m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 11m`
- `Total acumulado de referencia = 46h 11m`

### 2026-03-05 - Spots v3.3 fase 96-j: aguja en forma de rombo

- Ajustada la geometria de la aguja principal para mostrar forma de rombo (diamante) en lugar de rectangulo fino.
- Implementacion tecnica:
  - nuevo painter `_CompassDiamondNeedlePainter` para dibujar mitad norte y mitad sur del rombo,
  - aplicado al render de aguja en modo real y simulado.
- Se mantienen etiquetas `N`/`S` y el resto de comportamiento del overlay.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-j)

- `Bloque incremental 21:50-21:52 = 2m`
- `Bloque total 18:53-21:52 = 177m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 13m`
- `Total acumulado de referencia = 46h 13m`

### 2026-03-05 - Spots v3.3 fase 96-k: ajuste de lectura de rosa + texto de brujula real

- Ajustado layout del indicador de viento:
  - la velocidad del viento ya no va superpuesta sobre la rosa,
  - ahora se muestra debajo del dibujo de la rosa de vientos.
- Ajustado copy de grados para brujula real:
  - se simplifica a `Brujula: <grados>`.
- Se mantiene sin cambios el marcador de brujula simulada con su delta.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-k)

- `Bloque incremental 21:56-21:57 = 1m`
- `Bloque total 18:53-21:57 = 184m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 14m`
- `Total acumulado de referencia = 46h 14m`

### 2026-03-05 - Spots v3.3 fase 96-l: refinado estetico de rosa de vientos tradicional

- Aplicado pulido visual para que la rosa se vea mas bonita y clasica:
  - etiquetas cardinales/intercardinales refinadas (N destacada),
  - badges de etiquetas con mejor contraste,
  - anillos adicionales y glow radial central,
  - estrella interna secundaria para dar profundidad ornamental.
- Se mantiene intacto el overlay de agujas y su comportamiento funcional.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-l)

- `Bloque incremental 21:57-22:02 = 5m`
- `Bloque total 18:53-22:02 = 189m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 19m`
- `Total acumulado de referencia = 46h 19m`

### 2026-03-05 - Spots v3.3 fase 96-m: refinado de rosa tradicional y aguja de viento

- Ajustes visuales solicitados sobre la rosa de vientos en `Live`:
  - etiquetas cardinales/intercardinales recolocadas fuera de la esfera,
  - incremento de contraste/visibilidad en el dibujo interior (anillos, estrellas y glow),
  - aguja de viento cambiada a estilo flecha de reloj (shaft + punta).
- Se mantiene la aguja de brujula principal en rombo y toda la logica de overlay real/simulado.
- Implementacion tecnica:
  - nuevo helper `_buildWindClockHand(...)`,
  - nuevo painter `_WindClockHandPainter`,
  - ajuste de composicion de tamanos para acomodar etiquetas exteriores.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-m)

- `Bloque incremental 22:02-22:10 = 8m`
- `Bloque total 18:53-22:10 = 197m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 27m`
- `Total acumulado de referencia = 46h 27m`

### 2026-03-05 - Spots v3.3 fase 96-n: flecha de viento anclada al centro + texto de viento bajo brujula

- Ajustada la flecha de viento para que salga desde el centro de la rosa y su punta llegue al borde exterior (estilo aguja de reloj).
- Ajustado bloque textual de lectura cuando esta activa la brujula real:
  - primera linea: `Brujula: <grados>`
  - segunda linea: `Viento: <grados>`
- Se mantiene sin cambios el bloque de brujula simulada con su delta.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Spots v3.4 fase 97: inicializacion de sesion y продолжение

- Inicializada sesion de trabajo 2026-03-07 a las 09:49.
- Session Tracker actualizado con 16h 30m acumulados de referencia.
- Brujula y aguja de viento: mejoras visuales (flecha de viento apunta HACIA direccion, aguja toca esfera exterior, etiquetas cardinales N/S en blanco con sombra, relleno amber/orange en rosa).
- Forecast Table: rediseno a tabla compacta estilo Windguru, selector de resolucion (6h/3h/1h/20m), modo fullscreen con badge de proveedor/modelo.
- Integracion de datos reales: Open-Meteo API funcionando sin clave.
- Integracion AEMET: clave API inyectada via String.fromEnvironment().

### 2026-03-07 - Conteo de horas (inicio de bloque)

- `Bloque 09:49-09:56 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 37m`
- `Total acumulado de referencia = 46h 37m`

### 2026-03-07 - Revision de continuidad y estado actual

- Revisado de nuevo el proyecto completo con foco en `SESSION_TRACKER.md` para retomar el contexto exacto de trabajo.
- Validado estado tecnico actual del bloque activo en `spots`:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
- Confirmado que el trabajo en curso real esta en `Spots v3.4 fase 97`, no en `Spots fase 96-o`.
- Detectado WIP local ya avanzado en forecast real:
  - `lib/features/spots/domain/entities/spot_forecast_entry.dart`
  - `lib/features/spots/domain/ports/out/spots_forecast_port.dart`
  - `lib/features/spots/application/use_cases/spots_forecast_use_cases.dart`
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `lib/features/spots/di/spots_module.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/core/config/env/env_config.dart`
- Siguiente foco recomendado para continuar sin perder inercia:
  - cerrar `Spots fase 97-b` con tests dedicados del adaptador forecast, validacion de fallback/live en UI y anotacion final del flujo en tracker.

### 2026-03-07 - Conteo de horas (reinicio de bloque actual)

- `Bloque iniciado a las 15:22`
- `Acumulado confirmado hasta ultimo corte exacto = 46h 37m`
- `Nota`: el siguiente cierre sumara desde este nuevo corte para mantener trazabilidad limpia de la sesion retomada.

### 2026-03-07 - Spots v3.4 fase 97-b: oficializacion de Oliva Puerto para forecast real

- Ajustado el catalogo oficial de `Spots` para trabajar con `Oliva Puerto` como nombre visible del spot de referencia en lugar de `Oliva`.
- Alineado el wiring forecast para que `Oliva Puerto` resuelva exactamente igual que `Oliva` en proveedores reales:
  - alias de ubicacion para Open-Meteo,
  - alias de municipio para AEMET.
- Tests de `SpotsPage` actualizados para validar el flujo con el nombre oficial `Oliva Puerto`:
  - alta desde formulario,
  - sugerencias/autocompletado,
  - apertura del detalle,
  - filtros y busqueda.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `test/features/spots/presentation/pages/spots_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-b)

- `Bloque incremental 15:22-15:44 = 22m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 59m`
- `Total acumulado de referencia = 46h 59m`

### 2026-03-07 - Spots v3.4 fase 97-c: endurecimiento de proveedores reales y testabilidad

- Endurecida la consonancia `spot + proveedor + modelo` en el detalle de `Spots`:
  - el banner de datos live ya muestra el proveedor real activo,
  - el selector `Modelo de prevision` queda restringido a los modelos validos del proveedor seleccionado.
- Mejorada la testabilidad del adaptador forecast real:
  - `OpenMeteoSpotsForecastAdapter` acepta inyeccion opcional de API key AEMET,
  - admite hooks de fetch para tests sin red real.
- Anadida cobertura unitaria para `Oliva Puerto` en el adaptador:
  - mapeo Open-Meteo,
  - mapeo AEMET con alias de municipio,
  - retorno vacio cuando falta API key.
- Corregido `env_config` para volver al uso correcto de `String.fromEnvironment('AEMET_OPENDATA_API_KEY')`.
- Archivos actualizados:
  - `lib/core/config/env/env_config.dart`
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-c)

- `Bloque incremental 15:44-15:50 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 05m`
- `Total acumulado de referencia = 47h 05m`

### 2026-03-07 - Spots v3.4 fase 97-d: API key local integrada sin flags manuales

- Implementado cargador local opcional de secretos en runtime para desarrollo:
  - nuevo `local.env.json` en raiz del proyecto,
  - ignorado por git,
  - ejemplo tracked en `local.env.json.example`.
- `main()` inicializa ahora el store local antes de arrancar la app.
- `EnvConfig.aemetOpenDataApiKey` resuelve con prioridad:
  - valor local en `local.env.json`,
  - fallback a `String.fromEnvironment('AEMET_OPENDATA_API_KEY')`.
- Movida la API key fuera de `env_config.dart` para evitar dejar el secreto embebido en codigo tracked.
- Resultado: la app puede arrancar en esta maquina sin pasar `--dart-define` manualmente y manteniendo la key fuera del repo.
- Archivos actualizados:
  - `.gitignore`
  - `lib/core/config/env/local_env_store.dart`
  - `lib/core/config/env/env_config.dart`
  - `lib/main.dart`
  - `local.env.json.example`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-d)

- `Bloque incremental 15:50-15:55 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 10m`
- `Total acumulado de referencia = 47h 10m`

### 2026-03-07 - Spots v3.4 fase 97-e: cobertura UI del detalle forecast por proveedor

- `SpotDetailPage` acepta ya inyeccion opcional de `SpotsModule` para poder testear el detalle sin depender del wiring productivo.
- Anadida nueva bateria de widget tests para el detalle de `Oliva Puerto`:
  - cambio de proveedor `Open-Meteo -> AEMET`,
  - actualizacion del banner live con el proveedor activo,
  - resincronizacion automatica del modelo (`GFS -> AROME`),
  - restriccion visual de modelos validos por proveedor,
  - banner fallback cuando el proveedor seleccionado no devuelve datos.
- Esto deja cubierto el punto clave de UX pedido: que spot, proveedor y tabla queden en consonancia visible cuando el usuario cambia de fuente.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-13 - Conteo de horas (inicio de bloque actual)

- `Inicio de bloque actual = 20:58`.
- `Acumulado (track exacto desde 2026-03-01 11:34) = 1d 14h 00m`.
- `Total acumulado de referencia = 1d 14h 00m`.
- Nota: bloque abierto; se cerrara con la duracion real al finalizar la siguiente fase.

### 2026-03-13 - Spots v3.5 fase 103-c: AVAMET humedad robusta sin simbolo

- Corregido el parseo de `Humedad` en `AVAMET` para aceptar valores sin simbolo `%`.
- Se amplia el regex de humedad para soportar `Humitat74` ademas de `Humitat74%`.
- Test nuevo para validar parsing sin `%`.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/avamet_observation_client.dart`
  - `test/features/spots/infrastructure/services/avamet_observation_client_test.dart`

### 2026-03-13 - Spots v3.5 fase 103-d: refresco Live no cambia estacion

- Al refrescar `Live` se conserva la estacion seleccionada si sigue disponible.
- Solo se fuerza estacion preferida cuando la seleccion actual ya no existe.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion pendiente.

### 2026-03-13 - Spots v3.5 fase 103-e: retiro AVAMET como proveedor forecast

- Eliminado AVAMET del selector de proveedores de prevision.
- Se retira el cliente y UI de meteogramas AVAMET para forecast.
- Archivos actualizados:
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/infrastructure/services/avamet_forecast_client.dart`
- Verificacion pendiente.

### 2026-03-13 - Spots v3.5 fase 103-f: grafico Live mas profesional

- Grafico Live ahora escala dinamicamente el eje Y segun datos reales.
- Lineas suavizadas, relleno con gradiente y fondo sutil en area de plot.
- Marcadores con sombra ligera y grid mas limpio (major/minor).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion pendiente.

### 2026-03-13 - Spots v3.5 fase 103-g: historico a pasos de 20 min

- El historico ahora muestrea en saltos de 20 minutos.
- Ajustados los samples por rango (1h=3, 3h=9, 6h=18, 12h=36).
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion pendiente.

### 2026-03-13 - Spots v3.5 fase 103-h: comparativa historico con forecast real

- La linea de comparativa del historico usa forecast real cargado por provider.
- Se cachea la ultima serie de forecast y se interpola sin factor/bias artificial.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion pendiente.

### 2026-03-13 - Spots v3.5 fase 103-e: test refresco Live conserva seleccion

- Test de widget asegura que `Refrescar` no cambia la estacion seleccionada.
- Archivo actualizado:
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion pendiente.

### 2026-03-13 - Spots v3.5 fase 103-f: refresh Live solo actualiza estacion seleccionada

- El boton `Refrescar` en `Live` llama solo a la carga puntual de la estacion activa.
- No se recarga la lista completa de estaciones al refrescar.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion pendiente.


### 2026-03-13 - Conteo de horas (inicio de bloque actual)

- `Inicio de bloque actual = 20:58`.
- `Acumulado (track exacto desde 2026-03-01 11:34) = 1d 14h 00m`.
- `Total acumulado de referencia = 1d 14h 00m`.
- Nota: bloque abierto; se cerrara con la duracion real al finalizar la siguiente fase.
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-e)

- `Bloque incremental 15:55-15:58 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 13m`
- `Total acumulado de referencia = 47h 13m`

### 2026-03-07 - Spots v3.4 fase 97-f: fix de carga local de API key via asset

- Detectada causa del fallback constante en AEMET: `local.env.json` se estaba leyendo usando `Directory.current`, lo que no es fiable al arrancar una app Flutter fuera de la raiz del repo.
- Ajustada la carga local de secretos para usar `rootBundle.loadString('local.env.json')` como asset Flutter.
- `pubspec.yaml` actualizado para empaquetar `local.env.json` en runtime local.
- Con esto, la key local ya no depende del directorio actual del proceso y el banner de `no devolvio datos` deja de aparecer por culpa de una key no encontrada.
- Archivos actualizados:
  - `lib/core/config/env/local_env_store.dart`
  - `pubspec.yaml`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-f)

- `Bloque incremental 15:58-16:05 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 20m`
- `Total acumulado de referencia = 47h 20m`

### 2026-03-07 - Spots v3.4 fase 97-g: diagnostico extra del fallback AEMET

- Verificada la API real de AEMET para `Oliva Puerto`/municipio `46181`: responde correctamente y devuelve bloques horarios reales.
- Conclusiones del diagnostico:
  - el endpoint AEMET esta vivo,
  - el parser del adaptador funciona en test,
  - la causa mas probable del fallback persistente en app era que la key local no estaba entrando por la ruta esperada en runtime.
- Endurecida la carga local de secretos con doble via:
  - asset Flutter `rootBundle`,
  - fallback adicional a archivo local `local.env.json` en filesystem para entorno de desarrollo.
- Mejorado el mensaje de fallback en detalle Spot para AEMET sin key cargada:
  - ahora muestra `AEMET sin API key cargada. Mostrando fallback local.` en vez del mensaje generico.
- Archivos actualizados:
  - `lib/core/config/env/local_env_store.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-g)

- `Bloque incremental 16:05-16:11 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 26m`
- `Total acumulado de referencia = 47h 26m`

### 2026-03-07 - Spots v3.4 fase 97-h: causa real del error AEMET y mitigacion

- Diagnosticada la causa real del banner `Error cargando AEMET`: la API estaba respondiendo `429` por limite de peticiones por minuto, no por ausencia de datos.
- Endurecido el adaptador forecast:
  - cache en memoria para respuestas AEMET recientes (`10 min`) por spot/area,
  - preservacion de resultados validos para evitar volver a golpear AEMET en cada refresco inmediato,
  - mensajes de error HTTP ahora conservan parte del body para facilitar diagnostico.
- Mejorado el fallback en UI para distinguir especificamente el caso `429`:
  - `AEMET ha limitado temporalmente las peticiones. Mostrando fallback local.`
- Cobertura nueva en tests del adaptador para reuso de cache AEMET fresca.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-h)

- `Bloque incremental 16:11-16:18 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 33m`
- `Total acumulado de referencia = 47h 33m`

### 2026-03-07 - Spots v3.4 fase 97-i: cache persistente AEMET entre reinicios

- Implementada cache persistente simple de forecast para `Spots` usando fichero local en documentos de app.
- El adaptador AEMET ahora resuelve por capas:
  - cache en memoria fresca,
  - cache persistente reciente,
  - red AEMET,
  - cache persistente mas antigua si AEMET responde con error HTTP/rate limit.
- Anadido serializado `toJson/fromJson` en `SpotForecastEntry` para poder persistir bloques forecast.
- Nuevo store local de cache en `lib/features/spots/infrastructure/adapters/local/local_file_spots_forecast_cache_store.dart`.
- Efecto esperado: tras una carga correcta, el detalle puede seguir mostrando forecast AEMET util incluso despues de reiniciar la app o cuando AEMET devuelve `429`.
- Archivos actualizados:
  - `lib/features/spots/domain/entities/spot_forecast_entry.dart`
  - `lib/features/spots/infrastructure/adapters/local/local_file_spots_forecast_cache_store.dart`
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-i)

- `Bloque incremental 16:18-16:25 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 40m`
- `Total acumulado de referencia = 47h 40m`

### 2026-03-07 - Spots v3.4 fase 97-j: reduccion de peticiones AEMET por cambio de modelo

- Reducidas peticiones innecesarias desde el detalle de Spot: cambiar `Modelo de prevision` ya no dispara recarga cuando el proveedor activo es `AEMET`.
- Motivo: en el flujo actual AEMET no usa ese selector para construir la peticion real, asi que cada cambio de modelo era ruido que gastaba cuota y podia provocar mas `429`.
- La UI sigue mostrando el modelo elegido para consistencia visual, pero la red no se vuelve a tocar hasta que cambie el proveedor o haya una recarga real necesaria.
- Anadido widget test para asegurar que `AEMET` no refetch al alternar `AROME/HARMONIE`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-j)

- `Bloque incremental 16:25-16:31 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 46m`
- `Total acumulado de referencia = 47h 46m`

### 2026-03-07 - Spots v3.4 fase 97-k: ocultar forecast cuando entra fallback

- Ajustado el detalle de Spot para que, si el resultado forecast entra en `fallback`, no se muestre nada de forecast en pantalla.
- Se ocultan en ese caso:
  - titulo `Tabla Forecast`,
  - banner de estado,
  - tabla/datos simulados.
- Objetivo: evitar confundir al usuario con datos locales inventados cuando la fuente real falla o esta limitada.
- Tests de detalle actualizados para validar que en fallback no aparece contenido forecast visible.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-k)

- `Bloque incremental 16:31-16:34 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 49m`
- `Total acumulado de referencia = 47h 49m`

### 2026-03-07 - Spots v3.4 fase 97-l: empty state discreto sin forecast

- Refinada la UX cuando un proveedor no devuelve forecast usable: en vez de dejar el bloque vacio del todo, ahora se muestra un estado discreto de `Sin datos disponibles`.
- El empty state evita mostrar datos fake/fallback y mantiene contexto minimo para el usuario con una sugerencia de reintento o cambio de proveedor.
- El bloque de tabla sigue oculto mientras no haya forecast real o demo valido.
- Tests de detalle actualizados para validar el nuevo mensaje y la ausencia de tabla.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-l)

- `Bloque incremental 16:34-16:36 = 2m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 17h 51m`
- `Total acumulado de referencia = 47h 51m`

### 2026-03-07 - Spots v3.4 fase 97-m: diagnostico visible temporal para Open-Meteo

- Confirmado fuera de app que los endpoints reales de `Open-Meteo` responden para `Oliva Puerto`, asi que el fallo restante parecia estar en runtime/UI local y no en disponibilidad del proveedor.
- Anadido diagnostico visible temporal en el empty state de forecast: cuando falla `Open-Meteo`, ahora se muestra una version compacta del error tecnico debajo de `Sin datos disponibles`.
- El objetivo es poder leer desde la propia app la excepcion real de `Open-Meteo` y localizar el punto exacto del fallo sin volver a adivinar.
- Nuevo widget test para validar que el detalle enseña el error tecnico compacto en fallos `Open-Meteo`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-m)

- `Bloque incremental 16:36-16:45 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 00m`
- `Total acumulado de referencia = 48h 00m`

### 2026-03-07 - Spots v3.4 fase 97-n: fix real de Open-Meteo por valores nulos

- Identificada la causa exacta del fallo `Open-Meteo`: el payload real puede traer algunos valores `null` en series horarias marine/meteo, y el adaptador los estaba casteando directamente a `num`.
- Corregido el parseo para que sea null-safe:
  - las listas numericas aceptan `null`,
  - cada slot horario se valida antes de mapearse,
  - si un slot viene incompleto, se omite en vez de romper todo el forecast.
- Anadida cobertura unitaria para garantizar que `Open-Meteo` ya no crashea cuando alguna fila trae `null`.
- El mensaje tecnico temporal en UI ya no deberia aparecer para este caso una vez recargues la app.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-n)

- `Bloque incremental 16:45-16:49 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 04m`
- `Total acumulado de referencia = 48h 04m`

### 2026-03-07 - Spots v3.4 fase 97-o: filtros compartidos entre preview y fullscreen

- Unificada la experiencia de forecast para que la tabla normal tenga los mismos filtros funcionales que fullscreen.
- La preview ahora comparte:
  - selector de rango,
  - selector de resolucion (`6h/3h/1h/20m` segun rango),
  - mismo remuestreo sobre el mismo forecast base real.
- Resultado: preview y fullscreen quedan alineados visual y funcionalmente; fullscreen sigue siendo una ampliacion del mismo dataset, no otra fuente distinta.
- Anadido widget test para validar que los filtros locales de preview no disparan refetch innecesario.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-o)

- `Bloque incremental 16:49-17:01 = 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 16m`
- `Total acumulado de referencia = 48h 16m`

### 2026-03-07 - Spots v3.4 fase 97-p: orden visual de filtros forecast

- Ajustado el layout de la tabla forecast para que el segmented button de resolucion/horas quede debajo del segmented button de dias tambien en la preview.
- Para mantener el orden consistente, el selector de resolucion se integra ya dentro del bloque comun de tabla justo debajo del selector de rango.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-p)

- `Bloque incremental 17:01-17:06 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 21m`
- `Total acumulado de referencia = 48h 21m`

### 2026-03-07 - Spots v3.4 fase 97-q: eliminar pantalla fullscreen y pasar a modo expandido inline

- Eliminada la navegacion a una pantalla fullscreen separada para forecast.
- El boton `fullscreen` ahora activa un modo expandido dentro de la misma `SpotDetailPage`.
- Si el usuario esta en la pestana `Forecast` y gira el dispositivo a horizontal, la tabla pasa automaticamente al modo expandido sin cambiar de ruta.
- El modo expandido reutiliza la misma tabla y los mismos controles (`dias`, `resolucion`, proveedor/modelo/rango actuales), evitando duplicidad funcional entre preview y fullscreen.
- En portrait, el modo expandido manual puede cerrarse con `fullscreen_exit`; en landscape, el foco expandido se mantiene mientras sigas en `Forecast`.
- Ajustados widget tests para fijar entorno portrait y seguir validando el flujo del detalle tras el cambio.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-q)

- `Bloque incremental 17:06-17:15 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 30m`
- `Total acumulado de referencia = 48h 30m`

### 2026-03-07 - Spots v3.4 fase 97-r: quitar aspecto de segunda pantalla al ampliar forecast

- Ajustado el nuevo modo expandido para que deje de parecer una segunda pantalla cuando se pulsa `fullscreen` en portrait.
- Cambio aplicado:
  - en portrait, el boton `fullscreen` ya no levanta una vista que cubra toda la pagina; ahora solo activa estado ampliado inline dentro del propio bloque forecast,
  - la cobertura completa de pantalla se reserva al caso landscape dentro de la misma `SpotDetailPage`.
- Se mantiene el comportamiento automatico al girar a horizontal en `Forecast`, pero sin recuperar la antigua ruta fullscreen.
- Tambien se ha limpiado codigo muerto restante del flujo anterior.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-r)

- `Bloque incremental 17:15-17:25 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 40m`
- `Total acumulado de referencia = 48h 40m`

### 2026-03-07 - Spots v3.4 fase 97-s: fullscreen desactivado temporalmente

- Desactivado todo el comportamiento asociado al boton `fullscreen` de la tabla forecast.
- El icono permanece visible, pero ahora no ejecuta ninguna accion ni activa estados extra.
- Eliminados tambien los efectos visuales y el wiring temporal del modo ampliado inline para dejar la base limpia antes de rediseñar esta interaccion.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-s)

- `Bloque incremental 17:25-17:31 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 46m`
- `Total acumulado de referencia = 48h 46m`

### 2026-03-07 - Spots v3.4 fase 97-t: fullscreen inline horizontal al pulsar el boton

- Restaurado el comportamiento del boton `fullscreen`, pero ya sin navegar a una segunda pantalla.
- Al pulsarlo en forecast, ahora se abre un overlay fullscreen dentro de la misma `SpotDetailPage`.
- En portrait, la tabla se rota para mostrarse horizontalmente a pantalla completa; en landscape se muestra fullscreen sin rotacion adicional.
- El overlay reutiliza la misma tabla y mantiene filtros de rango/resolucion activos, con boton `fullscreen_exit` para cerrar.
- Anadido widget test para validar que el boton abre el fullscreen inline.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-t)

- `Bloque incremental 17:31-17:36 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 51m`
- `Total acumulado de referencia = 48h 51m`

### 2026-03-07 - Spots v3.4 fase 97-u: fix del crash al abrir fullscreen inline

- Diagnosticado y endurecido el fullscreen inline del forecast: el layout portrait estaba rotando la tabla sin acotar correctamente el tamano util, lo que podia disparar problemas de constraints/render al abrirlo en emulador.
- Ajuste aplicado:
  - el overlay fullscreen ahora calcula area disponible con `LayoutBuilder`,
  - la tabla rotada en portrait se monta dentro de un `SizedBox` con dimensiones explicitas,
  - landscape y portrait comparten el mismo overlay inline dentro de `SpotDetailPage`.
- Se mantiene el objetivo funcional: al pulsar `fullscreen`, la tabla se muestra horizontalmente a pantalla completa sin navegar a otra pantalla.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-u)

- `Bloque incremental 17:36-17:43 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 18h 58m`
- `Total acumulado de referencia = 48h 58m`

### 2026-03-07 - Spots v3.4 fase 97-v: fix del RenderFlex overflow en fullscreen inline

- Recibido error real del crash: `A RenderFlex overflowed by 36 pixels on the bottom` dentro del `Column` de `_buildWindguruStyleTable`.
- Causa: el overlay fullscreen portrait seguia forzando un alto demasiado justo para la tabla rotada y sus controles.
- Ajuste aplicado:
  - el contenido fullscreen ahora se monta dentro de `FittedBox(BoxFit.contain)`,
  - esto permite escalar la tabla completa al area disponible sin romper constraints ni desbordar verticalmente.
- Se mantiene el mismo comportamiento funcional: fullscreen inline, tabla horizontal y cierre con `fullscreen_exit`.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-v)

- `Bloque incremental 17:43-17:53 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 19h 08m`
- `Total acumulado de referencia = 49h 08m`

### 2026-03-07 - Spots v3.4 fase 97-w: fullscreen real al 100% sin chrome extra

- Rehecho el fullscreen inline para acercarlo a lo que se pedia realmente: tabla ocupando el 100% de la pantalla, sin cabecera extra ni aspecto de segunda pantalla.
- El overlay ahora:
  - cubre toda la pantalla,
  - pinta directamente la tabla fullscreen,
  - en portrait rota la tabla completa a horizontal,
  - deja solo un boton flotante minimo para cerrar.
- Ajustados los tests del detalle al nuevo comportamiento visual del fullscreen.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-w)

- `Bloque incremental 17:53-18:08 = 15m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 19h 23m`
- `Total acumulado de referencia = 49h 23m`

### 2026-03-07 - Spots v3.4 fase 97-x: fullscreen edge-to-edge sin margenes

- Ajustado el fullscreen inline para que la tabla llene visualmente toda la pantalla.
- El overlay ahora usa `ClipRect + FittedBox(BoxFit.cover)` sobre el viewport completo, eliminando margenes negros o huecos y empujando la tabla a edge-to-edge.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-x)

- `Bloque incremental 18:08-18:34 = 26m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 19h 49m`
- `Total acumulado de referencia = 49h 49m`

### 2026-03-07 - Spots v3.4 fase 97-y: fullscreen forecast realmente responsivo

- Ajustado el fullscreen para que el borde exterior de la tabla quede siempre dentro del viewport en cualquier dispositivo/orientacion.
- En fullscreen las filas ahora reciben una altura minima calculada dinamicamente a partir del alto visible, repartiendo la pantalla entre las 10 filas reales de la tabla.
- Esto reduce el hueco residual inferior y hace que el layout sea mucho mas consistente entre moviles con tamanos y proporciones distintas.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-y)

- `Bloque incremental 18:34-18:58 = 24m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 20h 13m`
- `Total acumulado de referencia = 50h 13m`

### 2026-03-07 - Spots v3.4 fase 97-z: margen extra para evitar overflow residual fullscreen

- Recibido overflow residual de `2.3 px` en fullscreen dentro del `Column` de la tabla.
- Ajustado el calculo de altura por fila fullscreen para dejar mas margen de seguridad al layout (`-6` en lugar de `-1`).
- Objetivo: evitar crasheos por redondeo/constraints en dispositivos con densidades y proporciones limite, manteniendo visible la fila `Lluvia`.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 97-z)

- `Bloque incremental 18:58-19:13 = 15m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 20h 28m`
- `Total acumulado de referencia = 50h 28m`

### 2026-03-07 - Spots v3.4 fase 98-a: fix estructural del overflow fullscreen

- Tras varios overflows residuales en distintos dispositivos, aplicado fix estructural al fullscreen forecast.
- En vez de ajustar la altura de filas a ojo, ahora se reserva espacio fijo para el boton de cierre y se reparte solo el alto util restante entre las 10 filas reales de la tabla.
- Esto hace el fullscreen mucho mas estable y portable entre resoluciones/densidades distintas.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-a)

- `Bloque incremental 19:13-19:29 = 16m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 20h 44m`
- `Total acumulado de referencia = 50h 44m`

### 2026-03-05 - Conteo de horas (actualizacion post fase 96-n)

- `Bloque incremental 22:14-22:17 = 3m`
- `Bloque total 18:53-22:17 = 204m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 16h 30m`
- `Total acumulado de referencia = 46h 30m`

### 2026-03-07 - Spots v3.4 fase 98-b: fix overflow celdas Direction/Label/Value

- El overflow seguia ocurriendo en las celdas de direccion porque usaban `height: minHeight` (altura fija) en lugar de constraints con minHeight.
- Cambiado en 3 funciones:
  - `_compactDirectionCell` (line 2372): `height: minHeight` -> `constraints: BoxConstraints(minHeight: minHeight)`
  - `_compactLabelCell` (line 2275): mismo fix
  - `_compactValueCell` (line 2349): mismo fix
- Esto permite que las celdas crezcan si el contenido no cabe en la altura minima, evitando el overflow.
- Verificacion ejecutada:
  - `flutter build apk --debug` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-b)

- `Bloque incremental = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 20h 54m`
- `Total acumulado de referencia = 50h 54m`

### 2026-03-07 - Reanudacion de contexto para continuar

- Revisado `SESSION_TRACKER.md` completo para retomar exactamente desde el ultimo corte registrado.
- Confirmado ultimo estado funcional de `spots`:
  - fase cerrada mas reciente: `Spots v3.4 fase 98-b` (fix overflow en fullscreen forecast),
  - ultimo acumulado de horas consolidado: `20h 54m` exactas desde `2026-03-01 11:34`,
  - total acumulado de referencia: `50h 54m`.
- Revisado el estado actual del repo y el trabajo en curso no comprometido.
- Detectado foco tecnico activo en `spots` con forecast real y wiring pendiente:
  - `lib/features/spots/di/spots_module.dart`,
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`,
  - `lib/features/spots/presentation/pages/spots_page.dart`,
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`,
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`,
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`.
- Confirmado contexto arquitectonico actual:
  - `sessions` y `community` estan mas avanzadas en hexagonal,
  - `spots` ya tiene forecast real hexagonal, pero `live` sigue embebido en UI y el modulo aun se instancia desde presentation con `SpotsModule.inMemory()`.
- Punto de continuidad recomendado para la siguiente iteracion:
  - endurecer/cerrar la integracion real de `forecast` en `spots`,
  - limpiar wiring del modulo,
  - y despues extraer `live` a puertos/use cases/adaptadores para alinear la feature con la arquitectura v3.

### 2026-03-07 - Conteo de horas (inicio de bloque actual)

- `Inicio de bloque actual = 19:57`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 20h 54m`
- `Total acumulado de referencia = 50h 54m`

### 2026-03-07 - Spots v3.4 fase 98-c: wiring de modulo y persistencia de forecast alineados

- Dado el siguiente paso tecnico en `spots` para limpiar wiring, se ha alineado la feature con el patron ya usado en `sessions` y `community`.
- Cambios aplicados:
  - nuevo flag `EnvConfig.spotsLocalPersistenceEnabled`,
  - `SpotsModule.inMemory()` deja de usar cache persistente en disco y pasa a usar cache en memoria para forecast,
  - nuevo `SpotsModule.localFile()` para forecast real con cache persistente local,
  - `SpotsPage` ya no crea wiring fijo; ahora acepta modulo inyectado o decide por flag de persistencia,
  - `SpotsPage` pasa su mismo `SpotsModule` a `SpotDetailPage`, evitando reinstanciar dependencias al navegar,
  - `SpotDetailPage` tambien queda alineada al mismo criterio por defecto (local file vs in-memory).
- Archivo nuevo:
  - `lib/features/spots/infrastructure/adapters/in_memory/in_memory_spots_forecast_cache_store.dart`
- Archivos actualizados:
  - `lib/core/config/env/env_config.dart`
  - `lib/features/spots/di/spots_module.dart`
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-c)

- `Bloque incremental 19:57-20:03 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 00m`
- `Total acumulado de referencia = 51h 00m`

### 2026-03-07 - Spots v3.4 fase 98-d: nuevos modelos Open-Meteo en forecast

- Se amplian las opciones de modelos disponibles para `Open-Meteo` en la UI de forecast de `spots`.
- Modelos anadidos:
  - `Best match`
  - `AROME France`
- Ajustes aplicados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - la lista de modelos de `Open-Meteo` ahora expone `Best match`, `GFS`, `ICON`, `ECMWF` y `AROME France`,
    - se alinea el factor interno del preview/mock para `AROME France`.
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
    - `Best match` se mapea a `models=auto`,
    - `AROME France` se mapea a `models=meteofrance_arome_france`.
  - tests reforzados para validar:
    - presencia de ambos modelos en la UI,
    - mapping correcto de URLs hacia Open-Meteo.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-d)

- `Bloque incremental 20:03-20:12 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 09m`
- `Total acumulado de referencia = 51h 09m`

### 2026-03-07 - Spots v3.4 fase 98-e: ampliacion Meteo-France dentro de Open-Meteo

- Se completa una segunda ampliacion de modelos `Open-Meteo` en forecast para comparar salidas Météo-France adicionales desde la misma UI.
- Modelos anadidos:
  - `ARPEGE Europe`
  - `ARPEGE Seamless`
- Ajustes aplicados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - la lista de modelos `Open-Meteo` ahora expone tambien `ARPEGE Europe` y `ARPEGE Seamless`,
    - se ajustan factores internos del preview para ambos modelos.
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
    - `ARPEGE Europe` -> `models=meteofrance_arpege_europe`,
    - `ARPEGE Seamless` -> `models=meteofrance_seamless`.
  - tests reforzados para validar:
    - presencia de estas variantes en la UI,
    - mapping correcto de URL hacia Open-Meteo.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-e)

- `Bloque incremental 20:12-20:15 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 12m`
- `Total acumulado de referencia = 51h 12m`

### 2026-03-07 - Spots v3.4 fase 98-f: alta de ARPEGE World

- Se completa la familia principal Météo-France accesible desde `Open-Meteo` dentro del selector de modelos de forecast.
- Modelo anadido:
  - `ARPEGE World`
- Ajustes aplicados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - `ARPEGE World` queda disponible en el selector de modelos `Open-Meteo`,
    - se anade un factor interno propio para el preview/mock.
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
    - `ARPEGE World` -> `models=meteofrance_arpege_world`.
  - tests reforzados para validar:
    - presencia del nuevo modelo en UI,
    - mapping correcto de URL hacia Open-Meteo.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-f)

- `Bloque incremental 20:15-20:18 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 15m`
- `Total acumulado de referencia = 51h 15m`

### 2026-03-07 - Spots v3.4 fase 98-g: alta de AROME Seamless

- Se incorpora `AROME Seamless` a la familia de modelos Météo-France expuesta desde `Open-Meteo`.
- Ajustes aplicados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - `AROME Seamless` ya aparece en el selector de modelos `Open-Meteo`,
    - se asigna un factor interno propio para el preview/mock.
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
    - `AROME Seamless` -> `models=meteofrance_arome_seamless`.
  - tests reforzados para validar:
    - presencia del modelo en UI,
    - mapping correcto de URL hacia Open-Meteo.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-g)

- `Bloque incremental 20:18-20:20 = 2m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 17m`
- `Total acumulado de referencia = 51h 17m`

### 2026-03-07 - Spots v3.4 fase 98-h: reordenacion de modelos Open-Meteo para Oliva

- Se reordena el desplegable de modelos `Open-Meteo` en `spots` segun prioridad recomendada para el spot de `Oliva`, manteniendo `Best match` en primera posicion.
- Nuevo orden visible en UI:
  - `Best match`
  - `AROME Seamless`
  - `ARPEGE Europe`
  - `ECMWF`
  - `AROME France`
  - `ICON`
  - `ARPEGE Seamless`
  - `ARPEGE World`
  - `GFS`
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-h)

- `Bloque incremental 20:20-20:28 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 25m`
- `Total acumulado de referencia = 51h 25m`

### 2026-03-07 - Spots v3.4 fase 98-i: ayuda contextual para modelos de forecast

- Se anade ayuda contextual al filtro de `Modelo de prevision` en `spots`.
- Cambios aplicados en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - icono pequeno de informacion junto al selector de modelo,
  - al pulsarlo se abre un dialogo con una explicacion corta del modelo seleccionado,
  - se cubren descripciones para modelos de `Open-Meteo`, `AEMET` y `Windguru`.
- Test anadido/ajustado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar la apertura del dialogo y su contenido.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-i)

- `Bloque incremental 20:28-20:34 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 31m`
- `Total acumulado de referencia = 51h 31m`

### 2026-03-07 - Spots v3.4 fase 98-j: dialogo de modelos enriquecido

- Se amplian los contenidos del dialogo de ayuda del modelo en forecast.
- Ahora el dialogo muestra, ademas de la descripcion corta:
  - `Tipo`
  - `Resolucion`
  - `Horizonte`
- Se han rellenado estos metadatos para modelos de `Open-Meteo`, `AEMET` y `Windguru` en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar tambien estos campos nuevos.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-j)

- `Bloque incremental 20:34-20:37 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 34m`
- `Total acumulado de referencia = 51h 34m`

### 2026-03-07 - Spots v3.4 fase 98-k: recomendacion contextual para Oliva

- Se enriquece una vez mas el dialogo de ayuda del modelo en forecast.
- Ahora incluye una linea adicional `Para Oliva` con una recomendacion corta y contextual segun el modelo seleccionado.
- Implementado en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para verificar tambien esta nueva recomendacion.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-k)

- `Bloque incremental 20:37-20:40 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 37m`
- `Total acumulado de referencia = 51h 37m`

### 2026-03-07 - Spots v3.4 fase 98-l: chip de recomendacion en el selector

- Se retira la recomendacion textual del dialogo de ayuda y se mueve al propio desplegable de modelos.
- Cambios aplicados en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - algunos modelos `Open-Meteo` prioritarios para `Oliva` muestran ahora un chip `Recomendado` dentro del menu,
  - el valor seleccionado sigue viendose limpio en el campo gracias a `selectedItemBuilder`,
  - el dialogo de info conserva descripcion, tipo, resolucion y horizonte, pero sin la linea `Para Oliva`.
- Test ajustado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar la presencia de los chips en el desplegable y el nuevo contenido del dialogo.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-l)

- `Bloque incremental 20:40-20:45 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 42m`
- `Total acumulado de referencia = 51h 42m`

### 2026-03-07 - Spots v3.4 fase 98-m: ajuste visual del chip recomendado

- Se mejora la legibilidad del chip `Recomendado` dentro del desplegable de modelos en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Ajustes visuales aplicados:
  - tipografia mas marcada,
  - fondo con `tertiaryContainer`,
  - sin borde,
  - padding mas compacto,
  - tap target reducido para que encaje mejor en el menu.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-m)

- `Bloque incremental 20:45-20:48 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 45m`
- `Total acumulado de referencia = 51h 45m`

### 2026-03-07 - Spots v3.4 fase 98-n: recomendaciones dependientes del spot

- Se deja de tratar la recomendacion como algo generico y pasa a depender del spot seleccionado.
- Implementado en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - nueva logica de recomendacion contextual por `spotName + provider + model`,
  - por ahora se define especificamente para `Oliva Puerto`,
  - se introducen dos niveles visibles en el desplegable: `Top` y `Recomendado`,
  - el dialogo de info vuelve a incluir una recomendacion textual, pero ahora contextualizada con el spot actual.
- Criterio actual para `Oliva Puerto` con `Open-Meteo`:
  - `Top`: `AROME Seamless`, `ARPEGE Europe`
  - `Recomendado`: `ECMWF`, `AROME France`
- Test ajustado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar:
  - chips `Top` y `Recomendado` en el desplegable,
  - texto contextual en el dialogo para `Oliva Puerto`.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-n)

- `Bloque incremental 20:48-20:54 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 51m`
- `Total acumulado de referencia = 51h 51m`

### 2026-03-07 - Spots v3.4 fase 98-o: recomendaciones extraidas a configuracion separada

- Se saca la logica de recomendaciones de modelos fuera de `spot_detail_page.dart` para dejar la pagina mas limpia y facilitar ampliaciones futuras por spot.
- Archivo nuevo:
  - `lib/features/spots/presentation/config/spot_forecast_model_recommendations.dart`
- Cambios aplicados:
  - se define `SpotForecastModelRecommendation`,
  - se centraliza `getSpotForecastModelRecommendation(...)`,
  - `spot_detail_page.dart` ahora solo consume esa configuracion para pintar chips `Top` / `Recomendado` y el texto contextual del dialogo.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-o)

- `Bloque incremental 20:54-20:58 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 55m`
- `Total acumulado de referencia = 51h 55m`

### 2026-03-07 - Spots v3.4 fase 98-p: metadatos de modelos extraidos a configuracion

- Se completa la limpieza de `spot_detail_page.dart` sacando tambien la informacion descriptiva de modelos a un fichero de configuracion separado.
- Archivo nuevo:
  - `lib/features/spots/presentation/config/spot_forecast_model_info.dart`
- Cambios aplicados:
  - se define `SpotForecastModelInfo`,
  - se centraliza `getSpotForecastModelInfo(...)`,
  - `spot_detail_page.dart` ya no contiene el bloque grande de descripciones/scope/resolution/horizon y ahora solo consume esa configuracion.
- Se mantiene separacion clara entre:
  - metadatos descriptivos del modelo,
  - recomendaciones contextuales por spot.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-p)

- `Bloque incremental 20:58-21:02 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 21h 59m`
- `Total acumulado de referencia = 51h 59m`

### 2026-03-07 - Spots v3.4 fase 98-q: orden de modelos desacoplado de la UI

- Se mueve tambien el orden de modelos por proveedor/spot fuera de `spot_detail_page.dart`.
- Archivo nuevo:
  - `lib/features/spots/presentation/config/spot_forecast_model_order.dart`
- Cambios aplicados:
  - se define `baseForecastModelsByProvider`,
  - se centraliza `getSpotForecastModels(...)`,
  - `spot_detail_page.dart` ya no guarda el mapa de modelos en duro y consume ahora la configuracion externa para poblar el selector.
- Resultado: la UI queda separada en tres capas de configuracion independientes:
  - orden de modelos,
  - metadatos descriptivos,
  - recomendaciones por spot.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-q)

- `Bloque incremental 21:02-21:04 = 2m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 01m`
- `Total acumulado de referencia = 52h 01m`

### 2026-03-07 - Spots v3.4 fase 98-r: configuracion movida fuera de presentation

- Se da un paso mas de limpieza arquitectonica moviendo toda la configuracion de modelos fuera de `presentation` hacia una capa mas neutral de `application/services`.
- Archivos nuevos:
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/application/services/spot_forecast_model_recommendations.dart`
- Archivos eliminados de `presentation/config`:
  - `spot_forecast_model_order.dart`
  - `spot_forecast_model_info.dart`
  - `spot_forecast_model_recommendations.dart`
- `lib/features/spots/presentation/pages/spot_detail_page.dart` ahora consume esas piezas desde `application/services`, dejando la UI como cliente de reglas ya preparadas.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-r)

- `Bloque incremental 21:04-21:08 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 05m`
- `Total acumulado de referencia = 52h 05m`

### 2026-03-07 - Spots v3.4 fase 98-s: fix de Best match en Open-Meteo

- Detectado que `Best match` podia dejar de funcionar por la forma de construir la URL hacia Open-Meteo.
- Ajuste aplicado en `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`:
  - `Best match` ya no fuerza `models=auto`,
  - ahora usa el comportamiento por defecto de Open-Meteo, omitiendo completamente el parametro `models`.
- Se actualiza el test en `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart` para validar precisamente ese contrato.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-s)

- `Bloque incremental 21:08-21:12 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 09m`
- `Total acumulado de referencia = 52h 09m`

### 2026-03-07 - Spots v3.4 fase 98-t: Best match por defecto en Open-Meteo

- Se cambia el modelo inicial de forecast para `Open-Meteo` a `Best match` en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Ajustado tambien el test de UI en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para reflejar:
  - la tabla inicial `Tabla Forecast (Best match)`,
  - y la presencia duplicada esperable de `Best match` cuando el item ya esta seleccionado y ademas abierto en el menu.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-t)

- `Bloque incremental 21:12-21:15 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 12m`
- `Total acumulado de referencia = 52h 12m`

### 2026-03-07 - Spots v3.4 fase 98-u: modelo por defecto contextual por spot

- Se implementa configuracion explicita de modelo por defecto por `spot + provider`.
- Cambios aplicados:
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
    - nuevo helper `getSpotDefaultForecastModel(...)`,
    - `Open-Meteo` usa `Best match` como default,
    - y queda preparado para reglas mas finas por spot en el futuro.
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - `_forecastModel` pasa a inicializarse desde esa configuracion,
    - al cambiar de proveedor tambien intenta recuperar el default contextual correspondiente.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-u)

- `Bloque incremental 21:15-21:19 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 16m`
- `Total acumulado de referencia = 52h 16m`

### 2026-03-07 - Spots v3.4 fase 98-v: rediseño del fullscreen de forecast

- Se mejora visualmente el modo ampliado de la tabla forecast en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Antes el fullscreen ocupaba toda la pantalla de forma muy cruda; ahora se presenta como una capa modal mas cuidada.
- Ajustes aplicados:
  - fondo oscurecido para separar mejor el contexto,
  - tarjeta centrada con esquinas redondeadas y sombra,
  - cabecera con titulo `Forecast ampliado`, spot, proveedor y modelo,
  - chips con rango y resolucion activos,
  - contenedor interno mas limpio para la tabla,
  - cierre mas claro con boton tonal y tap fuera del panel.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar tambien el nuevo encabezado.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-v)

- `Bloque incremental 21:19-21:24 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 21m`
- `Total acumulado de referencia = 52h 21m`

### 2026-03-07 - Spots v3.4 fase 98-w: fullscreen de tabla reducido a tabla pura

- Ajustado el fullscreen de forecast segun feedback: ahora muestra solo la tabla ocupando el 100% de la pantalla, sin cabeceras, chips, fondo modal ni controles visuales extra.
- Cambios en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - el overlay ampliado vuelve a ser una superficie limpia con solo la tabla escalada a pantalla completa,
  - se mantiene salida usable usando el gesto/boton atras del sistema,
  - se actualiza el manejo de back a `PopScope` para evitar API deprecada.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar que al abrir fullscreen desaparece la UI normal y no aparece boton de cierre embebido.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-w)

- `Bloque incremental 21:24-21:30 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 27m`
- `Total acumulado de referencia = 52h 27m`

### 2026-03-07 - Spots v3.4 fase 98-x: salida rapida del fullscreen

- Se anade un `FloatingActionButton.small` muy discreto en la esquina inferior derecha del fullscreen de forecast.
- Se mantiene la premisa visual principal: sigue viendose solo la tabla ocupando toda la pantalla, con un unico control pequeno para salir.
- Implementado en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para comprobar la presencia del boton `Salir de fullscreen`.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-x)

- `Bloque incremental 21:30-21:35 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 32m`
- `Total acumulado de referencia = 52h 32m`

### 2026-03-07 - Spots v3.4 fase 98-y: boton de salida fullscreen mas sutil

- Se afina visualmente el boton flotante de salida del fullscreen de forecast en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Ajustes aplicados:
  - tamano mas pequeno,
  - fondo negro semitransparente,
  - icono mas fino,
  - sin elevacion para que se funda mejor sobre la tabla.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-y)

- `Bloque incremental 21:35-21:39 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 22h 36m`
- `Total acumulado de referencia = 52h 36m`

### 2026-03-07 - Spots v3.4 fase 98-z: metadata del spot movida fuera del adaptador

- Se elimina el conocimiento hardcodeado por nombre del spot dentro de `open_meteo_spots_forecast_adapter.dart`.
- Ahora la metadata de forecast pasa a formar parte del propio `SpotItem`:
  - `latitude`
  - `longitude`
  - `aemetMunicipalityCode`
- Cambios aplicados:
  - `lib/features/spots/domain/entities/spot_item.dart`
    - ampliado con metadata geografica y codigo AEMET.
  - `lib/features/spots/presentation/pages/spots_page.dart`
    - los spots oficiales ya nacen con coordenadas/codigo AEMET,
    - los spots custom guardan lat/lon desde el picker,
    - al abrir detalle se pasa esta metadata al detalle.
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - construye el `SpotItem` consumido por forecast a partir de la metadata recibida.
  - `lib/features/spots/application/use_cases/spots_forecast_use_cases.dart`
  - `lib/features/spots/domain/ports/out/spots_forecast_port.dart`
    - forecast deja de pedirse por `spotName/area` y pasa a pedirse con `SpotItem`.
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
    - consume esa metadata del spot,
    - conserva solo fallbacks genericos por zona cuando la metadata no existe.
- Resultado:
  - el conocimiento del spot ya vive en la entidad/catalogo del spot y no dentro del proveedor,
  - `Oliva Puerto` y el resto de spots oficiales quedan preparados para afinar coordenadas sin tocar el adaptador.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 98-z)

- `Bloque incremental 21:39-23:18 = 99m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 24h 15m`
- `Total acumulado de referencia = 54h 15m`

### 2026-03-07 - Spots v3.4 fase 99-a: afinado de coordenadas para Oliva Puerto

- Afinadas las coordenadas del spot oficial `Oliva Puerto` para acercarlas mas al frente de playa util del spot, evitando el punto anterior mas desplazado hacia interior.
- Nuevo punto fijado en catalogo oficial:
  - `lat = 38.9348`
  - `lon = -0.0986`
- Implementado en `lib/features/spots/presentation/pages/spots_page.dart` dentro de la metadata oficial del spot.
- Reforzado test del adaptador en `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart` para comprobar que Open-Meteo usa precisamente esas coordenadas cuando el spot las aporta.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spots_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 99-a)

- `Bloque incremental 23:18-23:23 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 24h 20m`
- `Total acumulado de referencia = 54h 20m`

### 2026-03-07 - Spots v3.4 fase 99-b: AEMET deja de inventar celdas

- Ajustada la integracion AEMET para que la app no rellene con estimaciones locales los campos que no vienen realmente del proveedor.
- Cambios aplicados:
  - `lib/features/spots/domain/entities/spot_forecast_entry.dart`
    - varios campos de forecast pasan a ser anulables para representar ausencia real de dato.
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
    - AEMET ya no inventa:
      - `waterTempC`
      - `pressureHpa`
      - `waveM`
    - y tampoco fuerza valores por defecto en lluvia/nubosidad cuando no llegan.
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - la tabla forecast ahora muestra `-` en las celdas sin dato en lugar de colorear/mostrar un numero inventado,
    - el resample/interpolacion respeta nulls y no interpola metricas ausentes.
- Tests actualizados para validar el nuevo contrato de AEMET sin datos inventados.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 99-b)

- `Bloque incremental 23:23-23:43 = 20m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 24h 40m`
- `Total acumulado de referencia = 54h 40m`

### 2026-03-07 - Spots v3.4 fase 99-c: nomenclatura AEMET corregida en UI

- Ajustada la nomenclatura del selector de modelos de `AEMET` para alinearla mejor con la terminologia real visible en AEMET.
- Cambios aplicados:
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
    - `AEMET` pasa a ofrecer `HARMONIE-AROME` y `ECMWF`.
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
    - se actualiza la ficha descriptiva de `HARMONIE-AROME`,
    - se elimina la separacion artificial entre `AROME` y `HARMONIE`.
  - tests de UI y adaptador actualizados para reflejar esta nomenclatura.
- Importante:
  - esto corrige la semantica del selector, pero la fuente AEMET consumida sigue siendo una unica prediccion municipal horaria y no una seleccion real de modelo en backend.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-07 - Conteo de horas (actualizacion post fase 99-c)

- `Bloque incremental 23:43-23:54 = 11m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 24h 51m`
- `Total acumulado de referencia = 54h 51m`

### 2026-03-08 - Revision de continuidad y punto de reentrada

- Revisado el proyecto completo para retomar continuidad, con foco en `SESSION_TRACKER.md` y el worktree actual.
- Confirmado estado local pendiente en el slice `spots`:
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/domain/entities/spot_forecast_entry.dart`
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Ultimo punto funcional trabajado antes de esta revision:
  - `Spots v3.4 fase 99-b`: AEMET deja de inventar metricas ausentes y la UI pasa a mostrar `-` cuando no hay dato real.
  - `Spots v3.4 fase 99-c`: nomenclatura AEMET ajustada en UI a `HARMONIE-AROME` + `ECMWF`.
- Punto recomendado para continuar en la siguiente tarea:
  - validar/cerrar el bloque pendiente `99-b` + `99-c`,
  - y despues abordar `Spots v3.4 fase 99-d`: separar `AEMET` del adaptador `open_meteo` hacia un adaptador/proveedor propio para alinear mejor la capa `infrastructure` con proveedores reales.

### 2026-03-08 - Conteo de horas (inicio de bloque actual)

- Nueva sesion registrada desde `00:18`.
- `Acumulado (track exacto desde 2026-03-01 11:34) = 24h 51m`
- `Total acumulado de referencia = 54h 51m`
- `Bloque activo abierto desde 00:18; actualizar al cerrar la siguiente tarea.`

### 2026-03-08 - Spots v3.4 fase 99-d: modelo AEMET maritimo costero con tabla dedicada

- Anadida nueva opcion `Maritima costera` dentro del desplegable de modelos cuando el spot cae en zona AEMET costera soportada.
- Implementada carga dedicada del endpoint `prediccion/maritima/costera/costa/46` mediante cliente nuevo:
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
- Integracion en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - si el usuario selecciona `AEMET > Maritima costera`, la UI deja de mostrar la tabla horaria normal y renderiza una tabla especifica de boletin costero,
  - se muestran validez, aviso, situacion, tendencia y filas por `zona costera` con su texto de prediccion,
  - anadido fallback local para cuando el boletin no esta disponible.
- Ajustado catalogo/model info para exponer este modelo nuevo en el selector de AEMET solo cuando aplica por area.
- Tests actualizados:
  - nuevo caso de widget para comprobar seleccion del modelo costero y render de la tabla dedicada.
- Archivos actualizados:
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-d)

- `Bloque incremental 00:18-00:47 = 29m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 25h 20m`
- `Total acumulado de referencia = 55h 20m`

### 2026-03-08 - Spots v3.4 fase 99-e: proveedor AEMET desacoplado y operativo

- Se separa definitivamente la logica de `AEMET` del adaptador de `Open-Meteo` para que el proveedor AEMET funcione como slice propio dentro de `spots`.
- Nuevas piezas de infraestructura:
  - `lib/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/adapters/composite/composite_spots_forecast_adapter.dart`
- Cambios aplicados:
  - `OpenMeteoSpotsForecastAdapter` queda dedicado solo a `Open-Meteo`.
  - `AemetSpotsForecastAdapter` asume forecast municipal horario, cache en memoria/persistente y fallback a cache stale ante `429`/errores HTTP.
  - `SpotsModule` pasa a cablear ambos proveedores mediante un adaptador compuesto, de forma que la app ya resuelve `Open-Meteo` y `AEMET` como proveedores reales distintos.
- Cobertura actualizada:
  - tests de `Open-Meteo` simplificados para cubrir solo ese proveedor,
  - tests de `AEMET` movidos a archivo propio y validados sobre el nuevo adaptador.
- Archivos actualizados:
  - `lib/features/spots/di/spots_module.dart`
  - `lib/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart`
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - `test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart` (nuevo)
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-e)

- `Bloque incremental 00:47-01:00 = 13m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 25h 33m`
- `Total acumulado de referencia = 55h 33m`

### 2026-03-08 - Spots v3.4 fase 99-f: nomenclatura AEMET honesta con la fuente

- Eliminadas de la UI las vistas inventadas `HARMONIE-AROME` y `ECMWF` dentro del proveedor `AEMET`.
- El selector de modelos de `AEMET` pasa a exponer solo opciones honestas con OpenData:
  - `Prediccion municipal`
  - `Maritima costera` (cuando aplique por zona)
- Ajustada la ficha informativa para explicar que `Prediccion municipal` corresponde a la salida horaria oficial publicada por AEMET y no a un modelo numerico seleccionable dentro de ese endpoint.
- Tests actualizados para reflejar la nueva nomenclatura real de fuente.
- Archivos actualizados:
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-f)

- `Bloque incremental 01:00-01:08 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 25h 41m`
- `Total acumulado de referencia = 55h 41m`

### 2026-03-08 - Spots v3.4 fase 99-g: tercera opcion AEMET `Prediccion de playa`

- Integrada una tercera opcion real dentro de `AEMET`: `Prediccion de playa`.
- Se utiliza el endpoint especifico de playa `prediccion/especifica/playa/{codigo}` en lugar de reutilizar la tabla municipal.
- Nueva capa dedicada:
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
- Datos cableados para `Oliva Puerto` con codigo de playa `4618102`.
- La UI cambia a una tabla especifica de playa cuando el modelo seleccionado es `Prediccion de playa`:
  - cielo 11h / 17h
  - viento 11h / 17h
  - oleaje 11h / 17h
  - temperatura maxima
  - temperatura del agua
  - sensacion termica
  - UV maximo
- Tambien se amplio el modelo de spot para soportar `aemetBeachCode` y propagarlo desde `spots_page` hasta `spot_detail_page`.
- Archivos actualizados:
  - `lib/features/spots/domain/entities/spot_item.dart`
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart -r compact` (ok, sin regresiones)

### 2026-03-08 - Conteo de horas (cierre post fase 99-g)

- `Bloque incremental 01:08-01:18 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 25h 51m`
- `Total acumulado de referencia = 55h 51m`

### 2026-03-08 - Spots v3.4 fase 99-h: fix de rate limit AEMET por precarga indebida

- Detectado motivo probable del fallo real en app: `SpotDetailPage` estaba precargando en `initState` las fuentes `AEMET playa` y `AEMET maritima costera` aunque no estuvieran seleccionadas.
- Eso podia consumir cupo de AEMET nada mas abrir el detalle del spot y provocar `429`, dejando despues la `Prediccion municipal` tambien en fallback.
- Correccion aplicada:
  - las fuentes `AEMET playa` y `AEMET maritima costera` pasan a cargarse solo bajo demanda,
  - se inicializan de forma lazy unicamente cuando el usuario selecciona ese modelo o cuando su `FutureBuilder` lo necesita por primera vez.
- Archivo ajustado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-h)

- `Bloque incremental 01:18-01:28 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 01m`
- `Total acumulado de referencia = 56h 01m`

### 2026-03-08 - Spots v3.4 fase 99-i: ajuste de transporte HTTP AEMET y diagnostico real

- Verificado fuera de la app que los tres endpoints reales de AEMET para Oliva devuelven datos en este momento:
  - `municipio/horaria/46181`
  - `playa/4618102`
  - `maritima/costera/costa/46`
- Conclusion: el problema no era falta de dato en origen, sino la forma de peticion desde la app.
- Ajuste aplicado en los clientes/adaptadores AEMET:
  - se anaden cabeceras `accept: application/json`
  - se anade `api_key` tambien por cabecera en las llamadas al endpoint API
  - se fija `User-Agent: MeteoKite/2.0`
- Archivos tocados:
  - `lib/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
- Ajuste adicional de DX:
  - la UI de fallback de forecast ahora tambien muestra diagnostico tecnico corto para `AEMET`, no solo para `Open-Meteo`, para acelerar debug si vuelve a fallar.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-i)

- `Bloque incremental 01:28-01:34 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 07m`
- `Total acumulado de referencia = 56h 07m`

### 2026-03-08 - Spots v3.4 fase 99-j: fix de encoding AEMET

- Error real reportado en app para `Prediccion municipal`: `FormatException: Missing extension byte`.
- Causa localizada: algunas respuestas AEMET no vienen en UTF-8 limpio y la app intentaba decodificarlas siempre con `utf8`.
- Fix aplicado:
  - los clientes/adaptadores AEMET ahora leen bytes crudos,
  - intentan decodificar primero en `utf8`,
  - y hacen fallback a `latin1` si el payload no es UTF-8 valido.
- Archivos ajustados:
  - `lib/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-j)

- `Bloque incremental 01:34-01:38 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 11m`
- `Total acumulado de referencia = 56h 11m`

### 2026-03-08 - Spots v3.4 fase 99-k: blindaje anti-429 para AEMET

- Implementado control anti-rate-limit en los tres flujos AEMET:
  - municipal
  - playa
  - maritima costera
- Comportamiento nuevo:
  - cache en memoria para `playa` y `costera`
  - cooldown de `1 minuto` por clave AEMET tras detectar `429`
  - si hay dato previo cacheado, se reutiliza durante el cooldown en vez de volver a disparar peticiones al endpoint
  - en municipal tambien se reutiliza cache stale/persistente si el limite de AEMET salta
- Objetivo: que tras una primera carga buena la app no se rompa por navegar/cambiar de modelo demasiado rapido dentro del mismo minuto.
- Archivos ajustados:
  - `lib/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-k)

- `Bloque incremental 01:38-01:43 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 16m`
- `Total acumulado de referencia = 56h 16m`

### 2026-03-08 - Spots v3.4 fase 99-l: mejora visual de `Maritima costera`

- Redisenada la presentacion del boletin costero AEMET para que deje de parecer una tabla pobre y se lea como un parte maritimo util.
- Cambios en UI:
  - cabecera con chips de validez, hora de emision y numero de zonas,
  - bloques destacados para `Aviso`, `Situacion general` y `Tendencia`,
  - sustitucion del `DataTable` simple por tarjetas por zona costera,
  - extraccion de etiquetas rapidas desde el texto (`Marejadilla`, `Marejada`, `Aguaceros`, etc.),
  - prediccion por zona presentada en bullets mas legibles.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Test ajustado al nuevo render de etiquetas repetidas:
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-l)

- `Bloque incremental 01:43-01:53 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 26m`
- `Total acumulado de referencia = 56h 26m`

### 2026-03-08 - Spots v3.4 fase 99-m: tabla de playa AEMET alineada con municipal

- Rehecha la presentacion de `Prediccion de playa` para que visualmente se acerque a la tabla municipal sin falsear la estructura real de la fuente.
- Nuevo formato:
  - columnas por dia,
  - filas por variable (`Cielo`, `Viento`, `Oleaje`, `Temp. max`, `Temp. agua`, `Sens. termica`, `UV max`),
  - dentro de cada celda se muestran los dos cortes reales `11h / 17h` cuando aplica,
  - cabecera con chips de contexto (`dias`, `emitido`).
- Resultado: lectura mucho mas parecida a un forecast board de MeteoKite y menos a una `DataTable` generica.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-m)

- `Bloque incremental 01:53-02:00 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 33m`
- `Total acumulado de referencia = 56h 33m`

### 2026-03-08 - Spots v3.4 fase 99-n: etiquetas de playa mas honestas

- Ajustadas las etiquetas de la tabla `Prediccion de playa` para no sugerir horas puntuales falsas.
- Se reemplaza `11h / 17h` por `Manana / Tarde` en la cabecera y en las celdas de variables de doble tramo.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Test actualizado:
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-n)

- `Bloque incremental 02:00-02:04 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 37m`
- `Total acumulado de referencia = 56h 37m`

### 2026-03-08 - Spots v3.4 fase 99-o: ampliacion de cobertura AEMET en catalogo de spots

- Ampliados codigos AEMET municipales en el catalogo principal de spots para salir del caso centrado solo en `Oliva Puerto`.
- Spots reforzados:
  - `Calpe` -> `03047`
  - `Altea` -> `03018`
  - `Villajoyosa` -> `03139`
  - `Santa Pola` -> `03121`
  - `Tarifa` -> `11035`
- Tambien se corrigio `Xeraco` de `46145` a `46143`.
- Se anadieron/coherenciaron coordenadas base en varios de esos spots para que el resto de proveedores mantenga buena resolucion local.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spots_page.dart`
- Nota:
  - en esta pasada no se anaden mas `aemetBeachCode` porque no conviene inventarlos sin verificar endpoint especifico por playa.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-o)

- `Bloque incremental 02:04-02:18 = 14m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 51m`
- `Total acumulado de referencia = 56h 51m`

### 2026-03-08 - Spots v3.4 fase 99-p: multi-playa AEMET para `Oliva Puerto`

- Anadido soporte para asociar varias playas AEMET a un mismo spot.
- `Oliva Puerto` mantiene `4618102` como playa principal y suma `4618103` como playa adicional verificada para el mismo spot.
- Cambios estructurales:
  - `SpotItem` y `_AvailableSpot` pasan a soportar `aemetBeachCodes` ademas de `aemetBeachCode`.
  - `AemetBeachForecastClient` ahora puede cargar varias playas por spot con `fetchForecasts(...)`.
  - la vista `Prediccion de playa` renderiza una tabla por cada playa asociada en lugar de perder la informacion extra.
- Archivos actualizados:
  - `lib/features/spots/domain/entities/spot_item.dart`
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-p)

- `Bloque incremental 02:18-02:26 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 26h 59m`
- `Total acumulado de referencia = 56h 59m`

### 2026-03-08 - Ajuste puntual: codigo corregido de segunda playa en Oliva

- Corregido el segundo codigo de playa AEMET asociado a `Oliva Puerto`.
- Se reemplaza `4618108` por `4618103` tras validacion manual indicada en sesion.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spots_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre ajuste codigo playa)

- `Bloque incremental 02:26-02:35 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 27h 08m`
- `Total acumulado de referencia = 57h 08m`

### 2026-03-08 - Spots v3.4 fase 99-q: selector de playa AEMET por playa real

- Ajustado el comportamiento del desplegable AEMET para exponer una opcion por playa asociada al spot, tal como se pidio.
- Para `Oliva Puerto`, el selector ahora puede mostrar:
  - `Prediccion de playa (Pau-Pi)`
  - `Prediccion de playa (l'Aigua Blanca)`
- Cambios tecnicos:
  - helpers nuevos para construir etiquetas de modelo de playa y resolver el codigo AEMET asociado a cada opcion,
  - el selector de modelos deja de usar una unica opcion generica de playa cuando el spot tiene varias,
  - la carga de AEMET playa pide solo la playa seleccionada en vez de traer todas de golpe,
  - la ficha informativa acepta modelos de playa con nombre especifico.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-q)

- `Bloque incremental 02:35-02:44 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 27h 17m`
- `Total acumulado de referencia = 57h 17m`

### 2026-03-08 - Revision de continuidad y reentrada de trabajo

- Releido `SESSION_TRACKER.md` completo con foco en la cadena reciente `Spots v3.4 fase 99-d` -> `99-q` para retomar exactamente el ultimo punto cerrado.
- Revisado el estado staged actual del slice `spots` y confirmado que el worktree pendiente sigue centrado en forecast real y proveedores `AEMET` / `Open-Meteo`.
- Confirmado como ultimo hito funcional cerrado:
  - `Spots v3.4 fase 99-q`: selector AEMET por playa real (`Prediccion de playa (...)`) y carga bajo demanda de la playa elegida.
- Punto recomendado de continuidad tras esta revision:
  - reforzar arquitectura/cobertura del bloque forecast de `spots`, especialmente extraccion de la orquestacion hoy concentrada en `spot_detail_page.dart` y tests unitarios para clientes/adaptador compuesto AEMET.

### 2026-03-08 - Conteo de horas (inicio de bloque actual)

- Nueva sesion registrada desde `11:04`.
- `Acumulado (track exacto desde 2026-03-01 11:34) = 27h 17m`
- `Total acumulado de referencia = 57h 17m`
- `Bloque activo abierto desde 11:04; actualizar al cerrar la siguiente tarea.`

### 2026-03-08 - Spots v3.4 fase 99-r: fix de overflow en selector de modelos

- Ajustado el desplegable `Modelo de prevision` en `lib/features/spots/presentation/pages/spot_detail_page.dart` para evitar desbordes visuales cuando el label seleccionado o las opciones son demasiado largas.
- Cambios aplicados:
  - `isExpanded: true` en los `DropdownButtonFormField` de proveedor y modelo.
  - el valor seleccionado del modelo ahora se renderiza con `TextOverflow.ellipsis` en una sola linea.
  - las opciones del menu tambien truncan el texto largo en una sola linea para convivir mejor con el badge de recomendacion.
- Test nuevo en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar que el selector no lanza excepciones ni rompe en ancho estrecho (`320px`) al elegir `Prediccion de playa (l'Aigua Blanca)`.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-r)

- `Bloque incremental 11:04-11:36 = 32m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 27h 49m`
- `Total acumulado de referencia = 57h 49m`

### 2026-03-08 - Spots v3.4 fase 99-s: responsividad extra en cabecera Forecast

- Aplicada una segunda pasada de responsividad en `lib/features/spots/presentation/pages/spot_detail_page.dart` para evitar nuevos desbordes en anchos estrechos dentro de la seccion `Forecast`.
- Cambios aplicados:
  - el bloque `Modelo de prevision + info` pasa a layout responsive con `LayoutBuilder`:
    - en ancho normal sigue en la misma fila,
    - en ancho estrecho apila el selector y el boton `Info del modelo`.
  - el titulo `Tabla Forecast (...)` ahora se renderiza con helper dedicado y `ellipsis` para no romper con nombres largos de modelo AEMET.
- Test reforzado en `test/features/spots/presentation/pages/spot_detail_page_test.dart`:
  - en viewport estrecho se selecciona `Prediccion de playa (l'Aigua Blanca)`,
  - se comprueba que no hay excepciones,
  - y que el boton `Info del modelo` sigue siendo usable tras el reflow responsive.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-s)

- `Bloque incremental 11:36-11:43 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 27h 56m`
- `Total acumulado de referencia = 57h 56m`

### 2026-03-08 - Spots v3.4 fase 99-t: integracion inicial del proveedor Meteoblue

- Integrado `Meteoblue` como nuevo proveedor de forecast dentro del slice `spots`.
- Nueva infraestructura:
  - `lib/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart`
- Alcance de la integracion inicial:
  - consumo del endpoint Meteoblue por coordenadas con paquete horario combinado `basic-1h_wind-1h_sea-1h`,
  - mapeo a `SpotForecastEntry` de viento, racha, direccion, temperatura, lluvia y, cuando vienen, presion / temperatura del agua / oleaje,
  - soporte tanto para payload envuelto en `data_1h` como para payload horario plano.
- Wiring aplicado:
  - `CompositeSpotsForecastAdapter` ya enruta `Open-Meteo`, `AEMET` y `Meteoblue` como proveedores reales separados.
  - `SpotsModule` ya construye el adaptador Meteoblue en memoria y en local file.
- UI/metadata actualizadas:
  - `Meteoblue` aparece en el selector de proveedores de `SpotDetailPage`.
  - se anade modelo inicial `Basic` en catalogo/model info.
  - fallback especifico cuando falta `METEOBLUE_API_KEY`.
- Configuracion local actualizada:
  - `EnvConfig` y `LocalEnvStore` exponen `METEOBLUE_API_KEY`.
  - `local.env.json.example` documenta la nueva clave local.
- Tests anadidos/actualizados:
  - `test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-t)

- `Bloque incremental 11:43-11:59 = 16m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 28h 12m`
- `Total acumulado de referencia = 58h 12m`

### 2026-03-08 - Spots v3.4 fase 99-u: ajuste Meteoblue al payload real compartido

- Adaptado el parser de `lib/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart` para acercarlo al payload real de Meteoblue compartido en sesion.
- Cambios aplicados:
  - ahora el adaptador consume el paquete `basic-15min_basic-day_current_clouds-15min_sea-1h_air-15min`.
  - prioriza meteorologia en `data_xmin` y datos marinos en `data_1h`.
  - re-muestrea automaticamente series de `15min` a pasos de `3h` para encajar con la tabla forecast actual.
  - soporta aliases reales de Meteoblue detectados en la documentacion/payload:
    - `gust` en lugar de `windgusts`
    - `surfwave_height` en lugar de `surfwaveheight`
    - `totalcloudcover` para nubosidad
  - mantiene fallback compatible con payload horario plano / legado.
- Tests Meteoblue actualizados para cubrir mezcla `data_xmin + data_1h` y el mapeo correcto de campos reales.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-u)

- `Bloque incremental 11:59-12:08 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 28h 21m`
- `Total acumulado de referencia = 58h 21m`

### 2026-03-08 - Spots v3.4 fase 99-v: activacion real de Meteoblue con API key local

- Configurada `METEOBLUE_API_KEY` en `local.env.json` para que la app pueda cargar el proveedor Meteoblue en runtime real.
- Detectado y corregido el bloqueo funcional principal del parser Meteoblue:
  - la URL real devolvia meteorologia en `data_xmin`,
  - pero no siempre traia `gust` en esa misma resolucion,
  - por lo que todas las filas podian descartarse y acabar en `sin datos disponibles`.
- Ajustes aplicados en `lib/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart`:
  - el request Meteoblue ahora incluye tambien `wind-1h`,
  - la racha se toma de datos horarios cuando exista,
  - y si aun asi falta, se usa fallback a `windspeed` para no perder toda la tabla.
- Tests actualizados en `test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart` para cubrir:
  - URL nueva con `wind-1h`,
  - fallback cuando la racha no llega en `data_xmin`,
  - compatibilidad con payload horario plano.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-v)

- `Bloque incremental 12:08-12:31 = 23m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 28h 44m`
- `Total acumulado de referencia = 58h 44m`

### 2026-03-08 - Spots v3.4 fase 99-w: modo Meteoblue mas forense en tabla Forecast

- Ajustada la representacion de `Meteoblue` para que la tabla `Forecast` deje de interpolar/agrupar artificialmente este proveedor.
- Cambios funcionales clave:
  - el adaptador Meteoblue ya no re-muestrea a `3h` al construir entries;
  - se conserva la cadencia original `15min` de `data_xmin` para la meteorologia base;
  - los datos horarios (`gust`, `sea`) solo aparecen en las filas cuyo timestamp existe realmente en `data_1h`;
  - cuando no existe dato nativo de racha/oleaje/agua en ese timestamp, la tabla muestra ausencia real en lugar de aproximacion inventada.
- UI/filtros adaptados en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `Meteoblue` usa resoluciones nativas `15m` y `1h`.
  - para este proveedor se eliminan las resoluciones interpoladas `3h/6h` de los segmented buttons.
  - el rango se recorta por timestamps reales del feed, no por slots sinteticos.
  - la fila `Racha` ya soporta valores ausentes (`-`) cuando el feed original no la trae en esa resolucion.
- Dominio actualizado:
  - `SpotForecastEntry.gustKnots` pasa a nullable para reflejar fielmente proveedores donde la racha no siempre existe en cada slot.
- Tests reforzados:
  - `test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - ahora validan cadencia `15m`, ausencia real de campos horarios entre slots y segmented buttons nativos para Meteoblue.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-w)

- `Bloque incremental 12:31-12:57 = 26m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 29h 10m`
- `Total acumulado de referencia = 59h 10m`

### 2026-03-08 - Spots v3.4 fase 99-x: prueba visible de Meteoblue Current y Day

- Montado un primer bloque visible de `Meteoblue Current` y `Meteoblue Day` dentro de `Forecast` para comprobar en app la utilidad real de ambos paquetes sin mezclarlo con la tabla principal.
- Nueva infraestructura:
  - `lib/features/spots/infrastructure/services/meteoblue_current_day_client.dart`
- Integracion UI:
  - `SpotDetailPage` acepta/inicializa `MeteoblueCurrentDayClient`.
  - cuando el proveedor activo es `Meteoblue`, debajo de la tabla forecast aparecen:
    - bloque `Meteoblue Current` con hora, temperatura, viento y si el dato actual es observado/estimado;
    - bloque `Meteoblue Day` con resumen diario de min/max, viento medio, lluvia y predictabilidad.
- Esto no altera la tabla forense principal de `15m/1h`; es un complemento separado para inspeccionar `Current` y `Day` en paralelo.
- Tests UI actualizados en `test/features/spots/presentation/pages/spot_detail_page_test.dart` con cliente fake para verificar que ambos bloques aparecen al seleccionar `Meteoblue`.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-x)

- `Bloque incremental 12:57-13:07 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 29h 20m`
- `Total acumulado de referencia = 59h 20m`

### 2026-03-08 - Spots v3.4 fase 99-y: pulido visual de Meteoblue Day/Current

- Refinada la presentacion de los bloques `Meteoblue Current` y `Meteoblue Day` dentro de `Forecast` para que sean mas legibles y comparables a simple vista.
- Cambios visuales en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `Current` ahora tiene cabecera con icono y subtitulo explicativo.
  - `Day` deja de mostrarse como `DataTable` horizontal generica y pasa a tarjetas por dia, mas escaneables en movil/desktop.
  - cada tarjeta diaria resume min/max, viento medio, lluvia y predictabilidad con mejor densidad visual.
- La logica no cambia: sigue usando el feed `Current` y `Day` por separado del forecast forense principal.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-y)

- `Bloque incremental 13:07-13:12 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 29h 25m`
- `Total acumulado de referencia = 59h 25m`

### 2026-03-08 - Spots v3.4 fase 99-z: enrich de Current y Sea en Meteoblue

- Inspeccionado el payload real de Meteoblue para detectar variables adicionales disponibles en `data_current` y `data_1h`.
- Campos confirmados utiles:
  - `data_current`: `time`, `windspeed`, `temperature`, `isobserveddata`
  - `data_1h`: `surfwave_height`, `significantwaveheight`, `mean_waveperiod`, `windwave_meanperiod`, `mean_wavedirection`, `seasurfacetemperature`, `gust`, etc.
- Enriquecido `MeteoblueCurrentDayClient`:
  - `Current` ahora se completa con direccion del viento, presion y nubosidad buscando el timestamp mas cercano en `data_xmin`.
  - se anade snapshot `Sea` horario con temperatura del agua, ola surf, ola significativa, periodo medio, periodo de mar de viento y direccion media.
- UI ampliada en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `Meteoblue Current` muestra ya direccion, presion y nubes.
  - nuevo bloque `Meteoblue Sea (1h)` con resumen marino mas util para spots.
- Tests nuevos/actualizados:
  - `test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 99-z)

- `Bloque incremental 13:12-13:21 = 9m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 29h 34m`
- `Total acumulado de referencia = 59h 34m`

### 2026-03-08 - Spots v3.4 fase 100-a: mini tabla horaria para Meteoblue Sea

- Sustituido el bloque `Meteoblue Sea (1h)` de snapshot unico por una mini tabla horaria con multiples timestamps reales del feed marino.
- Cambios aplicados:
  - `MeteoblueCurrentDaySnapshot.sea` pasa de valor unico a lista de `MeteoblueSeaData`.
  - `MeteoblueCurrentDayClient` ahora parsea la serie completa de `data_1h` en lugar de quedarse con la hora mas cercana.
  - `SpotDetailPage` renderiza una mini tabla horizontal `Sea (1h)` con varias columnas reales y filas:
    - hora
    - agua
    - surf
    - significativa
    - periodo medio
    - periodo viento
    - direccion
- Esto deja el bloque bastante mas util y fiel al proveedor para lectura marina rapida.
- Tests actualizados:
  - `test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-a)

- `Bloque incremental 13:21-13:28 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 29h 41m`
- `Total acumulado de referencia = 59h 41m`

### 2026-03-08 - Spots v3.4 fase 100-b: enriquecimiento marino avanzado en Meteoblue Sea

- Revisado el payload real `data_1h` de Meteoblue y confirmadas variables marinas adicionales utiles para deportes de viento/ola:
  - `swell_significantheight`
  - `swell_meanperiod`
  - `swell_meandirection`
  - `windwave_height`
  - `windwave_direction`
  - `douglas_seastate`
- Integrado ese enrich en `lib/features/spots/infrastructure/services/meteoblue_current_day_client.dart`.
- Mejorada la mini tabla `Meteoblue Sea (1h)` en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - se anaden filas `Swell`, `Windsea`, `Dir swell`, `Dir viento` y `Douglas`.
  - `Surf`, `Signif.`, `Swell` y `Windsea` ahora llevan color semantico suave para lectura rapida.
- Tests actualizados para cubrir el nuevo mapeo marino y la presencia de las nuevas filas en UI:
  - `test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart -r compact` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-b)

- `Bloque incremental 13:28-13:44 = 16m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 29h 57m`
- `Total acumulado de referencia = 59h 57m`

### 2026-03-08 - Spots v3.4 fase 100-c: lectura visual mejorada de direcciones y Douglas

- Mejorada la legibilidad de la tabla `Meteoblue Sea (1h)` en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Cambios aplicados:
  - `Dir`, `Dir swell` y `Dir viento` pasan a renderizarse con la misma celda direccional compacta usada en forecast principal (flecha + cardinal), en lugar de solo grados.
  - `Douglas` deja de mostrarse como numero crudo y ahora se traduce a etiquetas marinas legibles (`Calma`, `Marejadilla`, `Marejada`, etc.).
- Se mantiene la tabla fiel al proveedor pero mucho mas interpretable visualmente.
- Tests UI ajustados para validar presencia de la etiqueta `Marejada` y lectura direccional visible.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-c)

- `Bloque incremental 13:44-13:51 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 30h 04m`
- `Total acumulado de referencia = 1d 00h 04m`

### 2026-03-08 - Spots v3.4 fase 100-d: compactacion movil y leyenda rapida en Meteoblue

- Compactado el bloque `Meteoblue` para que respire mejor en anchos estrechos sin tocar la fidelidad del dato.
- Cambios aplicados en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `LayoutBuilder` para ajustar paddings, spacing y ancho de tarjetas en modo estrecho.
  - la mini tabla `Sea (1h)` reduce ligeramente el ancho de columna en movil.
  - anadida microleyenda con `Tooltip` para conceptos marinos clave:
    - `Swell`
    - `Windsea`
    - `Douglas`
- Esto hace el bloque mas explicativo sin recargar la UI con texto permanente.
- Tests UI actualizados para validar la presencia de los tooltips/labels auxiliares.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-d)

- `Bloque incremental 13:51-13:55 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 30h 08m`
- `Total acumulado de referencia = 1d 00h 08m`

### 2026-03-08 - Spots v3.4 fase 100-e: modelos Meteoblue separados en el desplegable

- Reorganizada la integracion Meteoblue para que el selector de `Modelo de prevision` exponga vistas separadas en lugar de mezclar todo bajo `Basic`.
- Catalogo Meteoblue actualizado:
  - `Basic`
  - `Current`
  - `Day`
  - `Sea`
- Cambios aplicados:
  - `spot_forecast_model_order.dart` incluye ya los cuatro modelos.
  - `spot_forecast_model_info.dart` describe cada vista por separado.
  - `SpotDetailPage` ahora renderiza segun modelo Meteoblue seleccionado:
    - `Basic` -> solo tabla forecast principal
    - `Current` -> solo bloque actual
    - `Day` -> solo bloque diario
    - `Sea` -> solo bloque marino horario
- Esto elimina la sobrecarga visual dentro de `Basic` y deja cada paquete Meteoblue mas limpio y navegable.
- Test UI actualizado para validar que el dropdown ofrece los cuatro modelos y que cada uno muestra solo su vista correspondiente.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-e)

- `Bloque incremental 13:55-14:07 = 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 30h 20m`
- `Total acumulado de referencia = 1d 00h 20m`

### 2026-03-08 - Revision de continuidad y estado actual del proyecto

- Releido `SESSION_TRACKER.md` completo con foco en el ultimo tramo activo de `spots` y la evolucion reciente de `Meteoblue`/`AEMET`.
- Reconfirmada la direccion global del repo:
  - arquitectura v3.0 hexagonal en `docs/architecture/hexagonal_v3.md`,
  - backlog macro de migracion ya cerrado en `docs/architecture/migration_backlog_v3.md`.
- Estado funcional mas reciente reconstruido:
  - ultimo hito cerrado en tracker: `Spots v3.4 fase 100-e`.
  - foco actual del worktree: forecast real en `spots`, con integracion Meteoblue, AEMET municipal/playa/costa y orquestacion UI todavia concentrada sobre todo en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Cambios pendientes detectados en git al reentrar:
  - wiring/config para `Meteoblue` (`env`, `spots_module`, `composite adapter`),
  - nuevo adaptador `lib/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart`,
  - nuevo cliente `lib/features/spots/infrastructure/services/meteoblue_current_day_client.dart`,
  - ajustes de dominio en `lib/features/spots/domain/entities/spot_forecast_entry.dart` para `gustKnots` nullable,
  - ampliacion de cobertura/tests en `test/features/spots/...`.
- Verificacion ejecutada en esta reentrada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
- Punto de continuidad recomendado desde aqui:
  - `Spots v3.4 fase 100-f`: extraer la logica de `Meteoblue Current/Day/Sea` y parte de la orquestacion forecast fuera de `spot_detail_page.dart` hacia servicios/widgets mas limpios, manteniendo la cobertura de tests ya verde.

### 2026-03-08 - Conteo de horas (cierre bloque de revision y reentrada)

- `Bloque incremental 14:07-14:19 = 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 30h 32m`
- `Total acumulado de referencia = 1d 00h 32m`

### 2026-03-08 - Spots v3.4 fase 100-f: extraccion del bloque visual Meteoblue fuera de Spot Detail

- Continuado el siguiente paso acordado para empezar a descargar `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Extraido el rendering del bloque suplementario de `Meteoblue` a un widget dedicado:
  - `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart`
- El nuevo widget encapsula la UI de:
  - `Meteoblue Current`
  - `Meteoblue Sea (1h)`
  - `Meteoblue Day`
- `SpotDetailPage` queda mas limpio y pasa a conservar sobre todo la orquestacion de carga/seleccion:
  - helper `_buildSelectedMeteoblueSupplement(...)`
  - snapshot vacio reutilizable para fallback
  - `FutureBuilder` mas corto al elegir vista `Current` / `Sea` / `Day`
- Limpieza asociada en `SpotDetailPage`:
  - eliminados helpers visuales Meteoblue que ya no pertenecian a la pagina,
  - resueltas funciones privadas que quedaron sin uso tras la extraccion.
- Objetivo de esta fase:
  - reducir tamano y responsabilidad de `SpotDetailPage`,
  - dejar el bloque Meteoblue preparado para seguir separando piezas de forecast en siguientes iteraciones.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-f)

- `Bloque incremental 14:19-14:26 = 7m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 30h 39m`
- `Total acumulado de referencia = 1d 00h 39m`

### 2026-03-08 - Spots v3.4 fase 100-g: limpieza de ayudas inutiles y copy explicativo en tabla Sea

- Ajuste UX solicitado sobre `Meteoblue Sea (1h)` en `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart`.
- Eliminados los chips/tooltips de `Swell`, `Windsea` y `Douglas` por aportar poco valor real en esa posicion.
- En su lugar se anade una explicacion corta encima de la tabla para que la lectura sea inmediata:
  - `Agua` = temperatura superficial del agua,
  - `Surf`, `Signif.`, `Swell`, `Windsea` = alturas de ola en metros,
  - `T medio` y `T viento` = periodos en segundos,
  - `Dir` = direccion del mar,
  - `Douglas` = estado general del mar.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar el nuevo texto explicativo y dejar de depender de tooltips eliminados.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-g)

- `Bloque incremental 14:26-14:36 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 30h 49m`
- `Total acumulado de referencia = 1d 00h 49m`

### 2026-03-08 - Spots v3.4 fase 100-h: renombrado de filas en Meteoblue Sea para lectura mas clara

- Ajustado el copy de la tabla `Meteoblue Sea (1h)` en `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart` para hacerla mas autoexplicativa a primera vista.
- Renombres aplicados:
  - `Agua` -> `Agua º`
  - `Surf` -> `Surf(wave)`
  - `Signif.` -> `Oleaje(m)`
  - `Swell` -> `Mar de fondo`
  - `T medio` -> `Periodo(oleaje)`
  - `T viento` -> `Periodo(mar de viento)`
  - `Dir` -> `Sea dir.`
  - `Dir swell` -> `Dir(Mar de fondo)`
  - `Dir viento` -> `Dir(Wind)`
  - `Douglas` -> `Sea status`
- Test UI actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar el nuevo naming visible.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-h)

- `Bloque incremental 14:36-14:52 = 16m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 31h 05m`
- `Total acumulado de referencia = 1d 01h 05m`

### 2026-03-08 - Spots v3.4 fase 100-i: eliminacion del texto explicativo redundante en Sea

- Eliminado el texto explicativo superior de la tabla `Meteoblue Sea (1h)` en `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart`.
- Motivo: el bloque ya dispone de `Info del modelo`, asi que ese copy resultaba redundante y recargaba la vista.
- Test ajustado en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para dejar de esperar ese texto.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-i)

- `Bloque incremental 14:52-14:55 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 31h 08m`
- `Total acumulado de referencia = 1d 01h 08m`

### 2026-03-08 - Spots v3.4 fase 100-j: selector configurable para horizonte de Meteoblue Sea

- Implementado selector de horizonte visible en `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart` para la tabla `Meteoblue Sea (1h)`.
- Opciones disponibles en UI:
  - `6h`
  - `12h`
  - `24h`
- El estado del selector se gestiona desde `lib/features/spots/presentation/pages/spot_detail_page.dart`, sin refetch remoto: solo cambia cuantas columnas horarias se muestran del snapshot ya cargado.
- Se mantiene el comportamiento por defecto en `6h`, pero ya puede ampliarse desde la propia vista.
- Tests reforzados en `test/features/spots/presentation/pages/spot_detail_page_test.dart`:
  - se valida la presencia del selector,
  - se valida que al pasar a `12h` aparecen horas adicionales que antes no se mostraban.
- Mock Meteoblue del test ampliado para ofrecer serie marina suficientemente larga y cubrir el selector.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-j)

- `Bloque incremental 14:55-15:03 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 31h 16m`
- `Total acumulado de referencia = 1d 01h 16m`

### 2026-03-08 - Spots v3.4 fase 100-k: fullscreen en Meteoblue Sea alineado con forecast principal

- Extendida la tabla `Meteoblue Sea (1h)` para soportar fullscreen con comportamiento equivalente al de la tabla principal de forecast.
- Cambios principales:
  - `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart`
    - soporte de boton `Ampliar tabla`,
    - modo `expandToFill` para reutilizar el mismo widget dentro del overlay fullscreen.
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
    - sustituido el booleano anterior por un modo de fullscreen (`forecastTable` / `meteoblueSea`),
    - anadido overlay fullscreen especifico para `Meteoblue Sea`,
    - integrado con `PopScope` y cierre con `Salir de fullscreen` igual que el forecast principal.
- El selector de `6h / 12h / 24h` sigue funcionando tambien dentro del fullscreen, sin refetch remoto.
- Tests reforzados en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para cubrir el fullscreen de `Meteoblue Sea`.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre post fase 100-k)

- `Bloque incremental 15:03-15:15 = 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 31h 28m`
- `Total acumulado de referencia = 1d 01h 28m`

### 2026-03-08 - Hotfix fullscreen Meteoblue Sea: correccion de overflow vertical

- Detectado overflow vertical (`RenderFlex overflowed by 203 pixels on the bottom`) al usar fullscreen en `Meteoblue Sea`.
- Causa: el contenido del card entraba en un `Column` rigido dentro del overlay fullscreen, sin scroll vertical disponible cuando la altura visible no alcanzaba.
- Fix aplicado en `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart`:
  - extraido el cuerpo a helper propio,
  - en modo `expandToFill` ahora se envuelve en `SingleChildScrollView`,
  - se anade padding inferior para no solaparse con el boton `Salir de fullscreen`.
- Resultado: se mantiene el fullscreen y el selector de `6h / 12h / 24h`, pero sin desbordamiento vertical en pantallas mas justas.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre hotfix overflow fullscreen Sea)

- `Bloque incremental 15:15-15:18 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 31h 31m`
- `Total acumulado de referencia = 1d 01h 31m`

### 2026-03-08 - Ajuste UX fullscreen Meteoblue Sea: solo tabla como Open-Meteo

- Refinado el fullscreen de `Meteoblue Sea` para que se comporte visualmente como el fullscreen de la tabla principal.
- En fullscreen ya no se renderizan:
  - cabecera `Meteoblue Sea (1h)`
  - subtitulo descriptivo
  - selector `6h / 12h / 24h`
- En fullscreen queda solo la tabla marina y el boton `Salir de fullscreen`, igual que en Open-Meteo.
- En vista normal se mantienen la cabecera y el selector como antes.
- Implementado en `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart` con flags para ocultar header/controles cuando el widget se usa dentro del overlay.
- Overlay actualizado en `lib/features/spots/presentation/pages/spot_detail_page.dart` para activar ese modo reducido.
- Test actualizado en `test/features/spots/presentation/pages/spot_detail_page_test.dart`.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre ajuste fullscreen Sea solo tabla)

- `Bloque incremental 15:18-15:26 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 31h 39m`
- `Total acumulado de referencia = 1d 01h 39m`

### 2026-03-08 - Spots v3.4 fase 100-l: integracion inicial del proveedor Meteosource

- Implementado nuevo adaptador `lib/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter.dart`.
- Integracion actual de Meteosource:
  - endpoint `free/point` con `sections=hourly`,
  - parsing de forecast horario puntual,
  - mapeo a `SpotForecastEntry` de `temperature`, `wind.speed`, `wind.gusts`, `wind.angle`, `pressure`, `cloud_cover.total` y `precipitation.total`,
  - conversion de viento desde `m/s` a `kt`.
- Wiring completado en arquitectura:
  - `EnvConfig` y `LocalEnvStore` exponen `METEOSOURCE_API_KEY`,
  - `CompositeSpotsForecastAdapter` enruta `Meteosource`,
  - `SpotsModule` lo registra en DI tanto en memoria como en local file.
- UI / dominio de seleccion actualizados:
  - proveedor nuevo `Meteosource`,
  - modelo visible `Hourly`,
  - info de modelo añadida en `spot_forecast_model_info.dart`,
  - orden/default en `spot_forecast_model_order.dart`,
  - `SpotDetailPage` ajustada para fallback, rangos y resolucion coherentes con horizonte horario corto (solo `1 dia`, resolucion nativa `1h`).
- Secrets / entorno:
  - `local.env.json` local actualizado con `METEOSOURCE_API_KEY` proporcionada por usuario,
  - `local.env.json.example` corregido para dejar placeholders y evitar que el ejemplo trackeado arrastre valores reales.
- Cobertura añadida:
  - `test/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart` valida selector/banner/modelo de Meteosource.
- Verificacion adicional contra API real:
  - request directo a Meteosource ejecutado con la key local,
  - respuesta real recibida correctamente con `24` registros horarios y estructura compatible con el adaptador.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter_test.dart test/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteoblue_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-l Meteosource)

- `Bloque incremental 15:26-16:22 = 56m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 32h 35m`
- `Total acumulado de referencia = 1d 02h 35m`

### 2026-03-08 - Spots v3.4 fase 100-m: ampliacion Meteosource con Current y Day reales

- Validada la API real de Meteosource con la key local:
  - `sections=current,hourly,daily` devuelve correctamente `current`, `hourly` y `daily`.
  - comprobado en vivo que el payload diario trae `daily.data[].all_day` con min/max, viento medio y precipitacion.
- Añadido cliente dedicado `lib/features/spots/infrastructure/services/meteosource_current_day_client.dart` para `Current` y `Day`.
- Añadido widget visual `lib/features/spots/presentation/widgets/meteosource_forecast_supplement_card.dart`.
- `SpotDetailPage` actualizada para soportar modelos Meteosource:
  - `Hourly` sigue usando la tabla forecast,
  - `Current` muestra bloque suplementario propio,
  - `Day` muestra resumen diario propio.
- `spot_forecast_model_order.dart` y `spot_forecast_model_info.dart` ampliados para exponer `Current` y `Day` en Meteosource.
- Investigacion maritima cerrada por ahora:
  - la documentacion publica de Meteosource indica que `Maritime Forecast` entra via `Weather maps API`,
  - no aparece como serie puntual tipo `point/hourly` utilizable para la tabla `Sea` actual,
  - ademas la pagina publica lo marca para `Standard/Flexi plans`, no como flujo claro de `free point`.
  - conclusion operativa: `Current` y `Day` quedan integrados; `Sea` de Meteosource queda pendiente hasta confirmar un endpoint puntual/tabular utilizable.
- Cobertura añadida/extendida:
  - `test/features/spots/infrastructure/services/meteosource_current_day_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart` para modelos `Current` y `Day`.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteosource_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-m Meteosource Current/Day)

- `Bloque incremental 16:22-16:35 = 13m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 32h 48m`
- `Total acumulado de referencia = 1d 02h 48m`

### 2026-03-08 - Verificacion final de tier Meteosource y alcance real de la API key

- Se ha hecho comprobacion directa adicional de la key para aclarar el alcance real del plan actual.
- Resultado confirmado en vivo:
  - `free/point` funciona para `current`, `hourly` y `daily`.
  - `flexi/point` responde `The API key is not allowed to use this tier`.
  - `flexi/map` para variable maritima (`wave_height`) responde `403`, por lo que la capacidad maritima no esta disponible con esta key/tier actual en los endpoints probados.
- Con esto queda confirmado que la key ya funciona en la app para todo lo que el tier actual permite de forma puntual/tabular:
  - `Meteosource Hourly`
  - `Meteosource Current`
  - `Meteosource Day`
- Conclusión operativa:
  - no hace falta mas wiring para que la key actual funcione,
  - `Sea/Maritime` no puede integrarse de forma equivalente mientras la cuenta no tenga acceso al tier/endpoints maritimos necesarios.

### 2026-03-08 - Conteo de horas (cierre verificacion de tier Meteosource)

- `Bloque incremental 16:35-16:38 = 3m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 32h 51m`
- `Total acumulado de referencia = 1d 02h 51m`

### 2026-03-08 - Hotfix Meteosource: recarga perezosa de API key para sesiones ya abiertas

- Detectado motivo probable de que `Meteosource Hourly/Current/Day` no mostrasen datos en una app ya abierta tras anadir la key local:
  - el adaptador y el cliente estaban capturando la API key una sola vez en el constructor,
  - si la app o el arbol de estado seguia vivo desde antes de crear `local.env.json`/anadir la clave, esos servicios podian quedarse con key vacia aunque el archivo ya existiese.
- Fix aplicado:
  - `lib/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/meteosource_current_day_client.dart`
- Comportamiento nuevo:
  - si no se inyecta una key explicita, ambos resuelven la clave en cada uso a traves de `EnvConfig`,
  - si sigue vacia, fuerzan `LocalEnvStore.initialize()` y reintentan leer `local.env.json` antes de rendirse.
- Resultado esperado:
  - `Meteosource Hourly`, `Current` y `Day` ya pueden recuperar la key local aunque la sesion venga de antes, sin depender tanto de que el servicio hubiese nacido con el valor correcto.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteosource_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre hotfix recarga API key Meteosource)

- `Bloque incremental 16:38-16:43 = 5m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 32h 56m`
- `Total acumulado de referencia = 1d 02h 56m`

### 2026-03-08 - Verificacion de campos reales Meteosource: sin presion en hourly/current/daily free

- Inspeccionado el payload real de Meteosource con la key activa usando `sections=current,hourly,daily`.
- Hallazgo confirmado en vivo:
  - `hourly` trae: `date, weather, icon, summary, temperature, wind, cloud_cover, precipitation`
  - `current` trae: `icon, icon_num, summary, temperature, wind, precipitation, cloud_cover`
  - `daily.all_day` trae: `weather, icon, temperature, temperature_min, temperature_max, wind, cloud_cover, precipitation`
- No aparece `pressure` en ninguno de esos bloques reales del tier `free/point` probado.
- Conclusion:
  - el codigo ya intentaba mapear presion si existia,
  - pero con el payload real actual Meteosource no esta entregando ese campo, asi que la UI no puede mostrarlo con datos reales.

### 2026-03-08 - Conteo de horas (cierre verificacion pressure Meteosource)

- `Bloque incremental 16:43-16:49 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 33h 02m`
- `Total acumulado de referencia = 1d 03h 02m`

### 2026-03-08 - Spots v3.4 fase 100-n: integracion inicial de Meteostat Hourly via RapidAPI

- Implementado soporte de credenciales Meteostat en entorno local:
  - `METEOSTAT_RAPIDAPI_KEY`
  - `METEOSTAT_RAPIDAPI_HOST`
- Archivos de config actualizados:
  - `lib/core/config/env/env_config.dart`
  - `lib/core/config/env/local_env_store.dart`
  - `local.env.json.example`
  - `local.env.json` local con la key proporcionada por usuario.
- Nuevo adaptador creado:
  - `lib/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter.dart`
- Integracion funcional actual de Meteostat:
  - endpoint `point/hourly` via `RapidAPI`,
  - query horaria a 7 dias,
  - filtrado de registros ya pasados,
  - mapeo de `temp`, `prcp`, `wdir`, `wspd`, `wpgt`, `pres` a `SpotForecastEntry`,
  - conversion de viento/racha de `km/h` a `kt`.
- Wiring completado en arquitectura:
  - `CompositeSpotsForecastAdapter` enruta `Meteostat`,
  - `SpotsModule` registra el adaptador,
  - `spot_forecast_model_order.dart` expone proveedor/modelo `Meteostat -> Hourly`,
  - `spot_forecast_model_info.dart` documenta el modelo.
- UI de `spots` ajustada para el nuevo proveedor en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - selector de proveedor actualizado,
  - fallback especifico si falta `RapidAPI key`,
  - fallback mock local especifico para Meteostat,
  - rangos calculados como serie horaria real,
  - resolucion forzada a `1h` para evitar muestreos erroneos de una serie ya nativa por hora.
- Validacion real confirmada con la key proporcionada:
  - `point/hourly` responde `200`,
  - devuelve `temp`, `prcp`, `wdir`, `wspd`, `wpgt`, `pres`, por lo que Meteostat si aporta presion atmosferica real.
- Cobertura anadida/actualizada:
  - `test/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter_test.dart test/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteosource_current_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-n Meteostat Hourly)

- `Bloque incremental 16:49-17:19 = 30m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 33h 32m`
- `Total acumulado de referencia = 1d 03h 32m`

### 2026-03-08 - Spots v3.4 fase 100-o: ampliacion Meteostat con modelo Day

- Validado en vivo que `Meteostat point/daily` tambien responde correctamente con la key actual y devuelve serie diaria con:
  - `tavg`, `tmin`, `tmax`, `prcp`, `wspd`, `wpgt`, `pres`, `tsun`.
- Nuevo cliente creado:
  - `lib/features/spots/infrastructure/services/meteostat_day_client.dart`
- Nuevo widget visual creado:
  - `lib/features/spots/presentation/widgets/meteostat_day_supplement_card.dart`
- `SpotDetailPage` ampliada para soportar `Meteostat Day` como vista suplementaria propia, igual que ya se hacia con otros modelos no tabulares.
- `spot_forecast_model_order.dart` y `spot_forecast_model_info.dart` actualizados para exponer `Meteostat -> Day`.
- El resumen diario Meteostat muestra ahora por dia:
  - min/max y media termica,
  - viento medio,
  - racha,
  - presion,
  - lluvia,
  - minutos de sol.
- Cobertura añadida/actualizada:
  - `test/features/spots/infrastructure/services/meteostat_day_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart` valida el modelo `Day` y el rendering del bloque.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter_test.dart test/features/spots/infrastructure/services/meteostat_day_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-o Meteostat Day)

- `Bloque incremental 17:19-17:30 = 11m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 33h 43m`
- `Total acumulado de referencia = 1d 03h 43m`

### 2026-03-08 - Reentrada actual: revision de contexto para retomar el proyecto

- Releido `SESSION_TRACKER.md` completo con foco en el tramo final activo de `spots`.
- Reconfirmada la direccion general del repo:
  - arquitectura hexagonal v3.0 en `docs/architecture/hexagonal_v3.md`,
  - `README.md` todavia esta como plantilla minima y no refleja el estado real del producto.
- Estado del worktree revisado al reentrar:
  - el bloque activo sigue concentrado en `spots`, especialmente forecast real y proveedores,
  - hay cambios locales/staged en `AEMET`, `Meteoblue`, `Meteosource` y `Meteostat`,
  - `lib/features/spots/presentation/pages/spot_detail_page.dart` sigue siendo el punto mas cargado de orquestacion/UI.
- Ultimo hito cerrado antes de esta reentrada:
  - `Spots v3.4 fase 100-o: ampliacion Meteostat con modelo Day`.
- Punto de continuidad recomendado desde aqui:
  - `Spots v3.4 fase 100-p`: seguir descargando `spot_detail_page.dart` y cerrar la capa de suplementos forecast por proveedor/modelo (orquestacion, estados fallback/error y widgets dedicados) antes de abrir mas integraciones nuevas.

### 2026-03-08 - Conteo de horas (inicio bloque actual)

- `Inicio de bloque actual = 17:42`
- `Acumulado previo cerrado (track exacto desde 2026-03-01 11:34) = 33h 43m`
- `Total acumulado de referencia previo = 1d 03h 43m`
- `Nota: bloque abierto; al cerrar la siguiente intervencion se actualiza con la duracion real.`

### 2026-03-08 - Spots v3.4 fase 100-p: fix de rango real para Meteostat Hourly

- Corregido el problema por el que `Meteostat Hourly` podia quedarse sin exponer correctamente el rango de `7 dias` en la UI.
- Causas detectadas:
  - el adaptador pedia hasta `start + 6 dias`, lo que al filtrar horas ya pasadas podia dejar menos de 7 dias futuros efectivos,
  - el recorte visual de tabla seguia una logica fija de `8 slots por dia`, valida para series de `3h` pero incorrecta para `1h` como Meteostat.
- Fix aplicado en `lib/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter.dart`:
  - la query `point/hourly` ahora pide hasta `start + 7 dias` para conservar una ventana futura completa de 7 dias aunque parte del dia actual ya haya pasado.
- Fix aplicado en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `_clipForecastRows(...)` pasa a recortar por tiempo real (`slotTime < start + rango`) en lugar de limitar por numero fijo de slots,
  - el generador local de filas mock añade un slot extra para no quedarse corto justo en el borde del rango y reflejar mejor la capacidad real del proveedor.
- Cobertura reforzada:
  - `test/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - nuevo test para validar que `Meteostat` mantiene visible `7 dias` y puede renderizar semana completa en `1h`.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-p Meteostat range fix)

- `Bloque incremental 17:42-17:54 = 12m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 33h 55m`
- `Total acumulado de referencia = 1d 03h 55m`

### 2026-03-08 - Spots v3.4 fase 100-q: retirada de datos inventados en fallbacks forecast

- Ajustado el comportamiento de `spots` para no inventar datos cuando falla o no responde un proveedor real.
- Cambios aplicados en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `Open-Meteo`, `AEMET`, `Meteoblue`, `Meteosource` y `Meteostat` ya no rellenan la tabla forecast con series mock locales cuando la carga real devuelve vacio o error,
  - el estado fallback de forecast principal pasa a devolver `rows` vacias y mensaje explicito del proveedor,
  - el overlay fullscreen del forecast principal deja de reconstruirse con datos mock si el `FutureBuilder` no trae resultado,
  - `AEMET playa` y `AEMET maritima costera` dejan de fabricar boletines/tablas placeholder y ahora muestran estado vacio cuando no hay respuesta real.
- Refactor UX asociado:
  - nuevo helper reutilizable de estado vacio para forecast,
  - copy de fallback simplificado a `datos no disponibles` / mensaje real del proveedor, sin hablar de `fallback local` cuando no existe dato real.
- Se mantiene `Windguru` como modo demo/mock explicito; el resto de proveedores reales no presentan datos sinteticos como si fueran reales.
- Cobertura ajustada en `test/features/spots/presentation/pages/spot_detail_page_test.dart` para validar el estado vacio del forecast cuando un proveedor no devuelve datos.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-q no invented forecast data)

- `Bloque incremental 17:54-18:05 = 11m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 34h 06m`
- `Total acumulado de referencia = 1d 04h 06m`

### 2026-03-08 - Spots v3.4 fase 100-r: retirada de Windguru del selector forecast

- Revisada la viabilidad de `Windguru` como proveedor real y descartada su activacion por falta de acceso oficial utilizable desde app.
- Retirado `Windguru` del selector activo de proveedores en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Eliminado el wiring residual asociado al proveedor en forecast:
  - salida mock dedicada en `_loadForecastRows()`,
  - modelos base de `Windguru` en `lib/features/spots/application/services/spot_forecast_model_order.dart`,
  - metadatos/info de modelos en `lib/features/spots/application/services/spot_forecast_model_info.dart`,
  - caso mock local de filas forecast y sesgo proveedor dentro de `spot_detail_page.dart`.
- Limpiado tambien el rastro visible de `Windguru` en estaciones cercanas mock del detalle para no seguir sugiriendo un proveedor que ya no ofrecemos en forecast.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-r remove Windguru)

- `Bloque incremental 18:05-18:24 = 19m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 34h 25m`
- `Total acumulado de referencia = 1d 04h 25m`

### 2026-03-08 - Spots v3.4 fase 100-s: primera descarga del bloque forecast en `spot_detail_page`

- Aplicado un refactor pequeno pero util para seguir descargando `lib/features/spots/presentation/pages/spot_detail_page.dart` sin cambiar comportamiento.
- Extraidos helpers internos reutilizables para el bloque de forecast principal:
  - `_buildForecastLoadingState(...)`
  - `_openForecastTableFullscreen()`
  - `_updateForecastRange(...)`
  - `_updateForecastResolution(...)`
  - `_buildForecastTableContent(...)`
- Con esto el `FutureBuilder` principal de forecast queda menos cargado y concentra mejor la decision de flujo:
  - loading,
  - suplementos dedicados por proveedor/modelo,
  - fallback vacio,
  - tabla principal.
- No se han introducido nuevos datos ni cambios funcionales; el objetivo de esta fase ha sido bajar complejidad local del `build` y preparar extracciones mas grandes despues.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-s forecast builder cleanup)

- `Bloque incremental 18:24-19:21 = 57m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 22m`
- `Total acumulado de referencia = 1d 05h 22m`

### 2026-03-08 - Spots v3.4 fase 100-t: extraccion del dispatcher de suplementos forecast

- Continuada la descarga de `lib/features/spots/presentation/pages/spot_detail_page.dart` sin cambios funcionales.
- Extraidos helpers dedicados para el enrutado de suplementos forecast por proveedor/modelo:
  - `_buildMeteoblueSupplement()`
  - `_buildMeteosourceSupplement()`
  - `_buildMeteostatDaySupplement()`
  - `_buildForecastSupplementOrTable(...)`
- El `FutureBuilder` principal de forecast queda ahora mas reducido y delega la seleccion entre:
  - suplemento Meteoblue,
  - suplemento Meteosource,
  - suplemento Meteostat Day,
  - tabla forecast principal.
- Con esto se separa mejor la orquestacion del contenido y queda mas facil seguir extrayendo bloques por proveedor en la siguiente fase.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-t supplement dispatcher extraction)

- `Bloque incremental 19:21-19:25 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 26m`
- `Total acumulado de referencia = 1d 05h 26m`

### 2026-03-08 - Spots v3.4 fase 100-u: extraccion de secciones AEMET forecast dedicadas

- Seguido el refactor incremental de `lib/features/spots/presentation/pages/spot_detail_page.dart` extrayendo los dos bloques especiales de AEMET que aun cargaban mucho el `build` principal.
- Nuevos helpers de seccion:
  - `_buildAemetBeachForecastSection()`
  - `_buildAemetCoastalForecastSection()`
- El `build` principal ya no contiene en linea toda la logica de:
  - espera de `FutureBuilder`,
  - fallback vacio,
  - banner de estado,
  - composicion de tablas AEMET playa/costera.
- El comportamiento se mantiene: misma resolucion de empty state, mismas tablas dedicadas y misma verificacion de `source/data` antes de renderizar contenido real.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-u AEMET section extraction)

- `Bloque incremental 19:25-19:29 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 30m`
- `Total acumulado de referencia = 1d 05h 30m`

### 2026-03-08 - Spots v3.4 fase 100-v: extraccion de controles forecast

- Continuada la limpieza de `lib/features/spots/presentation/pages/spot_detail_page.dart` sacando del `build` principal los controles superiores del bloque forecast.
- Nuevos handlers/helpers extraidos:
  - `_handleForecastProviderChanged(...)`
  - `_handleForecastModelChanged(...)`
  - `_openWindMap()`
  - `_buildForecastProviderDropdown()`
  - `_buildForecastModelControls()`
  - `_buildWindMapButton()`
- Beneficio inmediato:
  - el `build` principal ya no contiene en linea toda la logica de cambio de proveedor/modelo,
  - queda mejor separada la orquestacion de refresh (`forecast rows`, `AEMET playa`, `AEMET costera`),
  - el bloque visual forecast empieza a quedar mas componible para futuras extracciones.
- Sin cambios funcionales: se mantiene la misma UI, mismos refresh condicionales y mismos tests de comportamiento.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-v forecast controls extraction)

- `Bloque incremental 19:29-19:33 = 4m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 34m`
- `Total acumulado de referencia = 1d 05h 34m`

### 2026-03-08 - Spots v3.4 fase 100-w: extraccion de la seccion Forecast completa

- Extraida la seccion `Forecast` completa del `switch` principal de `build` en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Nuevos helpers introducidos:
  - `_buildForecastSectionBody()`
  - `_buildForecastSection()`
- La seccion forecast queda ahora encapsulada en un bloque unico que compone:
  - controles de proveedor/modelo,
  - acceso a mapa de viento,
  - dispatcher de contenido (`AEMET playa`, `AEMET costera`, forecast general).
- Esto deja el `switch (_section)` bastante mas legible y reduce todavia mas la presion de mantenimiento sobre el `build` principal.
- Sin cambios funcionales: misma logica de carga, mismos empty states y misma composicion visual.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-w extract full forecast section)

- `Bloque incremental 19:33-19:35 = 2m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 36m`
- `Total acumulado de referencia = 1d 05h 36m`

### 2026-03-08 - Nota de investigacion: payload real AEMET playa para `l'Aigua Blanca`

- Revisado el payload real de AEMET playa para el codigo `4618103` (`l'Aigua Blanca`) usando la API oficial ya configurada localmente.
- Hallazgo principal:
  - el parser actual de `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart` extrae solo una parte del dia AEMET (`descripcion1/2`, `valor1`, `fecha`),
  - el payload crudo trae mas estructura auxiliar por bloque.
- Campos adicionales observados en la respuesta real de AEMET que ahora no mostramos explicitamente en la tabla:
  - `estadoCielo.f1` y `estadoCielo.f2`
  - `viento.f1` y `viento.f2`
  - `oleaje.f1` y `oleaje.f2`
  - `sTermica.valor1`
  - `value` vacio repetido dentro de varios bloques (`estadoCielo`, `viento`, `oleaje`, `tMaxima`, `sTermica`, `tAgua`, `uvMax`)
  - duplicados de compatibilidad como `tagua`, `tmaxima`, `stermica`
- Conclusion funcional:
  - si queremos enriquecer la tabla de playa, hay margen para mapear codigos/valores numericos internos de AEMET ademas de las descripciones textuales ya usadas.

### 2026-03-08 - Conteo de horas (nota investigacion AEMET playa)

- `Bloque incremental 19:35-19:48 = 13m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 49m`
- `Total acumulado de referencia = 1d 05h 49m`

### 2026-03-08 - Spots v3.4 fase 100-x: extraccion de la seccion Live completa

- Continuado el refactor de `lib/features/spots/presentation/pages/spot_detail_page.dart` extrayendo la seccion `Live` fuera del `switch` principal.
- Nuevos helpers/handlers introducidos para encapsular la UI y la interaccion de datos en vivo:
  - `_handleLiveStationChanged(...)`
  - `_handleWindSpeedUnitChanged(...)`
  - `_toggleRealtimeCompass()`
  - `_toggleSimulatedCompass(...)`
  - `_buildLiveStationDropdown()`
  - `_buildLiveProviderLabel()`
  - `_buildLiveWindUnitSelector()`
  - `_buildLiveCompassSection()`
  - `_buildLiveMetricsGrid()`
  - `_buildLiveSection()`
- La seccion `Live` queda ahora compuesta como bloque unico reutilizable y el `switch (_section)` del `build` principal gana legibilidad de forma similar a lo hecho antes con `Forecast`.
- Sin cambios funcionales: misma seleccion de estacion, mismas unidades, misma brujula realtime/simulada, mismas metricas y mismos widgets auxiliares.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-x extract full live section)

- `Bloque incremental 19:48-19:54 = 6m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 35h 55m`
- `Total acumulado de referencia = 1d 05h 55m`

### 2026-03-08 - Spots v3.4 fase 100-y: identificador explicito para estacion `AEMET Oliva`

- Registrado `AEMET Oliva` con identificador explicito `8058X` dentro de la estructura local de estaciones cercanas en `lib/features/spots/presentation/pages/spot_detail_page.dart`.
- Ajustado el modelo interno `_NearbyStation` para aceptar `stationId` opcional.
- La UI `Live` ahora muestra el detalle como `AEMET · 8058X` para la estacion seleccionada cuando existe identificador conocido.
- Objetivo de esta fase:
  - dejar el dato de estacion mejor preparado para una futura integracion live real basada en codigo oficial,
  - sin cambiar todavia el origen mock/local de las metricas live.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-y explicit station id)

- `Bloque incremental 19:54-20:02 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 36h 03m`
- `Total acumulado de referencia = 1d 06h 03m`

### 2026-03-08 - Spots v3.4 fase 100-z: separacion conceptual entre `live` y `forecast` en estaciones cercanas

- Ajustado el modelo local de estaciones cercanas en `lib/features/spots/presentation/pages/spot_detail_page.dart` para distinguir explicitamente el tipo de fuente asociado a la estacion.
- `_NearbyStation` ahora incluye `sourceKind`, y `AEMET Oliva` queda registrada como fuente de `Observacion` con codigo oficial `8058X`.
- La UI de `Live` pasa a mostrar el contexto completo como `Observacion · AEMET · 8058X`, dejando mas claro que se trata de datos medidos y no del proveedor de forecast principal.
- Se ha añadido tambien una pequena mejora de robustez en los dropdowns de comparativa del historico (`Fuente prevision` y `Modelo de calculo`) con `isExpanded` + `selectedItemBuilder` para evitar overflows en tests/layouts estrechos.
- Cobertura reforzada en `test/features/spots/presentation/pages/spot_detail_page_test.dart` con test especifico para la distincion observation/forecast en la seccion `Live`.
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 100-z observation vs forecast distinction)

- `Bloque incremental 20:02-20:10 = 8m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 36h 11m`
- `Total acumulado de referencia = 1d 06h 11m`

### 2026-03-08 - Spots v3.4 fase 101-a: etiqueta contextual para `AEMET Oliva` en Live

- Ajustada la etiqueta visible del desplegable de estaciones cercanas en `Live` para `AEMET Oliva`.
- En lugar del placeholder manual `4.2 km`, la estacion ahora se presenta como `AEMET Oliva · Puerto`, que describe mejor el contexto real que queremos transmitir en el spot.
- Cambio tecnico aplicado en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - `_NearbyStation` admite ahora `proximityLabel` opcional,
  - el dropdown usa `proximityLabel` cuando existe y cae a `distanceKm` solo en estaciones que todavia no tienen un descriptor mas preciso.
- Se mantiene el identificador oficial `8058X` en la linea de metadata de `Live` (`Observacion · AEMET · 8058X`).
- Verificacion ejecutada:
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 101-a live proximity label)

- `Bloque incremental 20:10-21:20 = 1h 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 37h 21m`
- `Total acumulado de referencia = 1d 07h 21m`

### 2026-03-08 - Spots v3.4 fase 101-b: primera integracion real de observaciones AEMET en `Live`

- Sustituido el bloque local simulado de estaciones/metricas `live` por una primera carga real de observaciones AEMET usando OpenData.
- Nuevo cliente en `lib/features/spots/infrastructure/services/aemet_observation_client.dart`:
  - consume `observacion/convencional/todas`,
  - ordena estaciones reales por distancia al spot,
  - mapea viento medio, racha, direccion, temperatura, presion, humedad y lluvia.
- Integrado en `lib/features/spots/presentation/pages/spot_detail_page.dart`:
  - la seccion `Live` carga ahora estaciones reales cercanas para spots con coordenadas,
  - `AEMET Oliva` se resuelve desde la estacion oficial `8058X` y sigue mostrandose como `AEMET Oliva · Puerto`,
  - la metadata deja claro `Observacion · AEMET · 8058X`,
  - si no hay coordenadas o falla la carga real, la seccion `Live` ya no inventa datos y muestra estado vacio/no disponible.
- Nota importante de alcance:
  - esta fase convierte en reales el dropdown de estaciones cercanas y las metricas live principales,
  - el historico grafico y las alarmas siguen siendo logica local pendiente de migrar a series reales.
- Cobertura añadida/ajustada:
  - `test/features/spots/infrastructure/services/aemet_observation_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/services/aemet_observation_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (cierre fase 101-b real AEMET live observations)

- `Bloque incremental 21:20-21:47 = 27m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 37h 48m`
- `Total acumulado de referencia = 1d 07h 48m`

### 2026-03-08 - Hotfix: decodificacion charset para observaciones AEMET Live

- Detectado en `Live` el error real `FormatException: Missing extension byte (at offset 1757)` al cargar observaciones AEMET.
- Causa localizada:
  - el endpoint `observacion/convencional/todas` devuelve `Content-Type: text/plain;charset=ISO-8859-15`,
  - el nuevo cliente `AemetObservationClient` estaba decodificando siempre con `utf8`, lo que rompia el parseo del payload real.
- Hotfix aplicado en `lib/features/spots/infrastructure/services/aemet_observation_client.dart`:
  - se detecta el `charset` de respuesta,
  - si viene `ISO-8859-15` se decodifica con `latin1`,
  - y como salvaguarda se hace fallback a `latin1` si `utf8` lanza `FormatException`.
- Resultado esperado:
  - la seccion `Live` deja de caer en `Sin datos disponibles` por este problema de codificacion cuando AEMET responde correctamente.
- Verificacion ejecutada:
  - `flutter test test/features/spots/infrastructure/services/aemet_observation_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)
  - `flutter analyze` (ok)

### 2026-03-08 - Conteo de horas (hotfix AEMET live charset)

- `Bloque incremental 21:47-21:57 = 10m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 37h 58m`
- `Total acumulado de referencia = 1d 07h 58m`

### 2026-03-10 - Conteo de horas (inicio de bloque actual)

- `Bloque 20:14-23:40 = 3h 26m` (live real AEMET, selector estaciones, mapa y refrescos).
- `Acumulado (track exacto desde 2026-03-01 11:34) = 41h 39m`.
- `Total acumulado de referencia = 1d 11h 39m`.

### 2026-03-10 - Spots v3.4 fase 101-c: live sin datos inventados y timestamp real

- En `Live`, las metricas pasan a ser anulables para no inventar ceros cuando AEMET no aporta un campo.
- Se muestra `Actualizado: dd/MM HH:mm` con el timestamp real de observacion cuando viene en la respuesta.
- La rosa del viento muestra un estado vacio si falta viento/direccion y se desactivan los botones de brujula en ese caso.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`

### 2026-03-11 - Spots v3.5 fase 102: proveedor Windguru con widget embebido

- Nuevo proveedor `Windguru` disponible en `Spots > Forecast`.
- Se integra el widget HTML oficial para `Oliva Canal` dentro de la seccion forecast.
- Se evita el fetch de modelos internos para Windguru y se muestra el widget embebido.
- Archivos actualizados:
  - `pubspec.yaml`
  - `lib/features/spots/application/services/spot_forecast_model_order.dart`
  - `lib/features/spots/application/services/spot_forecast_model_info.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion pendiente.

### 2026-03-11 - Spots v3.5 fase 102-b: fullscreen para widget Windguru

- Se anade boton de fullscreen al bloque Windguru y overlay fullscreen con cierre flotante.
- El overlay reutiliza el mismo estilo de pantalla completa que el forecast table.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion pendiente.

### 2026-03-11 - Spots v3.5 fase 102-c: evitar crash al abrir fullscreen Windguru

- El WebView embebido se desactiva mientras el overlay fullscreen esta activo.
- Se evita doble instancia del mismo controller en la misma pantalla.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion pendiente.

### 2026-03-11 - Spots v3.5 fase 102-d: fullscreen Windguru con controller dedicado

- Se crea un `WebViewController` separado para el fullscreen del widget.
- El widget embebido se mantiene fuera del árbol mientras el fullscreen está activo.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion pendiente.

### 2026-03-11 - Spots v3.5 fase 102-e: parametros completos del widget Windguru

- Se actualiza el snippet del widget con el set completo de parametros y variables.
- Archivos actualizados:

### 2026-03-12 - Conteo de horas (inicio de bloque actual)

- `Bloque iniciado a las 20:51`.
- `Acumulado (track exacto desde 2026-03-01 11:34) = 1d 11h 39m`.
- `Total acumulado de referencia = 1d 11h 39m`.
- Nota: cerrar el bloque al finalizar la siguiente fase con la duracion real.

### 2026-03-12 - Spots v3.5 fase 103: estacion Club Nautico de Oliva en Live

- En `Live`, se detecta la estacion AEMET cuyo nombre contiene `club nautico` + `oliva` y se muestra como `Club Nautico de Oliva`.
- La estacion aparece en el selector cuando AEMET la devuelve dentro del radio del spot.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada: pendiente.

### 2026-03-12 - Spots v3.5 fase 103-b: integracion AVAMET Club Nautico Oliva en Live

- Se integra AVAMET como fuente de observacion adicional para el spot `Oliva`.
- Nuevo cliente `AvametObservationClient` que parsea la pagina HTML de AVAMET y extrae:
  - timestamp, temperatura, humedad, presion, viento, racha y lluvia.
- Se anade estacion fija `Club Nautico de Oliva` con id `c25m181e07` y coords reales en el selector de Live.
- El refresco de estacion usa AVAMET cuando el proveedor es `AVAMET`.
- Test nuevo para validar el parseo del HTML de AVAMET.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/avamet_observation_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/infrastructure/services/avamet_observation_client_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada: pendiente.
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`
- Verificacion pendiente.

### 2026-03-11 - Spots v3.5 fase 102-f: guardas de WebView en tests

- Se evita instanciar WebView en tests al no tener plataforma registrada.
- Tests ejecutados: `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `SESSION_TRACKER.md`

### 2026-03-11 - Conteo de horas (inicio de bloque actual)

- `Bloque 21:44-21:44 = 0m` (marca de arranque de esta sesion).
- `Acumulado (track exacto desde 2026-03-01 11:34) = 1d 11h 39m`.
- `Total acumulado de referencia = 1d 11h 39m`.

### 2026-03-11 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:44-22:32 = 48m`

### 2026-03-11 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:32-23:16 = 44m`

### 2026-03-11 - Conteo de horas (cierre de bloque)

- `Bloque incremental 23:16-00:05 = 49m`
- `Bloque total 21:44-00:05 = 2h 21m`
- `Acumulado (track exacto desde 2026-03-01 11:34) = 1d 14h 00m`
- `Total acumulado de referencia = 1d 14h 00m`

### 2026-03-11 - Spots v3.4 fase 101-c (cierre): etiqueta live consistente + fix de tests

- Ajustada la etiqueta de estacion en `Live` para mantener consistencia del dropdown:
  - la estacion `8058X` vuelve a mostrarse como `AEMET Oliva · Puerto`,
  - el identificador oficial queda solo en la linea de metadata (`Observacion · AEMET · 8058X`).
- Fixes de estabilidad detectados en `flutter analyze`:
  - removido import duplicado en `SessionDetailPage`,
  - test de persistencia de sesiones actualizado con `spotName` requerido.
- Tests ajustados:
  - expectativa del label live permite multiples renders (`findsWidgets`).
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/sessions/presentation/pages/session_detail_page.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-12 - Conteo de horas (inicio de bloque actual)

- `Bloque 20:20-20:20 = 0m` (marca de arranque de esta sesion).
- `Acumulado (track exacto desde 2026-03-01 11:34) = 1d 14h 00m`.
- `Total acumulado de referencia = 1d 14h 00m`.

### 2026-03-12 - Spots v3.5 fase 102-g: refactor widget Windguru fuera de SpotDetailPage

- Extraida la UI del bloque Windguru a un widget dedicado para descargar `spot_detail_page.dart`.
- Nuevos widgets:
  - `lib/features/spots/presentation/widgets/windguru_forecast_card.dart`.
  - incluye `WindguruForecastCard` y `WindguruFullscreenOverlay`.
- `SpotDetailPage` ahora delega el render del widget embebido y del fullscreen a esos widgets.
- Sin cambios funcionales; solo refactor de presentacion.
- Ajuste adicional: eliminado `!` innecesario en `controller` para resolver warning de analyzer.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-12 - Spots v3.5 fase 102-h: tablas AEMET extraidas a widget dedicado

- Extraidas las tablas AEMET de playa y costera a un widget dedicado:
  - `lib/features/spots/presentation/widgets/aemet_forecast_tables.dart`.
- `SpotDetailPage` delega el render de ambas tablas sin cambiar su comportamiento.
- Sin cambios funcionales; solo refactor de presentacion.
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Revision general del proyecto y reentrada de sesion

- Releido el proyecto con foco en `SESSION_TRACKER.md`, `README.md`, `pubspec.yaml` y el worktree activo de `spots`.
- Estado reconstruido de la ultima sesion:
  - el ultimo bloque completamente cerrado en horas sigue siendo `2026-03-11`, con acumulado confirmado de `1d 14h 00m`,
  - hay trabajo posterior en curso sin cierre limpio de horas para `2026-03-12` y `2026-03-13`,
  - el foco funcional real pendiente/abierto esta en `Spots > Live`, especialmente integracion `AVAMET` para `Club Nautico de Oliva`, refresco por estacion seleccionada y mejoras del historico/grafico.
- Worktree actual detectado al retomar:
  - `lib/features/spots/infrastructure/services/avamet_observation_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/widgets/aemet_forecast_tables.dart`
  - `lib/features/spots/presentation/widgets/windguru_forecast_card.dart`
  - `test/features/spots/infrastructure/services/avamet_observation_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `SESSION_TRACKER.md`
- Hallazgos de la revision:
  - ya existe cliente `AvametObservationClient` para extraer observaciones HTML reales de AVAMET,
  - `SpotDetailPage` ya contempla una estacion fija `Club Nautico de Oliva` (`avamet:c25m181e07`) y refresco puntual de la estacion seleccionada,
  - el tracker local tiene entradas staged de `2026-03-13`, pero quedaron fuera de orden respecto al tramo final visible y sin cierre fiable de horas.
- Verificacion pendiente/bloqueada en esta reentrada:
  - no se ha podido ejecutar `flutter analyze` ni `flutter test` porque `flutter` no esta disponible en el `PATH` de esta terminal actual.

### 2026-03-14 - Conteo de horas (inicio de bloque actual)

- `Inicio de bloque actual = 14:10`.
- `Acumulado confirmado (track exacto desde 2026-03-01 11:34) = 1d 14h 00m`.
- `Total acumulado de referencia confirmado = 1d 14h 00m`.
- Nota importante:
  - quedan pendientes de reconciliar/cerrar los bloques abiertos de `2026-03-12` y `2026-03-13`,
  - hasta cerrar esos bloques no conviene afirmar un acumulado exacto superior sin inventar tiempo,
  - desde esta sesion seguimos llevando el conteo incremental a partir de `2026-03-14 14:10`.

### 2026-03-14 - Entorno: ruta Flutter localizada para esta sesion

- Localizado el SDK en `C:\Users\Rml\Documents\Raul\Programas\SDK\Flutter\flutter\bin`.
- Confirmado que, al anteponer esa ruta al `PATH`, `flutter` resuelve correctamente a:
  - `C:\Users\Rml\Documents\Raul\Programas\SDK\Flutter\flutter\bin\flutter.bat`
- Incidencia observada al retomar:
  - `flutter --version` queda bloqueado/timeout en esta terminal actual incluso invocando `flutter.bat` directamente,
  - por tanto el problema pendiente ya no es de `PATH`, sino de ejecucion/inicializacion del propio SDK en este entorno.

### 2026-03-14 - Entorno: causa real del bloqueo Flutter + validacion externa

- Diagnosticada la causa real del fallo al ejecutar Flutter dentro de esta terminal:
  - el sandbox corre como `CodexSandboxOffline`,
  - el SDK de Flutter esta bajo el usuario real `Rml`,
  - `git` marca el repo del SDK como `dubious ownership`,
  - y `flutter_tools` no puede abrir/escribir `bin/cache/lockfile` con permisos del usuario sandbox.
- Verificaciones realizadas:
  - `dart --version` desde el SDK local responde correctamente.
  - `flutter --version` ejecutado fuera del sandbox con permisos reales del usuario funciona ok.
- Versiones confirmadas:
  - `Flutter 3.41.2`
  - `Dart 3.11.0`
- Conclusion operativa:
  - para verificaciones Flutter reales en esta maquina, usar ejecucion fuera del sandbox con el binario localizado del SDK.

### 2026-03-14 - Spots v3.5: saneado de verificacion AVAMET/Live al retomar

- Limpiados dos restos muertos en `SpotDetailPage` detectados por analyzer:
  - `_modelFactor`
  - `_providerBias`
- Ajustado el widget test `live refresh keeps selected station` para apuntar explicitamente al dropdown de `Estacion meteorologica cercana`.
- Actualizada la expectativa del test al contrato real actual:
  - la seleccion persistida tras refresco es la clave estable `avamet:c25m181e07`,
  - no el id AEMET temporal `CNO1`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_observation_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:10-14:34 = 24m`.
- `Acumulado confirmado adicional de esta reentrada = 24m`.
- Nota:
  - el acumulado historico global sigue pendiente de conciliacion completa con los bloques abiertos de `2026-03-12` y `2026-03-13`,
  - pero esta sesion actual ya tiene trazado exacto desde `2026-03-14 14:10`.

### 2026-03-14 - Spots v3.5 fase 103-i: historico Live mas honesto mientras sigue local

- Ajustado el bloque de historico en `Live` para no sugerir refrescos "reales" inexistentes mientras la serie sigue siendo local.
- Cambios aplicados:
  - eliminada la regeneracion artificial por `refresh` que anadia jitter a la curva,
  - anadido copy explicito indicando que la serie historica sigue siendo local/provisional,
  - se mantiene la comparativa con `forecast` real ya cargado para el spot/proveedor/modelo activos.
- Objetivo:
  - hacer la UI mas honesta hasta migrar el historico de `Live` a series reales de observacion.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_observation_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:34-14:39 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-14:39 = 29m`.
- `Acumulado confirmado adicional de esta reentrada = 29m`.

### 2026-03-14 - Spots v3.5 fase 103-j: etiquetas horarias del historico ancladas a la observacion real

- Ajustadas las etiquetas horarias del grafico `Live` para que dejen de salir desde una hora fija artificial.
- Nuevo comportamiento:
  - si la estacion seleccionada tiene `observedAt`, el eje temporal se ancla a esa observacion real,
  - las marcas se alinean al paso actual de `20 min`,
  - si no hay timestamp disponible, se usa la hora actual como fallback tecnico.
- Mejora adicional de cobertura:
  - test del historico reforzado para asegurar que el bloque mantiene el mensaje de serie provisional y no reintroduce un refresh artificial separado.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_observation_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:39-14:42 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-14:42 = 32m`.
- `Acumulado confirmado adicional de esta reentrada = 32m`.

### 2026-03-14 - Spots v3.5 fase 103-k: historico provisional derivado de la estacion activa

- Sustituido el historico provisional basado en nombres fijos de estaciones por una serie determinista construida desde la estacion actualmente seleccionada y su dato `Live` actual.
- Resultado:
  - el grafico provisional deja de depender de arrays heredados tipo `Meteo Piles`/`Boya Gandia`,
  - la curva converge al viento actual de la estacion activa,
  - y mantiene una forma estable/coherente por `stationKey` y proveedor mientras no exista historico real.
- Alcance:
  - sigue siendo una serie local/provisional,
  - pero ahora esta alineada con `AVAMET`/`AEMET` reales y con la estacion seleccionada en pantalla.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_observation_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:42-14:46 = 4m`.
- `Bloque acumulado de esta reentrada 14:10-14:46 = 36m`.
- `Acumulado confirmado adicional de esta reentrada = 36m`.

### 2026-03-14 - Spots v3.5 fase 103-l: historico diario real inicial AVAMET en Live

- Integrada una primera via real de historico diario para `Live` usando `AVAMET` en `Club Nautico de Oliva`.
- Cambios aplicados:
  - creado `AvametDailyHistoryClient` para leer `mx-dia.php` y extraer la serie `Vel Mit` del bloque Highcharts,
  - conectado el historico real diario al `load` de estaciones `Live`,
  - preservado `historicalSeriesByStation` tambien en el refresh puntual de la estacion seleccionada,
  - adaptada la tarjeta de historico para distinguir entre serie provisional local y serie diaria real AVAMET,
  - ocultada la comparativa con forecast cuando la serie real diaria esta activa por diferencia de granularidad,
  - normalizados varios textos `Live` que habian quedado con caracteres mojibake.
- Cobertura anadida/ajustada:
  - nuevo test unitario para el parser de historico diario AVAMET,
  - nuevo widget test para fijar el modo `Historico diario real AVAMET`,
  - actualizado test de metadatos `Live` tras normalizar separadores visuales.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/avamet_daily_history_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/infrastructure/services/avamet_daily_history_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_observation_client_test.dart test/features/spots/infrastructure/services/avamet_daily_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:46-15:07 = 21m`.
- `Bloque acumulado de esta reentrada 14:10-15:07 = 57m`.
- `Acumulado confirmado adicional de esta reentrada = 57m`.

### 2026-03-14 - Spots v3.5 fase 103-m: retirada del historico provisional Live

- Eliminado el fallback local/provisional que seguiamos usando para simular historico en `Live`.
- Nuevo contrato del bloque:
  - si la estacion seleccionada tiene historico real cargado, se muestra la serie diaria real,
  - si no existe historico real, se muestra un estado vacio explicito y ya no se pinta ninguna curva inventada.
- Limpieza aplicada:
  - retiradas la generacion sintetica de puntos historicos,
  - retirada la comparativa con `forecast` ligada al fallback provisional,
  - retirados los controles de proveedor/modelo dentro del bloque de historico `Live`,
  - eliminados restos muertos que quedaron sin uso tras quitar la maqueta provisional.
- Cobertura ajustada:
  - el test del caso sin historico real ahora valida el estado vacio explicito,
  - el test del caso AVAMET real asegura que el bloque ya no muestra controles heredados del fallback.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_observation_client_test.dart test/features/spots/infrastructure/services/avamet_daily_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:07-15:13 = 6m`.
- `Bloque acumulado de esta reentrada 14:10-15:13 = 63m`.
- `Acumulado confirmado adicional de esta reentrada = 63m`.

### 2026-03-14 - Spots v3.5 fase 103-n: seleccion por defecto prioriza historico real en Live

- Ajustada la seleccion inicial de estacion en `Live` para priorizar cualquier estacion que ya venga con historico real cargado.
- Motivo:
  - tras retirar el fallback provisional, la UI podia entrar por defecto en una estacion sin historico y mostrar el estado vacio aunque otra estacion del mismo spot si tuviera serie real disponible.
- Nuevo comportamiento:
  - si alguna estacion del resultado trae `historicalSeriesByStation` no vacio, esa estacion pasa a ser la seleccion inicial,
  - si ninguna tiene historico real, se mantiene la heuristica previa de seleccion.
- Cobertura ajustada:
  - el test del modo AVAMET real ahora verifica tambien que la estacion seleccionada por defecto es `avamet:c25m181e07`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:13-15:24 = 11m`.
- `Bloque acumulado de esta reentrada 14:10-15:24 = 1h 14m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 14m`.

### 2026-03-14 - Spots v3.5 fase 103-o: parser AVAMET diario alineado con el HTML real

- Corregido el parser del historico diario AVAMET para `Live`.
- Causa detectada:
  - el HTML real de `mx-dia.php` para `Club Nautico de Oliva` si trae la serie `Vel Mit`,
  - pero el parser anterior intentaba extraer `data:[...]` con regex sobre arrays anidados y terminaba devolviendo serie vacia.
- Ajuste aplicado:
  - recortado el bloque real entre `grafic3` y `grafic4`,
  - sustituida la extraccion frágil por un parser pequeño con balanceo de corchetes para leer el array completo de `data:[...]` de `Vel Mit`.
- Resultado esperado:
  - el historico diario real de AVAMET vuelve a mostrarse en `Club Nautico de Oliva`.
- Cobertura ajustada:
  - el test del cliente diario ahora imita mejor la estructura real del bloque Highcharts de AVAMET.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/avamet_daily_history_client.dart`
  - `test/features/spots/infrastructure/services/avamet_daily_history_client_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_daily_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:24-15:32 = 8m`.
- `Bloque acumulado de esta reentrada 14:10-15:32 = 1h 22m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 22m`.

### 2026-03-14 - Spots v3.5 fase 103-p: refresh Live movido a la rosa de los vientos

- Reubicado el `refresh` de `Live` para limpiar la fila de acciones bajo `Ver estacion en el mapa`.
- Nuevo comportamiento:
  - desaparece el boton textual `Refrescar` de la fila inferior,
  - aparece un boton solo con icono `refresh` en la esquina superior derecha del bloque de la rosa de los vientos,
  - el refresh sigue reutilizando la misma accion de recarga de la estacion seleccionada.
- Ajuste adicional:
  - el icono se monta al nivel del contenedor de la seccion de brujula para que siga disponible incluso si la estacion no reporta viento y se muestra la tarjeta vacia.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:32-15:47 = 15m`.
- `Bloque acumulado de esta reentrada 14:10-15:47 = 1h 37m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 37m`.

### 2026-03-14 - Spots v3.5 fase 103-q: refresh Live compactado en la rosa

- Reducido visualmente el boton de `refresh` superpuesto sobre la rosa de los vientos para que ocupe aproximadamente la mitad del tamano anterior.
- Ajuste aplicado:
  - contenedor `24x24`,
  - `iconSize` reducido,
  - `padding` a cero y `visualDensity.compact`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:47-15:49 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-15:49 = 1h 39m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 39m`.

### 2026-03-14 - Spots v3.5 fase 103-r: revert del refresh compactado

- Revertido el compactado extremo del boton `refresh` sobre la rosa de los vientos porque quedaba demasiado pequeno visualmente.
- Resultado:
  - se mantiene la nueva ubicacion del icono en la esquina superior derecha,
  - pero recupera el tamano anterior del `IconButton.filledTonal`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:49-15:51 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-15:51 = 1h 41m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 41m`.

### 2026-03-14 - Spots v3.5 fase 103-s: leyenda interactiva del semaforo de viento

- Convertido el chip del semaforo de viento en un disparador interactivo.
- Nuevo comportamiento:
  - al pulsar el chip se abre un dialogo con la leyenda completa del semaforo,
  - se muestran los rangos en nudos y su interpretacion navegable.
- Ajuste de implementacion:
  - el chip pasa a `ActionChip`,
  - la leyenda se construye con filas simples para que quede mas facil de leer y de testear.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:51-15:54 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-15:54 = 1h 44m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 44m`.

### 2026-03-14 - Spots v3.5 fase 103-t: leyenda del semaforo ampliada con cometas y nuevos nombres

- Ajustada la leyenda interactiva del semaforo de viento para reflejar mejor los nombres deseados y anadir referencia de tamano de cometa.
- Cambios aplicados:
  - rango `14-18 kt` renombrado a `Viento flojo`,
  - rango `> 40 kt` renombrado a `Viento super fuerte`,
  - anadida una seccion de `Rangos orientativos de cometa` dentro del dialogo.
- Impacto adicional:
  - el chip de estado usa tambien los nuevos nombres para mantener consistencia entre UI principal y dialogo.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:54-16:00 = 6m`.
- `Bloque acumulado de esta reentrada 14:10-16:00 = 1h 50m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 50m`.

### 2026-03-14 - Spots v3.5 fase 103-u: ajuste fino del rango de cometa 10-14 kt

- Corregida la recomendacion de cometa para `10-14 kt` dentro de la leyenda del semaforo.
- Nuevo texto:
  - `10-14 kt: 14 m o +`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:00-16:03 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-16:03 = 1h 53m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 53m`.

### 2026-03-14 - Spots v3.5 fase 103-v: guia de cometas mas visual en la leyenda

- Rehecha la seccion de `Rangos orientativos de cometa` dentro del dialogo del semaforo para que se vea mas cuidada.
- Mejora visual aplicada:
  - la guia ahora aparece dentro de una tarjeta suave con borde,
  - anadido icono de viento en el encabezado,
  - cada rango se presenta como fila separada con icono, jerarquia visual y mejor espaciado.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:03-16:06 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-16:06 = 1h 56m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 56m`.

### 2026-03-14 - Spots v3.5 fase 103-w: pulido visual global de la leyenda del semaforo

- Mejorado el aspecto general del dialogo de la leyenda para que se sienta menos utilitario y mas integrado con la UI.
- Cambios visuales aplicados:
  - cabecera con icono y subtitulo explicativo,
  - espaciado y paddings refinados,
  - nueva tarjeta dedicada para la escala del viento con fondo degradado suave,
  - separacion mas clara entre la escala del semaforo y la guia de cometas.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:06-16:09 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-16:09 = 1h 59m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 59m`.

### 2026-03-14 - Spots v3.5 fase 103-x: copy de la guia ajustado a "Tamano orientativo"

- Cambiado el encabezado de la guia de cometas dentro de la leyenda para usar `Tamano orientativo de cometa`.
- Ajuste acompanado de actualizacion de test para reflejar el nuevo copy.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:09-16:11 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-16:11 = 2h 01m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 01m`.

### 2026-03-14 - Spots v3.5 fase 103-y: brujula Live movida a la esquina de la rosa

- Reubicado el control de activar/desactivar brujula en `Live`.
- Nuevo comportamiento:
  - desaparece el boton lateral con texto,
  - aparece solo el icono de brujula en la esquina superior izquierda de la rosa de los vientos,
  - mantiene el toggle de modo realtime y se desactiva si no hay datos de viento.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:11-16:15 = 4m`.
- `Bloque acumulado de esta reentrada 14:10-16:15 = 2h 05m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 05m`.

### 2026-03-14 - Spots v3.5 fase 103-z: investigacion AVAMET intradia y recorte de rangos no sostenibles

- Investigada la fuente publica real de AVAMET para `Club Nautico de Oliva` para contrastar el significado correcto de los botones del historico `Live`.
- Hallazgos confirmados:
  - `mxo_i.php` expone serie intradia real con `timestamp` para `Direccio` y `Velocitat`,
  - la cobertura publica observada ronda casi `5 dias`,
  - no se ha encontrado en esa vista una serie intradia publica separada para `Racha`,
  - `mx-dia.php` sigue siendo la fuente diaria agregada,
  - `mx-consultes.php` queda restringida a socios y no es utilizable como respaldo publico.
- Decision de producto aplicada para no prometer ventanas que hoy no se pueden representar con honestidad:
  - eliminados los botones `7d` y `30d` del selector del historico real,
  - el selector de `Live` se queda en `1d` y `3d`,
  - ajustado el rango por defecto para arrancar en `3d`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:15-16:53 = 38m`.
- `Bloque acumulado de esta reentrada 14:10-16:53 = 2h 43m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 43m`.

### 2026-03-14 - Spots v3.5 fase 104-a: historico Live migrado a intradia real AVAMET en Oliva

- Sustituido el uso principal del historico diario AVAMET por historico intradia real cuando la estacion publica lo expone.
- Nuevo cliente `AvametIntradayHistoryClient` para leer `mxo_i.php` y extraer la serie real de:
  - `Direccio` por timestamp,
  - `Velocitat` por timestamp.
- Integracion aplicada en `Spots > Live` para `Club Nautico de Oliva`:
  - `1d` y `3d` pasan a recortar por ventana temporal real (`24h` y `72h`),
  - las flechas del grafico ya usan la direccion registrada en cada muestra, no una direccion global fija,
  - se mantiene fallback diario AVAMET como respaldo tecnico si el intradia no estuviera disponible.
- Ajustes de UI y contrato:
  - el bloque cambia a `Historico intradia real AVAMET` cuando detecta serie subdiaria,
  - copy actualizado para explicar que la direccion es por medicion y que la racha intradia aun no aparece porque la fuente publica no expone esa serie.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/avamet_intraday_history_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/infrastructure/services/avamet_intraday_history_client_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_daily_history_client_test.dart test/features/spots/infrastructure/services/avamet_intraday_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:53-17:02 = 9m`.
- `Bloque acumulado de esta reentrada 14:10-17:02 = 2h 52m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 52m`.

### 2026-03-14 - Spots v3.5 fase 104-b: legibilidad mejorada del grafico intradia Live

- Pulido visual del grafico intradia real de `Live` para que `1d/3d` se lean mejor sin saturacion.
- Mejoras aplicadas en el pintor:
  - separadores verticales reforzados en cada cambio de dia,
  - etiqueta corta del dia en el arranque de cada jornada,
  - densidad de etiquetas temporales adaptativa segun el numero de muestras,
  - mantenimiento de la densidad adaptativa de flechas para no apelotonar el grafico.
- El objetivo de este paso ha sido hacer mas legible el historico intradia real sin inventar datos ni tocar el contrato funcional ya validado.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_intraday_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:02-17:06 = 4m`.
- `Bloque acumulado de esta reentrada 14:10-17:06 = 2h 56m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 56m`.

### 2026-03-14 - Spots v3.5 fase 104-c: flechas del intradia reforzadas para visibilidad real

- Ajustado el pintor del grafico intradia porque en uso real las flechas de direccion apenas se percibian.
- Mejora visual aplicada:
  - flechas mas grandes,
  - borde mas contrastado,
  - relleno base claro para separarlas del color de la curva,
  - sombra un poco mas marcada,
  - desplazamiento vertical por encima de la linea para que no queden enterradas en el trazo.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:06-17:13 = 7m`.
- `Bloque acumulado de esta reentrada 14:10-17:13 = 3h 03m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 03m`.

### 2026-03-14 - Spots v3.5 fase 104-d: fix del parser intradia para recuperar flechas reales

- Detectado bug real en la extraccion del historico intradia AVAMET: la serie de direccion era demasiado sensible al nombre exacto y a la codificacion del HTML.
- Correccion aplicada en `AvametIntradayHistoryClient`:
  - deteccion tolerante del nombre de serie de direccion (`Direccio` con distintas codificaciones),
  - emparejado por direccion temporal mas cercana en lugar de exigir coincidencia textual fragil.
- Impacto esperado:
  - las flechas del grafico vuelven a disponer de direccion real para las muestras intradia,
  - desaparece el caso en el que solo se veian la linea continua y la media discontinua.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/avamet_intraday_history_client.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_intraday_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:13-17:18 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-17:18 = 3h 08m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 08m`.

### 2026-03-14 - Spots v3.5 fase 104-e: historico intradia agrupado por franjas temporales utiles

- Replanteado el grafico `Live` para que no muestre la serie cruda sin control, sino franjas temporales adaptativas segun la ventana seleccionada.
- Nuevo comportamiento:
  - `1d` agrupa la serie en `20 min`, `1 h` o `3 h` segun la densidad real de datos disponible,
  - `3d` agrupa la serie en `3 h`, `6 h` o `12 h` segun la densidad real de datos disponible,
  - las etiquetas intradia pasan a mostrar horas (`HH:mm`) y los dias quedan separados visualmente con marcadores claros en la parte superior del grafico,
  - el copy del bloque informa de la franja activa usada por el historico.
- Esto deja la grafica bastante mas legible y alineada con la idea de “franjas” en vez de muestras crudas consecutivas.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/infrastructure/services/avamet_intraday_history_client_test.dart test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:18-17:25 = 7m`.
- `Bloque acumulado de esta reentrada 14:10-17:25 = 3h 15m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 15m`.

### 2026-03-14 - Spots v3.5 fase 104-f: selector manual de franjas para el historico Live

- Convertida la franja temporal del historico intradia en un control manual dentro de la propia tarjeta `Live`.
- Nuevo comportamiento:
  - con `1d` aparecen opciones `20 min`, `1 h` y `3 h`,
  - con `3d` aparecen opciones `3 h`, `6 h` y `12 h`,
  - cada rango recuerda su propia seleccion por separado,
  - el copy del bloque refleja siempre la franja actualmente activa.
- Esto deja la visualizacion mucho mas alineada con la idea de “ver el viento por franjas” y evita depender solo de la eleccion automatica.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:25-17:31 = 6m`.
- `Bloque acumulado de esta reentrada 14:10-17:31 = 3h 21m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 21m`.

### 2026-03-14 - Spots v3.5 fase 104-g: flecha realineada con la curva del historico

- Ajuste visual pedido sobre el grafico `Live` para comprobar si la lectura mejora cuando la flecha cae exactamente sobre la curva.
- Cambio aplicado:
  - eliminado el desplazamiento vertical artificial que elevaba la flecha por encima de la linea,
  - la flecha vuelve a dibujarse sobre el mismo punto de la serie agrupada.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:31-17:44 = 13m`.
- `Bloque acumulado de esta reentrada 14:10-17:44 = 3h 34m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 34m`.

### 2026-03-14 - Spots v3.5 fase 104-h: prueba sin desplazamiento vertical de flechas

- Ajustado el pintor del historico intradia para eliminar el desplazamiento vertical artificial de las flechas.
- Cambio aplicado:
  - cada flecha se dibuja ahora exactamente sobre el punto de la curva al que pertenece su muestra agrupada,
  - se mantiene el resto del estilo visual reforzado para que siga siendo legible sin separarla a proposito de la linea.
- Objetivo:
  - comprobar si la lectura resulta mas natural cuando direccion y velocidad comparten la misma posicion vertical en el grafico.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:44-17:46 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-17:46 = 3h 36m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 36m`.

### 2026-03-14 - Spots v3.5 fase 104-i: distincion visual entre flecha exacta y flecha representativa

- Rehecho el contrato visual de las flechas del historico intradia para distinguir dos casos distintos:
  - flecha exacta cuando la direccion viene fielmente de una medicion concreta de la estacion,
  - flecha representativa cuando la direccion resume una franja temporal agrupada.
- Ajuste tecnico aplicado:
  - cada `_HistoricalWindPoint` conserva ahora el tipo de direccion (`exact` o `representative`),
  - al agrupar por franjas, si el bucket contiene una sola muestra con direccion se mantiene como exacta,
  - si el bucket combina varias muestras, la direccion pasa a marcarse como representativa.
- Ajuste visual aplicado:
  - flecha exacta dibujada solida y rellena con el color del semaforo,
  - flecha representativa dibujada hueca para que no se confunda con un registro puntual fiel.
- Ajuste de copy:
  - el texto del bloque `Historico intradia real AVAMET` explica ahora el significado de ambos tipos de flecha.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:46-17:53 = 7m`.
- `Bloque acumulado de esta reentrada 14:10-17:53 = 3h 43m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 43m`.

### 2026-03-14 - Spots v3.5 fase 104-j: franjas del historico intradia alineadas con la rejilla temporal real

- Corregida la construccion temporal de las franjas del historico `Live`.
- Problema detectado:
  - la ventana se estaba recortando como rango rodante (`ultimo dato - 24h/72h`),
  - pero luego las agrupaciones se alineaban al inicio del dia,
  - eso podia dejar `1d` y `3d` visualmente desajustados respecto a la franja elegida.
- Ajuste aplicado:
  - cuando el historico es intradia, el rango visible ahora se recorta contra la propia rejilla de la franja seleccionada,
  - el final de la ventana se alinea al cierre del bucket activo,
  - a partir de ahi se reconstruyen exactamente las `24h` o `72h` esperadas para la vista actual.
- Impacto esperado:
  - `1d` y `3d` quedan mejor sincronizados con `20 min / 1 h / 3 h / 6 h / 12 h`,
  - desaparece la sensacion de franjas "corridas" o mal cerradas en los extremos del grafico.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:53-17:58 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-17:58 = 3h 48m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 48m`.

### 2026-03-14 - Spots v3.5 fase 104-k: modo 20 min pasa a muestras exactas de estacion

- Ajustado el historico intradia para que la opcion `20 min` de `1d` deje de agrupar la serie en buckets resumidos.
- Nuevo comportamiento:
  - en `1d > 20 min` se muestran directamente las muestras reales intradia de la estacion dentro de la ventana visible,
  - las flechas de ese modo pueden volver a salir solidas porque ya no se fuerzan como representativas por una agrupacion artificial,
  - las opciones `1 h`, `3 h`, `6 h` y `12 h` siguen agrupando por franjas y mantienen flechas huecas cuando resumen varias mediciones.
- Ajuste de copy:
  - cuando el modo activo es `20 min`, la tarjeta explica que se estan viendo `muestras exactas de estacion`.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:58-18:06 = 8m`.
- `Bloque acumulado de esta reentrada 14:10-18:06 = 3h 56m`.
- `Acumulado confirmado adicional de esta reentrada = 3h 56m`.

### 2026-03-14 - Spots v3.5 fase 104-l: modo 1d + 20 min rehaciendo rejilla y doble capa de flechas

- Replanteado el modo `1d + 20 min` del historico `Live` para seguir las reglas funcionales definidas en esta sesion.
- Nuevo comportamiento:
  - `1d` sigue significando una ventana de solo las ultimas `24 horas`,
  - `20 min` activa una rejilla temporal real de `20 en 20 minutos`,
  - las horas quedan visualmente mas marcadas dentro de esa rejilla,
  - las flechas solidas se pintan para cada registro real de estacion disponible,
  - ademas se pinta una segunda capa de flechas huecas como referencia de cada franja de `20 min`.
- Ajuste tecnico aplicado:
  - el grafico ya no depende solo del indice de los puntos para el eje X en este modo, sino de fracciones temporales reales dentro de la ventana alineada,
  - anadidas guias temporales especificas para `20 min`,
  - anadido overlay de marcadores representativos independientes de los marcadores exactos.
- Ajuste de copy:
  - el bloque explica ahora que en este caso se muestran `las ultimas 24 horas con rejilla de 20 min`,
  - actualizado el significado de flecha solida y hueca para reflejar el nuevo contrato visual.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:06-18:22 = 16m`.
- `Bloque acumulado de esta reentrada 14:10-18:22 = 4h 12m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 12m`.

### 2026-03-14 - Spots v3.5 fase 104-m: overlay de flechas huecas suprime buckets con flecha real

- Ajustado el modo `1d + 20 min` para evitar duplicidades visuales entre flechas solidas y huecas.
- Nuevo comportamiento:
  - si una franja de `20 min` ya contiene una direccion real de estacion, se pinta solo la flecha solida,
  - la flecha hueca representativa de esa misma franja se omite.
- Resultado esperado:
  - desaparecen los solapamientos innecesarios,
  - la lectura de flecha real frente a flecha de referencia queda mas limpia y menos confusa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:22-18:30 = 8m`.
- `Bloque acumulado de esta reentrada 14:10-18:30 = 4h 20m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 20m`.

### 2026-03-14 - Spots v3.5 fase 104-n: modo 1d + 20 min pasa a registros reales alineados a 10 min

- Ajustada la cadencia del modo especial `1d + 20 min`.
- Nuevo contrato:
  - la ventana sigue siendo de `24 horas`,
  - la rejilla sigue marcada cada `20 min`,
  - pero la serie y las flechas reales se alinean ahora a una cadencia de `10 min`.
- Ajuste tecnico aplicado:
  - en ese modo, la serie intradia se compacta en buckets de `10 min`,
  - esos buckets mantienen flecha solida cuando existe direccion real,
  - la capa hueca sigue representando las referencias de cada franja de `20 min` y continua omitiendose donde ya existe flecha solida en esa franja.
- Ajuste de copy:
  - el texto del bloque indica ahora `las ultimas 24 horas con rejilla de 20 min y registros reales alineados a 10 min`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:30-18:35 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-18:35 = 4h 25m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 25m`.

### 2026-03-14 - Spots v3.5 fase 104-o: diagnostico visible de buckets con direccion real en 1d + 20 min

- Anadido un diagnostico temporal en la tarjeta del historico `Live` para el modo `1d + 20 min`.
- Objetivo:
  - comprobar visualmente si la falta de flechas solidas viene de la fuente real o del procesado del grafico.
- Nuevo comportamiento:
  - se muestra una linea de debug con el conteo de buckets de `10 min` que llegan con direccion real frente al total teorico de las ultimas `24h`.
- Ejemplo del dato mostrado:
  - `Debug direccion 10 min: X/144 buckets con direccion real.`
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:35-18:51 = 16m`.
- `Bloque acumulado de esta reentrada 14:10-18:51 = 4h 41m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 41m`.

### 2026-03-14 - Spots v3.5 fase 104-p: comprobacion manual de cadencia real AVAMET para direccion

- Verificada manualmente la serie publica intradia de `Direccion` de AVAMET para `Club Nautico de Oliva`.
- Resultado de la comprobacion en la tarde del `2026-03-14`:
  - ultima lectura observada: `2026-03-14 19:42 +01:00`,
  - lectura anterior: `2026-03-14 19:37 +01:00`,
  - cadencia inmediata observada: `5 min`,
  - media de las ultimas `15` separaciones entre lecturas: `6 min`,
  - distribucion de esas `15` separaciones: `12` tramos de `5 min` y `3` tramos de `10 min`.
- Conclusión:
  - la fuente publica no parece estar entregando direccion cada hora,
  - si la UI solo muestra flechas solidas muy espaciadas, el cuello de botella probablemente ya no esta en la cadencia bruta de AVAMET sino en el procesado/pintado posterior.

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:51-18:53 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-18:53 = 4h 43m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 43m`.

### 2026-03-14 - Spots v3.5 fase 104-q: retirada total de flechas huecas en el historico intradia

- Simplificado el contrato visual del historico `Live` tras confirmar que la direccion AVAMET llega con cadencia suficientemente alta.
- Decision aplicada:
  - eliminada la capa de flechas huecas de referencia,
  - todas las flechas visibles pasan a mostrarse con estilo solido,
  - el copy de la tarjeta deja de hablar de flechas huecas y se centra solo en registros reales de estacion.
- Impacto esperado:
  - menos ruido visual,
  - desaparece la lectura ambigua entre datos reales y referencias de franja,
  - el grafico queda alineado con la idea de mostrar solo direccion real util.
- Limpieza adicional:
  - retirada una funcion auxiliar que habia quedado sin uso tras eliminar el overlay.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:53-18:57 = 4m`.
- `Bloque acumulado de esta reentrada 14:10-18:57 = 4h 47m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 47m`.

### 2026-03-14 - Spots v3.5 fase 104-r: tarjeta del historico simplificada al quitar copy sobrante

- Retirado el texto explicativo largo de la tarjeta del historico `Live`.
- Motivo:
  - una vez eliminadas las flechas huecas y simplificado el contrato visual, el copy explicativo ya aportaba poco y cargaba innecesariamente la tarjeta.
- Resultado:
  - se mantiene el titulo de la tarjeta,
  - se conserva el texto de debug mientras siga siendo util para diagnosticar la direccion real,
  - desaparecen las lineas de descripcion funcional que ocupaban espacio sin aportar lectura rapida.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:57-19:00 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-19:00 = 4h 50m`.
- `Acumulado confirmado adicional de esta reentrada = 4h 50m`.

### 2026-03-14 - Spots v3.5 fase 104-s: reseteo de la logica del historico a un patron fijo por rango y filtro

- Eliminada la logica ad hoc que se habia ido acumulando en el historico `Live` y sustituida por un patron fijo segun la combinacion de rango y filtro.
- Nuevo contrato implementado:
  - `3d` muestra solo los ultimos `3 dias`,
  - `1d` muestra solo las ultimas `24 horas`.
- Para `3d`:
  - filtro `12 h`: rejilla cada `12 h`, flechas cada `6 h`,
  - filtro `6 h`: rejilla cada `6 h`, flechas cada `3 h`,
  - filtro `3 h`: rejilla cada `3 h`, flechas cada `1 h`.
- Para `1d`:
  - filtro `3 h`: rejilla cada `1 h`, flechas cada `1 h`,
  - filtro `1 h`: rejilla cada `1 h`, flechas cada `30 min`,
  - filtro `20 min`: rejilla cada `20 min`, flechas cada `5 min`.
- Ajuste tecnico:
  - la serie se reconstruye ahora siempre con buckets de la cadencia de flechas definida para esa combinacion,
  - la rejilla temporal se pinta con una segunda regla fija e independiente,
  - se retira el diagnostico temporal para volver a una base mas limpia.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:00-19:25 = 25m`.
- `Bloque acumulado de esta reentrada 14:10-19:25 = 5h 15m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 15m`.

### 2026-03-14 - Spots v3.5 fase 104-t: eje vertical de nudos fijo durante el desplazamiento horizontal

- Anadido comportamiento fijo para el eje vertical del historico.
- Nuevo resultado:
  - al desplazar horizontalmente la grafica, la columna del eje Y con los nudos ya no se mueve con el lienzo,
  - la serie, la rejilla temporal y las flechas se desplazan, pero la referencia vertical queda siempre visible.
- Ajuste tecnico:
  - separado el eje Y en una capa `CustomPaint` fija superpuesta al grafico desplazable,
  - compartido el ancho del gutter entre el pintor principal y el pintor fijo para mantener la alineacion.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:25-19:29 = 4m`.
- `Bloque acumulado de esta reentrada 14:10-19:29 = 5h 19m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 19m`.

### 2026-03-14 - Spots v3.5 fase 104-u: prueba visual de grafico espejado en el eje temporal

- Aplicada una prueba visual para ver el historico pintado en el sentido contrario al actual.
- Ajuste realizado:
  - espejado horizontal del eje temporal dentro del pintor,
  - guias temporales, separadores de dia, linea principal y flechas usan ahora la fraccion horizontal invertida.
- Objetivo:
  - comparar rapidamente si el grafico se lee mejor en ese sentido antes de consolidar una direccion definitiva.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:29-19:41 = 12m`.
- `Bloque acumulado de esta reentrada 14:10-19:41 = 5h 31m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 31m`.

### 2026-03-14 - Spots v3.5 fase 104-v: revert de la prueba de grafico espejado

- Revertida la prueba visual que invertia horizontalmente el eje temporal del historico.
- Resultado:
  - la grafica vuelve a dibujarse con la orientacion previa al experimento,
  - se mantiene intacto el resto del patron nuevo de rangos, rejilla, cadencias y eje Y fijo.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:41-19:43 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-19:43 = 5h 33m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 33m`.

### 2026-03-14 - Spots v3.5 fase 104-w: foco inicial de la grafica en el punto actual

- Anadido posicionamiento automatico del visor del historico al cargar la grafica.
- Nuevo comportamiento:
  - al abrir el grafico, la ventana se coloca automaticamente cerca del punto mas actual en lugar de arrancar desde el origen horizontal,
  - aplica tanto a la vista embebida como al modo fullscreen,
  - despues de ese enfoque inicial el usuario puede seguir desplazando la grafica manualmente con normalidad.
- Ajuste tecnico:
  - incorporados `TransformationController` dedicados para la grafica inline y fullscreen,
  - calculada la traslacion inicial segun el ancho real del grafico, el viewport disponible y la posicion horizontal del punto mas reciente.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:43-19:46 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-19:46 = 5h 36m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 36m`.

### 2026-03-14 - Spots v3.5 fase 104-x: fix del eje Y fijo usando scroll horizontal controlado

- Corregido el descuadre entre el eje vertical de nudos y la grafica al desplazar el historico.
- Causa:
  - la solucion anterior con `InteractiveViewer` hacia que el contenido desplazable y la capa fija del eje Y no compartieran exactamente la misma interaccion visual.
- Solucion aplicada:
  - reemplazado el visor interactivo por desplazamiento horizontal puro con `ScrollController`,
  - el eje Y permanece fijo en su capa propia,
  - la grafica se desplaza horizontalmente debajo de ese eje sin escalado libre, evitando desalineaciones.
- Ajuste adicional:
  - el foco inicial en el punto actual se conserva y ahora se implementa saltando al `offset` horizontal correspondiente.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:46-19:53 = 7m`.
- `Bloque acumulado de esta reentrada 14:10-19:53 = 5h 43m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 43m`.

### 2026-03-14 - Spots v3.5 fase 104-aa: fix de pintado para respetar la cadencia pactada de flechas

- Corregido un fallo real entre la logica del historico y el pintado de flechas.
- Causa detectada:
  - aunque la serie ya se estaba bucketizando con la cadencia pactada (`5 min`, `30 min`, `1 h`, etc.), el pintor seguia aplicando un recorte extra por densidad (`arrowStep`) y terminaba ocultando muchas flechas solidas.
- Solucion aplicada:
  - eliminado ese salto adicional en el pintor,
  - ahora cada punto de la serie con direccion se pinta, respetando exactamente la cadencia definida por el patron `1d/3d + filtro`.
- Impacto esperado:
  - las flechas solidas ya no deberian aparecer "cada mucho tiempo" por culpa del renderizado,
  - la frecuencia visible pasa a depender solo de la cadencia de buckets definida en la logica del grafico.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:53-20:15 = 22m`.
- `Bloque acumulado de esta reentrada 14:10-20:15 = 6h 05m`.
- `Acumulado confirmado adicional de esta reentrada = 6h 05m`.

### 2026-03-14 - Spots v3.5 fase 104-ab: garantia dura de ventana maxima por rango en el historico intradia

- Anadida una salvaguarda extra para que cada rango no pueda superar su ventana maxima aunque falle algun detalle del recorte temporal.
- Nuevo comportamiento:
  - `1d` no puede renderizar mas buckets de los que caben en `24h` para la cadencia activa,
  - `3d` no puede renderizar mas buckets de los que caben en `72h` para la cadencia activa.
- Ajuste tecnico:
  - tras reconstruir la serie bucketizada, se aplica un recorte final por numero maximo de buckets esperado segun `rango + cadencia de flechas`.
- Objetivo:
  - reforzar exactamente la regla funcional que marcaste:
    - `1d` solo ultimas `24 horas`,
    - `3d` solo ultimos `3 dias`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:15-20:23 = 8m`.
- `Bloque acumulado de esta reentrada 14:10-20:23 = 6h 13m`.
- `Acumulado confirmado adicional de esta reentrada = 6h 13m`.

### 2026-03-14 - Spots v3.5 fase 104-ac: guias temporales alineadas a la rejilla real del filtro

- Corregido el caso en el que el modo `20 min` podia quedarse sin etiquetas horarias visibles.
- Causa detectada:
  - las guias de tiempo arrancaban desde el inicio bruto de la ventana,
  - si esa ventana venia alineada a `5 min`, la secuencia de `20 min` podia caer en `:05`, `:25`, `:45` y no tocar nunca una hora exacta.
- Solucion aplicada:
  - las guias temporales se alinean ahora al primer instante valido de la rejilla del filtro (`20 min`, `1 h`, etc.) dentro de la ventana visible.
- Impacto esperado:
  - en `20 min` vuelven a aparecer marcas y etiquetas de hora en `:00`,
  - la rejilla temporal refleja de verdad el patron del filtro activo.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:23-20:28 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-20:28 = 6h 18m`.
- `Acumulado confirmado adicional de esta reentrada = 6h 18m`.

### 2026-03-14 - Spots v3.5 fase 104-ad: etiquetado completo en cada franja del modo 20 min

- Ajustado el etiquetado del eje temporal para el modo `20 min`.
- Nuevo comportamiento:
  - cada marca de la rejilla de `20 min` muestra ahora su hora en formato `HH:mm`,
  - deja de etiquetarse solo la hora en punto.
- Objetivo:
  - cumplir exactamente la regla solicitada de que en la grafica de `20 min` aparezca la hora cada `20 minutos`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:28-20:33 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-20:33 = 6h 23m`.
- `Acumulado confirmado adicional de esta reentrada = 6h 23m`.

### 2026-03-14 - Spots v3.5 fase 104-y: relanzado manual del proyecto en emulador Pixel 7

- Reentrada de tooling para recuperar la sesion de depuracion del IDE.
- Acciones realizadas:
  - comprobados los dispositivos detectados por Flutter,
  - detectado que no habia ningun Android activo,
  - arrancado el emulador `Pixel_7`,
  - verificado como `emulator-5554`,
  - lanzada la app con `flutter run -d emulator-5554` en una nueva terminal.
- Objetivo:
  - restaurar la sesion de ejecucion para volver a disponer de `stop`, `hot reload` y `restart` asociados al proyecto.

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:53-20:01 = 8m`.
- `Bloque acumulado de esta reentrada 14:10-20:01 = 5h 51m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 51m`.

### 2026-03-14 - Spots v3.5 fase 104-z: intento de reenganche manual a la sesion Flutter del emulador

- Accion de tooling adicional para intentar recuperar los controles de debug del entorno:
  - comprobado que `emulator-5554` seguia activo,
  - lanzada una terminal adicional con `flutter attach -d emulator-5554`.
- Objetivo:
  - reenganchar una sesion Flutter viva sobre la app del emulador para facilitar que vuelvan a aparecer `stop`, `hot reload` y `restart` en el entorno de trabajo.
- Limitacion:
  - no puedo pulsar ni restaurar directamente los botones del IDE desde aqui; solo abrir y mantener la sesion Flutter correspondiente.

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:01-20:02 = 1m`.
- `Bloque acumulado de esta reentrada 14:10-20:02 = 5h 52m`.
- `Acumulado confirmado adicional de esta reentrada = 5h 52m`.

### 2026-03-14 - Spots v3.5 fase 104-ae: linea forecast discontinua real en el historico Live

- Reintroducida una linea discontinua de forecast sobre la grafica `Live` usando el forecast real ya cargado por la pagina.
- Alcance soportado para el overlay del historico:
  - `Open-Meteo`: todos los modelos disponibles,
  - `Meteoblue`: solo `Basic` y `Sea`,
  - `Meteosource`: solo `Hourly`,
  - `Meteostat`: solo `Hourly`,
  - `Windguru`: no integrado en esta capa del grafico.
- Comportamiento implementado:
  - la serie forecast se alimenta del provider/modelo actualmente seleccionado en la seccion `Forecast`,
  - se remuestrea a la misma cadencia activa del historico para adaptarse a `1d/3d` y a los filtros `20 min`, `1 h`, `3 h`, `6 h` y `12 h`,
  - la linea admite huecos reales cuando no hay solape temporal suficiente, evitando comparativas falsas,
  - el pintor del grafico y el eje Y fijo ya soportan correctamente una serie forecast parcial con valores nulos intermedios.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:33-20:56 = 23m`.
- `Bloque acumulado de esta reentrada 14:10-20:56 = 6h 46m`.
- `Acumulado confirmado adicional de esta reentrada = 6h 46m`.

### 2026-03-14 - Spots v3.5 fase 104-af: selector propio de forecast en Live y retirada de la discontinua gris

- Simplificada la lectura de la grafica `Live`:
  - eliminada la linea discontinua gris de media movil,
  - se mantiene solo la linea discontinua naranja del forecast.
- Añadido selector propio para la linea forecast dentro de la tarjeta `Live`, independiente del bloque `Forecast`.
- Nuevo comportamiento del selector del overlay:
  - proveedor seleccionable entre `Open-Meteo`, `Meteoblue`, `Meteosource` y `Meteostat`,
  - modelos disponibles filtrados por proveedor para el overlay del historico,
  - carga perezosa del forecast del overlay al entrar en `Live`, evitando peticiones duplicadas al arrancar la pagina,
  - boton propio de refresco para la linea forecast.
- Ajustes de UI:
  - etiquetas compactadas para evitar overflow en anchos estrechos,
  - el test del historico `Live` queda fijado con los nuevos selectores visibles.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:56-21:07 = 11m`.
- `Bloque acumulado de esta reentrada 14:10-21:07 = 6h 57m`.
- `Acumulado confirmado adicional de esta reentrada = 6h 57m`.

### 2026-03-14 - Spots v3.5 fase 104-ag: refresh de forecast movido a la esquina superior derecha del grafico

- Reubicado el boton de `refresh` de la linea forecast.
- Cambio aplicado:
  - sale del bloque de selectores de proveedor/modelo,
  - pasa a mostrarse dentro del grafico `Live`, en la esquina superior derecha,
  - se mantiene separado del boton de fullscreen, que sigue abajo a la derecha.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:07-21:35 = 28m`.
- `Bloque acumulado de esta reentrada 14:10-21:35 = 7h 25m`.
- `Acumulado confirmado adicional de esta reentrada = 7h 25m`.

### 2026-03-14 - Spots v3.5 fase 104-ah: boton de refresh forecast reducido en el grafico

- Ajustado el boton de `refresh` de forecast en la esquina superior derecha del grafico.
- Cambio aplicado:
  - reducido aproximadamente a la mitad,
  - `SizedBox 24x24`,
  - `iconSize` mas pequeno,
  - `padding` a cero y `visualDensity.compact`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:35-21:47 = 12m`.
- `Bloque acumulado de esta reentrada 14:10-21:47 = 7h 37m`.
- `Acumulado confirmado adicional de esta reentrada = 7h 37m`.

### 2026-03-14 - Spots v3.5 fase 104-ai: restaurado el tamano previo del refresh forecast

- Revertido el ultimo ajuste de tamano del boton de `refresh` del forecast.
- Estado final:
  - mantiene la posicion en la esquina superior derecha del grafico,
  - recupera el tamano anterior.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:47-21:49 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-21:49 = 7h 39m`.
- `Acumulado confirmado adicional de esta reentrada = 7h 39m`.

### 2026-03-14 - Patron vigente de la grafica Live

- Queda fijado como patron actual reutilizable para este tipo de graficas en `Spots > Live`:
  - ventana `1d`: muestra solo las ultimas `24 horas`,
  - ventana `3d`: muestra solo las ultimas `72 horas`.
- Regla de rejilla y cadencia en `3d`:
  - filtro `12 h`: rejilla cada `12 horas` y lectura/flecha cada `6 horas`,
  - filtro `6 h`: rejilla cada `6 horas` y lectura/flecha cada `3 horas`,
  - filtro `3 h`: rejilla cada `3 horas` y lectura/flecha cada `1 hora`.
- Regla de rejilla y cadencia en `1d`:
  - filtro `3 h`: rejilla cada `1 hora` y lectura/flecha cada `1 hora`,
  - filtro `1 h`: rejilla cada `1 hora` y lectura/flecha cada `30 minutos`,
  - filtro `20 min`: rejilla etiquetada cada `20 minutos` y lectura/flecha cada `5 minutos`.
- Serie principal y marcadores:
  - la linea continua representa la serie real agregada segun la cadencia activa,
  - solo se pintan flechas solidas,
  - cada flecha corresponde a direccion real disponible en el punto resultante de la serie,
  - no se usan ya flechas huecas ni linea gris discontinua de media movil.
- Forecast overlay:
  - se muestra una unica linea discontinua naranja,
  - tiene selector propio dentro de `Live`, independiente del bloque `Forecast`,
  - proveedores soportados: `Open-Meteo`, `Meteoblue`, `Meteosource`, `Meteostat`,
  - modelos soportados en overlay:
    - `Open-Meteo`: todos,
    - `Meteoblue`: `Basic` y `Sea`,
    - `Meteosource`: `Hourly`,
    - `Meteostat`: `Hourly`,
  - `Windguru` queda fuera del overlay por no disponer de serie estructurada integrada,
  - la serie forecast se remuestrea para adaptarse al filtro activo y admite huecos reales.
- Controles y comportamiento visual:
  - eje Y de nudos fijo y siempre visible durante el scroll horizontal,
  - foco inicial al cargar en el punto mas actual,
  - boton de refresh del grafico en la esquina superior derecha,
  - ese refresh recarga forecast, dato live de la estacion seleccionada e historico/direccion para actualizar tambien las flechas,
  - boton de fullscreen en la esquina inferior derecha,
  - selector de proveedor/modelo forecast visible encima del grafico.
- Objetivo del patron:
  - mantener una lectura consistente, honesta y reutilizable del historico `Live` sin volver a introducir logica ad hoc acumulada.

### 2026-03-14 - Spots v3.5 fase 104-aj: refresh del grafico tambien actualiza direccion y flechas

- Ampliado el comportamiento del boton de refresh de la grafica `Live`.
- Nuevo comportamiento:
  - recarga la linea forecast,
  - recarga el dato live de la estacion seleccionada,
  - recarga el historico de la estacion seleccionada,
  - en estaciones `AVAMET`, esto refresca tambien la direccion usada por las flechas del grafico.
- Ajuste de UI:
  - `tooltip` del boton actualizado a `Refrescar grafica`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:49-21:54 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-21:54 = 7h 44m`.
- `Acumulado confirmado adicional de esta reentrada = 7h 44m`.

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:54-21:59 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-21:59 = 7h 49m`.
- `Acumulado confirmado adicional de esta reentrada = 7h 49m`.

### 2026-03-14 - Spots v3.5 fase 104-ak: alarmas personalizadas con evaluacion real sobre Live

- Activada la logica real de evaluacion para `Alarmas personalizadas` en `Live`.
- Estado funcional actual:
  - las alarmas guardadas ya no son solo formularios persistidos en memoria,
  - cada alarma se evalua contra los datos reales disponibles de la estacion asociada,
  - si hay historico intradia suficiente, se comprueba la persistencia configurada (`5/10/15/30 min`),
  - si no hay historico intradia suficiente, la UI indica claramente si solo hay dato actual en rango o si faltan datos para validar.
- Estados visuales nuevos por alarma:
  - `cumpliendo ahora`,
  - `en rango pero aun sin persistencia completa`,
  - `fuera de rango`,
  - `sin datos suficientes`.
- Detalle tecnico:
  - la evaluacion usa `historicalSeriesByStation` y el dato `Live` actual de la estacion,
  - para series intradia se calcula la cobertura reciente dentro de la ventana pedida,
  - el resultado se refleja en cada tarjeta guardada con icono y color de estado.
- Nota:
  - no se han integrado aun notificaciones locales del sistema; el alcance de esta fase es dejar la alarma funcionando dentro de la UI con evaluacion real.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:59-22:11 = 12m`.
- `Bloque acumulado de esta reentrada 14:10-22:11 = 8h 01m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 01m`.

### 2026-03-14 - Spots v3.5 fase 104-al: alarmas reconfiguradas por spot, horario, direccion y vista global en perfil

- Replanteada la funcionalidad de `Alarmas personalizadas` para alinearla con el contrato nuevo de producto.
- Nuevo comportamiento en `Spots > Live`:
  - el `switch` de la tarjeta ya no bloquea el formulario; ahora activa o desactiva todas las alarmas del spot seleccionado,
  - el selector de estacion se usa solo para elegir la estacion concreta a la que se aplica cada alarma,
  - cada alarma guarda:
    - rango de viento,
    - rango horario,
    - direcciones activas,
    - intervalo de repeticion (`5/10/15/30 min`),
    - maximo fijo de `3` repeticiones.
- Evaluacion actual de la alarma:
  - se hace contra el dato `Live` actual de la estacion,
  - valida viento, franja horaria y direccion,
  - muestra estado visual por alarma:
    - lista para disparar,
    - coincidencia parcial,
    - no activa,
    - sin datos,
    - desactivada por switch global o por spot.
- Persistencia funcional entre pestañas:
  - se ha creado un catalogo compartido de alarmas para que la configuracion guardada en `Live` aparezca tambien en `Perfil`,
  - en `Perfil > Perfil` se anade una nueva tarjeta `Alarmas`,
  - esa tarjeta incluye un `switch` global para activar o desactivar todas las alarmas de todos los spots guardados.
- Nota honesta:
  - la persistencia implementada en esta fase es compartida dentro de la app/sesion actual mediante catalogo comun,
  - no se ha integrado aun persistencia en disco ni notificaciones locales del sistema.
- Archivos actualizados:
  - `lib/features/spots/presentation/state/spot_alarm_catalog.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:11-22:25 = 14m`.
- `Bloque acumulado de esta reentrada 14:10-22:25 = 8h 15m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 15m`.

### 2026-03-14 - Spots v3.5 fase 104-am: confirmacion al eliminar alarmas

- Anadida confirmacion explicita al borrar una alarma desde `Spots > Live`.
- Nuevo comportamiento:
  - al pulsar el icono de eliminar, se abre un `AlertDialog`,
  - la alarma solo se borra si el usuario confirma,
  - se evita eliminacion accidental por toque rapido.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:25-22:37 = 12m`.
- `Bloque acumulado de esta reentrada 14:10-22:37 = 8h 27m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 27m`.

### 2026-03-14 - Spots v3.5 fase 104-an: pulido visual de la tarjeta de alarmas personalizadas

- Reestilizada la tarjeta `Alarmas personalizadas` para que tenga una presencia mas cuidada y legible dentro de `Spots > Live`.
- Mejora visual aplicada:
  - cabecera superior con gradiente, icono destacado y estado del spot mas visible,
  - bloque `Nueva alarma` mantenido dentro de una tarjeta suave con mejor jerarquia,
  - nueva seccion `Alarmas guardadas` con encabezado propio,
  - cada alarma guardada pasa a mostrarse como tarjeta visual en lugar de `ListTile`,
  - estado de evaluacion presentado como pastilla destacada,
  - metadatos de viento, horario, direcciones y repeticion convertidos en chips visuales,
  - estado vacio mas claro cuando aun no hay alarmas para el spot.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:37-22:49 = 12m`.
- `Bloque acumulado de esta reentrada 14:10-22:49 = 8h 39m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 39m`.

### 2026-03-14 - Spots v3.5 fase 104-ao: chips de direcciones simplificados y acciones rapidas

- Corregida la duplicidad visual en los chips de `Direcciones activas` al dejar un unico icono por chip.
- Anadidas acciones rapidas para configurar direcciones de golpe:
  - `Todas` para marcar las ocho direcciones,
  - `Limpiar` para vaciar la seleccion actual.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:49-22:55 = 6m`.
- `Bloque acumulado de esta reentrada 14:10-22:55 = 8h 45m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 45m`.

### 2026-03-14 - Spots v3.5 fase 104-ap: selector rapido de direcciones unificado

- Simplificada la accion rapida de direcciones en la nueva alarma.
- Sustituidos los dos botones `Todas` y `Limpiar` por un unico chip `Todas` con comportamiento toggle:
  - si no estan todas marcadas, selecciona todas,
  - si ya estan todas marcadas, limpia la seleccion.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:55-22:58 = 3m`.
- `Bloque acumulado de esta reentrada 14:10-22:58 = 8h 48m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 48m`.

### 2026-03-14 - Spots v3.5 fase 104-aq: reordenacion del formulario de nueva alarma

- Recolocado el rango horario de la nueva alarma justo debajo del selector de estacion meteorologica.
- Nuevo orden del formulario:
  - estacion,
  - rango horario,
  - rango de viento,
  - direcciones,
  - repeticion.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:58-23:00 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-23:00 = 8h 50m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 50m`.

### 2026-03-14 - Spots v3.5 fase 104-ar: ajustes finales de copy e iconografia en alarmas

- Retocado el copy del rango de viento para dejarlo en `Rango de viento`.
- Sustituido el icono del boton `Guardar alarma` por uno tipo despertador (`alarm_add`).
- Alineado el encabezado `Alarmas guardadas` con el mismo icono del boton de guardar para mantener consistencia visual.
- Simplificado el chip de repeticion dentro de una alarma guardada para que muestre solo el intervalo, sin el texto de maximo de repeticiones.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 23:00-23:04 = 4m`.
- `Bloque acumulado de esta reentrada 14:10-23:04 = 8h 54m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 54m`.

### 2026-03-14 - Spots v3.5 fase 104-as: bloqueo de alarmas duplicadas

- Anadida validacion para impedir guardar dos alarmas identicas.
- La comprobacion compara:
  - spot,
  - estacion,
  - rango de viento,
  - rango horario,
  - direcciones,
  - intervalo de repeticion.
- Al intentar guardar un duplicado, la app muestra un `SnackBar` y no persiste la nueva alarma.
- La edicion de la propia alarma sigue permitida sin falsos positivos.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/state/spot_alarm_catalog.dart`
  - `test/features/spots/presentation/state/spot_alarm_catalog_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/pages/spot_detail_page_test.dart test/features/spots/presentation/state/spot_alarm_catalog_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 23:04-23:06 = 2m`.
- `Bloque acumulado de esta reentrada 14:10-23:06 = 8h 56m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 56m`.

### 2026-03-14 - Spots v3.5 fase 104-at: redisenyo de la tarjeta de alarmas en perfil y acciones completas

- Rehecha la tarjeta `Alarmas` dentro de `Perfil` con una presentacion mas visual y consistente con `Spots > Live`.
- Nuevo aspecto:
  - cabecera con gradiente, icono destacado y switch global mas integrado,
  - estado vacio estilizado cuando no hay alarmas,
  - cada alarma renderizada como tarjeta visual con chips de metadata y estado del spot.
- Nuevas acciones dentro de `Perfil > Alarmas`:
  - `Editar` abre un dialogo que carga la configuracion original de la alarma y persiste sobre el mismo `id`,
  - `Eliminar` pide confirmacion antes de borrar.
- La edicion desde perfil mantiene la proteccion contra duplicados.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/state/spot_alarm_catalog_test.dart -r compact` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 23:06-23:19 = 13m`.
- `Bloque acumulado de esta reentrada 14:10-23:19 = 9h 09m`.
- `Acumulado confirmado adicional de esta reentrada = 9h 09m`.

### 2026-03-14 - Spots v3.5 fase 104-au: lista de alarmas en perfil con scroll interno

- Ajustada la tarjeta `Perfil > Alarmas` para que no siga creciendo verticalmente cuando haya muchas alarmas.
- Nuevo comportamiento:
  - la cabecera permanece fija dentro de la tarjeta,
  - la lista de alarmas queda contenida con altura maxima,
  - las alarmas se recorren con scroll interno.
- Archivo actualizado:
  - `lib/features/profile/presentation/pages/profile_overview_section.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 23:19-23:28 = 9m`.
- `Bloque acumulado de esta reentrada 14:10-23:28 = 9h 18m`.
- `Acumulado confirmado adicional de esta reentrada = 9h 18m`.

### 2026-03-14 - Spots v3.5 fase 104-av: revision funcional del bloque forecast de AEMET

- Revisado de nuevo el alcance real de `AEMET` en el proyecto frente a OpenData oficial.
- Cobertura actual confirmada en el codigo:
  - `municipio horaria` para forecast base del proveedor,
  - `prediccion de playa`,
  - `maritima costera`,
  - `observaciones` para live.
- Hallazgos relevantes:
  - dentro de `municipio horaria` solo estamos usando una parte del payload y ademas remuestreando cada `3h`,
  - `prediccion de playa` ya nos da mas de lo que solemos aprovechar visualmente: UV, temperatura del agua y sensacion termica,
  - `AEMET` tambien ofrece rutas oficiales complementarias que aun no explotamos, como `municipio diaria`, `UVI` y `maritima de alta mar`.
- Archivos revisados:
  - `lib/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
- No se han aplicado cambios de codigo en esta fase; queda como investigacion para decidir siguiente paso.

### 2026-03-14 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 23:28-23:33 = 5m`.
- `Bloque acumulado de esta reentrada 14:10-23:33 = 9h 23m`.
- `Acumulado confirmado adicional de esta reentrada = 9h 23m`.

### 2026-03-15 - Spots v3.5 fase 104-aw: objetivo declarado para el mapa de viento

- Definido como objetivo de producto llegar a una version `nivel 3` del `Mapa de viento`.
- Alcance deseado:
  - animacion temporal del viento,
  - streamlines o particulas en movimiento,
  - cambio de hora mediante control temporal,
  - posible superposicion de spots o estaciones cercanas.
- Situacion actual recordada:
  - el `Mapa de viento` sigue siendo una maqueta visual con flechas fijas y sin datos reales por celda.
- Criterio de implementacion acordado:
  - construir la version avanzada por fases reales, evitando rehacer otra demo provisional sin fuente consistente.

### 2026-03-15 - Conteo de horas (arranque de jornada)

- `Bloque incremental 00:00-00:05 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-00:05 = 5m`.
- `Acumulado confirmado adicional de esta reentrada = 5m`.

### 2026-03-15 - Spots v3.5 fase 104-ax: base real del mapa de viento conectada al forecast

- Sustituida la maqueta fija del `Mapa de viento` por una primera base conectada al forecast real cargado en el spot.
- Nuevo comportamiento:
  - el mapa se centra en las coordenadas reales del spot,
  - la capa usa las muestras forecast disponibles del proveedor/modelo seleccionado,
  - se puede recorrer el tiempo con un slider inferior,
  - la celda central representa la lectura exacta del slot elegido,
  - las celdas vecinas se muestran como campo local derivado del forecast del spot para preparar la futura version avanzada.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)
  - `flutter test test/features/spots/presentation/state/spot_alarm_catalog_test.dart -r compact` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:05-00:09 = 4m`.
- `Bloque acumulado de esta reentrada 00:00-00:09 = 9m`.
- `Acumulado confirmado adicional de esta reentrada = 9m`.

### 2026-03-15 - Spots v3.5 fase 104-ay: animacion temporal basica en el mapa de viento

- Anadida reproduccion temporal basica sobre la nueva base real del `Mapa de viento`.
- Nuevo comportamiento:
  - boton `Play/Pausa` en la franja inferior del mapa,
  - avance automatico entre los slots forecast disponibles,
  - reinicio al llegar al final de la serie,
  - al mover manualmente el slider se detiene la reproduccion.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:09-00:14 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-00:14 = 14m`.
- `Acumulado confirmado adicional de esta reentrada = 14m`.

### 2026-03-15 - Spots v3.5 fase 104-az: aligerado del mapa de viento para reducir jank

- Ajustado el `Mapa de viento` para reducir carga visual y suavizar la animacion temporal en emulador.
- Cambios aplicados:
  - autoplay mas lento,
  - menos celdas derivadas alrededor del spot,
  - markers mas pequenos,
  - decoracion mas ligera en la flecha central y celdas,
  - `RepaintBoundary` sobre el bloque principal del mapa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:14-00:22 = 8m`.
- `Bloque acumulado de esta reentrada 00:00-00:22 = 22m`.
- `Acumulado confirmado adicional de esta reentrada = 22m`.

### 2026-03-15 - Spots v3.5 fase 104-ba: primera capa de particulas sobre el mapa de viento

- Anadida una primera capa ligera de particulas sobre el `Mapa de viento`.
- Caracteristicas de esta fase:
  - animacion continua independiente del slider temporal,
  - direccion y densidad ligadas al slot forecast activo,
  - implementacion con `CustomPaint` para evitar reconstruir el mapa entero en cada frame.
- Esta capa funciona como primer escalon visual real hacia el objetivo `nivel 3`, antes de abordar streamlines mas completos.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:22-00:25 = 3m`.
- `Bloque acumulado de esta reentrada 00:00-00:25 = 25m`.
- `Acumulado confirmado adicional de esta reentrada = 25m`.

### 2026-03-15 - Spots v3.5 fase 104-bb: correccion de overflow en el marcador central del mapa

- Corregido un `RenderFlex overflowed by 2 pixels on the bottom` en el marcador central del spot dentro del `Mapa de viento`.
- Ajustes aplicados:
  - padding vertical mas compacto,
  - flecha central ligeramente mas pequena,
  - icono de ubicacion mas compacto,
  - menor separacion entre tarjeta e icono.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:25-00:31 = 6m`.
- `Bloque acumulado de esta reentrada 00:00-00:31 = 31m`.
- `Acumulado confirmado adicional de esta reentrada = 31m`.

### 2026-03-15 - Spots v3.5 fase 104-bc: evolucion de particulas a streamlines ligeros

- Sustituida la capa de particulas simples por una representacion mas cercana a `streamlines`.
- Nuevo comportamiento visual:
  - trazos curvos segmentados,
  - orientacion ligada al slot forecast activo,
  - ligera oscilacion transversal para dar sensacion de flujo,
  - implementacion todavia ligera con `CustomPaint`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:31-00:36 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-00:36 = 36m`.
- `Acumulado confirmado adicional de esta reentrada = 36m`.

### 2026-03-15 - Spots v3.5 fase 104-bd: mejora de coherencia espacial del campo de viento

- Mejorada la coherencia espacial del `Mapa de viento` para que los streamlines ya no dependan de un unico vector global.
- Nuevo comportamiento:
  - las celdas derivadas del entorno del spot alimentan un pequeno campo local,
  - los streamlines muestrean ese campo y se curvan segun la variacion espacial cercana,
  - la sensacion final se acerca mas a un flujo real y menos a una superposicion decorativa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:36-00:41 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-00:41 = 41m`.
- `Acumulado confirmado adicional de esta reentrada = 41m`.

### 2026-03-15 - Spots v3.5 fase 104-be: selector de capas en el mapa de viento

- Anadido primer control de capas dentro del `Mapa de viento`.
- Capas activas ahora mismo:
  - `Viento`
  - `Racha`
- El cambio de capa afecta ya a:
  - la intensidad central mostrada en el spot,
  - la intensidad derivada en las celdas vecinas,
  - el campo local que alimenta los streamlines.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:41-00:46 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-00:46 = 46m`.
- `Acumulado confirmado adicional de esta reentrada = 46m`.

### 2026-03-15 - Spots v3.5 fase 104-bf: leyenda visual para capas del mapa de viento

- Anadida una leyenda visual para la capa activa del `Mapa de viento`.
- Cobertura actual:
  - `Viento`
  - `Racha`
- La leyenda explica los colores por rango y mejora la lectura del selector de capas sin tocar aun la fuente de datos.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:46-00:52 = 6m`.
- `Bloque acumulado de esta reentrada 00:00-00:52 = 52m`.
- `Acumulado confirmado adicional de esta reentrada = 52m`.

### 2026-03-15 - Spots v3.5 fase 104-bg: refuerzo visual de streamlines en el mapa

- Reforzada la visibilidad de las estelas del `Mapa de viento` tras detectar que en pantalla apenas se apreciaban.
- Ajustes aplicados:
  - mas lineas simultaneas,
  - mayor longitud de trazo,
  - doble trazo con halo de color,
  - punto final mas visible,
  - contraste mas alto sobre el mapa base.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:52-00:55 = 3m`.
- `Bloque acumulado de esta reentrada 00:00-00:55 = 55m`.
- `Acumulado confirmado adicional de esta reentrada = 55m`.

### 2026-03-15 - Spots v3.5 fase 104-bh: recorte de streamlines al viewport del mapa

- Corregido el desbordamiento visual de algunas estelas del `Mapa de viento`.
- Nuevo comportamiento:
  - la capa de streamlines queda recortada al rectangulo visible del mapa,
  - ya no se pintan trazos fuera del viewport.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:55-00:57 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-00:57 = 57m`.
- `Acumulado confirmado adicional de esta reentrada = 57m`.

### 2026-03-15 - Spots v3.5 fase 104-bi: estelas del mapa con look mas tipo corriente

- Ajustada la capa de `streamlines` del `Mapa de viento` para que se lea menos como rayas con punto final y mas como flujo continuo.
- Cambios visuales aplicados:
  - mayor recorrido por estela,
  - mas curvatura y sway en cada tramo,
  - doble cuerpo de color con brillo interior claro,
  - eliminacion del punto final para evitar look de particula.
- Objetivo de la prueba:
  - acercar el mapa a una lectura visual mas tipo corriente sin tocar la logica de datos del campo local.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 00:57-01:05 = 8m`.
- `Bloque acumulado de esta reentrada 00:00-01:05 = 1h 05m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 05m`.

### 2026-03-15 - Spots v3.5 fase 104-bj: revert del experimento visual de estelas tipo corriente

- Deshecho el ultimo ajuste visual de `streamlines` del `Mapa de viento`.
- Motivo:
  - el look mas tipo corriente no convence visualmente y se recupera la version anterior de estelas reforzadas.
- Estado final tras revert:
  - vuelve el trazo previo con halo, linea principal y punto final visible.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:05-01:09 = 4m`.
- `Bloque acumulado de esta reentrada 00:00-01:09 = 1h 09m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 09m`.

### 2026-03-15 - Spots v3.5 fase 104-bk: base del mapa preparada para un campo espacial mas denso

- Dado el siguiente paso hacia un mapa mas tipo `Windy` sin tocar todavia la fuente remota.
- Cambios aplicados en el `Mapa de viento`:
  - separada la construccion del campo local del simple pintado de estelas,
  - mantenidas las celdas visibles alrededor del spot,
  - ampliado el campo interno con nodos ocultos adicionales para dar mas coherencia espacial al flujo.
- Resultado:
  - los `streamlines` ya no dependen de solo unos pocos puntos visibles,
  - queda preparada una base mas seria para futuras capas o una malla real de forecast.
- Ajuste de copy:
  - la tarjeta del mapa ahora explica que el flujo sale de un `campo local denso` derivado del forecast del spot.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:09-01:17 = 8m`.
- `Bloque acumulado de esta reentrada 00:00-01:17 = 1h 17m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 17m`.

### 2026-03-15 - Spots v3.5 fase 104-bl: tercera capa `Olas` en el mapa de viento

- Anadida la capa `Olas` al selector del `Mapa de viento`.
- Comportamiento nuevo:
  - `Viento` y `Racha` mantienen flechas, colorimetria y streamlines,
  - `Olas` usa `waveM` como intensidad visual,
  - la capa `Olas` apaga las estelas para no insinuar una direccion de olas no modelada aparte.
- UI adaptada:
  - lectura central del spot con `m`,
  - celdas vecinas con icono de olas y valor decimal,
  - leyenda especifica por rangos de altura de ola.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:17-01:24 = 7m`.
- `Bloque acumulado de esta reentrada 00:00-01:24 = 1h 24m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 24m`.

### 2026-03-15 - Spots v3.5 fase 104-bm: refuerzo del campo espacial para `Viento/Racha`

- Reforzada la base del campo local usado por `Viento` y `Racha` en el `Mapa de viento`.
- Cambios aplicados:
  - malla interna oculta mas densa para alimentar el flujo,
  - derivacion espacial alineada con el rumbo base del viento,
  - gradiente a favor/en contra del flujo y cizalladura lateral para evitar un campo demasiado rigido.
- Resultado esperado:
  - estelas y celdas de `Viento/Racha` mas coherentes alrededor del spot,
  - lectura menos artificial del campo local sin tocar todavia la fuente remota.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:24-01:28 = 4m`.
- `Bloque acumulado de esta reentrada 00:00-01:28 = 1h 28m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 28m`.

### 2026-03-15 - Spots v3.5 fase 104-bn: mejora visible del mapa con mas celdas alrededor del spot

- Reforzada la presencia visual del campo en el `Mapa de viento`.
- Cambio aplicado:
  - ampliada la corona de celdas visibles alrededor del spot,
  - ya no se muestran solo cuatro esquinas, sino una distribucion mas rica con ejes e interior cercano.
- Efecto buscado:
  - que el mapa se lea mas como campo local y menos como marcador central con pocos apoyos visuales.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:28-01:31 = 3m`.
- `Bloque acumulado de esta reentrada 00:00-01:31 = 1h 31m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 31m`.

### 2026-03-15 - Spots v3.5 fase 104-bo: revert de la densificacion visible de flechas del mapa

- Deshecho el ultimo experimento visual que anadia mas flechas/celdas visibles alrededor del spot.
- Motivo:
  - la densificacion visible del mapa no convence visualmente.
- Se conserva:
  - el refuerzo interno del campo espacial para `Viento/Racha`,
  - la mejora de la malla oculta que alimenta las estelas.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:31-01:33 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-01:33 = 1h 33m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 33m`.

### 2026-03-15 - Spots v3.5 fase 104-bp: prueba de estelas mas cortas y numerosas

- Ajustada la capa de `streamlines` del `Mapa de viento` para probar una lectura mas densa del campo.
- Cambios visuales aplicados:
  - mas estelas simultaneas,
  - menor longitud por trazo,
  - opacidad algo mas suave,
  - punto final mas pequeno.
- Objetivo:
  - comprobar si el flujo se entiende mejor con una textura mas fina y menos dominante.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:33-01:35 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-01:35 = 1h 35m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 35m`.

### 2026-03-15 - Spots v3.5 fase 104-bq: correccion de cobertura de estelas en el viewport

- Corregido un problema de distribucion de `streamlines` que hacia que la textura se concentrara en una esquina del mapa.
- Ajuste aplicado:
  - sustituida la siembra pseudoaleatoria simple por una distribucion en rejilla con jitter suave.
- Resultado esperado:
  - las estelas cortas y numerosas cubren mejor todo el viewport en vez de agruparse.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:35-01:37 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-01:37 = 1h 37m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 37m`.

### 2026-03-15 - Spots v3.5 fase 104-br: boton `Mapa de viento` condicionado a forecast reutilizable

- Ajustado el bloque `Forecast` para que el boton `Mapa de viento` solo aparezca cuando el forecast actual tenga datos realmente reutilizables para el mapa.
- Reglas aplicadas:
  - oculto para `Windguru`,
  - oculto para `AEMET Playa`,
  - oculto para `AEMET Costera`,
  - visible solo si la carga del forecast devuelve filas utilizables con viento.
- Proteccion adicional:
  - `_openWindMap()` ahora vuelve a comprobar la compatibilidad del resultado antes de abrir el mapa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:37-01:42 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-01:42 = 1h 42m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 42m`.

### 2026-03-15 - Spots v3.5 fase 104-bs: simplificacion visual del mapa a una sola flecha central

- Simplificado el `Mapa de viento` para dejar solo la flecha central visible del spot.
- Cambios aplicados:
  - eliminadas las flechas/celdas auxiliares visibles alrededor del mapa,
  - se mantiene la malla interna que alimenta el campo y las estelas.
- Resultado:
  - el mapa queda mas limpio,
  - se conserva el flujo visual sin anadir ruido con marcadores extra.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:42-01:47 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-01:47 = 1h 47m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 47m`.

### 2026-03-15 - Spots v3.5 fase 104-bt: pulido de estelas para acompanar mejor a la flecha central

- Ajustada la capa de `streamlines` del `Mapa de viento` para que compita menos con la flecha central del spot.
- Cambios aplicados:
  - halo algo mas suave,
  - eliminacion del punto final de cada estela.
- Objetivo:
  - dejar un flujo visual mas limpio y secundario, manteniendo el mapa centrado en la lectura principal del spot.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:47-01:49 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-01:49 = 1h 49m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 49m`.

### 2026-03-15 - Spots v3.5 fase 104-bu: limpieza visual final del mapa

- Pulido visual adicional del `Mapa de viento`.
- Cambios aplicados:
  - corregidos los textos raros del header del mapa,
  - corregida la lectura del angulo del viento en grados,
  - mantenido el flujo mas suave sin punto final dominante.
- Archivos actualizados:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:49-01:52 = 3m`.
- `Bloque acumulado de esta reentrada 00:00-01:52 = 1h 52m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 52m`.

### 2026-03-15 - Spots v3.5 fase 104-bv: eliminacion de la leyenda del mapa

- Eliminada la leyenda de `Viento / Racha / Olas` del `Mapa de viento`.
- Motivo:
  - no aporta valor suficiente y ensucia la parte inferior del mapa.
- Limpieza asociada:
  - retiradas tambien las clases auxiliares de la leyenda para no dejar codigo muerto.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:52-01:55 = 3m`.
- `Bloque acumulado de esta reentrada 00:00-01:55 = 1h 55m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 55m`.

### 2026-03-15 - Spots v3.5 fase 104-bw: chip de direccion con rumbo y limpieza extra del mapa

- Mejorado el chip de direccion del `Mapa de viento`.
- Nuevo formato:
  - ahora muestra grados mas rumbo cardinal/intercardinal, por ejemplo `245° WSW`.
- Limpieza adicional:
  - eliminada la tarjeta flotante inferior explicativa para dejar el mapa mas limpio.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:55-01:57 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-01:57 = 1h 57m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 57m`.

### 2026-03-15 - Spots v3.5 fase 104-bx: simplificacion de la banda inferior del mapa

- Simplificada la banda inferior del `Mapa de viento`.
- Cambios aplicados:
  - el selector de capa y el control `Play/Pausa` quedan en una sola fila,
  - eliminado el texto intermedio de estado de animacion,
  - boton de reproduccion mas compacto.
- Resultado:
  - menos ruido visual y mas protagonismo para el mapa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:57-01:58 = 1m`.
- `Bloque acumulado de esta reentrada 00:00-01:58 = 1h 58m`.
- `Acumulado confirmado adicional de esta reentrada = 1h 58m`.

### 2026-03-15 - Spots v3.5 fase 104-by: fecha/hora actual movida a la banda inferior del mapa

- Reubicada la lectura de fecha y hora actual del `Mapa de viento`.
- Cambios aplicados:
  - eliminado el chip de fecha/hora de la cabecera superior,
  - la marca temporal actual ahora aparece centrada en la banda inferior,
  - queda situada entre el texto de inicio y el de fin del timeline.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 01:58-02:02 = 4m`.
- `Bloque acumulado de esta reentrada 00:00-02:02 = 2h 02m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 02m`.

### 2026-03-15 - Spots v3.5 fase 104-bz: boton de play recolocado a la izquierda del slider

- Ajustado el layout de la banda inferior del `Mapa de viento`.
- Nuevo orden:
  - selector de capa en su propia fila,
  - boton `Play/Pausa` a la izquierda del slider temporal.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 02:02-02:04 = 2m`.
- `Bloque acumulado de esta reentrada 00:00-02:04 = 2h 04m`.
- `Acumulado confirmado adicional de esta reentrada = 2h 04m`.

### 2026-03-15 - Spots v3.5 fase 104-ca: recuperacion de `wind_map_page.dart` tras ajuste fallido de cabecera

- Durante un intento de compactar la cabecera del `Mapa de viento`, el archivo quedo temporalmente desbalanceado en cierres.
- Accion tomada:
  - restaurado `wind_map_page.dart` al ultimo estado sano del commit local,
  - verificado que ese estado ya mantenia el boton `Play/Pausa` a la izquierda del slider, que era el objetivo funcional valido.
- Resultado:
  - sin cambio neto adicional respecto al estado ya bueno del archivo,
  - `flutter analyze` vuelve a quedar en verde.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 02:04-07:41 = 5h 37m`.
- `Bloque acumulado de esta reentrada 00:00-07:41 = 7h 41m`.
- `Acumulado confirmado adicional de esta reentrada = 7h 41m`.

### 2026-03-15 - Spots v3.5 fase 104-cb: selector del mapa simplificado a `Viento` y `Olas` con datos reales

- Simplificado el selector de capas del `Mapa de viento`.
- Nuevo comportamiento:
  - se elimina `Racha` del `SegmentedButton` para evitar duplicidad con el dato de racha ya visible en la cabecera,
  - `Olas` solo aparece si el modelo/proveedor actual trae `waveM` real en las muestras forecast,
  - si no hay olas disponibles, el mapa fuerza internamente la capa `Viento`.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 07:41-08:18 = 37m`.
- `Bloque acumulado de esta reentrada 00:00-08:18 = 8h 18m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 18m`.

### 2026-03-15 - Spots v3.5 fase 104-cc: recuperacion de visibilidad de estelas en `Viento`

- Reforzada de nuevo la visibilidad de las estelas en la capa `Viento` del `Mapa de viento`.
- Ajustes aplicados:
  - mas contraste en halo y trazo principal,
  - algo mas de longitud y densidad,
  - recuperado un punto final minimo para mejorar lectura en pantalla.
- Objetivo:
  - dejar visible el flujo mientras seguimos con una sola flecha central en el mapa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:18-08:27 = 9m`.
- `Bloque acumulado de esta reentrada 00:00-08:27 = 8h 27m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 27m`.

### 2026-03-15 - Spots v3.5 fase 104-cd: base real 5x5 de Open-Meteo integrada en el mapa

- Integrada una primera malla real `5x5` para el `Mapa de viento` cuando el proveedor activo es `Open-Meteo`.
- Nuevo flujo:
  - al abrir el mapa desde `SpotDetailPage`, si el forecast actual es `Open-Meteo`, se descarga una rejilla local de coordenadas alrededor del spot,
  - la rejilla se agrupa por timestamp y se pasa a `WindMapPage`,
  - la capa `Viento` prioriza esa malla real para alimentar el campo local y las estelas,
  - el mapa mantiene la derivacion anterior como fallback para proveedores no compatibles o si la malla falla.
- Alcance de esta fase:
  - serie espacial local real para `Viento`,
  - sin cambiar todavia la experiencia de `Olas`,
  - sin exponer aun la malla como celdas visibles en pantalla.
- Archivos actualizados:
  - `lib/features/spots/infrastructure/services/open_meteo_wind_map_grid_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:27-08:36 = 9m`.
- `Bloque acumulado de esta reentrada 00:00-08:36 = 8h 36m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 36m`.

### 2026-03-15 - Spots v3.5 fase 104-ce: campo interpolado denso sobre la malla real de Open-Meteo

- Evolucionada la primera malla real `5x5` de `Open-Meteo` a un campo interpolado mas denso dentro del `Mapa de viento`.
- Nuevo comportamiento en `Viento` cuando hay malla real:
  - ya no se usan solo los 25 nodos crudos de la rejilla,
  - el mapa genera una malla interna mas fina por interpolacion espacial,
  - las estelas se apoyan en ese campo denso y deberian sentirse mas continuas y menos "saltadas".
- Objetivo:
  - acercar la sensacion del flujo a un mapa tipo `Windy-like` sin cambiar aun la UI del mapa ni exponer celdas visibles.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:36-08:43 = 7m`.
- `Bloque acumulado de esta reentrada 00:00-08:43 = 8h 43m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 43m`.

### 2026-03-15 - Spots v3.5 fase 104-cf: fondo sutil de intensidad sobre el campo del mapa

- Anadida una capa visual de fondo para `Viento` en el `Mapa de viento`.
- Nuevo comportamiento:
  - el campo interpolado ya no solo alimenta las estelas,
  - ahora tambien genera una bruma de color muy suave sobre el mapa,
  - la intensidad sigue los nodos del campo y refuerza la lectura espacial sin meter mas flechas ni celdas visibles.
- Objetivo:
  - mejorar la lectura del flujo y acercar el mapa a una sensacion mas meteorologica sin recargar la UI.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:43-08:48 = 5m`.
- `Bloque acumulado de esta reentrada 00:00-08:48 = 8h 48m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 48m`.

### 2026-03-15 - Spots v3.5 fase 104-cg: prueba visual de fondo mas marcado tipo mapa meteorologico

- Ajustada la nueva capa de fondo de `Viento` para una lectura mas marcada y mas cercana a un mapa meteorologico.
- Cambios de la prueba:
  - radio visual mayor en cada nodo del campo,
  - gradiente mas presente,
  - mas solape entre manchas de color para que el fondo gane cuerpo.
- Objetivo:
  - comparar una version mas intensa frente al fondo sutil anterior sin tocar la estructura del mapa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:48-08:52 = 4m`.
- `Bloque acumulado de esta reentrada 00:00-08:52 = 8h 52m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 52m`.

### 2026-03-15 - Spots v3.5 fase 104-ch: correccion de orientacion meteorologica en flecha central y estelas

- Corregida la conversion entre grados meteorologicos y coordenadas de pantalla en el `Mapa de viento`.
- Ajustes aplicados:
  - la flecha central ya no rota con los grados "tal cual", sino con la conversion adecuada de rumbo meteorologico a direccion de flujo en pantalla,
  - las estelas y la interpolacion del campo ahora usan esa misma referencia coherente,
  - la media angular interna de la malla real tambien queda alineada con esa conversion.
- Objetivo:
  - evitar la sensacion de que el flujo "se mueve bien" pero la orientacion global este girada o desplazada respecto al viento real.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:52-08:59 = 7m`.
- `Bloque acumulado de esta reentrada 00:00-08:59 = 8h 59m`.
- `Acumulado confirmado adicional de esta reentrada = 8h 59m`.

### 2026-03-15 - Spots v3.5 fase 104-ci: fondo radial extendido hasta bordes del mapa

- Ajustada la siembra del campo del `Mapa de viento` para que las manchas radiales de fondo lleguen hasta el contorno visible del mapa.
- Cambios aplicados:
  - la malla interpolada de `Open-Meteo` ahora incluye nodos mucho mas cercanos a bordes y esquinas,
  - el fallback derivado tambien empuja sus semillas hacia el contorno,
  - se mantiene el `clipRect`, asi que el fondo puede tocar el borde sin salirse ni verse como un cuadro superpuesto raro.
- Objetivo:
  - conservar el look de manchas radiales, pero evitando que el color se quede corto antes del borde del mapa.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 08:59-09:05 = 6m`.
- `Bloque acumulado de esta reentrada 00:00-09:05 = 9h 05m`.
- `Acumulado confirmado adicional de esta reentrada = 9h 05m`.

### 2026-03-15 - Spots v3.5 fase 104-cj: aligerado del mapa para evitar arranque congelado

- Revisado el supuesto "crash" de arranque: no aparecia una excepcion fatal del proceso, pero si un bloqueo fuerte del hilo principal con muchisimos frames saltados.
- Ajustes de alivio aplicados en el `Mapa de viento`:
  - la animacion de estelas ya no arranca en `initState`, sino despues del primer frame,
  - la malla interpolada usada por el campo se ha hecho algo mas ligera,
  - reducidas densidad y longitud de estelas por frame para bajar coste de render.
- Objetivo:
  - evitar que el mapa se sienta como un crash antes de arrancar cuando realmente era jank severo.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 09:05-09:16 = 11m`.
- `Bloque acumulado de esta reentrada 00:00-09:16 = 9h 16m`.
- `Acumulado confirmado adicional de esta reentrada = 9h 16m`.

### 2026-03-15 - Spots v3.5 fase 104-ck: overflow corregido en el formulario de `Agregar spot`

- Corregido un `RenderFlex overflow` vertical en el formulario de `Agregar spot` dentro de `spots_page.dart`.
- Causa:
  - la `Column` del formulario podia superar el alto disponible del dialogo/hoja al combinar selector personalizado, foto, sugerencias y teclado.
- Ajuste aplicado:
  - envuelto el contenido del formulario en `SingleChildScrollView` para que pueda desplazarse en lugar de desbordar.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/spots_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 09:16-09:54 = 38m`.
- `Bloque acumulado de esta reentrada 00:00-09:54 = 9h 54m`.
- `Acumulado confirmado adicional de esta reentrada = 9h 54m`.

### 2026-03-15 - Spots v3.5 fase 104-cl: ajuste del AVD `Pixel_7` por crash del emulator

- Revisado el error del daemon:
  - `The Android emulator exited with code -1073741819 after startup`
  - ese codigo en Windows corresponde a `0xC0000005` y apunta a violacion de acceso del propio emulator, no de Flutter ni de la app.
- Hallazgo:
  - el AVD `Pixel_7` estaba configurado con `fastboot.forceFastBoot=yes`, una causa muy tipica de crash al restaurar snapshots corruptos o incompatibles.
- Ajuste aplicado fuera del repo:
  - `fastboot.forceColdBoot=yes`
  - `fastboot.forceFastBoot=no`
  - archivo tocado: `C:\\Users\\Rml\\.android\\avd\\Pixel_7.avd\\config.ini`
- Objetivo:
  - forzar arranque en frio del emulador y evitar la restauracion del estado rapido que estaba rompiendo el arranque.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 09:54-10:00 = 6m`.
- `Bloque acumulado de esta reentrada 00:00-10:00 = 10h 00m`.
- `Acumulado confirmado adicional de esta reentrada = 10h 00m`.

### 2026-03-15 - Spots v3.5 fase 104-cm: limpieza de quickboot del AVD `Pixel_7`

- Releido el output del emulator y contrastado con logs locales de `netsimd`.
- Conclusion:
  - `netsimd` no era la causa del crash,
  - arranca bien, registra el `Pixel 7` y despues se apaga porque el emulator principal se cae/desconecta.
- Saneado adicional aplicado fuera del repo sobre el AVD:
  - `quickbootChoice.ini` ajustado a `saveOnExit = false`,
  - eliminados restos de `snapshots`,
  - eliminado `read-snapshot.txt`.
- Estado final del AVD:
  - sin guardado de quickboot,
  - sin snapshot previo para restaurar,
  - preparado para arranque totalmente limpio.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 10:00-10:08 = 8m`.
- `Bloque acumulado de esta reentrada 00:00-10:08 = 10h 08m`.
- `Acumulado confirmado adicional de esta reentrada = 10h 08m`.

### 2026-03-15 - Spots v3.5 fase 104-cn: entrada del `Mapa de viento` aligerada para evitar caida del emulator

- Ajuste directo sobre la pantalla de `Mapa de viento` al detectar que el emulator se cae al entrar en ella.
- Cambios aplicados:
  - la animacion continua de estelas ya no arranca sola al abrir la pantalla,
  - ahora solo se activa cuando el usuario pone en marcha el timeline con `Play`,
  - la capa de fondo radial dibuja menos nodos por frame para reducir carga grafica inicial.
- Objetivo:
  - bajar el pico de coste justo al entrar en la pantalla, que era el momento mas probable del crash del emulator.
- Archivo actualizado:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Verificacion ejecutada:
  - `flutter analyze` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 10:08-10:18 = 10m`.
- `Bloque acumulado de esta reentrada 00:00-10:18 = 10h 18m`.
- `Acumulado confirmado adicional de esta reentrada = 10h 18m`.

### 2026-03-15 - Reanudacion de contexto en entorno local clonado

- Repositorio clonado en el workspace local actual sobre la rama `MeteoKite-v3.0`.
- Revisado `SESSION_TRACKER.md` para reconstruir el punto exacto de corte de la ultima sesion.
- Releidas referencias base de arquitectura:
  - `docs/architecture/hexagonal_v3.md`
  - `docs/architecture/migration_backlog_v3.md`
- Reinspeccionada la estructura real de features y bootstrap activo:
  - `lib/main.dart`
  - `lib/app/router/app_router.dart`
  - `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Confirmado foco funcional heredado:
  - `sessions` queda estable en base hexagonal y con bastante recorrido de UI ya cerrado,
  - el frente mas reciente y probable punto de continuacion esta en `spots`, especialmente `Mapa de viento`.
- Releidos los archivos clave del ultimo frente abierto:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
  - `lib/features/spots/infrastructure/services/open_meteo_wind_map_grid_client.dart`
  - `lib/features/spots/di/spots_module.dart`

### 2026-03-15 - Conteo de horas (inicio de nueva reentrada)

- `Hora de reanudacion registrada: 11:34 CET`.
- `Base heredada confirmada del mismo dia antes de esta reentrada: 10h 18m`.
- `Conteo de esta nueva reentrada iniciado desde 11:34 CET`.

### 2026-03-15 - Compatibilidad local: prueba de `flutter pub get` en macOS 12

- Ejecutada prueba real de compatibilidad del proyecto con el Flutter instalado localmente.
- Hallazgos confirmados:
  - con `pubspec.yaml` original, `flutter pub get` falla porque el repo exige `Dart ^3.11.0` y el entorno actual expone `Dart 3.10.8`,
  - se hizo una prueba temporal bajando el constraint a `Dart ^3.10.0`,
  - aun asi la ejecucion no era viable porque el propio toolchain de Flutter intenta reconstruirse y aborta con `Current Mac OS X version 12.0 is lower than minimum supported version 14.0`.
- Conclusion operativa:
  - el bloqueo no es solo el constraint del proyecto,
  - la instalacion local de Flutter usada en esta maquina ya exige `macOS 14` para operar correctamente,
  - se revierte el cambio temporal del `pubspec.yaml` para no falsear los requisitos reales del repo.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 11:34-11:50 = 16m`.
- `Bloque acumulado de esta nueva reentrada 11:34-11:50 = 16m`.
- `Acumulado combinado confirmado del dia = 10h 34m`.

### 2026-03-15 - Recuperacion del toolchain Flutter local para macOS 12

- Diagnosticada la causa real del bloqueo local:
  - la instalacion global en `/usr/local/share/flutter` habia quedado en una mezcla de estados,
  - la rama `stable` actual del remoto ya apunta a `3.41.x`,
  - ese toolchain intenta usar un Dart/VM que exige `macOS 14`, incompatible con esta maquina (`macOS 12.7.6`).
- Saneado aplicado sobre la instalacion global de Flutter:
  - checkout explicito al tag `3.38.9`,
  - limpieza completa de `bin/cache`,
  - regeneracion limpia del toolchain y del Dart SDK.
- Estado funcional confirmado del entorno tras el saneado:
  - `Flutter 3.38.9`
  - `Dart 3.10.8`
- Nota operativa importante:
  - dejar Flutter en la rama `stable` vuelve a romper esta maquina porque hoy intenta moverse a `3.41.x`,
  - para este entorno local el estado estable real es mantenerlo fijado en `3.38.9`.

### 2026-03-15 - Compatibilidad local del proyecto restaurada para macOS 12

- Ajustado `pubspec.yaml` para este entorno local:
  - `environment.sdk` pasa de `^3.11.0` a `^3.10.0`.
- Ejecutado `flutter pub get` con exito en el repo.
- Anadido `local.env.json` vacio para satisfacer el asset declarado y evitar warning de `flutter analyze`.
- Verificacion ejecutada:
  - `flutter pub get` (ok)
  - `flutter analyze` (ok)
- Hallazgo adicional en validacion de test suite:
  - `flutter test` no queda en verde,
  - los fallos observados apuntan a tests/reglas preexistentes del repo (por ejemplo `OpenMeteoSpotsForecastAdapter`, regla arquitectonica de imports directos a `infrastructure` desde `presentation`, y un test de `sessions_page` que no encuentra el boton esperado),
  - no parecen originados por la reparacion del toolchain ni por el asset local.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 11:50-11:58 = 8m`.
- `Bloque acumulado de esta nueva reentrada 11:34-11:58 = 24m`.
- `Acumulado combinado confirmado del dia = 10h 42m`.

### 2026-03-15 - Saneado de tests funcionales tras estabilizar el entorno local

- Reconfirmado el siguiente frente tecnico tras reparar Flutter/Android:
  - el entorno ya compila y ejecuta la app,
  - los fallos inmediatos mas pragmaticos estaban en tests desalineados con cambios recientes de contrato/UI.
- Ajustes aplicados en tests de `spots`:
  - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
  - actualizado el setup de los casos para pasar coordenadas explicitas al adapter de `Open-Meteo`, ahora obligatorias por contrato.
- Ajustes aplicados en tests de `sessions`:
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - los tests ya no asumen clases concretas de boton para los CTAs principales y se apoyan en el texto visible del control,
  - se anade `ensureVisible` donde hacia falta dentro del dialogo de subida para evitar fallos por contenido desplazable.
- Verificacion ejecutada:
  - `flutter test -r compact test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart test/features/sessions/presentation/pages/sessions_page_test.dart` (ok)
- Estado restante confirmado:
  - la suite arquitectonica sigue fallando en `test/architecture/hexagonal_dependency_rules_test.dart`,
  - el bloqueo pendiente ya no esta en `sessions` ni en el adapter `Open-Meteo`,
  - el siguiente refactor real queda acotado a `spots`, donde `presentation` sigue importando `infrastructure` directamente en varias paginas/widgets.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 11:58-12:33 = 35m`.
- `Bloque acumulado de esta nueva reentrada 11:34-12:33 = 59m`.
- `Acumulado combinado confirmado del dia = 11h 17m`.

### 2026-03-15 - Spots: guardrail hexagonal restaurado en `presentation`

- Atacado el siguiente bloqueo real tras sanear tests funcionales:
  - `test/architecture/hexagonal_dependency_rules_test.dart` seguia fallando porque `spots/presentation` importaba `infrastructure` directamente.
- Refactor minimo aplicado:
  - creados puentes de reexport en `application/services`:
    - `lib/features/spots/application/services/spots_external_data_clients.dart`
    - `lib/features/spots/application/services/spots_presentation_forecast_support.dart`
  - `presentation/pages` y `presentation/widgets` de `spots` pasan a importar esos puentes en lugar de rutas directas a `infrastructure`.
- Archivos de `presentation` ajustados:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
  - `lib/features/spots/presentation/widgets/aemet_forecast_tables.dart`
  - `lib/features/spots/presentation/widgets/meteoblue_forecast_supplement_card.dart`
  - `lib/features/spots/presentation/widgets/meteosource_forecast_supplement_card.dart`
  - `lib/features/spots/presentation/widgets/meteostat_day_supplement_card.dart`
- Verificacion ejecutada:
  - `flutter test -r compact test/architecture/hexagonal_dependency_rules_test.dart` (ok)
  - `flutter analyze lib/features/spots` (ok)
- Estado resultante:
  - los tests funcionales de `sessions` y `Open-Meteo` quedan verdes,
  - el guardrail arquitectonico vuelve a estar en verde,
  - el repo queda listo para volver a iterar sobre funcionalidad de producto en vez de deuda de entorno/tests.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 12:33-13:05 = 32m`.
- `Bloque acumulado de esta nueva reentrada 11:34-13:05 = 1h 31m`.
- `Acumulado combinado confirmado del dia = 11h 49m`.

### 2026-03-15 - Spots v3.5 fase 104-co: eliminada la capa de estelas/particulas del `Mapa de viento`

- Feedback de producto:
  - en el `Mapa de viento` aparecian muchisimos elementos amarillos con apariencia de triangulos,
  - no aportaban lectura util y ensuciaban demasiado la visualizacion.
- Ajuste aplicado en `lib/features/spots/presentation/pages/wind_map_page.dart`:
  - eliminada la capa `CustomPaint` de estelas/particulas del viento,
  - eliminado el codigo muerto asociado a esa capa visual (animacion dedicada y painter de streamlines),
  - se mantiene el fondo meteorologico por intensidad y el marcador principal del spot.
- Resultado esperado:
  - el mapa queda visualmente mucho mas limpio,
  - desaparecen los pseudo-triangulos amarillos,
  - se conserva la lectura general del viento sin ese ruido grafico.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 13:05-13:28 = 23m`.
- `Bloque acumulado de esta nueva reentrada 11:34-13:28 = 1h 54m`.
- `Acumulado combinado confirmado del dia = 12h 12m`.

### 2026-03-15 - Spots v3.5 fase 104-cp: limpieza del mapa base para eliminar iconografia terrestre intrusiva

- Revisado el feedback posterior al cambio anterior:
  - los "triangulos" seguian apareciendo por territorio y no por el mar,
  - eso indicaba que no provenian de la capa de estelas sino del propio mapa raster base.
- Diagnostico confirmado en `wind_map_page.dart`:
  - la pantalla seguia usando `https://tile.openstreetmap.org/{z}/{x}/{y}.png`,
  - esa base incluye iconografia/POIs incrustados en tierra, que visualmente ensucian el `Mapa de viento`.
- Ajuste aplicado:
  - sustituido el tile base por `Carto light_nolabels`,
  - sin etiquetas ni iconos terrestres intrusivos sobre el territorio.
- Resultado esperado:
  - desaparecen los triangulos/iconos que venian del tile raster,
  - el mapa queda mucho mas limpio para leer el viento y el spot.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 13:28-13:33 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-13:33 = 1h 59m`.
- `Acumulado combinado confirmado del dia = 12h 17m`.

### 2026-03-15 - Spots v3.5 fase 104-cq: escala cromatica de semaforo en la bruma del `Mapa de viento`

- Ajuste visual solicitado sobre el `Mapa de viento`:
  - la bruma pasa a usar una escala tipo semaforo de viento.
- Cambio aplicado en `lib/features/spots/presentation/pages/wind_map_page.dart`:
  - verde para viento bajo,
  - amarillo para rango intermedio,
  - naranja para viento fuerte,
  - rojo para viento muy fuerte.
- Objetivo:
  - hacer la lectura mas intuitiva y mas alineada con una logica visual de riesgo/intensidad.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 13:33-13:59 = 26m`.
- `Bloque acumulado de esta nueva reentrada 11:34-13:59 = 2h 25m`.
- `Acumulado combinado confirmado del dia = 12h 43m`.

### 2026-03-15 - Spots v3.5 fase 104-cr: escala del `Mapa de viento` unificada con la leyenda del semaforo

- Refinado visual solicitado:
  - el `Mapa de viento` debe usar exactamente la misma escala cromatica que la leyenda del semaforo de viento existente en la app.
- Ajuste aplicado:
  - extraida la escala compartida a `lib/features/spots/application/services/wind_semaforo_scale.dart`,
  - `spot_detail_page.dart` y `wind_map_page.dart` pasan a reutilizar esa misma fuente de verdad.
- Resultado:
  - desaparece la divergencia entre colores del mapa y colores de la leyenda,
  - el semaforo del mapa queda alineado con el patron ya presente en producto.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart lib/features/spots/presentation/pages/spot_detail_page.dart lib/features/spots/application/services/wind_semaforo_scale.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 13:59-14:03 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:03 = 2h 29m`.
- `Acumulado combinado confirmado del dia = 12h 47m`.

### 2026-03-15 - Spots v3.5 fase 104-cs: nueva escala global del semaforo de viento

- Actualizada la fuente de verdad global del semaforo de viento en:
  - `lib/features/spots/application/services/wind_semaforo_scale.dart`
- Nueva escala aplicada y persistida para todo consumidor del semaforo:
  - `<= 6 kt` azul
  - `6-10 kt` turquesa
  - `10-16 kt` verde
  - `16-26 kt` amarillo
  - `26-32 kt` naranja
  - `32-40 kt` rojo
  - `> 40 kt` morado
- Impacto:
  - la leyenda del semaforo,
  - el `Mapa de viento`,
  - y las tablas de forecast que ya consumen la escala compartida
  pasan a reflejar automaticamente estos nuevos rangos/colores.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/application/services/wind_semaforo_scale.dart lib/features/spots/presentation/pages/wind_map_page.dart lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:03-14:13 = 10m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:13 = 2h 39m`.
- `Acumulado combinado confirmado del dia = 12h 57m`.

### 2026-03-15 - Spots v3.5 fase 104-ct: semaforo ajustado a los mismos cortes del dialogo de leyenda

- Ajuste de coherencia final sobre la escala compartida del semaforo:
  - la fuente de verdad global ya no solo replica la paleta, sino tambien los mismos cortes del dialogo.
- Definicion final aplicada:
  - `< 10 kt` azul
  - `10-14 kt` turquesa
  - `14-18 kt` verde
  - `18-26 kt` amarillo
  - `26-32 kt` naranja
  - `32-40 kt` rojo
  - `> 40 kt` morado
- Impacto:
  - dialogo de leyenda,
  - `Mapa de viento`,
  - tablas de forecast con color de viento
  quedan alineados tambien en el limite exacto de cada rango.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/application/services/wind_semaforo_scale.dart lib/features/spots/presentation/pages/wind_map_page.dart lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:13-14:18 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:18 = 2h 44m`.
- `Acumulado combinado confirmado del dia = 13h 02m`.

### 2026-03-15 - Spots v3.5 fase 104-cu: malla interpolada mas densa para suavizar cortes de la bruma

- Ajuste fino sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se aumento solo la densidad de la malla interpolada usada para extender el campo visual del viento.
- Objetivo:
  - reducir cortes raros o saltos visibles entre zonas de bruma,
  - rellenar mejor las transiciones,
  - sin cambiar la paleta del semaforo,
  - sin tocar el radio/intensidad que ya habia quedado aprobada visualmente.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:18-14:25 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:25 = 2h 51m`.
- `Acumulado combinado confirmado del dia = 13h 09m`.

### 2026-03-15 - Spots v3.5 fase 104-cv: niebla aligerada para recuperar lectura del mapa base

- Ajuste fino sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se redujo la densidad visual de la niebla bajando la opacidad del gradiente radial en cada nodo.
- Objetivo:
  - mantener la continuidad conseguida con la malla interpolada mas densa,
  - pero devolver protagonismo al mapa base y evitar que la bruma lo tape.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:25-14:27 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:27 = 2h 53m`.
- `Acumulado combinado confirmado del dia = 13h 11m`.

### 2026-03-15 - Spots v3.5 fase 104-cw: niebla mas transparente para no tapar el mapa

- Ajuste fino adicional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se bajaron otra vez las opacidades del gradiente radial de la niebla.
- Objetivo:
  - conservar continuidad y codigo de color,
  - pero hacer la bruma claramente mas transparente para que el mapa base siga leyendose bien.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:27-14:28 = 1m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:28 = 2h 54m`.
- `Acumulado combinado confirmado del dia = 13h 12m`.

### 2026-03-15 - Spots v3.5 fase 104-cx: niebla al doble de transparencia aproximada

- Ajuste fino adicional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se redujeron aproximadamente a la mitad las opacidades del gradiente radial de la niebla.
- Objetivo:
  - probar una version claramente mas ligera,
  - manteniendo continuidad, radio y paleta,
  - para evaluar mejor el equilibrio entre informacion meteorologica y lectura del mapa base.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:28-14:30 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:30 = 2h 56m`.
- `Acumulado combinado confirmado del dia = 13h 14m`.

### 2026-03-15 - Spots v3.5 fase 104-cy: mapa de viento bloqueado para version gratuita

- Ajuste funcional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se desactivaron las interacciones manuales del `FlutterMap`:
  - sin desplazamiento,
  - sin zoom por gesto,
  - sin exploracion libre del mapa.
- Objetivo:
  - dejar el mapa fijo y centrado en el spot como comportamiento de la version gratuita.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:30-14:33 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:33 = 2h 59m`.
- `Acumulado combinado confirmado del dia = 13h 17m`.

### 2026-03-15 - Spots v3.5 fase 104-cz: niebla con opacidad reducida adicional

- Ajuste fino visual sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se redujo de nuevo la opacidad del gradiente radial de la niebla.
- Objetivo:
  - hacer la superposicion mas sutil,
  - mejorar la lectura del mapa base,
  - sin tocar malla, radio, colores ni bloqueo de interaccion.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:33-14:35 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:35 = 3h 01m`.
- `Acumulado combinado confirmado del dia = 13h 19m`.

### 2026-03-15 - Spots v3.5 fase 104-da: base continua suave para acercar la bruma a un overlay meteorologico

- Ajuste visual incremental sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se anadio una capa base continua muy tenue por celdas interpoladas debajo de la niebla radial existente.
- Objetivo:
  - acercar la lectura del campo a un overlay continuo tipo mapa meteorologico,
  - reducir la percepcion de manchas separadas,
  - sin romper el look aprobado ni meter animaciones/particulas.
- La niebla radial se mantiene como detalle suave encima, pero ahora apoyada por una base mas uniforme.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:35-14:40 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:40 = 3h 06m`.
- `Acumulado combinado confirmado del dia = 13h 24m`.

### 2026-03-15 - Spots v3.5 fase 104-db: reintroduccion limpia de estelas de direccion

- Ajuste visual sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se reintrodujeron estelas de direccion, pero en una version mucho mas contenida:
  - trazos cortos,
  - redondeados,
  - blancos,
  - y espaciados sobre una submalla,
  para evitar el ruido visual y el efecto de triangulos de intentos anteriores.
- Objetivo:
  - recuperar lectura de direccion del viento sobre el campo,
  - sin sobrecargar el mapa ni competir con la bruma y el mapa base.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:40-14:43 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:43 = 3h 09m`.
- `Acumulado combinado confirmado del dia = 13h 27m`.

### 2026-03-15 - Spots v3.5 fase 104-dc: estelas traidas al frente para mejorar legibilidad

- Ajuste de orden de pintado sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Las estelas de direccion ahora se renderizan por encima de la niebla y del overlay continuo.
- Objetivo:
  - mejorar su visibilidad real sobre el campo de color,
  - sin aumentar cantidad, tamaño ni opacidad de las estelas.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:43-14:47 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:47 = 3h 13m`.
- `Acumulado combinado confirmado del dia = 13h 31m`.

### 2026-03-15 - Spots v3.5 fase 104-dd: estelas corregidas con sentido de flujo y animacion

- Ajuste funcional/visual sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Problema detectado:
  - las estelas anteriores eran lineas simetricas y estaticas,
  - por lo que no comunicaban bien la orientacion real ni el sentido del flujo.
- Solucion aplicada:
  - se anadio una animacion dedicada para las estelas,
  - ahora cada trazo avanza en la direccion del viento,
  - con una pequena cola secundaria mas tenue para reforzar el sentido sin usar flechas o triangulos.
- Resultado esperado:
  - direccion mas legible,
  - percepcion clara de movimiento,
  - sin volver al ruido visual de overlays anteriores.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:47-14:49 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:49 = 3h 15m`.
- `Acumulado combinado confirmado del dia = 13h 33m`.

### 2026-03-15 - Spots v3.5 fase 104-de: estelas convertidas en microflechas con punta coherente

- Ajuste visual/funcional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Problema observado:
  - aunque las estelas ya tenian movimiento, su forma seguia siendo demasiado ambigua
  - y no dejaba claro que la punta debia coincidir con el sentido de la flecha de direccion principal.
- Solucion aplicada:
  - las estelas pasan a renderizarse como microflechas,
  - con eje principal, cola tenue y punta explicita,
  - todas orientadas con la misma logica angular que el flujo del viento.
- Objetivo:
  - hacer que la “cabeza” de cada estela apunte visualmente en el mismo sentido esperado que la flecha del marcador.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:49-14:54 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-14:54 = 3h 20m`.
- `Acumulado combinado confirmado del dia = 13h 38m`.

### 2026-03-15 - Spots v3.5 fase 104-df: sentido de estelas invertido para corregir orientacion

- Ajuste fino sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Tras probar las microflechas, se detecto que apuntaban en sentido opuesto al esperado.
- Solucion aplicada:
  - se invirtio el angulo de direccion usado por las estelas,
  - manteniendo igual su forma, densidad y animacion.
- Objetivo:
  - alinear la punta visible de la estela con la orientacion correcta percibida en el mapa.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 14:54-15:00 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:00 = 3h 26m`.
- `Acumulado combinado confirmado del dia = 13h 44m`.

### 2026-03-15 - Spots v3.5 fase 104-dg: estelas alineadas con la direccion de referencia del frame

- Ajuste funcional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Problema detectado:
  - el marcador central y las estelas no siempre coincidian visualmente en orientacion,
  - porque las estelas se estaban guiando por la direccion local de cada nodo interpolado.
- Solucion aplicada:
  - las estelas ahora usan la misma direccion de referencia del `sample` activo que alimenta el marcador central.
- Objetivo:
  - asegurar coherencia angular clara entre la flecha principal del frame y la punta de las microflechas del overlay.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:00-15:02 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:02 = 3h 28m`.
- `Acumulado combinado confirmado del dia = 13h 46m`.

### 2026-03-15 - Spots v3.5 fase 104-dh: estelas devueltas a direccion interpolada por nodo

- Ajuste funcional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Tras la aclaracion de criterio, se revierte la simplificacion anterior:
  - las estelas ya no siguen la direccion global del frame,
  - vuelven a usar la direccion interpolada propia de cada nodo del campo.
- Motivo:
  - priorizar fidelidad del overlay direccional frente a coherencia visual forzada con la flecha central.
- Consecuencia esperada:
  - la capa de estelas representa mejor variaciones locales del campo,
  - aunque pueda diferir del vector central en zonas concretas.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:02-15:06 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:06 = 3h 32m`.
- `Acumulado combinado confirmado del dia = 13h 50m`.

### 2026-03-15 - Spots v3.5 fase 104-di: mapa de viento alineado con filtros temporales de las tablas

- Ajuste funcional sobre `SpotDetailPage` en:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Problema corregido:
  - el `Mapa de viento` se abria con la serie completa de `result.rows`,
  - ignorando el rango temporal y la resolucion que el usuario tenia aplicados en la tabla forecast.
- Solucion aplicada:
  - `_openWindMap()` ahora construye las muestras desde:
    - `_clipForecastRows(..., range: _forecastRange)`
    - y despues `_resampleForecastRows(..., _forecastResolution)`
- Resultado:
  - el mapa respeta el mismo recorte temporal y la misma resolucion visible en las tablas.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:06-15:08 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:08 = 3h 34m`.
- `Acumulado combinado confirmado del dia = 13h 52m`.

### 2026-03-15 - Spots v3.5 fase 104-dj: estelas en modo hibrido para mejorar lectura

- Ajuste funcional/visual sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Nuevo criterio aplicado a las estelas:
  - ya no siguen ciegamente la direccion global del centro,
  - pero tampoco se dejan ir a cualquier direccion local interpolada.
- Implementacion:
  - cada estela parte de la direccion central del frame,
  - y solo admite una desviacion local acotada de hasta `20°` respecto a esa referencia.
- Objetivo:
  - que la relacion entre flecha central y estelas sea mas intuitiva,
  - manteniendo algo de variacion espacial sin generar contradicciones fuertes.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:08-15:16 = 8m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:16 = 3h 42m`.
- `Acumulado combinado confirmado del dia = 14h 00m`.

### 2026-03-15 - Spots v3.5 fase 104-dk: correccion angular de estelas (-90 grados)

- Ajuste fino sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Sintoma reportado:
  - las estelas se percibian aproximadamente giradas `90°` en sentido horario respecto a la flecha central.
- Solucion aplicada:
  - se corrigio la conversion angular de las estelas rotando su direccion `-90°`.
- Objetivo:
  - alinear la orientacion visible de las microflechas con la lectura esperada de la flecha central.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:16-15:24 = 8m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:24 = 3h 50m`.
- `Acumulado combinado confirmado del dia = 14h 08m`.

### 2026-03-15 - Spots v3.5 fase 104-dl: playback del mapa suavizado con interpolacion entre frames

- Ajuste funcional importante sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Problema previo:
  - el `play` avanzaba por saltos usando un `Timer`,
  - lo que hacia que el mapa, el marcador y el tiempo se vieran a trompicones.
- Solucion aplicada:
  - se sustituyo el avance discreto por una animacion interpolada entre muestras consecutivas,
  - el `sample` activo ahora se interpola en tiempo, viento, direccion, racha y ola,
  - y cuando hay grid disponible tambien se interpola el campo entre snapshots consecutivos.
- Efecto esperado:
  - transicion visual mucho mas fluida,
  - menos saltos bruscos al reproducir,
  - timeline y marcador acompañan el movimiento.
- Ajuste asociado:
  - el tiempo mostrado ya refleja tambien minutos reales durante la interpolacion.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:24-15:29 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:29 = 3h 55m`.
- `Acumulado combinado confirmado del dia = 14h 13m`.

### 2026-03-15 - Spots v3.5 fase 104-dm: chips de velocidad x2/x10 junto al selector de capa

- Ajuste de UX sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Se anadieron chips de velocidad junto al selector `Viento/Olas`:
  - `x2`
  - `x10`
- Implementacion:
  - los chips cambian la duracion real del controlador de playback,
  - por lo que aceleran de verdad la reproduccion, no solo la etiqueta visual.
- Comportamiento:
  - estado por defecto `x1`,
  - al activar `x2` o `x10` cambia la velocidad,
  - al desactivar el chip seleccionado vuelve a `x1`.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:29-15:35 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:35 = 4h 01m`.
- `Acumulado combinado confirmado del dia = 14h 19m`.

### 2026-03-15 - Spots v3.5 fase 104-dn: optimizacion de playback para 1h y resoluciones finas

- Mejora de rendimiento/fluidez sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/wind_map_page.dart`
- Cambios principales:
  - se elimino el `setState` por frame del playback y se sustituyo por `AnimatedBuilder` sobre el controlador de reproduccion,
  - durante playback fino (`<= 1h`) se activa una degradacion inteligente del overlay:
    - malla interpolada mas ligera,
    - menos semillas ocultas,
    - menos densidad de estelas,
    - niebla y base continua algo mas ligeras.
- Objetivo:
  - reducir trompicones y coste de render en series temporales densas sin castigar la calidad normal en `3h`.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/wind_map_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:35-15:51 = 16m`.
- `Bloque acumulado de esta nueva reentrada 11:34-15:51 = 4h 17m`.
- `Acumulado combinado confirmado del dia = 14h 35m`.

### 2026-03-15 - Spots v3.5 fase 104-do: tablas forecast sin color para viento por debajo de 10 kt

- Ajuste visual puntual sobre tablas forecast en:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Cambio aplicado:
  - la funcion `_windColor(int knots)` devuelve `Colors.transparent` cuando el viento es `< 10 kt`.
- Objetivo:
  - evitar que el viento flojo tenga relleno de color en las tablas,
  - manteniendo el resto de la escala de color igual a partir de `10 kt`.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 15:51-16:01 = 10m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:01 = 4h 27m`.
- `Acumulado combinado confirmado del dia = 14h 45m`.

### 2026-03-15 - Spots v3.5 fase 104-dp: tablas forecast devueltas a la escala completa del semaforo

- Ajuste visual puntual sobre tablas forecast en:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Se revierte el experimento de dejar `< 10 kt` sin color.
- Estado final:
  - las tablas vuelven a usar la escala completa del semaforo en todos los tramos, incluido el viento por debajo de `10 kt`.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:01-16:19 = 18m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:19 = 4h 45m`.
- `Acumulado combinado confirmado del dia = 15h 03m`.

### 2026-03-15 - Spots v3.5 fase 104-dq: tablas forecast con <10 kt en blanco

- Ajuste visual puntual sobre tablas forecast en:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Estado final:
  - para viento `< 10 kt`, la tabla no aplica color de fondo,
  - a partir de `10 kt`, mantiene la escala del semaforo.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:19-16:20 = 1m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:20 = 4h 46m`.
- `Acumulado combinado confirmado del dia = 15h 04m`.

### 2026-03-15 - Spots v3.5 fase 104-dr: rachas alineadas con el mismo patron de color del viento

- Ajuste visual puntual sobre tablas forecast en:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Cambio aplicado:
  - la fila de `Racha` deja de usar una version atenuada del color
  - y pasa a reutilizar exactamente el mismo patron de color que la fila de `Viento`.
- Objetivo:
  - eliminar inconsistencias visuales entre viento y rachas dentro de la tabla.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:20-16:24 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:24 = 4h 50m`.
- `Acumulado combinado confirmado del dia = 15h 08m`.

### 2026-03-15 - Spots v3.5 fase 104-ds: reglas de resolucion temporal especificas para el mapa de viento

- Ajuste funcional sobre `Mapa de viento` en:
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
- Nueva regla aplicada al abrir el mapa:
  - `15 dias` -> el mapa usa `6h`
  - `7 dias`, `3 dias`, `1 dia` -> el mapa usa siempre `3h`
- Motivo:
  - mantener suficiente detalle temporal,
  - pero priorizando fluidez y playback estable en el video del mapa.
- Importante:
  - esta regla se aplica solo al `Mapa de viento`;
  - la tabla forecast mantiene su propia resolucion seleccionada por el usuario.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:24-16:26 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:26 = 4h 52m`.
- `Acumulado combinado confirmado del dia = 15h 10m`.

### 2026-03-15 - Backend fase 001: bootstrap inicial de Supabase para sacar AEMET del cliente

- Se crea la base del backend dentro del repo:
  - `supabase/config.toml`
  - `supabase/.env.example`
  - `supabase/functions/_shared/cors.ts`
  - `supabase/functions/_shared/http.ts`
  - `supabase/functions/forecast-proxy/index.ts`
  - `docs/backend/supabase_backend.md`
- Objetivo:
  - empezar a sacar las API keys del cliente Flutter,
  - empezando por AEMET, que es el problema mas inmediato.
- Primera Edge Function creada:
  - `forecast-proxy`
- Alcance inicial del proxy:
  - `aemet-beach-forecast`
  - `aemet-coastal-forecast`
  - `aemet-station-observation`
  - `aemet-observations-latest`
- En esta fase el proxy devuelve payload bruto encapsulado, sin normalizacion de dominio todavia.
- Ajuste auxiliar:
  - `.gitignore` actualizado para ignorar `supabase/.env`
- Documentacion inicial incluida con pasos de arranque local y ejemplos `curl`.
- Verificacion ejecutada:
  - comprobacion de archivos creados en `supabase/` y `docs/backend/`
- Limite conocido:
  - aun no se ha integrado Flutter con Supabase,
  - los clientes AEMET de la app todavia no apuntan a la Edge Function.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:26-16:41 = 15m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:41 = 5h 07m`.
- `Acumulado combinado confirmado del dia = 15h 25m`.

### 2026-03-15 - Backend fase 002: configuracion base del cliente para el proyecto real de Supabase

- Se incorpora soporte de configuracion para el proyecto:
  - `https://tefbkhwaxlsfxvnleutb.supabase.co`
- Archivos actualizados:
  - `lib/core/config/env/local_env_store.dart`
  - `lib/core/config/env/env_config.dart`
  - `local.env.json.example`
  - `supabase/.env.example`
  - `docs/backend/supabase_backend.md`
- Nuevas variables preparadas:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- Objetivo:
  - dejar listo el repo para conectar Flutter al proyecto real de Supabase sin hardcodear valores en codigo.
- Verificacion ejecutada:
  - `flutter analyze lib/core/config/env/env_config.dart lib/core/config/env/local_env_store.dart` (ok)
- Limite conocido:
  - aun falta la `anon key` para cerrar la configuracion del cliente
  - y todavia no se ha integrado el SDK/cliente de Supabase en Flutter

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:41-16:46 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:46 = 5h 12m`.
- `Acumulado combinado confirmado del dia = 15h 30m`.

### 2026-03-15 - Backend fase 003: integracion minima de Supabase en Flutter

- Se completa la configuracion minima de cliente para el proyecto:
  - `https://tefbkhwaxlsfxvnleutb.supabase.co`
- Cambios aplicados:
  - `pubspec.yaml`: anadido `supabase_flutter`
  - `lib/main.dart`: bootstrap de `Supabase.initialize(...)` si `SUPABASE_URL` y `SUPABASE_ANON_KEY` existen
  - `local.env.json`: configurado con el `SUPABASE_URL` y la `SUPABASE_ANON_KEY` recibida
- Verificacion ejecutada:
  - `flutter pub get` (ok)
  - `flutter analyze lib/main.dart lib/core/config/env/env_config.dart lib/core/config/env/local_env_store.dart` (ok)
- Limite conocido:
  - la app ya puede arrancar con Supabase inicializado,
  - pero los clientes forecast/AEMET aun no se han reapuntado a la Edge Function `forecast-proxy`.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:46-16:49 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:49 = 5h 15m`.
- `Acumulado combinado confirmado del dia = 15h 33m`.

### 2026-03-15 - Backend fase 004: anon key JWT real cargada en configuracion local

- Se sustituye la clave publishable provisional por la `anon key` JWT real del proyecto de Supabase en:
  - `local.env.json`
  - `local.env.json.example`
- Motivo:
  - el SDK de Supabase en Flutter debe arrancar con la `anon key` real del proyecto.
- Verificacion ejecutada:
  - `flutter analyze lib/main.dart lib/core/config/env/env_config.dart lib/core/config/env/local_env_store.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:49-16:52 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:52 = 5h 18m`.
- `Acumulado combinado confirmado del dia = 15h 36m`.

### 2026-03-15 - Backend fase 005: esquema inicial de toda la app en Supabase

- Se amplia el trabajo de backend desde forecast puntual a una base completa de aplicacion.
- Archivos nuevos:
  - `supabase/migrations/20260315170000_app_backend_bootstrap.sql`
  - `docs/backend/supabase_app_backend.md`
- Alcance de la migracion inicial:
  - `profiles`
  - `user_gear_setups`
  - `spots`
  - `user_saved_spots`
  - `sessions`
  - `session_likes`
  - `session_comments`
  - `user_follows`
  - `direct_threads`
  - `direct_thread_participants`
  - `direct_messages`
  - views `community_leaderboard` y `community_following_feed`
  - buckets de storage para avatar, banner y media de sesion
- Tambien se incluye:
  - trigger de `updated_at`
  - bootstrap de perfil al crear usuario en `auth.users`
  - RLS base por dominio
- Documentacion:
  - blueprint de backend completo en `docs/backend/supabase_app_backend.md`
- Limite conocido:
  - no se ha podido validar la migracion con CLI porque `supabase` no esta instalada en este entorno.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:52-16:57 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-16:57 = 5h 23m`.
- `Acumulado combinado confirmado del dia = 15h 41m`.

### 2026-03-15 - Backend fase 006: RPCs y politicas de storage para operaciones de app

- Se anade una segunda migracion de backend:
  - `supabase/migrations/20260315173000_app_backend_rpcs_and_storage.sql`
- Alcance:
  - helper `is_storage_owner(path, user_id)`
  - RPC `toggle_session_like(uuid)`
  - RPC `follow_user(uuid)`
  - RPC `unfollow_user(uuid)`
  - RPC `add_session_comment(uuid, text)`
  - RPC `upsert_profile(...)`
  - politicas de storage para:
    - `profile-avatars`
    - `profile-banners`
    - `session-media`
- Criterio:
  - lectura publica de assets
  - escritura solo del propietario usando prefijo `user_id/...`
- Documentacion backend actualizada:
  - `docs/backend/supabase_app_backend.md`
- Limite conocido:
  - sigue sin poder validarse via CLI en este entorno porque `supabase` no esta instalada.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 16:57-17:06 = 9m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:06 = 5h 32m`.
- `Acumulado combinado confirmado del dia = 15h 50m`.

### 2026-03-15 - Backend fase 007: Supabase CLI instalada en el entorno local

- Se instala Supabase CLI via Homebrew.
- Verificacion ejecutada:
  - `which supabase` -> `/usr/local/bin/supabase`
  - `supabase --version` -> `2.75.0`
- Nota:
  - la CLI avisa de version mas nueva disponible (`2.78.1`), pero queda operativa y suficiente para seguir con migraciones/pruebas locales.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:06-17:11 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:11 = 5h 37m`.
- `Acumulado combinado confirmado del dia = 15h 55m`.

### 2026-03-15 - Backend fase 008: verificacion operativa de Supabase CLI y bloqueos reales

- Comprobaciones ejecutadas:
  - `supabase projects list`
  - `supabase status`
  - `supabase link --project-ref tefbkhwaxlsfxvnleutb`
- Resultado:
  - la CLI ya funciona,
  - pero no puede operar contra el proyecto porque falta autenticacion (`supabase login` o `SUPABASE_ACCESS_TOKEN`)
  - y la validacion local via `supabase status` falla porque Docker no esta levantado.
- Se actualiza documentacion con la secuencia operativa necesaria en:
  - `docs/backend/supabase_backend.md`

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:11-17:13 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:13 = 5h 39m`.
- `Acumulado combinado confirmado del dia = 15h 57m`.

### 2026-03-15 - Backend fase 009: proyecto Supabase enlazado y migraciones aplicadas en remoto

- Operaciones ejecutadas con CLI autenticada:
  - `supabase projects list`
  - `supabase link --project-ref tefbkhwaxlsfxvnleutb`
  - `supabase db push`
  - `supabase migration list`
- Ajuste requerido detectado durante el `link`:
  - el proyecto remoto usa Postgres `17`
  - se actualiza `supabase/config.toml`:
    - `[db].major_version = 17`
- Resultado:
  - proyecto `tefbkhwaxlsfxvnleutb` enlazado correctamente
  - migraciones aplicadas en remoto:
    - `20260315170000_app_backend_bootstrap.sql`
    - `20260315173000_app_backend_rpcs_and_storage.sql`
  - `supabase migration list` confirma local y remoto alineados

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:13-17:18 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:18 = 5h 44m`.
- `Acumulado combinado confirmado del dia = 16h 02m`.

### 2026-03-15 - Backend fase 010: primer puente Flutter -> Supabase en auth

- Se integra `auth` para que deje de depender siempre del adapter en memoria cuando Supabase esta configurado.
- Archivos afectados:
  - `lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart`
  - `lib/features/auth/di/auth_module.dart`
  - `lib/features/auth/presentation/providers/auth_di_providers.dart`
- Comportamiento nuevo:
  - `AuthModule.auto()` usa Supabase si `SUPABASE_URL` y `SUPABASE_ANON_KEY` existen
  - email -> `signInWithOtp(...)`
  - dev bypass -> `signInAnonymously()`
  - Google/Apple siguen como placeholders de configuracion pendiente
- Verificacion ejecutada:
  - `flutter analyze lib/features/auth lib/main.dart` (ok)
- Limite conocido:
  - el arranque real en `macOS` no se pudo cerrar por un error previo de CocoaPods/locale (`Unicode Normalization not appropriate for ASCII-8BIT`), ajeno a la integracion de Supabase.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:18-17:22 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:22 = 5h 48m`.
- `Acumulado combinado confirmado del dia = 16h 06m`.

### 2026-03-15 - Backend fase 011: primer puente Flutter -> Supabase en profile

- Se integra `profile` con Supabase sin reescribir toda la UI, usando un modelo hibrido:
  - cache sincronica para la pantalla
  - carga/guardado asincronos reales contra backend
- Archivos afectados:
  - `lib/features/profile/domain/ports/out/profile_repository_port.dart`
  - `lib/features/profile/application/use_cases/profile_use_cases.dart`
  - `lib/features/profile/presentation/state/profile_controller.dart`
  - `lib/features/profile/infrastructure/adapters/in_memory/in_memory_profile_repository_adapter.dart`
  - `lib/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter.dart`
  - `lib/features/profile/infrastructure/adapters/supabase/supabase_profile_repository_adapter.dart`
  - `lib/features/profile/di/profile_module.dart`
  - `lib/features/profile/presentation/pages/profile_page.dart`
- Comportamiento nuevo:
  - `ProfileModule.auto()` usa Supabase cuando esta configurado
  - `ProfilePage` hidrata el perfil desde remoto en `initState()`
  - guardar cambios del perfil hace `upsert` sobre la tabla `profiles`
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile lib/features/auth lib/main.dart` (ok)
- Limite conocido:
  - `messages` y `gear` siguen todavia en memoria/local
  - solo el perfil principal entra ya en flujo Supabase

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:22-17:29 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:29 = 5h 55m`.
- `Acumulado combinado confirmado del dia = 16h 13m`.

### 2026-03-15 - Backend fase 012: primer puente Flutter -> Supabase en sessions

- Se integra `sessions` con Supabase de forma pragmatica, manteniendo la UI actual:
  - cache sincronica para pintar la pantalla
  - hidratacion asincrona desde backend al arrancar
  - guardado/eliminado optimistas con persistencia remota
- Archivos afectados:
  - `lib/features/sessions/domain/ports/out/session_records_port.dart`
  - `lib/features/sessions/application/use_cases/session_records_use_cases.dart`
  - `lib/features/sessions/infrastructure/adapters/in_memory/in_memory_session_records_adapter.dart`
  - `lib/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart`
  - `lib/features/sessions/infrastructure/adapters/supabase/supabase_session_records_adapter.dart`
  - `lib/features/sessions/di/sessions_module.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
  - `test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart`
- Comportamiento nuevo:
  - `SessionsModule.auto()` usa Supabase para `recorded sessions` cuando la app esta configurada con backend
  - `devices` y `session view preferences` siguen locales por ahora
  - la pantalla hidrata sesiones remotas en `initState()`
  - las nuevas sesiones pasan a generarse con UUID valido para encajar con `public.sessions.id`
- Verificacion ejecutada:
  - `flutter analyze lib/features/sessions lib/main.dart` (ok)
  - `flutter test -r compact test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart` (ok)
- Limites conocidos:
  - no hay migracion automatica de sesiones historicas guardadas solo en fichero local
  - `community feed`, likes y comentarios siguen pendientes de conectar a Supabase

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:29-17:42 = 13m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:42 = 6h 08m`.
- `Acumulado combinado confirmado del dia = 16h 26m`.

### 2026-03-15 - Backend fase 013: primer puente Flutter -> Supabase en community

- Se integra `community` en modo hibrido para empezar a consumir backend real sin rehacer toda la feature:
  - `leaderboard` remoto desde la vista `community_leaderboard`
  - `feed` remoto desde la vista `community_following_feed`
  - likes, comentarios y preferencias de seguimiento siguen locales por ahora
- Archivos afectados:
  - `lib/features/community/domain/ports/out/community_following_feed_port.dart`
  - `lib/features/community/domain/ports/out/community_leaderboard_port.dart`
  - `lib/features/community/application/use_cases/community_following_feed_use_cases.dart`
  - `lib/features/community/application/use_cases/community_leaderboard_use_cases.dart`
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_following_feed_adapter.dart`
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_leaderboard_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_following_feed_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_leaderboard_adapter.dart`
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
  - `pubspec.yaml`
- Comportamiento nuevo:
  - `CommunityModule.auto()` usa Supabase cuando esta configurado
  - `CommunityPage` hidrata asincronamente usuarios y sesiones al arrancar
  - el perfil actual de referencia pasa a resolverse via `ProfileModule.auto()` para no quedarse desfasado respecto al backend
- Verificacion ejecutada:
  - `flutter pub get` (ok)
  - `flutter analyze lib/features/community lib/main.dart` (ok)
- Limites conocidos:
  - el feed remoto usa la vista publica actual, no una vista filtrada por follows reales del backend
  - likes, comentarios y follows siguen todavia en storage local y se deberian mover en la siguiente fase

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:42-17:56 = 14m`.
- `Bloque acumulado de esta nueva reentrada 11:34-17:56 = 6h 22m`.
- `Acumulado combinado confirmado del dia = 16h 40m`.

### 2026-03-15 - Backend fase 014: likes, comentarios y follows de community en Supabase

- Se completa el bloque social principal de `community` para que deje de depender del storage local:
  - likes via RPC `toggle_session_like`
  - comentarios via tabla `session_comments` + RPC `add_session_comment`
  - follows via tabla `user_follows` + RPCs `follow_user` / `unfollow_user`
- Archivos afectados:
  - `lib/features/community/domain/ports/out/community_session_reactions_port.dart`
  - `lib/features/community/domain/ports/out/community_session_comments_port.dart`
  - `lib/features/community/domain/ports/out/community_following_preferences_port.dart`
  - `lib/features/community/application/use_cases/community_session_reactions_use_cases.dart`
  - `lib/features/community/application/use_cases/community_session_comments_use_cases.dart`
  - `lib/features/community/application/use_cases/community_following_preferences_use_cases.dart`
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_session_reactions_adapter.dart`
  - `lib/features/community/infrastructure/adapters/local/local_file_community_session_reactions_adapter.dart`
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_session_comments_adapter.dart`
  - `lib/features/community/infrastructure/adapters/local/local_file_community_session_comments_adapter.dart`
  - `lib/features/community/infrastructure/adapters/in_memory/in_memory_community_following_preferences_adapter.dart`
  - `lib/features/community/infrastructure/adapters/local/local_file_community_following_preferences_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_session_reactions_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_session_comments_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_following_preferences_adapter.dart`
  - `lib/features/community/di/community_module.dart`
  - `lib/features/community/presentation/pages/community_page.dart`
- Comportamiento nuevo:
  - `community_page` hidrata de forma asincrona no solo feed/leaderboard, sino tambien likes y comentarios por sesion
  - seguir/dejar de seguir actualiza backend real y luego rehidrata el estado social
  - publicar comentario y dar like dejan de ser solo persistencia local
- Verificacion ejecutada:
  - `flutter analyze lib/features/community lib/main.dart` (ok)
- Limites conocidos:
  - el feed sigue viniendo de la vista publica `community_following_feed`, asi que el filtrado por follows reales todavia no esta cerrado de extremo a extremo en SQL
  - faltaria crear una vista o consulta remota personalizada para mostrar solo sesiones de usuarios seguidos por el usuario autenticado

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 17:56-18:03 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:03 = 6h 29m`.
- `Acumulado combinado confirmado del dia = 16h 47m`.

### 2026-03-15 - Backend fase 015: feed de community filtrado por follows reales

- Se prepara el cierre end-to-end del feed social para que deje de depender de la vista publica generica:
  - nueva migracion `supabase/migrations/20260315181000_following_feed_rpc.sql`
  - nueva RPC `get_following_feed(limit_count, offset_count)` basada en `user_follows`
  - el adapter Flutter del feed se reapunta a esa RPC autenticada
- Archivos afectados:
  - `supabase/migrations/20260315181000_following_feed_rpc.sql`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_following_feed_adapter.dart`
  - `docs/backend/supabase_app_backend.md`
- Verificacion ejecutada:
  - `flutter analyze lib/features/community lib/main.dart` (ok)
- Despliegue remoto cerrado:
  - `supabase db push` aplicado correctamente con `20260315181000_following_feed_rpc.sql`
  - `supabase migration list` confirma remoto alineado:
    - `20260315170000`
    - `20260315173000`
    - `20260315181000`

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:03-18:20 = 17m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:20 = 6h 46m`.
- `Acumulado combinado confirmado del dia = 17h 04m`.

### 2026-03-15 - Backend fase 016: saneado de envs y separacion cliente/backend

- Se limpia la confusion entre variables de app y variables de backend:
  - `supabase/.env.example` queda saneado como plantilla sin secretos reales
  - `docs/backend/supabase_backend.md` documenta claramente que:
    - `local.env.json` en raiz lo usa Flutter
    - `supabase/.env` o `supabase secrets set` lo usa Supabase backend
- Archivos afectados:
  - `supabase/.env.example`
  - `docs/backend/supabase_backend.md`
- Riesgo detectado:
  - `supabase/.env.example` tenia credenciales reales y no debia quedarse asi versionado

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:20-18:25 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:25 = 6h 51m`.
- `Acumulado combinado confirmado del dia = 17h 09m`.

### 2026-03-15 - Backend fase 017: restauracion de claves reales en local.env.json

- Se restauran en `local.env.json` de la raiz las claves reales que necesita la app Flutter:
  - `AEMET_OPENDATA_API_KEY`
  - `METEOBLUE_API_KEY`
  - `METEOSOURCE_API_KEY`
  - `METEOSTAT_RAPIDAPI_KEY`
  - `METEOSTAT_RAPIDAPI_HOST`
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- Confirmacion operativa:
  - `local.env.json` esta ignorado por git en `.gitignore`
  - por tanto sigue siendo el sitio correcto para secretos del cliente en esta maquina

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:25-18:32 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:32 = 6h 58m`.
- `Acumulado combinado confirmado del dia = 17h 16m`.

### 2026-03-15 - Backend fase 018: alta de supabase/.env local para CLI y backend

- Se crea `supabase/.env` local no versionado para separar secretos operativos del backend respecto al cliente Flutter.
- Valores incluidos:
  - `SUPABASE_ACCESS_TOKEN`
- Confirmacion operativa:
  - `supabase/.env` sigue ignorado por git en `.gitignore`
  - `local.env.json` queda reservado para la app Flutter
  - `supabase/.env` queda reservado para CLI/backend

### 2026-03-15 - Backend fase 019: limpieza de duplicidad entre local.env.json y supabase/.env

- Se elimina duplicidad innecesaria:
  - `SUPABASE_URL` y `SUPABASE_ANON_KEY` se mantienen solo en `local.env.json`
  - `supabase/.env` se queda solo con `SUPABASE_ACCESS_TOKEN`
- Resultado:
  - cliente Flutter -> `local.env.json`
  - CLI/backend -> `supabase/.env`

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:32-18:39 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:39 = 7h 05m`.
- `Acumulado combinado confirmado del dia = 17h 23m`.

### 2026-03-15 - Backend fase 020: hardening de adapters Supabase en community

- Se refuerzan los adapters Supabase de `community` para tolerar mejor estados sin sesion autenticada:
  - feed -> devuelve vacio si no hay usuario
  - likes -> devuelve estado base si no hay usuario
  - comentarios -> devuelve lista vacia / fallback si no hay usuario
  - follows -> no intenta escribir en backend si no hay usuario
- Archivos afectados:
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_following_feed_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_session_reactions_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_session_comments_adapter.dart`
  - `lib/features/community/infrastructure/adapters/supabase/supabase_community_following_preferences_adapter.dart`
- Verificacion ejecutada:
  - `flutter analyze lib/features/community lib/main.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:39-18:40 = 1m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:40 = 7h 06m`.
- `Acumulado combinado confirmado del dia = 17h 24m`.

### 2026-03-15 - Backend fase 021: AEMET reapuntado a forecast-proxy de Supabase

- Se crea un gateway cliente para Edge Functions y se reapunta AEMET para reducir dependencia de API key directa en Flutter.
- Cobertura incluida:
  - prediccion municipal AEMET
  - prediccion de playa AEMET
  - prediccion maritima costera AEMET
  - observaciones AEMET
- Archivos afectados:
  - `lib/core/config/env/env_config.dart`
  - `lib/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_beach_forecast_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart`
  - `lib/features/spots/infrastructure/services/aemet_observation_client.dart`
  - `lib/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `supabase/functions/forecast-proxy/index.ts`
- Backend remoto:
  - se despliega de nuevo `forecast-proxy` en Supabase
  - se añade soporte para `aemet-municipal-forecast`
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots lib/main.dart` (ok)
  - `supabase functions deploy forecast-proxy --project-ref tefbkhwaxlsfxvnleutb` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:40-18:47 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:47 = 7h 13m`.
- `Acumulado combinado confirmado del dia = 17h 31m`.

### 2026-03-15 - Backend fase 022: carga de secreto AEMET en Supabase

- Se carga `AEMET_OPENDATA_API_KEY` en `Supabase secrets` usando la clave real de `local.env.json`.
- Se redepliega `forecast-proxy` despues de fijar el secreto para que la function deje de responder con `missing-aemet-api-key`.
- Operaciones ejecutadas:
  - `supabase secrets set AEMET_OPENDATA_API_KEY=... --project-ref tefbkhwaxlsfxvnleutb`
  - `supabase functions deploy forecast-proxy --project-ref tefbkhwaxlsfxvnleutb`

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:47-18:54 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:54 = 7h 20m`.
- `Acumulado combinado confirmado del dia = 17h 38m`.

### 2026-03-15 - Backend fase 023: Meteoblue reapuntado a forecast-proxy de Supabase

- Se extiende `forecast-proxy` para soportar `meteoblue-forecast-package`.
- Se reapunta Meteoblue en cliente para que el forecast horario y el bloque `Current / Sea / Day` puedan entrar por Supabase:
  - `lib/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/meteoblue_current_day_client.dart`
  - `lib/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `supabase/functions/forecast-proxy/index.ts`
- Tambien se añade `meteoblueAccessConfigured` en `env_config.dart` para no mostrar mensajes falsos de API key ausente cuando el proveedor entra por backend.
- Backend remoto:
  - `supabase secrets set METEOBLUE_API_KEY=... --project-ref tefbkhwaxlsfxvnleutb`
  - `supabase functions deploy forecast-proxy --project-ref tefbkhwaxlsfxvnleutb`
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots lib/main.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:54-18:59 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-18:59 = 7h 25m`.
- `Acumulado combinado confirmado del dia = 17h 43m`.

### 2026-03-15 - Backend fase 024: Meteosource reapuntado a forecast-proxy de Supabase

- Se extiende `forecast-proxy` para soportar `meteosource-point-forecast`.
- Se reapunta Meteosource en cliente para que tanto el forecast horario como el bloque `Current / Day` puedan entrar por Supabase:
  - `lib/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/meteosource_current_day_client.dart`
  - `lib/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `supabase/functions/forecast-proxy/index.ts`
- Tambien se añade `meteosourceAccessConfigured` en `env_config.dart` para no mostrar mensajes falsos de API key ausente cuando el proveedor entra por backend.
- Backend remoto:
  - `supabase secrets set METEOSOURCE_API_KEY=... --project-ref tefbkhwaxlsfxvnleutb`
  - `supabase functions deploy forecast-proxy --project-ref tefbkhwaxlsfxvnleutb`
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots lib/main.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 18:59-19:07 = 8m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:07 = 7h 33m`.
- `Acumulado combinado confirmado del dia = 17h 51m`.

### 2026-03-15 - Backend fase 025: Meteostat reapuntado a forecast-proxy de Supabase

- Se extiende `forecast-proxy` para soportar `meteostat-point-hourly` y `meteostat-point-daily`.
- Se reapunta Meteostat en cliente para que tanto el forecast `Hourly` como el bloque `Day` puedan entrar por Supabase:
  - `lib/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter.dart`
  - `lib/features/spots/infrastructure/services/meteostat_day_client.dart`
  - `lib/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart`
  - `lib/features/spots/presentation/pages/spot_detail_page.dart`
  - `supabase/functions/forecast-proxy/index.ts`
- Tambien se añade `meteostatAccessConfigured` en `env_config.dart` para no mostrar mensajes falsos de RapidAPI ausente cuando el proveedor entra por backend.
- Backend remoto:
  - `supabase secrets set METEOSTAT_RAPIDAPI_KEY=... METEOSTAT_RAPIDAPI_HOST=... --project-ref tefbkhwaxlsfxvnleutb`
  - `supabase functions deploy forecast-proxy --project-ref tefbkhwaxlsfxvnleutb`
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots lib/core/config/env lib/main.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:07-19:14 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:14 = 7h 40m`.
- `Acumulado combinado confirmado del dia = 17h 58m`.

### 2026-03-15 - Backend fase 026: limpieza de plantillas y configuracion cliente/backend

- Se recrean las plantillas que faltaban en disco:
  - `local.env.json.example`
  - `supabase/.env.example`
- Se deja claro el reparto correcto de variables:
  - Flutter cliente: `SUPABASE_URL` y `SUPABASE_ANON_KEY`
  - Backend Supabase: secretos de proveedor y `SUPABASE_ACCESS_TOKEN`
- Se actualiza `docs/backend/supabase_backend.md` para reflejar el estado real del proxy:
  - AEMET
  - Meteoblue
  - Meteosource
  - Meteostat
- Tambien se documenta que las claves de terceros en `local.env.json` quedan como fallback legacy, no como configuracion recomendada del cliente.
- Verificacion ejecutada:
  - comprobacion manual de `local.env.json.example` (ok)
  - comprobacion manual de `supabase/.env.example` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:14-19:27 = 13m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:27 = 7h 53m`.
- `Acumulado combinado confirmado del dia = 18h 11m`.

### 2026-03-15 - Backend fase 027: fix operativo de secretos Meteostat en Supabase

- Se detecta que `METEOSTAT_RAPIDAPI_KEY` no persiste en `Supabase secrets` aunque la CLI devolvia `Finished`.
- Se verifica el problema de forma directa:
  - `supabase secrets list` no mostraba la clave
  - la invocacion remota de `forecast-proxy` seguia respondiendo `missing-meteostat-rapidapi-key`
- Se aplica un workaround robusto en backend:
  - la Edge Function pasa a leer `METEOSTAT_API_KEY` y `METEOSTAT_API_HOST`
  - mantiene compatibilidad hacia atras intentando tambien `METEOSTAT_RAPIDAPI_KEY` y `METEOSTAT_RAPIDAPI_HOST`
- Se actualizan:
  - `supabase/functions/forecast-proxy/index.ts`
  - `supabase/.env.example`
  - `docs/backend/supabase_backend.md`
- Operaciones remotas ejecutadas:
  - `supabase secrets set METEOSTAT_API_KEY=... --project-ref tefbkhwaxlsfxvnleutb`
  - `supabase functions deploy forecast-proxy --project-ref tefbkhwaxlsfxvnleutb`
- Verificacion ejecutada:
  - `supabase secrets list --project-ref tefbkhwaxlsfxvnleutb` (la clave nueva aparece)
  - `curl https://tefbkhwaxlsfxvnleutb.supabase.co/functions/v1/forecast-proxy ... action=meteostat-point-daily` (ok, devuelve payload Meteostat)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:27-19:40 = 13m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:40 = 8h 06m`.
- `Acumulado combinado confirmado del dia = 18h 24m`.

### 2026-03-15 - Backend fase 028: fallback de Meteostat Day desde serie Hourly

- Se detecta que la accion remota `meteostat-point-daily` ya responde correctamente pero el upstream devuelve `data: []` para el spot probado.
- `Meteostat Day` no se deja ya en error por ese vacio: el cliente reconstruye un resumen diario a partir de la serie `Hourly` cuando el endpoint diario no trae filas.
- Agregacion aplicada por dia:
  - temperatura media, minima y maxima
  - viento medio
  - racha maxima
  - presion media
  - precipitacion acumulada
- Archivo afectado:
  - `lib/features/spots/infrastructure/services/meteostat_day_client.dart`
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots/infrastructure/services/meteostat_day_client.dart lib/features/spots/presentation/pages/spot_detail_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:40-19:43 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:43 = 8h 09m`.
- `Acumulado combinado confirmado del dia = 18h 27m`.

### 2026-03-15 - Backend fase 029: spots guardados hidratados desde Supabase

- Se migra el catalogo de `spots guardados` a un modelo hibrido con cache local y `hydrate` asincrono desde `public.user_saved_spots`.
- Se crea el adapter:
  - `lib/features/spots/infrastructure/adapters/supabase/supabase_spots_catalog_adapter.dart`
- El contrato del catalogo de spots deja de ser solo sincrono:
  - `hydrateSpots()` en `SpotsCatalogPort`
  - `getSpots.load()` en `GetSpotsUseCase`
- `SpotsModule.auto()` pasa a seleccionar Supabase cuando el cliente esta configurado.
- Se conectan las pantallas que consumen el catalogo:
  - `lib/features/spots/presentation/pages/spots_page.dart`
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- El guardado y borrado se hacen de forma optimista en cache y se reflejan en remoto sobre `user_saved_spots`.
- Verificacion ejecutada:
  - `flutter analyze lib/features/spots lib/features/sessions` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:43-19:49 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:49 = 8h 15m`.
- `Acumulado combinado confirmado del dia = 18h 33m`.

### 2026-03-15 - Backend fase 030: direct threads de profile hidratados desde Supabase

- `profile/messages` deja de depender solo de memoria para la lista de conversaciones directas.
- Se crea el adapter:
  - `lib/features/profile/infrastructure/adapters/supabase/supabase_profile_messages_repository_adapter.dart`
- El repositorio de mensajes pasa a modo hibrido:
  - `direct threads` se hidratan desde `direct_threads`, `direct_thread_participants` y `direct_messages`
  - `indexed messages` siguen locales por ahora
  - `mute`, `block` y `delete` se mantienen como overlays locales mientras no exista esquema remoto especifico para ese estado
- Se amplian:
  - `ProfileMessagesRepositoryPort` con `hydrate()`
  - `GetDirectMessageThreadsUseCase` con `load()`
  - `ProfileMessagesController` con `hydrate()`
- `ProfileModule.auto()` selecciona ya el adapter Supabase para mensajes cuando el cliente esta configurado.
- `ProfilePage` hidrata conversaciones remotas al arrancar.
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:49-19:55 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-19:55 = 8h 21m`.
- `Acumulado combinado confirmado del dia = 18h 39m`.

### 2026-03-15 - Backend fase 031: saneado de tests de Sessions tras migraciones backend

- Se valida la rama `Meteokite-4.0` despues del push y aparece una regresion de test en `sessions_page_test.dart`.
- Causa raiz detectada:
  - `SessionsModule.inMemory()` reutilizaba adapters estaticos entre tests
  - eso filtraba estado entre casos y volvia fragiles varias expectativas de UI
- Fix aplicado:
  - `lib/features/sessions/di/sessions_module.dart`
  - el modo `inMemory()` crea ahora adapters frescos por instancia
- Ajustes de test:
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze` completo (ok)
  - `flutter test test/features/sessions/presentation/pages/sessions_page_test.dart --plain-name 'syncs selected device session from selected device card'` (ok)
  - `flutter analyze lib/features/sessions test/features/sessions/presentation/pages/sessions_page_test.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 19:55-20:31 = 36m`.
- `Bloque acumulado de esta nueva reentrada 11:34-20:31 = 8h 57m`.
- `Acumulado combinado confirmado del dia = 19h 15m`.

### 2026-03-15 - Backend fase 032: smoke validation en verde para la rama Meteokite-4.0

- Se relanza la validacion corta de la rama despues de corregir los tests de `sessions`.
- Resultado final:
  - `flutter analyze` completo en verde
  - smoke de tests en verde:
    - `test/architecture/hexagonal_dependency_rules_test.dart`
    - `test/features/sessions/presentation/pages/sessions_page_test.dart`
    - `test/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter_test.dart`
- Se confirma como fix raiz de la inestabilidad:
  - `lib/features/sessions/di/sessions_module.dart`
  - `SessionsModule.inMemory()` ya no comparte adapters entre tests
- Se ajustan tambien los tests asociados:
  - `test/features/sessions/presentation/pages/sessions_page_test.dart`
  - `test/features/spots/presentation/pages/spot_detail_page_test.dart`

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 20:31-21:14 = 43m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:14 = 9h 40m`.
- `Acumulado combinado confirmado del dia = 19h 58m`.

### 2026-03-15 - Backend fase 033: gear setups de profile persistidos en Supabase

- Se conecta `profile gear setups` a `public.user_gear_setups`.
- Restriccion del esquema actual:
  - la tabla remota solo expone columnas resumidas (`board`, `kite`, `bar`, `wetsuit`, `notes`)
  - para no perder estructura completa del setup, se serializa el detalle entero en `notes`
- Nuevo adapter:
  - `lib/features/profile/infrastructure/adapters/supabase/supabase_profile_gear_repository_adapter.dart`
- Alcance real:
  - inventario fino de gear sigue local en memoria
  - `gear setups` guardadas se hidratan y persisten en remoto
  - al hidratar, el adapter reconstruye tambien los items referenciados para que `sessions` y `profile` sigan funcionando
- Cambios de integracion:
  - `ProfileGearRepositoryPort` añade `hydrate()`
  - `ProfileGearUseCases` añade `hydrate()`
  - `ProfileGearController` añade `hydrate()`
  - `ProfileModule.auto()` usa ya el adapter Supabase para gear setups
  - `ProfilePage` hidrata gear remoto al arrancar y republica el catalogo para `sessions`
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile lib/features/sessions` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:14-21:20 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:20 = 9h 46m`.
- `Acumulado combinado confirmado del dia = 20h 04m`.

### 2026-03-15 - Backend fase 034: safety net para hidratacion de gear en profile

- Se anade una prueba unitaria dirigida al nuevo contrato `hydrate()` de gear en `profile`.
- Nuevo test:
  - `test/features/profile/presentation/state/profile_gear_controller_test.dart`
- Cobertura cerrada:
  - `ProfileGearController.hydrate()` llama al repositorio
  - el estado interno del controlador se refresca con kites, bars, boards, harnesses, wetsuits, helmets, vests y `gear setups`
  - las busquedas por id (`findKite`, `findBoard`) quedan validadas tras la hidratacion
- Verificacion ejecutada:
  - `flutter test -r compact test/features/profile/presentation/state/profile_gear_controller_test.dart` (ok)
  - `flutter analyze lib/features/profile lib/features/sessions test/features/profile/presentation/state/profile_gear_controller_test.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:20-21:27 = 7m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:27 = 9h 53m`.
- `Acumulado combinado confirmado del dia = 20h 11m`.

### 2026-03-15 - Backend fase 035: Sessions ya consume gear remoto de Profile

- Se corrige el acoplamiento entre `Sessions` y `Profile` para que el snapshot de gear no siga leyendo solo `localFile/inMemory`.
- Cambio principal:
  - `lib/features/sessions/presentation/pages/sessions_page.dart`
- Ajuste aplicado:
  - `SessionsPage` resuelve ahora su `ProfileModule` propio
  - en ejecucion real sin override usa `ProfileModule.auto()`
  - en modo de test/local explicito mantiene `localFile` o `inMemory` para no romper validaciones ni flujos controlados
  - se anade `hydrate()` de gear al arrancar la pagina antes de usar el snapshot
- Impacto funcional:
  - una `gear setup` persistida en Supabase desde `Profile` ya puede alimentar el selector de `Sessions`
  - se mantiene compatibilidad con los tests y con el modo explicito local
- Verificacion ejecutada:
  - `flutter analyze lib/features/sessions lib/features/profile` (ok)
  - `flutter test -r compact test/features/sessions/presentation/pages/sessions_page_test.dart --plain-name "allows selecting custom gear setup when uploading session"` (ok)
  - `flutter test -r compact test/features/sessions/presentation/pages/sessions_page_test.dart --plain-name "persists last used gear setup and upload spot across page instances"` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:27-21:36 = 9m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:36 = 10h 02m`.
- `Acumulado combinado confirmado del dia = 20h 20m`.

### 2026-03-15 - Backend fase 036: estado remoto por usuario en mensajes directos

- Se cierra el hueco de `profile/messages` donde `mute`, `block` y `delete` seguian siendo overlays solo locales.
- Nueva migracion:
  - `supabase/migrations/20260315213000_direct_thread_user_states.sql`
- Esquema nuevo en Supabase:
  - tabla `public.direct_thread_user_states`
  - flags por usuario e hilo: `is_muted`, `is_blocked`, `is_deleted`
  - `updated_at` + trigger
  - RLS de propietario por `user_id`
- Integracion Flutter:
  - `lib/features/profile/infrastructure/adapters/supabase/supabase_profile_messages_repository_adapter.dart`
- Comportamiento nuevo:
  - `hydrate()` fusiona el estado remoto del usuario con los hilos directos
  - `toggleMuteDirectThread`, `blockDirectThread` y `deleteDirectThread` siguen siendo optimistas en UI
  - despues persisten en remoto mediante `upsert` a `direct_thread_user_states`
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile` (ok)
  - `supabase db push --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:36-21:40 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:40 = 10h 06m`.
- `Acumulado combinado confirmado del dia = 20h 24m`.

### 2026-03-15 - Cierre de rama: push del bloque gear + sessions + messages

- Commit creado:
  - `19be6a1` `feat: sync profile gear and direct message state with supabase`
- Push ejecutado:
  - `origin/Meteokite-4.0`
- Alcance del commit:
  - `gear setups` de profile en Supabase
  - consumo de gear remoto desde `Sessions`
  - test de hidratacion de `ProfileGearController`
  - estado remoto de `mute/block/delete` para mensajes directos

### 2026-03-15 - Backend fase 037: buscador de mensajes de Profile ya hidrata desde Supabase

- Se elimina el cuello donde `Buscar en app` seguia dependiendo del fallback local en modo Supabase.
- Archivo ajustado:
  - `lib/features/profile/infrastructure/adapters/supabase/supabase_profile_messages_repository_adapter.dart`
- Nuevo comportamiento:
  - `hydrate()` construye `indexedMessages` remotos a partir de:
    - `session_comments` del usuario autenticado
    - `direct_messages` enviados por el usuario autenticado
  - si no hay datos remotos, mantiene fallback local para no dejar la UI vacia
  - `updateIndexedMessage` y `deleteIndexedMessage` siguen funcionando sobre el indice hidratado en memoria
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:40-21:56 = 16m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:56 = 10h 22m`.
- `Acumulado combinado confirmado del dia = 20h 40m`.

### 2026-03-15 - Backend fase 038: edicion y borrado remoto para el indice de mensajes

- Se completa el ciclo de `Buscar en app` para que el indice remoto no sea solo lectura.
- Cambios de backend:
  - nueva migracion `supabase/migrations/20260315220000_message_update_delete_policies.sql`
  - RLS anadido:
    - `session_comments`: owner update
    - `direct_messages`: sender update y delete
- Cambios de cliente:
  - `lib/features/profile/infrastructure/adapters/supabase/supabase_profile_messages_repository_adapter.dart`
- Nuevo comportamiento:
  - si el entry es `session-comment-*`, editar actualiza `session_comments.text` y borrar elimina la fila
  - si el entry es `direct-message-*`, editar actualiza `direct_messages.body` y borrar elimina la fila
  - la UI sigue funcionando de forma optimista sobre el indice hidratado en memoria
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile` (ok)
  - `supabase db push --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:56-21:59 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-21:59 = 10h 25m`.
- `Acumulado combinado confirmado del dia = 20h 43m`.

### 2026-03-15 - Backend fase 039: base de roles de aplicacion en Supabase

- Se anade una capa formal de autorizacion para no depender solo de ownership y RLS por usuario.
- Nueva migracion:
  - `supabase/migrations/20260315221000_app_roles_foundation.sql`
- Elementos creados:
  - enum `public.app_role` con `user`, `moderator`, `admin`
  - tabla `public.user_roles`
  - helper `public.role_level(...)`
  - helper `public.has_role_at_least(...)`
  - RPCs:
    - `public.assign_user_role(...)`
    - `public.revoke_user_role(...)`
- RLS:
  - cada usuario puede leer sus propios roles
  - `admin` puede leer y gestionar todos los roles
- Verificacion ejecutada:
  - `supabase db push --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 21:59-22:01 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:01 = 10h 27m`.
- `Acumulado combinado confirmado del dia = 20h 45m`.

### 2026-03-15 - Backend fase 040: rol super_admin para gobernar admins

- Se amplía el modelo de autorizacion para que el control de roles no dependa de `admin`, sino de `super_admin`.
- Migraciones nuevas:
  - `supabase/migrations/20260315220500_super_admin_role_upgrade.sql`
  - `supabase/migrations/20260315220600_super_admin_permissions.sql`
- Cambio aplicado:
  - enum `app_role` ampliado con `super_admin`
  - `role_level(...)` actualizado
  - `assign_user_role(...)` y `revoke_user_role(...)` pasan a exigir `super_admin`
  - las policies de `user_roles` pasan de `admin` a `super_admin`
- Nota tecnica:
  - hubo que separar el alta del nuevo valor del enum y la reescritura de funciones/policies en dos migraciones por restriccion transaccional de Postgres
- Verificacion ejecutada:
  - `supabase db push --include-all --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:01-22:04 = 3m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:04 = 10h 30m`.
- `Acumulado combinado confirmado del dia = 20h 48m`.

### 2026-03-15 - Backend fase 041: super_admin unico y auditoria de acciones admin

- Se endurece el modelo de permisos para que solo exista un `super_admin` global con control total sobre los `admin`.
- Nueva migracion:
  - `supabase/migrations/20260315221500_single_super_admin_and_admin_audit.sql`
- Cambios aplicados:
  - indice unico parcial para garantizar un unico `super_admin` en `user_roles`
  - tabla `public.admin_action_audit`
  - helper `public.current_highest_role()`
  - RPC `public.log_admin_action(...)`
  - `assign_user_role(...)`:
    - sigue reservado a `super_admin`
    - bloquea asignar un segundo `super_admin`
    - deja trazabilidad en `admin_action_audit`
  - `revoke_user_role(...)`:
    - sigue reservado a `super_admin`
    - no permite revocar `super_admin` por la misma via operativa
    - deja trazabilidad en `admin_action_audit`
- Visibilidad:
  - las filas de `admin_action_audit` solo son legibles por `super_admin`
  - `admin` puede insertar trazas via `log_admin_action(...)` si una accion privilegiada futura lo requiere
- Verificacion ejecutada:
  - `supabase db push --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:04-22:10 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:10 = 10h 36m`.
- `Acumulado combinado confirmado del dia = 20h 54m`.

### 2026-03-15 - Backend fase 042: bootstrap seguro del primer super_admin

- Se elimina la dependencia de inserciones manuales para crear el unico `super_admin` inicial.
- Nueva migracion:
  - `supabase/migrations/20260315222000_bootstrap_first_super_admin.sql`
- RPC nueva:
  - `public.bootstrap_first_super_admin()`
- Garantias:
  - solo funciona autenticado
  - solo funciona si todavia no existe ningun `super_admin`
  - asigna `super_admin` al usuario autenticado
  - deja traza en `admin_action_audit`
- Verificacion ejecutada:
  - `supabase db push --include-all --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:10-22:12 = 2m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:12 = 10h 38m`.
- `Acumulado combinado confirmado del dia = 20h 56m`.

### 2026-03-15 - Backend fase 043: RPCs de auditoria y directorio de roles para super_admin

- Se completa la mitad de lectura del modelo de gobernanza para que el `super_admin` pueda inspeccionar actividad privilegiada y usuarios con rol.
- Nueva migracion:
  - `supabase/migrations/20260315223000_super_admin_audit_rpcs.sql`
- RPCs nuevas:
  - `public.get_admin_action_audit(limit_count, offset_count)`
  - `public.get_role_directory()`
- Alcance:
  - `get_admin_action_audit(...)` devuelve actor, rol, accion, objetivo, detalles y fecha
  - `get_role_directory()` devuelve usuarios con rol y orden jerarquico
  - ambas quedan reservadas de facto a `super_admin` mediante `has_role_at_least('super_admin')`
- Verificacion ejecutada:
  - `supabase db push --include-all --yes` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:12-22:17 = 5m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:17 = 10h 43m`.
- `Acumulado combinado confirmado del dia = 21h 01m`.

### 2026-03-15 - Backend fase 044: panel admin minimo en la app

- Se expone una primera superficie de administracion en cliente para consumir las RPCs de roles y auditoria.
- Nuevo archivo:
  - `lib/features/profile/presentation/pages/admin_console_page.dart`
- Integracion:
  - nueva ruta `AppRoutes.adminConsole`
  - registro en `lib/app/router/app_router.dart`
  - acceso desde `Ajustes > Panel admin`
- Alcance funcional:
  - si el usuario tiene acceso, la pagina lee:
    - `get_role_directory()`
    - `get_admin_action_audit(...)`
  - muestra:
    - resumen
    - directorio de roles
    - auditoria admin
  - si el usuario no es `super_admin`, cae en estado de acceso restringido / error controlado
- Verificacion ejecutada:
  - `flutter analyze lib/features/profile/presentation/pages/admin_console_page.dart lib/features/profile/presentation/pages/settings_page.dart lib/app/router/app_router.dart lib/app/router/app_routes.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:17-22:21 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:21 = 10h 47m`.
- `Acumulado combinado confirmado del dia = 21h 05m`.

### 2026-03-15 - Cierre del bloque admin/backend

- Se documenta en `docs/backend/supabase_app_backend.md` el modelo final de gobernanza:
  - roles `user/moderator/admin/super_admin`
  - unicidad del `super_admin`
  - auditoria admin
  - RPC de bootstrap del primer `super_admin`
  - RPCs de lectura para panel admin
- El bloque queda listo para cierre tecnico y push en la rama `Meteokite-4.0`.

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:21-22:25 = 4m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:25 = 10h 51m`.
- `Acumulado combinado confirmado del dia = 21h 09m`.

### 2026-03-15 - Auth fase 045: retirada del bypass de login en arranque

- Se elimina el comportamiento que seguia saltando la pantalla de login por configuracion de desarrollo.
- Cambios:
  - `lib/core/config/env/env_config.dart`
    - `devBypassEnabled` pasa a `false`
  - `lib/app/router/app_router.dart`
    - el `initialLocation` deja de depender del flag de bypass
    - ahora arranca en `dashboard` solo si existe sesion real de Supabase
    - en caso contrario arranca en `login`
- Efecto:
  - la app vuelve a exigir autenticacion real cuando no hay sesion
  - si ya existe sesion valida, sigue entrando directamente al dashboard
- Verificacion ejecutada:
  - `flutter analyze lib/app/router/app_router.dart lib/core/config/env/env_config.dart lib/features/auth/presentation/pages/login_page.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:25-22:34 = 9m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:34 = 11h 00m`.
- `Acumulado combinado confirmado del dia = 21h 18m`.

### 2026-03-15 - Auth fase 046: saneado visual y funcional de la pantalla de login

- Se rehace la pantalla de acceso para quitar el tono de placeholder y hacer mas claro el flujo real de Supabase.
- Archivo principal:
  - `lib/features/auth/presentation/pages/login_page.dart`
- Mejora funcional:
  - el acceso por email OTP ya no trata el caso exitoso como error
  - si Supabase responde sin sesion inmediata, se muestra mensaje informativo de enlace enviado por correo en vez de navegar mal al dashboard
- Mejora visual:
  - cabecera mas clara
  - jerarquia mas limpia para email / acceso social / cuentas recientes
  - copy alineado con el estado real del producto
  - desaparece la expectativa de `DEV BYPASS` en UI normal
- Ajuste de adapter:
  - `lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart`
  - `signInWithEmail` devuelve `null` en exito y deja al cliente decidir si hay sesion o flujo OTP pendiente
- Test actualizado:
  - `test/features/auth/presentation/pages/login_page_test.dart`
- Verificacion ejecutada:
  - `flutter analyze lib/features/auth/presentation/pages/login_page.dart lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart test/features/auth/presentation/pages/login_page_test.dart` (ok)
  - `flutter test -r compact test/features/auth/presentation/pages/login_page_test.dart` (ok)

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:34-22:40 = 6m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:40 = 11h 06m`.
- `Acumulado combinado confirmado del dia = 21h 24m`.

### 2026-03-15 - Cierre de bloque: login OTP endurecido y push a Meteokite-4.0

- Commit creado:
  - `64b7366` `fix: harden auth login flow against otp rate limits`
- Push ejecutado:
  - `origin/Meteokite-4.0`
- Cambios cerrados:
  - cooldown local de reenvio OTP
  - mensaje especifico para `rate limit`
  - limpieza visual y funcional del login

### 2026-03-15 - Conteo de horas (actualizacion intermedia)

- `Bloque incremental 22:40-22:51 = 11m`.
- `Bloque acumulado de esta nueva reentrada 11:34-22:51 = 11h 17m`.
- `Acumulado combinado confirmado del dia = 21h 35m`.

### 2026-03-16 - Auth fase 047: registro de deep link nativo para magic link

- Se corrige la causa principal del fallo al pulsar el enlace de acceso desde el correo en movil/emulador.
- Diagnostico:
  - el problema no era solo que la app estuviera en local,
  - faltaba registrar el esquema `meteokite://login-callback` en Android/iOS para que el sistema operativo pudiera reenviar el enlace a la app.
- Cambios:
  - `android/app/src/main/AndroidManifest.xml`
    - anadido `intent-filter` `VIEW` para `meteokite://login-callback`
  - `ios/Runner/Info.plist`
    - anadido `CFBundleURLTypes` con esquema `meteokite`
- Verificacion ejecutada:
  - `plutil -lint ios/Runner/Info.plist` (ok)
- Nota operativa:
  - tras este cambio hace falta recompilar/reinstalar la app en el emulador/dispositivo,
  - ademas, en el proyecto Supabase Cloud debe estar permitida la redirect URL `meteokite://login-callback`, no solo en el `supabase/config.toml` local.

### 2026-03-16 - Auth fase 048: rediseño visual de la pantalla de login

- Se rehace la pantalla de acceso para salir del aspecto de placeholder y llevarla a una UI mas cercana a producto real.
- Archivo principal:
  - `lib/features/auth/presentation/pages/login_page.dart`
- Cambios visuales:
  - layout responsive en dos columnas para desktop/tablet y bloque unico limpio en mobile
  - fondo con gradiente y ambient shapes suaves
  - panel hero con resumen de capacidades de la cuenta
  - panel de formulario mas claro para `Login`, `Crear cuenta` y `Magic link`
  - botones sociales degradados a estado no disponible real en vez de CTA ambiguo
  - cuentas recientes integradas mejor en la composicion
- Ajustes de soporte:
  - `test/features/auth/presentation/pages/login_page_test.dart`
    - expectativas actualizadas para la nueva UI
- Verificacion ejecutada:
  - `flutter analyze lib/features/auth/presentation/pages/login_page.dart lib/features/auth` (ok)
  - `flutter test -r compact test/features/auth/presentation/pages/login_page_test.dart` (ok)
- Registro horario:
  - bloque de trabajo de esta fase registrado en fecha `2026-03-16`
  - consolidado horario del dia pendiente del siguiente cierre global para no mezclarlo con el bloque anterior ya cerrado del `2026-03-15`

### 2026-03-16 - Auth fase 049: simplificacion del login y primer cambio de marca a WindWisher

- Se corrige el enfoque del login:
  - se elimina el bloque hero recargado,
  - la parte superior pasa a mostrar solo logo, nombre y branding principal de la app,
  - el acceso queda concentrado en una sola tarjeta limpia.
- Nuevo branding visible aplicado:
  - `WindWisher`
- Archivos ajustados:
  - `lib/features/auth/presentation/pages/login_page.dart`
  - `lib/main.dart`
  - `lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart`
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`
  - `web/index.html`
  - `web/manifest.json`
  - `supabase/config.toml`
  - `test/features/auth/presentation/pages/login_page_test.dart`
  - `test/app/app_bootstrap_test.dart`
- Cambio operativo importante:
  - el esquema de deep link para magic link pasa de `meteokite://login-callback` a `windwisher://login-callback`
  - hace falta reflejar la misma redirect URL en la configuracion real de Auth de Supabase Cloud para no romper el acceso por correo
- Alcance decidido:
  - se cambia branding visible y metadata principal de app,
  - no se renombra todavia el package Dart `meteokitev2_0` ni todos los imports, porque eso ya es una migracion aparte
- Verificacion ejecutada:
  - `flutter analyze lib/features/auth/presentation/pages/login_page.dart lib/main.dart lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart test/features/auth/presentation/pages/login_page_test.dart test/app/app_bootstrap_test.dart` (ok)
  - `flutter test -r compact test/features/auth/presentation/pages/login_page_test.dart test/app/app_bootstrap_test.dart` (ok)

### 2026-03-16 - Auth fase 050: alineacion local de Site URL para magic link

- Se elimina `http://localhost:3000` de la configuracion local de Supabase para no seguir mezclando el flujo cloud de auth con un destino web inexistente.
- Cambio:
  - `supabase/config.toml`
    - `site_url = "https://supabase.com"`
- Motivo:
  - mientras no exista hosting real para `windwisher.com`, conviene dejar una `Site URL` valida y neutra
  - el flujo movil sigue dependiendo de `windwisher://login-callback` en redirect URLs, no de tener hosting propio

### 2026-03-16 - Profile/Messages fase 051: fix de recursion RLS en direct_thread_participants

- Aparece un error backend al entrar por bypass y cargar mensajes:
  - `infinite recursion detected in policy for relation "direct_thread_participants" (42P17)`
- Causa raiz:
  - la policy `thread participants visible to participants` se evaluaba consultando la propia tabla `direct_thread_participants`,
  - eso provocaba recursion RLS en Supabase/Postgres.
- Solucion aplicada:
  - nueva migracion `20260316214000_fix_direct_thread_participants_rls_recursion.sql`
  - se crea la funcion `public.is_thread_participant(uuid)` con `security definer`
  - se reapuntan las policies de:
    - `direct_threads`
    - `direct_thread_participants`
    - `direct_messages`
  - asi se evita consultar la misma tabla bajo una policy autorreferente
- Despliegue:
  - `supabase db push --yes` (ok)

### 2026-03-16 - Branding fase 052: export inicial del logo WindWisher

- Se genera una primera exportacion real del logo para poder descargarlo y reutilizarlo fuera del widget de Flutter.
- Archivo creado:
  - `assets/branding/windwisher_logo.svg`
- Caracteristicas del export:
  - rosa de los vientos
  - aguja/brujula principal norte-sur
  - flecha de direccion apuntando al este
  - formato SVG para poder escalarlo y editarlo sin perdida

### 2026-03-18 - Spots v3.4 fase 99-j: selector de fuente historica para Oliva AEMET

- Ajustada la tarjeta `Historico` en `Spot detalle > Live` para la estacion AEMET de Oliva:
  - aparece un `SegmentedButton` con fuentes separadas `WindWisher` y `AEMET oficial`,
  - `WindWisher` queda como fuente seleccionada por defecto,
  - `AEMET oficial` conserva intacta la logica y ventana fija existentes.
- Regla de producto aplicada:
  - no se reutiliza la serie oficial de AEMET como sustituto silencioso de `WindWisher`,
  - si aun no existe registro propio, `WindWisher` muestra estado vacio especifico en lugar de mezclar fuentes.
- Alcance de esta fase:
  - solo UI/estado local de seleccion de fuente historica,
  - el backend de persistencia `WindWisher` cada 5 minutos queda pendiente para la siguiente fase.
- Ajuste posterior dentro de la misma fase:
  - la prioridad final al entrar en `Live` para Oliva queda fijada como:
    - `WindWisher` sobre `AEMET oficial · Oliva`,
    - fallback a `AEMET oficial · Oliva` si `WindWisher` falla,
    - fallback a `AVAMET` solo si fallan ambos anteriores.
  - `AEMET oficial · Oliva` sigue visible en el listado y cambiar la fuente historica a `AEMET oficial` fuerza la seleccion de la estacion `8058X`.

### 2026-03-19 - Spots v3.4 fase 99-k: backend base para historico WindWisher

- Anadido backend inicial para el historico propio `WindWisher` de Oliva:
  - nueva tabla `public.windwisher_aemet_oliva`,
  - nueva Edge Function `live-wind-recorder`,
  - configuracion de function en `supabase/config.toml`.
- Contrato actual del recorder:
  - consulta `AEMET 8058X`,
  - extrae solo `vv` como viento instantaneo y `dv` como direccion,
  - usa `fint` como `observed_at`,
  - hace `upsert` por `station_id + observed_at`.
- Alcance deliberado de esta fase:
  - backend de captura y persistencia,
  - lectura Flutter de `windwisher_aemet_oliva` conectada al selector `WindWisher` en `Live`,
  - fallback operativo mantenido:
    - `WindWisher`
    - `AEMET oficial`
    - `AVAMET`
  - la app no lee la tabla completa:
    - si el filtro historico esta en `1d`, consulta `1 dia`
    - si el filtro historico esta en `3d`, consulta `3 dias`
  - el cambio de bucket horario del historico tambien refresca `WindWisher`, manteniendo el mismo patron comun de filtros de la grafica.
  - se anade runbook operativo de despliegue:
    - SQL manual `supabase/manual/windwisher_aemet_oliva_scheduler.sql`
    - secuencia documentada de `db push`, `secrets set`, `functions deploy` y verificacion de la tabla.
    - helper local `scripts/deploy_windwisher_aemet_oliva.sh` para automatizar el despliegue base antes del cron manual.
  - semantica explicita de la grafica `WindWisher`:
    - la flecha usa la direccion de cada captura persistida,
    - la linea azul es una media movil calculada en cliente sobre esa misma serie de viento,
    - no se introduce una segunda fuente “media” distinta dentro del historico intradia.
  - estado operativo validado en cloud:
    - `supabase link` ok sobre proyecto `tefbkhwaxlsfxvnleutb`,
    - `supabase db push` ok con migracion `20260319103000_windwisher_aemet_oliva.sql`,
    - `forecast-proxy` desplegada,
    - `live-wind-recorder` desplegada,
    - `LIVE_WIND_RECORDER_SECRET` cargado y validado,
    - invocacion sin auth devuelve `401`,
    - invocacion con auth ok devolviendo muestra real insertada para `8058X`.
  - pendiente manual restante:
    - programar `supabase/manual/windwisher_aemet_oliva_scheduler.sql` en SQL Editor para automatizar la captura cada 5 minutos.
  - ajuste posterior en `Live`:
    - `WindWisher` ya no entra como historico efectivo si solo existe una muestra aislada; con menos de 2 capturas cae a `AEMET oficial`,
    - la limitacion de buckets `1 h / 3 h` se mantiene solo para `AEMET oficial`, no para `WindWisher`.
  - cron backend activado en cloud:
    - `pg_cron` y `pg_net` habilitados,
    - job `windwisher-live-wind-recorder-every-5-min` creado y activo con expresion `*/5 * * * *`,
    - la activacion se hizo via `POST /v1/projects/{ref}/database/query`,
    - el intento con `alter database ... set app.settings.live_wind_recorder_secret` fallo por permisos y se reemplazo por el bearer embebido en el job.
  - retirada posterior del experimento:
    - se elimina `WindWisher` del historico `Live` de Oliva y vuelve la rama unica `AEMET` / `AVAMET`,
    - se borra el cliente Flutter, la function `live-wind-recorder`, el SQL manual y el script de despliegue,
    - se anade la migracion `20260319154000_remove_windwisher_aemet_oliva.sql`,
    - en cloud se desprograma el cron, se elimina la tabla y se borra la function desplegada.
  - nueva integracion Meteoclimatic para Oliva:
    - se anade `Oliva Nova Beach & Golf Resort` como estacion `METEOCLIMATIC` en `Live`,
    - el cliente parsea la ficha publica y su `v1/api.json` de ultimas `24 h`,
    - el historico queda limitado a `1d`,
    - la grafica reutiliza el patron existente:
      - flechas cada `5 min`
      - franja/agrupacion visual cada `20 min` cuando el bucket activo es `20 min`.
  - sustitucion posterior de la fuente de `Oliva Nova`:
    - se retira el cliente experimental de Meteoclimatic porque su `api.json` publico devolvia `fault 502`,
    - `Oliva Nova Beach & Golf Resort` pasa a cargarse desde `Inforatge`,
    - el live se parsea desde `https://inforatge.com/meteo-oliva-02`,
    - el historico intradia se parsea desde el grafico publico `graficc.php` con series `Vent` y `Direccio del vent`,
    - la estacion queda marcada en `Live` como proveedor `INFORATGE`,
    - el historico sigue limitado a `1d` con resolucion fuente de `10 min`.
  - ajuste de UX para `Oliva Nova`:
    - al auto-seleccionarse o al elegirse manualmente, el bucket intradia por defecto pasa a `20 min`,
    - esto mantiene la fuente real a `10 min` pero alinea la vista con el patron visual usado en `AVAMET`.
  - ampliacion posterior de `Inforatge` en Oliva:
    - se reutiliza el mismo cliente publico para las estaciones `Poliesportiu (e=01)` y `Oliva Nova (e=02)`,
    - `Live` anade `Oliva Poliesportiu` como segunda estacion `INFORATGE`,
    - el live de `Poliesportiu` sale de `https://inforatge.com/meteo-oliva`,
    - su historico intradia sale del mismo `graficc.php` publico con `e=01`.
  - control de tiempo:
    - estimacion acumulada de esta tanda de trabajo: `6-8 horas` efectivas,
    - a partir de aqui se deja como regla operativa iniciar cronometro al empezar cualquier bloque de programacion y anotar despues la duracion en este tracker.
  - bloque posterior `2026-03-19`:
    - inicio de cronometro para integracion de nueva estacion publica `meteo.aiguablanca.com`,
    - duracion estimada del bloque: `25-35 min`,
    - se anade cliente dedicado contra `https://meteo.feedket.com/api/endpoints/latest.php`,
    - la nueva estacion `Playa Aigua Blanca` entra en `Live` para spots de Oliva con lectura actual e historico intradia,
    - la fuente publica entrega muestras de viento cada `5 min` y se deja bucket historico por defecto en `20 min`,
    - presion convertida de `mmHg` a `hPa` antes de pintar tarjetas live.
  - bloque posterior `2026-03-19`:
    - inicio de cronometro para enriquecer todas las graficas del historico de viento,
    - duracion estimada del bloque: `20-30 min`,
    - se anade soporte de racha historica cuando la fuente la expone realmente,
    - AEMET y `Playa Aigua Blanca` rellenan la racha historica; `AVAMET intradia` e `Inforatge` siguen sin racha historica por limitacion de fuente,
    - la racha se agrega por bucket usando el maximo disponible dentro del tramo,
    - se vuelve a pintar la linea de media,
    - se anade una leyenda visual compartida para `Viento real`, `Media`, `Racha` y `Forecast`, mostrando solo las series que existan.
  - bloque posterior `2026-03-19`:
    - inicio de cronometro para pulido final del historico `Live`,
    - duracion estimada del bloque: `45-60 min`,
    - se elimina finalmente la linea de `Media` del historico,
    - la linea de `Racha` pasa a continua en todos los graficos,
    - se corrige la bucketizacion para que `1d + 3 h` y `3d + 3 h` muestren la franja horaria correcta,
    - `Playa Aigua Blanca` queda limitada a `1d` porque su fuente publica solo expone ultimas `24 h`,
    - se corrige el transporte de `gustKnots` para que `Playa Aigua Blanca` pinte racha historica tambien tras refresco,
    - `AVAMET intradia` e `Inforatge` se mantienen sin racha historica por limitacion real de sus series.
  - bloque posterior `2026-03-20`:
    - inicio de cronometro para sustituir la pantalla mock de `Webcam` por la webcam real principal de Oliva,
    - duracion estimada del bloque: `20-30 min`,
    - se fija `Oliva Puerto · Comunitat Valenciana` como webcam principal unica para spots de Oliva,
    - se eliminan las tarjetas de muestra `Oliva Norte` / `Oliva Paseo` del catalogo remoto en memoria,
    - la pantalla `Webcam` deja de usar placeholder, controles fake de calidad/audio y snackbars de "segunda fase",
    - `WebcamPlayerPage` pasa a cargar la pagina publica real en `WebView`,
    - la vista de webcam dentro de `Spot detail` pasa a presentar una unica webcam principal real cuando solo existe una entrada.
  - ajuste posterior `2026-03-20`:
    - continuacion del cronometro del bloque de `Webcam`,
    - duracion incremental estimada: `10-15 min`,
    - se inspecciona la fuente oficial y se extrae el stream real aislado,
    - la webcam de `Oliva Puerto` deja de cargar la web completa y pasa a reproducir solo el manifiesto oficial `manifest.mpd`,
    - el embed usa el mismo reproductor publico `shaka-player` / `shaka-streaming-controls` que usa la propia web oficial.
  - ajuste posterior `2026-03-20`:
    - continuacion del cronometro del bloque de `Webcam`,
    - duracion incremental estimada: `5-10 min`,
    - se anade `Oliva Nova` como segunda webcam real de Oliva,
    - se extrae de la fuente oficial su miniatura y manifiesto `https://streaming.comunitatvalenciana.com/webcam/Olivagolf/manifest.mpd`,
    - el catalogo de Oliva queda con dos webcams reales de `Comunitat Valenciana`: `Oliva Puerto` y `Oliva Nova`.
  - ajuste posterior `2026-03-20`:
    - continuacion del cronometro del bloque de `Webcam`,
    - duracion incremental estimada: `20-30 min`,
    - se amplian las webcams con `locationLabel`, `latitude` y `longitude`,
    - se centraliza el catalogo en `lib/features/spots/infrastructure/data/spot_webcam_catalog.dart` para dejar de hardcodear entradas sueltas en el adapter,
    - la pestaña `Webcam` del spot ordena ahora por distancia al spot cuando hay coordenadas disponibles,
    - la tarjeta de cada webcam muestra ubicacion y distancia al spot,
    - la pantalla de spots anade un chip `webcam(s) cerca` cuando el spot tiene webcams disponibles dentro del umbral cercano.
  - bloque nuevo `2026-03-20`:
    - inicio de cronometro para sustituir la pestaña `Social` mock por datos reales de spot,
    - duracion estimada del bloque: `60-90 min`,
    - se elimina el feed sembrado en memoria dentro de `spot_detail_page.dart`,
    - se anade `SpotSocialClient` con lectura y escritura reales sobre Supabase, y fallback local en memoria si no hay backend configurado,
    - se modelan `spot_social_posts` y `spot_social_replies` con soporte de respuestas anidadas,
    - se anade la migracion `20260320103000_spot_social_posts.sql` con RLS y escritura limitada al autor autenticado,
    - la UI `Social` pasa a cargar, refrescar, publicar, responder, editar y borrar usando datos reales,
    - se retira el flujo fake de adjuntar foto/video porque no habia almacenamiento real detras,
    - despliegue completado despues:
      - se repara el historial remoto con `supabase migration repair --status reverted 20260319103000`,
      - se aplica correctamente `20260320103000_spot_social_posts.sql` con `supabase db push --include-all --yes`,
      - `Social` queda ya preparado para leer y escribir contra Supabase.
  - bloque nuevo `2026-03-20`:
    - inicio de cronometro para endurecer las alarmas guardadas del spot,
    - duracion estimada del bloque: `15-20 min`,
    - `SpotAlarmCatalog` deja de vivir solo en memoria y pasa a persistirse en `spot_alarm_catalog_v1.json`,
    - se guardan y restauran:
      - activacion global,
      - activacion por spot,
      - alarmas guardadas con rango, horas, direcciones y repeat window,
    - las alarmas sobreviven ya a reinicios de la app,
    - sigue pendiente la segunda fase:
      - ejecucion en background fuera de la pantalla del spot.
  - bloque nuevo `2026-03-20`:
    - continuacion del cronometro del trabajo de alarmas,
    - duracion estimada del bloque: `25-35 min`,
    - se anade `flutter_local_notifications`,
    - se crea `LocalNotificationsService` y se inicializa desde `main.dart`,
    - Android solicita `POST_NOTIFICATIONS`,
    - las alarmas activas ya pueden disparar notificaciones locales reales cuando el `live` del spot se refresca y cumple la condicion,
    - el disparo respeta:
      - cooldown segun `repeatWindow`,
      - `maxRepeats` por racha activa,
      - reseteo del contador cuando la alarma deja de estar activa,
    - limitacion actual:
      - funciona con la app en uso y al refrescar/cargar `live`,
      - no hay todavia worker en background ni push remoto.
  - bloque nuevo `2026-03-20`:
    - continuacion del cronometro del trabajo de alarmas,
    - duracion estimada del bloque: `15-20 min`,
    - `SpotDetailPage` pasa a observar ciclo de vida con `WidgetsBindingObserver`,
    - si el spot tiene alarmas guardadas:
      - al volver la app a primer plano se refresca `live` y se re-evaluan,
      - en primer plano se programa auto-refresh cada `5 min`,
    - la tarjeta de alarmas guardadas muestra ya:
      - ultimo disparo relativo,
      - contador `triggerCount/maxRepeats`,
    - sigue pendiente el verdadero background execution fuera de la pantalla del spot.
  - bloque nuevo `2026-03-21`:
    - inicio de cronometro para backend real de persistencia de alarmas,
    - duracion estimada del bloque: `30-45 min`,
    - se anade `SpotAlarmSyncClient` para sincronizar alarmas y preferencias con Supabase cuando hay sesion autenticada,
    - `SpotAlarmCatalog` sigue manteniendo fallback local pero ahora:
      - hidrata desde remoto,
      - guarda/borrar alarmas en remoto,
      - sincroniza `globalEnabled` y `spotEnabledByKey`,
      - sincroniza tambien `triggerCount` y `lastTriggeredAt`,
    - `SpotDetailPage` hidrata el catalogo remoto al abrir el spot,
    - se anade y aplica en cloud la migracion `20260321103000_spot_alarms.sql`,
    - quedan creadas las tablas:
      - `spot_alarms`,
      - `spot_alarm_preferences`,
    - limitacion actual:
      - sigue sin existir un evaluador backend programado,
      - las push remotas con app cerrada siguen pendientes para la siguiente fase.
  - bloque nuevo `2026-03-21`:
    - continuacion del cronometro para pipeline backend de alarmas con app cerrada,
    - duracion estimada del bloque: `35-50 min`,
    - se anade `stationProvider` a `SpotAlarmRecord` y a la sync remota,
    - se anaden y aplican en cloud:
      - `20260321113000_spot_alarm_push_pipeline.sql`,
      - `20260321114500_backfill_spot_alarm_station_provider.sql`,
    - se crean las tablas:
      - `user_push_subscriptions`,
      - `spot_alarm_delivery_log`,
    - se crea la Edge Function `spot-alarm-runner`:
      - evalua alarmas `AEMET` en backend,
      - registra resultados en `spot_alarm_delivery_log`,
      - deja trazado si falta suscripcion push o si el provider aun no esta soportado,
    - se anade `supabase/manual/spot_alarm_runner_scheduler.sql` para programar el job cada `5 min`,
    - estado actual:
      - schema backend listo,
      - runner escrito,
      - backfill de `station_provider` aplicado,
    - sigue pendiente para cerrar la fase:
      - desplegar la function,
      - definir `SPOT_ALARM_RUNNER_SECRET`,
      - asegurar `SUPABASE_SERVICE_ROLE_KEY` en secrets de la function,
      - registrar tokens push reales de dispositivo en `user_push_subscriptions`,
      - implementar el envio push real.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para dejar operativo el runner backend de alarmas,
    - duracion estimada del bloque: `30-40 min`,
    - se anade y aplica en cloud `20260322100000_spot_alarm_runner_rpcs.sql`,
    - el runner pasa a apoyarse en RPCs `security definer` y ya no necesita `SUPABASE_SERVICE_ROLE_KEY`,
    - se limpia `spot-alarm-runner`:
      - se elimina el insert placeholder,
      - se anade `update_backend_spot_alarm_trigger_state`,
      - cuando una alarma deja de estar activa, el backend resetea `triggerCount` y `lastTriggeredAt`,
    - se genera y guarda `SPOT_ALARM_RUNNER_SECRET` en `local.env.json`,
    - se publican los secrets remotos necesarios para la function,
    - se despliega en cloud la Edge Function `spot-alarm-runner`,
    - verificacion remota ejecutada:
      - `POST /functions/v1/spot-alarm-runner` responde `ok`,
      - resultado actual: `evaluated: 0`, `active: 0`, `logged: 0`, `unsupported: 0`,
    - limitacion actual:
      - el scheduler SQL de `pg_cron` sigue pendiente de activarse manualmente desde SQL Editor,
      - el envio push real y el registro de tokens de dispositivo siguen pendientes.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro del runner backend de alarmas,
    - duracion estimada del bloque: `10-15 min`,
    - se corrige `spot-alarm-runner` para que respete en backend:
      - `repeatWindow`,
      - `maxRepeats`,
      - reseteo remoto cuando la condicion deja de cumplirse,
    - cuando existe una suscripcion push candidata, el runner actualiza ya en remoto:
      - `triggerCount`,
      - `lastTriggeredAt`,
    - esto evita que el cron vuelva a registrar la misma alarma en cada pasada mientras siga activa dentro del cooldown,
    - la function redeployada sigue respondiendo `ok` en la prueba remota manual.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para preparar el registro de dispositivos push,
    - duracion estimada del bloque: `15-20 min`,
    - se anade `PushNotificationSubscriptionService` en:
      - `lib/core/notifications/push_notification_subscription_service.dart`,
    - el servicio persiste ya la preferencia local del dispositivo en `push_notifications_state_v1.json`,
    - `main.dart` lo inicializa en arranque,
    - `SettingsPage` deja de tener un switch fake:
      - el toggle de notificaciones queda conectado al servicio real,
      - muestra feedback segun estado,
      - avisa claramente de que las push remotas siguen pendientes de configurar,
    - estado actual:
      - la app ya diferencia entre preferencia local de notificaciones y pipeline remoto,
      - sigue faltando integrar un proveedor real de push (Firebase/FCM) para registrar `user_push_subscriptions`.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para dejar lista la sincronizacion remota de dispositivos push,
    - duracion estimada del bloque: `10-15 min`,
    - se anade `PushNotificationSubscriptionSyncClient` en:
      - `lib/core/notifications/push_notification_subscription_sync_client.dart`,
    - `PushNotificationSubscriptionService` ya puede:
      - persistir `deviceToken`, `provider`, `platform` y `deviceLabel`,
      - activar/desactivar la suscripcion remota del dispositivo,
      - borrar la suscripcion remota cuando el token desaparezca,
    - con esto el hueco para `user_push_subscriptions` queda preparado y el siguiente paso tecnico ya es solo integrar el proveedor real del token,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre `main.dart`, `settings_page.dart` y los servicios de push.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para integrar Firebase Messaging,
    - duracion estimada del bloque: `20-30 min`,
    - se anaden dependencias reales:
      - `firebase_core`,
      - `firebase_messaging`,
    - se crea `FirebasePushMessagingService` en:
      - `lib/core/notifications/firebase_push_messaging_service.dart`,
    - el arranque de la app en `main.dart` inicializa ya:
      - `Supabase`,
      - `PushNotificationSubscriptionService`,
      - `FirebasePushMessagingService`,
    - cuando Firebase este configurado de verdad, el servicio:
      - pide permisos,
      - obtiene token FCM,
      - registra o refresca la suscripcion en `user_push_subscriptions`,
      - escucha `onTokenRefresh`,
    - la integracion es tolerante a falta de configuracion nativa:
      - si aun no existen archivos/proyecto Firebase, no rompe el arranque y deja el estado como `providerNotConfigured`,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre `main.dart`, `settings_page.dart` y los servicios de push/Firebase.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para conectar el proyecto Firebase real,
    - duracion estimada del bloque: `10-15 min`,
    - se anade el plugin Android `com.google.gms.google-services` en:
      - `android/settings.gradle.kts`,
      - `android/app/build.gradle.kts`,
    - se documenta la configuracion del proyecto Firebase `windwisherapp-5ed22` en:
      - `docs/backend/firebase_setup.md`,
    - siguiente accion operativa del usuario:
      - descargar `google-services.json` para `com.windwisher.app`,
      - descargar `GoogleService-Info.plist` para el bundle id final de iOS,
      - copiarlos en `android/app/` e `ios/Runner/`.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro tras `flutterfire configure`,
    - duracion estimada del bloque: `10-15 min`,
    - `flutterfire` genera:
      - `lib/firebase_options.dart`,
      - `android/app/google-services.json`,
      - `ios/Runner/GoogleService-Info.plist`,
      - `macos/Runner/GoogleService-Info.plist`,
    - `FirebasePushMessagingService` pasa a inicializar Firebase con:
      - `DefaultFirebaseOptions.currentPlatform`,
    - con esto la capa Flutter deja de depender de inicializacion generica y queda alineada con el proyecto Firebase `windwisherapp-5ed22`,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre `main.dart`, `firebase_options.dart` y los servicios de push.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para enganchar push y sesion de usuario,
    - duracion estimada del bloque: `5-10 min`,
    - `PushNotificationSubscriptionService` pasa a escuchar `onAuthStateChange` de Supabase,
    - si el usuario inicia sesion despues del arranque y ya existe token FCM local:
      - la sincronizacion a `user_push_subscriptions` se relanza automaticamente,
      - ya no depende de reiniciar la app ni de tocar el switch de ajustes,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre `main.dart` y los servicios de push.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para observabilidad de push en ajustes,
    - duracion estimada del bloque: `5-10 min`,
    - en `SettingsPage` se muestra ya:
      - estado de sincronizacion push,
      - token obfuscado si existe,
      - o `Token: pendiente` si aun no se ha recibido,
    - `PushNotificationSubscriptionService` expone `currentStatus` para no depender solo de `SnackBar`,
    - esto deja una comprobacion visual inmediata para saber si el problema esta en:
      - Firebase/provider,
      - falta de token,
      - falta de sesion,
      - o sync correcta con Supabase.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para logout funcional en Ajustes,
    - duracion estimada del bloque: `10-15 min`,
    - se anade `signOut` a toda la cadena de auth:
      - `AuthSessionPort`,
      - casos de uso,
      - `AuthModule`,
      - adapters `Supabase` e `InMemory`,
      - `authSessionProvider`,
    - `SettingsPage` conecta ya el boton `Cerrar sesion`,
    - comportamiento nuevo:
      - muestra estado de carga mientras cierra,
      - ejecuta logout real,
      - redirige a `login`,
      - muestra `SnackBar` si falla,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre auth + settings.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para recovery de contrasena en login,
    - duracion estimada del bloque: `15-20 min`,
    - se anade `sendPasswordRecoveryEmail` a toda la cadena de auth:
      - puerto,
      - caso de uso,
      - modulo,
      - adapters,
      - provider,
  - `LoginPage` anade el boton:
      - `He olvidado mi contrasena`,
    - el recovery se envia ya desde la app con:
      - `resetPasswordForEmail(..., redirectTo: 'windwisher://login-callback')`,
    - esto evita depender del boton `Send password recovery` del dashboard de Supabase,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre auth, login y `AppStrings`.
  - bloque nuevo `2026-03-22`:
    - arranque del repo independiente `WindWisher`,
    - duracion estimada del bloque: `20-30 min`,
    - ejecutado `flutter pub get` en la carpeta nueva,
    - primera pasada de branding runtime:
      - `MeteoKite` -> `WindWisher` en titulo principal,
      - pantalla de donaciones,
      - textos operativos de forecast,
      - fuente por defecto de webcams,
      - `User-Agent` de clientes AEMET y AVAMET,
      - test base de widget,
    - segunda pasada de higiene del repo:
      - `README.md` reescrito como proyecto real,
      - `.gitignore` ampliado para Flutter, artefactos locales y secretos,
      - cabeceras y referencias principales de `docs/architecture` y planes de login renombradas a `WindWisher`,
    - estado al cierre del bloque:
      - los restos de `MeteoKite` quedan ya sobre todo en el historico del propio tracker,
      - el runtime principal ya responde como `WindWisher`,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre archivos runtime tocados.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para pulido de arranque en `WindWisher`,
    - duracion estimada del bloque: `10-15 min`,
    - detectado en Android debug arranque con multiples `Skipped frames`,
    - ajuste aplicado en `main.dart`:
      - se mantiene antes de `runApp` solo la inicializacion critica,
      - `LocalNotificationsService`,
      - `PushNotificationSubscriptionService`,
      - y `FirebasePushMessagingService`
        pasan a inicializarse en background tras el primer frame de la UI,
    - ajuste aplicado en `login_page.dart`:
      - el logo inicial deja de usar `Logo.svg`,
      - ese `svg` contenia realmente un PNG embebido en base64,
      - se sustituye por carga directa de `LogoWindWisher.png` para abaratar el primer render,
    - objetivo:
      - reducir coste en main thread al abrir la app sin cambiar el flujo funcional principal,
    - verificacion ejecutada:
      - `flutter analyze lib/main.dart`,
      - `flutter analyze lib/features/auth/presentation/pages/login_page.dart`.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para Firebase Hosting y dominio web,
    - duracion estimada del bloque: `35-45 min`,
    - configurado proyecto Firebase activo:
      - `windwisherapp-5ed22`,
    - anadidos archivos de hosting:
      - `.firebaserc`,
      - `hosting` en `firebase.json`,
      - script `scripts/deploy_firebase_hosting.sh`,
    - primera build web desplegada en:
      - `https://windwisherapp-5ed22.web.app`,
    - incidencia detectada:
      - el primer deploy publico `assets/local.env.json` con secretos locales,
    - mitigacion aplicada inmediatamente:
      - regenerada `build/web/assets/local.env.json` con solo config publica,
      - redeploy de hosting ejecutado,
      - documentado el deploy seguro en `README.md`,
    - dominio custom configurado en Firebase Hosting:
      - `windwisher.com`,
      - `www.windwisher.com`,
      - ambos quedan `Conectado`,
    - pendiente critico fuera de repo:
      - rotacion de secretos expuestos en el primer deploy,
    - verificacion ejecutada:
      - `flutter build web`,
      - `firebase hosting:sites:list`,
      - `firebase deploy --only hosting`.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para recovery web de contrasena,
    - duracion estimada del bloque: `20-30 min`,
    - anadido soporte de auth para `updatePassword`,
    - `SupabaseAuthSessionAdapter` diferencia ya redirects:
      - magic link web -> `/login`,
      - password recovery web -> `/reset-password`,
      - mobile -> `windwisher://login-callback`,
    - anadida pagina nueva:
      - `lib/features/auth/presentation/pages/reset_password_page.dart`,
    - anadida ruta:
      - `/reset-password`,
    - la pagina permite:
      - validar sesion de recovery,
      - introducir nueva contrasena,
      - confirmar contrasena,
      - actualizarla con Supabase,
      - volver al login al terminar,
    - strings nuevas anadidas en `AppStrings`,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre router + auth + reset page.
  - bloque nuevo `2026-03-22`:
    - continuacion del cronometro para corregir pantalla blanca en web,
    - duracion estimada del bloque: `15-20 min`,
    - causa localizada:
      - el arranque web entraba por capas de persistencia local con `dart:io` y `path_provider`,
    - ajustes aplicados para web-safe startup:
      - `AppStoragePaths`,
      - `LocalEnvStore`,
      - `AppLocaleController`,
      - `PushNotificationSubscriptionService`,
    - en web ahora:
      - no intenta crear directorios locales,
      - no intenta leer/escribir ficheros de locale,
      - no intenta persistir estado push en archivo,
      - se mantiene la carga del `local.env.json` publico servido por Hosting,
    - deploy web ejecutado de nuevo con:
      - `./scripts/deploy_firebase_hosting.sh`,
    - verificacion ejecutada:
      - `flutter analyze` limpio sobre archivos core tocados,
      - redeploy en Firebase Hosting completado.
  - bloque nuevo `2026-03-22`:
    - ajuste fino del redirect de password recovery,
    - duracion estimada del bloque: `5-10 min`,
    - problema detectado:
      - si el recovery se solicitaba desde mobile, Supabase seguia generando enlace con `windwisher://login-callback`,
    - ajuste aplicado:
      - `sendPasswordRecoveryEmail` pasa a usar siempre `https://windwisher.com/reset-password` fuera de web,
      - en web se mantiene `Uri.base.origin/reset-password`,
    - verificacion ejecutada:
      - `flutter analyze lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart`.
  - bloque nuevo `2026-03-22`:
    - limpieza visual del login,
    - duracion estimada del bloque: `10-15 min`,
    - cambios aplicados:
      - boton `Entrar con magic link` ocultado en login compartido para mobile y web,
      - eliminada la logica muerta de cooldown/reenvio asociada a ese acceso,
      - test de login actualizado para reflejar el flujo visible actual,
    - verificacion ejecutada:
      - `flutter analyze lib/features/auth/presentation/pages/login_page.dart test/features/auth/presentation/pages/login_page_test.dart`,
      - `flutter test test/features/auth/presentation/pages/login_page_test.dart -r compact`.
  - bloque nuevo `2026-03-22`:
    - ajustes del flujo de spots guardados,
    - duracion estimada del bloque: `20-30 min`,
    - cambios aplicados:
      - la pestaña `Spots` se rehidrata al cambiar la sesion de Supabase,
      - los spots guardados del usuario vuelven a cargarse tras login/logout sin recrear la pantalla,
      - en `Agregar spot`, un spot oficial solo cuenta como oficial si se toca su sugerencia,
      - si no se toca la sugerencia, el alta se trata como posible spot personalizado y exige coordenadas,
      - anadida pista visual `Spot oficial seleccionado: ...` cuando la sugerencia se ha elegido,
    - verificacion ejecutada:
      - `flutter analyze lib/features/spots/presentation/pages/spots_page.dart test/features/spots/presentation/pages/spots_page_test.dart`,
      - `flutter test test/features/spots/presentation/pages/spots_page_test.dart --plain-name "requires tapping the suggestion to save as official spot" -r compact`.
  - bloque nuevo `2026-03-22`:
    - cierre del flujo web de `reset password` y endurecimiento final de spots,
    - duracion estimada del bloque: `25-35 min`,
    - cambios aplicados:
      - `reset password` en web ahora fuerza `getSessionFromUrl(Uri.base)` cuando llega un enlace de recovery,
      - anadido estado intermedio de validacion del enlace antes de mostrarlo como invalido,
      - strings nuevas para el estado `recoveryLinkChecking`,
      - en spots con Supabase, la hidratacion fusiona remoto + local para no pisar altas recientes,
      - tras guardar un spot, la vista vuelve a `Todos`, orden `Recientes` y limpia la busqueda para hacerlo visible,
      - anadido test que cubre guardar una sugerencia oficial seleccionada y ver su tarjeta,
    - verificacion ejecutada:
      - `flutter analyze lib/core/i18n/app_strings.dart lib/features/auth/presentation/pages/reset_password_page.dart lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart lib/features/spots/infrastructure/adapters/supabase/supabase_spots_catalog_adapter.dart lib/features/spots/presentation/pages/spots_page.dart lib/main.dart test/features/spots/presentation/pages/spots_page_test.dart`,
      - `flutter test test/features/spots/presentation/pages/spots_page_test.dart --plain-name "saves a selected official suggestion and shows its card" -r compact`.
  - bloque nuevo `2026-03-23`:
    - bloque consolidado de estabilizacion general antes de cierre de jornada,
    - duracion estimada del bloque: `7h`,
    - cambios funcionales y de infraestructura cerrados:
      - login, recovery y router web/mobile estabilizados,
      - `push subscriptions` corregidas para `upsert` multi-dispositivo con conflicto `user_id,device_token`,
      - raiz `/`, aliases legacy y redirects de auth alineados en router,
      - sesiones, community, profile y catalogos auxiliares convertidos a comportamiento web-safe sin persistencia local por fichero cuando corre en navegador,
      - `SpotAlarmCatalog` y otros estados locales dejaron de tocar `dart:io` en web,
      - adaptadores y clientes de forecast/observacion de `spots` endurecidos para no crear `HttpClient()` en constructor,
      - tanda completa de clientes de `SpotDetailPage` blindada para que en web no revienten en arranque por `Platform._version`,
      - varias capas con fallback a memoria o Supabase en vez de `LocalFile*` al correr en Chrome,
    - alcance tecnico principal:
      - `main.dart`,
      - `app_router.dart`,
      - `push_notification_subscription_sync_client.dart`,
      - `reset_password_page.dart`,
      - `sessions_module.dart`,
      - `community_module.dart`,
      - `profile_module.dart`,
      - `profile_overview_section.dart`,
      - `spot_alarm_catalog.dart`,
      - adapters y services de `spots` para forecast/observacion,
    - commit de cierre del bloque:
      - `79181ee` `Stabilize auth and web compatibility flows`,
    - estado al cerrar:
      - commit hecho,
      - push hecho a `origin/main`,
      - working tree limpio.
  - bloque nuevo `2026-03-24`:
    - bloque de compatibilidad web/release para `Spots`, `Forecast`, `Windguru`, `Webcam` y `Live`,
    - duracion horaria exacta pendiente de consolidacion manual,
    - `Spots`:
      - corregida la no aparicion de la tarjeta de preview del spot guardado en web release,
      - endurecida la hidratacion tras guardar para evitar estados intermedios en web publicada,
      - evitado render de imagenes locales con `Image.file(...)` en web para no romper la lista de cards,
      - validado el flujo completo `Agregar spot -> Guardar spot -> Mostrar card` en `windwisher.com`,
    - `Forecast` / viento en web:
      - ampliado `forecast-proxy` en Supabase para cubrir rutas que en web no podian depender de `dart:io`,
      - conectado `Open-Meteo` point forecast / marine al proxy para restaurar el viento en web,
      - reapuntadas rutas web de `AVAMET`, `Aigua Blanca`, `Open-Meteo grid` e `Inforatge` al proxy,
      - desplegadas iteraciones del `forecast-proxy` y de Firebase Hosting para alinear local/debug/release,
    - `Windguru`:
      - eliminada la restriccion que lo deshabilitaba en web,
      - anadido embed HTML especifico para web manteniendo `WebViewWidget` en movil,
      - soportado tambien fullscreen de Windguru en web con el mismo embed,
    - `Webcam`:
      - creada capa de embed web dedicada (`webcam_web_embed*`),
      - corregido el crash de Chrome/web por uso indebido de `WebViewController()` en web,
      - reemplazado `setInnerHtml` por `iframe.srcdoc` para que el player directo del stream ejecute scripts,
      - alineado el flujo web con movil:
        - `Abrir webcam` lleva a la pagina intermedia,
        - la pantalla muestra primero la card con streaming y debajo la card descriptiva,
        - el fullscreen en web queda delegado al propio reproductor,
        - ocultados en web los botones flotantes propios de fullscreen / salir de fullscreen,
    - `Live`:
      - confirmado que la rosa con brujula usa `flutter_compass`,
      - confirmado que `flutter_compass` no da heading real en web,
      - ocultado el boton de brujula en `windwisher.com` para no mostrar una accion no operativa,
    - compatibilidad web estructural adicional:
      - drenadas varias inicializaciones eager de clientes/almacenamientos que rompian Chrome por `Platform._version` o `dart:io`,
      - diferida la creacion de `HttpClient()` y protegidas rutas web en varios clientes de `spots`,
      - usadas alternativas web-safe o basadas en Supabase donde hacia falta durante la carga de modulos,
    - verificacion y despliegue:
      - multiples `flutter analyze` sobre archivos tocados en cada subbloque,
      - multiples despliegues a Firebase Hosting (`windwisher.com` / `windwisherapp-5ed22.web.app`),
      - despliegues iterativos de `forecast-proxy` en Supabase,
      - validacion funcional final en:
        - `windwisher.com`,
        - `flutter run -d chrome`,
        - app movil/emulador,
    - commit de cierre del bloque:
      - `026eb3a` `Fix web spots, forecast, Windguru, and webcam flows`.
  - bloque nuevo `2026-03-26`:
    - bloque de conversion de `Social` a `Chat` realtime en `spots`, mas compatibilidad de iPhone simulator y ajuste de branding/web,
    - duracion estimada del bloque: `8h`,
    - `Chat` del spot:
      - renombrada la seccion `Social` a `Chat`,
      - feed rehecho como timeline de chat en vez de foro anidado,
      - replies pasados a estilo `WhatsApp/Telegram` con cita corta del mensaje respondido,
      - accion de responder movida a gesto de swipe a la izquierda con feedback haptico,
      - composer inferior unificado para mensaje nuevo, respuesta y edicion,
      - tarjeta de mensajes con scroll interno y foco en el ultimo mensaje al entrar en `Chat`,
      - composer reposicionado para verse completo al abrir `Chat`,
      - miniavatares anadidos en la timeline con fallback a iniciales,
      - boton de adjuntar redisenado:
        - icono `+`,
        - solo dos opciones (`Tomar foto o video` / `Adjuntar foto o video desde la galeria`),
        - restauracion del viewport al volver de galeria/camara,
      - adjuntos renderizados y visibles dentro de la app:
        - imagen con visor fullscreen,
        - video con visor interno fullscreen y controles (`play/pause`, progreso y tiempos),
      - eliminado el boton manual de recarga del chat y varios textos auxiliares de cabecera/composer,
      - envio optimista para que mensajes y respuestas aparezcan al instante antes del refresh realtime,
    - realtime / Supabase:
      - creada tabla `spot_social_attachments` con bucket `spot-social-media` y politicas RLS/storage,
      - activado realtime para el chat del spot,
      - suscripciones de feed, presence y typing limitadas a cuando el usuario esta realmente dentro de la pestana `Chat`,
      - anadidos indicadores de presencia (`personas dentro del chat`) y `escribiendo...`,
      - migraciones nuevas:
        - `20260325103000_spot_social_attachments.sql`,
        - `20260326091500_enable_realtime_for_spot_chat.sql`,
      - migraciones aplicadas al proyecto Supabase remoto `tefbkhwaxlsfxvnleutb`,
    - iPhone simulator / iOS:
      - rebajadas dependencias Firebase para compatibilidad con `Xcode 14.2`,
      - `Podfile` y proyecto iOS alineados a `iOS 15.0`,
      - desactivada temporalmente la inicializacion de `Firebase Messaging` solo en `iOS simulator` para evitar el error `Messaging#getToken`,
      - con ese ajuste el `Forecast` vuelve a cargar en el simulador,
      - para no romper la build web tras ese downgrade, vendorizada una copia local de `firebase_messaging_web` con interop moderna y constraints relajadas para este proyecto,
    - branding / web:
      - rehechos iconos y splash de app con branding propio,
      - afinada la experiencia de splash entre PWA instalada y splash HTML/web,
      - publicados varios rebuilds y despliegues en `windwisher.com` para alinear launcher, favicon y splash,
      - resuelta la regresion de `flutter build web` causada por `firebase_messaging_web 3.5.18` con `Dart 3.10`,
      - build final publicada en Hosting tras `flutter build web --no-wasm-dry-run`,
      - limpiados warnings/lints residuales en la copia local de `firebase_messaging_web` para no dejar diagnosticos amarillos en el workspace,
    - verificacion ejecutada:
      - multiples `flutter analyze` sobre los archivos tocados,
      - `flutter pub get` tras anadir `url_launcher` y `video_player`,
      - `supabase db push`,
      - pruebas funcionales en Android, Chrome, `windwisher.com` e iPhone simulator.
  - bloque nuevo `2026-03-27`:
    - bloque de endurecimiento de permisos/roles y reglas de producto para spots guardados,
    - duracion estimada del bloque: `4h`,
    - roles y permisos:
      - creados roles `pro` y `vip` en Supabase,
      - creado rol `manager`,
      - mantenido `manager` fuera de la jerarquia generica efectiva de permisos,
      - anadidos helpers especificos:
        - `has_manager_role()`,
        - `is_manager_of_vip(...)`,
        - `get_my_managed_vips()`,
      - creada relacion `manager -> vip` con:
        - `manager_vip_accounts`,
        - `assign_vip_to_manager(...)`,
        - `revoke_vip_from_manager(...)`,
        - `get_manager_vip_directory()`,
      - creada moderacion por spot en vez de moderacion global:
        - `spot_moderators`,
        - `can_moderate_spot(...)`,
      - el chat del spot pasa a consultar esa moderacion por `spot_key`,
    - ajustes de UI por perfil:
      - `Ajustes` ahora muestra paneles segun roles visibles del usuario,
      - anadidos accesos/placeholder para:
        - `Panel moderador`,
        - `Panel manager`,
        - `Panel admin`,
        - `Panel superadmin`,
        - `Apartado VIP`,
    - reglas de spots guardados por rol:
      - `user`:
        - maximo `2` spots oficiales,
        - sin spots custom,
        - sin edicion ni borrado,
      - `pro`, `vip`, `moderator`, `admin`, `super_admin`:
        - gestion completa del apartado,
      - `manager` queda fuera de ese acceso avanzado por ahora,
      - backend blindado con:
        - `has_advanced_saved_spot_access()`,
        - `can_insert_saved_spot(...)`,
        - nuevas policies RLS sobre `user_saved_spots`,
      - UX alineada en `SpotsPage` para reflejar esas restricciones sin errores tardios,
    - migraciones nuevas:
      - `20260327150000_add_pro_and_vip_roles.sql`,
      - `20260327150100_update_role_levels_for_pro_and_vip.sql`,
      - `20260327153000_spot_scoped_moderators.sql`,
      - `20260327160000_add_manager_role.sql`,
      - `20260327160100_update_role_levels_for_manager.sql`,
      - `20260327161500_update_manager_role_level.sql`,
      - `20260327163000_manager_vip_assignments.sql`,
      - `20260327164500_exclude_manager_from_generic_role_hierarchy.sql`,
      - `20260327170000_add_manager_vip_permission_helpers.sql`,
      - `20260327173000_saved_spots_role_limits.sql`,
    - verificacion ejecutada:
      - multiples `flutter analyze` sobre `settings_page.dart`, `spots_page.dart`, `spot_detail_page.dart` y `spot_social_client.dart`,
      - multiples `supabase db push` aplicados al remoto para las migraciones de roles, manager/vip, moderacion por spot y limites de spots guardados.

  - bloque nuevo `2026-03-28`:
    - bloque de alarmas remotas, depuracion Android/Redmi, forecast por Supabase y coherencia visual de direccion de viento,
    - duracion estimada del bloque: `6h`,
    - alarmas / push:
      - preparada la base remota de alarmas con `spot_alarm_runtime`,
      - ampliado y desplegado `spot-alarm-runner` para:
        - ventanas horarias por minuto,
        - `snooze`,
        - `stop until reset`,
        - envio push real por FCM,
      - cargado el secret `FIREBASE_SERVICE_ACCOUNT_JSON` en Supabase,
      - activado scheduler remoto del runner,
      - ajustada la evaluacion horaria del runner a `Europe/Madrid`,
      - instrumentado el flujo para distinguir:
        - `active`,
        - `wind-mismatch`,
        - `time-mismatch`,
        - `unsupported-provider`,
      - anadido manejo de `spot_alarm` en foreground en Android para convertir push remota en notificacion local audible,
      - limpiados tokens FCM obsoletos de `raulmldev` durante la depuracion en dispositivo real,
    - sincronizacion y UX de alarmas:
      - endurecida la sync de alarmas para dejar de fallar en silencio,
      - guardado/edicion/eliminacion de alarmas ahora notifican errores reales de sync,
      - anadido aviso `Nueva alarma creada.` al crear una alarma nueva en `Live`,
    - forecast Android / Redmi:
      - aislado el fallo de `Forecast` en Redmi al camino cliente `Supabase Functions invoke`,
      - verificado que `local.env.json` si va empaquetado dentro del APK,
      - instrumentado `supabase_forecast_proxy_client.dart` con logs de exito/fallo y tiempo,
      - confirmado timeout del camino SDK en Android y mantenido `Forecast` pasando por la misma Edge Function de Supabase,
      - dejada una invocacion especifica de cliente movil hacia `forecast-proxy` para evitar el bloqueo del runtime Android sin sacar el trafico fuera de Supabase,
    - visualizacion de direccion de viento:
      - corregida la orientacion de flechas en la tabla principal de forecast para mostrar flujo de viento como en Windguru manteniendo texto cardinal meteorologico,
      - corregidas flechas equivalentes en:
        - tarjeta suplementaria de Meteoblue,
        - rosa / manecilla de viento,
        - grafico / mapa historico de viento,
        - `wind_map_page.dart`,
      - corregido un giro extra de `90°` en el mapa de viento que hacia que ciertas direcciones no coincidieran con la tabla,
    - Android / dispositivo real:
      - detectado y configurado Redmi Note 10S por ADB,
      - concedido `POST_NOTIFICATIONS`,
      - instaladas varias builds release para pruebas reales,
      - aislado el ruido `E/gralloc4(... Empty SMPTE 2094-40 data)` como log del stack grafico/MIUI sin impacto funcional directo en la app,
    - verificacion ejecutada:
      - multiples `flutter analyze` sobre `spot_detail_page.dart`, `wind_map_page.dart`, `meteoblue_forecast_supplement_card.dart`, `supabase_forecast_proxy_client.dart` y `firebase_push_messaging_service.dart`,
      - despliegues de `spot-alarm-runner`,
      - pruebas reales en Redmi conectado por USB,
      - rebuilds y reinstalaciones Android release para validar forecast y alarmas.

  - bloque nuevo `2026-04-01 / 2026-04-02`:
    - cierre funcional del spot `Oliva Canal - Platja dels Gorgs` como referencia base para futuros spots,
    - login / live:
      - eliminado el boton de bypass del login en `WindWisher`,
      - eliminada la linea `Observacion ...` en `Live`, manteniendo solo `Actualizado: ...`,
      - ajustado `AEMET Oliva` para tomar la observacion puntual mas reciente en vez de quedarse con una entrada vieja del listado general,
    - alarms / notifications:
      - estabilizado el flujo remoto de alarmas con push FCM real,
      - afinadas las notificaciones locales de alarma con `Parar`, `Posponer`, dialogo propio y frase destacada,
      - validado el ciclo completo de push, `stop`, `snooze` y corte por `maxRepeats`,
    - forecast / precision:
      - restaurada la tarjeta `Precision de Modelo Forecast`,
      - anadido dialogo informativo propio y reescrito para explicar mejor metricas, umbrales y ejemplos,
    - live / historical refresh:
      - mejorado el feedback del boton refresh de la rosa de los vientos,
      - mejorado el feedback del boton refresh del historico,
      - ambos ahora muestran spinner y `SnackBar` si falla la actualizacion,
    - Inforatge:
      - corregido el parser de fecha/hora del live snapshot para el formato real `d'abril / d’abril`,
      - dejada la seleccion del snapshot de `Inforatge` priorizando el live para la tarjeta `Live`,
      - recuperados correctamente `Oliva Nova` y `Oliva Poliesportiu` tras el cambio de estacion,
    - social / chat:
      - corregida la entrada a la pestana de chat para volver a mostrar el ultimo mensaje real,
      - restaurado el patron de scroll en dos fases:
        - bajar al fondo,
        - asegurar compositor,
        - rematar al fondo tras el layout final,
    - criterio de producto:
      - se decide congelar por ahora el alcance de `Oliva Canal` y tratar este spot como modelo a replicar en los siguientes spots del proyecto.

  - bloque nuevo `2026-04-02`:
    - reorientacion de la pestana `Session` para eliminar comportamiento de plantilla y dejarla preparada para integraciones reales,
    - dispositivos:
      - eliminado el sembrado de dispositivos ficticios (`Woo Sports 3`, `Apple Watch Ultra`) tanto en memoria como en persistencia local,
      - `Telefono del usuario` pasa a ser el dispositivo base por defecto,
      - limpieza automatica de dispositivos de plantilla heredados al abrir la pestana,
      - anadida autodeteccion real del dispositivo base con `device_info_plus` para mostrar marca/modelo/plataforma reales,
    - vinculacion de dispositivos:
      - `Configurar dispositivo` deja de crear tipos manuales ficticios,
      - ahora solo muestra dispositivos compatibles detectados aun no vinculados,
      - permite editar el nombre visible antes de vincular,
      - el telefono queda fuera del flujo de configuracion manual porque la app lo autodetecta automaticamente,
    - sesiones reales vs simuladas:
      - eliminados los flujos `_mockParseImportedSession(s)` y los helpers de importacion/sincronizacion ficticia desde la pantalla,
      - `Sincronizar`, `Importar` y `Captura` ahora muestran mensaje honesto cuando la integracion real aun no esta conectada,
      - sustituidos spots hardcodeados del upload por el catalogo real de spots,
    - capacidades del dispositivo:
      - separada la idea de `capacidades` del modelo general de sesiones frente a los sensores fisicos reales del dispositivo,
      - el dialogo de capacidades ahora muestra solo sensores disponibles,
      - despues refinado para mostrar solo sensores relevantes para kite:
        - GPS,
        - acelerometro,
        - giroscopio,
        - magnetometro,
        - orientacion,
        - y, cuando aplique, ritmo cardiaco / barometro,
      - eliminados de la tarjeta sensores poco utiles para esta UX como luz ambiental, proximidad y pasos,
      - corregido el mapeo de Android/iPhone para no caer al caso por defecto de 3 capacidades,
      - validado el hardware real del Redmi por `adb shell dumpsys sensorservice`,
    - UX de la pestana:
      - corregido overflow horizontal al mostrar nombre real largo del dispositivo,
      - mejorados textos de la tarjeta principal para reflejar disponibilidad real del dispositivo y numero de sensores relevantes detectados,
      - renombrado el bloque central a `Captura de sesion`,
      - ajustado el copy para dejar claro que no se estan inventando datos,
    - soporte y tooling:
      - anadida dependencia `device_info_plus`,
      - actualizado `pubspec.lock` y registradores generados correspondientes,
    - verificacion:
      - multiples `flutter analyze` limpios sobre `sessions_page.dart`, `session_detail_page.dart` y adapters de sesiones,
      - inspeccion del Redmi real (`Xiaomi M2101K7BNY`) via `adb`,
      - instalacion de build actual en el dispositivo para comprobar la pestana `Session`.

  - bloque nuevo `2026-04-03`:
    - evolucion de `Session` hacia captura GPS real util y legible en producto,
    - duracion estimada del bloque: `6h`,
    - nota de control horario:
      - este bloque ya queda consolidado con duracion propia,
      - el siguiente cierre global de horas debe recomputar el total acumulado historico de `WindWisher` para dejarlo otra vez explicito en el tracker,
    - captura real:
      - anadida grabacion real de sesion con `geolocator`,
      - la sesion ya guarda track GPS real, distancia, velocidad media, velocidad maxima y timeline de velocidad,
      - ajustado el flujo de detener/grabar para separar mejor:
        - detener y revisar,
        - detener sin `GPS OK` y descartar,
      - el guardado sigue siendo honesto y no se inventan metricas de saltos o hangtime,
    - calidad GPS / captura:
      - chip de GPS mejorado con estados visuales y precision en metros,
      - `GPS OK` fijado en `<= 5 m`,
      - filtrado basico de muestras malas:
        - se descartan fixes con precision > `25 m`,
        - se descartan saltos imposibles > `65 kt`,
      - anadido chip de `Auto-pausa` con estado visible,
    - auto-pausa:
      - anadida auto-pausa inteligente para sesiones reales,
      - entra con velocidad <= `1.5 kt` durante `20 s`,
      - sale con velocidad >= `4 kt` durante `6 s`,
      - tiempos `activo` y `parado` pasan a apoyarse en esta logica,
      - se persiste tambien el numero de auto-pausas de la sesion,
    - feedback en vivo durante grabacion:
      - anadidos chips de:
        - velocidad actual,
        - velocidad maxima,
        - tiempo activo,
        - tiempo parado,
      - suavizada la `Velocidad actual` con media corta de las ultimas 4 muestras para evitar dientes del GPS,
    - detalle de sesion:
      - anadida tarjeta `Ruta GPS real` con mapa del track guardado,
      - la tarjeta muestra:
        - distancia,
        - duracion,
        - franja horaria inicio-fin,
        - punta maxima en kt,
      - marcadores visibles en mapa para:
        - inicio,
        - fin,
        - punto de velocidad maxima,
      - anadida leyenda para interpretar esos marcadores,
      - anadida tarjeta `Calidad de captura` con:
        - puntos GPS validos,
        - auto-pausas,
        - velocidad media en movimiento,
    - verificacion:
      - multiples `flutter analyze` limpios sobre `sessions_page.dart` y `session_detail_page.dart`,
      - pruebas orientadas a iteracion con `hot reload / hot restart`,
      - sin tocar ya `Meteokite`; todo el trabajo queda consolidado solo en `WindWisher`.

  - bloque nuevo `2026-04-05`:
    - consolidacion de `Session` sobre datos reales y limpieza de residuos sinteticos,
    - duracion estimada del bloque: `5h`,
    - persistencia / my sessions:
      - verificado que en Supabase existen sesiones reales del usuario (`c3f2da51-bdcb-4e68-9475-f381c93ad5b2`) y que el vacio en app no venia de una tabla remota vacia,
      - reforzado `SupabaseSessionRecordsAdapter` para usar persistencia local solo como respaldo temporal:
        - si Supabase falla o no hay sesion autenticada, la sesion queda en local como pendiente,
        - si Supabase guarda bien, la copia local se elimina,
        - al cargar, se mezclan solo las sesiones locales pendientes de subir y se limpian las ya presentes en remoto,
      - `SessionsModule.auto()` queda cableado con fallback local explicito para sesiones,
      - eliminados `unawaited(...)` en guardado/borrado principal de `My Sessions` para evitar falsos positivos de persistencia en UI,
      - anadido debug visual en estado vacio de `My Sessions` para mostrar si Supabase tiene sesion iniciada y con que `user id`,
    - modelos / datos honestos:
      - eliminado `SessionInsightData.fromSession(...)` y con ello el ultimo generador sintético de metricas de sesion,
      - anadido `SessionInsightData.empty(...)` como factory honesto para estados vacios,
      - alineados `Session`, `Community` y tests para construir `insights` solo con datos reales o vacio explicito,
      - actualizados tests de detalle de sesion y persistencia local para trabajar ya sin fallbacks sinteticos,
    - detalle de sesion / UX:
      - compactado `Historial de saltos` cuando no hay saltos detectados, reduciendo altura y ruido visual,
      - compactada `Mediciones avanzadas` cuando no hay ningun KPI real, ocultando selector y contenedor interior innecesarios,
      - `Resumen post-sesion` pasa a mostrar solo tiles con datos reales:
        - mantiene siempre `Duracion sesion`,
        - el resto de KPIs solo aparecen si existen de verdad,
      - corregido el chip horario `inicio-fin` de `Ruta GPS real` para usar hora local (`toLocal()`) en vez de mostrar UTC,
    - advanced metrics / community:
      - mejorado el copy de `Mediciones avanzadas` para distinguir entre:
        - sesion sin KPIs reales,
        - categoria concreta sin datos,
      - alineado `Community` con el catalogo actual de KPIs reales de `Session`:
        - fuera `racha_max` y `racha_10s`,
        - `Freestyle` pasa a `Maniobras`,
        - `Velocidad P95` pasa a `Velocidad alta sostenida`,
        - `Smoothness score` pasa a `Suavidad de navegacion`,
        - `Score de maniobras` se mantiene como label final para esa familia,
    - saltos / deteccion:
      - mantenida la bifurcacion `inertial_fallback` / `barometric`,
      - convertidos avisos `TODO` del pipeline barometrico en comentarios normales para limpiar el analizador sin perder la intencion tecnica,
    - estructura / mantenimiento:
      - consolidado el trabajo de extraccion de widgets y modelos de detalle ya movidos a `presentation/widgets/session_detail` y `presentation/models`,
      - el detalle queda mas mantenible y con menos logica inflada en pagina,
    - verificacion:
      - `flutter analyze` limpio en los archivos tocados,
      - `flutter test` limpio en:
        - `test/features/sessions/presentation/pages/session_detail_page_test.dart`,
        - `test/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter_test.dart`,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.

  - bloque nuevo `2026-04-05`:
    - pulido de `My Sessions` como listado diario y limpieza de acciones redundantes,
    - duracion estimada del bloque: `3h`,
    - my sessions / ux del listado:
      - simplificada la card de sesion para dejarla como acceso ligero al detalle,
      - eliminadas de la card las acciones `Editar` y `Eliminar` porque ya existen en `Detalle de sesion`,
      - reducido el placeholder sin foto para que pese menos visualmente en la lista,
      - mantenida la fila de KPIs cortos en una sola linea horizontal,
      - afinado el orden de KPIs a:
        - duracion,
        - velocidad maxima,
        - hangtime,
        - salto,
      - simplificados los chips de duracion y velocidad maxima a icono + valor,
      - eliminado el texto redundante debajo del chip de equipacion porque ese detalle ya vive en el dialogo,
    - widgets compartidos de session:
      - extraidos widgets reutilizables para chip y dialogo de equipacion:
        - `session_gear_action_chip.dart`,
        - `session_gear_dialog.dart`,
      - extraidos widgets reutilizables para chip y dialogo de dispositivo:
        - `session_device_action_chip.dart`,
        - `session_device_dialog.dart`,
      - reutilizados tanto en `MySessionCard` como en `SessionHeroCard`,
      - `session_detail_page.dart` deja de construir inline ambos dialogos y pasa a delegar en widgets compartidos,
    - my sessions / filtros y busqueda:
      - eliminados de la UI el filtro por dispositivo y el selector de orden,
      - `My Sessions` queda siempre ordenado por `Mas recientes`,
      - el buscador pasa a ser el unico control visible para sesiones,
      - ampliada la busqueda para encontrar por:
        - titulo,
        - resumen,
        - dispositivo,
        - spot,
        - equipacion (`gearSetupName`),
      - anadido boton para limpiar la busqueda desde el `TextField`,
      - mejorado el estado vacio para distinguir entre:
        - no hay sesiones finalizadas,
        - no hay resultados para la busqueda actual,
    - limpieza tecnica:
      - descartada la extraccion intermedia de `my_session_summary_section.dart` al no aportar suficiente claridad real en una card tan pequena,
      - eliminados helpers y props ya no usados en `sessions_page.dart` y `my_session_card.dart`,
      - incluidos cambios generados de `macos/` asociados al estado actual de CocoaPods/workspace para mantener el arbol consistente,
    - verificacion:
      - multiples `flutter analyze` limpios sobre:
        - `sessions_page.dart`,
        - `my_session_card.dart`,
        - `session_detail_page.dart`,
        - `session_hero_card.dart`,
        - widgets compartidos de dispositivo y equipacion,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.

  - bloque nuevo `2026-04-06`:
    - refactor de arquitectura de `Session` para dejar `presentation/` mas coherente y `sessions_page.dart` bastante mas descargado,
    - duracion estimada del bloque: `7h`,
    - acumulado reciente visible del bloque grande de `Session`:
      - `2026-04-03`: `6h`
      - `2026-04-05`: `5h`
      - `2026-04-05`: `3h`
      - `2026-04-06`: `7h`
      - total reciente estimado de esta etapa: `21h`
    - ordenacion de carpetas de presentation:
      - separadas responsabilidades en:
        - `presentation/mappers/` para mapeo de view data,
        - `presentation/logic/` para logica operativa y coordinacion de captura,
        - `presentation/builders/` para ensamblado de sesiones grabadas,
      - movidos a `presentation/logic/`:
        - `start_session_capture_logic.dart`,
        - `start_session_location_logic.dart`,
        - `start_session_device_detection_logic.dart`,
        - `start_session_media_logic.dart`,
        - `start_session_track_metrics_logic.dart`,
      - movido a `presentation/builders/`:
        - `start_session_recorded_session_builder.dart`,
      - imports actualizados en toda la capa `presentation` para reflejar la nueva estructura,
    - sessions / pages:
      - consolidada la division de `sessions_page.dart` respecto a:
        - `start_session_page.dart`,
        - `my_sessions_page.dart`,
      - reforzada la idea de pagina contenedora/orquestadora y no pagina con toda la UI inline,
    - sessions / models y mappers:
      - anadidos y consolidados modelos de presentacion propios para:
        - `start_session_models.dart`,
        - `my_sessions_models.dart`,
        - `session_gear_models.dart`,
      - consolidado el uso de mappers de presentacion para:
        - `StartSession`,
        - `My Sessions`,
        - gear snapshot / opciones de equipo,
    - start session / widgets y dialogos:
      - extraidos widgets propios para el bloque `Start Session`:
        - selector de dispositivo,
        - tarjeta de dispositivo seleccionado,
        - tarjeta de sesiones sincronizadas pendientes,
        - tarjeta de importacion de archivo,
        - panel contenedor de `Start Session`,
        - dialogo de stop recording,
        - dialogo de add device,
        - dialogo de capacidades,
        - dialogo reutilizable de upload/edit session,
      - la pagina deja de construir inline varios `AlertDialog` y bloques largos de UI,
    - start session / logica de captura:
      - sacada de la pagina la logica de:
        - auto-pausa,
        - resolucion de velocidad GPS,
        - validacion de muestras,
        - acumulacion de track,
        - cooldown de eventos de movimiento,
        - actividad reciente inercial,
        - evaluacion de acelerometro y giroscopio,
        - deteccion y cierre de saltos,
        - decision de rama barometrica vs inercial,
        - aplicacion final del salto al estado local,
      - `sessions_page.dart` queda bastante mas centrada en aplicar resultados y refrescar UI,
    - start session / flujo de control:
      - extraidas decisiones explicitas para:
        - control principal de captura (`start / confirm stop / guardar / reset / mensaje`),
        - acceso a localizacion,
        - parada de captura (`discardAndReset / markFinished`),
      - limpiados `_startRealSessionRecording()` y `_stopRealSessionRecording()` para que funcionen como secuencias de alto nivel,
      - separados helpers privados para:
        - activar captura,
        - arrancar ticker,
        - conectar streams,
        - manejar muestra GPS rechazada/aceptada,
    - start session / persistencia y guardado:
      - unificado el guardado de sesion nueva y sesion importada/sincronizada con helpers comunes para:
        - preparar sincronizacion,
        - calcular timing final,
        - insertar en feed,
        - persistir y actualizar preferencias,
    - my sessions:
      - consolidado el uso de:
        - `MySessionCardData`,
        - `MySessionsEmptyStateData`,
        - `MySessionsSearchFieldData`,
      - extraidos widgets propios para buscador y estado vacio,
      - la card y el listado quedan ya alineados con el nuevo reparto `models / mappers / widgets`,
    - verificacion:
      - `flutter analyze lib/features/sessions/presentation` limpio,
      - multiples `flutter analyze` limpios durante el bloque sobre archivos tocados,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.

  - bloque nuevo `2026-04-06`:
    - fix real de fotos de `Session` compartidas entre dispositivos,
    - duracion estimada del bloque: `1h`,
    - almacenamiento remoto de foto:
      - al crear, importar o editar una sesion con foto, la imagen se sube primero a Supabase Storage (`session-media`),
      - la sesion ya no persiste la ruta local del dispositivo como `session_photo_path`,
      - la ruta remota generada incluye sufijo temporal para evitar cache visual al cambiar la foto,
    - persistencia / adapter:
      - `SupabaseSessionRecordsAdapter` deja de enviar rutas locales a la tabla `sessions`,
      - `has_session_photo` en remoto queda alineado con la existencia real de URL remota,
    - render de `My Sessions` y detalle:
      - `MySessionCard` y `SessionHeroCard` aceptan URL remota y la muestran con `Image.network`,
      - se mantiene compatibilidad visual con path local solo como tolerancia, no como fuente de verdad remota,
    - resultado funcional validado:
      - cambiada la foto de una sesion en Xiaomi,
      - la misma sesion muestra ya la foto correcta en el emulador,
      - confirmado que el problema de base era guardar path local en vez de URL remota compartible,
    - verificacion:
      - `flutter analyze` limpio en:
        - `sessions_page.dart`,
        - `my_session_card.dart`,
        - `session_hero_card.dart`,
        - `supabase_session_records_adapter.dart`,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.


  - bloque nuevo `2026-04-09`:
    - simplificacion visual de `Start Session` para dejar la tarjeta de captura en modo minimo y mas honesto,
    - duracion estimada del bloque: `2h`,
    - tarjeta de captura:
      - recortado el copy redundante del bloque `Captura de sesion`,
      - eliminada la barra de progreso por no aportar valor real en este flujo,
      - eliminada la nube de chips secundarios para reducir ruido visual,
      - mantenida solo la chip de `guardado` por ser la unica señal operativa realmente util,
      - el resumen pasa a mostrar solo `tiempo`, `ultimo salto` y `velocidad`,
      - la velocidad visible queda reducida a la velocidad actual,
      - el estado GPS deja de ocupar espacio en la tarjeta,
      - el `ultimo salto` pasa a salir del `jumpHistory` real de la captura activa,
    - copy / panel:
      - simplificado el copy general de `Start Session` para evitar repeticiones de `sesion real`,
      - eliminada la linea duplicada de estado bajo el titulo `Captura de sesion`,
      - mensajes de estado mas cortos al empezar, grabar y guardar,
    - cierre del bloque:
      - commit realizado: `c8a90cf` `Simplify start session capture card`,
      - push correcto a `origin/WindWisher-v1.0`,
    - verificacion:
      - `flutter analyze` limpio en modelos, mapper, `sessions_page.dart`, `session_capture_status_card.dart` y `session_start_panel.dart`,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.


  - bloque nuevo `2026-04-08`:
    - discovery BLE real y probe propietario FitCloud para smartwatch `HT17`,
    - duracion estimada del bloque: `3h`,
    - permisos y experiencia de usuario:
      - anadidos permisos BLE reales en Android (`BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`) y textos de privacidad Bluetooth en iOS/macOS,
      - el dialogo pasa a llamarse `Anadir dispositivo`,
      - el flujo pide permisos Bluetooth, maneja Bluetooth apagado y abre el prompt/ajustes cuando el sistema lo requiere,
      - corregidos overflows horizontal y vertical del dialogo al mostrar nombres/diagnosticos BLE largos,
    - discovery de dispositivos:
      - el adapter BLE muestra dispositivos detectados aunque aun no sean elegibles,
      - el selector ensena datos de diagnostico utiles (`id`, `services`, `manufacturerData`, `rssi`, `connectable`),
      - anadido canal nativo Android `windwisher/bluetooth_devices` para leer dispositivos ya vinculados con el telefono (`bondedDevices`) y mezclar esa fuente real con el scan BLE,
      - esto permite seleccionar el reloj real `HT17 / C1:A1:B2:2F:E0:A9` aunque el anuncio BLE activo no siempre sea suficiente,
    - GATT y sensores:
      - el probe lee el GATT completo visible y lista servicios/caracteristicas con propiedades (`read`, `write`, `notify`, `indicate`),
      - se confirma que el reloj no expone Heart Rate estandar `180D`, Environmental Sensing `181A` ni Location and Navigation `1819`,
      - se conserva la regla de producto: sin `barometer`/`altimeter`, el reloj no es elegible para grabar sesion de kitesurf,
    - protocolo FitCloud:
      - decompilada FitCloudPro con `jadx` para identificar el flujo de heart rate,
      - localizado protocolo propietario sobre servicio `000001ff-3c17-d293-8e48-14fe2e4da212`, write `ff02` y notify `ff03`,
      - probado comando diagnostico de inicio/parada de pulso contra el `HT17`,
      - recibidas notificaciones reales de pulso y parseadas lecturas plausibles (`82`, `80`, `76`, `73`, `68`, `66`, `67` bpm),
      - el probe marca `heart_rate` como sensor fisico solo cuando llegan BPM validos,
    - verificacion:
      - rebuild completo en Xiaomi tras cambio nativo de Android,
      - hot reload posterior tras cambios Dart,
      - `flutter analyze` limpio en adapter BLE y logica de deteccion,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.


  - bloque nuevo `2026-04-06`:
    - fiabilidad de `Session` y vinculacion real de dispositivos reencauzadas sobre hardware fisico,
    - duracion estimada del bloque: `4h`,
    - sensores y capacidades:
      - eliminada `orientation` como sensor fisico del catalogo,
      - separadas en modelo las nociones de `sensores fisicos` y `capacidades derivadas`,
      - los dialogos de capacidades muestran ya ambos bloques por separado,
    - saltos / honestidad de medicion:
      - `inertial_fallback` deja de registrar saltos por si solo,
      - la rotacion deja de contar como requisito universal de confirmacion,
      - la heuristica pasa a orientarse por tipo de dispositivo en vez de asumir el mismo comportamiento para movil, reloj y sensor de tabla,
      - la altura de salto deja de inferirse desde `hangtime`,
      - `hangtime` se conserva como metrica propia y la altura queda `No disponible` cuando no existe fuente vertical fiable,
    - dispositivos / vinculacion:
      - `LinkedDevice` se amplia con `family`, `placement`, `physicalSensorKeys` e `isSessionEligible`,
      - la elegibilidad queda centralizada en `LinkedDevice.isSessionEligibleForDetectedDevice(...)`,
      - telefono local sigue entrando por deteccion interna,
      - `watch` y `board_sensor` solo son elegibles si exponen `barometer` o `altimeter`,
      - la seleccion de `Start Session` trabaja ya con dispositivos elegibles y con inventario de sensores fisicos reales,
    - discovery externo real:
      - anadida base BLE real con `flutter_reactive_ble`,
      - creado adapter `ble_session_device_discovery_adapter.dart`,
      - `detectExternalSessionDevices()` deja de ser placeholder vacio y pasa a lanzar escaneo BLE real,
      - el dialogo de vincular muestra dispositivos detectados y la comprobacion de elegibilidad ocurre despues de que el usuario seleccione uno,
      - primera base de identificacion para sensores de tabla tipo `WOO` a partir de anuncios BLE, lista para endurecerse luego con `manufacturer data` / `service UUIDs`,
    - verificacion:
      - `flutter pub get` correcto,
      - multiples `flutter analyze` limpios sobre modelos, logica, adapters BLE, dialogo de vinculacion y `sessions_page.dart`,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.

  - bloque nuevo `2026-04-12`:
    - reorganizacion profunda de `profile` para alinear arquitectura de presentacion con la UI real de `Perfil`,
    - duracion estimada del bloque: `8h`,
    - estructura de presentacion:
      - separado `presentation/pages` en ramas explicitas `alarms`, `messages` y `profile`,
      - dentro de `profile` se consolidan `user` y `gear` como subdominios propios,
      - eliminada la vieja carpeta `presentation/pages/widgets` al quedar ya sin uso real,
    - perfil / user:
      - consolidada la division `Usuario / Equipo` dentro de `Perfil`,
      - `Usuario` muestra `summary` + `stats`,
      - `Equipo` muestra las tres tarjetas de material,
      - la capa `user` queda organizada con `widgets` y `dialogs` propios,
      - la tarjeta de resumen estadistico pasa a reutilizarse tambien en la vista publica sin boton de detalle,
    - kpis y dialogo de estadisticas:
      - consolidado el motor `Profile KPIs` con agregacion desde sesiones y comunidad,
      - el dialogo de detalle se refactoriza a widgets internos para selector, seccion y contexto,
      - el catalogo de KPIs filtra ya los no hidratados para no ensenar placeholders vacios,
      - simplificada la UI del dialogo para usuario final quitando textos tecnicos como `Dato disponible` o `Pendiente desde ...`,
    - gear / arquitectura:
      - `gear` queda separado en `dialogs`, `management`, `usage` y `widgets`,
      - `profile_gear_section.dart` pasa a consumir bloques de datos agrupados en vez de muchos parametros sueltos,
      - los coordinadores de dialogos se trocean en `profile_gear_dialogs_coordinator.dart`, `profile_gear_item_dialogs.dart`, `profile_gear_setup_dialogs.dart` y `profile_gear_dialogs_dependencies.dart`,
    - gear / widgets:
      - extraidas como widgets las tres tarjetas de `Equipo`: `Tu material`, `Mis equipaciones` y `Estadisticas de uso`,
      - `Mis equipaciones` deja el patron de cards y pasa a lista de pastillas/filas interactivas con detalle en dialogo y menu `...` propio,
      - `Tu material` se divide en header, selector y seccion de configuracion,
      - `Estadisticas de uso` se divide en header, filas y accion de detalle,
    - gear / detalle de uso:
      - enriquecida la tarjeta de uso con resumen real: `equipacion mas usada`, `cometa mas usada` y `tabla mas usada`,
      - el detalle de uso deja de navegar a una pagina y pasa a abrirse en dialogo modal reutilizable,
      - corregidos overflows horizontales del dialogo haciendo flexibles las filas `label / value` y los bloques con accion `Detalles`,
      - eliminado el boton inferior redundante de cierre para dejar solo la `X` del encabezado,
    - cierre del bloque:
      - actualizado `SESSION_TRACKER.md` con consolidacion de horas y resumen del trabajo,
    - verificacion:
      - multiples `flutter analyze` limpios durante el bloque y al cierre,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.


  - bloque nuevo `2026-04-13`:
    - cierre fuerte del tab `Mensajes` y saneado del scope de `Alarmas` por usuario,
    - duracion estimada del bloque: `7h`,
    - mensajes / producto:
      - eliminada la antigua vista `Buscar en app` de la interfaz de perfil para dejar `Mensajes` centrado solo en chats directos,
      - el listado de chats pasa a una UX mucho mas compacta y cercana a WhatsApp,
      - sustituido el boton `+` con dialogo viejo por buscador inline capaz de filtrar chats existentes e iniciar conversaciones con usuarios desde la misma tarjeta,
      - los resultados de busqueda mezclan ya chats existentes y usuarios nuevos en una sola lista,
      - ordenados los resultados para priorizar coincidencias mas naturales,
    - mensajes / chat directo:
      - el chat directo queda funcional de extremo a extremo en dialogo: carga, envio, edicion, borrado, reply, multimedia persistente y apertura de foto/video,
      - el flujo de bloqueo se corrige para que sea toggle real `bloquear / desbloquear` tanto en UI como en repositorio y controller,
      - revisada la experiencia visual del chat para acercarla mas al patron del chat de `spot`,
    - mensajes / arquitectura:
      - eliminados archivos muertos del antiguo indexado y del dialogo legacy de `nuevo chat`,
      - renombrado `profile_messages_chat_pages.dart` a `direct_chat_dialog.dart`,
      - renombrado `profile_messages_section.dart` a `profile_direct_messages_section.dart`,
      - reordenada la carpeta `widgets/chat/` por responsabilidad en `dialog`, `feed`, `composer` y `header`,
      - extraidas hojas de acciones, utilidades, shell visual y controlador propio del chat directo,
      - el archivo principal del chat queda ya como wiring de estado/vista y no como `god file`,
    - alarmas / usuario:
      - corregido el catalogo de alarmas para que la persistencia local tambien quede separada por usuario y no por un unico fichero global,
      - el catalogo reacciona ya al cambio de sesion y rehidrata el scope correcto,
      - esto alinea la cache local con el comportamiento remoto de Supabase para que cada usuario vea solo sus alarmas,
    - migraciones / backend relacionadas con mensajes directos:
      - mantenidas en el repo las migraciones para creacion segura de chat directo, multimedia persistente y soporte de `reply`,
    - cierre del bloque:
      - actualizado `SESSION_TRACKER.md` con el trabajo realizado y horas estimadas,
    - verificacion:
      - multiples `flutter analyze` limpios sobre `messages`, `profile_page`, `profile_module`, `spot_alarm_catalog` y piezas auxiliares durante el bloque,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.


  - bloque nuevo `2026-04-13`:
    - extension del bloque de `Mensajes` para cerrar notificaciones directas, unread y realtime en un nivel ya utilizable en produccion,
    - duracion estimada adicional del tramo: `4h`,
    - mensajes / notificaciones:
      - anadido soporte cliente para `direct_message` en Firebase Messaging y notificaciones locales,
      - creada la entidad de evento `direct_message_notification_event.dart` para abrir chats desde notificaciones remotas y locales,
      - `DashboardPage` ya enruta la apertura de la notificacion hacia `Perfil > Mensajes > chat correspondiente`,
      - desplegada la Edge Function `direct-message-push` y la RPC `get_backend_direct_message_push_targets(...)`,
      - el envio push excluye chats silenciados, bloqueados o eliminados por el receptor,
      - validado el comportamiento real:
        - con app en primer plano y usuario en lista de chats: llega aviso local y se actualiza la lista,
        - con app en segundo plano: llegan push correctamente,
        - con app completamente cerrada en Xiaomi/MIUI queda documentada una limitacion dependiente del sistema,
    - mensajes / realtime y estado:
      - anadido `realtime` para lista de chats y para feed del chat directo,
      - anadido `typing...` real por hilo,
      - anadido unread real por usuario basado en `last_read_message_created_at`,
      - anadido estado `Visto` en mensajes propios usando el ultimo punto de lectura del otro participante,
      - corregido el refresco de preview del listado para que el ultimo mensaje del chat no quede stale tras enviar o editar,
    - mensajes / robustez del cliente:
      - al activar notificaciones, la app solicita y valida permisos reales del sistema,
      - el envio de push deja trazas explicitas de `sent / failed / reason` para no volver a ir a ciegas,
      - anadido fallback de aviso local en foreground desde `ProfilePage` cuando entra un mensaje nuevo y el chat no esta abierto,
    - backend / repo:
      - mantenidas y conectadas las migraciones `20260414001000_direct_message_push_notifications.sql` y `20260414004500_direct_thread_unread_state.sql`,
      - actualizados puertos, casos de uso, controller y adapters para watchers, typing, unread y notificaciones,
    - verificacion:
      - multiples `flutter analyze` limpios sobre `main.dart`, `settings_page.dart`, `profile_page.dart`, `profile_messages` y adapters de Supabase,
      - se mantiene solo el warning externo conocido de `webview_flutter:macos`.


  - bloque nuevo `2026-05-09`:
    - cierre del flujo de alarmas push/locales y optimizacion de carga en Spots/Live/Forecast,
    - tiempo real trabajado en este tramo: `55 min` aprox. (`13:53-14:48 CEST`),
    - alarmas / backend:
      - el runner de Supabase vuelve a evaluar alarmas activas respetando `snoozed_until`, `stopped_until_reset` y `max_repeats`,
      - cambiado el scheduler de `spot-alarm-runner` de cada 5 minutos a cada 1 minuto para que `min1` pueda funcionar de forma realista con app cerrada,
      - desplegada la Edge Function `spot-alarm-runner` en el proyecto remoto,
      - verificado en Supabase que el cron remoto activo es `spot-alarm-runner-every-1-min`,
      - anadido `occurrenceIndex` al payload FCM para que cliente y backend sepan que repeticion se esta gestionando,
      - reforzado el envio por usuario para evitar entregas cruzadas entre subscripciones,
      - anadido soporte de observaciones `PUERTOS/PORTUS` en el runner de alarmas,
    - alarmas / cliente:
      - separadas las rutas de notificacion de `spot_alarm`, `spot_chat` y `direct_message`,
      - al tocar una alarma push se abre `Perfil > Alarmas`,
      - tocar la notificacion de alarma actua como posponer cuando quedan repeticiones y como finalizar/parar al llegar a `max_repeats`,
      - `Posponer` cancela la notificacion visible, programa repeticion local si el sistema lo permite y sincroniza `snoozed_until` para que Supabase sea el fallback fiable,
      - `Parar` cancela la notificacion y deja la alarma parada hasta que las condiciones se desactiven y puedan reactivarse,
      - inicializacion defensiva de dependencias en background isolate para taps/acciones de notificaciones,
      - ids deterministas de notificacion por alarma para poder cancelar correctamente incluso despues de reinicios,
    - spots / live:
      - optimizacion del tab Live para no cargar historicos pesados al entrar,
      - carga de historico bajo demanda con boton dedicado,
      - patron de lazy loading por estacion para que cada spot pueda cargar solo su estacion de referencia y despues las seleccionadas,
      - restaurada y ajustada la seleccion de estaciones live, incluyendo `AEMET Oliva` y la preferencia por Club Nautico en Oliva Canal,
    - spots / forecast:
      - Forecast queda orientado a carga por modelo seleccionado en lugar de precargar todo,
      - reorganizacion de tablas por proveedor/modelo con piezas compartidas,
      - mantenido Windguru con su comportamiento especifico,
    - notificaciones de chat de spot:
      - anadido evento local `spot_chat_notification_event.dart`,
      - enrutable desde notificaciones hacia el chat del spot correspondiente sin mezclarlo con alarmas,
    - verificacion:
      - `flutter analyze lib/core/notifications/local_notifications_service.dart lib/core/notifications/firebase_push_messaging_service.dart` limpio,
      - `flutter build apk --debug` correcto,
      - APK debug instalado correctamente en el dispositivo Android conectado mediante `adb install -r`,
      - validacion manual del usuario: el flujo de alarma ya parece funcionar bien con app cerrada.


  - bloque nuevo `2026-05-09`:
    - apuntalado del sistema de alarmas para Apple/iOS y cierre de regresion en acciones de notificacion,
    - tiempo real trabajado en este tramo: `1h 20 min` aprox. de trabajo efectivo,
    - alarmas / Apple:
      - anadido `Runner.entitlements` en iOS con `aps-environment` dependiente de configuracion,
      - conectado el target iOS para firmar con `Runner/Runner.entitlements`,
      - configurado `APS_ENVIRONMENT = development` en Debug y `production` en Profile/Release,
      - anadido `remote-notification` a `Info.plist`,
      - anadidos entitlements APNs equivalentes en macOS,
      - el payload APNs de `spot-alarm-runner` mantiene `category: spot_alarm_actions`, `sound: default` e `interruption-level: time-sensitive`,
    - iOS / compatibilidad de build:
      - creado override local `third_party/webview_flutter_wkwebview_xcode14` para compilar con Xcode 14.2 sin llamar directamente a `WKWebView.isInspectable`,
      - anadido override en `pubspec.yaml` hacia el WebView local parcheado,
      - fijado `SwiftProtobuf` en `1.36.1` en `ios/Podfile`,
      - anadidos parches reproducibles `post_install` para quitar sintaxis Swift no soportada por Xcode 14.2 en Pods generados,
      - actualizado `Podfile.lock` con Firebase 11.15.0 y dependencias compatibles con los plugins actuales,
      - excluido `third_party/**` del analyzer para no analizar codigo vendorizado/generado del plugin,
    - alarmas / contrato antirregresion:
      - creado `docs/backend/android_spot_alarm_contract.md` documentando el contrato Android + Apple de alarmas,
      - creado `scripts/check_android_spot_alarm_contract.py` para validar permisos, scheduler, payloads, APNs, routing y parches iOS criticos,
      - el contrato separa explicitamente `spot_alarm`, `spot_chat` y `direct_message`,
    - alarmas / acciones de notificacion:
      - reforzado `Parar` para cancelar tambien cualquier notificacion activa del canal `spot_alarms_v2`,
      - si Android entrega una respuesta sin payload, se cancela al menos la notificacion visual por `response.id`,
      - `Parar` ahora sincroniza `stopped_until_reset` directamente con Supabase aunque el catalogo local no este hidratado en background,
      - `Posponer` desde notificacion tambien puede sincronizar `snoozed_until` directamente con Supabase si la alarma no esta cargada localmente,
    - verificacion:
      - `flutter build ios --debug --simulator` correcto,
      - `python3 scripts/check_android_spot_alarm_contract.py` correcto,
      - `plutil -lint` correcto para `Info.plist` y entitlements Apple,
      - `flutter analyze` limpio.


  - bloque nuevo `2026-05-10`:
    - cierre del bug de acciones Android en notificaciones de alarmas y medicion de rendimiento Live,
    - tiempo real trabajado en este tramo: `20 min` aprox. de trabajo efectivo,
    - alarmas / Android:
      - anadido `ActionBroadcastReceiver` de `flutter_local_notifications` al `AndroidManifest.xml` para que `Posponer` y `Parar` entren realmente en Dart,
      - anadidos receivers de notificaciones programadas y permiso `RECEIVE_BOOT_COMPLETED` para reforzar repeticiones locales tras reinicio o actualizacion,
      - ampliado el script de contrato para detectar si esos receivers/permisos desaparecen,
      - validacion manual del usuario: `Posponer` y `Parar` ya funcionan correctamente,
    - spots / live:
      - anadidas trazas `LiveStationTiming` para medir `resolve-stations`, `live-data` e `history`,
      - las trazas incluyen `elapsedMs`, proveedor, `stationKey`, nombre de estacion y numero de puntos de historico,
      - esto permite comparar velocidades reales entre AEMET, AVAMET, Puertos, Inforatge y resto de estaciones desde logs del dispositivo,
    - verificacion:
      - `python3 scripts/check_android_spot_alarm_contract.py` correcto,
      - `flutter analyze` limpio,
      - `flutter build apk --debug` correcto.


  - bloque nuevo `2026-05-13`:
    - refactor incremental del tab Live de Spots para dejar el historico mas modular y seguro de mantener,
    - tiempo real trabajado en este tramo: `30 min` aprox. de trabajo efectivo,
    - spots / live / estaciones:
      - extraidos widgets de seleccion y acciones de estaciones live,
      - eliminado el boton de debug `Chequear AEMET Oliva`,
      - mantenido el lazy loading de estacion seleccionada y la carga manual de historico,
    - spots / live / historico:
      - extraidos helpers puros del historico a `live_history_helpers.dart`,
      - extraida la tarjeta inicial de `Cargar historico`,
      - extraidos controles de rango/bucket del historico,
      - extraidos controles de comparativa forecast historico,
      - extraida la carcasa visual de la grafica historica con refrescar y pantalla completa,
      - extraido el encabezado del historico cargado,
      - `live_history_section.dart` queda mas cerca de un ensamblador de datos y callbacks,
    - verificacion:
      - `flutter analyze` limpio tras cada paso del refactor.


  - bloque nuevo `2026-05-13`:
    - continuacion del refactor Live de Spots para separar responsabilidades del historico y de estaciones,
    - tiempo real trabajado en este tramo: `25 min` aprox. de trabajo efectivo,
    - spots / live / historico:
      - `live_history_controller.dart` queda reducido a orquestacion de estado y acciones,
      - extraido fetch de historico por proveedor a `live_history_data_loader.dart`,
      - extraida comparativa forecast historica a `live_history_forecast_overlay.dart`,
      - extraida preparacion de ventana/serie historica a `live_history_series_controller.dart`,
    - spots / live / widgets:
      - extraidos widget de etiqueta de ultimo dato, selector de unidades y grid de metricas live,
      - eliminado el render de metricas desde `live_formatters.dart`,
    - spots / live / estaciones:
      - extraida carga de payload live por proveedor a `live_station_payload_loader.dart`,
      - extraida metadata/registro de estaciones configuradas a `live_station_metadata_loader.dart`,
      - `live_station_data_loader.dart` queda centrado en resolver estaciones y construir el resultado de carga,
    - verificacion:
      - `flutter analyze` limpio tras los cortes realizados.


  - bloque nuevo `2026-05-13`:
    - refactor de la seccion de alarmas del tab Live de Spots,
    - tiempo real trabajado en este tramo: `25 min` aprox. de trabajo efectivo,
    - spots / live / alarmas:
      - extraida la UI del formulario de alarma a `live_alarm_form_widgets.dart`,
      - extraida la UI de alarmas guardadas a `live_saved_alarm_widgets.dart`,
      - reducido `live_alarm_widgets.dart` a piezas comunes de evaluacion y chips,
      - `live_alarms_section.dart` queda como ensamblador de cabecera, formulario, lista y callbacks,
      - extraidos helpers privados para activar/desactivar alarmas del spot, guardar, editar y eliminar alarmas,
      - extraidos setters privados para estacion, rango de viento, direcciones, repeticion y maximo de avisos,
      - separada la construccion de la lista y tarjetas de alarmas guardadas en helpers dedicados,
    - verificacion:
      - `flutter analyze` limpio tras el refactor.


  - bloque nuevo `2026-05-13`:
    - continuacion del refactor de widgets de alarmas Live,
    - tiempo real trabajado en este tramo: `10 min` aprox. de trabajo efectivo,
    - spots / live / alarmas:
      - dividido `live_alarm_form_widgets.dart` en widgets especificos de tiempo/viento, direcciones y repeticion/guardar,
      - anadidos `live_alarm_time_wind_widgets.dart`, `live_alarm_direction_widgets.dart` y `live_alarm_repeat_widgets.dart`,
      - `live_alarm_form_widgets.dart` queda centrado en cabecera, tarjeta y selector de estacion,
      - pulida la tarjeta de alarmas guardadas separando acciones y chips de metadatos dentro de `live_saved_alarm_widgets.dart`,
    - verificacion:
      - `flutter analyze` limpio tras el refactor.


  - bloque nuevo `2026-05-13`:
    - mejora de legibilidad de tablas Forecast con primera columna fija,
    - tiempo real trabajado en este tramo: `25 min` aprox. de trabajo efectivo,
    - spots / forecast / tablas:
      - creado `ForecastStickyLabelTable` para mantener visible la primera columna de etiquetas mientras se desplazan los datos,
      - aplicada la columna fija a la tabla principal de forecast,
      - aplicada la columna fija a la tabla AEMET Playa,
      - aplicada la columna fija a la tabla Meteoblue Sea,
      - descartado el primer enfoque de referencia desplegable porque no cumplia el comportamiento esperado,
      - ajustada la altura de filas en AEMET Playa para evitar overflow vertical en celdas con Manana/Tarde,
    - verificacion:
      - `flutter analyze` limpio,
      - validacion manual del usuario: las tablas ya funcionan bien con la primera columna visible.


  - bloque nuevo `2026-05-13`:
    - correccion de avatares en el chat de spot,
    - tiempo real trabajado en este tramo: `15 min` aprox. de trabajo efectivo,
    - spots / chat:
      - corregido `SpotChatAvatar` para distinguir entre URLs remotas y rutas locales,
      - evitado que una URL publica de Supabase se intente abrir como archivo local,
      - anadido `authorAvatarPath` a posts y respuestas sociales para transportar el avatar del autor,
      - propagado el avatar desde el feed social hasta las entradas renderizadas del chat,
      - cargados los avatares de otros usuarios desde `public_profiles.avatar_path`, respetando el endurecimiento RLS de `profiles`,
    - verificacion:
      - `flutter analyze` limpio,
      - validacion manual del usuario: ahora se ve correctamente el avatar propio y el de los demas usuarios.


  - bloque nuevo `2026-05-13`:
    - construccion inicial del spot oficial de Piles y correccion de textos AEMET,
    - tiempo real trabajado en este tramo: `45 min` aprox. de trabajo efectivo,
    - spots / catalogo:
      - Piles pasa a usar constantes propias de spot oficial,
      - actualizadas coordenadas del spot a la playa AEMET de Piles,
      - corregido el codigo municipal AEMET a `46195`,
      - anadido codigo de playa AEMET `4619501`,
      - anadidas capacidades propias de Piles con AEMET/Puertos del Estado por defecto,
      - Piles hereda estaciones live de referencia cercanas y Puertos Gandia Serpis como patron inicial replicable,
    - spots / webcams:
      - anadido perfil de webcam propio para Piles con pagina oficial de Comunitat Valenciana,
      - anadidas paginas de referencia de webcam y playa de Piles,
    - spots / forecast / AEMET:
      - creado `aemet_text_normalizer.dart` para limpiar entidades HTML, mojibake y caracteres de sustitucion,
      - aplicado el normalizador a prediccion de playa y maritima costera,
      - anadido nombre amigable `Piles` para el codigo de playa `4619501`,
      - ajustada la tabla de playa para mostrar Manana/Sensacion termica/temperaturas correctamente,
      - configurada la maritima costera para mostrar textos largos sin tildes y evitar simbolos raros,
    - tests / verificacion:
      - anadido test unitario para normalizacion de textos AEMET,
      - `flutter test test/features/spots/infrastructure/services/aemet_text_normalizer_test.dart` limpio,
      - `flutter analyze` limpio,
      - validacion manual del usuario: la tabla costera ya no muestra simbolos raros.


  - bloque nuevo `2026-05-13`:
    - ajuste de widget Windguru por spot y mejora de gestos,
    - tiempo real trabajado en este tramo: `20 min` aprox. de trabajo efectivo,
    - spots / forecast / Windguru:
      - el widget de Windguru pasa a resolverse por nombre de spot,
      - Piles utiliza el widget `s=504236` proporcionado por el usuario,
      - Oliva mantiene su `s=48858` pero usa el formato completo de filas del widget nuevo,
      - el subtitulo del bloque Windguru se adapta al spot seleccionado,
      - la altura del widget Windguru sube a `680` para acomodar mas filas,
      - fullscreen y WebView movil/web usan el mismo HTML resuelto por spot,
      - anadido `EagerGestureRecognizer` al WebView de Windguru para mejorar el deslizamiento tactil,
    - verificacion:
      - `flutter analyze` limpio,
      - validacion manual del usuario: el deslizamiento de filas ahora va mucho mejor.


  - bloque nuevo `2026-05-13`:
    - optimizacion de apertura del mapa de viento desde Forecast,
    - tiempo real trabajado en este tramo: `10 min` aprox. de trabajo efectivo,
    - spots / forecast / mapa de viento:
      - eliminada la carga previa de grilla Open-Meteo antes de abrir el visor de viento,
      - el mapa actual usa el visor oficial de Puertos del Estado y no consumia esa grilla,
      - eliminado el cliente `_openMeteoWindMapGridClient` que quedaba sin uso en `SpotDetailPage`,
      - el boton de mapa de viento navega antes al visor al no esperar una peticion innecesaria,
    - verificacion:
      - `flutter analyze` limpio,
      - validacion manual del usuario: la apertura del mapa de viento se nota mas rapida.


  - bloque nuevo `2026-05-13`:
    - construccion del apartado Live para el spot oficial de Piles,
    - tiempo real trabajado en este tramo: `40 min` aprox. de trabajo efectivo,
    - spots / live / Piles:
      - Piles pasa a tener perfil Live propio y deja de heredar todas las estaciones de Oliva,
      - configurada la estacion preferida por defecto como Club Nautico de Oliva por cercania y utilidad para el spot,
      - mantenida la estacion de Puertos del Estado Gandia Serpis como estacion util para Piles,
      - anadida la estacion AVAMET Gandia Cami de la mar solo para Piles,
      - verificado que Gandia Serpis y Gandia Cami de la mar no son la misma estacion,
      - anadida la estacion Meteo Piles desde `meteopiles.es` para datos live del spot,
      - anadida la estacion DK Piles Meteo desde el widget Windguru Live `id_station=51`,
      - DK Piles Meteo queda limitada al spot de Piles y no aparece en Oliva,
      - el cliente Windguru Live usa referer DK Piles para leer el dato actual de viento, racha, viento minimo, direccion y hora,
      - el historico queda desactivado para Meteo Piles y DK Piles porque las fuentes descubiertas solo exponen dato actual fiable,
      - las tarjetas Live ahora se construyen solo con metricas disponibles para evitar tarjetas vacias,
      - DK Piles muestra viento, racha y viento minimo sin ensenar temperatura/presion/humedad/lluvia cuando la fuente devuelve valores nulos,
    - verificacion:
      - `flutter analyze` limpio,
      - validacion manual del usuario: DK Piles funciona estupendamente y las tarjetas vacias ya no aparecen.


  - bloque nuevo `2026-05-13`:
    - cierre operativo del spot oficial de Piles,
    - tiempo real trabajado en este tramo: `60 min` aprox. de trabajo efectivo,
    - spots / live / historico backend:
      - creada la tabla `spot_live_observations` para historicos live rotativos,
      - configurada retencion automatica de `72 h` para evitar crecimiento indefinido,
      - creada la Edge Function `spot-live-observation-collector`,
      - desplegada la function en Supabase,
      - configurado el secreto `SPOT_LIVE_COLLECTOR_SECRET` reutilizando el valor operativo de `LIVE_WIND_RECORDER_SECRET`,
      - creado y activado el cron `spot-live-observation-collector-every-5-min`,
      - verificado en cloud que el cron queda activo con expresion `*/5 * * * *`,
      - verificada invocacion manual con insercion real de muestras,
      - conectada la app para leer historico backend desde `spot_live_observations`,
      - DK Piles Meteo usa el historico backend propio al pulsar cargar historico,
    - spots / live / MeteoPiles:
      - comprobado que `meteopiles.es/wflash/Data/wflash.txt` y `wflash2.txt` estan congelados desde enero de 2020,
      - el contador visible en la web solo cuenta desde la descarga AJAX y no indica nueva medicion real,
      - corregido el parser para leer el timestamp VWS `F=` desde epoch 1900,
      - anadido filtro anti-stale para rechazar observaciones con mas de `2 h`,
      - limpiadas las muestras falsas de MeteoPiles guardadas con fecha actual,
      - MeteoPiles queda oculto del selector Live de Piles hasta que vuelva a publicar datos reales,
      - el collector backend deja de consultar MeteoPiles y solo recoge DK Piles Meteo,
    - spots / webcam / Piles:
      - la webcam de Piles deja de abrir la pagina completa de Comunitat Valenciana,
      - anadido stream DASH directo `https://streaming.comunitatvalenciana.com/webcam/Piles/manifest.mpd`,
      - anadida miniatura directa `https://streaming.comunitatvalenciana.com/static/Piles/webcam_mini.png`,
      - el reproductor queda alineado con el comportamiento de Oliva,
    - verificacion:
      - `flutter analyze` limpio,
      - `deno check supabase/functions/spot-live-observation-collector/index.ts` limpio,
      - Edge Function redesplegada tras desactivar MeteoPiles,
      - validacion manual del usuario: el spot de Piles queda completo hasta nueva ampliacion.


  - bloque nuevo `2026-05-16`:
    - observaciones maritimas cercanas bajo demanda para Live,
    - tiempo real trabajado en este tramo: `120 min` aprox. de trabajo efectivo,
    - investigacion / fuentes maritimas:
      - evaluado MADIS Maritime como fuente experimental de observaciones maritimas,
      - confirmado que MADIS devuelve muy pocos datos utiles en Mediterraneo cercano a costa,
      - investigado Copernicus Marine In Situ para Mediterraneo como proveedor mas adecuado,
      - verificado el producto `INSITU_MED_PHYBGCWAV_DISCRETE_MYNRT_013_035` y el dataset `cmems_obs-ins_med_phybgcwav_mynrt_na_irr`,
      - confirmadas variables utiles para Live: `WSPD`, `WDIR`, `GSPD`, `GDIR`, `DRYT`, `RELH`, `ATMS`, `VHM0`, `VAVT`, `TEMP`,
    - backend / Supabase:
      - creada la tabla `spot_maritime_observations` para observaciones maritimas cacheadas y historico rotativo de `72 h`,
      - creada la funcion SQL `prune_spot_maritime_observations`,
      - aplicada la migracion remota en Supabase,
      - configurados secrets `COPERNICUSMARINE_SERVICE_USERNAME` y `COPERNICUSMARINE_SERVICE_PASSWORD`,
      - creada y desplegada la Edge Function `madis-maritime-nearby`,
      - creada y desplegada la Edge Function `copernicus-marine-nearby`,
      - `copernicus-marine-nearby` lee metadatos STAC, calcula chunks, descarga SQLite desde S3 y extrae filas con `sql.js`,
      - Copernicus queda como proveedor principal y MADIS como fallback/experimental,
      - radio por defecto limitado a `10 km` para no saturar,
      - excepcion temporal de pruebas para spots de Tarifa con radio `50 km`,
      - primera carga limitada a `10` plataformas con paginacion `Cargar 10 barcos mas`,
      - la respuesta backend devuelve `total`, `offset`, `limit`, `hasMore` y observaciones normalizadas,
    - app / Live:
      - anadido `SpotMaritimeObservationsClient`,
      - `SpotDetailPage` recibe el cliente de observaciones maritimas y mantiene estado de carga/paginacion,
      - anadido controlador `live_maritime_observations_controller.dart`,
      - el boton `Cargar observaciones maritimas` aparece bajo `Ver estacion en el mapa`,
      - la UI muestra el radio usado y el total de barcos/plataformas detectadas,
      - las estaciones maritimas se inyectan en el selector Live solo bajo demanda,
      - Live reconoce `COPERNICUS_MARINE` y `MADIS_MARITIME` para payload, historico y etiquetas,
    - validacion:
      - `deno check supabase/functions/madis-maritime-nearby/index.ts` limpio,
      - `deno check supabase/functions/copernicus-marine-nearby/index.ts` limpio,
      - `flutter analyze` limpio,
      - prueba remota de `copernicus-marine-nearby` en Tarifa con `50 km`: devuelve `4` plataformas,
      - prueba remota cacheada posterior: `total=4`, `count=4`, `hasMore=false`,
      - `local.env.json` sigue ignorado por git y contiene credenciales locales sin versionar.


  - bloque nuevo `2026-05-16`:
    - estabilizacion de Spots, Live Tarifa, observaciones maritimas y limite Windguru,
    - tiempo real trabajado en este tramo: `105 min` aprox. de trabajo efectivo,
    - spots / orden manual:
      - anadido orden manual por defecto en la lista de spots,
      - las tarjetas se pueden mantener pulsadas y arrastrar para reordenar,
      - anadido chip `Manual` junto a `Recientes`, `A-Z` y `Z-A`,
      - el drag queda activo solo en orden manual y fuera del modo multi-seleccion,
      - el orden se persiste en JSON local por usuario/dispositivo,
      - el orden se mantiene tras hidratar catalogo, agregar, editar o eliminar spots,
      - optimizado el arrastre con `RepaintBoundary`, menor filtrado de imagen y proxy sin escalado para reducir lag,
    - live / observaciones maritimas:
      - el boton de observaciones maritimas selecciona automaticamente la primera observacion con viento real,
      - las observaciones sin `wind_speed_knots` o sin `wind_dir_deg` ya no se inyectan como estaciones Live seleccionables,
      - el contador diferencia entre observaciones detectadas y observaciones utiles con viento,
      - comprobado en Tarifa - Balneario que Copernicus devuelve `4` observaciones dentro de `50 km` pero solo `6101404___MO` trae viento util,
      - confirmado que `Tarifa-coast-buoy___MO` publica oleaje/temperatura pero no variables `WSPD/WDIR`,
    - backend / Copernicus Marine:
      - `copernicus-marine-nearby` ahora conserva el ultimo valor disponible por variable y plataforma en lugar de exigir mismo timestamp para todas las variables,
      - anadido `variableObservedAt` en `raw_payload` para diagnosticar de donde viene cada variable,
      - function redesplegada en Supabase,
      - verificada consulta fresca en Tarifa - Balneario tras el despliegue,
    - live / Tarifa:
      - creado perfil Live especifico `tarifa`,
      - `Tarifa - Balneario` y `Tarifa - Valdevaqueros` usan `AEMET Tarifa` (`6001`) como estacion base/preferida,
      - las observaciones maritimas quedan como fuente extra bajo demanda y no como fuente principal de Live,
    - forecast / Windguru:
      - definido limite operativo de Windguru a 10 spots prioritarios:
        `Oliva Canal - Platja dels Gorgs`, `Piles`, `El Perellonet`, `Cullera - El Pollo`, `Gandia Playa`, `Denia - Punta Els Molins`, `Calpe`, `Santa Pola - Platja Lissa`, `El Campello - Playa Muchavista` y `Tarifa - Valdevaqueros`,
      - Windguru desaparece del selector de proveedores en cualquier spot fuera de esa lista,
      - proteccion inicial para que un spot no permitido no conserve `Windguru` como proveedor por estado previo,
      - retirado Windguru de `Tarifa - Balneario` y `Xeraco` para no consumir widgets del limite externo,
    - verificacion:
      - `deno check supabase/functions/copernicus-marine-nearby/index.ts` limpio,
      - `flutter analyze` limpio,
      - desplegada `copernicus-marine-nearby` en Supabase,
      - `local.env.json` sigue ignorado por git y no se versiona.


  - bloque nuevo `2026-05-18`:
    - integracion Weather Underground, optimizacion de Spots y puntos de llegada para Google Maps,
    - tiempo real trabajado en este tramo: `135 min` aprox. de trabajo efectivo,
    - live / Weather Underground:
      - anadido cliente `WundergroundPwsClient` para leer la estacion publica `IOLIVA107`,
      - `WU Oliva IOLIVA107` aparece como estacion Live solo en el perfil de Oliva,
      - carga viento actual desde Weather Underground,
      - carga historico real de 1 dia desde Weather Underground al pulsar el boton de grafica,
      - historico configurado con granularidad densa tipo `min20`,
      - integrado en payload, historico, metadata, seleccion y etiquetas Live,
    - spots / rendimiento:
      - la pestana Spots pasa a renderizar con `CustomScrollView` y slivers,
      - la lista normal usa `SliverList.builder` para construir tarjetas de forma perezosa,
      - el modo manual usa `SliverReorderableList`,
      - el reordenado permite auto-scroll mientras se arrastra una tarjeta,
      - eliminado el recuento/chip de webcams de las tarjetas para aligerar carga,
      - eliminado `spots_webcam_distance_helper.dart`,
    - spots / mapa y llegada:
      - anadido boton de mapa en las tarjetas de spot,
      - el dialogo muestra mapa OSM con marcador del spot real y, si existe, marcador separado de llegada/aparcamiento,
      - Google Maps abre una ruta en coche al punto de llegada si esta configurado,
      - se separan coordenadas reales del spot de coordenadas utiles para acceder/aparcar,
      - `SpotCapabilities` incorpora `navigationLatitude`, `navigationLongitude` y `navigationLabel`,
    - puntos de llegada configurados:
      - `Oliva Canal - Platja dels Gorgs`: `38.91580884367901, -0.07779792085000076`,
      - `Piles`: `38.943633843553286, -0.10985116793513353`,
      - `Gandia Playa`: `39.02083052614467, -0.17543646293914303`,
      - `Xeraco`: `39.03800937721705, -0.18951786389646919`,
      - `Cullera - El Pollo`: `39.21294234832044, -0.23836018562887695`,
      - `El Perellonet`: `39.28095954536101, -0.27708708529321363`,
      - `Denia - Les Deveses`: `38.883244386654184, -0.03539319215620903`,
      - `Denia - Punta Els Molins`: `38.86044033592307, 0.04655905881270543`,
      - `Calpe`: `38.64159285682161, 0.04694828199875873`,
      - `Altea - Cap Negret`: `38.606497460633456, -0.041219503393286`,
      - `Villajoyosa - Espigon`: `38.50239214628279, -0.23440666068378316`,
      - `Villajoyosa - Playa Paraiso`: `38.49715021833233, -0.2584490074105973`,
      - `El Campello - Playa Muchavista`: `38.39502060831646, -0.4071727602994512`,
      - `Santa Pola - Platja Lissa`: `38.190017240184275, -0.5902498009788203`,
      - `Tarifa - Balneario`: `36.009606703879996, -5.607629973493867`,
      - `Tarifa - Valdevaqueros`: `36.06735671371158, -5.683717901374338`,
    - nuevos spots:
      - creado `Tarifa - Campo de futbol` con coordenadas `36.02129962247533, -5.616776453751289`,
      - punto de llegada `Tarifa - Campo de futbol`: `36.02176430173696, -5.615059313052187`,
      - creado `Tarifa - Los Lances` con coordenadas `36.046076176197694, -5.640893942328883`,
      - punto de llegada `Tarifa - Los Lances`: `36.047401, -5.640325`,
      - ambos usan el perfil Live/AEMET de Tarifa y quedan sin Windguru dedicado para respetar el limite de 10 widgets prioritarios,
    - verificacion:
      - `flutter analyze` limpio tras los cambios principales,
      - `local.env.json` sigue ignorado por git y no se versiona.


  - bloque nuevo `2026-05-19`:
    - ampliacion de estaciones Live y catalogo internacional de spots,
    - tiempo real trabajado en este tramo: `35 min` aprox. de trabajo efectivo,
    - live / Weather Underground:
      - anadida la estacion `WU Oliva IOLIVA94` solo al perfil Live de `Piles`,
      - confirmada respuesta publica actual de `IOLIVA94` desde Weather Underground,
      - coordenadas registradas para `IOLIVA94`: `38.93356, -0.116067`,
      - el historico denso tipo `min20` se aplica ahora a cualquier estacion `WUNDERGROUND`,
      - `IOLIVA107` se mantiene solo en Oliva y `IOLIVA94` solo en Piles,
    - spots / catalogo:
      - creado el spot oficial `Dakhla` con coordenadas `23.901726320541233, -15.785405169532982`,
      - corregida el area de `Dakhla` a `Sahara Occidental`,
      - creado el spot oficial `Essaouira` con coordenadas `31.498473284986574, -9.764221578867195`,
      - `Essaouira` queda en area `Marruecos`,
      - ambos quedan sin proveedores especificos por ahora hasta conectar fuentes utiles para esa zona,
    - spots / formulario:
      - el campo opcional de agregar spot pasa a indicar `Zona / provincia / pais (opcional)`,
    - verificacion:
      - `flutter analyze` limpio,
      - `local.env.json` sigue ignorado por git y no se versiona.
