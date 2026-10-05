import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/executor_greeting.dart';
import 'executor_order_screen.dart';
import 'executor_result_screen.dart';
import 'executor_profile_screen.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

class ExecutorScreen extends StatefulWidget {
  final DemoStore store;
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
  Timer? _greetingTimer;
  @override
  void initState() {
    super.initState();
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  DemoStore get store => widget.store;
  int get employeeId => widget.employeeId;

  @override
  Widget build(BuildContext context) {
    final employee = store.employee(employeeId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(['Мои наряды', 'История нарядов', 'Профиль'][_page]),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDFEBFA),
        selectedIndex: _page,
        onDestinationSelected: (p) => setState(() => _page = p),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Наряды',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'История'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          if (_page == 2) {
            return ExecutorProfileScreen(store: store, employeeId: employeeId);
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
            if (_page == 1) return b.createdAt.compareTo(a.createdAt);
            if (a.emergency != b.emergency) {
              return a.emergency ? -1 : 1;
            }
            return a.deadline.compareTo(b.deadline);
          });

          return ListView(
            padding: EdgeInsets.all(24),
            children: [
              if (_page == 0)
                ExecutorGreeting(
                  employee: employee,
                  time: store.now,
                  orders: orders,
                )
              else
                Text(
                  employee.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              if (_page == 1) ...[
                SizedBox(height: 6),
                Text(
                  "${employee.specialty} · ${employee.brigade}",
                  style: TextStyle(color: Color(0xFF687385)),
                ),
              ],
              SizedBox(height: 28),
              if (orders.isEmpty)
                Text(
                  _page == 1 ? 'История пока пуста' : 'Нет активных нарядов',
                ),
              for (final order in orders) ...[
                _OrderTile(
                  order: order,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          _page == 1 ||
                              {
                                OrderStatus.review,
                                OrderStatus.rework,
                              }.contains(order.status)
                          ? ExecutorResultScreen(
                              store: store,
                              order: order,
                              employeeId: employeeId,
                            )
                          : ExecutorOrderScreen(
                              store: store,
                              order: order,
                              employeeId: employeeId,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;
  const _OrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = order.emergency ? Color(0xFFDC2626) : Color(0xFF01408B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: order.emergency ? Color(0xFFFECACA) : Color(0xFFE5E8ED),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      uiText(context, "Наряд №${order.number}"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.status.color.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        uiText(context, order.status.label),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: order.status.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                order.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 6),
              Text(
                "${order.area} · ${order.equipment}",
                style: TextStyle(color: Color(0xFF687385), height: 1.5),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    uiText(context, order.priority),
                    style: TextStyle(color: accent),
                  ),
                  Text(
                    '${dateLabel(order.deadline)} '
                    '${timeLabel(order.deadline)} ',
                    style: TextStyle(
                      color: order.overdue
                          ? Color(0xFFDC2626)
                          : Color(0xFF687385),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
