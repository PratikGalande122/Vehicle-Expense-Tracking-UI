class VehicleModel {
  final String id;
  final String name;       // vehicle's given name (e.g. "My Bike")
  final String make;       // brand (e.g. "Honda")
  final String model;      // model (e.g. "CBR")
  final int year;
  final String licensePlate; // registrationNumber in API
  final String? vehicleType; // "Bike", "Car", "Scooter", "Truck", "Other"
  final String? fuelType;    // "Petrol", "Diesel", "Electric", "CNG", "Hybrid"
  final DateTime? createdAt;

  const VehicleModel({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vehicleType,
    this.fuelType,
    this.createdAt,
  });

  // Maps API integer enums to display strings
  static String _fuelTypeFromInt(dynamic v) {
    switch (v?.toString()) {
      case '1': return 'Petrol';
      case '2': return 'Diesel';
      case '3': return 'Electric';
      case '4': return 'CNG';
      case '5': return 'Hybrid';
      default:  return v?.toString() ?? '';
    }
  }

  static String _vehicleTypeFromInt(dynamic v) {
    switch (v?.toString()) {
      case '1': return 'Bike';
      case '2': return 'Car';
      case '3': return 'Scooter';
      case '4': return 'Truck';
      case '5': return 'Other';
      default:  return v?.toString() ?? '';
    }
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      make: json['brand']?.toString() ?? json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      licensePlate: json['registrationNumber']?.toString() ??
          json['licensePlate']?.toString() ?? '',
      vehicleType: _vehicleTypeFromInt(json['vehicleType']),
      fuelType: _fuelTypeFromInt(json['fuelType']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  // toJson sends the field names the API expects for create/update
  Map<String, dynamic> toJson() => {
        'name': name,
        'brand': make,
        'model': model,
        'year': year,
        'registrationNumber': licensePlate,
        if (vehicleType != null) 'vehicleType': _vehicleTypeToInt(vehicleType!),
        if (fuelType != null) 'fuelType': _fuelTypeToInt(fuelType!),
      };

  static int _fuelTypeToInt(String v) {
    switch (v) {
      case 'Petrol':   return 1;
      case 'Diesel':   return 2;
      case 'Electric': return 3;
      case 'CNG':      return 4;
      case 'Hybrid':   return 5;
      default:         return 1;
    }
  }

  static int _vehicleTypeToInt(String v) {
    switch (v) {
      case 'Bike':    return 1;
      case 'Car':     return 2;
      case 'Scooter': return 3;
      case 'Truck':   return 4;
      default:        return 5;
    }
  }

  String get displayName {
    if (name.isNotEmpty) return name;
    return '$year $make $model'.trim();
  }

  static List<String> get fuelTypes => const [
        'Petrol',
        'Diesel',
        'Electric',
        'CNG',
        'Hybrid',
      ];

  static List<String> get vehicleTypes => const [
        'Bike',
        'Car',
        'Scooter',
        'Truck',
        'Other',
      ];
}
