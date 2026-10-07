import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/models/models.dart';

class ExecutorHistoryTile extends StatelessWidget {
  const ExecutorHistoryTile({
    super.key,
    required this.order,
    required this.now,
    required this.onTap,
    this.compact = false,
    this.loadTime,
  });
  final WorkOrder order;
  final DateTime now;
  final VoidCallback onTap;
  final bool compact;
  final Future<WorkOrder> Function()? loadTime;

  DateTime get _finishedAt =>
      order.finishedAt ??
      order.history
          .where((event) => event.status == order.status)
          .map((event) => event.time)
          .fold(
            order.createdAt,
            (latest, time) => time.isAfter(latest) ? time : latest,
          );

  @override
  Widget build(BuildContext context) {
    final score = order.masterScore ?? order.assessment?.score;
    if (!compact) return _historyCard(context, score);
    final closed = order.status == OrderStatus.closed;
    final color = closed
        ? const Color(0xFF059669)
        : order.status == OrderStatus.rework
        ? const Color(0xFFD97706)
        : const Color(0xFFDC2626);
    final assessment = score == null
        ? uiText(context, 'Оценка ожидается')
        : '${score.toStringAsFixed(1)} · ${order.masterScore != null ? strings(context).master : strings(context).aiShort}';
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE6EDF5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: closed
                ? const Border(
                    left: BorderSide(width: 3, color: Color(0xFF059669)),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              closed
                                  ? LucideIcons.circleCheck
                                  : order.status == OrderStatus.rework
                                  ? LucideIcons.clock
                                  : LucideIcons.circleX,
                              size: 14,
                              color: color,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                executorStatusText(context, order),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: Text(
                        strings(context).orderNumber(order.displayNumber),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344866),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  uiText(context, order.title),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${uiText(context, order.equipment)} · ${uiText(context, order.area)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF7A8597),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendarDays,
                      size: 14,
                      color: Color(0xFF637B9E),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        compact
                            ? dateLabel(_finishedAt)
                            : '${dateLabel(_finishedAt)} · ${timeLabel(_finishedAt)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF637B9E),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 7),
                  child: Divider(height: 1, color: Color(0xFFE8EDF4)),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final time = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.timer,
                          size: 15,
                          color: Color(0xFF637B9E),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: _OrderWorkMinutes(
                            order: order,
                            now: now,
                            loadTime: loadTime,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.4,
                              color: Color(0xFF637B9E),
                            ),
                          ),
                        ),
                      ],
                    );
                    if (!closed) return time;
                    final rating = _metric(
                      LucideIcons.star,
                      assessment,
                      const Color(0xFF01408B),
                    );
                    if (constraints.maxWidth < 260 ||
                        MediaQuery.textScalerOf(context).scale(12) > 16) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [time, const SizedBox(height: 8), rating],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: time),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: rating,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _historyCard(BuildContext context, double? score) {
    final closed = order.status == OrderStatus.closed;
    final rework = order.status == OrderStatus.rework;
    final color = closed
        ? const Color(0xFF22C55E)
        : rework
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);
    final assessment = closed
        ? score == null
              ? uiText(context, 'Оценка ожидается')
              : '${order.masterScore != null ? strings(context).master : strings(context).aiShort} ${score.toStringAsFixed(1)}'
        : executorStatusText(context, order);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  closed
                      ? LucideIcons.check
                      : rework
                      ? LucideIcons.clock
                      : LucideIcons.x,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        executorStatusText(context, order),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      strings(context).orderNumber(order.displayNumber),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      uiText(context, order.title),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.factory,
                          size: 13,
                          color: Color(0xFF7A8597),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            uiText(context, order.equipment),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              color: Color(0xFF637B9E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      uiText(context, order.area),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF7A8597),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 108,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dateLabel(_finishedAt)}, ${timeLabel(_finishedAt)}',
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.4,
                        color: Color(0xFF7A8597),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 13,
                          color: Color(0xFF7A8597),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _OrderWorkMinutes(
                            order: order,
                            now: now,
                            loadTime: loadTime,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.3,
                              color: Color(0xFF7A8597),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: closed
                            ? const Color(0xFFEAF2FF)
                            : const Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            closed ? LucideIcons.star : LucideIcons.info,
                            size: 14,
                            color: closed
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF7A8597),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              assessment,
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                                color: closed
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF7A8597),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: 11, height: 1.4, color: color),
        ),
      ),
    ],
  );
}

class _OrderWorkMinutes extends StatefulWidget {
  const _OrderWorkMinutes({
    required this.order,
    required this.now,
    required this.loadTime,
    required this.style,
  });
  final WorkOrder order;
  final DateTime now;
  final Future<WorkOrder> Function()? loadTime;
  final TextStyle style;
  @override
  State<_OrderWorkMinutes> createState() => _OrderWorkMinutesState();
}

class _OrderWorkMinutesState extends State<_OrderWorkMinutes> {
  Future<WorkOrder>? _loading;
  @override
  void initState() {
    super.initState();
    if (!widget.order.detailsLoaded &&
        widget.order.status == OrderStatus.closed &&
        widget.loadTime != null) {
      _loading = widget.loadTime!();
    }
  }

  @override
  void didUpdateWidget(covariant _OrderWorkMinutes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order) {
      _loading =
          !widget.order.detailsLoaded &&
              widget.order.status == OrderStatus.closed
          ? widget.loadTime?.call()
          : null;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<WorkOrder>(
    future: _loading,
    builder: (context, snapshot) {
      final order = snapshot.data ?? widget.order;
      if (!order.detailsLoaded && snapshot.hasError) {
        return Text(strings(context).refreshFailed, style: widget.style);
      }
      final minutes = order.detailsLoaded
          ? '${order.workDuration(widget.now).inMinutes}'
          : _loading != null
          ? '…'
          : '—';
      return Text(
        strings(context).historyWorkMinutes(minutes),
        style: widget.style,
      );
    },
  );
}
