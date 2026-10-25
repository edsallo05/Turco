import 'package:flutter/foundation.dart';

import '../data/salon_repository.dart';
import '../models/appointment.dart';
import '../models/client.dart';
import '../models/stylist.dart';

class AppointmentDetailViewModel extends ChangeNotifier {
  AppointmentDetailViewModel(this._repo, this.appointmentId) {
    _repo.addListener(notifyListeners);
  }

  final SalonRepository _repo;

  /// Puede ser null si la ruta trae un identificador inválido.
  final int? appointmentId;

  Appointment? get appointment => appointmentId == null ? null : _repo.appointmentById(appointmentId!);
  bool get notFound => appointment == null;
  Client? get client => appointment == null ? null : _repo.clientById(appointment!.clientId);
  Stylist? get stylist => appointment == null ? null : _repo.stylistById(appointment!.stylistId);

  void complete() => _repo.completeAppointment(appointmentId!);
  void cancel() => _repo.cancelAppointment(appointmentId!);

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }
}
