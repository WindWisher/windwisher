# WindWisher - Diseno de replica de Login

## Objetivo

Replicar en WindWisher la pantalla de login heredada con el mismo layout, jerarquia visual y comportamiento funcional principal (email, cuentas recientes, Google, Apple y DEV BYPASS), manteniendo la implementacion preparada para evolucionar a la arquitectura completa del proyecto.

## Alcance

- Replicar `LoginPage` tomando como referencia la implementacion previa de `lib/features/auth/presentation/pages/login_page.dart`.
- Corregir el punto de entrada actual (`lib/main.dart`) para que la app arranque y muestre la pantalla de login.
- Introducir solo la infraestructura minima para compilar y ejecutar la pantalla (estado, providers y navegacion de placeholder).

Fuera de alcance en esta iteracion:

- Integracion real con backend.
- Autenticacion social real (solo estructura/placeholder).
- Persistencia avanzada mas alla de lo necesario para cuentas recientes.

## Enfoque elegido

Se adopta un clon fiel rapido con infraestructura minima compatible.

Razon:

- Entrega la misma experiencia visual y de uso de forma inmediata.
- Minimiza riesgo de divergencia respecto a v1.0.
- Permite evolucionar despues a Clean Architecture completa sin bloquear la UI.

## Diseno tecnico

### Estructura propuesta

- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/providers/*` (estado de sesion y cuentas recientes)
- `lib/app/router/*` (rutas minimas para login y dashboard placeholder)
- `lib/main.dart` (bootstrap limpio, sin template counter)

### Componentes UI replicados

- `Scaffold` con `AppBar` titulo "Acceso".
- `Card` centrada con ancho maximo, paddings y espaciados equivalentes.
- Campo de email.
- Seccion "Cuentas recientes" con `ListTile`, avatar con iniciales y accion de eliminar.
- Boton principal "Continuar con email".
- Botones secundarios Google y Apple (placeholder por flag).
- Boton DEV BYPASS (condicional por flag).
- Mensajes de error con `SnackBar`.

### Flujo de datos y estado

- `isSubmitting` local en la pagina para bloquear acciones concurrentes.
- Estado de sesion mediante provider (loading/error).
- Lista de cuentas recientes mediante provider dedicado.
- Metodo comun `_runSignIn` para centralizar loading, manejo de error y navegacion.

### Navegacion

- Navegacion a dashboard placeholder tras login correcto.
- En esta fase, rutas minimas para no acoplar el resto de features.

### Manejo de errores

- Validacion basica de email antes de intentar login.
- Mensaje de error legible en `SnackBar` para fallos funcionales.
- Bloqueo de botones durante operaciones en curso.

## Estrategia de pruebas

- `flutter analyze` para validar estructura y tipos.
- `flutter test` con al menos:
  - Render del login.
  - Flujo de boton email en loading.
  - Visibilidad condicional de DEV BYPASS.
  - Render de cuentas recientes.

## Riesgos y mitigaciones

- Riesgo: Dependencias de v1.0 no disponibles en v2.0.
  - Mitigacion: adaptar imports y crear placeholders aislados.
- Riesgo: divergencia visual por tema no migrado.
  - Mitigacion: copiar tokens minimos de espaciado/estilo necesarios para fidelidad.

## Criterios de aceptacion

- La app arranca en v2.0 y muestra login en lugar del template de contador.
- La pantalla se ve y se comporta como en v1.0.
- Botones y estados de carga funcionan sin crashes.
- Proyecto compila y pasa `flutter analyze`.
