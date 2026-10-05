import 'package:flutter/material.dart';

import '../l10n/ui_localization.dart';
import 'demo_store.dart';
import 'models.dart';
import 'ui.dart';

class ReportMetrics extends StatelessWidget {
  const ReportMetrics({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Всего нарядов', store.orders.length, Icons.assignment_outlined, brand),
      (
        'Закрыто',
        store.count(OrderStatus.closed),
        Icons.task_alt,
        const Color(0xFF059669),
      ),
      (
        'Отклонено',
        store.count(OrderStatus.rejected),
        Icons.cancel_outlined,
        const Color(0xFFDC2626),
      ),
      (
        'На доработке',
        store.count(OrderStatus.rework),
        Icons.replay,
        const Color(0xFFD97706),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 890 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 30) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              Container(
                width: width,
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.white, metric.$4, .07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: metric.$4.withValues(alpha: .2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${metric.$2}',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: metric.$4,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: metric.$4.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(metric.$3, color: metric.$4, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      uiText(context, metric.$1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ink,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
