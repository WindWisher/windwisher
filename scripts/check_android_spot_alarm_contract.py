#!/usr/bin/env python3
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text()


def require(condition: bool, message: str) -> None:
    if not condition:
        print(f"FAIL: {message}")
        sys.exit(1)


def contains(path: str, needle: str, message: str) -> None:
    require(needle in read(path), f"{message} ({path})")


def main() -> None:
    manifest = "android/app/src/main/AndroidManifest.xml"
    ios_info = "ios/Runner/Info.plist"
    ios_entitlements = "ios/Runner/Runner.entitlements"
    ios_project = "ios/Runner.xcodeproj/project.pbxproj"
    ios_podfile = "ios/Podfile"
    macos_debug_entitlements = "macos/Runner/DebugProfile.entitlements"
    macos_release_entitlements = "macos/Runner/Release.entitlements"
    pubspec = "pubspec.yaml"
    webview_delegate = (
        "third_party/webview_flutter_wkwebview_xcode14/darwin/"
        "webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/"
        "WebViewProxyAPIDelegate.swift"
    )
    runner = "supabase/functions/spot-alarm-runner/index.ts"
    scheduler = "supabase/manual/spot_alarm_runner_scheduler.sql"
    firebase = "lib/core/notifications/firebase_push_messaging_service.dart"
    local = "lib/core/notifications/local_notifications_service.dart"
    dashboard = "lib/features/dashboard/presentation/pages/dashboard_page.dart"

    contains(
        manifest,
        "android.permission.POST_NOTIFICATIONS",
        "Android notification runtime permission must stay declared",
    )
    contains(
        manifest,
        "android.permission.SCHEDULE_EXACT_ALARM",
        "Android exact alarm permission must stay declared",
    )
    contains(
        manifest,
        "spot_alarms_v2",
        "Default FCM channel must keep the alarm channel id",
    )

    contains(
        scheduler,
        "spot-alarm-runner-every-1-min",
        "Spot alarm runner cron job must be the 1-minute job",
    )
    contains(
        scheduler,
        "'* * * * *'",
        "Spot alarm runner cron schedule must stay every minute",
    )
    contains(
        scheduler,
        "/functions/v1/spot-alarm-runner",
        "Spot alarm runner scheduler must call the edge function",
    )

    contains(
        runner,
        'type: "spot_alarm"',
        "Backend alarm push payload must keep type=spot_alarm",
    )
    contains(
        runner,
        "occurrenceIndex: String(alarm.trigger_count)",
        "Backend alarm push payload must include occurrenceIndex from trigger_count",
    )
    contains(
        runner,
        "alarm.trigger_count >= alarm.max_repeats",
        "Backend must stop sending after max_repeats",
    )
    contains(
        runner,
        "snoozedUntil.getTime() > now.getTime()",
        "Backend must respect snoozed_until before sending repeats",
    )
    contains(
        runner,
        "alarm.stopped_until_reset",
        "Backend must respect stopped_until_reset",
    )
    contains(
        runner,
        'category: "spot_alarm_actions"',
        "APNs alarm push payload must keep the alarm action category",
    )
    contains(
        runner,
        '"interruption-level": "time-sensitive"',
        "APNs alarm push payload must keep time-sensitive interruption level",
    )
    contains(
        runner,
        'sound: "default"',
        "APNs alarm push payload must keep audible delivery",
    )

    contains(
        ios_entitlements,
        "aps-environment",
        "iOS entitlements must keep APNs enabled",
    )
    contains(
        ios_entitlements,
        "$(APS_ENVIRONMENT)",
        "iOS APNs environment must be driven by build configuration",
    )
    contains(
        ios_project,
        "CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;",
        "iOS target must sign with Runner.entitlements",
    )
    contains(
        ios_project,
        "APS_ENVIRONMENT = development;",
        "iOS Debug must use APNs development environment",
    )
    contains(
        ios_project,
        "APS_ENVIRONMENT = production;",
        "iOS Profile/Release must use APNs production environment",
    )
    contains(
        ios_info,
        "remote-notification",
        "iOS Info.plist must keep remote-notification background mode",
    )
    contains(
        macos_debug_entitlements,
        "com.apple.developer.aps-environment",
        "macOS debug entitlements must keep APNs enabled",
    )
    contains(
        macos_release_entitlements,
        "com.apple.developer.aps-environment",
        "macOS release entitlements must keep APNs enabled",
    )
    contains(
        pubspec,
        "webview_flutter_wkwebview_xcode14",
        "Xcode 14.2 builds must keep the local WebView WKWebView compatibility override",
    )
    contains(
        webview_delegate,
        'Selector(("setInspectable:"))',
        "Local WebView patch must use dynamic setInspectable selector",
    )
    require(
        "pigeonInstance.isInspectable =" not in read(webview_delegate),
        "Local WebView patch must not directly call WKWebView.isInspectable",
    )
    contains(
        ios_podfile,
        "pod 'SwiftProtobuf', '1.36.1'",
        "iOS Podfile must pin SwiftProtobuf for Xcode 14.2 compatibility",
    )
    for needle in (
        "-package-name SwiftProtobuf",
        "@usableFromInline",
        "@inlinable",
        "nonisolated\\(unsafe\\)",
        "buffer.initializeElement",
        "\\bsending\\s+",
        "\\binternal import\\b",
    ):
        contains(
            ios_podfile,
            needle,
            f"iOS Podfile must keep CocoaPods compatibility patch for {needle}",
        )

    for path in (firebase, local):
        source = read(path)
        for payload_type in ("spot_alarm", "spot_chat", "direct_message"):
            require(
                payload_type in source,
                f"{path} must keep separate handling for {payload_type}",
            )
        require(
            "occurrenceIndex" in source,
            f"{path} must preserve occurrenceIndex handling",
        )

    contains(
        dashboard,
        "openAlarmsFromNotification",
        "Alarm notifications must route to Profile > Alarms",
    )
    contains(
        dashboard,
        "openSpotChatFromNotification",
        "Spot chat notifications must route separately to spot chat",
    )

    print("OK: spot alarm notification contract checks passed.")


if __name__ == "__main__":
    main()
