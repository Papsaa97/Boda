import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../activity/domain/activity_type.dart';
import '../../activity/presentation/controllers/activity_controller.dart';
import '../../zones/domain/zone_entity.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/geometry.dart';
import '../domain/plan_document.dart';
import '../domain/plan_repository.dart';
import '../domain/edit_history.dart';

/// Nástroj plátna.
enum CanvasTool {
  /// Výběr zóny klepnutím, posun a zvětšení plátna.
  select,

  /// Kreslení obrysu zahrady (FR-P1).
  outline,

  /// Kreslení tvaru zóny (FR-P4).
  zone,

  /// Úprava uzlů vybraného tvaru: posun, přidání, smazání (FR-P1).
  edit,

  /// Kalibrace délkou úsečky (FR-P2).
  calibrate,

  /// Kontrolní vzdálenost po kalibraci (FR-P2).
  measure,
}

/// Které vrstvy jsou vidět (FR-P5).
enum LayerView { reality, plan, both }

/// Id výběru pro obrys zahrady (zóny mají své UUID).
const outlineSelection = '#outline';

/// Co je na plánu a v historii zpět/znovu (podklad mění kalibrace).
class PlanSnapshot extends Equatable {
  const PlanSnapshot(this.doc, this.background);

  final PlanDocument doc;
  final PlanBackground? background;

  @override
  List<Object?> get props => [doc, background];
}

class CanvasState extends Equatable {
  const CanvasState({
    required this.plan,
    this.tool = CanvasTool.select,
    this.view = LayerView.both,
    this.snap = true,
    this.draft = const [],
    this.selected,
    this.selectedVertex,
    this.canUndo = false,
    this.canRedo = false,
  });

  final PlanSnapshot plan;
  final CanvasTool tool;
  final LayerView view;

  /// Přitahování k mřížce [gridStep].
  final bool snap;

  /// Rozkreslené body (obrys, zóna) nebo body úsečky (kalibrace, měření).
  final List<Pt> draft;

  /// Vybraná zóna (id) nebo [outlineSelection].
  final String? selected;
  final int? selectedVertex;
  final bool canUndo;
  final bool canRedo;

  PlanDocument get doc => plan.doc;
  PlanBackground? get background => plan.background;

  /// Vrstva, do které jde nově nakreslená zóna.
  ZoneLayer get drawLayer =>
      view == LayerView.plan ? ZoneLayer.plan : ZoneLayer.reality;

  bool shows(ZoneLayer layer) => switch (view) {
    LayerView.both => true,
    LayerView.reality => layer == ZoneLayer.reality,
    LayerView.plan => layer == ZoneLayer.plan,
  };

  /// Body tvaru, který se právě upravuje nebo je vybraný.
  List<Pt>? get selectedPolygon => selected == null
      ? null
      : selected == outlineSelection
      ? (doc.hasOutline ? doc.outline : null)
      : doc.shapes[selected]?.polygon;

  CanvasState copyWith({
    PlanSnapshot? plan,
    CanvasTool? tool,
    LayerView? view,
    bool? snap,
    List<Pt>? draft,
    String? Function()? selected,
    int? Function()? selectedVertex,
    bool? canUndo,
    bool? canRedo,
  }) => CanvasState(
    plan: plan ?? this.plan,
    tool: tool ?? this.tool,
    view: view ?? this.view,
    snap: snap ?? this.snap,
    draft: draft ?? this.draft,
    selected: selected == null ? this.selected : selected(),
    selectedVertex: selectedVertex == null
        ? this.selectedVertex
        : selectedVertex(),
    canUndo: canUndo ?? this.canUndo,
    canRedo: canRedo ?? this.canRedo,
  );

  @override
  List<Object?> get props => [
    plan,
    tool,
    view,
    snap,
    draft,
    selected,
    selectedVertex,
    canUndo,
    canRedo,
  ];
}

/// Krok mřížky v metrech (FR-P1).
const gridStep = 0.5;

/// Jak blízko (v metrech) musí být klepnutí k uzlu.
const vertexTolerance = 0.6;

/// Co má plátno po klepnutí udělat dál.
enum TapOutcome {
  none,

