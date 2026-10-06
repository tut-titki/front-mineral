import '../../../core/api/api_client.dart';

// MARK: - Area

class AreaReference {
  const AreaReference({required this.id, required this.name});

  final int id;
  final String name;

  factory AreaReference.fromJson(Map<String, dynamic> json) {
    return AreaReference(id: _asInt(json['id']), name: _asString(json['name']));
  }
}

// MARK: - Equipment

class EquipmentReference {
  const EquipmentReference({
    required this.id,
    required this.name,
    required this.areaId,
    this.inventoryNumber,
    this.type,
    this.criticality,
    this.qrToken,
  });

  final int id;
  final String name;

  final String? inventoryNumber;
  final String? type;
  final int? criticality;
  final String? qrToken;

  final int areaId;

  factory EquipmentReference.fromJson(Map<String, dynamic> json) {
    return EquipmentReference(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      inventoryNumber: _asNullableString(json['inventoryNumber']),
      type: _asNullableString(json['type']),
      criticality: _asNullableInt(json['criticality']),
      qrToken: _asNullableString(json['qrToken']),
      areaId: _asInt(json['areaId']),
    );
  }

  String get displayName {
    final inventory = inventoryNumber;

    if (inventory == null || inventory.trim().isEmpty) {
      return name;
    }

    return '$name · $inventory';
  }
}

// MARK: - Employee status

enum EmployeeStatus {
  available,
  busy,
  queued,
  offShift,
  unknown;

  factory EmployeeStatus.fromApi(String? value) {
    return switch (value?.toUpperCase()) {
      'AVAILABLE' => EmployeeStatus.available,
      'BUSY' => EmployeeStatus.busy,
      'QUEUED' => EmployeeStatus.queued,
      'OFF_SHIFT' => EmployeeStatus.offShift,
      _ => EmployeeStatus.unknown,
    };
  }

  String? get apiValue => switch (this) {
    EmployeeStatus.available => 'AVAILABLE',
    EmployeeStatus.busy => 'BUSY',
    EmployeeStatus.queued => 'QUEUED',
    EmployeeStatus.offShift => 'OFF_SHIFT',
    EmployeeStatus.unknown => null,
  };

  String get label => switch (this) {
    EmployeeStatus.available => 'Свободен',
    EmployeeStatus.busy => 'В работе',
    EmployeeStatus.queued => 'В очереди',
    EmployeeStatus.offShift => 'Не на смене',
    EmployeeStatus.unknown => 'Статус неизвестен',
  };
}

// MARK: - Executor count

class ExecutorOrderCount {
  const ExecutorOrderCount({required this.assignedOrders});

  final int assignedOrders;

  factory ExecutorOrderCount.fromJson(Map<String, dynamic> json) {
    return ExecutorOrderCount(
      assignedOrders: _asIntOrZero(json['assignedOrders']),
    );
  }
}

// MARK: - Executor

class ExecutorReference {
  const ExecutorReference({
    required this.id,
    required this.fullName,
    required this.employeeStatus,
    required this.isOnShift,
    required this.assignedOrders,
    this.specialty,
    this.grade,
  });

  final int id;
  final String fullName;

  final String? specialty;
  final int? grade;

  final EmployeeStatus employeeStatus;
  final bool isOnShift;

  /// Количество активных назначенных нарядов.
  final int assignedOrders;

  factory ExecutorReference.fromJson(Map<String, dynamic> json) {
    final count = _mapOrNull(json['_count'], ExecutorOrderCount.fromJson);

    return ExecutorReference(
      id: _asInt(json['id']),
      fullName: _asString(json['fullName']),
      specialty: _asNullableString(json['specialty']),
      grade: _asNullableInt(json['grade']),
      employeeStatus: EmployeeStatus.fromApi(
        _asNullableString(json['employeeStatus']),
      ),
      isOnShift: _asBool(json['isOnShift']),
      assignedOrders: count?.assignedOrders ?? 0,
    );
  }

