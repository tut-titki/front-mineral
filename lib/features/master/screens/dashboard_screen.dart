import 'package:flutter/material.dart';
import '../../../core/api/api_services.dart';
import '../../../core/api/backend_document.dart';
import '../../analytics/data/analytics_api.dart';
import '../../orders/data/references_api.dart';
import '../../orders/models/work_order_api_models.dart';
import '../../orders/screens/orders_screen.dart';
import '../../team/screens/team_screen.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/ui.dart';

export '../../orders/screens/orders_screen.dart';
export '../../team/screens/team_screen.dart';
export '../../assistant/screens/ai_screen.dart';
export '../../notifications/screens/notifications_screen.dart';
export '../../reports/screens/reports_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.api,
    required this.onOrder,
    required this.onCreate,
    required this.onTeam,
  });
  final ApiServices api;
  final ValueChanged<WorkOrderApiModel> onOrder;
  final VoidCallback onCreate, onTeam;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PageHeading(
        'Обзор смены',
        subtitle: 'Текущие показатели и наряды смены',
        action: FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add),
          label: Text(uiText(context, 'Создать наряд')),
        ),
      ),
      BackendSection<DashboardAnalytics>(
        load: api.analytics.getDashboard,
        changes: api.realtime.changes,
        builder: (context, data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveGrid(
              minWidth: 190,
              children: [
                MetricCard(
                  title: backendText(
                    context,
                    'Активные наряды',
                    'Белсенді нарядтар',
                  ),
                  value: '${data.active ?? '—'}',
                  icon: Icons.assignment_outlined,
                ),
                MetricCard(
                  title: 'Просрочено',
                  value: '${data.overdue ?? '—'}',
                  icon: Icons.schedule,
                  color: Colors.red,
                ),
                MetricCard(
                  title: 'Оборудование в простое',
                  value: '${data.equipmentInDowntime ?? '—'}',
                  icon: Icons.factory_outlined,
                  color: Colors.orange,
                ),
                MetricCard(
                  title: backendText(
                    context,
                    'Средняя реакция, мин.',
                    'Орташа жауап уақыты, мин.',
                  ),
                  value: '${data.averageReactionMinutes ?? '—'}',
                  icon: Icons.timer_outlined,
                ),
                MetricCard(
                  title: backendText(
                    context,
                    'Среднее выполнение, мин.',
                    'Орташа орындау уақыты, мин.',
                  ),
                  value: '${data.averageCompletionMinutes ?? '—'}',
                  icon: Icons.task_alt,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AdaptiveGrid(
              minWidth: 300,
              children: [
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeading(
                        backendText(
                          context,
                          'Оборудование: частые отказы',
                          'Жабдық: жиі ақаулар',
                        ),
                      ),
                      BackendDocumentView(document: data.topEquipment),
                    ],
                  ),
                ),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeading('Рейтинг исполнителей'),
                      BackendDocumentView(document: data.topExecutors),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SectionHeading('Требуют внимания'),
      BackendSection<List<WorkOrderApiModel>>(
        load: () => api.workOrders.getAllWorkOrders(),
        changes: api.realtime.changes,
        builder: (context, orders) {
          final urgent = orders
              .where(
                (o) =>
                    o.isOverdue ||
                    o.waitingForMasterReview ||
                    (o.isEmergency && o.status == WorkOrderStatus.issued),
              )
              .toList();
          return urgent.isEmpty
              ? Panel(
                  child: Text(
                    uiText(context, 'Нет нарядов, требующих внимания'),
                  ),
                )
              : Column(
                  children: [
                    for (final order in urgent)
                      ApiOrderCard(order: order, onTap: () => onOrder(order)),
                  ],
                );
        },
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const Expanded(child: SectionHeading('Команда на смене')),
          TextButton(
            onPressed: onTeam,
            child: Text(uiText(context, 'Вся команда →')),
          ),
        ],
      ),
      BackendSection<List<ExecutorReference>>(
        load: api.references.getExecutors,
        changes: api.realtime.changes,
        builder: (context, employees) {
          final shift = employees.where((e) => e.isOnShift).toList();
          return shift.isEmpty
              ? Panel(
                  child: Text(
                    backendText(
                      context,
                      'На смене нет исполнителей',
                      'Ауысымда орындаушылар жоқ',
                    ),
                  ),
                )
              : AdaptiveGrid(
                  minWidth: 260,
                  children: [
                    for (final employee in shift)
                      BackendEmployeeCard(executor: employee),
                  ],
                );
        },
      ),
      const SizedBox(height: 24),
      AdaptiveGrid(
        minWidth: 300,
        children: [
          _analyticsPanel(
            context,
            backendText(
              context,
              'Прогноз отказов · 30 дней',
              'Ақаулар болжамы · 30 күн',
            ),
            () => api.analytics.getFailureForecast(),
          ),
          _analyticsPanel(
            context,
            'Аномалии оборудования',
            api.analytics.getAnomalies,
          ),
        ],
      ),
    ],
  );
  Widget _analyticsPanel(
    BuildContext context,
    String title,
    Future<BackendDocument> Function() load,
  ) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(title),
        BackendSection<BackendDocument>(
          load: load,
          changes: api.realtime.changes,
          builder: (context, data) => BackendDocumentView(document: data),
        ),
      ],
    ),
  );
}
