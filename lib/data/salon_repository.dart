import 'package:flutter/foundation.dart';

import '../core/utils/formatters.dart';
import '../models/appointment.dart';
import '../models/client.dart';
import '../models/enums.dart';
import '../models/service.dart';
import '../models/stylist.dart';

/// Error de regla de negocio con un mensaje listo para mostrar.
class BusinessRuleException implements Exception {
  const BusinessRuleException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Horario del salón: lunes a sábado de 9:00 a 19:00, franjas de 30 min.
class SalonSchedule {
  SalonSchedule._();
  static const int openMinutes = 9 * 60;
  static const int closeMinutes = 19 * 60;
  static const int slotMinutes = 30;

  static bool isOpenDay(DateTime d) => d.weekday != DateTime.sunday;

  static List<int> get slotStarts =>
      [for (int m = openMinutes; m < closeMinutes; m += slotMinutes) m];
}

/// Fuente única de datos en memoria y reglas de negocio (modelo).
/// Todos los ViewModels escuchan este objeto, así los cambios se reflejan al instante.
class SalonRepository extends ChangeNotifier {
  SalonRepository({
    required List<Service> services,
    required List<Stylist> stylists,
    required List<Client> clients,
    required List<Appointment> appointments,
    DateTime Function()? clock,
  })  : _services = List.unmodifiable(services),
        _stylists = List.unmodifiable(stylists),
        _clients = List.of(clients),
        _appointments = List.of(appointments),
        _clock = clock ?? DateTime.now {
    _nextClientId = _clients.fold(0, (m, c) => c.id > m ? c.id : m) + 1;
    _nextAppointmentId = _appointments.fold(0, (m, a) => a.id > m ? a.id : m) + 1;
  }

  final List<Service> _services;
  final List<Stylist> _stylists;
  final List<Client> _clients;
  final List<Appointment> _appointments;
  final DateTime Function() _clock;
  late int _nextClientId;
  late int _nextAppointmentId;

  DateTime get now => _clock();
  DateTime get today => dateOnly(now);

  // ---------------------------------------------------------------- consultas
  List<Service> get services => _services;
  List<Stylist> get stylists => _stylists;
  List<Client> get clients => List.unmodifiable(_clients);
  List<Appointment> get appointments => List.unmodifiable(_appointments);

  Service? serviceById(int id) {
    for (final s in _services) {
      if (s.id == id) return s;
    }
    return null;
  }

  Stylist? stylistById(int id) {
    for (final s in _stylists) {
      if (s.id == id) return s;
    }
    return null;
  }

  Client? clientById(int id) {
    for (final c in _clients) {
      if (c.id == id) return c;
    }
    return null;
  }

  Appointment? appointmentById(int id) {
    for (final a in _appointments) {
      if (a.id == id) return a;
    }
    return null;
  }

