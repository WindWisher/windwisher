# WindWisher Data Sources Inventory

Fecha: `2026-04-25`

Estado: inventario inicial basado en codigo, pendiente de revision legal/licencias

Objetivo:
- inventariar fuentes reales de datos, proveedores e integraciones,
- saber que debe aparecer en `Politica de privacidad`, `Fuentes de datos y licencias` y `Descargo de meteo y seguridad`,
- y evitar usar datos meteorologicos o mapas sin revisar atribucion/licencia.

Nota:
- este documento es operativo, no texto legal para usuario final,
- debe actualizarse cada vez que se anada una nueva fuente o proveedor.

## 1. Infraestructura y backend

Detectado en codigo:

- Autenticacion: `Supabase Auth`
- Base de datos: `Supabase Postgres`
- Storage/media: `Supabase Storage`
- Edge Functions: `Supabase Edge Functions`
- Push notifications: `Firebase Cloud Messaging`
- Local notifications: `flutter_local_notifications`
- Hosting/web: `PENDIENTE de despliegue final`
- Analytics/crash reporting: `No detectado como integracion explicita`

Evidencia en repo:
- `lib/main.dart`
- `lib/firebase_options.dart`
- `lib/core/notifications/firebase_push_messaging_service.dart`
- `lib/core/notifications/push_notification_subscription_service.dart`
- `lib/features/auth/infrastructure/adapters/supabase/supabase_auth_session_adapter.dart`
- `supabase/config.toml`

Datos personales potenciales:
- cuenta,
- email,
- perfil,
- sesiones,
- mensajes,
- media,
- notificaciones,
- logs tecnicos.

## 2. Mapas y geolocalizacion

Detectado en codigo:

- Proveedor de mapas/tiles principal en spots: `OpenStreetMap tile server`
- Proveedor de mapas/tiles en mapa de viento: `CARTO basemaps`
- Geocoding/reverse geocoding: `PENDIENTE`
- Ubicacion del dispositivo: `geolocator`
- Compass/orientacion: `flutter_compass`
- Condiciones de licencia/atribucion: `PENDIENTE de revisar y mostrar donde corresponda`

URLs detectadas:
- `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- `https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}{r}.png`

Evidencia en repo:
- `lib/features/spots/presentation/pages/spots_page.dart`
- `lib/features/spots/presentation/pages/spot_detail_page.dart`
- `lib/features/spots/presentation/pages/wind_map_page.dart`

Riesgos legales/producto:
- ubicacion puede ser dato personal,
- sesiones y spots pueden revelar habitos o lugares frecuentes,
- mapas suelen exigir atribucion visible.

## 3. Meteorologia y condiciones

Detectado en codigo:

- AEMET OpenData: `municipal, playa, maritima costera, observacion convencional`
- AVAMET: `observacion, historico intradia, historico diario`
- Open-Meteo: `forecast y marine grid para mapa de viento`
- Meteoblue: `forecast package`
- Meteosource: `point forecast`
- Meteostat via RapidAPI: `hourly/daily point data`
- Windguru: `widget/embed en WebView/iframe`
- Inforatge: `estaciones Oliva/Oliva Nova`
- Aigua Blanca / Feedket: `endpoint meteo`
- Webcams Comunitat Valenciana: `streaming y thumbnails`
- estaciones propias o comunitarias: `PENDIENTE`

Para cada fuente hay que anotar:
- URL/documentacion,
- tipo de dato,
- licencia o condiciones,
- atribucion obligatoria,
- limites de cache,
- limites de redistribucion,
- disponibilidad/API keys,
- si es fuente oficial o no oficial.

Enlaces legales/documentacion inicial:
- AEMET datos abiertos: `https://www.aemet.es/es/datos_abiertos`
- AEMET OpenData: `https://opendata.aemet.es/centrodedescargas/AEMETApi`
- Open-Meteo terms: `https://openmeteo.org/terms/`
- Meteoblue terms: `https://content.meteoblue.com/en/about-us/legal/terms-conditions`
- Meteoblue API docs: `https://docs.meteoblue.com/en/weather-apis/introduction/overview`
- Meteosource terms: `https://www.meteosource.com/terms-of-service`
- Meteosource API docs: `https://public-web.meteosource.com/documentation`
- Meteostat privacy/API note: `https://meteostat.net/en/privacy`
- Meteostat API docs: `https://dev.meteostat.net/api`
- Comunitat Valenciana webcams: `https://www.comunitatvalenciana.com/en/webcams`
- Comunitat Valenciana disclaimer: `https://www.comunitatvalenciana.com/en/disclaimer`

URLs/endpoints detectados:
- AEMET OpenData: `https://opendata.aemet.es/opendata/api/...`
- Open-Meteo Forecast: `https://api.open-meteo.com/v1/forecast`
- Open-Meteo Marine: `https://marine-api.open-meteo.com/v1/marine`
- Meteoblue: `https://my.meteoblue.com/packages/...`
- Meteosource: `https://www.meteosource.com/api/v1/free/point`
- Meteostat/RapidAPI: `https://meteostat.p.rapidapi.com/...`
- AVAMET: `https://www.avamet.org/...`
- Inforatge: `https://inforatge.com/meteo-oliva-02`, `https://inforatge.com/meteo-oliva`
- Aigua Blanca / Feedket: `https://meteo.feedket.com/api/endpoints`
- Windguru base embed: `https://www.windguru.cz`
- Webcams Comunitat Valenciana: `https://streaming.comunitatvalenciana.com/...`

