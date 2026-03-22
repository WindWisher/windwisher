# Login Screen Replica Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replicar en WindWisher la pantalla de login heredada con apariencia y comportamiento equivalentes, dejando placeholders funcionales para auth social y DEV BYPASS.

**Architecture:** Se implementa una vertical slice minima de `auth` en Flutter con Riverpod para estado de sesion y cuentas recientes, GoRouter para navegacion login->dashboard, y UI Material3 replicada desde v1.0. El flujo mantiene acciones asincronas con estado de carga, manejo de errores por `SnackBar`, y estructura compatible con futura Clean Architecture.

**Tech Stack:** Flutter, Dart, Material 3, flutter_riverpod, go_router, flutter_test.

---

### Task 1: Base App + Router Bootstrap

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/app/router/app_routes.dart`
- Create: `lib/app/router/app_router.dart`
- Create: `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- Modify: `lib/main.dart`

**Step 1: Write the failing test**

```dart
testWidgets('app starts on login route', (tester) async {
  await tester.pumpWidget(const AppBootstrap());
  expect(find.text('Acceso'), findsOneWidget);
});
```

Test file: `test/app/app_bootstrap_test.dart`

**Step 2: Run test to verify it fails**

Run: `flutter test test/app/app_bootstrap_test.dart -r expanded`
Expected: FAIL by missing `AppBootstrap`/router files.

**Step 3: Write minimal implementation**

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardPage()),
    ],
  );
});
```

```dart
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(routerConfig: router);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/app/app_bootstrap_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add pubspec.yaml lib/main.dart lib/app/router lib/features/dashboard test/app/app_bootstrap_test.dart
git commit -m "feat: bootstrap app router with login entry"
```

### Task 2: Session State Provider (email/social/dev)

**Files:**
- Create: `lib/features/auth/presentation/providers/auth_session_provider.dart`
- Test: `test/features/auth/presentation/providers/auth_session_provider_test.dart`

**Step 1: Write the failing test**

```dart
test('signInWithEmail returns error when email is empty', () async {
  final container = ProviderContainer();
  final notifier = container.read(authSessionProvider.notifier);
  final error = await notifier.signInWithEmail('');
  expect(error, isNotNull);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/providers/auth_session_provider_test.dart -r expanded`
Expected: FAIL by provider not found.

**Step 3: Write minimal implementation**

```dart
class AuthSessionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> signInWithEmail(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Introduce un email valido';
    }
    state = const AsyncLoading();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = const AsyncData(null);
    return null;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/providers/auth_session_provider_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/auth/presentation/providers/auth_session_provider.dart test/features/auth/presentation/providers/auth_session_provider_test.dart
git commit -m "feat: add auth session provider with placeholder sign-in flows"
```

### Task 3: Recent Accounts Provider

**Files:**
- Create: `lib/features/auth/presentation/providers/recent_auth_accounts_provider.dart`
- Modify: `lib/features/auth/presentation/providers/auth_session_provider.dart`
- Test: `test/features/auth/presentation/providers/recent_auth_accounts_provider_test.dart`

**Step 1: Write the failing test**

```dart
test('add email stores most recent first and deduplicates', () async {
  final container = ProviderContainer();
  final actions = container.read(recentAuthAccountsActionsProvider);
  await actions.add('user@example.com');
  await actions.add('user@example.com');
  final list = await container.read(recentAuthEmailsProvider.future);
  expect(list.first, 'user@example.com');
  expect(list.length, 1);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/providers/recent_auth_accounts_provider_test.dart -r expanded`
Expected: FAIL by missing provider/actions.

**Step 3: Write minimal implementation**

```dart
class RecentAuthAccountsActions {
  RecentAuthAccountsActions(this.ref);
  final Ref ref;

  Future<void> add(String email) async { /* prepend + dedupe + max 10 */ }
  Future<void> remove(String email) async { /* remove + refresh */ }
}
```

Storage inicial: en memoria (`StateProvider<List<String>>`) para replicar UX rapido.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/providers/recent_auth_accounts_provider_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/auth/presentation/providers/recent_auth_accounts_provider.dart lib/features/auth/presentation/providers/auth_session_provider.dart test/features/auth/presentation/providers/recent_auth_accounts_provider_test.dart
git commit -m "feat: add recent account state and actions"
```

### Task 4: Login Page Replica UI + Behavior

**Files:**
- Create: `lib/features/auth/presentation/pages/login_page.dart`
- Modify: `lib/features/auth/presentation/providers/auth_session_provider.dart`
- Modify: `lib/features/auth/presentation/providers/recent_auth_accounts_provider.dart`
- Test: `test/features/auth/presentation/pages/login_page_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('login page shows main actions from v1.0', (tester) async {
  await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: LoginPage())));
  expect(find.text('Bienvenido a WindWisher'), findsOneWidget);
  expect(find.text('Continuar con email'), findsOneWidget);
  expect(find.textContaining('Google'), findsOneWidget);
  expect(find.textContaining('Apple'), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart -r expanded`
Expected: FAIL by missing page.

**Step 3: Write minimal implementation**

```dart
class LoginPage extends ConsumerStatefulWidget { /* same structure as v1.0 */ }
class _LoginPageState extends ConsumerState<LoginPage> {
  Future<void> _runSignIn(Future<String?> Function() action) async { /* loading + snackbar + go */ }
}
```

Replicar: AppBar, Card centrada, TextField email, seccion cuentas recientes, botones email/google/apple/dev bypass.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/auth/presentation/pages/login_page.dart lib/features/auth/presentation/providers test/features/auth/presentation/pages/login_page_test.dart
git commit -m "feat: replicate legacy login screen in WindWisher"
```

### Task 5: Quality Gate + Final Wiring

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart` (remove counter template test)

**Step 1: Write the failing test**

```dart
testWidgets('app no longer renders counter template', (tester) async {
  await tester.pumpWidget(const AppBootstrap());
  expect(find.text('You have pushed the button this many times:'), findsNothing);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test -r expanded`
Expected: FAIL while old template test still exists or app wiring incomplete.

**Step 3: Write minimal implementation**

```dart
void main() {
  runApp(const ProviderScope(child: AppBootstrap()));
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test -r expanded && flutter analyze`
Expected: all tests PASS and analyzer clean.

**Step 5: Commit**

```bash
git add lib/main.dart test/widget_test.dart
git commit -m "chore: finalize login bootstrap and remove template artifacts"
```
