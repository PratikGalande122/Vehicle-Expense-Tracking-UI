class FuelLogModel {
  final String id;
  final String vehicleId;
  final String? vehicleName;
  final DateTime date;
  final double liters;
  final double pricePerLiter;
  final double totalCost;
  final double? odometer;
  final String? notes;

  const FuelLogModel({
    required this.id,
    required this.vehicleId,
    this.vehicleName,
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.totalCost,
    this.odometer,
    this.notes,
  });

  factory FuelLogModel.fromJson(Map<String, dynamic> json) {
    return FuelLogModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleName: json['vehicleName']?.toString(),
      // API uses 'filledAt'; fallback to 'date' for compatibility
      date: DateTime.tryParse(
              (json['filledAt'] ?? json['date'])?.toString() ?? '') ??
          DateTime.now(),
      // API uses 'litresFilled'; fallback to 'liters'
      liters: double.tryParse(
              (json['litresFilled'] ?? json['liters'])?.toString() ?? '0') ??
          0,
      // API uses 'pricePerLitre'; fallback to 'pricePerLiter'
      pricePerLiter: double.tryParse(
              (json['pricePerLitre'] ?? json['pricePerLiter'])
                      ?.toString() ??
                  '0') ??
          0,
      totalCost: double.tryParse(json['totalCost']?.toString() ?? '0') ?? 0,
      // API uses 'odometerReading'; fallback to 'odometer'
      odometer: json['odometerReading'] != null
          ? double.tryParse(json['odometerReading'].toString())
          : json['odometer'] != null
              ? double.tryParse(json['odometer'].toString())
              : null,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'liters': liters,
        'pricePerLiter': pricePerLiter,
        'totalCost': totalCost,
        if (odometer != null) 'odometer': odometer,
        if (notes != null) 'notes': notes,
      };
}
