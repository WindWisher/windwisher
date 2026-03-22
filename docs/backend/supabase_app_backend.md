# Supabase App Backend Blueprint

## Objetivo

Montar primero el backend completo de la app antes de seguir migrando clientes Flutter a proveedor remoto.

## Cobertura inicial

La primera migracion de Supabase ya deja base para todas las features principales del repo:

- `auth`
- `profile`
- `sessions`
- `community`
- `spots`

Archivo principal:

- `supabase/migrations/20260315170000_app_backend_bootstrap.sql`
- `supabase/migrations/20260315173000_app_backend_rpcs_and_storage.sql`

## Tablas incluidas

### Auth / Profile

- `profiles`
- `user_gear_setups`

### Spots

- `spots`
- `user_saved_spots`

### Sessions

- `sessions`
- `session_likes`
- `session_comments`

### Community

- `user_follows`
- `community_leaderboard` (view)
- `community_following_feed` (view)

### Messaging

- `direct_threads`
- `direct_thread_participants`
- `direct_messages`

### Storage

- `profile-avatars`
- `profile-banners`
- `session-media`

## Seguridad

La migracion incluye RLS base:

- perfiles publicos legibles
- escritura solo del propietario
- sesiones publicas legibles y privadas solo del propietario
- follows, gear setups y saved spots solo del propietario
- mensajes visibles solo a participantes

La segunda migracion añade:

- RPCs para interacciones comunes
- politicas de storage por usuario

## RPCs incluidas

- `toggle_session_like(uuid)`
- `follow_user(uuid)`
- `unfollow_user(uuid)`
- `add_session_comment(uuid, text)`
- `get_following_feed(integer, integer)`
- `upsert_profile(...)`

## Gobernanza y roles

Migraciones relevantes:

- `supabase/migrations/20260315221000_app_roles_foundation.sql`
- `supabase/migrations/20260315220500_super_admin_role_upgrade.sql`
- `supabase/migrations/20260315220600_super_admin_permissions.sql`
- `supabase/migrations/20260315221500_single_super_admin_and_admin_audit.sql`
- `supabase/migrations/20260315222000_bootstrap_first_super_admin.sql`
- `supabase/migrations/20260315223000_super_admin_audit_rpcs.sql`

Modelo actual:

- `user`
- `moderator`
- `admin`
- `super_admin`

Reglas:

- solo puede existir un `super_admin`
- `super_admin` es quien puede asignar o revocar roles
- las acciones privilegiadas se auditan en `admin_action_audit`
- solo `super_admin` puede leer esa auditoria

RPCs de gobernanza:

- `has_role_at_least(app_role)`
- `assign_user_role(uuid, app_role)`
- `revoke_user_role(uuid, app_role)`
- `bootstrap_first_super_admin()`
- `get_admin_action_audit(limit_count, offset_count)`
- `get_role_directory()`

Bootstrap del primer `super_admin`:

- la RPC `bootstrap_first_super_admin()` solo funciona:
  - si el usuario esta autenticado
  - si todavia no existe ningun `super_admin`
- una vez ejecutada con exito:
  - asigna `super_admin` al usuario autenticado
  - registra la accion en `admin_action_audit`

Panel cliente:

- la app ya expone `Ajustes > Panel admin`
- ese panel consume:
  - `get_role_directory()`
  - `get_admin_action_audit(...)`
- si el usuario no es `super_admin`, el acceso queda restringido

## Storage

Buckets previstos:

- `profile-avatars`
- `profile-banners`
- `session-media`

Politica:

- lectura publica
- escritura solo del propietario usando prefijo de path `user_id/...`

## Criterio de diseño

- Se ha priorizado una base pragmatica y amplia antes que una normalizacion excesiva.
- Hay campos duplicados deliberados como `spot_name`, `gear_setup_name` o labels en perfil para facilitar migracion desde el estado local actual.
- Las vistas de comunidad permiten alimentar leaderboard/feed sin obligar a recalcular todo en Flutter.
- El feed social real de "siguiendo" ya no depende de una vista publica generica: se obtiene via RPC autenticada para respetar `user_follows`.

## Que falta todavia

- integrar Flutter con estas tablas reales
- migrar adaptadores locales a repositorios Supabase
- conectar `forecast-proxy` desde la app
- definir seeds reales para spots base
- endurecer mas RLS y politicas de storage
- añadir migraciones posteriores para constraints/indices extras y RPCs mas especificas de dominio

## Orden recomendado de migracion

1. `auth + profiles`
2. `spots + user_saved_spots`
3. `sessions`
4. `community`
5. `direct messages`
6. `forecast-proxy` y resto de proveedores remotos
