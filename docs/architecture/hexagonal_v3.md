# MeteoKite v3.0 - Arquitectura Hexagonal

## Objetivo

Definir una base estable para evolucionar todas las features a un modelo
hexagonal (Ports and Adapters) sin frenar el desarrollo funcional.

## Estructura objetivo por feature

```text
lib/features/<feature>/
  domain/
    entities/
    value_objects/
    ports/
      in/
      out/
  application/
    use_cases/
    services/
  infrastructure/
    adapters/
      in_memory/
      local/
      remote/
  presentation/
    pages/
    widgets/
    state/
    providers/
  di/
    <feature>_module.dart
```

Notas:
- `domain` no depende de Flutter, Riverpod, ni de adaptadores.
- `application` orquesta casos de uso y depende solo de `domain`.
- `infrastructure` implementa puertos `out` y conoce detalles de data source.
- `presentation` consume puertos `in` o casos de uso, nunca repos concretos.

## Reglas de dependencia

1. `domain` -> no importa nada de `application`, `infrastructure`, `presentation`.
2. `application` -> puede importar `domain`; no importa `presentation`.
3. `infrastructure` -> puede importar `domain` y `application` (para wiring),
   pero no debe contener logica de UI.
4. `presentation` -> no importa `infrastructure/*` directamente.
5. Toda composicion de dependencias se hace en `di/<feature>_module.dart`.

## Guardrails automáticos

- Se agrega test de arquitectura en
  `test/architecture/hexagonal_dependency_rules_test.dart`.
- Reglas iniciales verificadas automaticamente:
  - `domain` no importa Flutter/Riverpod/GoRouter ni capas externas,
  - `presentation` no importa `infrastructure` directamente.

## Convenciones de naming

- Puerto de entrada: `GetProfilePort`, `SaveSessionPort`.
- Puerto de salida: `ProfileRepositoryPort`, `SessionDataSourcePort`.
- Caso de uso: `GetProfileUseCase`, `CreateSessionUseCase`.
- Adaptador: `InMemoryProfileRepositoryAdapter`, `ApiSessionRepositoryAdapter`.
- Modulo DI: `ProfileModule`, `SessionsModule`.

## Estrategia de migracion incremental

1. No hacer big-bang: migrar por feature y por vertical slice.
2. Mantener compatibilidad con UI actual con wrappers finos.
3. Mover primero contratos y use cases, luego adaptadores.
4. Por ultimo simplificar `presentation` para que solo orqueste estado/UI.
5. Cada fase debe cerrar con `flutter analyze` y tests existentes en verde.

## Estado actual

- `profile` queda como piloto migrado a `domain/application/infrastructure/presentation`.
- `auth` queda migrada a `domain/application/infrastructure/presentation` con DI por feature.
- Se mantienen aliases deprecated temporales en `profile` para compatibilidad de imports legacy.
- `sessions` avanza a base hexagonal con slices de dispositivos y sesiones registradas (entidades, puertos out, use cases, adaptadores in-memory y modulo DI).
- `spots` queda migrada en base para catalogo y media remota (webcams/referencias) con puertos out, use cases, adaptadores in-memory y modulo DI.
- `community` queda migrada en base con slices de feed + leaderboard y orquestacion en `application/services`.
- `dashboard` queda como feature liviana: sin puertos/adaptadores por ahora, con reglas de toolbar extraidas a `application/services`.

## Definicion de hecho para una feature migrada

- Tiene carpeta `domain/ports/in` y `domain/ports/out`.
- Casos de uso viven en `application/use_cases`.
- No hay imports de `infrastructure` desde `presentation`.
- Existe `di/<feature>_module.dart` con wiring centralizado.
- Tests basicos del flujo principal pasan sin regressions.