  /// Tvar zóny je uzavřený: zeptat se, ke které zóně patří.
  zoneClosed,

  /// Úsečka má oba body: zeptat se na skutečnou délku.
  needLength,
}

/// Výměra zóny podle plánu, když se liší od zadané (FR-P4).
class AreaSuggestion extends Equatable {
  const AreaSuggestion({
    required this.zoneId,
    required this.zoneName,
    required this.planArea,
    this.currentArea,
  });

  final String zoneId;
  final String zoneName;
  final double planArea;

  /// Ručně zadaná výměra; null = výměra se nastavila sama.
  final double? currentArea;

  @override
  List<Object?> get props => [zoneId, zoneName, planArea, currentArea];
}

/// Plán zahrady (kap. 5.1): kreslení, úpravy, kalibrace, vrstvy, zpět.
/// Každý krok se hned uloží (obrys do zahrady, tvary do zón).
class CanvasController extends AsyncNotifier<CanvasState> {
  late EditHistory<PlanSnapshot> _history;
  PlanSnapshot? _dragStart;

  @override
  Future<CanvasState> build() async {
    final repo = ref.read(planRepositoryProvider);
    final outline = await repo.loadOutline();
    final background = await repo.loadBackground();
    final zones = await ref.read(zonesControllerProvider.future);
    final plan = PlanSnapshot(
      PlanDocument(
        outline: outline,
        shapes: {
          for (final z in zones)
            if (!z.archived && z.polygon != null)
              z.id: ZoneShape(z.polygon!, layer: z.layer),
        },
      ),
      background,
    );
    _history = EditHistory(plan);
    return CanvasState(plan: plan);
  }

  CanvasState get _s => state.requireValue;

  void _set(CanvasState next) => state = AsyncData(
    next.copyWith(canUndo: _history.canUndo, canRedo: _history.canRedo),
  );

  void setTool(CanvasTool tool) {
    final keepSelection = tool == CanvasTool.edit || tool == CanvasTool.select;
    _set(
      _s.copyWith(
        tool: tool,
        draft: const [],
        selected: keepSelection ? null : () => null,
        selectedVertex: () => null,
      ),
    );
  }

  void setView(LayerView view) => _set(_s.copyWith(view: view));

  void toggleSnap() => _set(_s.copyWith(snap: !_s.snap));

  /// Úprava uzlů vybraného tvaru.
  void editSelected() {
    if (_s.selectedPolygon == null) return;
    _set(_s.copyWith(tool: CanvasTool.edit, selectedVertex: () => null));
  }

  Pt _snapped(Pt p) => _s.snap ? snapToGrid(p, gridStep) : p;

  /// Klepnutí na plán (souřadnice v metrech).
  TapOutcome tap(Pt p) {
    final s = _s;
    switch (s.tool) {
      case CanvasTool.select:
        _set(s.copyWith(selected: () => _hit(p), selectedVertex: () => null));
        return TapOutcome.none;
      case CanvasTool.outline:
      case CanvasTool.zone:
        final draft = s.draft;
        if (draft.length >= 3 && draft.first.distanceTo(p) <= vertexTolerance) {
          return _closeDraft();
        }
        _set(s.copyWith(draft: [...draft, _snapped(p)]));
        return TapOutcome.none;
      case CanvasTool.calibrate:
      case CanvasTool.measure:
        final draft = s.draft.length >= 2 ? <Pt>[] : s.draft;
        final next = [...draft, p];
        _set(s.copyWith(draft: next));
        return next.length == 2 ? TapOutcome.needLength : TapOutcome.none;
      case CanvasTool.edit:
        final polygon = s.selectedPolygon;
        if (polygon == null) return TapOutcome.none;
        final vertex = nearestVertex(polygon, p, vertexTolerance);
        if (vertex != null) {
          _set(s.copyWith(selectedVertex: () => vertex));
          return TapOutcome.none;
        }
        final mid = nearestVertex(edgeMidpoints(polygon), p, vertexTolerance);
        if (mid != null) {
          final before = s.plan;
          _commitPolygon([...polygon]..insert(mid + 1, _snapped(p)));
          _set(_s.copyWith(selectedVertex: () => mid + 1));
          unawaited(_persist(before, _s.plan));
        }
        return TapOutcome.none;
    }
  }

