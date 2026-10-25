import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Mensaje con ilustración (imagen de assets dentro de un círculo).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    required this.message,
    this.circleSize = 120,
    this.isError = false,
    this.action,
    this.topPadding = 28,
    this.titleSize = 17,
  });

  final String imagePath;
  final String title;
  final String message;
  final double circleSize;
  final bool isError;
  final Widget? action;
  final double topPadding;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final bg = isError ? cs.errorContainer : cs.primaryContainer;
    final fg = isError ? cs.error : cs.primary;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            padding: EdgeInsets.all(circleSize * 0.27),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Image.asset(imagePath, color: fg, colorBlendMode: BlendMode.srcIn),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: context.ts(titleSize, FontWeight.w600)),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(message,
                textAlign: TextAlign.center,
                style: context.ts(13, FontWeight.w400, color: cs.onSurfaceVariant)),
          ),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}
