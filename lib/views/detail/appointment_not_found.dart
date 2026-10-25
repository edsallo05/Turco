import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/turco_app_bar.dart';

/// Se muestra cuando la ruta trae un identificador que no existe.
class AppointmentNotFound extends StatelessWidget {
  const AppointmentNotFound({super.key, this.title = 'Detalle del turno'});
  final String title;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/agenda');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TurcoAppBar(title: title, onBack: () => _goBack(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Center(
                  child: EmptyState(
                    imagePath: 'assets/images/illustrations/search_x.png',
                    title: 'No encontramos este turno',
                    message: 'El turno no existe o ya no está disponible.',
                    circleSize: 112,
                    titleSize: 18,
                    isError: true,
                    topPadding: 90,
                    action: FilledButton.icon(
                      onPressed: () => _goBack(context),
                      icon: const Icon(AppIcons.arrowLeft, size: 18),
                      label: const Text('Volver a la agenda'),
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(64, 44)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
