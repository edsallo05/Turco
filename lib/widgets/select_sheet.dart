import 'package:flutter/material.dart';

import '../core/theme/app_icons.dart';
import '../core/theme/app_theme.dart';
import 'sheet_handle.dart';

class SelectOption<T> {
  const SelectOption({required this.value, required this.label, this.subtitle});
  final T value;
  final String label;
  final String? subtitle;
}

/// Hoja inferior para elegir una opción (cliente, estilista).
Future<T?> showSelectSheet<T>(
  BuildContext context, {
  required String title,
  required List<SelectOption<T>> options,
  T? selected,
  String emptyMessage = 'No hay opciones disponibles.',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final cs = ctx.cs;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: ctx.ts(17, FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              if (options.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(emptyMessage, style: ctx.ts(13, FontWeight.w400, color: cs.onSurfaceVariant)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final o = options[i];
                      final isSel = o.value == selected;
                      return InkWell(
                        onTap: () => Navigator.of(ctx).pop(o.value),
                        child: SizedBox(
                          height: 52,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(o.label, style: ctx.ts(15, FontWeight.w500)),
                                    if (o.subtitle != null)
                                      Text(o.subtitle!, style: ctx.ts(12, FontWeight.w400, color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              if (isSel) Icon(AppIcons.check, size: 18, color: cs.primary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
