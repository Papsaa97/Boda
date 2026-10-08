import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/activity/presentation/controllers/activity_controller.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('loads activities sorted newest first', () async {
    final repo = InMemoryActivityRepository([
      activity('old', date: DateTime(2026, 10, 1)),
      activity('new', date: DateTime(2026, 10, 5)),
    ]);
    final container = makeContainer(activities: repo);
    addTearDown(container.dispose);

    final list = await container.read(activityControllerProvider.future);
    expect(list.map((a) => a.id), ['new', 'old']);
  });

  test('add, update and delete keep state and storage in sync', () async {
    final repo = InMemoryActivityRepository();
    final container = makeContainer(activities: repo);
    addTearDown(container.dispose);
    final controller = container.read(activityControllerProvider.notifier);
    await container.read(activityControllerProvider.future);

    await controller.addActivity(
      title: 'Zálivka',
      date: DateTime(2026, 10, 7, 8),
      zoneId: 'Z1',
    );
    var state = container.read(activityControllerProvider).value!;
    expect(state, hasLength(1));
    expect(repo.items.values.single.title, 'Zálivka');

    final updated = activity(
      state.single.id,
      date: state.single.date,
      title: 'Zálivka rajčat',
      zoneId: 'Z2',
    );
    await controller.updateActivity(updated);
    state = container.read(activityControllerProvider).value!;
    expect(state.single.title, 'Zálivka rajčat');
    expect(repo.items[updated.id]!.zoneId, 'Z2');

    await controller.deleteActivity(updated.id);
    expect(container.read(activityControllerProvider).value, isEmpty);
    expect(repo.items, isEmpty);
  });
}
