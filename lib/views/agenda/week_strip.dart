import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../viewmodels/agenda_view_model.dart';

/// Cabecera de semana + tira horizontal con los siete días (ListView.builder).
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.vm, required this.onPickDate});
  final AgendaViewModel vm;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final days = vm.weekDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkResponse(
                    onTap: vm.previousWeek,
                    radius: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(AppIcons.chevronLeft, size: 22, color: cs.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(monthYear(vm.selectedDate),
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: context.ts(15, FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  InkResponse(
                    onTap: vm.nextWeek,
                    radius: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(AppIcons.chevronRight, size: 22, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onPickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.calendar, size: 18, color: cs.primary),
                    const SizedBox(width: 6),
                    Text('Elegir fecha', style: context.ts(13, FontWeight.w500, color: cs.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 6 * 4) / 7;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, i) {
                  final d = days[i];
                  final selected = isSameDay(d, vm.selectedDate);
                  final closed = d.weekday == DateTime.sunday;
                  final fgDay = selected ? cs.onPrimary : cs.onSurfaceVariant;
                  final fgNum = selected ? cs.onPrimary : cs.onSurface;
                  return SizedBox(
                    width: i < 6 ? itemWidth + 4 : itemWidth,
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 6 ? 4 : 0),
                      child: Opacity(
                        opacity: closed ? 0.4 : 1,
                        child: Material(
                          color: selected ? cs.primary : kTransparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => vm.selectDate(d),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(weekdayShort(d), style: context.ts(11, FontWeight.w500, color: fgDay)),
                                const SizedBox(height: 2),
                                Text('${d.day}', style: context.ts(16, FontWeight.w600, color: fgNum)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text('Domingo: salón cerrado', style: context.ts(11, FontWeight.w400, color: cs.onSurfaceVariant)),
      ],
    );
  }
}
