import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../models/enums.dart';
import '../../viewmodels/agenda_view_model.dart';
import '../../viewmodels/theme_view_model.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/turco_app_bar.dart';
import 'appointment_card.dart';
import 'quick_actions_sheet.dart';
import 'week_strip.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, required this.agendaVm, required this.themeVm, this.stylistParam});

  final AgendaViewModel agendaVm;
  final ThemeViewModel themeVm;

  /// Valor del parámetro de consulta `?estilista=3`.
  final String? stylistParam;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  AgendaViewModel get vm => widget.agendaVm;

  @override
  void initState() {
    super.initState();
    vm.addListener(_onViewModel);
    _applyStylistParam();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onViewModel());
  }

  @override
  void didUpdateWidget(covariant AgendaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stylistParam != widget.stylistParam) _applyStylistParam();
  }

  @override
  void dispose() {
    vm.removeListener(_onViewModel);
    super.dispose();
  }

  void _applyStylistParam() {
    final id = int.tryParse(widget.stylistParam ?? '');
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) vm.setStylist(id);
    });
  }

  /// Muestra el SnackBar cuando se vuelve del formulario con un turno guardado.
  void _onViewModel() {
    if (!mounted || !vm.hasPendingSaved) return;
    final r = vm.takePendingSaved();
    if (r == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Turno guardado para el ${shortDate(r.date)}'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => context.push<AppointmentSavedResult>('/turno/${r.appointmentId}'),
        ),
      ));
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Elegir fecha',
    );
    if (picked != null) vm.selectDate(picked);
  }

  Future<void> _newAppointment() async {
    final r = await context.push<AppointmentSavedResult>(
      '/turno/nuevo',
      extra: AppointmentFormInitial(date: vm.selectedDate),
    );
    if (r != null) vm.registerSaved(r);
  }

  Future<void> _openDetail(Appointment a) async {
    final r = await context.push<AppointmentSavedResult>('/turno/${a.id}');
    if (r != null) vm.registerSaved(r);
  }

  void _setStylistFilter(int? id) {
    vm.setStylist(id);
    // Mantiene la URL sincronizada con el filtro: /agenda?estilista=3
    context.go(id == null ? '/agenda' : '/agenda?estilista=$id');
  }

  Future<void> _quickActions(Appointment a) async {
    final client = vm.clientName(a);
    final action = await showQuickActionsSheet(
      context,
      title: '$client · ${hhmm(a.start)}',
      subtitle: '${a.servicesLabel} · ${vm.stylistFirstName(a)}',
    );
    if (action == null || !mounted) return;
    if (action == QuickAction.complete) {
      await _confirmComplete(a);
    } else {
      await _confirmCancel(a);
    }
  }

  Future<void> _confirmCancel(Appointment a) async {
    final ok = await showConfirmDialog(
      context,
      icon: AppIcons.alertTriangle,
      title: '¿Cancelar este turno?',
      message:
          'El horario de ${vm.clientName(a)} (${hhmm(a.start)} a ${hhmm(a.end)}) quedará libre. Esta acción no se puede deshacer.',
      cancelLabel: 'Volver',
      confirmLabel: 'Cancelar turno',
    );
    if (ok && mounted) {
      vm.cancel(a.id);
      _snack('Turno cancelado');
    }
  }

  Future<void> _confirmComplete(Appointment a) async {
    final ok = await showConfirmDialog(
      context,
      icon: AppIcons.circleCheck,
      title: '¿Completar este turno?',
      message:
          '${vm.clientName(a)} (${hhmm(a.start)} a ${hhmm(a.end)}) se marcará como completado y ya no se podrá editar.',
      cancelLabel: 'Volver',
      confirmLabel: 'Completar',
      destructive: false,
    );
    if (ok && mounted) {
      vm.complete(a.id);
      _snack('Turno completado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newAppointment,
        icon: const Icon(AppIcons.plus, size: 20),
        label: const Text('Nuevo turno'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TurcoAppBar(
              leadingWidget: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10)),
                    child: Icon(AppIcons.scissors, size: 18, color: cs.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Text('Turco', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              actions: [_ThemeMenu(themeVm: widget.themeVm)],
            ),
            Expanded(
              child: ResponsiveBody(
                child: ListenableBuilder(
                  listenable: vm,
                  builder: (context, _) => _buildList(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final items = vm.appointments;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: 1 + (items.isEmpty ? 1 : items.length),
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(context);
        if (items.isEmpty) {
          return const EmptyState(
            imagePath: 'assets/images/illustrations/calendar_x.png',
            title: 'No hay turnos para este día',
            message: 'Crea el primer turno con el botón de abajo o cambia los filtros.',
          );
        }
        final a = items[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppointmentCard(
            appointment: a,
            clientName: vm.clientName(a),
            stylistName: vm.stylistFirstName(a),
            onTap: () => _openDetail(a),
            onLongPress: () => _quickActions(a),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = context.cs;
    final s = vm.summary;
    Widget summaryCard(String value, String label, Color valueColor) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: context.ts(20, FontWeight.w600, color: valueColor)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.ts(11, FontWeight.w400, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeekStrip(vm: vm, onPickDate: _pickDate),
          const SizedBox(height: 10),
          Row(
            children: [
              summaryCard('${s.scheduled}', 'Programados', cs.primary),
              const SizedBox(width: 8),
              summaryCard('${s.completed}', 'Completados', cs.tertiary),
              const SizedBox(width: 8),
              summaryCard(money(s.income), 'Ingreso est.', cs.onSurface),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(label: 'Todos', selected: vm.stylistFilter == null, onTap: () => _setStylistFilter(null)),
                for (final st in vm.stylists) ...[
                  const SizedBox(width: 8),
                  AppChip(
                    label: st.name.split(' ').first,
                    selected: vm.stylistFilter == st.id,
                    onTap: () => _setStylistFilter(st.id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppointmentStatus?>(
              showSelectedIcon: true,
              segments: const [
                ButtonSegment(value: null, label: Text('Todos', maxLines: 1)),
                ButtonSegment(value: AppointmentStatus.programado, label: Text('Program.', maxLines: 1)),
                ButtonSegment(value: AppointmentStatus.completado, label: Text('Complet.', maxLines: 1)),
                ButtonSegment(value: AppointmentStatus.cancelado, label: Text('Cancel.', maxLines: 1)),
              ],
              selected: {vm.statusFilter},
              onSelectionChanged: (set) => vm.setStatus(set.first),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menú del botón de tema: Sistema / Claro / Oscuro.
class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu({required this.themeVm});
  final ThemeViewModel themeVm;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return ListenableBuilder(
      listenable: themeVm,
      builder: (context, _) {
        PopupMenuItem<ThemeMode> item(ThemeMode mode, IconData icon, String label) {
          final selected = themeVm.mode == mode;
          return PopupMenuItem<ThemeMode>(
            value: mode,
            height: 44,
            child: Row(
              children: [
                Icon(icon, size: 18, color: selected ? cs.primary : cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(child: Text(label)),
                if (selected) Icon(AppIcons.check, size: 16, color: cs.primary),
              ],
            ),
          );
        }

        return PopupMenuButton<ThemeMode>(
          tooltip: 'Cambiar tema',
          padding: EdgeInsets.zero,
          offset: const Offset(0, 36),
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 180),
          icon: Icon(AppIcons.themeMode, size: 22, color: cs.onSurfaceVariant),
          onSelected: themeVm.setMode,
          itemBuilder: (_) => [
            item(ThemeMode.system, AppIcons.smartphone, 'Sistema'),
            item(ThemeMode.light, AppIcons.sun, 'Claro'),
            item(ThemeMode.dark, AppIcons.moon, 'Oscuro'),
          ],
        );
      },
    );
  }
}
