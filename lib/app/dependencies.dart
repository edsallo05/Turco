import '../data/salon_repository.dart';
import '../data/seed_data.dart';
import '../viewmodels/agenda_view_model.dart';
import '../viewmodels/clients_view_model.dart';
import '../viewmodels/services_view_model.dart';
import '../viewmodels/stylists_view_model.dart';
import '../viewmodels/theme_view_model.dart';

/// Contenedor simple de dependencias (sin paquetes de estado externos).
/// Se crea una vez en main() y se pasa por constructor a las pantallas.
class AppDependencies {
  AppDependencies._(this.repository)
      : theme = ThemeViewModel(),
        agenda = AgendaViewModel(repository),
        clients = ClientsViewModel(repository),
        services = ServicesViewModel(repository),
        stylists = StylistsViewModel(repository);

  factory AppDependencies.create() => AppDependencies._(SeedData.buildRepository());

  final SalonRepository repository;
  final ThemeViewModel theme;
  final AgendaViewModel agenda;
  final ClientsViewModel clients;
  final ServicesViewModel services;
  final StylistsViewModel stylists;
}