  /// Uzavře rozkreslený tvar tlačítkem „Hotovo“.
  TapOutcome closeDraft() =>
      _s.draft.length >= 3 ? _closeDraft() : TapOutcome.none;

  TapOutcome _closeDraft() {
    final s = _s;
    if (!isUsablePolygon(s.draft)) return TapOutcome.none;
    if (s.tool == CanvasTool.outline) {
      final next = PlanSnapshot(s.doc.withOutline(s.draft), s.background);
      _commit(
        next,
        s.copyWith(
          draft: const [],
          tool: CanvasTool.select,
          selected: () => outlineSelection,
        ),
      );
      unawaited(_persist(s.plan, next));
      return TapOutcome.none;
    }
    return TapOutcome.zoneClosed;
  }

  void clearDraft() => _set(_s.copyWith(draft: const []));

  /// Leží rozkreslená zóna celá v obrysu? (bez obrysu vždy ano)
  bool get draftInsideOutline {
    final s = _s;
    return !s.doc.hasOutline || polygonWithin(s.draft, s.doc.outline);
  }

  /// Zóny bez tvaru, ke kterým jde nakreslený tvar přiřadit.
  List<ZoneEntity> get assignableZones {
    final zones = ref.read(zonesControllerProvider).value ?? const [];
    return [
      for (final z in zones)
        if (!z.archived && !_s.doc.shapes.containsKey(z.id)) z,
    ];
  }

  /// Přiřadí rozkreslený tvar existující zóně, nebo založí novou.
  /// Vrací návrh výměry, když se liší od zadané.
  Future<AreaSuggestion?> assignDraft({
    String? zoneId,
    String? newName,
    ZoneType newType = ZoneType.other,
  }) async {
    final s = _s;
    final polygon = s.draft;
    final zones = ref.read(zonesControllerProvider.notifier);
    final layer = s.drawLayer;
    late final ZoneEntity zone;
    if (zoneId != null) {
      final existing = ref.read(zoneByIdProvider(zoneId));
      if (existing == null) return null;
      zone = existing;
    } else {
      zone = ZoneEntity(
        id: ref.read(newIdProvider)(),
        name: newName?.trim() ?? '',
        type: newType,
        layer: layer,
      );
      final error = await zones.saveZone(zone);
      if (error != null) throw error;
    }
    final shape = ZoneShape(
      polygon,
      layer: zoneId == null ? layer : zone.layer,
    );
    final next = PlanSnapshot(s.doc.withShape(zone.id, shape), s.background);
    _commit(
      next,
      s.copyWith(
        draft: const [],
        tool: CanvasTool.select,
        selected: () => zone.id,
      ),
    );
    await _persist(s.plan, next);
    return _areaSuggestion(zone.id);
  }

  /// Výběr zóny nebo obrysu pod bodem; nejmenší tvar vyhrává.
  String? _hit(Pt p) {
    final s = _s;
    final hits = [
      for (final e in s.doc.shapes.entries)
        if (s.shows(e.value.layer) && polygonContainsPoint(e.value.polygon, p))
          e,
    ]..sort((a, b) => a.value.area.compareTo(b.value.area));
    if (hits.isNotEmpty) return hits.first.key;
    if (s.doc.hasOutline && polygonContainsPoint(s.doc.outline, p)) {
      return outlineSelection;
    }
    return null;
  }

  /// Začátek tahu: chytí uzel vybraného tvaru u bodu [p].
  bool dragStart(Pt p) {
    final s = _s;
    final polygon = s.selectedPolygon;
    if (s.tool != CanvasTool.edit || polygon == null) return false;
    final vertex = nearestVertex(polygon, p, vertexTolerance);
    if (vertex == null) return false;
    _dragStart = s.plan;
    _set(s.copyWith(selectedVertex: () => vertex));
    return true;
  }

  void dragUpdate(Pt p) {
    final s = _s;
    final vertex = s.selectedVertex;
    final polygon = s.selectedPolygon;
    if (_dragStart == null || vertex == null || polygon == null) return;
    final next = [...polygon]..[vertex] = _snapped(p);
    final plan = _withSelectedPolygon(next);
    _history.replace(plan);
    _set(s.copyWith(plan: plan));
  }

