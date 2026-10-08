import '../../../core/api/api_client.dart';
import '../../../core/api/backend_document.dart';

class AssistantReply {
  const AssistantReply({required this.answer, this.intent, this.data});
  final String answer;
  final String? intent;
  final Object? data;

  factory AssistantReply.fromJson(dynamic json) {
    if (json is! Map || json['answer'] is! String) {
      throw const ApiException(
        statusCode: 502,
        message: 'Сервер вернул неверный ответ ассистента',
      );
    }
    return AssistantReply(
      answer: json['answer'] as String,
      intent: json['intent'] is Map
          ? (json['intent'] as Map)['intent'] as String?
          : json['intent'] is String
          ? json['intent'] as String
          : null,
      data: json['data'],
    );
  }
}

class AssistantApi {
  const AssistantApi(this._client);
  final ApiClient _client;

  Future<AssistantReply> chat(String message) async {
    final text = message.trim();
    if (text.length < 2 || text.length > 1000) {
      throw const ApiException(
        statusCode: 400,
        message: 'Сообщение должно содержать от 2 до 1000 символов',
      );
    }
    return AssistantReply.fromJson(
      (await _client.post('/api/assistant/chat', body: {'message': text})).data,
    );
  }

  Future<BackendDocument> getHistory() async =>
      BackendDocument((await _client.get('/api/assistant/history')).data);
}
