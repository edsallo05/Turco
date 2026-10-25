import 'enums.dart';
import 'service.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.clientId,
    required this.stylistId,
    required this.services,
    required this.start,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int clientId;
  final int stylistId;
  final List<Service> services;
  final DateTime start;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Valores calculados: no se guardan por separado.
  int get durationMinutes => services.fold(0, (sum, s) => sum + s.durationMinutes);
  DateTime get end => start.add(Duration(minutes: durationMinutes));
  int get totalPrice => services.fold(0, (sum, s) => sum + s.price);
  String get servicesLabel => services.map((s) => s.name).join(' + ');

  bool get isScheduled => status == AppointmentStatus.programado;

  /// Los turnos cancelados no ocupan horario.
  bool get occupiesTime => status != AppointmentStatus.cancelado;

  /// Un turno que termina a las 10:00 no se solapa con uno que empieza a las 10:00.
  bool overlaps(DateTime otherStart, DateTime otherEnd) =>
      start.isBefore(otherEnd) && otherStart.isBefore(end);

  Appointment copyWith({
    int? clientId,
    int? stylistId,
    List<Service>? services,
    DateTime? start,
    String? notes,
    bool clearNotes = false,
    AppointmentStatus? status,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id,
      clientId: clientId ?? this.clientId,
      stylistId: stylistId ?? this.stylistId,
      services: services ?? this.services,
      start: start ?? this.start,
      notes: clearNotes ? null : (notes ?? this.notes),
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Resultado que el formulario devuelve con `context.pop(valor)`.
class AppointmentSavedResult {
  const AppointmentSavedResult({required this.appointmentId, required this.date});
  final int appointmentId;
  final DateTime date;
}

/// Datos iniciales que otras pantallas envían al formulario con `extra`.
class AppointmentFormInitial {
  const AppointmentFormInitial({this.clientId, this.serviceId, this.date});
  final int? clientId;
  final int? serviceId;
  final DateTime? date;
}
