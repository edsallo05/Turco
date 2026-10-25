import 'package:flutter_test/flutter_test.dart';
import 'package:turco/data/salon_repository.dart';
import 'package:turco/data/seed_data.dart';

void main() {
  test('el turno que termina a las 10:00 no se solapa con uno que empieza a las 10:00', () {
    final now = DateTime(2026, 10, 19, 8, 0); // lunes
    final repo = SalonRepository(
      services: SeedData.services,
      stylists: SeedData.stylists,
      clients: SeedData.buildRepository(clock: now).clients,
      appointments: const [],
      clock: () => now,
    );
    final svc = [SeedData.services.first]; // Corte mujer, 60 min
    repo.createAppointment(clientId: 1, stylistId: 1, services: svc, start: DateTime(2026, 10, 20, 9, 0));
    // Empieza justo cuando termina el anterior: permitido.
    repo.createAppointment(clientId: 3, stylistId: 1, services: svc, start: DateTime(2026, 10, 20, 10, 0));
    // Solapa: debe fallar.
    expect(
      () => repo.createAppointment(clientId: 5, stylistId: 1, services: svc, start: DateTime(2026, 10, 20, 9, 30)),
      throwsA(isA<BusinessRuleException>()),
    );
  });

  test('no se permiten domingos ni turnos que terminen después de las 19:00', () {
    final now = DateTime(2026, 10, 19, 8, 0);
    final repo = SalonRepository(
      services: SeedData.services,
      stylists: SeedData.stylists,
      clients: SeedData.buildRepository(clock: now).clients,
      appointments: const [],
      clock: () => now,
    );
    final svc = [SeedData.services.first];
    expect(
      () => repo.createAppointment(clientId: 1, stylistId: 1, services: svc, start: DateTime(2026, 10, 25, 10, 0)),
      throwsA(isA<BusinessRuleException>()),
    );
    expect(
      () => repo.createAppointment(clientId: 1, stylistId: 1, services: svc, start: DateTime(2026, 10, 20, 18, 30)),
      throwsA(isA<BusinessRuleException>()),
    );
  });
}
