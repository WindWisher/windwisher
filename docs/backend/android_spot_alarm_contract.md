# Spot alarm notification contract

This file documents the Android and Apple alarm flow that must stay stable.

## Runtime model

- Supabase is the source of truth for evaluating spot alarms while the app is closed.
- The Android client may schedule local repeats after the user taps or snoozes a notification, but those local repeats are only a convenience. MIUI and other battery managers can kill scheduled local work.
- Because of that, `spot-alarm-runner` must keep running every minute and must also honor `snoozed_until`.
- Chat notifications and alarm notifications are separate payload types and must not share routing logic:
  - `spot_alarm`
  - `spot_chat`
  - `direct_message`

## Push payload contract

Every alarm push sent by `supabase/functions/spot-alarm-runner/index.ts` must include:

- `type: "spot_alarm"`
- `alarmId`
- `spotKey`
- `stationKey`
- `stationProvider`
- `repeatWindow`
- `maxRepeats`
- `occurrenceIndex`
- `title`
- `body`

`occurrenceIndex` is required. It tells the app whether the tapped push is the first alert or a later repeat. Without it, the app can treat every backend push as occurrence `0` and incorrectly snooze after the last allowed repeat.

## Apple push payload contract

The APNs payload generated through FCM must keep:

- visible alert title/body,
- `sound: "default"`,
- `category: "spot_alarm_actions"`,
- `interruption-level: "time-sensitive"`.

The category links APNs notifications with the Darwin category registered by `flutter_local_notifications`, so Apple can expose the same `Posponer` and `Parar` actions where the system allows it. The tap fallback must still work even if Apple does not show actions.

## State contract

- `snoozed_until` means: do not send another backend push until this timestamp has passed.
- `stopped_until_reset` means: do not send more pushes until conditions stop matching and the runner resets the alarm state.
- `trigger_count >= max_repeats` means: do not send more pushes during the current active conditions window.
- When conditions stop matching, the backend resets runtime state so the alarm can trigger again later.

## Android requirements

`android/app/src/main/AndroidManifest.xml` must keep:

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.SCHEDULE_EXACT_ALARM`
- `com.google.firebase.messaging.default_notification_channel_id = spot_alarms_v2`

The default FCM channel can remain `spot_alarms_v2`, but the Dart notification layer still separates alarm, spot chat, and direct message channels.

## Apple requirements

`ios/Runner/Runner.entitlements` must keep:

- `aps-environment = $(APS_ENVIRONMENT)`

`ios/Runner.xcodeproj/project.pbxproj` must keep:

- `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`
- `APS_ENVIRONMENT = development` for Debug
- `APS_ENVIRONMENT = production` for Profile/Release

`ios/Runner/Info.plist` must keep:

- `UIBackgroundModes` with `remote-notification`

`macos/Runner/*.entitlements` must keep APNs entitlements too if the macOS build is expected to receive the same push alarm flow.

Apple still requires the Push Notifications capability and valid APNs credentials/certificates in the Apple Developer/Firebase project. The repo-side contract makes the app capable of using them; provisioning must also include the capability.

## iOS build compatibility

The current local Apple toolchain is Xcode 14.2 / iOS SDK 16.2. Until the build machines move to Xcode 14.3+ or newer, keep:

- `pubspec.yaml` overriding `webview_flutter_wkwebview` to `third_party/webview_flutter_wkwebview_xcode14`.
- the local WebView patch using the dynamic `setInspectable:` selector instead of directly calling `WKWebView.isInspectable`.
- `ios/Podfile` pinning `SwiftProtobuf` to `1.36.1`.
- the `ios/Podfile` `post_install` patches that remove newer Swift syntax from generated Pods for Xcode 14.2.

These patches are deliberately centralized in repo files so `pod install` and Flutter builds remain reproducible.

## Scheduler requirements

`supabase/manual/spot_alarm_runner_scheduler.sql` must keep:

- job name: `spot-alarm-runner-every-1-min`
- schedule: `* * * * *`
- endpoint: `/functions/v1/spot-alarm-runner`

If the scheduler drifts back to 5 minutes, `repeatWindow = min1` will not be reliable with the app closed.

## Validation

Run this before changing alarm notification code:

```sh
python3 scripts/check_android_spot_alarm_contract.py
flutter analyze
```

The script checks the most fragile contract points so this flow does not silently regress again.