  bool get canBeAssigned {
    return isOnShift && employeeStatus != EmployeeStatus.offShift;
  }

  String get qualification {
    final parts = <String>[];

    if (specialty != null && specialty!.trim().isNotEmpty) {
      parts.add(specialty!.trim());
    }

    if (grade != null) {
      parts.add('$grade разряд');
    }

    return parts.join(' · ');
  }

  String get statusLabel {
    if (!isOnShift || employeeStatus == EmployeeStatus.offShift) {
      return 'Не на смене';
    }

    switch (employeeStatus) {
      case EmployeeStatus.available:
        return 'Свободен';

      case EmployeeStatus.busy:
        return assignedOrders > 0
            ? 'В работе · $assignedOrders нар.'
            : 'В работе';

      case EmployeeStatus.queued:
        return assignedOrders > 0
            ? 'В очереди · $assignedOrders нар.'
            : 'В очереди';

      case EmployeeStatus.offShift:
        return 'Не на смене';

      case EmployeeStatus.unknown:
        return 'Статус неизвестен';
    }
  }
}

// MARK: - Fault code

class FaultCodeReference {
  const FaultCodeReference({
    required this.id,
    required this.code,
    required this.name,
    this.category,
  });

  final int id;
  final String code;
  final String name;
  final String? category;

  factory FaultCodeReference.fromJson(Map<String, dynamic> json) {
    return FaultCodeReference(
      id: _asInt(json['id']),
      code: _asString(json['code']),
      name: _asString(json['name']),
      category: _asNullableString(json['category']),
    );
  }

  String get displayName {
    if (code.trim().isEmpty) {
      return name;
    }

    return '$code · $name';
  }
}

// MARK: - Material

class MaterialReference {
  const MaterialReference({
    required this.id,
    required this.name,
    required this.unit,
  });

  final int id;
  final String name;
  final String unit;

  factory MaterialReference.fromJson(Map<String, dynamic> json) {
    return MaterialReference(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      unit: _asString(json['unit']),
    );
  }
}

// MARK: - Material norm

class MaterialNormReference {
  const MaterialNormReference({
    required this.materialId,
    required this.quantity,
    this.material,
  });

  final int materialId;

  /// Backend возвращает quantity строкой.
  final String quantity;

  final MaterialReference? material;

  factory MaterialNormReference.fromJson(Map<String, dynamic> json) {
    return MaterialNormReference(
      materialId: _asInt(json['materialId']),
      quantity: _asString(json['quantity']),
      material: _mapOrNull(json['material'], MaterialReference.fromJson),
    );
  }

  double? get quantityValue {
    return double.tryParse(quantity);
  }
}

// MARK: - Normative

class NormativeReference {
  const NormativeReference({
    required this.id,
    required this.name,
    required this.hours,
    this.equipmentType,
    this.equipmentId,
    this.faultCodeId,
    this.faultCode,
    this.materialNorms = const [],
  });

  final int id;
  final String name;

  final String? equipmentType;
  final int? equipmentId;
  final int? faultCodeId;

  /// Backend возвращает часы строкой:
  /// например "2", "2.5".
  final String hours;

  final FaultCodeReference? faultCode;

  final List<MaterialNormReference> materialNorms;

  factory NormativeReference.fromJson(Map<String, dynamic> json) {
    return NormativeReference(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      equipmentType: _asNullableString(json['equipmentType']),
      equipmentId: _asNullableInt(json['equipmentId']),
      faultCodeId: _asNullableInt(json['faultCodeId']),
      hours: _asString(json['hours']),
      faultCode: _mapOrNull(json['faultCode'], FaultCodeReference.fromJson),
      materialNorms: _mapList(
        json['materialNorms'],
        MaterialNormReference.fromJson,
      ),
    );
  }

  double? get hoursValue {
    return double.tryParse(hours);
  }

  String get hoursLabel {
    final value = hoursValue;

    if (value == null) {
      return '$hours ч.';
    }

    if (value == value.roundToDouble()) {
      return '${value.toInt()} ч.';
    }

    return '$value ч.';
  }
}

