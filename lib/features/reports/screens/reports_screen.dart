import 'package:flutter/material.dart';

import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/reports/widgets/report_metrics.dart';
import 'package:mineral/features/reports/models/report_snapshot.dart';
import 'package:mineral/shared/widgets/ui.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.store});
  final DemoStore store;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? selectedPeriod;
  String preset = 'today';

  DateTime get today {
    final now = widget.store.now;
    return DateTime(now.year, now.month, now.day);
  }

  DateTimeRange? get period => switch (preset) {
    'all' => null,
    'week' => DateTimeRange(
      start: DateTime(today.year, today.month, today.day - 6),
      end: today,
    ),
    'month' => DateTimeRange(
      start: DateTime(today.year, today.month, today.day - 29),
      end: today,
    ),
    'custom' => selectedPeriod,
    _ => DateTimeRange(start: today, end: today),
  };

  Future<void> selectPeriod() async {
    final earliest = widget.store.orders.fold<DateTime>(
      DateTime(today.year - 5, today.month, today.day),
      (date, order) => order.createdAt.isBefore(date) ? order.createdAt : date,
    );
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(earliest.year, earliest.month, earliest.day),
      lastDate: today,
      currentDate: today,
      initialDateRange: period,
      helpText: strings(context).selectPeriod,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            datePickerTheme: theme.datePickerTheme.copyWith(
              rangePickerHeaderHeadlineStyle: TextStyle(
                fontSize: MediaQuery.sizeOf(context).width < 480 ? 16 : 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null && mounted) {
      setState(() {
        selectedPeriod = selected;
        preset = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final s = strings(context);
      final snapshot = ReportSnapshot(widget.store, period);
      final ranking = snapshot.ranking;
      final range = period;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  s.reportsRating,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ink,
                    letterSpacing: -.8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                tooltip: s.exportReport,
                onSelected: (format) => showMessage(
                  context,
                  format == 'pdf'
                      ? 'Выгрузку PDF подключим вместе с backend'
                      : 'Выгрузку Excel подключим вместе с backend',
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_outlined, color: brand),
                        const SizedBox(width: 12),
                        Text(s.exportPdf),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excel',
                    child: Row(
                      children: [
                        const Icon(Icons.table_chart_outlined, color: brand),
                        const SizedBox(width: 12),
                        Text(s.exportExcel),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.ios_share, size: 18, color: brand),
                      const SizedBox(width: 8),
                      Text(
                        s.exportReport,
                        style: const TextStyle(
                          color: brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.reportPeriodHint,
            style: const TextStyle(color: muted, height: 1.5),
          ),
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
          const SizedBox(height: 24),
          ReportMetrics(store: widget.store, orders: snapshot.orders),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeading('Рейтинг исполнителей'),
                if (ranking.isEmpty)
                  Text(
                    s.noPeriodEmployees,
                    style: const TextStyle(color: muted),
                  ),
                for (var index = 0; index < ranking.length; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: background,
                          child: Text(
                            ranking[index].initials,
                            style: const TextStyle(color: brand),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ranking[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ranking[index].specialty,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: ranking[index].rating / 5,
                                backgroundColor: background,
                                color: brand,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          ranking[index].rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: brand,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
