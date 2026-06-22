class ExpenseModel {
  final String id;
  final String vehicleId;
  final String? vehicleName;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? place;
  final String? driver;
  final String? paymentMethod;
  final String? reason;

  const ExpenseModel({
    required this.id,
    required this.vehicleId,
    this.vehicleName,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.notes,
    this.place,
    this.driver,
    this.paymentMethod,
    this.reason,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleName: json['vehicleName']?.toString(),
      category: _categoryFromExpenseType(
              json['expenseType'] ?? json['category']) ??
          '',
      description: json['description']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      date: DateTime.tryParse(
              (json['expenseDate'] ?? json['date'])?.toString() ?? '') ??
          DateTime.now(),
      notes: json['notes']?.toString(),
      place: json['place']?.toString(),
      driver: json['driver']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      reason: json['reason']?.toString(),
    );
  }

  static String? _categoryFromExpenseType(dynamic v) {
    switch (v?.toString()) {
      case '1': return 'Fuel';
      case '2': return 'Service';
      case '3': return 'Insurance';
      case '4': return 'Parking';
      case '5': return 'Toll';
      case '6': return 'Repair';
      case '7': return 'Accessories';
      case '8': return 'Washing';
      case '9': return 'Other';
      default:  return v?.toString();
    }
  }

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'category': category,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  static List<String> get categories => const [
        'Fuel',
        'Service',
        'Insurance',
        'Parking',
        'Toll',
        'Repair',
        'Accessories',
        'Washing',
        'Other',
      ];
}