// MARK: - Brigade member

class BrigadeMemberReference {
  const BrigadeMemberReference({
    required this.id,
    required this.fullName,
    this.specialty,
  });

  final int id;
  final String fullName;
  final String? specialty;

  factory BrigadeMemberReference.fromJson(Map<String, dynamic> json) {
    return BrigadeMemberReference(
      id: _asInt(json['id']),
      fullName: _asString(json['fullName']),
      specialty: _asNullableString(json['specialty']),
    );
  }
}

// MARK: - Brigade

class BrigadeReference {
  const BrigadeReference({
    required this.id,
    required this.name,
    this.members = const [],
  });

  final int id;
  final String name;

  final List<BrigadeMemberReference> members;

  factory BrigadeReference.fromJson(Map<String, dynamic> json) {
    return BrigadeReference(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      members: _mapList(json['members'], BrigadeMemberReference.fromJson),
    );
  }
}

// MARK: - References API

class ReferencesApi {
  const ReferencesApi(this._client);

  final ApiClient _client;

  // MARK: Areas

  Future<List<AreaReference>> getAreas() async {
    final response = await _client.get('/api/references/areas');

    return _parseList(response.data, AreaReference.fromJson);
  }

  // MARK: Equipment

  Future<List<EquipmentReference>> getEquipment({int? areaId}) async {
    final response = await _client.get(
      '/api/references/equipment',
      queryParameters: {'areaId': ?areaId},
    );

    return _parseList(response.data, EquipmentReference.fromJson);
  }

  // MARK: Executors

  Future<List<ExecutorReference>> getExecutors() async {
    final response = await _client.get('/api/references/executors');

    return _parseList(response.data, ExecutorReference.fromJson);
  }

  // MARK: Normatives

  Future<List<NormativeReference>> getNormatives({int? equipmentId}) async {
    final response = await _client.get(
      '/api/references/normatives',
      queryParameters: {'equipmentId': ?equipmentId},
    );

    return _parseList(response.data, NormativeReference.fromJson);
  }

  // MARK: Fault codes

  Future<List<FaultCodeReference>> getFaultCodes() async {
    final response = await _client.get('/api/references/fault-codes');

    return _parseList(response.data, FaultCodeReference.fromJson);
  }

  // MARK: Materials

  Future<List<MaterialReference>> getMaterials() async {
    final response = await _client.get('/api/references/materials');

    return _parseList(response.data, MaterialReference.fromJson);
  }

  // MARK: Brigades

  Future<List<BrigadeReference>> getBrigades() async {
    final response = await _client.get('/api/references/brigades');

    return _parseList(response.data, BrigadeReference.fromJson);
  }
}

// MARK: - JSON helpers

List<T> _parseList<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value is! List) {
    throw const ApiException(
      statusCode: 500,
      message: 'Сервер вернул неверный формат справочника',
    );
  }

  return value.map((item) => parser(_asJsonMap(item))).toList(growable: false);
}

Map<String, dynamic> _asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw const ApiException(
    statusCode: 500,
    message: 'Сервер вернул неверный формат данных',
  );
}

T? _mapOrNull<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value == null) {
    return null;
  }

  return parser(_asJsonMap(value));
}

List<T> _mapList<T>(dynamic value, T Function(Map<String, dynamic>) parser) {
  if (value == null) {
    return const [];
  }

  if (value is! List) {
    return const [];
  }

  return value.map((item) => parser(_asJsonMap(item))).toList(growable: false);
}

String _asString(dynamic value) {
  if (value == null) {
    throw const FormatException('Expected String value');
  }

  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  final parsed = int.tryParse(value?.toString() ?? '');

  if (parsed != null) {
    return parsed;
  }

  throw FormatException('Expected int value, got $value');
}

int _asIntOrZero(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString()) ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();

    return normalized == 'true' || normalized == '1';
  }

  return false;
}
