import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fotka záznamu, nebo ikona, pokud fotka chybí či nejde načíst.
class ActivityPhoto extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.local_florist,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    final p = path;
    if (kIsWeb || p == null || p.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(p),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
