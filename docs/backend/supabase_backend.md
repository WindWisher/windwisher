# Supabase Backend Bootstrap

## Objetivo

Sacar del cliente Flutter las API keys de proveedores forecast y centralizarlas en Supabase.

## Proyecto actual

- Supabase project URL:
  - `https://tefbkhwaxlsfxvnleutb.supabase.co`

## Estructura activa

- `supabase/config.toml`
- `supabase/.env.example`
- `supabase/functions/forecast-proxy/index.ts`
- `supabase/functions/_shared/*`

Nota:
- El experimento de historico `WindWisher` para AEMET Oliva se ha retirado del repo y del despliegue por no aportar una fuente mas granular que la observacion horaria publicada por AEMET.

## Alcance actual

La Edge Function `forecast-proxy` cubre los proveedores con claves sensibles que usa `spots`:

- AEMET
  - `aemet-municipal-forecast`
  - `aemet-beach-forecast`
  - `aemet-coastal-forecast`
  - `aemet-station-observation`
  - `aemet-observations-latest`
- Meteoblue
  - `meteoblue-forecast-package`
- Meteosource
  - `meteosource-point-forecast`
- Meteostat
  - `meteostat-point-hourly`
  - `meteostat-point-daily`

## Requisitos locales

1. Instalar Supabase CLI.
2. Copiar `supabase/.env.example` a un archivo de secretos local o cargar secretos en Supabase.
3. Definir al menos:

```bash
supabase secrets set AEMET_OPENDATA_API_KEY=tu_clave
```

Para cubrir todos los proveedores protegidos del proxy:

```bash
supabase secrets set \
  AEMET_OPENDATA_API_KEY=tu_clave_aemet \
  METEOBLUE_API_KEY=tu_clave_meteoblue \
  METEOSOURCE_API_KEY=tu_clave_meteosource \
  METEOSTAT_API_KEY=tu_clave_meteostat \
  METEOSTAT_API_HOST=meteostat.p.rapidapi.com
```

## Que archivo usa cada parte

- `local.env.json` en la raiz del proyecto:
  - lo usa Flutter
  - se carga desde `lib/core/config/env/local_env_store.dart`
  - aqui van los valores que necesita la app cliente para arrancar
  - ejemplo: `SUPABASE_URL`, `SUPABASE_ANON_KEY`

- `supabase/.env` o `supabase secrets set ...`:
  - lo usa el backend de Supabase y las Edge Functions
  - Flutter no lee este archivo
  - aqui deben vivir las claves de servidor de proveedores externos

- `supabase/.env.example`:
  - es solo plantilla
  - no debe contener secretos reales
  - sirve para recordar que variables necesita el backend

## Desarrollo local

```bash
supabase start
supabase functions serve forecast-proxy --env-file supabase/.env
```

## Secuencia recomendada

```bash
supabase login
supabase link --project-ref tefbkhwaxlsfxvnleutb
supabase db push
supabase functions deploy forecast-proxy
```

## Invocacion de ejemplo

### AEMET playa

```bash
curl -i \
  -X POST 'http://127.0.0.1:54321/functions/v1/forecast-proxy' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "aemet-beach-forecast",
    "beachCode": "4618102"
  }'
```

### AEMET costera

```bash
curl -i \
  -X POST 'http://127.0.0.1:54321/functions/v1/forecast-proxy' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "aemet-coastal-forecast",
    "coastalCode": "41"
  }'
```

### AEMET observacion de estacion

```bash
curl -i \
  -X POST 'http://127.0.0.1:54321/functions/v1/forecast-proxy' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "aemet-station-observation",
    "stationId": "8416Y"
  }'
```
