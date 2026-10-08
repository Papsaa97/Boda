// test/features/activity/data/activity_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:zahradnik_boda_mvp01/features/activity/data/activity_hive_model.dart';
import 'package:zahradnik_boda_mvp01/features/activity/data/activity_repository_impl.dart';
import 'package:zahradnik_boda_mvp01/features/activity/data/hive_local_data_source.dart';
import 'package:zahradnik_boda_mvp01/features/activity/domain/activity_entity.dart';

// Import generovaného souboru (vznikne v dalším kroku)
import 'activity_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<HiveLocalDataSource>()])
void main() {
  late MockHiveLocalDataSource mockLocalDataSource;
  late ActivityRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockHiveLocalDataSource();
    repository = ActivityRepositoryImpl(mockLocalDataSource);
  });

  group('getAllActivities', () {
    test('maps Hive models to domain entities', () async {
      final hiveModels = [
        ActivityHiveModel(
          id: '1',
          title: 'Zálivka rajčat',
          date: DateTime(2024, 5, 1, 8, 0),
          zoneId: 'Z1',
          notes: 'Ráno před sluncem',
          imagePath: '/path/to/image1.png',
        ),
        ActivityHiveModel(
          id: '2',
          title: 'Pletí záhonu',
          date: DateTime(2024, 5, 2, 9, 30),
          zoneId: 'Z2',
          notes: null,
          imagePath: null,
        ),
      ];

      when(mockLocalDataSource.getAll()).thenReturn(hiveModels);

      final result = await repository.getAllActivities();

      expect(result.length, 2);

      final first = result[0];
      expect(first.id, hiveModels[0].id);
      expect(first.title, hiveModels[0].title);
      expect(first.date, hiveModels[0].date);
      expect(first.zoneId, hiveModels[0].zoneId);
      expect(first.notes, hiveModels[0].notes);
      expect(first.imagePath, hiveModels[0].imagePath);
    });
  });

  group('addActivity', () {
    test(
      'converts ActivityEntity to Hive model and delegates to data source',
      () async {
        final entity = ActivityEntity(
          id: '123',
          title: 'Nová aktivita',
          date: DateTime(2024, 5, 3, 7, 45),
          zoneId: 'Z3',
          notes: 'Testovací poznámka',
          imagePath: '/path/to/image2.png',
        );

        await repository.addActivity(entity);

        // Verification + capture argumentu
        final verification = verify(mockLocalDataSource.add(captureAny));

        final capturedModel = verification.captured.single as ActivityHiveModel;

        expect(capturedModel.id, entity.id);
        expect(capturedModel.title, entity.title);
        expect(capturedModel.date, entity.date);
        expect(capturedModel.zoneId, entity.zoneId);
        expect(capturedModel.notes, entity.notes);
        expect(capturedModel.imagePath, entity.imagePath);
      },
    );
  });
}
