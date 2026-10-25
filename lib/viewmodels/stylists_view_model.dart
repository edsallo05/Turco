import 'package:flutter/foundation.dart';

import '../data/salon_repository.dart';
import '../models/enums.dart';
import '../models/stylist.dart';

class StylistsViewModel extends ChangeNotifier {
  StylistsViewModel(this._repo) {
    _repo.addListener(notifyListeners);
  }

  final SalonRepository _repo;

  List<Stylist> get stylists => _repo.stylists;

  int scheduledToday(Stylist s) => _repo.scheduledCountOfStylistOn(s.id, _repo.today);

  int get totalScheduledToday => stylists.fold(0, (sum, s) => sum + scheduledToday(s));

  /// Categorías de los servicios del estilista, en orden de aparición.
  List<ServiceCategory> categoriesOf(Stylist s) {
    final result = <ServiceCategory>[];
    for (final id in s.serviceIds) {
      final svc = _repo.serviceById(id);
      if (svc != null && !result.contains(svc.category)) result.add(svc.category);
    }
    return result;
  }

  bool exists(int id) => _repo.stylistById(id) != null;

  @override
  void dispose() {
    _repo.removeListener(notifyListeners);
    super.dispose();
  }
}
