# WindWisher Legal Map ES

Fecha: `2026-04-25`

Estado: borrador de trabajo interno

Objetivo:
- traducir el producto real de WindWisher a un mapa legal utilizable,
- alinear el apartado `Informacion legal` de la app con marco espanol,
- y evitar que los textos de `assets/legal/` sigan siendo solo scaffolding provisional.

Nota:
- este documento no sustituye asesoramiento juridico profesional,
- pero si fija una base de trabajo mucho mas solida para producto, contenido y compliance.

## 1. Punto de partida

Hoy en la app ya existen seis piezas legales visibles:
- `Terminos y condiciones`
- `Politica de privacidad`
- `Aviso legal`
- `Descargo de meteo y seguridad`
- `Normas de comunidad y rankings`
- `Fuentes de datos y licencias`

Archivos actuales:
- [assets/legal/terms_and_conditions_2026_05_draft_1.json](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/assets/legal/terms_and_conditions_2026_05_draft_1.json:1)
- [assets/legal/privacy_policy_2026_05_draft_1.json](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/assets/legal/privacy_policy_2026_05_draft_1.json:1)
- [assets/legal/legal_notice_2026_05_draft_1.json](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/assets/legal/legal_notice_2026_05_draft_1.json:1)
- [assets/legal/weather_safety_disclaimer_2026_04_draft_1.json](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/assets/legal/weather_safety_disclaimer_2026_04_draft_1.json:1)
- [assets/legal/community_guidelines_2026_05_draft_1.json](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/assets/legal/community_guidelines_2026_05_draft_1.json:1)
- [assets/legal/data_sources_licenses_2026_05_draft_1.json](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/assets/legal/data_sources_licenses_2026_05_draft_1.json:1)

Estado actual:
- el contenido ya esta bastante mas alineado con el producto real,
- se sigue tratando como borrador pendiente de revision juridica,
- y `Terminos y condiciones` es el unico documento con aceptacion obligatoria.

Implementacion de aceptacion:
- [lib/features/auth/presentation/onboarding/terms_acceptance_gate.dart](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/lib/features/auth/presentation/onboarding/terms_acceptance_gate.dart:1)
- [lib/features/auth/presentation/onboarding/legal_document_dialog_shell.dart](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/lib/features/auth/presentation/onboarding/legal_document_dialog_shell.dart:1)

Regla aplicada:
- ninguna ruta privada principal debe renderizar si el usuario autenticado no tiene aceptada en backend la version vigente de terminos,
- el boton de aceptacion queda desactivado hasta hacer scroll al final del documento,
- la aceptacion se guarda en `profiles.accepted_terms_version` y `profiles.accepted_terms_at`,
- si el usuario cancela, se cierra sesion y vuelve a login.

## 2. Que hace realmente WindWisher y por que importa legalmente

WindWisher no es solo una app meteo. La app ya mezcla o proyecta mezclar:
- autenticacion y cuenta de usuario,
- perfil publico y privado,
- sesiones deportivas,
- geolocalizacion y rutas,
- rankings / leaderboards,
- comunidad: follows, likes, comentarios, mensajes,
- fotos y contenido generado por usuario,
- notificaciones,
- posibles datos de sensores/dispositivos conectados,
- datos meteorologicos de terceros,
- decisiones de uso en agua con implicaciones de seguridad.

Eso obliga a separar bien varias capas legales:
- uso del servicio,
- privacidad y proteccion de datos,
- aviso legal e identidad del responsable,
- comunidad y contenido de usuario,
- descargo de meteo y seguridad,
- fuentes/licencias de datos,
- y cookies si aplica a web.

## 3. Referencias de producto revisadas

Estas referencias no sustituyen legislacion, pero si muestran como resuelven el problema apps muy parecidas:

### WOO Sports
- Terminos:
  - https://www.woosports.com/en/us/terms-and-conditions
- Privacidad:
  - https://www.woosports.com/en/privacy-policy

Puntos utiles:
- cubre sensor data, performance data y location,
- cubre perfiles/sesiones publicas y competiciones,
- trata account deletion y menores,
- une bien hardware + app + comunidad.

### Surfr
- Privacidad:
  - https://www.thesurfr.app/privacy/

Puntos utiles:
- muy pegado al producto real,
- detalla visibilidad de perfil, live location y leaderboards,
- explica permisos del dispositivo y controles de privacidad en app,
- es probablemente la referencia de tono/producto mas cercana para WindWisher.

### Windy
- Terminos generales:
  - https://account.windy.com/agreements/windy-terms-of-use
- Privacidad:
  - https://account.windy.com/agreements/privacy-policy
