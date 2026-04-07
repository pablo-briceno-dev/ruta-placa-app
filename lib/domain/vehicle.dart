class Vehicle {
  final String plate;
  final String type;
  final String alias;

  Vehicle({required this.plate, required this.type, required this.alias});

  Map<String, dynamic> toJson() => {
    'plate': plate,
    'type': type,
    'alias': alias,
  };

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      Vehicle(plate: json['plate'], type: json['type'], alias: json['alias']);
}
