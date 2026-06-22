// ============================================================================
// api_models.dart
// Complete Flutter models synchronized with VehicleExpense .NET 8 API
// ============================================================================

// ── Enums ────────────────────────────────────────────────────────────────────

/// Matches VehicleExpense.Domain.Enums.VehicleType
enum VehicleType {
  bike(1),
  car(2),
  scooter(3),
  truck(4),
  other(5);

  const VehicleType(this.value);
  final int value;

  static VehicleType fromValue(int v) =>
      VehicleType.values.firstWhere((e) => e.value == v,
          orElse: () => VehicleType.other);

  String get label => switch (this) {
        VehicleType.bike => 'Bike',
        VehicleType.car => 'Car',
        VehicleType.scooter => 'Scooter',
        VehicleType.truck => 'Truck',
        VehicleType.other => 'Other',
      };
}

/// Matches VehicleExpense.Domain.Enums.FuelType
enum FuelType {
  petrol(1),
  diesel(2),
  electric(3),
  cng(4),
  hybrid(5);

  const FuelType(this.value);
  final int value;

  static FuelType fromValue(int v) =>
      FuelType.values.firstWhere((e) => e.value == v,
          orElse: () => FuelType.petrol);

  String get label => switch (this) {
        FuelType.petrol => 'Petrol',
        FuelType.diesel => 'Diesel',
        FuelType.electric => 'Electric',
        FuelType.cng => 'CNG',
        FuelType.hybrid => 'Hybrid',
      };
}

/// Matches VehicleExpense.Domain.Enums.ExpenseType
enum ExpenseType {
  fuel(1),
  service(2),
  insurance(3),
  parking(4),
  toll(5),
  repair(6),
  accessories(7),
  washing(8),
  other(9);

  const ExpenseType(this.value);
  final int value;

  static ExpenseType fromValue(int v) =>
      ExpenseType.values.firstWhere((e) => e.value == v,
          orElse: () => ExpenseType.other);

  String get label => switch (this) {
        ExpenseType.fuel => 'Fuel',
        ExpenseType.service => 'Service',
        ExpenseType.insurance => 'Insurance',
        ExpenseType.parking => 'Parking',
        ExpenseType.toll => 'Toll',
        ExpenseType.repair => 'Repair',
        ExpenseType.accessories => 'Accessories',
        ExpenseType.washing => 'Washing',
        ExpenseType.other => 'Other',
      };
}

/// Matches VehicleExpense.Domain.Enums.Gender
enum Gender {
  male(0),
  female(1),
  other(2);

  const Gender(this.value);
  final int value;

  static Gender? fromValue(int? v) {
    if (v == null) return null;
    return Gender.values.firstWhere((e) => e.value == v,
        orElse: () => Gender.other);
  }

  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.other => 'Other',
      };
}

/// Matches VehicleExpense.Domain.Enums.BloodGroup
enum BloodGroup {
  aPositive(0),
  aNegative(1),
  bPositive(2),
  bNegative(3),
  abPositive(4),
  abNegative(5),
  oPositive(6),
  oNegative(7);

  const BloodGroup(this.value);
  final int value;

  static BloodGroup? fromValue(int? v) {
    if (v == null) return null;
    return BloodGroup.values.firstWhere((e) => e.value == v,
        orElse: () => BloodGroup.oPositive);
  }

  String get label => switch (this) {
        BloodGroup.aPositive => 'A+',
        BloodGroup.aNegative => 'A-',
        BloodGroup.bPositive => 'B+',
        BloodGroup.bNegative => 'B-',
        BloodGroup.abPositive => 'AB+',
        BloodGroup.abNegative => 'AB-',
        BloodGroup.oPositive => 'O+',
        BloodGroup.oNegative => 'O-',
      };
}

// ── Auth Models ──────────────────────────────────────────────────────────────

class SendOtpRequest {
  final String email;
  final String fullName;
  const SendOtpRequest({required this.email, required this.fullName});
  Map<String, dynamic> toJson() => {'email': email, 'fullName': fullName};
}

class SendOtpResponse {
  final String message;
  final String? otp;
  const SendOtpResponse({required this.message, this.otp});
  factory SendOtpResponse.fromJson(Map<String, dynamic> json) =>
      SendOtpResponse(message: json['message'] ?? '', otp: json['otp']);
}

class VerifyOtpRequest {
  final String email;
  final String otp;
  const VerifyOtpRequest({required this.email, required this.otp});
  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

/// POST /api/auth/verify-otp → response
class AuthResponse {
  final int userId;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );
}

// ── User Profile Models ───────────────────────────────────────────────────────

