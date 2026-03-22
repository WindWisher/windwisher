# Community UI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the Community tab UI-first with `Leaderboard` and `Following`, including Woo-like filters, user actions, and placeholder navigation to profile/sessions/messages.

**Architecture:** Keep implementation inside presentation layer for this phase, using deterministic in-memory mock models colocated with the community pages. Build Community as a stateful shell with two segmented subviews that preserve independent state. Add dedicated placeholder destination screens for profile, sessions, and messages, then wire navigation and widget tests.

**Tech Stack:** Flutter Material 3, existing app spacing tokens (`AppSpacing`), flutter_test widget tests.

---

### Task 1: Replace Community placeholder with segmented shell

**Files:**
- Modify: `lib/features/community/presentation/pages/community_page.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('community shows leaderboard and following segments', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: CommunityPage()));

  expect(find.text('Leaderboard'), findsOneWidget);
  expect(find.text('Following'), findsOneWidget);
  expect(find.text('Big Air Score'), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: FAIL because Community still shows old placeholder content.

**Step 3: Write minimal implementation**

```dart
enum _CommunityTab { leaderboard, following }

SegmentedButton<_CommunityTab>(
  segments: const [
    ButtonSegment(value: _CommunityTab.leaderboard, label: Text('Leaderboard')),
    ButtonSegment(value: _CommunityTab.following, label: Text('Following')),
  ],
  selected: {_selectedTab},
  onSelectionChanged: (value) => setState(() => _selectedTab = value.first),
)
```

Implement `CommunityPage` as `StatefulWidget` with default tab `Leaderboard` and render a first leaderboard block containing `Big Air Score` label.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/community/presentation/pages/community_page.dart test/features/community/presentation/pages/community_page_test.dart
git commit -m "feat: add segmented shell for community leaderboard and following"
```

### Task 2: Implement Leaderboard list rows and Woo-like filters

**Files:**
- Modify: `lib/features/community/presentation/pages/community_page.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('leaderboard row shows rank avatar username score and highest jump', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: CommunityPage()));

  expect(find.text('#1'), findsOneWidget);
  expect(find.textContaining('@'), findsWidgets);
  expect(find.textContaining('Big Air'), findsWidgets);
  expect(find.textContaining('m'), findsWidgets);
});

testWidgets('leaderboard filters are visible', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: CommunityPage()));

  expect(find.text('Periodo'), findsOneWidget);
  expect(find.text('Spot'), findsOneWidget);
  expect(find.text('Scope'), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: FAIL because row fields/filters are incomplete.

**Step 3: Write minimal implementation**

```dart
class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.bigAirScore,
    required this.highestJumpMeters,
    required this.avatarColor,
  });
}
```

Add deterministic mock leaderboard entries and render list cards/tiles with:
- `#rank`
- circular avatar
- `@username`
- `Big Air Score` value
- `Salto mas alto: X.X m`

Add filter controls using `DropdownButtonFormField` for period/spot/scope and keep default ordering by score.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/community/presentation/pages/community_page.dart test/features/community/presentation/pages/community_page_test.dart
git commit -m "feat: implement community leaderboard rows and filters"
```

### Task 3: Add Following discovery + sessions feed UI

**Files:**
- Modify: `lib/features/community/presentation/pages/community_page.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('following shows search and only followed sessions', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: CommunityPage()));

  await tester.tap(find.text('Following'));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  expect(find.text('Mensaje'), findsWidgets);
  expect(find.text('Ver perfil'), findsWidgets);
  expect(find.text('Ver sesiones'), findsWidgets);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: FAIL because Following content is not implemented.

**Step 3: Write minimal implementation**

```dart
TextField(
  decoration: const InputDecoration(
    prefixIcon: Icon(Icons.search_rounded),
    hintText: 'Buscar usuarios',
  ),
)
```

Implement Following tab sections:
- Search/discovery list with `Seguir` button.
- Followed sessions feed cards with score + highest jump.
- Action chips/buttons: `Mensaje`, `Ver perfil`, `Ver sesiones`.
- Empty states for no follows and no search results.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/community/presentation/pages/community_page.dart test/features/community/presentation/pages/community_page_test.dart
git commit -m "feat: add following discovery and sessions feed UI"
```

### Task 4: Add navigation placeholders for profile/sessions/messages

**Files:**
- Create: `lib/features/community/presentation/pages/community_user_profile_page.dart`
- Create: `lib/features/community/presentation/pages/community_user_sessions_page.dart`
- Create: `lib/features/community/presentation/pages/community_messages_page.dart`
- Modify: `lib/features/community/presentation/pages/community_page.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('community actions navigate to placeholder pages', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: CommunityPage()));

  await tester.tap(find.text('Ver perfil').first);
  await tester.pumpAndSettle();
  expect(find.text('Perfil de usuario'), findsOneWidget);
});
```

Add similar checks for `Ver sesiones` and `Mensaje`.

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: FAIL because destination pages do not exist yet.

**Step 3: Write minimal implementation**

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => CommunityUserProfilePage(username: entry.username),
  ),
);
```

Create simple destination pages with AppBar + basic user context:
- `Perfil de usuario`
- `Sesiones de usuario`
- `Mensajes`

Wire all actions in Leaderboard and Following to these pages.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/community/presentation/pages/community_page.dart lib/features/community/presentation/pages/community_user_profile_page.dart lib/features/community/presentation/pages/community_user_sessions_page.dart lib/features/community/presentation/pages/community_messages_page.dart test/features/community/presentation/pages/community_page_test.dart
git commit -m "feat: add community navigation placeholders for profile sessions and messages"
```

### Task 5: Polish responsive behavior and run full verification

**Files:**
- Modify: `lib/features/community/presentation/pages/community_page.dart`
- Test: `test/features/community/presentation/pages/community_page_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('community filters do not overflow on narrow layouts', (tester) async {
  await tester.binding.setSurfaceSize(const Size(360, 780));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(const MaterialApp(home: CommunityPage()));
  expect(tester.takeException(), isNull);
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
Expected: FAIL if there are overflow/layout exceptions.

**Step 3: Write minimal implementation**

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final narrow = constraints.maxWidth < 700;
    return narrow ? Column(children: filters) : Row(children: filtersExpanded);
  },
)
```

Use responsive filter layout and `isExpanded: true` for dropdowns where needed.

**Step 4: Run full verification**

Run:
- `flutter test test/features/community/presentation/pages/community_page_test.dart -r compact`
- `flutter analyze`
- `flutter test -r compact`

Expected: all PASS.

**Step 5: Commit**

```bash
git add lib/features/community/presentation/pages/community_page.dart test/features/community/presentation/pages/community_page_test.dart
git commit -m "test: cover community responsive leaderboard and following flows"
```
