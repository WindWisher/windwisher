# Firebase Setup

Proyecto Firebase actual:

- `windwisherapp-5ed22`

Objetivo de esta integracion:

- registrar el dispositivo en `user_push_subscriptions`,
- permitir push remotas para alarmas con la app cerrada.

## Android

Datos del proyecto Android en esta app:

- `applicationId`: `com.windwisher.app`

Pasos:

1. Abre Firebase Console.
2. En el proyecto `windwisherapp-5ed22`, anade una app Android.
3. Usa exactamente `com.windwisher.app` como package name.
4. Descarga `google-services.json`.
5. Coloca el archivo en:
   - `android/app/google-services.json`

Estado en el repo:

- ya esta anadido el plugin `com.google.gms.google-services` en:
  - `android/settings.gradle.kts`
  - `android/app/build.gradle.kts`

## iOS

Datos base del proyecto iOS:

- bundle id: debe coincidir con el que uses en Xcode para `Runner`

Pasos:

1. Abre Firebase Console.
2. En el proyecto `windwisherapp-5ed22`, anade una app iOS.
3. Usa exactamente el bundle id configurado en Xcode para `Runner`.
4. Descarga `GoogleService-Info.plist`.
5. Coloca el archivo en:
   - `ios/Runner/GoogleService-Info.plist`
6. Anade el fichero al target `Runner` en Xcode si no entra solo.

## Despues de copiar los archivos

Ejecuta:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## Comprobacion esperada

Cuando Firebase quede bien configurado:

- la app arrancara sin caer en `providerNotConfigured`,
- `FirebasePushMessagingService` pedira permisos,
- obtendra token FCM,
- y sincronizara el token contra `user_push_subscriptions`.

## Bloqueo que sigue pendiente

Aunque Firebase quede configurado, aun faltara:

- implementar el envio push real en `spot-alarm-runner`,
- no solo el registro del dispositivo.
