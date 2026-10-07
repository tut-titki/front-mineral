import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mineral/core/utils/enterprise_time.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/models/models.dart';
import '../widgets/executor_history_tile.dart';

class ExecutorHistoryScreen extends StatefulWidget {
  const ExecutorHistoryScreen({
    super.key,
    required this.orders,
    required this.now,
    required this.onRefresh,
    required this.onOpen,
    required this.loadTime,
    this.error,
  });
  final List<WorkOrder> orders;
  final DateTime now;
  final Future<void> Function() onRefresh;
  final ValueChanged<WorkOrder> onOpen;
  final Future<WorkOrder> Function(WorkOrder) loadTime;
  final String? error;
  @override
  State<ExecutorHistoryScreen> createState() => _ExecutorHistoryScreenState();
}

DateTime historyOrderTime(WorkOrder order) =>
    order.finishedAt ??
    order.history
        .where((event) => event.status == order.status)
        .map((event) => event.time)
        .fold(
          order.createdAt,
          (latest, time) => time.isAfter(latest) ? time : latest,
        );

class _ExecutorHistoryScreenState extends State<ExecutorHistoryScreen> {
  String _query = '';
  OrderStatus? _status;
  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    final archived =
        widget.orders
            .where(
              (o) => {
                OrderStatus.closed,
                OrderStatus.cancelled,
                OrderStatus.rejected,
              }.contains(o.status),
            )
            .toList()
          ..sort((a, b) => historyOrderTime(b).compareTo(historyOrderTime(a)));
    final month = archived
        .where(
          (o) =>
              !historyOrderTime(
                o,
              ).isBefore(widget.now.subtract(const Duration(days: 30))) &&
              !historyOrderTime(o).isAfter(widget.now),
        )
        .toList();
    final scores = month
        .where((o) => o.status == OrderStatus.closed)
        .map((o) => o.masterScore ?? o.assessment?.score)
        .whereType<double>()
        .toList();
    final average = scores.isEmpty
        ? '—'
        : (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1);
    final visible = archived
        .where(
          (o) =>
              (_status == null || o.status == _status) &&
              '${o.displayNumber} ${uiText(context, o.title)} ${uiText(context, o.equipment)}'
                  .toLowerCase()
                  .contains(_query.trim().toLowerCase()),
        )
        .toList();
    final today = enterpriseTime(widget.now);
    bool isToday(WorkOrder order) {
      final date = enterpriseTime(historyOrderTime(order));
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF01408B), Color(0xFF0A57A3)],
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                          (
                            LucideIcons.calendarDays600,
                            s.historyMonthSummary,
                            '${month.length}',
                          ),
                          (
                            LucideIcons.badgeCheck600,
                            uiText(context, 'Завершено'),
                            '${month.where((o) => o.status == OrderStatus.closed).length}',
                          ),
                          (
                            LucideIcons.award600,
                            s.historyAverageScore,
                            average,
                          ),
                        ]
                        .map(
                          (item) => Container(
                            width: (constraints.maxWidth - 16) / 3,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0x20FFFFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 32,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: item.$1 == LucideIcons.award600
                                              ? const Color(0x26FFD65B)
                                              : const Color(0x1FFFFFFF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          item.$1,
                                          size: 20,
                                          color: item.$1 == LucideIcons.award600
                                              ? const Color(0xFFFFD65B)
                                              : item.$1 ==
                                                    LucideIcons.badgeCheck600
                                              ? const Color(0xFF8AF0CB)
                                              : const Color(0xFFDDEFFF),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item.$2,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            height: 1.15,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFDDEBFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.$3,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF01408B), Color(0xFF0A57A3)],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEAF1FC),
                      hintText: uiText(
                        context,
                        'Поиск по номеру или оборудованию',
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF74839B),
                      ),
                      prefixIcon: const Icon(
                        LucideIcons.search,
                        size: 18,
                        color: Color(0xFF74839B),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    spacing: 6,
                    children:
                        [
                              (null, s.all),
                              (
                                OrderStatus.closed,
                                uiText(context, 'Завершено'),
                              ),
                              (OrderStatus.cancelled, s.cancelledPlural),
                              (OrderStatus.rejected, s.rejectedPlural),
                            ]
                            .map(
                              (item) => Expanded(
                                child: TextButton(
                                  onPressed: () =>
                                      setState(() => _status = item.$1),
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    backgroundColor: _status == item.$1
                                        ? const Color(0xFF01408B)
                                        : const Color(0xFFEAF1FC),
                                    foregroundColor: _status == item.$1
                                        ? Colors.white
                                        : const Color(0xFF637B9E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      item.$2,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  if (widget.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        widget.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        uiText(
                          context,
                          archived.isEmpty
                              ? 'История пока пуста'
                              : 'По вашему запросу ничего не найдено',
                        ),
                      ),
                    ),
                  for (final group in [true, false])
                    if (visible.any((o) => isToday(o) == group)) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 14,
                          bottom: 10,
                          left: 2,
                        ),
                        child: Text(
                          group ? s.todayPeriod : s.historyEarlier,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF74839B),
                          ),
                        ),
                      ),
                      for (final order in visible.where(
                        (o) => isToday(o) == group,
                      )) ...[
                        ExecutorHistoryTile(
                          loadTime: () => widget.loadTime(order),
                          order: order,
                          now: widget.now,
                          onTap: () => widget.onOpen(order),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
