# WindWisher

WindWisher es una app Flutter centrada en spots, viento en vivo, historico intradia, webcams y alertas.

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

## Estructura

- [`lib/`](./lib): app Flutter
- [`supabase/`](./supabase): migraciones, functions y SQL manual
- [`docs/backend/`](./docs/backend): notas operativas de backend
- [`SESSION_TRACKER.md`](./SESSION_TRACKER.md): registro de bloques de trabajo

## Notas

- El proyecto nuevo parte de una importacion desde Meteokite y todavia quedan referencias historicas en `docs/` y `SESSION_TRACKER.md`.
- La identidad operativa actual del runtime ya es `WindWisher`.
