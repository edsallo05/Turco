import 'package:flutter/material.dart';

import '../core/theme/app_icons.dart';
import '../core/theme/app_theme.dart';

/// Barra superior del diseño (56 dp, sin elevación).
/// Se coloca dentro de un `SafeArea(bottom: false)` al inicio de la pantalla.
class TurcoAppBar extends StatelessWidget {
  const TurcoAppBar({
    super.key,
    this.title,
    this.leadingWidget,
    this.subtitle,
    this.onBack,
    this.actions = const [],
  });

  final String? title;

  /// Reemplaza al título (se usa para el logo + "Turco" de la Agenda).
  final Widget? leadingWidget;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (onBack != null) ...[
              InkResponse(
                onTap: onBack,
                radius: 22,
                child: Icon(AppIcons.chevronLeft, size: 24, color: cs.onSurface),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: leadingWidget ??
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title ?? '', style: context.ts(20, FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
            ),
            for (final a in actions) ...[const SizedBox(width: 16), a],
          ],
        ),
      ),
    );
  }
}

/// Icono de acción de la barra superior (22 dp, color onSurfaceVariant).
class AppBarAction extends StatelessWidget {
  const AppBarAction({super.key, required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Tooltip(
        message: tooltip ?? '',
        child: Icon(icon, size: 22, color: context.cs.onSurfaceVariant),
      ),
    );
  }
}
