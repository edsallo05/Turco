import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/appointment.dart';
import '../views/agenda/agenda_screen.dart';
import '../views/clients/clients_screen.dart';
import '../views/detail/appointment_detail_screen.dart';
import '../views/form/appointment_form_screen.dart';
import '../views/services/services_screen.dart';
import '../views/shell/shell_scaffold.dart';
import '../views/stylists/stylists_screen.dart';
import 'dependencies.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Rutas de la app. Solo go_router: nada de Navigator.push / pushNamed.
GoRouter buildRouter(AppDependencies d) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/agenda',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/agenda',
              builder: (context, state) => AgendaScreen(
                agendaVm: d.agenda,
                themeVm: d.theme,
                stylistParam: state.uri.queryParameters['estilista'], // parámetro de consulta
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/clientes',
              builder: (context, state) => ClientsScreen(clientsVm: d.clients, agendaVm: d.agenda),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/servicios',
              builder: (context, state) => ServicesScreen(servicesVm: d.services, agendaVm: d.agenda),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/estilistas',
              builder: (context, state) => StylistsScreen(stylistsVm: d.stylists, agendaVm: d.agenda),
            ),
          ]),
        ],
      ),
      // Se abren por encima de la barra inferior (navigator raíz).
      // "nuevo" va antes que ":id" para que no se interprete como identificador.
      GoRoute(
        path: '/turno/nuevo',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AppointmentFormScreen(
          repository: d.repository,
          clientsVm: d.clients,
          initial: state.extra is AppointmentFormInitial ? state.extra as AppointmentFormInitial : null, // extra
        ),
      ),
      GoRoute(
        path: '/turno/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AppointmentDetailScreen(
          repository: d.repository,
          appointmentId: int.tryParse(state.pathParameters['id'] ?? ''), // parámetro de ruta
        ),
        routes: [
          GoRoute(
            path: 'editar',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => AppointmentFormScreen(
              repository: d.repository,
              clientsVm: d.clients,
              editingId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
        ],
      ),
    ],
  );
}
