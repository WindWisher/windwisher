import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/app/router/router_refresh_notifier.dart';

void main() {
  test('refreshes for auth changes and stops after disposal', () {
    final changes = StreamController<Object?>(sync: true);
    final notifier = RouterRefreshNotifier(changes.stream);
    var refreshCount = 0;
    notifier.addListener(() => refreshCount += 1);

    changes.add('signed-in');
    changes.add('token-refreshed');
    expect(refreshCount, 2);

    notifier.dispose();
    changes.add('signed-out');
    expect(refreshCount, 2);
    unawaited(changes.close());
  });
}
