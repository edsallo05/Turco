import '../models/appointment.dart';
import '../models/client.dart';
import '../models/enums.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import 'salon_repository.dart';

/// Datos de prueba cargados en memoria. Las fechas se calculan a partir de
/// DateTime.now() para que nunca queden vencidas.
class SeedData {
  SeedData._();

  static const List<Service> services = [
    Service(id: 1, name: 'Corte mujer', category: ServiceCategory.corte, durationMinutes: 60, price: 30, audience: Audience.mujeres),
    Service(id: 2, name: 'Corte caballero', category: ServiceCategory.corte, durationMinutes: 45, price: 25, audience: Audience.hombres),
    Service(id: 3, name: 'Corte clásico', category: ServiceCategory.corte, durationMinutes: 30, price: 18, audience: Audience.hombres),
    Service(id: 4, name: 'Color completo', category: ServiceCategory.color, durationMinutes: 120, price: 70, audience: Audience.mujeres),
    Service(id: 5, name: 'Mechas', category: ServiceCategory.color, durationMinutes: 150, price: 85, audience: Audience.mujeres),
    Service(id: 6, name: 'Retoque de raíz', category: ServiceCategory.color, durationMinutes: 90, price: 45, audience: Audience.mujeres),
    Service(id: 7, name: 'Barba', category: ServiceCategory.barba, durationMinutes: 45, price: 20, audience: Audience.hombres),
    Service(id: 8, name: 'Afeitado', category: ServiceCategory.barba, durationMinutes: 30, price: 15, audience: Audience.hombres),
    Service(id: 9, name: 'Peinado evento', category: ServiceCategory.peinado, durationMinutes: 60, price: 40, audience: Audience.unisex),
    Service(id: 10, name: 'Brushing', category: ServiceCategory.peinado, durationMinutes: 30, price: 18, audience: Audience.mujeres),
    Service(id: 11, name: 'Hidratación', category: ServiceCategory.tratamiento, durationMinutes: 45, price: 28, audience: Audience.unisex),
    Service(id: 12, name: 'Keratina', category: ServiceCategory.tratamiento, durationMinutes: 90, price: 65, audience: Audience.unisex),
  ];

  static const List<Stylist> stylists = [
    // Solo servicios de mujeres (+ unisex).
    Stylist(id: 1, name: 'Marta Salazar', avatarPath: 'assets/images/avatars/marta.png', serviceIds: [1, 4, 5, 6, 10, 9]),
    // Solo servicios de hombres.
    Stylist(id: 2, name: 'Pedro Vega', avatarPath: 'assets/images/avatars/pedro.png', serviceIds: [2, 3, 7, 8]),
    // Ambos públicos.
    Stylist(id: 3, name: 'Lucía Torres', avatarPath: 'assets/images/avatars/lucia.png', serviceIds: [11, 12, 1, 2, 9]),
    Stylist(id: 4, name: 'Rafael Núñez', avatarPath: 'assets/images/avatars/rafael.png', serviceIds: [7, 8, 2]),
    Stylist(id: 5, name: 'Camila Ortiz', avatarPath: 'assets/images/avatars/camila.png', serviceIds: [10, 9, 6, 11]),
  ];