  Future<AreaSuggestion?> dragEnd() async {
    final before = _dragStart;
    _dragStart = null;
    if (before == null) return null;
    _history.commitFrom(before);
    _set(_s);
    await _persist(before, _s.plan);
    return _suggestionForSelected();
  }

  /// Smaže vybraný uzel (tvar musí mít aspoň 3 uzly).
  Future<AreaSuggestion?> deleteSelectedVertex() async {
    final s = _s;
    final vertex = s.selectedVertex;
    final polygon = s.selectedPolygon;
    if (vertex == null || polygon == null || polygon.length <= 3) return null;
    final before = s.plan;
    _commitPolygon([...polygon]..removeAt(vertex));
    _set(_s.copyWith(selectedVertex: () => null));
    await _persist(before, _s.plan);
    return _suggestionForSelected();
  }

  void _commitPolygon(List<Pt> polygon) {
    final next = _withSelectedPolygon(polygon);
    _history.push(next);
    _set(_s.copyWith(plan: next));
  }

  PlanSnapshot _withSelectedPolygon(List<Pt> polygon) {
    final s = _s;
    final selected = s.selected;
    final doc = selected == outlineSelection
        ? s.doc.withOutline(polygon)
        : s.doc.withShape(
            selected!,
            s.doc.shapes[selected]!.copyWith(polygon: polygon),
          );
    return PlanSnapshot(doc, s.background);
  }

  /// Kalibrace (FR-P2): úsečka z [draft] má skutečnou délku [realMeters].
  /// Celý plán i podklad se přepočte kolem prvního bodu úsečky.
  Future<void> calibrate(double realMeters) async {
    final s = _s;
    if (s.draft.length != 2) return;
    final k = calibrationFactor(
      drawn: s.draft[0].distanceTo(s.draft[1]),
      real: realMeters,
    );
    final center = s.draft[0];
    final next = PlanSnapshot(
      s.doc.scaled(center, k),
      s.background?.scaled(center, k),
    );
    _commit(next, s.copyWith(draft: const [], tool: CanvasTool.measure));
    await _persist(s.plan, next);
  }

  /// Kontrolní vzdálenost (FR-P2): odchylka v procentech.
  double measure(double realMeters) {
    final s = _s;
    final measured = s.draft[0].distanceTo(s.draft[1]);
    _set(s.copyWith(draft: const []));
    return deviationPercent(measured: measured, real: realMeters);
  }

  /// Zóna z Návrhu se zrealizuje: přejde do Reality a do deníku se
  /// zapíše záznam (FR-P5).
  Future<void> realize(String zoneId, {required String activityTitle}) async {
    final s = _s;
    final shape = s.doc.shapes[zoneId];
    if (shape == null || shape.layer != ZoneLayer.plan) return;
    final next = PlanSnapshot(
      s.doc.withShape(zoneId, shape.copyWith(layer: ZoneLayer.reality)),
      s.background,
    );
    _commit(next, s);
    await _persist(s.plan, next);
    await ref
        .read(activityControllerProvider.notifier)
        .addActivity(
          title: activityTitle,
          date: ref.read(clockProvider)(),
          zoneId: zoneId,
          type: ActivityType.other,
        );
  }

  /// Odebere tvar zóny z plánu (zóna zůstane v seznamu).
  Future<void> removeShape(String zoneId) async {
    final s = _s;
    if (!s.doc.shapes.containsKey(zoneId)) return;
    final next = PlanSnapshot(s.doc.withShape(zoneId, null), s.background);
    _commit(next, s.copyWith(selected: () => null, tool: CanvasTool.select));
    await _persist(s.plan, next);
  }

  /// Smaže obrys zahrady.
  Future<void> removeOutline() async {
    final s = _s;
    if (!s.doc.hasOutline) return;
    final next = PlanSnapshot(s.doc.withOutline(const []), s.background);
    _commit(next, s.copyWith(selected: () => null, tool: CanvasTool.select));
    await _persist(s.plan, next);
  }

