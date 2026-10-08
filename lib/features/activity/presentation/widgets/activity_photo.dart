import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

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
        semanticLabel: 'Fotka záznamu',
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

/// Fotka přes celou obrazovku s přiblížením dvěma prsty.
class PhotoViewerScreen extends ConsumerWidget {
  const PhotoViewerScreen({super.key, required this.path, required this.title});

  final String path;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = ref.watch(photoStorageProvider).resolve(path);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: resolved == null
          ? const SizedBox.shrink()
          : InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.file(
                  File(resolved),
                  semanticLabel: 'Fotka záznamu $title',
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
    );
  }
}
