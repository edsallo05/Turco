enum ServiceCategory {
  corte('Corte'),
  color('Color'),
  barba('Barba'),
  peinado('Peinado'),
  tratamiento('Tratamiento');

  const ServiceCategory(this.label);
  final String label;

  /// Nombre del archivo en assets/images/categories/.
  String get imagePath => 'assets/images/categories/$name.png';
}

enum Audience {
  mujeres('Mujeres'),
  hombres('Hombres'),
  unisex('Unisex');

  const Audience(this.label);
  final String label;
}

/// Filtro de público de las pantallas (Todos, Mujeres, Hombres).
enum AudienceFilter {
  todos('Todos'),
  mujeres('Mujeres'),
  hombres('Hombres');

  const AudienceFilter(this.label);
  final String label;
}

enum Gender {
  mujer('Mujer'),
  hombre('Hombre');

  const Gender(this.label);
  final String label;

  AudienceFilter get defaultAudience =>
      this == Gender.mujer ? AudienceFilter.mujeres : AudienceFilter.hombres;
}

enum AppointmentStatus {
  programado('Programado'),
  completado('Completado'),
  cancelado('Cancelado');

  const AppointmentStatus(this.label);
  final String label;
}
