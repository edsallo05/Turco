import 'enums.dart';

class Service {
  const Service({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.price,
    required this.audience,
  });

  final int id;
  final String name;
  final ServiceCategory category;
  final int durationMinutes;
  final int price;
  final Audience audience;

  bool matches(AudienceFilter filter) {
    switch (filter) {
      case AudienceFilter.todos:
        return true;
      case AudienceFilter.mujeres:
        return audience != Audience.hombres;
      case AudienceFilter.hombres:
        return audience != Audience.mujeres;
    }
  }
}
