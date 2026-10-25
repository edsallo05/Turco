import 'package:flutter/foundation.dart';

import '../core/utils/formatters.dart';
import '../data/salon_repository.dart';
import '../models/appointment.dart';
import '../models/client.dart';
import '../models/enums.dart';
import '../models/service.dart';
import '../models/stylist.dart';

class TimeSlot {
  const TimeSlot({required this.minutes, required this.available, required this.selected});
  final int minutes;
  final bool available;
  final bool selected;
  String get label => minutesToHhmm(minutes);
}

/// ViewModel del formulario de turno (crear y editar).
/// Aquí viven las reglas: estilistas válidos, franjas disponibles y resumen.
class AppointmentFormViewModel extends ChangeNotifier {
  AppointmentFormViewModel(this._repo, {this.editing, AppointmentFormInitial? initial}) {
    final e = editing;
    if (e != null) {
      _clientId = e.clientId;
      _stylistId = e.stylistId;
      _serviceIds = e.services.map((s) => s.id).toSet();
      _date = dateOnly(e.start);
      _startMinutes = e.start.hour * 60 + e.start.minute;
      _notes = e.notes ?? '';
    } else if (initial != null) {
      _clientId = initial.clientId;
      if (initial.serviceId != null && _repo.serviceById(initial.serviceId!) != null) {
        _serviceIds.add(initial.serviceId!);
      }
      final d = initial.date;
      if (d != null && isValidDate(d)) _date = dateOnly(d);
    }
    final client = _clientId == null ? null : _repo.clientById(_clientId!);
    _audience = client?.gender.defaultAudience ?? AudienceFilter.todos;
    _snapshot = _signature();
  }

  final SalonRepository _repo;
  final Appointment? editing;

  int? _clientId;
  int? _stylistId;
  Set<int> _serviceIds = {};
  DateTime? _date;
  int? _startMinutes;
  String _notes = '';
  AudienceFilter _audience = AudienceFilter.todos;
  String? _notice;
  late final String _snapshot;

  static const int maxNotes = 500;

  bool get isEditing => editing != null;
  int? get clientId => _clientId;
  int? get stylistId => _stylistId;
  DateTime? get date => _date;
  int? get startMinutes => _startMinutes;
  String get notes => _notes;
  AudienceFilter get audience => _audience;
  Set<int> get selectedServiceIds => _serviceIds;

  Client? get client => _clientId == null ? null : _repo.clientById(_clientId!);
  Stylist? get stylist => _stylistId == null ? null : _repo.stylistById(_stylistId!);
  List<Client> get clients => _repo.clients;

  // ------------------------------------------------------------- servicios
  List<Service> get selectedServices =>
      _repo.services.where((s) => _serviceIds.contains(s.id)).toList();

  /// Servicios visibles agrupados por categoría (los ya elegidos siempre se ven).
  Map<ServiceCategory, List<Service>> get servicesByCategory {
    final map = <ServiceCategory, List<Service>>{};
    for (final c in ServiceCategory.values) {
      final items = _repo.services
          .where((s) => s.category == c && (s.matches(_audience) || _serviceIds.contains(s.id)))
          .toList();
      if (items.isNotEmpty) map[c] = items;
    }
    return map;
  }

  /// Solo estilistas que realizan todos los servicios elegidos.
  List<Stylist> get eligibleStylists => _repo.stylistsFor(selectedServices);

  // --------------------------------------------------------------- resumen
  int get durationMinutes => selectedServices.fold(0, (s, e) => s + e.durationMinutes);
  int get totalPrice => selectedServices.fold(0, (s, e) => s + e.price);
  String get durationLabel => durationMinutes == 0 ? '0 min' : durationText(durationMinutes);
  String get endLabel => _startMinutes == null || durationMinutes == 0
      ? 'Fin --:--'
      : 'Fin ${minutesToHhmm(_startMinutes! + durationMinutes)}';

  // ------------------------------------------------------------------ fecha
  bool isValidDate(DateTime d) => !dateOnly(d).isBefore(_repo.today) && SalonSchedule.isOpenDay(d);

  DateTime get firstSelectableDate => _repo.today;

