import 'package:flutter/foundation.dart';

import '../data/salon_repository.dart';
import '../models/enums.dart';
import '../models/service.dart';

class ServicesViewModel extends ChangeNotifier {
  ServicesViewModel(this._repo);

  final SalonRepository _repo;
  ServiceCategory? _category;
  AudienceFilter _audience = AudienceFilter.todos;

  ServiceCategory? get category => _category;
  AudienceFilter get audience => _audience;

  void setCategory(ServiceCategory? c) {
    _category = c;
    notifyListeners();
  }

  void setAudience(AudienceFilter a) {
    _audience = a;
    notifyListeners();
  }

  List<Service> get filtered => _repo.services
      .where((s) => _category == null || s.category == _category)
      .where((s) => s.matches(_audience))
      .toList();

  /// Columnas según el ancho: 2 (<600 dp), 3 (600-840 dp), 4 (>840 dp).
  static int columnsFor(double width) {
    if (width < 600) return 2;
    if (width <= 840) return 3;
    return 4;
  }
}