  static SalonRepository buildRepository({DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Client client(int id, String name, String phone, Gender g, {String? email, int daysAgo = 60}) => Client(
          id: id,
          name: name,
          phone: phone,
          gender: g,
          email: email,
          registeredAt: DateTime(today.year, today.month, today.day - daysAgo),
        );

    final clients = [
      client(1, 'Laura Gómez', '52111222', Gender.mujer, email: 'laura.gomez@correo.com', daysAgo: 120),
      client(2, 'Carlos Ruiz', '52345678', Gender.hombre, email: 'carlos.ruiz@correo.com', daysAgo: 100),
      client(3, 'Ana Martín', '53220140', Gender.mujer, daysAgo: 90),
      client(4, 'Diego Pérez', '55908771', Gender.hombre, daysAgo: 80),
      client(5, 'Sofía Díaz', '54667310', Gender.mujer, email: 'sofia.diaz@correo.com', daysAgo: 75),
      client(6, 'Javier Soto', '52774009', Gender.hombre, daysAgo: 20),
      client(7, 'Marta Peña', '53441902', Gender.mujer, daysAgo: 15),
      client(8, 'Valeria Castro', '55120387', Gender.mujer, email: 'valeria.castro@correo.com', daysAgo: 40),
      client(9, 'Andrés Molina', '52889014', Gender.hombre, daysAgo: 30),
      client(10, 'Luis Herrera', '53907125', Gender.hombre, daysAgo: 10),
    ];

    // Si hoy es domingo (salón cerrado) los datos se anclan al lunes siguiente,
    // para que "hoy" de la semilla siempre sea un día laborable.
    final anchor = today.weekday == DateTime.sunday
        ? DateTime(today.year, today.month, today.day + 1)
        : today;

    // Un domingo no admite turnos: ese día se traslada al lunes de la semana siguiente.
    DateTime day(int offset) {
      var d = DateTime(anchor.year, anchor.month, anchor.day + offset);
      if (d.weekday == DateTime.sunday) d = DateTime(d.year, d.month, d.day + 8);
      return d;
    }

    Appointment appt(
      int id,
      int offset,
      int hour,
      int minute,
      int clientId,
      int stylistId,
      List<int> serviceIds, {
      String? notes,
      bool cancelled = false,
    }) {
      final d = day(offset);
      final start = DateTime(d.year, d.month, d.day, hour, minute);
      final svc = [for (final sid in serviceIds) services.firstWhere((s) => s.id == sid)];
      final minutes = svc.fold<int>(0, (sum, s) => sum + s.durationMinutes);
      final end = start.add(Duration(minutes: minutes));
      final status = cancelled
          ? AppointmentStatus.cancelado
          : (!end.isAfter(now) ? AppointmentStatus.completado : AppointmentStatus.programado);
      var created = DateTime(start.year, start.month, start.day - 5, 10, 0);
      if (created.isAfter(now)) created = now.subtract(const Duration(days: 3));
      var updated = created.add(const Duration(days: 2));
      if (updated.isAfter(now)) updated = created;
      return Appointment(
        id: id,
        clientId: clientId,
        stylistId: stylistId,
        services: svc,
        start: start,
        notes: notes,
        status: status,
        createdAt: created,
        updatedAt: updated,
      );
    }

    const longNote =
        'La clienta pide un cambio de estilo importante: quiere pasar de un corte recto a capas largas '
        'con volumen en las puntas. Tiene el cuero cabelludo sensible, por lo que se debe evitar el agua '
        'muy caliente y los productos con fragancia fuerte. Llegó la última vez con el cabello muy seco, '
        'conviene aplicar una hidratación breve antes del secado. Prefiere que no le hablen mucho durante '
        'el servicio y pide que se le avise unos minutos antes de terminar.';

    final appointments = [
      // Hace 3 días
      appt(1, -3, 9, 0, 1, 1, [1], notes: 'Quiere un cambio de look: flequillo cortina.'),
      appt(2, -3, 11, 0, 4, 2, [8], cancelled: true),
      appt(3, -3, 14, 0, 5, 3, [12]),
      // Hace 2 días
      appt(4, -2, 10, 0, 2, 2, [2, 7], notes: 'Máquina en el número 2 a los lados.'),
      appt(5, -2, 10, 30, 3, 1, [4, 10]),
      // Ayer
      appt(6, -1, 15, 0, 8, 5, [10, 11], notes: 'Alergia a los productos con amoníaco.'),
      appt(7, -1, 10, 0, 10, 4, [2, 7, 8], notes: longNote),
      // Hoy
      appt(8, 0, 9, 0, 1, 1, [1]),
      appt(9, 0, 10, 0, 2, 2, [2, 7],
          notes: 'Prefiere la máquina en el número 2 a los lados. Llega siempre diez minutos antes y pide agua.'),
      appt(10, 0, 10, 30, 3, 1, [4, 10]),
      appt(11, 0, 12, 0, 4, 2, [8], cancelled: true),
      appt(12, 0, 14, 0, 5, 3, [11, 1]),
      // Próximos días
      appt(13, 1, 11, 0, 7, 1, [1], notes: 'Primera visita.'),
      appt(14, 1, 16, 0, 9, 2, [3]),
      appt(15, 2, 17, 30, 8, 3, [12], notes: 'Termina justo a la hora de cierre.'), // 17:30 + 90 min = 19:00
      appt(16, 3, 9, 30, 10, 4, [7]),
    ];

    return SalonRepository(
      services: services,
      stylists: stylists,
      clients: clients,
      appointments: appointments,
      clock: () => DateTime.now(),
    );
  }
}
