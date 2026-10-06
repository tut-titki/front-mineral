class PendingAction {
  final String id;
  final int employeeId;
  final int orderNumber;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const PendingAction({
    required this.id,
    required this.employeeId,
    required this.orderNumber,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'orderNumber': orderNumber,
    'type': type,
    'payload': payload,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      id: json['id'] as String,
      employeeId: json['employeeId'] as int,
      orderNumber: json['orderNumber'] as int,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