- Estructura completa de acuerdos:
  - https://account.windy.com/agreements/terms-and-conditions

Puntos utiles:
- separa terminos generales de condiciones especificas por servicio,
- buena referencia si en el futuro WindWisher acaba teniendo modulos mas diferenciados.

### AEMET
- Nota legal:
  - https://www.aemet.es/es/nota_legal
- Politica de cookies:
  - https://www.aemet.es/es/politica_cookies
- Privacidad de la app:
  - https://www.aemet.es/es/app/eltiempodeAEMET/politica_privacidad_app

Puntos utiles:
- buen benchmark para la parte meteorologica,
- muy clara en descargo de fiabilidad y responsabilidad,
- explicita si la ubicacion se procesa solo en dispositivo o no.

### AVAMET
- superficie legal visible:
  - https://www.avamet.org/avapred_in.php
  - https://www.avamet.org/mxo-mxo.php?territori=c07

Puntos utiles:
- deja visibles `Avís legal`, `Politica de privacitat` y `Politica de cookies`,
- insiste en provisionalidad/no oficialidad de datos,
- da buena referencia para licencias de contenido y advertencias sobre datos meteo no oficiales.

### Windguru
- home con superficies legales persistentes:
  - https://www.windguru.cz/

Punto util:
- aunque no he podido leer bien sus textos con este navegador, si deja claro que `Terms` y `Privacy` deben estar siempre accesibles.

## 4. Base normativa espanola recomendada

Aqui es donde entra bien `legalize-es`.

Repositorio:
- https://github.com/legalize-dev/legalize-es

Para nosotros sirve como:
- base de consulta normativa,
- referencia versionada,
- repositorio tecnico-juridico para revisar articulos concretos y no redactar a ciegas.

No sirve como:
- politica de privacidad final,
- terminos finales,
- o aviso legal listo para pegar.

Normas base a revisar con prioridad:

### Proteccion de datos
- RGPD:
  - https://www.boe.es/buscar/doc.php?id=DOUE-L-2016-80807
- LOPDGDD:
  - https://www.boe.es/buscar/act.php?id=BOE-A-2018-16673

Aplican de lleno por:
- cuenta,
- perfil,
- geolocalizacion,
- sesiones,
- mensajes,
- notificaciones,
- media subida por usuario,
- y potencial telemetria/sensores.

### Servicios digitales / informacion legal
- LSSI-CE:
  - https://www.boe.es/buscar/act.php?id=BOE-A-2002-13758

Importa especialmente por:
- informacion identificativa del prestador,
- comunicaciones electronicas,
- web/cookies,
- servicios de la sociedad de la informacion.

### Consumo y condiciones de servicio
- Ley General para la Defensa de los Consumidores y Usuarios:
  - https://www.boe.es/buscar/pdf/2007/BOE-A-2007-20555-consolidado.pdf

Importa sobre todo si acabais teniendo:
- suscripciones,
- pagos,
- compras in-app,
- funciones premium,
- o cualquier contrato B2C mas claro.

## 5. Documentos que deberiamos tener

### A. Terminos de uso
Debe cubrir:
- acceso y creacion de cuenta,
- reglas de uso del servicio,
- contenido del usuario,
- conducta prohibida,
- perfiles y sesiones publicas,
- leaderboards y competiciones si aplica,
- suspension/cierre de cuenta,
- limitacion de responsabilidad,
- ley aplicable y contacto.

### B. Politica de privacidad
Debe cubrir:
- categorias de datos tratadas,
- finalidades,
- bases juridicas,
- destinatarios/encargados,
- transferencias internacionales si existen,
- plazos de conservacion,
- derechos del usuario,
- contacto de privacidad,
- tratamiento de ubicacion, sesiones, mensajes, media y notificaciones,
- y si hay menores o no.

### C. Aviso legal
Debe cubrir:
- identidad del responsable,
- NIF/razon social o forma juridica real,
- email de contacto,
- propiedad intelectual,
- condiciones generales de acceso,
- limitaciones de responsabilidad sobre contenidos y disponibilidad.

### D. Politica de cookies
Solo necesaria de forma fuerte si:
- la web o landings usan cookies reales,
- analytics web,
- banners,
- embeds, etc.

Para app movil pura no tiene por que ser la primera prioridad.

### E. Normas de comunidad / contenido / leaderboards
Muy recomendable como pieza separada o seccion fuerte dentro de terminos.
Debe cubrir:
- contenido permitido/prohibido,
- comentarios y mensajes,
- reportes/moderacion,
- perfiles publicos,
- rankings y fair play,
- fraude/manipulacion de sesiones o resultados.

