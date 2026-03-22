# Backlog de migracion hexagonal - WindWisher

## Estado global

- [x] Definir blueprint arquitectonico v3.0
- [x] Migrar `profile` a estructura `domain/application/infrastructure/presentation`
- [x] Migrar `auth`
- [x] Migrar `sessions`
- [x] Migrar `spots`
- [x] Migrar `community`
- [x] Revisar `dashboard` como feature liviana

## Plan por feature

### 1) profile (piloto)

- [x] Mover use cases de `domain/usecases` a `application/use_cases`
- [x] Renombrar contratos a `ports/out` cuando aplique
- [x] Crear `di/profile_module.dart` con wiring hexagonal explicito
- [x] Reducir `profile_page.dart` a composicion + estado de vista

### 2) auth

- [x] Definir `ports/out` de autenticacion
- [x] Extraer adaptadores (dev/mock/real)
- [x] Reubicar providers para consumir puertos de entrada

### 3) sessions

- [x] Delimitar entidades y puertos de dominio
- [x] Crear casos de uso de lectura/creacion/edicion
- [x] Integrar wiring por modulo

### 4) spots

- [x] Separar modelo de dominio de detalles de mapa/webcam
- [x] Introducir puertos para providers externos
- [x] Aislar adaptadores de datos remotos

### 5) community

- [x] Definir puertos de timeline/mensajes/perfiles
- [x] Mover logica de orquestacion a `application`
- [x] Limpiar dependencias cruzadas con presentation

### 6) dashboard (feature liviana)

- [x] Extraer reglas de toolbar a servicio de `application`
- [x] Mantener dashboard sin puertos/adaptadores mientras no gestione datos propios

## Criterios de avance

- Cada tarea cierra con:
  - `flutter analyze` en verde
  - tests de feature en verde (si existen)
  - nota en `SESSION_TRACKER.md`
