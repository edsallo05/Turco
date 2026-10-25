import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/salon_repository.dart';
import '../../models/appointment.dart';
import '../../models/enums.dart';
import '../../viewmodels/appointment_form_view_model.dart';
import '../../viewmodels/clients_view_model.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/select_sheet.dart';
import '../../widgets/turco_app_bar.dart';
import '../clients/client_form_sheet.dart';
import '../detail/appointment_not_found.dart';
import 'time_slot_grid.dart';

/// Formulario para crear (`/turno/nuevo`) y editar (`/turno/:id/editar`) un turno.
class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen({
    super.key,
    required this.repository,
    required this.clientsVm,
    this.editingId,
    this.initial,
  });

  final SalonRepository repository;
  final ClientsViewModel clientsVm;
  final int? editingId;
  final AppointmentFormInitial? initial;

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  // Un FocusNode por campo: al fallar la validación el foco va al primero con error.
  final _clientFocus = FocusNode();
  final _servicesFocus = FocusNode();
  final _stylistFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _slotsFocus = FocusNode();
  final _notesFocus = FocusNode();

  AppointmentFormViewModel? _vm;
  bool _notFound = false;
  bool _forcePop = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingId != null) {
      final a = widget.repository.appointmentById(widget.editingId!);
      if (a == null || !a.isScheduled) {
        _notFound = true;
        return;
      }
      _vm = AppointmentFormViewModel(widget.repository, editing: a);
    } else {
      _vm = AppointmentFormViewModel(widget.repository, initial: widget.initial);
    }
    _notesController.text = _vm!.notes;
    _vm!.addListener(_onViewModel);
  }

  @override
  void dispose() {
    _vm?.removeListener(_onViewModel);
    _vm?.dispose();
    _notesController.dispose();
    for (final f in [_clientFocus, _servicesFocus, _stylistFocus, _dateFocus, _slotsFocus, _notesFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  /// Avisos del ViewModel (por ejemplo, estilista limpiado al cambiar servicios).
  void _onViewModel() {
    final notice = _vm?.takeNotice();
    if (notice == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(notice)));
  }

  // ----------------------------------------------------------------- salida
  Future<void> _requestExit() async {
    final vm = _vm!;
    if (!vm.hasChanges) {
      _leave();
      return;
    }
    final discard = await _confirmDiscard();
    if (discard && mounted) _leave();
  }

  Future<bool> _confirmDiscard() {
    return showConfirmDialog(
      context,
      icon: AppIcons.alertTriangle,
      title: '¿Descartar los cambios?',
      message: 'Tienes cambios sin guardar en este turno. Si sales ahora se perderán.',
      cancelLabel: 'Seguir editando',
      confirmLabel: 'Descartar',
    );
  }

  void _leave([AppointmentSavedResult? result]) {
    setState(() => _forcePop = true);
    context.pop(result);
  }

  // ---------------------------------------------------------------- guardado
  void _focusFirstError() {
    final vm = _vm!;
    final order = <(String? Function(), FocusNode)>[
      (vm.validateClient, _clientFocus),
      (vm.validateServices, _servicesFocus),
      (vm.validateStylist, _stylistFocus),
      (vm.validateDate, _dateFocus),
      (vm.validateTime, _slotsFocus),
      (() => vm.validateNotes(_notesController.text), _notesFocus),
    ];
    for (final (check, node) in order) {
      if (check() != null) {
        node.requestFocus();
        final ctx = node.context;
        if (ctx != null) {
          Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 250), alignment: 0.2);
        }
        return;
      }
    }
  }

  void _save() {
    final vm = _vm!;
    if (!_formKey.currentState!.validate()) {
      _focusFirstError();
      return;
    }
    try {
      final result = vm.save();
      _leave(result);
    } on BusinessRuleException catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // ---------------------------------------------------------------- selectores
  Future<void> _pickClient(FormFieldState<Object?> state) async {
    final vm = _vm!;
    final id = await showSelectSheet<int>(
      context,
      title: 'Cliente',
      selected: vm.clientId,
      options: [
        for (final c in vm.clients)
          SelectOption(value: c.id, label: c.name, subtitle: '${phoneDisplay(c.phone)} · ${c.gender.label}'),
      ],
    );
    if (id != null) {
      vm.setClient(id);
      state.didChange(null);
    }
  }

  Future<void> _createClient(FormFieldState<Object?>? state) async {
    final created = await showClientFormSheet(context, vm: widget.clientsVm);
    if (created != null && mounted) {
      _vm!.setClient(created.id);
      state?.didChange(null);
    }
  }

  Future<void> _pickStylist(FormFieldState<Object?> state) async {
    final vm = _vm!;
    if (vm.selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Primero elige los servicios.')));
      return;
    }
    final id = await showSelectSheet<int>(
      context,
      title: 'Estilista',
      selected: vm.stylistId,
      emptyMessage: 'Ningún estilista realiza todos los servicios elegidos.',
      options: [for (final s in vm.eligibleStylists) SelectOption(value: s.id, label: s.name)],
    );
    if (id != null) {
      vm.setStylist(id);
      state.didChange(null);
    }
  }

  Future<void> _pickDate(FormFieldState<Object?> state) async {
    final vm = _vm!;
    final first = vm.firstSelectableDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.suggestedDate(),
      firstDate: first,
      lastDate: DateTime(first.year + 2, first.month, first.day),
      selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
      helpText: 'Fecha del turno',
    );
    if (picked != null) {
      vm.setDate(picked);
      state.didChange(null);
    }
  }

  // -------------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    if (_notFound) return const AppointmentNotFound(title: 'Editar turno');
    final vm = _vm!;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return PopScope(
          canPop: _forcePop || !vm.hasChanges,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final discard = await _confirmDiscard();
            if (discard && mounted) _leave();
          },
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  TurcoAppBar(title: vm.isEditing ? 'Editar turno' : 'Nuevo turno', onBack: _requestExit),
                  Expanded(
                    child: ResponsiveBody(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Form(key: _formKey, child: _buildFields(context, vm)),
                      ),
                    ),
                  ),
                  _buildBottomBar(context, vm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFields(BuildContext context, AppointmentFormViewModel vm) {
    final cs = context.cs;
    final grouped = vm.servicesByCategory;
    final noSlots = vm.date != null && vm.validateDate() == null && !vm.hasAvailableSlot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------- Cliente
        TurcoFormField(
          label: 'Cliente',
          check: vm.validateClient,
          builder: (state, hasError) => SelectBox(
            icon: AppIcons.user,
            text: vm.client?.name ?? 'Selecciona un cliente',
            isPlaceholder: vm.client == null,
            hasError: hasError,
            focusNode: _clientFocus,
            onTap: () => _pickClient(state),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _createClient(null),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.userPlus, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text('Crear cliente nuevo', style: context.ts(13, FontWeight.w600, color: cs.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ------------------------------------------------- Servicios para
        Text('Servicios para', style: context.ts(12, FontWeight.w500, color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AudienceFilter>(
            showSelectedIcon: true,
            segments: [
              for (final a in AudienceFilter.values) ButtonSegment(value: a, label: Text(a.label)),
            ],
            selected: {vm.audience},
            onSelectionChanged: (s) => vm.setAudience(s.first),
          ),
        ),
        const SizedBox(height: 10),
        // -------------------------------------------------------- Servicios
        Focus(
          focusNode: _servicesFocus,
          child: TurcoFormField(
            label: 'Servicios',
            sectionTitle: true,
            check: vm.validateServices,
            builder: (state, hasError) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, top: 2),
                    child: Text(entry.key.label.toUpperCase(),
                        style: context.ts(12, FontWeight.w600, color: cs.onSurfaceVariant)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in entry.value)
                          AppChip(
                            label: s.name,
                            selected: vm.selectedServiceIds.contains(s.id),
                            onTap: () {
                              vm.toggleService(s.id);
                              state.didChange(null);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ---------------------------------------------------------- Estilista
        TurcoFormField(
          label: 'Estilista',
          check: vm.validateStylist,
          builder: (state, hasError) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectBox(
                icon: AppIcons.scissors,
                text: vm.stylist?.name ??
                    (vm.selectedServiceIds.isEmpty ? 'Primero elige los servicios' : 'Selecciona un estilista'),
                isPlaceholder: vm.stylist == null,
                hasError: hasError,
                focusNode: _stylistFocus,
                onTap: () => _pickStylist(state),
              ),
              if (!hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(AppIcons.info, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Solo se muestran estilistas que realizan todos los servicios elegidos.',
                            style: context.ts(11, FontWeight.w400, color: cs.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // -------------------------------------------------------------- Fecha
        TurcoFormField(
          label: 'Fecha',
          check: vm.validateDate,
          builder: (state, hasError) => SelectBox(
            icon: AppIcons.calendar,
            text: vm.date == null ? 'Selecciona una fecha' : fullDate(vm.date!),
            isPlaceholder: vm.date == null,
            hasError: hasError,
            focusNode: _dateFocus,
            onTap: () => _pickDate(state),
          ),
        ),
        const SizedBox(height: 12),
        // ------------------------------------------------------ Hora (franjas)
        Focus(
          focusNode: _slotsFocus,
          child: TurcoFormField(
            label: 'Hora de inicio',
            sectionTitle: true,
            check: vm.validateTime,
            builder: (state, hasError) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const SlotLegend(),
                const SizedBox(height: 8),
                TimeSlotGrid(
                  slots: vm.slots,
                  onSelect: (m) {
                    vm.setStartMinutes(m);
                    state.didChange(null);
                  },
                ),
                if (noSlots)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No hay horarios libres para esta combinación. Prueba con otra fecha, estilista o servicios.',
                      style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // -------------------------------------------------------------- Notas
        LabeledTextFormField(
          label: 'Notas (opcional)',
          controller: _notesController,
          focusNode: _notesFocus,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 5,
          minLines: 3,
          maxLength: AppointmentFormViewModel.maxNotes,
          onChanged: vm.setNotes,
          validator: vm.validateNotes,
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, AppointmentFormViewModel vm) {
    final cs = context.cs;
    Widget summaryItem(IconData icon, String text, FontWeight w) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.primary),
            const SizedBox(width: 4),
            Text(text, style: context.ts(13, w)),
          ],
        );

    final media = MediaQuery.of(context);
    // Pantalla baja (horizontal o teclado abierto): resumen y botones en una sola fila.
    final compact = media.size.height - media.viewInsets.bottom < 520;

    final summary = Container(
      width: compact ? null : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          summaryItem(AppIcons.clock, vm.durationLabel, FontWeight.w600),
          SizedBox(width: compact ? 14 : 0),
          summaryItem(AppIcons.flag, vm.endLabel, FontWeight.w600),
          SizedBox(width: compact ? 14 : 0),
          summaryItem(AppIcons.price, money(vm.totalPrice), FontWeight.w700),
        ],
      ),
    );
    final cancelButton = OutlinedButton(onPressed: _requestExit, child: const Text('Cancelar'));
    final saveButton = FilledButton.icon(
      onPressed: _save,
      icon: const Icon(AppIcons.check, size: 18),
      label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Guardar turno')),
    );

    return Container(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, compact ? 8 : 12, 16, compact ? 8 : 16),
          child: compact
              ? Row(
                  children: [
                    Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: summary)),
                    const SizedBox(width: 10),
                    SizedBox(width: 110, child: cancelButton),
                    const SizedBox(width: 8),
                    SizedBox(width: 150, child: saveButton),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    summary,
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: cancelButton),
                        const SizedBox(width: 10),
                        Expanded(child: saveButton),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
