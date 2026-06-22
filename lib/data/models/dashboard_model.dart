class DashboardModel {
  final int totalVehicles;
  final double totalFuelCost;
  final double totalExpenseCost;
  final List<VehicleSummary> vehicleSummaries;
  final List<ExpenseBreakdown> expenseBreakdown;

  const DashboardModel({
    required this.totalVehicles,
    required this.totalFuelCost,
    required this.totalExpenseCost,
    required this.vehicleSummaries,
    required this.expenseBreakdown,
  });

  double get totalCost => totalFuelCost + totalExpenseCost;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalVehicles:
          int.tryParse(json['totalVehicles']?.toString() ?? '0') ?? 0,
      totalFuelCost:
          double.tryParse(json['totalFuelCost']?.toString() ?? '0') ?? 0,
      totalExpenseCost:
          double.tryParse(json['totalExpenseCost']?.toString() ?? '0') ?? 0,
      vehicleSummaries: (json['vehicleSummaries'] as List<dynamic>?)
              ?.map((e) => VehicleSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expenseBreakdown: (json['expenseBreakdown'] as List<dynamic>?)
              ?.map((e) => ExpenseBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class VehicleSummary {
  final String vehicleId;
  final String vehicleName;
  final double totalFuelCost;
  final double totalExpenseCost;
  final int fuelLogCount;
  final int expenseCount;

  const VehicleSummary({
    required this.vehicleId,
    required this.vehicleName,
    required this.totalFuelCost,
    required this.totalExpenseCost,
    required this.fuelLogCount,
    required this.expenseCount,
  });

  double get totalCost => totalFuelCost + totalExpenseCost;

  factory VehicleSummary.fromJson(Map<String, dynamic> json) {
    return VehicleSummary(
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleName: json['vehicleName']?.toString() ?? '',
      // API returns 'fuelCost'; fallback to 'totalFuelCost'
      totalFuelCost: double.tryParse(
              (json['fuelCost'] ?? json['totalFuelCost'])?.toString() ?? '0') ??
          0,
      // API returns 'otherExpenses'; fallback to 'totalExpenseCost'
      totalExpenseCost: double.tryParse(
              (json['otherExpenses'] ?? json['totalExpenseCost'])
                      ?.toString() ??
                  '0') ??
          0,
      // API doesn't return log counts; default to 0
      fuelLogCount:
          int.tryParse(json['fuelLogCount']?.toString() ?? '0') ?? 0,
      expenseCount:
          int.tryParse(json['expenseCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class ExpenseBreakdown {
  final String category;
  final double amount;
  final double percentage;

  const ExpenseBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseBreakdown(
      category: json['category']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      percentage:
          double.tryParse(json['percentage']?.toString() ?? '0') ?? 0,
    );
  }
}
