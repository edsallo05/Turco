import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/enums.dart';

extension AppointmentStatusColors on AppointmentStatus {
  /// Color de la barra lateral de la tarjeta.
  Color bar(ColorScheme cs) {
    switch (this) {
      case AppointmentStatus.programado:
        return cs.primary;
      case AppointmentStatus.completado:
        return cs.tertiary;
      case AppointmentStatus.cancelado:
        return cs.error;
    }
  }

  Color container(ColorScheme cs) {
    switch (this) {
      case AppointmentStatus.programado:
        return cs.primaryContainer;
      case AppointmentStatus.completado:
        return cs.tertiaryContainer;
      case AppointmentStatus.cancelado:
        return cs.errorContainer;
    }
  }

  Color onContainer(ColorScheme cs) {
    switch (this) {
      case AppointmentStatus.programado:
        return cs.onPrimaryContainer;
      case AppointmentStatus.completado:
        return cs.onTertiaryContainer;
      case AppointmentStatus.cancelado:
        return cs.onErrorContainer;
    }
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: status.container(cs), borderRadius: BorderRadius.circular(8)),
      child: Text(status.label, style: context.ts(11, FontWeight.w600, color: status.onContainer(cs))),
    );
  }
}