Evidencia en repo:
- `lib/features/spots/infrastructure/services/*`
- `lib/features/spots/infrastructure/adapters/*`
- `lib/features/spots/presentation/pages/spot_detail_page.dart`
- `lib/features/spots/presentation/pages/webcam_player_page.dart`
- `lib/features/spots/infrastructure/data/spot_webcam_catalog.dart`
- `lib/features/spots/presentation/widgets/windguru_forecast_card.dart`
- `lib/features/spots/presentation/widgets/windguru_web_embed_web.dart`

Punto importante:
- varias fuentes se consumen directamente o mediante `SupabaseForecastProxyClient`, por lo que la app puede estar actuando como cliente directo y como proxy tecnico segun configuracion.

## 4. Comunidad y contenido de usuario

Datos generados por usuarios:

- perfiles,
- handles,
- seguidores/seguidos,
- comentarios,
- likes,
- mensajes,
- sesiones compartidas,
- fotos/media,
- spots creados o editados,
- rankings/leaderboards.

Pendiente:
- definir reportes/moderacion,
- definir retencion de mensajes,
- definir tratamiento de contenido al borrar cuenta,
- definir visibilidad publica/privada por tipo de dato.

Evidencia en repo:
- `lib/features/community/infrastructure/adapters/supabase/*`
- `lib/features/profile/infrastructure/adapters/supabase/*`
- `supabase/migrations/*community*`
- `supabase/migrations/*profiles*`

## 5. Sesiones, sensores y dispositivos

Datos potenciales:

- GPS/ruta,
- velocidad,
- altura/saltos,
- hangtime,
- metricas tecnicas,
- material usado,
- datos importados de dispositivos,
- telemetria BLE si se integra.

Tecnologias detectadas:
- `geolocator`
- `sensors_plus`
- `flutter_compass`
- `flutter_reactive_ble`
- importacion/registro local y Supabase de sesiones

Pendiente:
- separar datos calculados por WindWisher de datos importados,
- definir si se consideran datos de salud/rendimiento deportivo,
- definir visibilidad por defecto,
- definir retencion tras eliminacion de cuenta.

Evidencia en repo:
- `lib/features/sessions/*`
- `lib/features/sessions/infrastructure/adapters/ble/*`
- `lib/features/sessions/infrastructure/adapters/supabase/*`
- `lib/features/sessions/presentation/logic/*`

## 6. Proveedores que deben aparecer en privacidad

Lista inicial detectada:

- Supabase: `auth, base de datos, storage, edge functions`
- Firebase/Google: `push notifications / Firebase project`
- Apple/Google Sign-In: `codigo preparado pero desactivado en EnvConfig`
- OpenStreetMap tile server: `map tiles`
- CARTO basemaps: `map tiles`
- AEMET: `meteorologia oficial OpenData`
- AVAMET: `observacion/historico meteo`
- Open-Meteo: `forecast/marine`
- Meteoblue: `forecast`
- Meteosource: `forecast`
- Meteostat/RapidAPI: `historico/forecast puntual`
- Windguru: `embed/widget`
- Inforatge: `estaciones locales`
- Aigua Blanca / Feedket: `endpoint meteo`
- Comunitat Valenciana webcams: `webcams/streaming`
- Stores Apple/Google: `PENDIENTE segun publicacion`
- Herramientas de soporte/diagnostico: `No detectado como integracion explicita`

Enlaces legales iniciales:
- Supabase DPA: `https://supabase.com/downloads/docs/Supabase%2BDPA%2B231211.pdf`
- Firebase privacy/security: `https://firebase.google.com/support/privacy/`
- Firebase data processing terms: `https://firebase.google.com/terms/data-processing-terms`
- OpenStreetMap copyright/license: `https://www.openstreetmap.org/copyright`
- OpenStreetMap tile usage policy: `https://operations.osmfoundation.org/policies/tiles/`
- CARTO basemaps docs: `https://docs.carto.com/faqs/carto-basemaps`

Para cada proveedor:
- rol: encargado, proveedor tecnico, fuente de datos, pasarela, etc.
- datos tratados,
- region,
- transferencia internacional,
- enlace legal,
- necesidad de consentimiento o base juridica.

## 7. Pendientes antes de publicar textos finales

- Confirmar cuales de las fuentes detectadas estaran activas en produccion.
- Confirmar proveedor de mapas y atribucion visible para OpenStreetMap/CARTO.
- Completar enlaces legales y condiciones de cada proveedor.
- Completar lista de encargados/proveedores con rol juridico.
- Completar transferencias internacionales, especialmente Supabase/Firebase/Google/RapidAPI.
- Definir retencion de sesiones, mensajes y media.
- Definir tratamiento de datos al borrar cuenta.
- Decidir si habra politica de cookies por web/analytics.
- Revisar si Windguru iframe/webview y webcams requieren avisos/atribucion adicionales.
