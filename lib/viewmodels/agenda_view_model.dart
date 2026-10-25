import 'package:flutter/foundation.dart';

import '../core/utils/formatters.dart';
import '../data/salon_repository.dart';
import '../models/appointment.dart';
import '../models/enums.dart';
import '../models/stylist.dart';

class DaySummary {
  const DaySummary({required this.scheduled, required this.completed, required this.income});
  final int scheduled;
  final int completed;
  final int income;
}

class AgendaViewModel extends ChangeNotifier {
  AgendaViewModel(this._repo) {
    _selected = dateOnly(_repo.now);
    _repo.addListener(notifyListeners);
  }

  final SalonRepository _repo;
  late DateTime _selected;
  int? _stylistId;
  AppointmentStatus? _status;
  AppointmentSavedResult? _pendingSaved;

  DateTime get selectedDate => _selected;
  int? get stylistFilter => _stylistId;
  AppointmentStatus? get statusFilter => _status;
  List<Stylist> get stylists => _repo.stylists;

  /// Los siete días (lunes a domingo) de la semana de la fecha seleccionada.
  List<DateTime> get weekDays {
    final monday = DateTime(_selected.year, _selected.month, _selected.day - (_selected.weekday - 1));
    return List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
  }

  void selectDate(DateTime d) {
    _selected = dateOnly(d);
    notifyListeners();
  }

  void nextWeek() => selectDate(DateTime(_selected.year, _selected.month, _selected.day + 7));
  void previousWeek() => selectDate(DateTime(_selected.year, _selected.month, _selected.day - 7));

  void setStylist(int? id) {
    if (_stylistId == id) return;
    _stylistId = id;
    notifyListeners();
  }

  void setStatus(AppointmentStatus? s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  /// Resumen del día completo (no depende de los filtros).
  DaySummary get summary {
    final day = _repo.appointmentsOnDay(_selected);
    final scheduled = day.where((a) => a.status == AppointmentStatus.programado).length;
    final completed = day.where((a) => a.status == AppointmentStatus.completado).length;
    final income = day.where((a) => a.status != AppointmentStatus.cancelado).fold<int>(0, (s, a) => s + a.totalPrice);
    return DaySummary(scheduled: scheduled, completed: completed, income: income);
  }

  /// Turnos del día, ordenados por hora y con los filtros aplicados.
  List<Appointment> get appointments => _repo
      .appointmentsOnDay(_selected)
      .where((a) => _stylistId == null || a.stylistId == _stylistId)
      .where((a) => _status == null || a.status == _status)
      .toList();

  String clientName(Appointment a) => _repo.clientById(a.clientId)?.name ?? 'Cliente eliminado';
  String stylistFirstName(Appointment a) =>
      (_repo.stylistById(a.stylistId)?.name ?? '').split(' ').first;

  void complete(int id) => _repo.completeAppointment(id);
  void cancel(int id) => _repo.cancelAppointment(id);

  // ------------------------------------------------ resultado del formulario
  /// Se llama al volver del formulario: se ubica en la fecha del turno guardado.
  void registerSaved(AppointmentSavedResult r) {
    _selected = dateOnly(r.date);
    final saved = _repo.appointmentById(r.appointmentId);
    if (saved != null) {
      if (_stylistId != null && saved.stylistId != _stylistId) _stylistId = null;
      if (_status != null && saved.status != _status) _status = null;
    }
    _pendingSaved = r;
    notifyListeners();
  }

  AppointmentSavedResult? takePendingSaved() {
    final r = _pendingSaved;
    _pendingSaved = null;
    return r;
  }

  bool get hasPendingSaved => _pendingSaved != null;

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }
}
