import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../models/enums.dart';
import '../../widgets/status_badge.dart';

/// Tarjeta de turno de la lista de la Agenda.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.clientName,
    required this.stylistName,
    required this.onTap,
    required this.onLongPress,
  });

  final Appointment appointment;
  final String clientName;
  final String stylistName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final a = appointment;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return Opacity(
      opacity: a.status == AppointmentStatus.cancelado ? 0.75 : 1,
      child: Material(
        color: cs.surfaceContainer,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          onLongPress: a.isScheduled ? onLongPress : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(color: a.status.bar(cs), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hhmm(a.start), style: context.ts(15, FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(hhmm(a.end), style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clientName,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: context.ts(15, FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(a.servicesLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(AppIcons.user, size: 13, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(stylistName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.ts(12, FontWeight.w500, color: cs.onSurfaceVariant)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: a.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
