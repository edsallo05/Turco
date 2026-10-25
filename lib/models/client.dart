import 'enums.dart';

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    this.email,
    required this.registeredAt,
  });

  final int id;
  final String name;

  /// Solo los 8 dígitos, sin espacios.
  final String phone;
  final Gender gender;
  final String? email;
  final DateTime registeredAt;

  Client copyWith({String? name, String? phone, Gender? gender, String? email, bool clearEmail = false}) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      email: clearEmail ? null : (email ?? this.email),
      registeredAt: registeredAt,
    );
  }
}
