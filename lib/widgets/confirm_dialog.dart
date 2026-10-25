import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Diálogo de confirmación del diseño: icono arriba a la izquierda, título,
/// mensaje y dos acciones de texto alineadas a la derecha.
/// Devuelve true si el usuario confirma.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = ctx.cs;
      final accent = destructive ? cs.error : cs.primary;
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: accent),
              const SizedBox(height: 14),
              Text(title, style: ctx.ts(20, FontWeight.w600)),
              const SizedBox(height: 14),
              Text(message, style: ctx.ts(14, FontWeight.w400, color: cs.onSurfaceVariant, height: 1.45)),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(cancelLabel),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: accent),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(confirmLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
