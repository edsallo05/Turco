import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Asa de las hojas inferiores (36 x 4).
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(color: context.cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
    );
  }
}
