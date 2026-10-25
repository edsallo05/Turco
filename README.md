# Turco

Aplicación Flutter (Android) para gestionar los turnos de una peluquería mixta.
Primer parcial · Programación para Dispositivos Móviles.

- **Arquitectura:** MVVM con `ChangeNotifier` + `ListenableBuilder` (sin paquetes de estado externos).
- **Navegación:** solo `go_router` (`StatefulShellRoute.indexedStack`, parámetros de ruta, de consulta, `extra` y `pop(valor)`).
- **Datos:** en memoria, cargados desde `lib/data/seed_data.dart` (fechas calculadas con `DateTime.now()`).
- **application id:** `com.nombrealumno.turco` (reemplazar por tu nombre y primer apellido, ej. `com.anaperez.turco`).
- **Flutter usado:** 3.29 o superior (por `NavigationBarThemeData.indicatorSize`) (canal stable). Dart SDK ^3.5.

## Cómo inicializar el proyecto

Este repositorio trae `lib/`, `assets/`, `pubspec.yaml` y `test/`. La carpeta `android/` se genera con:

```bash
flutter create --org com.nombrealumno --project-name turco --platforms android .
flutter pub get
```

Después:

1. En `android/app/src/main/AndroidManifest.xml` deja `android:label="Turco"`.
2. Verifica en `android/app/build.gradle(.kts)` que `applicationId` sea `com.nombrealumno.turco`.
3. Si `flutter create` crea `test/widget_test.dart`, bórralo (usa `MyApp`, que ya no existe).

## Ejecutar

```bash
flutter run            # depuración en emulador o teléfono
flutter test           # pruebas de reglas de negocio
```

## Generar el APK release

```bash
flutter build apk --release
# Resultado: build/app/outputs/flutter-apk/app-release.apk
```

Sube el APK a **Releases** de GitHub (`build/` está en `.gitignore`).

## Fuente y recursos gráficos

- Fuente **Poppins** en `assets/fonts/` (Regular, Medium, SemiBold, Bold).
- Imágenes en `assets/images/` (categorías, avatares, ilustraciones). Son PNG de un solo color con
  transparencia que se tiñen desde el tema, así funcionan en claro y oscuro.

## Estructura de carpetas

```
lib/
  main.dart
  app/            app.dart (MaterialApp.router), router.dart (go_router), dependencies.dart
  core/           theme/ (tema claro/oscuro, iconos), utils/ (formatos de fecha, dinero, texto)
  models/         Service, Stylist, Client, Appointment y enums
  data/           SalonRepository (reglas de negocio) y SeedData (datos de prueba)
  viewmodels/     ChangeNotifier de cada pantalla
  views/          shell/, agenda/, detail/, form/, clients/, services/, stylists/
  widgets/        componentes reutilizables (app bar, chips, campos, diálogos...)
assets/           fonts/ e images/
tool/             generate_assets.py
test/             business_rules_test.dart
capturas/         capturas reales de la app (agregar)
```

## Entregables pendientes de tu parte

- Carpeta `capturas/` con capturas reales: seis pantallas, formulario con errores, franjas deshabilitadas y Agenda en modo oscuro.
- APK release publicado en Releases.
