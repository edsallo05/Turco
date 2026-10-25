import 'package:flutter/foundation.dart';

import '../core/utils/formatters.dart';
import '../data/salon_repository.dart';
import '../models/appointment.dart';
import '../models/client.dart';
import '../models/enums.dart';

class ClientsViewModel extends ChangeNotifier {
  ClientsViewModel(this._repo) {
    _repo.addListener(notifyListeners);
  }

  final SalonRepository _repo;
  String _query = '';
  Gender? _gender;

  static final RegExp _emailRegex = RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  String get query => _query;
  Gender? get genderFilter => _gender;

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setGender(Gender? g) {
    _gender = g;
    notifyListeners();
  }

  int get total => _repo.clients.length;
  int get womenCount => _repo.clients.where((c) => c.gender == Gender.mujer).length;
  int get menCount => _repo.clients.where((c) => c.gender == Gender.hombre).length;
  bool get hasAnyClient => _repo.clients.isNotEmpty;

  /// Búsqueda por nombre o teléfono (sin mayúsculas ni acentos) + filtro de género.
  List<Client> get filtered {
    final q = normalizeText(_query);
    final digits = _query.replaceAll(RegExp(r'\D'), '');
    return _repo.clients.where((c) {
      if (_gender != null && c.gender != _gender) return false;
      if (q.isEmpty) return true;
      final byName = normalizeText(c.name).contains(q);
      final byPhone = digits.isNotEmpty && c.phone.contains(digits);
      return byName || byPhone;
    }).toList();
  }

  int appointmentCount(Client c) => _repo.appointmentsOfClient(c.id).length;
  List<Appointment> historyOf(Client c) => _repo.appointmentsOfClient(c.id);
  int scheduledCount(Client c) => _repo.scheduledCountOfClient(c.id);
  Client? clientById(int id) => _repo.clientById(id);

  // -------------------------------------------------------- validaciones
  String? validateName(String? v) {
    final n = (v ?? '').trim();
    if (n.length < 3 || n.length > 60) return 'Escribe entre 3 y 60 caracteres';
    return null;
  }

  String? validatePhone(String? v, {int? excludeId}) {
    final p = (v ?? '').trim();
    if (!RegExp(r'^\d{8}$').hasMatch(p)) return 'Debe tener exactamente 8 dígitos';
    if (_repo.isPhoneTaken(p, excludeId: excludeId)) return 'Este teléfono ya está registrado';
    return null;
  }

  String? validateGender(Gender? g) => g == null ? 'Selecciona un género' : null;

  String? validateEmail(String? v) {
    final e = (v ?? '').trim();
    if (e.isEmpty) return null;
    return _emailRegex.hasMatch(e) ? null : 'Escribe un correo válido';
  }

  // ------------------------------------------------------------- acciones
  Client save({
    int? id,
    required String name,
    required String phone,
    required Gender gender,
    String? email,
  }) {
    final mail = (email ?? '').trim().isEmpty ? null : email!.trim();
    if (id == null) {
      return _repo.addClient(name: name.trim(), phone: phone.trim(), gender: gender, email: mail);
    }
    return _repo.updateClient(id, name: name.trim(), phone: phone.trim(), gender: gender, email: mail);
  }

  /// Mensaje si no se puede eliminar; null si se puede.
  String? deleteBlockedMessage(Client c) {
    final n = _repo.scheduledCountOfClient(c.id);
    if (n == 0) return null;
    return 'No se puede eliminar: ${c.name} tiene ${plural(n, 'turno programado', 'turnos programados')}.';
  }

  Appointment? firstScheduledOf(Client c) {
    final list = _repo.appointmentsOfClient(c.id).where((a) => a.isScheduled).toList();
    return list.isEmpty ? null : list.last;
  }

  void delete(Client c) => _repo.deleteClient(c.id);

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }
}
