import 'package:flutter/material.dart';

/// Color totalmente transparente (evita usar `Colors.xxx` en los widgets).
const Color kTransparent = Color(0x00000000);

/// Tema global claro/oscuro de Turco (Material 3, Poppins).
/// Todos los colores salen del [ColorScheme]; ningún widget usa colores fijos.
class AppTheme {
  AppTheme._();

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006A60),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF9EF2E4),
    onPrimaryContainer: Color(0xFF00201C),
    secondary: Color(0xFF4A6360),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCE8E2),
    onSecondaryContainer: Color(0xFF05201C),
    tertiary: Color(0xFF456179),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCDE5FF),
    onTertiaryContainer: Color(0xFF001D32),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF4FBF9),
    onSurface: Color(0xFF161D1C),
    onSurfaceVariant: Color(0xFF3F4947),
    outline: Color(0xFF6F7977),
    outlineVariant: Color(0xFFBEC9C6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2B3231),
    onInverseSurface: Color(0xFFF4FBF9),
    inversePrimary: Color(0xFF74F8E5),
    surfaceTint: Color(0xFF006A60),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEFF5F3),
    surfaceContainer: Color(0xFFE9EFED),
    surfaceContainerHigh: Color(0xFFE3EAE8),
    surfaceContainerHighest: Color(0xFFDEE4E2),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF53DBC9),
    onPrimary: Color(0xFF003731),
    primaryContainer: Color(0xFF005047),
    onPrimaryContainer: Color(0xFF74F8E5),
    secondary: Color(0xFFB0CCC6),
    onSecondary: Color(0xFF1B3531),
    secondaryContainer: Color(0xFF314B47),
    onSecondaryContainer: Color(0xFFCCE8E2),
    tertiary: Color(0xFFADCAE6),
    onTertiary: Color(0xFF001D32),
    tertiaryContainer: Color(0xFF2D4A62),
    onTertiaryContainer: Color(0xFFCDE5FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0E1514),
    onSurface: Color(0xFFDDE4E2),
    onSurfaceVariant: Color(0xFFBEC9C6),
    outline: Color(0xFF899390),
    outlineVariant: Color(0xFF3F4947),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFDDE4E2),
    onInverseSurface: Color(0xFF2B3231),
    inversePrimary: Color(0xFF006A60),
    surfaceTint: Color(0xFF53DBC9),
    surfaceContainerLowest: Color(0xFF090F0F),
    surfaceContainerLow: Color(0xFF161D1C),
    surfaceContainer: Color(0xFF1A2120),
    surfaceContainerHigh: Color(0xFF252B2A),
    surfaceContainerHighest: Color(0xFF303736),
  );

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  static ThemeData _build(ColorScheme cs) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Poppins',
    );
    final t = base.textTheme;
    final text = t
        .copyWith(
          headlineSmall: t.headlineSmall
              ?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge:
              t.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: t.titleMedium
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium:
              t.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
          labelSmall:
              t.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        )
        .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface);

    final stadium = const StadiumBorder();
    TextStyle label(double size, FontWeight w) =>
        TextStyle(fontFamily: 'Poppins', fontSize: size, fontWeight: w);

    return base.copyWith(
      scaffoldBackgroundColor: cs.surface,
      textTheme: text,
      splashFactory: InkRipple.splashFactory,
      dividerTheme:
          DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 46),
          shape: stadium,
          textStyle: label(14, FontWeight.w600),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 46),
          shape: stadium,
          textStyle: label(14, FontWeight.w600),
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: stadium,
          textStyle: label(14, FontWeight.w600),
          foregroundColor: cs.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        hintStyle: label(14, FontWeight.w400).copyWith(color: cs.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        counterStyle:
            label(11, FontWeight.w400).copyWith(color: cs.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: kTransparent,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: stadium,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected)
                ? cs.onSecondaryContainer
                : cs.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? label(12, FontWeight.w600).copyWith(color: cs.onSurface)
              : label(12, FontWeight.w500).copyWith(color: cs.onSurfaceVariant),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 4,
        extendedTextStyle: label(14, FontWeight.w600),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedIconLabelSpacing: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle:
            label(14, FontWeight.w400).copyWith(color: cs.onInverseSurface),
        actionTextColor: cs.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainer,
        surfaceTintColor: kTransparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        modalBackgroundColor: cs.surface,
        surfaceTintColor: kTransparent,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerHigh,
        surfaceTintColor: kTransparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: label(14, FontWeight.w500).copyWith(color: cs.onSurface),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(label(13, FontWeight.w500)),
          iconSize: const WidgetStatePropertyAll(14),
          padding:
              const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
          side: WidgetStatePropertyAll(BorderSide(color: cs.outline)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? cs.secondaryContainer
                : kTransparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? cs.onSecondaryContainer
                : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Atajos de estilo para no repetir `copyWith` en las vistas.
extension TurcoContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  /// Estilo Poppins con tamaño/peso del diseño; el color sale del tema.
  TextStyle ts(double size, FontWeight weight, {Color? color, double? height}) {
    return Theme.of(this).textTheme.bodyMedium!.copyWith(
          fontSize: size,
          fontWeight: weight,
          color: color ?? cs.onSurface,
          height: height,
        );
  }
}
