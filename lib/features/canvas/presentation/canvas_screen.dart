import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/di/providers.dart';
import '../../../core/text/numbers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../zones/domain/zone_entity.dart';
import '../../zones/domain/zone_rules.dart';
import '../../zones/presentation/zone_icons.dart';
import '../../zones/presentation/zones_controller.dart';
import '../domain/geometry.dart';
import 'canvas_controller.dart';
import 'plan_painter.dart';

/// Plán zahrady (MVP 1.1, kap. 5.1): obrys, zóny jako polygony,
/// kalibrace, vrstvy Realita a Návrh, zpět a znovu.
class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  CanvasController get _c => ref.read(canvasControllerProvider.notifier);

  void _snack(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), action: action));
  }

  /// Nabídne převzít výměru z plánu (FR-P4).
  void _suggestArea(AreaSuggestion? s) {
    if (s == null || s.currentArea == null || !mounted) return;
    final l = AppLocalizations.of(context);
    _snack(
      l.canvasAreaSuggest(
        s.zoneName,
        formatDecimal(s.planArea, maxFractionDigits: 1),
        formatDecimal(s.currentArea!, maxFractionDigits: 1),
      ),
      action: SnackBarAction(
        label: l.canvasAreaUse,
        onPressed: () => _c.applyPlanArea(s.zoneId),
      ),
    );
  }

  Future<void> _onTap(Pt point) async {
    switch (_c.tap(point)) {
      case TapOutcome.none:
        return;
      case TapOutcome.zoneClosed:
        await _assignZone();
      case TapOutcome.needLength:
        await _askLength();
    }
  }

  Future<void> _close() async {
    if (_c.closeDraft() == TapOutcome.zoneClosed) await _assignZone();
  }

  Future<void> _assignZone() async {
    final l = AppLocalizations.of(context);
    if (!_c.draftInsideOutline) _snack(l.canvasOutsideOutline);
    final planned =
        ref.read(canvasControllerProvider).value?.drawLayer == ZoneLayer.plan;
    final choice = await showModalBottomSheet<_Assignment>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AssignSheet(zones: _c.assignableZones, planned: planned),
    );
    if (choice == null || !mounted) return;
    try {
      final suggestion = await _c.assignDraft(
        zoneId: choice.zoneId,
        newName: choice.name,
        newType: choice.type,
      );
      _suggestArea(suggestion);
    } on ZoneNameError catch (e) {
      _snack(e == ZoneNameError.empty ? l.zoneNameEmpty : l.zoneNameDuplicate);
    }
  }

  Future<void> _askLength() async {
    final s = ref.read(canvasControllerProvider).value;
    if (s == null || s.draft.length != 2) return;
    final drawn = s.draft[0].distanceTo(s.draft[1]);
    final real = await showDialog<double>(
      context: context,
      builder: (_) => _LengthDialog(drawn: drawn),
    );
    if (real == null || !mounted) {
      _c.clearDraft();
      return;
    }
    final l = AppLocalizations.of(context);
    if (s.tool == CanvasTool.calibrate) {
      await _c.calibrate(real);
      _snack(l.canvasCalibrated);
    } else {
      final deviation = _c.measure(real);
      final value = formatDecimal(deviation, maxFractionDigits: 1);
      _snack(
        deviation > maxCalibrationDeviationPercent
            ? l.canvasDeviationBad(value)
            : l.canvasDeviationOk(value),
      );
    }
  }

  Future<void> _pickBackground() async {
    final l = AppLocalizations.of(context);
    final photos = ref.read(photoStorageProvider);
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2560,
      maxHeight: 2560,
      imageQuality: 85,
    );
    if (picked == null) return;
    try {
      final bytes = await picked.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final image = (await codec.getNextFrame()).image;
      final relative = p.join(
        'plan',
        'background_${ref.read(newIdProvider)()}.jpg',
      );
      final target = File(p.join(photos.rootPath, relative));
      await target.parent.create(recursive: true);
      await target.writeAsBytes(bytes);
      final old = ref.read(canvasControllerProvider).value?.background;
      await _c.setBackground(
        path: relative,
        widthPx: image.width,
        heightPx: image.height,
      );
      image.dispose();
      if (old != null) _deleteFile(photos.resolve(old.path));
    } on Exception {
      if (mounted) _snack(l.canvasBackgroundFailed);
    }
  }

  void _deleteFile(String? path) {
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }

  Future<void> _menu(String action) async {
    switch (action) {
      case 'snap':
        _c.toggleSnap();
      case 'background':
        await _pickBackground();
      case 'removeBackground':
        final path = ref.read(canvasControllerProvider).value?.background?.path;
        await _c.removeBackground();
        _deleteFile(ref.read(photoStorageProvider).resolve(path));
      case 'removeOutline':
        await _c.removeOutline();
    }
  }

  String _hint(AppLocalizations l, CanvasState s) => switch (s.tool) {
    CanvasTool.select =>
      s.doc.hasOutline || s.doc.shapes.isNotEmpty ? '' : l.canvasEmptyHint,
    CanvasTool.outline => l.canvasHintOutline,
    CanvasTool.zone => l.canvasHintZone,
    CanvasTool.edit => l.canvasHintEdit,
    CanvasTool.calibrate => l.canvasHintCalibrate,
    CanvasTool.measure => l.canvasHintMeasure,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(canvasControllerProvider);
    final s = async.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.canvasTitle),
        actions: [
          IconButton(
            tooltip: l.canvasUndo,
            onPressed: s?.canUndo ?? false ? _c.undo : null,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: l.canvasRedo,
            onPressed: s?.canRedo ?? false ? _c.redo : null,
            icon: const Icon(Icons.redo),
          ),
          PopupMenuButton<String>(
            tooltip: l.canvasMore,
            onSelected: _menu,
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: 'snap',
                checked: s?.snap ?? true,
                child: Text(l.canvasSnap),
              ),
              if (!kIsWeb)
                PopupMenuItem(
                  value: 'background',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.canvasBackgroundPick),
                    subtitle: Text(l.canvasBackgroundHelp),
                  ),
                ),
              if (s?.background != null)
                PopupMenuItem(
                  value: 'removeBackground',
                  child: Text(l.canvasBackgroundRemove),
                ),
              if (s?.doc.hasOutline ?? false)
                PopupMenuItem(
                  value: 'removeOutline',
                  child: Text(l.canvasRemoveOutline),
                ),
            ],
          ),
        ],
      ),
      body: async.when(
        skipError: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadErrorView(error: error, stack: stack),
        data: (s) {
          final hint = _hint(l, s);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: SegmentedButton<LayerView>(
                  segments: [
                    ButtonSegment(
                      value: LayerView.reality,
                      label: Text(l.canvasLayerReality),
                    ),
                    ButtonSegment(
                      value: LayerView.plan,
                      label: Text(l.canvasLayerPlan),
                    ),
                    ButtonSegment(
                      value: LayerView.both,
                      label: Text(l.canvasLayerBoth),
                    ),
                  ],
                  selected: {s.view},
                  onSelectionChanged: (v) => _c.setView(v.first),
                ),
              ),
              if (hint.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Expanded(
                child: _PlanView(
                  state: s,
                  onTap: _onTap,
                  onDragEnd: () async => _suggestArea(await _c.dragEnd()),
                ),
              ),
              _BottomBar(state: s, onClose: _close, onSuggest: _suggestArea),
            ],
          );
        },
      ),
      bottomNavigationBar: s == null
          ? null
          : NavigationBar(
              selectedIndex: switch (s.tool) {
                CanvasTool.select || CanvasTool.edit => 0,
                CanvasTool.outline => 1,
                CanvasTool.zone => 2,
                CanvasTool.calibrate => 3,
                CanvasTool.measure => 4,
              },
              onDestinationSelected: (i) => _c.setTool(
                const [
                  CanvasTool.select,
                  CanvasTool.outline,
                  CanvasTool.zone,
                  CanvasTool.calibrate,
                  CanvasTool.measure,
                ][i],
              ),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.touch_app_outlined),
                  label: l.canvasToolSelect,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.crop_square),
                  label: l.canvasToolOutline,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pentagon_outlined),
                  label: l.canvasToolZone,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.straighten),
                  label: l.canvasToolCalibrate,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.rule),
                  label: l.canvasToolMeasure,
                ),
              ],
            ),
    );
  }
}

