import 'package:flutter/material.dart';
import '../../../core/api/api_services.dart';
import '../../../core/api/backend_document.dart';
import '../../orders/models/work_order_api_models.dart';
import '../../orders/screens/orders_screen.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/ui.dart';
import '../data/assistant_api.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.api, required this.onOrder});
  final ApiServices api;
  final ValueChanged<WorkOrderApiModel> onOrder;
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool sending = false;
  Object? sendError;
  int historyVersion = 0;
  AssistantReply? reply;
  String? submittedMessage;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (sending || !formKey.currentState!.validate()) return;
    final message = controller.text.trim();
    setState(() {
      sending = true;
      sendError = null;
    });
    try {
      final response = await widget.api.assistant.chat(message);
      if (!mounted) return;
      setState(() {
        reply = response;
        submittedMessage = message;
        controller.clear();
        historyVersion++;
      });
    } catch (error) {
      if (mounted) setState(() => sendError = error);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PageHeading(
        'ИИ-контроль',
        subtitle:
            'Рекомендации цифрового контролёра. Финальное решение принимает мастер.',
      ),
      const SectionHeading('Контроль сроков'),
      BackendSection<List<WorkOrderApiModel>>(
        load: widget.api.workOrders.getAllWorkOrders,
        changes: widget.api.realtime.changes,
        builder: (context, orders) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!orders.any((o) => o.isOverdue))
              Panel(
                child: Text(
                  backendText(
                    context,
                    'Нет просроченных нарядов',
                    'Мерзімі өткен нарядтар жоқ',
                  ),
                ),
              ),
            for (final o in orders.where((o) => o.isOverdue))
              ApiOrderCard(order: o, onTap: () => widget.onOrder(o)),
            const SizedBox(height: 24),
            const SectionHeading('Проверка выполнения'),
            if (!orders.any((o) => o.waitingForMasterReview))
              Panel(child: Text(uiText(context, 'Нет нарядов на проверке'))),
            for (final o in orders.where((o) => o.waitingForMasterReview))
              ApiOrderCard(order: o, onTap: () => widget.onOrder(o)),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeading('Аномалии оборудования'),
            BackendSection<BackendDocument>(
              load: widget.api.analytics.getAnomalies,
              changes: widget.api.realtime.changes,
              builder: (context, data) => BackendDocumentView(document: data),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeading('Ассистент мастера'),
            BackendSection<BackendDocument>(
              key: ValueKey(historyVersion),
              load: widget.api.assistant.getHistory,
              builder: (context, data) => BackendDocumentView(document: data),
            ),
            if (reply != null) ...[
              const Divider(),
              Text(
                submittedMessage!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SelectableText(
                reply!.answer,
                style: const TextStyle(height: 1.6),
              ),
            ],
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                enabled: !sending,
                minLines: 1,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: uiText(context, 'Например: кто сейчас свободен?'),
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                ),
                validator: (text) =>
                    (text?.trim().length ?? 0) < 2 ||
                        (text?.trim().length ?? 0) > 1000
                    ? backendText(
                        context,
                        'Введите от 2 до 1000 символов',
                        '2–1000 таңба енгізіңіз',
                      )
                    : null,
              ),
            ),
            if (sendError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  backendError(context, sendError!),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            FilledButton.icon(
              onPressed: sending ? null : _send,
              icon: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(
                backendText(
                  context,
                  sendError == null ? 'Отправить' : 'Повторить',
                  sendError == null ? 'Жіберу' : 'Қайталау',
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
