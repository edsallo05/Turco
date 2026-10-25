import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/sheet_handle.dart';

enum QuickAction { complete, cancel }

/// Hoja de acciones rápidas (pulsación larga sobre un turno programado).
Future<QuickAction?> showQuickActionsSheet(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return showModalBottomSheet<QuickAction>(
    context: context,
    builder: (ctx) {
      final cs = ctx.cs;
      Widget row(IconData icon, Color color, String label, QuickAction action) {
        return InkWell(
          onTap: () => Navigator.of(ctx).pop(action),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 16),
                Expanded(child: Text(label, style: ctx.ts(15, FontWeight.w500, color: color == cs.error ? cs.error : cs.onSurface))),
              ],
            ),
          ),
        );
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerLeft, child: Text(title, style: ctx.ts(17, FontWeight.w600))),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(subtitle, style: ctx.ts(13, FontWeight.w400, color: cs.onSurfaceVariant)),
              ),
              const SizedBox(height: 14),
              row(AppIcons.circleCheck, cs.tertiary, 'Marcar como completado', QuickAction.complete),
              row(AppIcons.ban, cs.error, 'Cancelar turno', QuickAction.cancel),
            ],
          ),
        ),
      );
    },
  );
}
