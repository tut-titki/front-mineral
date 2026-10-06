import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/executor_greeting.dart';
import '../widgets/executor_history_tile.dart';
import '../models/executor_order_queue.dart';
import 'executor_order_loader.dart';
import 'executor_profile_screen.dart';
import 'executor_notifications_screen.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/l10n/language_switcher.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/shared/models/models.dart';

class ExecutorScreen extends StatefulWidget {
  final ExecutorRepository store;
  final int employeeId;

  const ExecutorScreen({
    super.key,
    required this.store,
    required this.employeeId,
  });

  @override
  State<ExecutorScreen> createState() => _ExecutorScreenState();
}

class _ExecutorScreenState extends State<ExecutorScreen> {
  int _page = 0;
  String _query = '';
  String? _refreshError;

  Future<void> _refresh() async {
    try {
      await store.refreshExecutor(employeeId);
      if (mounted) setState(() => _refreshError = null);
    } catch (error) {
      if (mounted) {
        setState(
          () =>
              _refreshError = error is ApiException && error.message.isNotEmpty
              ? error.message
              : strings(context).refreshFailed,
        );
      }
    }
  }

  Timer? _greetingTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refresh());
    });
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  ExecutorRepository get store => widget.store;
  int get employeeId => widget.employeeId;

  void _openOrder(WorkOrder order) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ExecutorOrderLoader(
        store: store,
        order: order,
        employeeId: employeeId,
        showResult: _page == 1 ? true : null,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final employee = store.employee(employeeId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          [
            uiText(context, 'Мои наряды'),
            uiText(context, 'История нарядов'),
            uiText(context, 'Профиль'),
          ][_page],
        ),
        actions: [
          const LanguageSwitcher(),
          IconButton(
            tooltip: uiText(context, 'Уведомления'),
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExecutorNotificationsScreen(
                  store: store,
                  employeeId: employeeId,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDFEBFA),
        selectedIndex: _page,
        onDestinationSelected: (p) => setState(() => _page = p),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            label: uiText(context, 'Наряды'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: uiText(context, 'История'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: uiText(context, 'Профиль'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          if (_page == 2) {
            return ExecutorProfileScreen(store: store, employeeId: employeeId);
          }
          if (store.isLoading && store.assignedTo(employeeId).isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (store.loadError != null && store.assignedTo(employeeId).isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_refreshError ?? store.loadError!),
                  TextButton(
                    onPressed: _refresh,
                    child: Text(uiText(context, 'Повторить')),
                  ),
                ],
              ),
            );
          }
          final orders = store.assignedTo(employeeId).where((order) {
            final archived = {
              OrderStatus.closed,
              OrderStatus.cancelled,
              OrderStatus.rejected,
            }.contains(order.status);
            return _page == 1 ? archived : !archived;
          }).toList();
          orders.sort((a, b) {
            if (_page == 1) {
              return (b.finishedAt ?? b.createdAt).compareTo(
                a.finishedAt ?? a.createdAt,
              );
            }
            return ExecutorOrderQueue.compare(a, b);
          });

          final queue = ExecutorOrderQueue(orders);
          final visible = orders
              .where(
                (o) =>
                    ('${o.displayNumber} ${o.title} ${o.equipment} ${uiText(context, o.title)} ${uiText(context, o.equipment)}'
                        .toLowerCase()
                        .contains(_query.trim().toLowerCase())),
              )
              .toList();
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (_page == 0)
                  ExecutorGreeting(
                    employee: employee,
                    time: store.now,
                    orders: store.assignedTo(employeeId),
                  )
                else
                  Text(
                    uiText(
                      context,
                      'Завершённые, отменённые и отклонённые наряды',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF687385),
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 16),
                if (store.loadError != null || _refreshError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      store.loadError ?? _refreshError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E8ED)),
                    ),
                    hintText: uiText(
                      context,
                      'Поиск по номеру или оборудованию',
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                if (visible.isEmpty)
                  Text(
                    orders.isNotEmpty
                        ? uiText(context, 'По вашему запросу ничего не найдено')
                        : _page == 1
                        ? uiText(context, 'История пока пуста')
                        : uiText(context, 'Нет активных нарядов'),
                  ),
                if (_page == 1)
                  for (final order in visible) ...[
                    ExecutorHistoryTile(
                      order: order,
                      now: store.now,
                      onTap: () => _openOrder(order),
                    ),
                    const SizedBox(height: 10),
                  ]
                else ...[
                  for (final status in [
                    OrderStatus.working,
                    OrderStatus.paused,
                    OrderStatus.issued,
                    OrderStatus.accepted,
                    OrderStatus.rework,
                    OrderStatus.queued,
                    OrderStatus.review,
                  ])
                    if (visible.any((o) => o.status == status)) ...[
                      _section(uiText(context, status.label), status.color),
                      for (final order in visible.where(
                        (o) => o.status == status,
                      )) ...[
                        _OrderTile(
                          order: order,
                          queuePosition: queue.position(order),
                          now: store.now,
                          onTap: () => _openOrder(order),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  if (_query.trim().isEmpty &&
                      store
                          .assignedTo(employeeId)
                          .any((o) => o.status == OrderStatus.closed)) ...[
                    _section(
                      uiText(context, 'Завершено'),
                      const Color(0xFF059669),
                      onTap: () => setState(() => _page = 1),
                    ),
                    for (final order
                        in (store
                                .assignedTo(employeeId)
                                .where((o) => o.status == OrderStatus.closed)
                                .toList()
                              ..sort(
                                (a, b) =>
                                    (b.history.isEmpty
                                            ? b.createdAt
                                            : b.history.last.time)
                                        .compareTo(
                                          a.history.isEmpty
                                              ? a.createdAt
                                              : a.history.last.time,
                                        ),
                              ))
                            .take(2)) ...[
                      ExecutorHistoryTile(
                        order: order,
                        now: store.now,
                        onTap: () => _openOrder(order),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(String title, Color color, {VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 10),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        if (onTap != null)
          IconButton(
            tooltip: uiText(context, 'История'),
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),
      ],
    ),
  );
}

class _OrderTile extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;
  final int? queuePosition;
  final DateTime now;
  const _OrderTile({
    required this.order,
    required this.onTap,
    this.queuePosition,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final accent = order.emergency
        ? const Color(0xFFDC2626)
        : const Color(0xFF01408B);

    final overdue = order.isOverdue(now);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: order.emergency
              ? const Color(0xFFF3C4C4)
              : const Color(0xFFE6EBF2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings(context).orderNumber(order.displayNumber),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF687385),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      executorStatusText(context, order),
                      style: TextStyle(
                        fontSize: 12,
                        color: order.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF98A2B3),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uiText(context, order.title),
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          uiText(context, order.equipment),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF687385),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          uiText(context, order.area),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF98A2B3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.beforeImages.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        order.beforeImages.first.bytes,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 68,
                          height: 68,
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    uiText(context, order.priority),
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${dateLabel(order.deadline)} · ${timeLabel(order.deadline)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: overdue
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF687385),
                    ),
                  ),
                  if (queuePosition != null)
                    Text(
                      strings(context).queuePosition('$queuePosition'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF01408B),
                      ),
                    ),
                ],
              ),
              if (overdue) ...[
                const SizedBox(height: 8),
                Text(
                  strings(context).overdueByMinutes(
                    '${(now.difference(order.deadline).inSeconds + 59) ~/ 60}',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (order.status == OrderStatus.working) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF01408B),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(uiText(context, 'Открыть наряд')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
