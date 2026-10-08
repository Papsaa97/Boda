import 'package:flutter_test/flutter_test.dart';
import 'package:zahradnik_boda/features/activity/domain/activity_type.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_backend.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_context.dart';
import 'package:zahradnik_boda/features/assistant/domain/assistant_message.dart';
import 'package:zahradnik_boda/features/assistant/domain/dose_calculator.dart';
import 'package:zahradnik_boda/features/assistant/domain/safety_check.dart';
import 'package:zahradnik_boda/features/inventory/domain/inventory_item.dart';
import 'package:zahradnik_boda/features/inventory/domain/units.dart';
import 'package:zahradnik_boda/features/tasks/domain/task_entity.dart';
import 'package:zahradnik_boda/features/zones/domain/zone_entity.dart';

import '../../helpers/fakes.dart';

const vegetables = ZoneEntity(
  id: 'Z1',
  name: 'Zelenina',
  type: ZoneType.vegetable,
  areaM2: 20,
);
const lawn = ZoneEntity(
  id: 'Z4',
  name: 'Trávník',
  type: ZoneType.lawn,
  areaM2: 100,
);
const cererit = InventoryItem(
  id: 'i1',
  category: InventoryCategory.fertilizer,
  name: 'Cererit',
  unit: InventoryUnit.kg,
  stockQty: 2.5,
  details: FertilizerDetails(
    n: 10,
    form: FertilizerForm.granular,
    dose: LabelDose(60, InventoryUnit.g),
  ),
);
const hosticky = InventoryItem(
  id: 'i2',
  category: InventoryCategory.fertilizer,
  name: 'Hoštický kompost',
  unit: InventoryUnit.kg,
  stockQty: 40,
  details: FertilizerDetails(dose: LabelDose(1.5, InventoryUnit.kg)),
);
const bioSpray = InventoryItem(
  id: 'i3',
  category: InventoryCategory.plantProtection,
  name: 'Biool',
  unit: InventoryUnit.ml,
  stockQty: 500,
  details: PlantProtectionDetails(
    authorizationNo: '4410-0',
    phiDays: 0,
    nonProfessional: true,
    dose: LabelDose(5, InventoryUnit.ml),
  ),
);
const proSpray = InventoryItem(
  id: 'i4',
  category: InventoryCategory.plantProtection,
  name: 'Profistop',
  unit: InventoryUnit.ml,
  stockQty: 100,
  details: PlantProtectionDetails(dose: LabelDose(2, InventoryUnit.ml)),
);
const seeds = InventoryItem(
  id: 'i5',
  category: InventoryCategory.seed,
  name: 'Mrkev Nantes',
  unit: InventoryUnit.pack,
  stockQty: 1,
  details: SeedDetails(species: 'mrkev', variety: 'Nantes', lot: 'L-42'),
);

