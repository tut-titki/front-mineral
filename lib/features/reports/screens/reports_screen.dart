import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import '../../../core/api/api_services.dart';
import '../../../core/api/backend_document.dart';
import '../../orders/models/work_order_api_models.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/models/models.dart' show dateLabel;
import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/ui.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.api});
  final ApiServices api;
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? selectedPeriod;
  String preset = 'today';
  bool exporting = false;
  DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTimeRange? get period => switch (preset) {
    'all' => null,
    'week' => DateTimeRange(
      start: today.subtract(const Duration(days: 6)),
      end: today,
    ),
    'month' => DateTimeRange(
      start: today.subtract(const Duration(days: 29)),
      end: today,
    ),
    'custom' => selectedPeriod,
    _ => DateTimeRange(start: today, end: today),
  };
  Future<void> selectPeriod() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today,
      currentDate: today,
      initialDateRange: period,
      helpText: strings(context).selectPeriod,
    );
    if (range != null && mounted) {
      setState(() {
        selectedPeriod = range;
        preset = 'custom';
      });
    }
  }

  Future<void> _export(String format) async {
    if (exporting) return;
    setState(() => exporting = true);
    try {
      final pdf = format == 'pdf';
      final bytes = await widget.api.reports.export(pdf: pdf);
      if (!mounted) return;
      final saved = await FileSaver.instance.saveAs(
        name: 'mineral-report',
        bytes: bytes,
        fileExtension: pdf ? 'pdf' : 'xlsx',
        mimeType: pdf ? MimeType.pdf : MimeType.microsoftExcel,
      );
      if (mounted && saved != null) {
        showMessage(
          context,
          backendText(context, 'Отчёт сохранён', 'Есеп сақталды'),
        );
      }
    } catch (error) {
      if (mounted) showMessage(context, backendError(context, error));
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  Widget _report(String title, Future<BackendDocument> Function() load) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title),
              BackendSection<BackendDocument>(
                load: load,
                changes: widget.api.realtime.changes,
                builder: (context, data) => BackendDocumentView(document: data),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    final range = period;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          s.reportsRating,
          subtitle: s.reportPeriodHint,
          action: exporting
              ? const CircularProgressIndicator()
              : PopupMenuButton<String>(
                  tooltip: s.exportReport,
                  onSelected: _export,
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'pdf', child: Text(s.exportPdf)),
                    PopupMenuItem(value: 'excel', child: Text(s.exportExcel)),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.ios_share, color: brand),
                    label: Text(s.exportReport),
                  ),
                ),
        ),
        Text(s.reportPeriodHint, style: const TextStyle(color: muted)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in [
              ('today', s.todayPeriod),
              ('week', s.weekPeriod),
              ('month', s.monthPeriod),
              ('all', s.allTimePeriod),
            ])
              ChoiceChip(
                label: Text(choice.$2),
                selected: preset == choice.$1,
                onSelected: (_) => setState(() => preset = choice.$1),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: selectPeriod,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              range == null
                  ? s.selectPeriod
                  : '${dateLabel(range.start)} — ${dateLabel(range.end)}',
            ),
          ),
        ),
        BackendSection<List<WorkOrderApiModel>>(
          load: () => widget.api.workOrders.getAllWorkOrders(compact: false),
          changes: widget.api.realtime.changes,
          builder: (context, allOrders) {
            final selected = allOrders.where((o) {
              final created = o.createdAt.toLocal();
              return range == null ||
                  (!created.isBefore(range.start) &&
                      created.isBefore(
                        DateTime(
                          range.end.year,
                          range.end.month,
                          range.end.day + 1,
                        ),
                      ));
            }).toList();
            final closed = selected
                .where((o) => o.status == WorkOrderStatus.closed)
                .toList();
            final scores = closed
                .map((o) => o.aiAssessment?.masterScore)
                .whereType<num>()
                .toList();
            final average = scores.isEmpty
                ? null
                : scores.reduce((a, b) => a + b) / scores.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdaptiveGrid(
                  minWidth: 190,
                  children: [
                    MetricCard(
                      title: 'Выдано нарядов',
                      value: '${selected.length}',
                      icon: Icons.assignment_outlined,
                    ),
                    MetricCard(
                      title: 'Выполнено',
                      value:
                          '${selected.where((o) => [WorkOrderStatus.completed, WorkOrderStatus.aiReview, WorkOrderStatus.closed].contains(o.status)).length}',
                      icon: Icons.task_alt,
                      color: Colors.green,
                    ),
                    MetricCard(
                      title: 'Просрочено',
                      value: '${selected.where((o) => o.isOverdue).length}',
                      icon: Icons.schedule,
                      color: Colors.red,
                    ),
                    MetricCard(
                      title: backendText(
                        context,
                        'Средняя оценка мастера',
                        'Шебердің орташа бағасы',
                      ),
                      value: average?.toStringAsFixed(1) ?? '—',
                      icon: Icons.star_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeading(
                        backendText(
                          context,
                          'Рейтинг за выбранный период',
                          'Таңдалған кезеңдегі рейтинг',
                        ),
                      ),
                      if (scores.isEmpty) Text(s.noPeriodEmployees),
                      ..._ranking(context, closed),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          backendText(
            context,
            'Сводки сервера и экспорт — за период, заданный сервером.',
            'Сервер жиынтықтары мен экспорт — сервер белгілеген кезең үшін.',
          ),
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        _report(
          backendText(context, 'Отчёт по смене', 'Ауысым есебі'),
          widget.api.reports.getShift,
        ),
        _report('Рейтинг исполнителей', widget.api.reports.getRatings),
        _report(
          backendText(context, 'Рейтинг бригад', 'Бригадалар рейтингі'),
          widget.api.reports.getBrigadeRatings,
        ),
        _report(
          backendText(context, 'Расход материалов', 'Материалдар шығыны'),
          widget.api.reports.getMaterials,
        ),
        _report(
          backendText(
            context,
            'Простой оборудования',
            'Жабдықтың тоқтап тұруы',
          ),
          widget.api.reports.getDowntime,
        ),
      ],
    );
  }

  List<Widget> _ranking(BuildContext context, List<WorkOrderApiModel> orders) {
    final byExecutor = <int, List<WorkOrderApiModel>>{};
    for (final order in orders.where(
      (o) => o.aiAssessment?.masterScore != null,
    )) {
      byExecutor.putIfAbsent(order.assigneeId, () => []).add(order);
    }
    double score(List<WorkOrderApiModel> orders) =>
        orders.fold<double>(0, (sum, o) => sum + o.aiAssessment!.masterScore!) /
        orders.length;
    final groups = byExecutor.values.toList()
      ..sort((a, b) => score(b).compareTo(score(a)));
    return [
      for (final group in groups)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline, color: brand),
          title: Text(group.first.assignee.fullName),
          subtitle: LinearProgressIndicator(
            value: (score(group) / 5).clamp(0, 1),
            backgroundColor: background,
          ),
          trailing: Text(
            score(group).toStringAsFixed(1),
            style: const TextStyle(color: brand, fontWeight: FontWeight.w800),
          ),
        ),
    ];
  }
}