/// Posuvné a zvětšitelné plátno s podkladem a kresbou.
class _PlanView extends ConsumerStatefulWidget {
  const _PlanView({
    required this.state,
    required this.onTap,
    required this.onDragEnd,
  });

  final CanvasState state;
  final void Function(Pt) onTap;
  final VoidCallback onDragEnd;

  @override
  ConsumerState<_PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends ConsumerState<_PlanView> {
  final _transform = TransformationController();

  /// Plán se přizpůsobí oknu jen při otevření, ne při každé změně kresby.
  bool _fitted = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// Na telefonu by plán začínal v rohu plátna a zahrada by ležela
  /// napůl mimo obrazovku; proto se po otevření vycentruje a zmenší.
  void _fitOnce(PlanFrame frame, Size viewport) {
    if (_fitted || viewport.isEmpty) return;
    _fitted = true;
    final s = widget.state;
    final fit = fitPlanToView(frame, [
      ...s.doc.allPoints,
      if (s.background case final b?) ...[
        b.origin,
        b.origin + Pt(b.widthM, b.heightM),
      ],
    ], viewport);
    if (fit != null) _transform.value = fit;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onTap = widget.onTap;
    final onDragEnd = widget.onDragEnd;
    final l = AppLocalizations.of(context);
    final controller = ref.read(canvasControllerProvider.notifier);
    final zones = <String, ZoneEntity>{
      for (final z
          in ref.watch(zonesControllerProvider).value ?? const <ZoneEntity>[])
        z.id: z,
    };
    final frame = PlanFrame.of(state);
    final theme = Theme.of(context);
    final background = state.background;
    final backgroundFile = background == null || kIsWeb
        ? null
        : ref.read(photoStorageProvider).resolve(background.path);
    final editing = state.tool == CanvasTool.edit;
    return Semantics(
      label: l.canvasSemantics(state.doc.shapes.length),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _fitOnce(frame, constraints.biggest);
          return InteractiveViewer(
            transformationController: _transform,
            constrained: false,
            minScale: 0.2,
            maxScale: 8,
            panEnabled: !editing,
            boundaryMargin: const EdgeInsets.all(200),
            child: GestureDetector(
              onTapUp: (d) => onTap(frame.toMeters(d.localPosition)),
              onPanStart: editing
                  ? (d) => controller.dragStart(frame.toMeters(d.localPosition))
                  : null,
              onPanUpdate: editing
                  ? (d) =>
                        controller.dragUpdate(frame.toMeters(d.localPosition))
                  : null,
              onPanEnd: editing ? (_) => onDragEnd() : null,
              child: SizedBox.fromSize(
                size: frame.size,
                child: Stack(
                  children: [
                    if (background != null && backgroundFile != null)
                      Positioned(
                        left: frame.toPx(background.origin).dx,
                        top: frame.toPx(background.origin).dy,
                        width: background.widthM * pixelsPerMeter,
                        height: background.heightM * pixelsPerMeter,
                        child: Opacity(
                          opacity: 0.55,
                          child: Image.file(
                            File(backgroundFile),
                            fit: BoxFit.fill,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PlanPainter(
                          state: state,
                          frame: frame,
                          zones: zones,
                          scheme: theme.colorScheme,
                          textStyle: theme.textTheme.labelMedium!.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Akce k rozkreslenému tvaru nebo k výběru.
class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.state,
    required this.onClose,
    required this.onSuggest,
  });

  final CanvasState state;
  final VoidCallback onClose;
  final void Function(AreaSuggestion?) onSuggest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = ref.read(canvasControllerProvider.notifier);
    final s = state;
    final drawing = s.tool == CanvasTool.outline || s.tool == CanvasTool.zone;
    if (drawing && s.draft.isNotEmpty) {
      return _Bar(
        children: [
          TextButton(onPressed: c.clearDraft, child: Text(l.canvasDiscard)),
          FilledButton(
            onPressed: s.draft.length >= 3 ? onClose : null,
            child: Text(l.canvasDone),
          ),
        ],
      );
    }
    final selected = s.selected;
    final polygon = s.selectedPolygon;
    if (selected == null || polygon == null) return const SizedBox.shrink();
    final area = formatDecimal(polygonArea(polygon), maxFractionDigits: 1);
    final shape = s.doc.shapes[selected];
    final zone = selected == outlineSelection
        ? null
        : ref.watch(zoneByIdProvider(selected));
    final title = selected == outlineSelection
        ? l.canvasSelectedOutline(area)
        : shape?.layer == ZoneLayer.plan
        ? l.canvasSelectedPlanned(zone?.name ?? '', area)
        : l.canvasSelectedZone(zone?.name ?? '', area);
    final editing = s.tool == CanvasTool.edit;
    return _Bar(
      title: title,
      leading: zone == null ? null : Icon(zoneIcon(zone.type)),
      children: [
        if (editing) ...[
          if (s.selectedVertex != null && polygon.length > 3)
            TextButton(
              onPressed: () async => onSuggest(await c.deleteSelectedVertex()),
              child: Text(l.canvasDeleteVertex),
            ),
          FilledButton.tonal(
            onPressed: () => c.setTool(CanvasTool.select),
            child: Text(l.canvasEditDone),
          ),
        ] else ...[
          if (shape?.layer == ZoneLayer.plan && zone != null)
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await c.realize(
                  selected,
                  activityTitle: l.canvasRealizedActivity(zone.name),
                );
                final failed = ref.read(canvasControllerProvider).hasError;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      failed ? l.commonSaveFailed : l.canvasRealized(zone.name),
                    ),
                  ),
                );
              },
              child: Text(l.canvasRealize),
            ),
          if (shape != null)
            TextButton(
              onPressed: () => c.removeShape(selected),
              child: Text(l.canvasRemoveShape),
            ),
          FilledButton.tonal(
            onPressed: c.editSelected,
            child: Text(l.canvasEditNodes),
          ),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.children, this.title, this.leading});

  final List<Widget> children;
  final String? title;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainer,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          Wrap(alignment: WrapAlignment.end, spacing: 8, children: children),
        ],
      ),
    ),
  );
}

/// Volba zóny pro nakreslený tvar.
class _Assignment {
  const _Assignment({this.zoneId, this.name, this.type = ZoneType.other});

  final String? zoneId;
  final String? name;
  final ZoneType type;
}

class _AssignSheet extends StatefulWidget {
  const _AssignSheet({required this.zones, required this.planned});

  final List<ZoneEntity> zones;
  final bool planned;

  @override
  State<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends State<_AssignSheet> {
  final _name = TextEditingController();
  var _type = ZoneType.other;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            l.canvasAssignTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final z in widget.zones)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(zoneIcon(z.type)),
              title: Text(z.name),
              onTap: () => Navigator.of(context).pop(_Assignment(zoneId: z.id)),
            ),
          const Divider(),
          Text(
            l.canvasAssignNew,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (widget.planned)
            Text(
              l.canvasAssignPlanned,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l.canvasAssignNewName),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final t in ZoneType.values)
                ChoiceChip(
                  avatar: Icon(zoneIcon(t), size: 18),
                  label: Text(zoneTypeLabel(l, t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(_Assignment(name: _name.text, type: _type)),
            child: Text(l.canvasAssignCreate),
          ),
        ],
      ),
    );
  }
}

/// Skutečná délka úsečky (kalibrace a kontrola, FR-P2).
class _LengthDialog extends StatefulWidget {
  const _LengthDialog({required this.drawn});

  final double drawn;

  @override
  State<_LengthDialog> createState() => _LengthDialogState();
}

class _LengthDialogState extends State<_LengthDialog> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseDecimal(_text.text);
    if (value == null || value <= 0) {
      setState(() => _error = AppLocalizations.of(context).canvasLengthInvalid);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.canvasLengthTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.canvasLengthDrawn(
              formatDecimal(widget.drawn, maxFractionDigits: 2),
            ),
          ),
          TextField(
            controller: _text,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.canvasLengthLabel,
              errorText: _error,
              suffixText: 'm',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.commonSave)),
      ],
    );
  }
}
