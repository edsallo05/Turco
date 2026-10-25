import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';

/// Contenedor con la barra de navegación inferior (4 destinos).
/// StatefulShellRoute.indexedStack conserva el estado de cada pestaña.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    // Atrás desde otra pestaña vuelve a Agenda; desde Agenda cierra la app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(icon: Icon(AppIcons.calendarDays), label: 'Agenda'),
            NavigationDestination(icon: Icon(AppIcons.users), label: 'Clientes'),
            NavigationDestination(icon: Icon(AppIcons.scissors), label: 'Servicios'),
            NavigationDestination(icon: Icon(AppIcons.contact), label: 'Estilistas'),
          ],
        ),
      ),
    );
  }
}
