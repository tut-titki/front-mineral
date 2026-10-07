import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/backend_document.dart';
import '../../l10n/ui_localization.dart';
import 'ui.dart';

String backendText(BuildContext context, String ru, String kk) =>
    Localizations.localeOf(context).languageCode == 'kk'
    ? kk
    : uiText(context, ru);

String backendError(BuildContext context, Object error) => error is ApiException
    ? error.message
    : backendText(
        context,
        'Не удалось загрузить данные. Проверьте соединение и повторите.',
        'Деректерді жүктеу мүмкін болмады. Қосылымды тексеріп, қайталаңыз.',
      );

class BackendError extends StatelessWidget {
  const BackendError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      children: [
        const Icon(Icons.cloud_off_outlined, color: Colors.red),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(backendText(context, 'Повторить', 'Қайталау')),
        ),
      ],
    ),
  );
}

class BackendSection<T> extends StatefulWidget {
  const BackendSection({
    super.key,
    required this.load,
    required this.builder,
    this.changes,
  });
  final Future<T> Function() load;
  final Widget Function(BuildContext, T) builder;
  final Stream<void>? changes;
  @override
  State<BackendSection<T>> createState() => _BackendSectionState<T>();
}

class _BackendSectionState<T> extends State<BackendSection<T>> {
  T? data;
  Object? error;
  bool loading = true;
  int generation = 0;
  StreamSubscription<void>? subscription;
  @override
  void initState() {
    super.initState();
    subscription = widget.changes?.listen((_) => reload());
    reload();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> reload() async {
    final current = ++generation;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.load();
      if (mounted && current == generation) {
        setState(() {
          data = result;
          loading = false;
        });
      }
    } catch (exception) {
      if (mounted && current == generation) {
        setState(() {
          error = exception;
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          tooltip: uiText(context, 'Обновить'),
          onPressed: loading ? null : reload,
          icon: const Icon(Icons.refresh),
        ),
      ),
      if (loading)
        const Padding(
          padding: EdgeInsets.all(28),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (error != null)
        BackendError(message: backendError(context, error!), onRetry: reload)
      else
        widget.builder(context, data as T),
    ],
  );
}

/// Displays actual fields of responses whose nested schema is undocumented.
class BackendDocumentView extends StatelessWidget {
  const BackendDocumentView({super.key, required this.document});
  final BackendDocument document;
  @override
  Widget build(BuildContext context) => document.isEmpty
      ? Text(
          backendText(context, 'Нет данных', 'Деректер жоқ'),
          style: const TextStyle(color: muted),
        )
      : _render(context, document.value);

  Widget _render(BuildContext context, Object? value) {
    if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _render(context, item),
            ),
        ],
      );
    }
    if (value is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in value.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: entry.value is Map || entry.value is List
                  ? ExpansionTile(
                      title: Text(_label(context, entry.key.toString())),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: _render(context, entry.value),
                        ),
                      ],
                    )
                  : Text(
                      '${_label(context, entry.key.toString())}: ${_scalar(context, entry.value)}',
                      style: const TextStyle(height: 1.5),
                    ),
            ),
        ],
      );
    }
    return SelectableText(_scalar(context, value));
  }

  String _scalar(BuildContext context, Object? value) => value == null
      ? '—'
      : value is bool
      ? backendText(context, value ? 'Да' : 'Нет', value ? 'Иә' : 'Жоқ')
      : value.toString();
  String _label(BuildContext context, String key) {
    const labels = {
      'fullName': ('Имя', 'Аты'),
      'name': ('Название', 'Атауы'),
      'message': ('Сообщение', 'Хабарлама'),
      'answer': ('Ответ', 'Жауап'),
      'role': ('Роль', 'Рөлі'),
      'content': ('Текст', 'Мәтін'),
      'createdAt': ('Дата', 'Күні'),
      'equipment': ('Оборудование', 'Жабдық'),
      'executor': ('Исполнитель', 'Орындаушы'),
      'rating': ('Рейтинг', 'Рейтинг'),
      'score': ('Оценка', 'Баға'),
      'count': ('Количество', 'Саны'),
      'total': ('Всего', 'Барлығы'),
      'orders': ('Наряды', 'Нарядтар'),
      'quantity': ('Количество', 'Саны'),
      'unit': ('Единица', 'Өлшем бірлігі'),
      'description': ('Описание', 'Сипаттама'),
      'recommendation': ('Рекомендация', 'Ұсыныс'),
      'specialty': ('Специальность', 'Мамандық'),
      'status': ('Статус', 'Мәртебе'),
      'brigade': ('Бригада', 'Бригада'),
      'material': ('Материал', 'Материал'),
    };
    final label = labels[key];
    return label == null ? key : backendText(context, label.$1, label.$2);
  }
}
