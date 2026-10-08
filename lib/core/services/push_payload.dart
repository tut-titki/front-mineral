class PushPayload {
  PushPayload(Map<String, dynamic> data) : data = Map.unmodifiable(data);
  final Map<String, dynamic> data;
  bool get emergency =>
      data['type'] == 'NEW_ORDER' && data['priority'] == 'EMERGENCY';
  String get channelId => emergency ? 'emergency_orders' : 'orders';
  String get category => emergency ? 'EMERGENCY_ORDER' : 'ORDER';
  int? get workOrderId {
    final id = int.tryParse('${data['workOrderId']}');
    return id != null && id > 0 ? id : null;
  }

  int? get suggestedExecutorId {
    if (data['type'] != 'NOT_ACCEPTED') return null;
    final id = int.tryParse('${data['suggestedExecutorId']}');
    return id != null && id > 0 ? id : null;
  }
}
