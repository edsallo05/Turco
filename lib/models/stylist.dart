class Stylist {
  const Stylist({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.serviceIds,
  });

  final int id;
  final String name;
  final String avatarPath;
  final List<int> serviceIds;

  bool performs(int serviceId) => serviceIds.contains(serviceId);
}