  /// Vloží podklad (FR-P3). Výchozí měřítko: obrázek široký jako obrys,
  /// nebo 30 m; přesné měřítko nastaví kalibrace.
  Future<void> setBackground({
    required String path,
    required int widthPx,
    required int heightPx,
  }) async {
    final s = _s;
    final xs = s.doc.outline.map((p) => p.x);
    final width = s.doc.hasOutline
        ? xs.reduce((a, b) => a > b ? a : b) -
              xs.reduce((a, b) => a < b ? a : b)
        : 30.0;
    final next = PlanSnapshot(
      s.doc,
      PlanBackground(
        path: path,
        widthPx: widthPx,
        heightPx: heightPx,
        metersPerPixel: (width <= 0 ? 30.0 : width) / widthPx,
      ),
    );
    _commit(next, s);
    await _persist(s.plan, next);
  }

  Future<void> removeBackground() async {
    final s = _s;
    if (s.background == null) return;
    final next = PlanSnapshot(s.doc, null);
    _commit(next, s);
    await _persist(s.plan, next);
  }

  Future<void> undo() async {
    final before = _s.plan;
    final plan = _history.undo();
    _set(_s.copyWith(plan: plan, draft: const [], selectedVertex: () => null));
    await _persist(before, plan);
  }

  Future<void> redo() async {
    final before = _s.plan;
    final plan = _history.redo();
    _set(_s.copyWith(plan: plan, draft: const [], selectedVertex: () => null));
    await _persist(before, plan);
  }

  /// Použije výměru z plánu (FR-P4, uživatel potvrdil).
  Future<void> applyPlanArea(String zoneId) async {
    final zone = ref.read(zoneByIdProvider(zoneId));
    final shape = _s.doc.shapes[zoneId];
    if (zone == null || shape == null) return;
    await ref
        .read(zonesControllerProvider.notifier)
        .saveZone(zone.copyWith(areaM2: () => _round(shape.area)));
  }

  void _commit(PlanSnapshot next, CanvasState state) {
    _history.push(next);
    _set(state.copyWith(plan: next));
  }

  /// Uloží rozdíl mezi dvěma stavy plánu.
  Future<void> _persist(PlanSnapshot before, PlanSnapshot after) async {
    final repo = ref.read(planRepositoryProvider);
    if (before.doc.outline != after.doc.outline) {
      await repo.saveOutline(after.doc.outline);
    }
    if (before.background != after.background) {
      await repo.saveBackground(after.background);
    }
    final ids = {...before.doc.shapes.keys, ...after.doc.shapes.keys};
    final zones = ref.read(zonesControllerProvider.notifier);
    for (final id in ids) {
      final was = before.doc.shapes[id];
      final now = after.doc.shapes[id];
      if (was == now) continue;
      final zone = ref.read(zoneByIdProvider(id));
      if (zone == null) continue;
      var updated = zone.copyWith(
        polygon: () => now?.polygon,
        layer: now?.layer ?? zone.layer,
      );
      // Zóna bez ručně zadané výměry dostane výměru z plánu sama.
      if (now != null && zone.areaM2 == null) {
        updated = updated.copyWith(areaM2: () => _round(now.area));
      }
      await zones.saveZone(updated);
    }
  }

  AreaSuggestion? _suggestionForSelected() {
    final id = _s.selected;
    return id == null || id == outlineSelection ? null : _areaSuggestion(id);
  }

  /// Návrh převzít výměru z plánu, když se liší o víc než 1 %.
  AreaSuggestion? _areaSuggestion(String zoneId) {
    final zone = ref.read(zoneByIdProvider(zoneId));
    final shape = _s.doc.shapes[zoneId];
    if (zone == null || shape == null) return null;
    final area = _round(shape.area);
    final current = zone.areaM2;
    if (current != null && (current - area).abs() <= area * 0.01) return null;
    return AreaSuggestion(
      zoneId: zoneId,
      zoneName: zone.name,
      planArea: area,
      currentArea: current,
    );
  }
}

double _round(double area) => (area * 10).roundToDouble() / 10;

final canvasControllerProvider =
    AsyncNotifierProvider.autoDispose<CanvasController, CanvasState>(
      CanvasController.new,
    );
