import 'package:flutter/material.dart';

import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/shared/widgets/ui.dart';

class KanbanColumn extends StatelessWidget {
  const KanbanColumn({
    super.key,
    required this.title,
    required this.color,
    required this.orders,
    required this.store,
    required this.onOrder,
  });

  final String title;
  final Color color;
  final List<WorkOrder> orders;
  final DemoStore store;
  final ValueChanged<WorkOrder> onOrder;

  @override
  Widget build(BuildContext context) => Container(
    width: 310,
    constraints: const BoxConstraints(minHeight: 380),
    margin: const EdgeInsets.only(right: 18, top: 6, bottom: 10),
    decoration: BoxDecoration(
      color: Color.lerp(Colors.white, color, .07),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: .45), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: .08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Color.lerp(color, Colors.black, .18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  uiText(context, title),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(minWidth: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${orders.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color.lerp(color, Colors.black, .25),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
          child: Column(
            children: [
              for (final order in orders)
                OrderCard(
                  order: order,
                  store: store,
                  onTap: () => onOrder(order),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