### F. Descargo meteo y seguridad
Esto es critico en WindWisher.
Debe cubrir:
- informacion meteo de apoyo, no garantia,
- posible retraso, error, indisponibilidad o provisionalidad,
- no sustituye juicio del usuario ni avisos oficiales,
- el usuario decide bajo su propia responsabilidad en el agua,
- fuentes externas pueden cambiar o fallar.

### G. Fuentes de datos y licencias
Debe cubrir:
- origen de datos meteorologicos,
- atribuciones exigidas,
- limites de reutilizacion,
- contenido de terceros,
- webcams/mapas si aplica.

## 6. Gap actual entre lo que tenemos y lo que necesitamos

### Terminos actuales
Hoy:
- ya cubren cuenta, sesiones, comunidad, rankings, contenido de usuario,
- ya incluyen conducta prohibida, manipulacion de rankings y limitacion funcional,
- ya conectan con seguridad en el agua y datos estimados,
- siguen pendientes de revision juridica final, identidad del responsable y redaccion contractual definitiva.

### Privacidad actual
Hoy:
- cubre cuenta, perfil, preferencias, material, sesiones, ubicacion, mensajes, comentarios, likes, follows, media y notificaciones,
- ya menciona proveedores externos, finalidades, derechos y conservacion,
- sigue pendiente de completar con:
  - responsable definitivo,
  - bases juridicas concretas,
  - encargados reales,
  - transferencias internacionales si existen,
  - plazos de conservacion exactos,
  - contacto de privacidad.

### Aviso legal actual
Hoy:
- ya cubre naturaleza del servicio, disponibilidad, contenido de terceros, propiedad intelectual y limitaciones generales,
- sigue pendiente de completar con:
  - identidad del responsable,
  - datos mercantiles/fiscales si aplican,
  - email juridico,
  - domicilio o canal formal,
  - ley aplicable y cualquier dato exigible por LSSI.

### Descargo meteo y seguridad actual
Hoy:
- ya existe como documento propio,
- cubre datos orientativos, fuentes externas, errores, retrasos, responsabilidad del usuario y no sustitucion de avisos oficiales,
- es una pieza critica para WindWisher y debe mantenerse visible en `Informacion legal`.

### Normas de comunidad y rankings actuales
Hoy:
- ya existen como documento propio,
- cubren convivencia, contenido de usuario, manipulacion de sesiones, fair play, moderacion y reportes futuros,
- deberian evolucionar junto con herramientas reales de reporte/moderacion.

### Fuentes de datos y licencias actuales
Hoy:
- ya existe como documento propio,
- cubre proveedores, atribucion, limites de reutilizacion y disponibilidad,
- queda pendiente listar fuentes reales usadas por la app y sus atribuciones obligatorias.

## 7. Recomendacion operativa

Orden de trabajo recomendado:

1. Completar identidad legal del responsable
- nombre/razon social,
- NIF/CIF si aplica,
- contacto juridico y privacidad,
- domicilio o canal formal exigible.

2. Revisar juridicamente los seis documentos actuales
- especialmente privacidad, terminos y aviso legal.

3. Completar privacidad con datos reales de tratamiento
- proveedores,
- bases juridicas,
- transferencias,
- conservacion,
- derechos y canal operativo.

4. Completar fuentes y licencias reales
- AEMET/AVAMET u otras fuentes si se usan,
- mapas,
- proveedores meteo,
- atribuciones requeridas,
- limites de reutilizacion.

5. Decidir si hace falta `Politica de cookies`
- segun web/hosting/analytics real.

6. Definir moderacion y reportes
- especialmente si comunidad, comentarios, mensajes y rankings siguen creciendo.

## 8. Como usar legalize-es de forma util

Uso recomendado del repo:
- consultar texto consolidado de normas base,
- localizar articulos concretos,
- rastrear cambios si una norma se reforma,
- mantener trazabilidad interna de por que hemos redactado ciertas clausulas.

Uso no recomendado:
- copiar articulos sin adaptacion,
- convertir el repo en texto legal final para usuario,
- o pensar que por citar normas ya tenemos compliance cerrado.

## 9. Siguiente entregable recomendado

Los entregables `2026-05-draft-1` ya existen para:
- terminos,
- privacidad,
- aviso legal,
- comunidad/rankings,
- fuentes/licencias.

Tambien existe `weather_safety_disclaimer_2026_04_draft_1`.

El siguiente entregable util dentro del repo deberia ser:
- [legal_responsible_identity.md](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/docs/legal/legal_responsible_identity.md:1) con datos del responsable,
- [data_sources_inventory.md](/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher/docs/legal/data_sources_inventory.md:1) con proveedores/datos usados por la app,
- y una revision final de copy legal antes de publicar una version no marcada como draft.
