import 'package:flutter/material.dart';
import 'package:mineral/l10n/ui_localization.dart';

import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/core/theme/app_theme.dart';

const brand = AppColors.primary;
const ink = AppColors.ink;
const muted = AppColors.muted;
const background = AppColors.background;
const border = AppColors.border;
const lightBlue = AppColors.lightBlue;

class EmployeeChoice extends StatelessWidget {
  const EmployeeChoice({
    super.key,
    required this.employee,
    required this.store,
  });
  final Employee employee;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final color = store.employeeColor(employee);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.name,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                uiText(context, employee.specialty),
                style: TextStyle(fontSize: 11, color: muted),
              ),
              Text(
                uiText(context, store.employeeStatus(employee)),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BrigadeChoice extends StatelessWidget {
  const BrigadeChoice({super.key, required this.brigade, required this.store});
  final String brigade;
  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final members = store.brigadeMembers(brigade);
    final onShift = members.where((e) => e.onShift).length;
    final available = members
        .where((e) => store.employeeStatus(e) == 'Свободен')
        .length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uiText(context, brigade),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          uiText(
            context,
            onShift == 0
                ? 'Не на смене'
                : 'На смене: $onShift · свободны: $available · заняты: ${onShift - available}',
          ),
          style: TextStyle(
            fontSize: 12,
            color: onShift == 0
                ? muted
                : available > 0
                ? Color(0xFF059669)
                : Color(0xFFD97706),
          ),
        ),
      ],
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = 20,
  });

  final Widget child;
  final Color color;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class PageHeading extends StatelessWidget {
  const PageHeading(
    this.title, {
    super.key,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            uiText(context, title),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ink,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 8),
          Text(
            uiText(context, subtitle),
            style: TextStyle(color: muted, height: 1.5),
          ),
          if (action != null) ...[SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        uiText(context, text),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  const StatusTag(this.text, {super.key, this.color = brand});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        uiText(context, text),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({super.key, required this.children, this.minWidth = 230});

  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minWidth).floor().clamp(
          1,
          children.length,
        );

        final width = (constraints.maxWidth - (columns - 1) * 14) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = brand,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  uiText(context, title),
                  style: TextStyle(color: muted),
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          SizedBox(height: 18),
          Text(
            uiText(context, value),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.store,
    required this.onTap,
  });

  final WorkOrder order;
  final DemoStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: order.emergency ? Color(0xFFFECACA) : border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      uiText(context, 'НАРЯД №${order.number}'),
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    StatusTag(order.status.label, color: order.status.color),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  uiText(context, order.title),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  uiText(context, '${order.equipment} · ${order.area}'),
                  style: TextStyle(fontSize: 13, color: muted),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusTag(
                      order.priority,
                      color: order.emergency ? Colors.red : muted,
                    ),
                    Text(
                      uiText(
                        context,
                        'До ${timeLabel(order.deadline)}'
                        ' · ${dateLabel(order.deadline)}',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: order.overdue ? Colors.red : muted,
                      ),
                    ),
                    if (order.overdue)
                      StatusTag('Просрочен', color: Colors.red),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  uiText(
                    context,
                    'Выдан ${dateLabel(order.createdAt)} · ${timeLabel(order.createdAt)}',
                  ),
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.person_outline, color: muted, size: 17),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        store.assignmentLabel(order),
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AiCard extends StatelessWidget {
  const AiCard({
    super.key,
    required this.title,
    required this.text,
    this.warning = false,
  });

  final String title;
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Panel(
      color: warning ? Color(0xFFFFF7ED) : lightBlue,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber : Icons.auto_awesome,
            color: warning ? Colors.orange : brand,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uiText(context, title),
                  style: TextStyle(fontWeight: FontWeight.w700, color: ink),
                ),
                SizedBox(height: 8),
                Text(
                  uiText(context, text),
                  style: TextStyle(color: muted, height: 1.6),
                ),
                SizedBox(height: 12),
                Text(
                  uiText(context, 'Демонстрационные данные · ИИ не подключён'),
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(uiText(context, text)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