void main() {
  group('dose calculator (FR-B2)', () {
    test('label dose times zone area, with its source', () {
      expect(
        zoneDose(cererit, vegetables),
        const Calculation(
          label: 'Cererit na zónu Zelenina (20 m²)',
          result: '1,2 kg',
          source: '60 g/m² podle obalu',
        ),
      );
      expect(zoneDose(hosticky, lawn)!.result, '150 kg');
      expect(
        zoneDose(bioSpray, vegetables)!.source,
        '5 ml/m² podle etikety (povolení 4410-0)',
      );
    });

    test('nothing without an area, a dose, or non-professional use', () {
      expect(zoneDose(cererit, testZones.first), isNull);
      expect(zoneDose(seeds, vegetables), isNull);
      expect(zoneDose(proSpray, vegetables), isNull);
    });

    test('amounts switch to kg and l and keep sensible digits', () {
      expect(formatAmount(500, InventoryUnit.g), '500 g');
      expect(formatAmount(2.5, InventoryUnit.ml), '2,5 ml');
      expect(formatAmount(1500, InventoryUnit.ml), '1,5 l');
      expect(formatAmount(0.125, InventoryUnit.kg), '0,13 kg');
    });

    test('a question naming a zone and a product narrows the calculations', () {
      final all = calculationsFor(
        question: 'Co mám hnojit?',
        zones: const [vegetables, lawn],
        inventory: const [cererit, hosticky, seeds],
      );
      expect(all, hasLength(4));

      final narrowed = calculationsFor(
        question: 'Kolik Cereritu dát na zeleninu?',
        zones: const [vegetables, lawn],
        inventory: const [cererit, hosticky],
      );
      expect(narrowed.map((c) => c.result), ['1,2 kg']);
    });

    test('mentions match word stems without diacritics', () {
      expect(mentions('pohnojit zeleninu', 'Zelenina'), isTrue);
      expect(mentions('posekat travnik', 'Trávník'), isTrue);
      expect(mentions('co na zahradu', 'Okrasná zahrada'), isFalse);
      expect(mentions('okrasnou zahradu', 'Okrasná zahrada'), isTrue);
    });
  });

  group('context (FR-B1)', () {
    test('only whitelisted data from active zones and open tasks', () {
      final context = buildAssistantContext(
        question: 'Jak se daří zelenině?',
        zones: [
          vegetables,
          lawn,
          const ZoneEntity(id: 'Z9', name: 'Stará', archived: true),
        ],
        activities: [
          activity('a1', date: DateTime(2026, 9, 1), zoneId: 'Z1'),
          activity('a2', date: DateTime(2026, 10, 1), zoneId: 'Z1'),
          activity('a3', date: DateTime(2026, 10, 2), zoneId: 'Z4'),
        ],
        tasks: [
          TaskEntity(id: 't1', title: 'Zalít', due: DateTime(2026, 10, 9)),
          TaskEntity(
            id: 't2',
            title: 'Hotovo',
            due: DateTime(2026, 10, 1),
            status: TaskStatus.done,
          ),
        ],
        inventory: const [cererit, seeds],
      );
      expect(context.zones.map((z) => z.id), ['Z1', 'Z4']);
      expect(context.focusZones.map((z) => z.id), ['Z1']);
      expect(context.recentActivities.map((a) => a.id), ['a2', 'a1']);
      expect(context.openTasks.map((t) => t.id), ['t1']);

      final json = context.toJson();
      expect(json.keys, [
        'garden',
        'zones',
        'recentActivities',
        'openTasks',
        'inventory',
        'calculations',
      ]);
      final items = json['inventory']! as List;
      expect((items.first as Map)['details'], {
        'n': 10.0,
        'form': 'granular',
        'labelDose': '60 g/m²',
      });
      expect((items.last as Map)['details'], {
        'species': 'mrkev',
        'variety': 'Nantes',
      });
      expect((json['openTasks']! as List).single, {
        'title': 'Zalít',
        'due': '2026-10-09',
      });

      final summary = context.summary;
      expect(summary.zoneNames, ['Zelenina']);
      expect(summary.activityCount, 2);
      expect(ContextSummary.fromJson(summary.toJson()), summary);
    });
  });

  group('safety check (FR-B4)', () {
    final calculations = [zoneDose(cererit, vegetables)!];

    List<SafetyWarning> check(String answer, {String question = 'Co dál?'}) =>
        checkAnswer(
          answer: answer,
          question: question,
          calculations: calculations,
          inventory: const [cererit, bioSpray, proSpray],
        );

    test('doses from calculations, labels or the question pass', () {
      expect(check('Na Zeleninu dej 1,2 kg Cereritu (60 g/m²).'), isEmpty);
      expect(check('Dej 1200 g hnojiva.'), isEmpty);
      expect(check('Dej 30 g/m².', question: 'Stačí 30 g na m2?'), isEmpty);
    });

    test('made-up doses are flagged', () {
      expect(check('Pohnoj dávkou 80 g/m² a pak zalij.'), [
        const UnverifiedDose('80 g/m²'),
      ]);
      expect(check('Cererit dej 2 kg.'), [const UnverifiedDose('2 kg')]);
    });

    test('amounts outside dosing are not checked', () {
      expect(check('Zalij 10 l vody a počkej 2 dny.'), isEmpty);
    });

    test('professional-only products and missing PHI are flagged', () {
      expect(check('Můžeš použít Profistop.'), [
        const ProfessionalOnly('Profistop'),
      ]);
      expect(check('Postříkej Bioolem.'), [const MissingPhi('Biool')]);
      expect(check('Postříkej Bioolem, ochranná lhůta je 0 dní.'), isEmpty);
    });

    test('warnings survive JSON', () {
      for (final w in const [
        UnverifiedDose('80 g/m²'),
        ProfessionalOnly('X'),
        MissingPhi('Y'),
      ]) {
        expect(SafetyWarning.fromJson(w.toJson()), w);
      }
    });
  });

  group('backend contract', () {
    test('a reply parses actions and usage, invalid actions are dropped', () {
      final reply = AssistantReply.fromJson({
        'answer': ' Pohnoj. ',
        'actions': [
          {'type': 'task', 'title': 'Pohnojit', 'due': '2026-10-10'},
          {'type': 'shopping', 'name': 'Cererit', 'qty': 2, 'unit': 'kg'},
          {'type': 'activity', 'title': 'Hnojení', 'activityType': 'x'},
          {'type': 'task'},
          'nonsense',
        ],
        'usage': {'used': 3, 'limit': 10, 'plan': 'free'},
      })!;
      expect(reply.answer, 'Pohnoj.');
      expect(reply.actions, [
        TaskAction(title: 'Pohnojit', due: DateTime(2026, 10, 10)),
        const ShoppingAction(name: 'Cererit', qty: 2, unit: InventoryUnit.kg),
        const ActivityAction(title: 'Hnojení', type: ActivityType.other),
      ]);
      expect(
        reply.usage,
        const AssistantUsage(used: 3, limit: 10, plan: 'free'),
      );
      expect(AssistantReply.fromJson({'answer': ''}), isNull);
    });

    test('message meta round-trips through JSON', () {
      final meta = MessageMeta(
        context: const ContextSummary(zoneNames: ['Zelenina'], taskCount: 2),
        actions: [TaskAction(title: 'A', due: DateTime(2026, 10, 9))],
        warnings: const [UnverifiedDose('80 g/m²')],
        usage: const AssistantUsage(used: 1, limit: 10),
        demo: true,
        failure: AssistantFailureKind.limitReached,
      );
      expect(MessageMeta.fromJson(meta.toJson()), meta);
      expect(MessageMeta.fromJson('broken'), const MessageMeta());
    });
  });
}
