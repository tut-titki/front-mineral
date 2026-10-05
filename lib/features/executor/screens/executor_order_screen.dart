import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'completion_screen.dart';
import '../widgets/order_section.dart';
import '../widgets/work_timer.dart';
import '../models/executor_order_queue.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';

class ExecutorOrderScreen extends StatefulWidget {
  const ExecutorOrderScreen({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
  });
  final ExecutorRepository store;
  final WorkOrder order;
  final int employeeId;

  @override
  State<ExecutorOrderScreen> createState() => _ExecutorOrderScreenState();
}

class _ExecutorOrderScreenState extends State<ExecutorOrderScreen> {
  ExecutorRepository get store => widget.store;
  WorkOrder get order => widget.order;
  int get employeeId => widget.employeeId;
  bool _changing = false;
  bool _reasonOpen = false;

  Future<void> _change(
    BuildContext context,
    OrderStatus status, {
    String reason = '',
  }) async {
    if (_changing) return;
    setState(() => _changing = true);
    try {
      await store.executorAction(employeeId, order, status, reason: reason);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError &&
                      error.message ==
                          'Сначала приостановите или завершите текущий наряд'
                  ? strings(context).finishCurrentFirst
                  : strings(context).changeStatusFailed,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  Future<void> _reason(BuildContext context, OrderStatus status) async {
    if (_reasonOpen || _changing) return;
    _reasonOpen = true;
    final controller = TextEditingController();
    final key = GlobalKey<FormState>();
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  status == OrderStatus.rejected
                      ? uiText(context, 'Причина отказа')
                      : uiText(context, 'Причина приостановки'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Form(
                  key: key,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: uiText(context, 'Причина'),
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? uiText(context, 'Укажите причину')
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    if (key.currentState!.validate()) {
                      Navigator.pop(context, controller.text.trim());
                    }
                  },
                  child: Text(uiText(context, 'Подтвердить')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(uiText(context, 'Отмена')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // Wait for the closing sheet animation before disposing its controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    _reasonOpen = false;
    if (reason != null &&
        context.mounted &&
        order.status ==
            (status == OrderStatus.rejected
                ? OrderStatus.issued
                : OrderStatus.working)) {
      _change(context, status, reason: reason);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final assigned = store.assignedTo(employeeId).contains(order);
      final queuePosition = ExecutorOrderQueue(
        store.assignedTo(employeeId),
      ).position(order);
      final otherWorking = store
          .assignedTo(employeeId)
          .any((o) => o != order && o.status == OrderStatus.working);
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            strings(context).orderNumber('${order.number}'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEF0F4))),
            ),
            child: AbsorbPointer(
              absorbing: _changing,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_changing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (otherWorking &&
                      {
                        OrderStatus.accepted,
                        OrderStatus.queued,
                        OrderStatus.paused,
                        OrderStatus.rework,
                      }.contains(order.status))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        strings(context).finishCurrentFirst,
                        style: const TextStyle(color: Color(0xFF687385)),
                      ),
                    ),
                  if (!assigned)
                    Text(
                      uiText(
                        context,
                        'Наряд переназначен другому исполнителю.',
                      ),
                    ),
                  if (assigned && order.status == OrderStatus.issued) ...[
                    FilledButton(
                      onPressed: () => _change(context, OrderStatus.accepted),
                      child: Text(uiText(context, 'Принять в работу')),
                    ),
                    OutlinedButton(
                      onPressed: () => _change(context, OrderStatus.queued),
                      child: Text(uiText(context, 'Поставить в очередь')),
                    ),
                    TextButton(
                      onPressed: () => _reason(context, OrderStatus.rejected),
                      child: Text(uiText(context, 'Отклонить')),
                    ),
                  ],
                  if (assigned &&
                      {
                        OrderStatus.accepted,
                        OrderStatus.queued,
                        OrderStatus.paused,
                        OrderStatus.rework,
                      }.contains(order.status))
                    FilledButton(
                      onPressed: otherWorking
                          ? null
                          : () => _change(context, OrderStatus.working),
                      child: Text(
                        order.status == OrderStatus.paused ||
                                order.status == OrderStatus.rework
                            ? uiText(context, 'Возобновить работу')
                            : uiText(context, 'Начать исполнение'),
                      ),
                    ),
                  if (assigned && order.status == OrderStatus.working) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _reason(context, OrderStatus.paused),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              textStyle: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(fontSize: 13),
                              backgroundColor: const Color(0xFFFFE6A3),
                              foregroundColor: const Color(0xFF8F5100),
                              side: BorderSide.none,
                            ),
                            icon: const Icon(Icons.pause_rounded, size: 18),
                            label: Text(uiText(context, 'Приостановить')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => CompletionScreen(
                                  store: store,
                                  order: order,
                                  employeeId: employeeId,
                                ),
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(60),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              textStyle: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(fontSize: 13),
                              backgroundColor: const Color(0xFF08A45C),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 20),
                            label: Text(uiText(context, 'Исполнено')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: Color(0xFF01408B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      uiText(context, order.status.label),
                      style: const TextStyle(
                        color: Color(0xFF01408B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: Color(0xFF01408B),
                  ),
                  const SizedBox(width: 6),
                  WorkTimer(order: order, store: store),
                ],
              ),
            ),
            if (queuePosition != null) ...[
              const SizedBox(height: 16),
              Text(
                strings(context).queuePosition('$queuePosition'),
                style: const TextStyle(
                  color: Color(0xFF01408B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              uiText(context, order.title),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6EAF0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: order.beforeImages.isNotEmpty
                        ? Image.memory(
                            order.beforeImages.first.bytes,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFFF0F4FA),
                            child: const Icon(
                              Icons.precision_manufacturing_outlined,
                              color: Color(0xFF65748B),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uiText(context, order.equipment),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          uiText(context, order.area),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF65748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OrderSection(
              icon: Icons.schedule_outlined,
              title: uiText(context, 'Срок выполнения'),
              child: Text(
                '${dateLabel(order.deadline)} · ${timeLabel(order.deadline)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: order.overdue
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF01408B),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings(context).priorityValue(uiText(context, order.priority)),
              style: TextStyle(
                color: order.emergency
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF65748B),
              ),
            ),
            const SizedBox(height: 24),
            OrderSection(
              icon: Icons.description_outlined,
              title: uiText(context, 'Описание неисправности'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  uiText(context, order.description),
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ),
            if (order.comment.isNotEmpty) ...[
              const SizedBox(height: 20),
              OrderSection(
                icon: Icons.chat_bubble_outline,
                title: uiText(context, 'Комментарий'),
                child: Text(uiText(context, order.comment)),
              ),
            ],
            const SizedBox(height: 24),
            if (order.beforeImages.isNotEmpty)
              PhotoAttachments(
                title: uiText(context, 'Фото до начала работ'),
                photos: order.beforeImages,
                framed: false,
              )
            else
              OrderSection(
                icon: Icons.camera_alt_outlined,
                title: uiText(context, 'Фото до начала работ'),
                child: Text(
                  uiText(context, 'Мастер не добавил фотографии'),
                  style: const TextStyle(color: Color(0xFF65748B)),
                ),
              ),
            if (order.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  uiText(context, 'История действий'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  for (final event in order.history.reversed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(eventText(context, event)),
                      subtitle: Text(
                        '${eventAuthor(context, event)} · ${dateLabel(event.time)} ${timeLabel(event.time)}',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}
