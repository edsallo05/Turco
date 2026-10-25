import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/enums.dart';
import '../models/stylist.dart';

/// Avatar circular con la inicial (clientes). Mujer = primaryContainer, hombre = tertiaryContainer.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({super.key, required this.name, required this.gender, required this.size});
  final String name;
  final Gender gender;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final woman = gender == Gender.mujer;
    final bg = woman ? cs.primaryContainer : cs.tertiaryContainer;
    final fg = woman ? cs.onPrimaryContainer : cs.onTertiaryContainer;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(initialOf(name), style: context.ts(size * 0.4, FontWeight.w600, color: fg)),
    );
  }
}

/// Avatar del estilista: círculo + imagen de assets (se tiñe con el tema).
class StylistAvatar extends StatelessWidget {
  const StylistAvatar({super.key, required this.stylist, required this.size});
  final Stylist stylist;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
      child: Image.asset(
        stylist.avatarPath,
        width: size,
        height: size,
        color: cs.onPrimaryContainer,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (_, __, ___) => Center(
          child: Text(initialOf(stylist.name), style: context.ts(size * 0.4, FontWeight.w600, color: cs.onPrimaryContainer)),
        ),
      ),
    );
  }
}