/// GET/PUT /api/user/profile → response
class UserProfileResponse {
  final int id;
  final String fullName;
  final String email;
  final String? mobileNumber;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final BloodGroup? bloodGroup;
  final String? medicalConditions;
  final String? allergies;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? emergencyContactRelation;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;
  final String? preferredMechanicName;
  final String? preferredMechanicContact;
  final String? preferredHospital;
  final String? preferredHospitalContact;
  final String? drivingLicenseNumber;
  final DateTime? licenseExpiryDate;
  final String? riderNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfileResponse({
    required this.id,
    required this.fullName,
    required this.email,
    this.mobileNumber,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.bloodGroup,
    this.medicalConditions,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.emergencyContactRelation,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.preferredMechanicName,
    this.preferredMechanicContact,
    this.preferredHospital,
    this.preferredHospitalContact,
    this.drivingLicenseNumber,
    this.licenseExpiryDate,
    this.riderNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileResponse(
        id: json['id'],
        fullName: json['fullName'] ?? '',
        email: json['email'] ?? '',
        mobileNumber: json['mobileNumber'],
        profileImageUrl: json['profileImageUrl'],
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.tryParse(json['dateOfBirth'])
            : null,
        gender: Gender.fromValue(json['gender']),
        address: json['address'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        pincode: json['pincode'],
        bloodGroup: BloodGroup.fromValue(json['bloodGroup']),
        medicalConditions: json['medicalConditions'],
        allergies: json['allergies'],
        emergencyContactName: json['emergencyContactName'],
        emergencyContactNumber: json['emergencyContactNumber'],
        emergencyContactRelation: json['emergencyContactRelation'],
        insuranceProvider: json['insuranceProvider'],
        insurancePolicyNumber: json['insurancePolicyNumber'],
        preferredMechanicName: json['preferredMechanicName'],
        preferredMechanicContact: json['preferredMechanicContact'],
        preferredHospital: json['preferredHospital'],
        preferredHospitalContact: json['preferredHospitalContact'],
        drivingLicenseNumber: json['drivingLicenseNumber'],
        licenseExpiryDate: json['licenseExpiryDate'] != null
            ? DateTime.tryParse(json['licenseExpiryDate'])
            : null,
        riderNotes: json['riderNotes'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );
}

// ── Vehicle Models ───────────────────────────────────────────────────────────

/// GET /api/vehicles list item / POST /PUT response
class Vehicle {
  final int id;
  final int userId;
  final String name;
  final String registrationNumber;
  final VehicleType vehicleType;
  final FuelType fuelType;
  final int year;
  final String? brand;
  final String? model;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.name,
    required this.registrationNumber,
    required this.vehicleType,
    required this.fuelType,
    required this.year,
    this.brand,
    this.model,
    required this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'],
        userId: json['userId'] ?? 0,
        name: json['name'] ?? '',
        registrationNumber: json['registrationNumber'] ?? '',
        vehicleType: VehicleType.fromValue(json['vehicleType'] ?? 5),
        fuelType: FuelType.fromValue(json['fuelType'] ?? 1),
        year: json['year'] ?? 0,
        brand: json['brand'],
        model: json['model'],
        createdAt:
            DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );

  String get displayName => name.isNotEmpty ? name : '$year ${brand ?? ''} ${model ?? ''}'.trim();
}

/// POST/PUT /api/vehicles → request body
class AddVehicleRequest {
  final String name;
  final String registrationNumber;
  final VehicleType vehicleType;
  final FuelType fuelType;
  final int year;
  final String? brand;
  final String? model;

  const AddVehicleRequest({
    required this.name,
    required this.registrationNumber,
    required this.vehicleType,
    required this.fuelType,
    required this.year,
    this.brand,
    this.model,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'registrationNumber': registrationNumber,
        'vehicleType': vehicleType.value,
        'fuelType': fuelType.value,
        'year': year,
        if (brand != null) 'brand': brand,
        if (model != null) 'model': model,
      };
}

// ── Fuel Log Models ──────────────────────────────────────────────────────────

/// GET /api/fuel list item / POST response
class FuelLog {
  final int id;
  final int vehicleId;
  final int userId;
  final double litresFilled;
  final double pricePerLitre;
  final double totalCost;
  final double odometerReading;
  final DateTime filledAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FuelLog({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.litresFilled,
    required this.pricePerLitre,
    required this.totalCost,
    required this.odometerReading,
    required this.filledAt,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory FuelLog.fromJson(Map<String, dynamic> json) => FuelLog(
        id: json['id'],
        vehicleId: json['vehicleId'],
        userId: json['userId'] ?? 0,
        litresFilled: (json['litresFilled'] as num).toDouble(),
        pricePerLitre: (json['pricePerLitre'] as num).toDouble(),
        totalCost: (json['totalCost'] as num).toDouble(),
        odometerReading: (json['odometerReading'] as num).toDouble(),
        filledAt:
            DateTime.tryParse(json['filledAt'] ?? '') ?? DateTime.now(),
        notes: json['notes'],
        createdAt:
            DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );
}

/// POST/PUT /api/fuel → request body
class AddFuelRequest {
  final int vehicleId;
  final double litresFilled;
  final double pricePerLitre;
  final double odometerReading;
  final DateTime filledAt;
  final String? notes;

  const AddFuelRequest({
    required this.vehicleId,
    required this.litresFilled,
    required this.pricePerLitre,
    required this.odometerReading,
    required this.filledAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'litresFilled': litresFilled,
        'pricePerLitre': pricePerLitre,
        'odometerReading': odometerReading,
        'filledAt': filledAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}

// ── Expense Models ───────────────────────────────────────────────────────────

/// GET /api/expenses list item / POST response
class Expense {
  final int id;
  final int vehicleId;
  final int userId;
  final ExpenseType expenseType;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.expenseType,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        vehicleId: json['vehicleId'],
        userId: json['userId'] ?? 0,
        expenseType: ExpenseType.fromValue(json['expenseType'] ?? 9),
        amount: (json['amount'] as num).toDouble(),
        description: json['description'],
        expenseDate:
            DateTime.tryParse(json['expenseDate'] ?? '') ?? DateTime.now(),
        createdAt:
            DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
      );
}

/// POST/PUT /api/expenses → request body
class AddExpenseRequest {
  final int vehicleId;
  final ExpenseType expenseType;
  final double amount;
  final String? description;
  final DateTime expenseDate;

  const AddExpenseRequest({
    required this.vehicleId,
    required this.expenseType,
    required this.amount,
    this.description,
    required this.expenseDate,
  });

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'expenseType': expenseType.value,
        'amount': amount,
        'expenseDate': expenseDate.toIso8601String(),
        if (description != null) 'description': description,
      };
}

// ── Dashboard Models ─────────────────────────────────────────────────────────

/// GET /api/dashboard → vehicle-level summary
class VehicleExpenseSummary {
  final int vehicleId;
  final String vehicleName;
  final double fuelCost;
  final double otherExpenses;
  final double total;

  const VehicleExpenseSummary({
    required this.vehicleId,
    required this.vehicleName,
    required this.fuelCost,
    required this.otherExpenses,
    required this.total,
  });

  factory VehicleExpenseSummary.fromJson(Map<String, dynamic> json) =>
      VehicleExpenseSummary(
        vehicleId: json['vehicleId'],
        vehicleName: json['vehicleName'] ?? '',
        fuelCost: (json['fuelCost'] as num).toDouble(),
        otherExpenses: (json['otherExpenses'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );
}

/// GET /api/dashboard → full response
class DashboardResponse {
  final int totalVehicles;
  final double totalFuelCost;
  final double totalExpenseCost;
  final double totalSpent;
  final List<VehicleExpenseSummary> vehicleSummaries;

  const DashboardResponse({
    required this.totalVehicles,
    required this.totalFuelCost,
    required this.totalExpenseCost,
    required this.totalSpent,
    required this.vehicleSummaries,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) =>
      DashboardResponse(
        totalVehicles: json['totalVehicles'] ?? 0,
        totalFuelCost: (json['totalFuelCost'] as num? ?? 0).toDouble(),
        totalExpenseCost: (json['totalExpenseCost'] as num? ?? 0).toDouble(),
        totalSpent: json['totalSpent'] != null
            ? (json['totalSpent'] as num).toDouble()
            : ((json['totalFuelCost'] as num? ?? 0) +
                    (json['totalExpenseCost'] as num? ?? 0))
                .toDouble(),
        vehicleSummaries:
            (json['vehicleSummaries'] as List<dynamic>? ?? [])
                .map((e) => VehicleExpenseSummary.fromJson(e))
                .toList(),
      );
}

// ── API Error Model ──────────────────────────────────────────────────────────

class ApiErrorResponse {
  final String message;
  final List<String>? errors;

  const ApiErrorResponse({required this.message, this.errors});

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      ApiErrorResponse(
        message: json['message'] ?? 'Unknown error',
        errors: json['errors'] != null
            ? List<String>.from(json['errors'])
            : null,
      );
}
