import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/appointment_form_view_model.dart';

/// Cuadrícula de franjas de 30 min (GridView.builder, 4 columnas).
/// Dentro de un scroll: shrinkWrap + NeverScrollableScrollPhysics.
class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({super.key, required this.slots, required this.onSelect});
  final List<TimeSlot> slots;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 40,
      ),
      itemBuilder: (context, i) {
        final slot = slots[i];
        final BoxDecoration deco;
        final TextStyle style;
        if (slot.selected) {
          deco = BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10));
          style = context.ts(13, FontWeight.w600, color: cs.onPrimary);
        } else if (!slot.available) {
          deco = BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
          );
          style = context.ts(13, FontWeight.w500, color: cs.outline);
        } else {
          deco = BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outline),
          );
          style = context.ts(13, FontWeight.w500);
        }
        return Semantics(
          button: true,
          enabled: slot.available,
          label: 'Hora ${slot.label}${slot.available ? '' : ', no disponible'}',
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: slot.available ? () => onSelect(slot.minutes) : null,
            child: Ink(
              decoration: deco,
              child: Center(child: Text(slot.label, style: style)),
            ),
          ),
        );
      },
    );
  }
}

/// Leyenda: Libre / No disponible / Elegida.
class SlotLegend extends StatelessWidget {
  const SlotLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    Widget item(Decoration deco, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: deco),
            const SizedBox(width: 4),
            Text(label, style: context.ts(11, FontWeight.w400, color: cs.onSurfaceVariant)),
          ],
        );
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        item(BoxDecoration(borderRadius: BorderRadius.circular(3), border: Border.all(color: cs.outline)), 'Libre'),
        item(BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(3)), 'No disponible'),
        item(BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(3)), 'Elegida'),
      ],
    );
  }
}
