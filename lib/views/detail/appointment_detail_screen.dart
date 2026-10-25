import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/salon_repository.dart';
import '../../models/appointment.dart';
import '../../models/enums.dart';
import '../../viewmodels/appointment_detail_view_model.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/turco_app_bar.dart';
import 'appointment_not_found.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required this.repository, required this.appointmentId});
  final SalonRepository repository;
  final int? appointmentId;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late final AppointmentDetailViewModel vm =
      AppointmentDetailViewModel(widget.repository, widget.appointmentId);

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Future<void> _edit() async {
    final r = await context.push<AppointmentSavedResult>('/turno/${widget.appointmentId}/editar');
    // El resultado sigue viajando hasta la Agenda.
    if (r != null && mounted) context.pop(r);
  }

  Future<void> _complete(Appointment a) async {
    final ok = await showConfirmDialog(
      context,
      icon: AppIcons.circleCheck,
      title: '¿Completar este turno?',
      message:
          '${vm.client?.name ?? 'El cliente'} (${hhmm(a.start)} a ${hhmm(a.end)}) se marcará como completado y ya no se podrá editar.',
      cancelLabel: 'Volver',
      confirmLabel: 'Completar',
      destructive: false,
    );
    if (ok && mounted) vm.complete();
  }

  Future<void> _cancel(Appointment a) async {
    final ok = await showConfirmDialog(
      context,
      icon: AppIcons.alertTriangle,
      title: '¿Cancelar este turno?',
      message:
          'El horario de ${vm.client?.name ?? 'el cliente'} (${hhmm(a.start)} a ${hhmm(a.end)}) quedará libre. Esta acción no se puede deshacer.',
      cancelLabel: 'Volver',
      confirmLabel: 'Cancelar turno',
    );
    if (ok && mounted) vm.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final a = vm.appointment;
        if (a == null) return const AppointmentNotFound();
        return _buildDetail(context, a);
      },
    );
  }

  Widget _buildDetail(BuildContext context, Appointment a) {
    final cs = context.cs;
    final client = vm.client;
    final stylist = vm.stylist;

    Widget card({required Widget child}) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(16)),
          child: child,
        );

    Widget dataRow(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.ts(11, FontWeight.w400, color: cs.onSurfaceVariant)),
                    Text(value, style: context.ts(14, FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        );

    final notes = a.notes;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TurcoAppBar(
              title: 'Detalle del turno',
              onBack: () => context.canPop() ? context.pop() : context.go('/agenda'),
            ),
            Expanded(
              child: ResponsiveBody(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InitialAvatar(
                                  name: client?.name ?? '?',
                                  gender: client?.gender ?? Gender.mujer,
                                  size: 48,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(client?.name ?? 'Cliente eliminado',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.ts(17, FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(AppIcons.phone, size: 13, color: cs.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(client == null ? '-' : phoneDisplay(client.phone),
                                              style: context.ts(13, FontWeight.w400, color: cs.onSurfaceVariant)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(status: a.status),
                              ],
                            ),
                            dataRow(AppIcons.calendar, 'Fecha', fullDate(a.start)),
                            dataRow(AppIcons.clock, 'Hora',
                                '${hhmm(a.start)} a ${hhmm(a.end)} (${durationText(a.durationMinutes)})'),
                            dataRow(AppIcons.user, 'Estilista', stylist?.name.split(' ').first ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Servicios', style: context.ts(14, FontWeight.w600)),
                            for (final s in a.services) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name, style: context.ts(14, FontWeight.w500)),
                                        Text('${s.durationMinutes} min',
                                            style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  Text(money(s.price), style: context.ts(14, FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: cs.outlineVariant, height: 1),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total', style: context.ts(14, FontWeight.w600)),
                                Text(money(a.totalPrice), style: context.ts(16, FontWeight.w700, color: cs.primary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (notes != null && notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Notas', style: context.ts(14, FontWeight.w600)),
                              const SizedBox(height: 6),
                              // Área con scroll propio: sin overflow aunque el texto sea largo.
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 140),
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Text(notes,
                                          style: context.ts(13, FontWeight.w400,
                                              color: cs.onSurfaceVariant, height: 1.45)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Creado el ${numericDate(a.createdAt)} · Modificado el ${numericDate(a.updatedAt)}',
                        style: context.ts(11, FontWeight.w400, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(context, a),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Appointment a) {
    final cs = context.cs;
    final small = const Size(0, 44);
    const pad = EdgeInsets.symmetric(horizontal: 6);

    Widget fit(String label) => FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1));

    return Container(
      width: double.infinity,
      color: cs.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: a.isScheduled
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _edit,
                    style: OutlinedButton.styleFrom(minimumSize: small, padding: pad),
                    icon: const Icon(AppIcons.pencil, size: 18),
                    label: fit('Editar'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _complete(a),
                    style: FilledButton.styleFrom(
                      minimumSize: small,
                      padding: pad,
                      backgroundColor: cs.secondaryContainer,
                      foregroundColor: cs.onSecondaryContainer,
                    ),
                    icon: const Icon(AppIcons.check, size: 18),
                    label: fit('Completar'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _cancel(a),
                    style: TextButton.styleFrom(minimumSize: small, padding: pad, foregroundColor: cs.error),
                    icon: const Icon(AppIcons.ban, size: 18),
                    label: fit('Cancelar'),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.lock, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Turno ${a.status.label.toLowerCase()}: solo lectura',
                    style: context.ts(13, FontWeight.w500, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
    );
  }
}
