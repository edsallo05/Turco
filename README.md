# Turco

Aplicación Flutter (Android) para gestionar los turnos de una peluquería mixta.
Primer examen parcial · Programación para Dispositivos Móviles · Ingeniería Informática, 3.er año.

## Datos del proyecto

| Dato | Valor |
|---|---|
| Nombre visible | Turco |
| Application id | `com.eduardosalgueiro.turco` |
| Versión de Flutter usada | 3.47.5 |
| Arquitectura | MVVM con `ChangeNotifier` + `ListenableBuilder` (sin paquetes de estado externos) |
| Navegación | `go_router` con `StatefulShellRoute.indexedStack` |
| Datos | En memoria, cargados desde `lib/data/seed_data.dart` (fechas calculadas con `DateTime.now()`) |

## Cómo inicializar el proyecto

Requisitos: Flutter instalado, Android SDK y un emulador o teléfono Android (`flutter doctor` sin errores).

```bash
git clone <URL-DEL-REPOSITORIO>
cd turco
flutter pub get
```

## Cómo ejecutar

```bash
flutter run          # depuración en emulador o teléfono
flutter test         # pruebas de reglas de negocio
```

## Cómo generar el APK release

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.
Una copia se guarda en la carpeta `entrega/` y también se publica en la sección **Releases** del repositorio de GitHub.

## Recursos

- Fuente **Poppins** (Regular, Medium, SemiBold, Bold) en `assets/fonts/`.
- Imágenes propias en `assets/images/` (`categories/`, `avatars/`, `illustrations/`), declaradas en `pubspec.yaml`.

## Estructura de carpetas

```
lib/
  main.dart                 punto de entrada
  app/                      app.dart (MaterialApp.router), router.dart (go_router), dependencies.dart
  core/
    theme/                  tema claro/oscuro, iconos
    utils/                  formatos de fecha, dinero y texto
  models/                   Service, Stylist, Client, Appointment y enums
  data/                     SalonRepository (reglas de negocio) y SeedData (datos de prueba)
  viewmodels/               ChangeNotifier de cada pantalla
  views/                    shell/, agenda/, detail/, form/, clients/, services/, stylists/
  widgets/                  componentes reutilizables (barra, chips, campos, diálogos...)
assets/
  fonts/                    Poppins
  images/                   categories/, avatars/, illustrations/
android/                    proyecto Android generado por Flutter
test/                       business_rules_test.dart
capturas/                   capturas reales de la app corriendo
entrega/                    APK release
```
