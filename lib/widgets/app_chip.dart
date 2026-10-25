import 'package:flutter/material.dart';

import '../core/theme/app_icons.dart';
import '../core/theme/app_theme.dart';

/// Chip del diseño: 32 dp de alto, radio 8. Seleccionado = secondaryContainer + check.
class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: selected ? BorderSide.none : BorderSide(color: cs.outlineVariant),
    );
    final fg = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    return Material(
      color: selected ? cs.secondaryContainer : kTransparent,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(AppIcons.check, size: 14, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(label, style: context.ts(13, FontWeight.w500, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