  /// Primera fecha válida a partir de hoy (para abrir el selector).
  DateTime suggestedDate() {
    var d = _date ?? _repo.today;
    while (!isValidDate(d)) {
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return d;
  }

  // ----------------------------------------------------------------- franjas
  List<TimeSlot> get slots {
    final dur = durationMinutes < SalonSchedule.slotMinutes ? SalonSchedule.slotMinutes : durationMinutes;
    return [
      for (final m in SalonSchedule.slotStarts)
        TimeSlot(minutes: m, available: _isAvailable(m, dur), selected: m == _startMinutes),
    ];
  }

  bool get hasAvailableSlot => slots.any((s) => s.available);

  bool _isAvailable(int minutes, int duration) {
    final d = _date;
    if (d == null || !isValidDate(d)) return false;
    if (minutes + duration > SalonSchedule.closeMinutes) return false;
    final start = DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);
    final keepsOriginal = editing != null && editing!.start == start;
    if (start.isBefore(_repo.now) && !keepsOriginal) return false;
    return !_repo.hasConflict(
      start: start,
      durationMinutes: duration,
      stylistId: _stylistId,
      clientId: _clientId,
      excludeId: editing?.id,
    );
  }

  // -------------------------------------------------------------- acciones
  void setClient(int? id) {
    _clientId = id;
    final c = client;
    if (c != null) _audience = c.gender.defaultAudience;
    _refresh();
  }

  void setAudience(AudienceFilter a) {
    _audience = a;
    notifyListeners();
  }

  void toggleService(int id) {
    if (!_serviceIds.remove(id)) _serviceIds.add(id);
    if (_stylistId != null && !eligibleStylists.any((s) => s.id == _stylistId)) {
      _stylistId = null;
      _notice = 'Se limpió el estilista: ya no realiza todos los servicios elegidos.';
    }
    _refresh();
  }

  void setStylist(int? id) {
    _stylistId = id;
    _refresh();
  }

  void setDate(DateTime? d) {
    _date = d == null ? null : dateOnly(d);
    _refresh();
  }

  void setStartMinutes(int? m) {
    _startMinutes = m;
    notifyListeners();
  }

  void setNotes(String v) {
    _notes = v;
    notifyListeners();
  }

  /// Si la hora elegida deja de estar libre tras un cambio, se limpia.
  void _refresh() {
    final m = _startMinutes;
    if (m != null) {
      final slot = slots.where((s) => s.minutes == m);
      if (slot.isEmpty || !slot.first.available) _startMinutes = null;
    }
    notifyListeners();
  }

  /// Aviso pendiente (por ejemplo, estilista limpiado). Se consume una vez.
  String? takeNotice() {
    final n = _notice;
    _notice = null;
    return n;
  }

  // ------------------------------------------------------------ validaciones
  String? validateClient() => _clientId == null ? 'Selecciona un cliente' : null;
  String? validateServices() => _serviceIds.isEmpty ? 'Elige al menos un servicio' : null;
  String? validateStylist() => _stylistId == null ? 'Selecciona un estilista' : null;
  String? validateDate() =>
      (_date == null || !isValidDate(_date!)) ? 'Elige una fecha válida (no domingos)' : null;
  String? validateTime() => _startMinutes == null ? 'Elige una hora para el turno' : null;
  String? validateNotes(String? v) =>
      (v ?? '').length > maxNotes ? 'Máximo $maxNotes caracteres' : null;

  // -------------------------------------------------------- cambios sin guardar
  String _signature() =>
      '$_clientId|$_stylistId|${(_serviceIds.toList()..sort()).join(',')}|$_date|$_startMinutes|$_notes';

  bool get hasChanges => _signature() != _snapshot;

  // ----------------------------------------------------------------- guardar
  /// Crea o actualiza el turno. Lanza [BusinessRuleException] si incumple una regla.
  AppointmentSavedResult save() {
    final d = _date!;
    final m = _startMinutes!;
    final start = DateTime(d.year, d.month, d.day, m ~/ 60, m % 60);
    final text = _notes.trim().isEmpty ? null : _notes.trim();
    final Appointment saved;
    if (editing == null) {
      saved = _repo.createAppointment(
        clientId: _clientId!,
        stylistId: _stylistId!,
        services: selectedServices,
        start: start,
        notes: text,
      );
    } else {
      saved = _repo.updateAppointment(
        editing!.id,
        clientId: _clientId!,
        stylistId: _stylistId!,
        services: selectedServices,
        start: start,
        notes: text,
      );
    }
    return AppointmentSavedResult(appointmentId: saved.id, date: dateOnly(saved.start));
  }
}
