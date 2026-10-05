import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineral/shared/models/models.dart';

class ExecutorHistoryTile extends StatelessWidget {
  const ExecutorHistoryTile({
    super.key,
    required this.order,
    required this.now,
    required this.onTap,
  });
  final WorkOrder order;
  final DateTime now;
  final VoidCallback onTap;

  DateTime get _finishedAt => order.history
      .where((event) => event.status == order.status)
      .map((event) => event.time)
      .fold(
        order.createdAt,
        (latest, time) => time.isAfter(latest) ? time : latest,
      );

  @override
  Widget build(BuildContext context) {
    final score = order.masterScore ?? order.assessment?.score;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E8ED)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      uiText(context, order.status.label),
                      style: TextStyle(
                        color: order.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    dateLabel(_finishedAt),
                    style: const TextStyle(
                      color: Color(0xFF687385),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings(context).orderNumber('${order.number}'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF01408B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          uiText(context, order.equipment),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          uiText(context, order.title),
                          style: const TextStyle(
                            color: Color(0xFF687385),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chevron_right, color: Color(0xFF687385)),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _metric(
                    Icons.timer_outlined,
                    strings(context).historyWorkMinutes(
                      '${order.workDuration(now).inMinutes}',
                    ),
                  ),
                  if (order.status == OrderStatus.closed)
                    _metric(
                      Icons.star_outline,
                      score == null
                          ? uiText(context, 'Оценка ожидается')
                          : '${score.toStringAsFixed(1)} · ${order.masterScore != null ? strings(context).master : strings(context).aiShort}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: const Color(0xFF687385)),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF687385)),
        ),
      ),
    ],
  );
}
