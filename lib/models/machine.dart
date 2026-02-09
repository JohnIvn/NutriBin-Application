// Machine Model
enum MachineStatus { online, offline, maintenance }

class Machine {
  final String id;
  final String name;
  final String location;
  final String deviceId;
  final String description;
  final MachineStatus status;
  final DateTime registeredAt;

  Machine({
    required this.id,
    required this.name,
    required this.location,
    required this.deviceId,
    required this.description,
    required this.status,
    required this.registeredAt,
  });
}

// class NutriBin {
//   final String id;
//   final String name;
//   final String location;
//   final String deviceId;
//   final String description;
//   final MachineStatus status;
//   final DateTime registeredAt;
//   NutriBin({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.deviceId,
//     required this.description,
//     required this.status,
//     required this.registeredAt,
//   });
// }
