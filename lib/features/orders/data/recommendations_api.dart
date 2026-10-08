import '../../../core/api/api_client.dart';
import 'references_api.dart';

// MARK: - Recommended executor

class RecommendedExecutor {
  const RecommendedExecutor({
    required this.id,
    required this.fullName,
    required this.employeeStatus,
    required this.queue,
    required this.score,
    this.specialty,
    this.equipmentRating,
  });

  final int id;
  final String fullName;
  final String? specialty;

  final EmployeeStatus employeeStatus;

  /// Количество активных нарядов.
  final int queue;

  /// Средняя оценка работ исполнителя
  /// на таком типе оборудования.
  final double? equipmentRating;

  /// Итоговый рейтинг рекомендации.
  final double score;

  factory RecommendedExecutor.fromJson(Map<String, dynamic> json) {
    return RecommendedExecutor(
      id: _asInt(json['id']),
      fullName: _asString(json['fullName']),
      specialty: _asNullableString(json['specialty']),
      employeeStatus: EmployeeStatus.fromApi(
        _asNullableString(json['employeeStatus']),
      ),
      queue: _asIntOrZero(json['queue']),
      equipmentRating: _asNullableDouble(json['equipmentRating']),
      score: _asDouble(json['score']),
    );
  }

  bool get isAvailable => employeeStatus == EmployeeStatus.available;

  String get statusLabel {
    return switch (employeeStatus) {
      EmployeeStatus.available => 'Свободен',
      EmployeeStatus.busy => 'В работе',
      EmployeeStatus.queued =>
        queue > 0 ? 'В очереди · $queue нар.' : 'В очереди',
      EmployeeStatus.offShift => 'Не на смене',
      EmployeeStatus.unknown => 'Статус неизвестен',
    };
  }

  String get ratingLabel {
    final rating = equipmentRating;

    if (rating == null) {
      return 'Нет оценки';
    }

    return rating.toStringAsFixed(1);
  }
}

// MARK: - Work recommendation

class WorkRecommendation {
  const WorkRecommendation({
    this.faultCodeId,
    this.normativeId,
    this.estimatedHours,
    this.explanation,
  });

  final int? faultCodeId;
  final int? normativeId;

  /// Примерное время выполнения,
  /// рассчитанное AI.
  final double? estimatedHours;

  /// Объяснение рекомендации.
  final String? explanation;

  factory WorkRecommendation.fromJson(Map<String, dynamic> json) {
    return WorkRecommendation(
      faultCodeId: _asNullableInt(json['faultCodeId']),
      normativeId: _asNullableInt(json['normativeId']),
      estimatedHours: _asNullableDouble(json['estimatedHours']),
      explanation: _asNullableString(json['explanation']),
    );
  }

  bool get hasFaultCode => faultCodeId != null;

  bool get hasNormative => normativeId != null;

  bool get hasEstimatedHours => estimatedHours != null;

  bool get hasSuggestion =>
      faultCodeId != null || normativeId != null || estimatedHours != null;

  String? get estimatedHoursLabel {
    final hours = estimatedHours;

    if (hours == null) {
      return null;
    }

    if (hours == hours.roundToDouble()) {
      return '${hours.toInt()} ч.';
    }

    return '${hours.toStringAsFixed(1)} ч.';
  }
}

// MARK: - Recommendations API

class RecommendationsApi {
  const RecommendationsApi(this._client);

  final ApiClient _client;

  // MARK: Executors recommendation

  Future<List<RecommendedExecutor>> getRecommendedExecutors({
    required int equipmentId,
    String? description,
    int? faultCodeId,
    int? brigadeId,
  }) async {
    if (equipmentId <= 0) {
      throw const ApiException(
        statusCode: 400,
        message: 'Не выбрано оборудование',
      );
    }

    final response = await _client.get(
      '/api/recommendations/executors',
      queryParameters: {
        'equipmentId': equipmentId,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'faultCodeId': ?faultCodeId,
        'brigadeId': ?brigadeId,
      },
    );

    final data = response.data;

    if (data is! List) {
      throw const ApiException(
        statusCode: 500,
        message:
            'Сервер вернул неверный формат '
            'рекомендаций исполнителей',
      );
    }

    return data
        .map((item) => RecommendedExecutor.fromJson(_asJsonMap(item)))
        .toList(growable: false);
  }

  // MARK: Work recommendation

  Future<WorkRecommendation> getWorkRecommendation({
    required String description,
    required int equipmentId,
  }) async {
    final normalizedDescription = description.trim();

    if (normalizedDescription.length < 3) {
      throw const ApiException(
        statusCode: 400,
        message: 'Сначала укажите описание неисправности',
      );
    }

    if (equipmentId <= 0) {
      throw const ApiException(
        statusCode: 400,
        message: 'Сначала выберите оборудование',
      );
    }

    final response = await _client.post(
      '/api/recommendations/work',
      body: {'description': normalizedDescription, 'equipmentId': equipmentId},
    );

    return WorkRecommendation.fromJson(_asJsonMap(response.data));
  }
}

// MARK: - JSON helpers

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

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  final parsed = double.tryParse(value?.toString() ?? '');

  if (parsed != null) {
    return parsed;
  }

  throw FormatException('Expected double value, got $value');
}

double? _asNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}
