import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../models/client.dart';
import '../../models/enums.dart';
import '../../viewmodels/agenda_view_model.dart';
import '../../viewmodels/clients_view_model.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/turco_app_bar.dart';
import 'client_detail_sheet.dart';
import 'client_form_sheet.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key, required this.clientsVm, required this.agendaVm});
  final ClientsViewModel clientsVm;
  final AgendaViewModel agendaVm;

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late final TextEditingController _search = TextEditingController(text: widget.clientsVm.query);

  ClientsViewModel get vm => widget.clientsVm;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _snack(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), action: action));
  }

  Future<void> _addClient() async {
    final c = await showClientFormSheet(context, vm: vm);
    if (c != null && mounted) _snack('Cliente registrado');
  }

  Future<void> _openClient(Client c) async {
    final action = await showClientDetailSheet(context, vm: vm, client: c);
    if (action == null || !mounted) return;
    switch (action) {
      case ClientAction.newAppointment:
        final r = await context.push<AppointmentSavedResult>(
          '/turno/nuevo',
          extra: AppointmentFormInitial(clientId: c.id),
        );
        if (r != null && mounted) {
          widget.agendaVm.registerSaved(r);
          context.go('/agenda');
        }
      case ClientAction.edit:
        final saved = await showClientFormSheet(context, vm: vm, editing: c);
        if (saved != null && mounted) _snack('Cliente actualizado');
      case ClientAction.delete:
        await _delete(c);
    }
  }

  Future<void> _delete(Client c) async {
    final blocked = vm.deleteBlockedMessage(c);
    if (blocked != null) {
      final next = vm.firstScheduledOf(c);
      _snack(
        blocked,
        action: next == null
            ? null
            : SnackBarAction(label: 'Ver', onPressed: () => context.push('/turno/${next.id}')),
      );
      return;
    }
    final ok = await showConfirmDialog(
      context,
      icon: AppIcons.alertTriangle,
      title: '¿Eliminar a ${c.name}?',
      message: 'Se eliminará el cliente junto con su historial de turnos completados y cancelados.',
      cancelLabel: 'Cancelar',
      confirmLabel: 'Eliminar',
    );
    if (ok && mounted) {
      vm.delete(c);
      _snack('Cliente eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClient,
        icon: const Icon(AppIcons.userPlus, size: 20),
        label: const Text('Nuevo cliente'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TurcoAppBar(
              title: 'Clientes',
              actions: [AppBarAction(icon: AppIcons.userPlus, onTap: _addClient, tooltip: 'Nuevo cliente')],
            ),
            Expanded(
              child: ResponsiveBody(
                child: ListenableBuilder(
                  listenable: vm,
                  builder: (context, _) {
                    final list = vm.filtered;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _search,
                            onChanged: vm.setQuery,
                            style: context.ts(14, FontWeight.w400),
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre o teléfono',
                              hintStyle: context.ts(14, FontWeight.w400, color: cs.onSurfaceVariant),
                              filled: true,
                              fillColor: cs.surfaceContainerHigh,
                              prefixIcon: Icon(AppIcons.search, size: 20, color: cs.onSurfaceVariant),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(24)),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(24)),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(24)),
                                borderSide: BorderSide(color: cs.primary, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<Gender?>(
                              showSelectedIcon: true,
                              segments: const [
                                ButtonSegment(value: null, label: Text('Todos')),
                                ButtonSegment(value: Gender.mujer, label: Text('Mujeres')),
                                ButtonSegment(value: Gender.hombre, label: Text('Hombres')),
                              ],
                              selected: {vm.genderFilter},
                              onSelectionChanged: (s) => vm.setGender(s.first),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${plural(vm.total, 'cliente', 'clientes')} · ${plural(vm.womenCount, 'mujer', 'mujeres')} · ${plural(vm.menCount, 'hombre', 'hombres')}',
                            style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: list.isEmpty
                                ? SingleChildScrollView(
                                    child: Center(
                                      child: EmptyState(
                                        imagePath: 'assets/images/illustrations/users.png',
                                        title: vm.hasAnyClient ? 'Sin resultados' : 'Todavía no hay clientes',
                                        message: vm.hasAnyClient
                                            ? 'Ningún cliente coincide con la búsqueda o el filtro.'
                                            : 'Registra el primero con el botón de abajo.',
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 96),
                                    itemCount: list.length,
                                    separatorBuilder: (_, __) => Divider(color: cs.outlineVariant, height: 1),
                                    itemBuilder: (context, i) {
                                      final c = list[i];
                                      final n = vm.appointmentCount(c);
                                      return InkWell(
                                        onTap: () => _openClient(c),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Row(
                                            children: [
                                              InitialAvatar(name: c.name, gender: c.gender, size: 44),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(c.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: context.ts(15, FontWeight.w600)),
                                                    Text('${phoneDisplay(c.phone)} · ${c.gender.label}',
                                                        style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(plural(n, 'turno', 'turnos'),
                                                  style: context.ts(12, FontWeight.w500, color: cs.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
