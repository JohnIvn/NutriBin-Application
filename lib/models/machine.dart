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

class MachineSerial {
  final String machineSerialId;
  final String serialNumber;
  final bool isUsed;
  final bool isActive;
  final DateTime dateCreated;

  MachineSerial({
    required this.machineSerialId,
    required this.serialNumber,
    required this.isUsed,
    required this.isActive,
    required this.dateCreated,
  });

  factory MachineSerial.fromJson(Map<String, dynamic> json) {
    return MachineSerial(
      machineSerialId: json['machine_serial_id'],
      serialNumber: json['serial_number'],
      isUsed: json['is_used'],
      isActive: json['is_active'],
      dateCreated: DateTime.parse(json['date_created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machine_serial_id': machineSerialId,
      'serial_number': serialNumber,
      'is_used': isUsed,
      'is_active': isActive,
      'date_created': dateCreated.toIso8601String(),
    };
  }
}

class FertilizerAnalytics {
  final String? nitrogen;
  final String? phosphorus;
  final String? potassium;
  final double? temperature;
  final double? ph;
  final double? humidity;
  final double? moisture;
  final double? weightKg;
  final bool? reedSwitch;
  final double? methane;
  final double? airQuality;
  final double? carbonMonoxide;
  final double? combustibleGases;

  FertilizerAnalytics({
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.temperature,
    this.ph,
    this.humidity,
    this.moisture,
    this.weightKg,
    this.reedSwitch,
    this.methane,
    this.airQuality,
    this.carbonMonoxide,
    this.combustibleGases,
  });

  factory FertilizerAnalytics.fromJson(Map<String, dynamic> json) {
    return FertilizerAnalytics(
      nitrogen: json['nitrogen'] as String?,
      phosphorus: json['phosphorus'] as String?,
      potassium: json['potassium'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      ph: (json['ph'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      moisture: (json['moisture'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      reedSwitch: json['reed_switch'] as bool?,
      methane: (json['methane'] as num?)?.toDouble(),
      airQuality: (json['air_quality'] as num?)?.toDouble(),
      carbonMonoxide: (json['carbon_monoxide'] as num?)?.toDouble(),
      combustibleGases: (json['combustible_gases'] as num?)?.toDouble(),
    );
  }
}