  List<Appointment> appointmentsOnDay(DateTime day) {
    final list = _appointments.where((a) => isSameDay(a.start, day)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  /// Historial del cliente, del más reciente al más antiguo.
  List<Appointment> appointmentsOfClient(int clientId) {
    final list = _appointments.where((a) => a.clientId == clientId).toList()
      ..sort((a, b) => b.start.compareTo(a.start));
    return list;
  }

  int scheduledCountOfClient(int clientId) =>
      _appointments.where((a) => a.clientId == clientId && a.isScheduled).length;

  int scheduledCountOfStylistOn(int stylistId, DateTime day) => _appointments
      .where((a) => a.stylistId == stylistId && a.isScheduled && isSameDay(a.start, day))
      .length;

  /// Estilistas que realizan TODOS los servicios dados.
  List<Stylist> stylistsFor(Iterable<Service> services) {
    final list = services.toList();
    return _stylists.where((st) => list.every((s) => st.performs(s.id))).toList();
  }

  // ------------------------------------------------------------ reglas turnos
  /// ¿Hay solape con otro turno (no cancelado) del mismo estilista o cliente?
  bool hasConflict({
    required DateTime start,
    required int durationMinutes,
    int? stylistId,
    int? clientId,
    int? excludeId,
  }) {
    final end = start.add(Duration(minutes: durationMinutes));
    for (final a in _appointments) {
      if (a.id == excludeId || !a.occupiesTime) continue;
      if (!a.overlaps(start, end)) continue;
      if (stylistId != null && a.stylistId == stylistId) return true;
      if (clientId != null && a.clientId == clientId) return true;
    }
    return false;
  }

  void _validateAppointment({
    required int clientId,
    required int stylistId,
    required List<Service> services,
    required DateTime start,
    Appointment? editing,
  }) {
    final stylist = stylistById(stylistId);
    if (clientById(clientId) == null) throw const BusinessRuleException('El cliente no existe.');
    if (stylist == null) throw const BusinessRuleException('El estilista no existe.');
    if (services.isEmpty) throw const BusinessRuleException('Elige al menos un servicio.');
    if (!services.every((s) => stylist.performs(s.id))) {
      throw const BusinessRuleException('El estilista no realiza todos los servicios elegidos.');
    }
    if (!SalonSchedule.isOpenDay(start)) {
      throw const BusinessRuleException('El salón está cerrado los domingos.');
    }
    final duration = services.fold<int>(0, (s, e) => s + e.durationMinutes);
    final startMin = start.hour * 60 + start.minute;
    if (startMin < SalonSchedule.openMinutes ||
        startMin + duration > SalonSchedule.closeMinutes ||
        startMin % SalonSchedule.slotMinutes != 0) {
      throw const BusinessRuleException(
          'El turno debe empezar en una franja de 30 minutos y terminar a las 19:00 como máximo.');
    }
    final moved = editing == null || editing.start != start;
    if (moved && start.isBefore(now)) {
      throw const BusinessRuleException('No se pueden programar turnos en una fecha y hora que ya pasaron.');
    }
    if (hasConflict(start: start, durationMinutes: duration, stylistId: stylistId, excludeId: editing?.id)) {
      throw const BusinessRuleException('El estilista ya tiene un turno que se solapa con ese horario.');
    }
    if (hasConflict(start: start, durationMinutes: duration, clientId: clientId, excludeId: editing?.id)) {
      throw const BusinessRuleException('El cliente ya tiene un turno que se solapa con ese horario.');
    }
  }

  Appointment createAppointment({
    required int clientId,
    required int stylistId,
    required List<Service> services,
    required DateTime start,
    String? notes,
  }) {
    _validateAppointment(clientId: clientId, stylistId: stylistId, services: services, start: start);
    final stamp = now;
    final a = Appointment(
      id: _nextAppointmentId++,
      clientId: clientId,
      stylistId: stylistId,
      services: List.unmodifiable(services),
      start: start,
      notes: notes,
      status: AppointmentStatus.programado,
      createdAt: stamp,
      updatedAt: stamp,
    );
    _appointments.add(a);
    notifyListeners();
    return a;
  }

  Appointment updateAppointment(
    int id, {
    required int clientId,
    required int stylistId,
    required List<Service> services,
    required DateTime start,
    String? notes,
  }) {
    final current = appointmentById(id);
    if (current == null) throw const BusinessRuleException('El turno no existe.');
    if (!current.isScheduled) throw const BusinessRuleException('Solo los turnos programados se pueden editar.');
    _validateAppointment(
        clientId: clientId, stylistId: stylistId, services: services, start: start, editing: current);
    final updated = current.copyWith(
      clientId: clientId,
      stylistId: stylistId,
      services: List.unmodifiable(services),
      start: start,
      notes: notes,
      clearNotes: notes == null,
      updatedAt: now,
    );
    _appointments[_appointments.indexWhere((a) => a.id == id)] = updated;
    notifyListeners();
    return updated;
  }

  void _setStatus(int id, AppointmentStatus status) {
    final current = appointmentById(id);
    if (current == null) throw const BusinessRuleException('El turno no existe.');
    if (!current.isScheduled) {
      throw const BusinessRuleException('Solo los turnos programados se pueden completar o cancelar.');
    }
    _appointments[_appointments.indexWhere((a) => a.id == id)] =
        current.copyWith(status: status, updatedAt: now);
    notifyListeners();
  }

  void completeAppointment(int id) => _setStatus(id, AppointmentStatus.completado);

  /// Los turnos no se eliminan: la baja es la cancelación.
  void cancelAppointment(int id) => _setStatus(id, AppointmentStatus.cancelado);

  // ----------------------------------------------------------------- clientes
  bool isPhoneTaken(String phone, {int? excludeId}) =>
      _clients.any((c) => c.phone == phone && c.id != excludeId);

  Client addClient({
    required String name,
    required String phone,
    required Gender gender,
    String? email,
  }) {
    if (isPhoneTaken(phone)) throw const BusinessRuleException('Ese teléfono ya está registrado.');
    final c = Client(
      id: _nextClientId++,
      name: name,
      phone: phone,
      gender: gender,
      email: email,
      registeredAt: now,
    );
    _clients.add(c);
    notifyListeners();
    return c;
  }

  Client updateClient(
    int id, {
    required String name,
    required String phone,
    required Gender gender,
    String? email,
  }) {
    final i = _clients.indexWhere((c) => c.id == id);
    if (i < 0) throw const BusinessRuleException('El cliente no existe.');
    if (isPhoneTaken(phone, excludeId: id)) throw const BusinessRuleException('Ese teléfono ya está registrado.');
    final updated = _clients[i].copyWith(
      name: name,
      phone: phone,
      gender: gender,
      email: email,
      clearEmail: email == null,
    );
    _clients[i] = updated;
    notifyListeners();
    return updated;
  }

  /// No se puede eliminar un cliente con turnos programados. Si no los tiene,
  /// se elimina junto con su historial (completados y cancelados).
  void deleteClient(int id) {
    final c = clientById(id);
    if (c == null) return;
    if (scheduledCountOfClient(id) > 0) {
      throw BusinessRuleException(
          'No se puede eliminar: ${c.name} tiene ${plural(scheduledCountOfClient(id), 'turno programado', 'turnos programados')}.');
    }
    _appointments.removeWhere((a) => a.clientId == id);
    _clients.removeWhere((x) => x.id == id);
    notifyListeners();
  }
}
