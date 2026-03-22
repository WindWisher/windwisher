# WindWisher

WindWisher es una app Flutter centrada en spots, viento en vivo, historico intradia, webcams, alertas, sesiones y comunidad.

## Stack

- Flutter
- Supabase para auth, datos y backend
- Firebase para FCM

## Arranque local

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

Necesitas un `local.env.json` valido en la raiz del proyecto.

## Web y Hosting

La web se publica en Firebase Hosting.

Para desplegar sin exponer secretos locales:

```bash
./scripts/deploy_firebase_hosting.sh
```

Ese flujo genera `build/web`, reemplaza `build/web/assets/local.env.json` por una version publica y luego despliega.

## Estructura

- [`lib/`](./lib): app Flutter
- [`supabase/`](./supabase): migraciones, functions y SQL manual
- [`docs/backend/`](./docs/backend): notas operativas de backend
- [`SESSION_TRACKER.md`](./SESSION_TRACKER.md): registro de bloques de trabajo

## Notas

- El proyecto nuevo parte de una importacion desde Meteokite y todavia quedan referencias historicas en `docs/` y `SESSION_TRACKER.md`.
- La identidad operativa actual del runtime ya es `WindWisher`.
