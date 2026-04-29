# WindWisher Legal Responsible Identity

Fecha: `2026-04-25`

Estado: plantilla interna pendiente de completar

Objetivo:
- reunir los datos reales que faltan para convertir `Aviso legal`, `Politica de privacidad` y `Terminos y condiciones` en documentos publicables,
- evitar que esos datos queden dispersos en conversaciones,
- y separar claramente informacion legal real de placeholders de producto.

Nota:
- este documento no debe publicarse tal cual si contiene datos internos,
- y no sustituye revision juridica profesional.

## 1. Responsable del servicio

Completar antes de publicar textos legales definitivos:

- Nombre o razon social: `PENDIENTE`
- Nombre comercial: `WindWisher`
- NIF/CIF/NIE: `PENDIENTE`
- Forma juridica: `PENDIENTE`
- Domicilio o direccion formal: `PENDIENTE`
- Pais principal de establecimiento: `Espana` si aplica
- Email legal general: `PENDIENTE`
- Email privacidad/RGPD: `PENDIENTE`
- Email soporte usuario: `PENDIENTE`

## 2. Titularidad y equipo

Completar segun estructura real:

- Titular de la app: `PENDIENTE`
- Desarrollador/editor en stores: `PENDIENTE`
- Responsable de soporte: `PENDIENTE`
- Responsable de privacidad: `PENDIENTE`
- Delegado de proteccion de datos: `NO DEFINIDO`

Notas:
- si no existe obligacion de DPO, documentar motivo internamente,
- si se usa una cuenta personal para stores, revisar si debe aparecer en textos publicos.

## 3. Canales de contacto que deberian aparecer en la app

Minimo recomendado:

- Contacto legal: `PENDIENTE`
- Contacto privacidad: `PENDIENTE`
- Contacto soporte: `PENDIENTE`
- Canal para derechos RGPD: `PENDIENTE`
- Canal para reportes de comunidad/contenido: `PENDIENTE`

## 4. Datos para Aviso legal

Campos que deben acabar reflejados en `legal_notice_*.json`:

- identificacion del responsable,
- datos fiscales/mercantiles si proceden,
- email o canal formal,
- titularidad de marca, logotipo, textos e interfaz,
- jurisdiccion/ley aplicable,
- limitacion de responsabilidad sobre datos de terceros,
- limitacion de responsabilidad sobre disponibilidad del servicio.

## 5. Datos para Politica de privacidad

Campos que deben acabar reflejados en `privacy_policy_*.json`:

- responsable del tratamiento,
- datos tratados,
- finalidades,
- bases juridicas,
- destinatarios/proveedores,
- transferencias internacionales si existen,
- plazos de conservacion,
- derechos del usuario,
- canal para ejercer derechos,
- informacion sobre menores si aplica.

## 6. Datos para Terminos y condiciones

Campos que deben acabar reflejados en `terms_and_conditions_*.json`:

- reglas de acceso,
- edad minima o restricciones de uso,
- conducta prohibida,
- moderacion/suspension,
- contenido de usuario,
- rankings y fair play,
- eliminacion de cuenta,
- descargo sobre metricas y seguridad,
- ley aplicable y resolucion de conflictos.

## 7. Pendientes

- Completar datos reales del responsable.
- Decidir emails/canales publicos definitivos.
- Decidir si hace falta DPO o declaracion de no aplicacion.
- Revisar si hay pagos/suscripciones antes de cerrar terminos.
- Revisar si hay web/cookies antes de cerrar politica de cookies.
