import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Fotka záznamu, nebo ikona, pokud fotka chybí či nejde načíst.
///
/// [path] je cesta tak, jak je uložená v záznamu (obvykle relativní);
/// plnou cestu dopočítá [PhotoStorage.resolve].
class ActivityPhoto extends ConsumerWidget {
  const ActivityPhoto({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.iconSize = 28,
  });

  final String? path;
  final double? width;
  final double? height;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(Icons.local_florist, size: iconSize, color: scheme.primary),
    );

    final resolved = kIsWeb
        ? null
        : ref.watch(photoStorageProvider).resolve(path);
    if (resolved == null) return placeholder;

    // Náhled v seznamu nedekódujeme v plném rozlišení, šetří to paměť
    // i plynulost posouvání dlouhého deníku.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = width == null ? null : (width! * dpr).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(resolved),
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        fit: BoxFit.cover,
        semanticLabel: AppLocalizations.of(context).photoSemantic,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

/// Fotky záznamu přes celou obrazovku: listování do stran, přiblížení
/// dvěma prsty.
class PhotoViewerScreen extends ConsumerStatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.paths,
    required this.title,
    this.initialIndex = 0,
  });

  final List<String> paths;
  final String title;
  final int initialIndex;

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final storage = ref.watch(photoStorageProvider);
    final count = widget.paths.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          count > 1
              ? l.photoViewerTitle(widget.title, _index + 1, count)
              : widget.title,
        ),
      ),
      body: PageView.builder(
        controller: _pages,
        itemCount: count,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          final resolved = storage.resolve(widget.paths[i]);
          if (resolved == null) return const SizedBox.shrink();
          return InteractiveViewer(
            maxScale: 5,
            child: Center(
              child: Image.file(
                File(resolved),
                semanticLabel: l.photoSemanticOf(widget.title),
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
