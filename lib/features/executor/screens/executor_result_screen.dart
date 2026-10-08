import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';
import 'executor_order_loader.dart';

class ExecutorResultScreen extends StatelessWidget {
  const ExecutorResultScreen({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
  });
  final ExecutorRepository store;
  final WorkOrder order;
  final int employeeId;

  void _open(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ExecutorOrderLoader(
        showResult: false,
        store: store,
        order: order,
        employeeId: employeeId,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final s = strings(context);
      final assessment = order.assessment;
      final reason = order.history
          .where((e) => e.status == OrderStatus.rework)
          .lastOrNull
          ?.reason;
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(s.resultOrderNumber(order.displayNumber)),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF01408B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _open(context),
              child: Text(
                order.status == OrderStatus.rework ? s.goToRework : s.openOrder,
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          children: [
            Text(
              uiText(context, order.title),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${uiText(context, order.equipment)} · ${uiText(context, order.area)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF687385),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.status == OrderStatus.closed
                          ? LucideIcons.circleCheck
                          : LucideIcons.clock,
                      size: 15,
                      color: order.status.color,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        executorStatusText(context, order),
                        style: TextStyle(
                          color: order.status.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (order.status == OrderStatus.review) ...[
              const SizedBox(height: 16),
              Text(
                s.reportAwaitingMaster,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF687385),
                  height: 1.5,
                ),
              ),
            ],
            if (order.status == OrderStatus.rework) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  s.reworkReasonValue(
                    reason == null || reason.isEmpty
                        ? s.askMasterRemarks
                        : uiText(context, reason),
                  ),
                  style: const TextStyle(color: Color(0xFF8F5100), height: 1.5),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _section(LucideIcons.star, s.executionResult, [
              _notice(
                LucideIcons.info,
                order.masterScore == null
                    ? s.masterScorePending
                    : s.eventScore('${order.masterScore}'),
                const Color(0xFFEAF3FF),
                const Color(0xFF637B9E),
              ),
              const SizedBox(height: 14),
              if (assessment == null)
                Text(
                  s.assessmentPending,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF687385),
                    height: 1.5,
                  ),
                )
              else ...[
                _notice(
                  LucideIcons.shieldCheck,
                  s.assessmentVerdict(uiText(context, assessment.verdict)),
                  const Color(0xFFF4F7FB),
                  const Color(0xFF172B4D),
                ),
                if (assessment.score != null) ...[
                  const SizedBox(height: 8),
                  _notice(
                    LucideIcons.star,
                    s.assessmentScore('${assessment.score}'),
                    const Color(0xFFF4F7FB),
                    const Color(0xFF172B4D),
                  ),
                ],
                if (assessment.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    uiText(context, assessment.explanation),
                    style: const TextStyle(height: 1.5),
                  ),
                ],
                if (assessment.strengths.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _notice(
                    LucideIcons.thumbsUp,
                    s.assessmentStrengths(
                      uiText(context, assessment.strengths),
                    ),
                    const Color(0xFFEAF8F3),
                    const Color(0xFF167C63),
                  ),
                ],
                if (assessment.improvements.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _notice(
                    LucideIcons.messageSquare,
                    s.assessmentImprovements(
                      uiText(context, assessment.improvements),
                    ),
                    const Color(0xFFFFF5E5),
                    const Color(0xFF8F5100),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final items = [
                      _fact(
                        LucideIcons.clock,
                        s.workMinutesValue(
                          order.detailsLoaded
                              ? '${order.workDuration(store.now).inMinutes}'
                              : '—',
                        ),
                      ),
                      if (order.normHours != null)
                        _fact(
                          LucideIcons.chartNoAxesColumnIncreasing,
                          s.normHoursValue('${order.normHours}'),
                        ),
                    ];
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: items
                          .map(
                            (item) => SizedBox(
                              width:
                                  constraints.maxWidth < 260 ||
                                      items.length == 1
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2,
                              child: item,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _section(LucideIcons.clipboardList, s.yourReport, [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    left: BorderSide(width: 3, color: Color(0xFF01408B)),
                  ),
                ),
                child: Text(
                  order.completedWork.isEmpty
                      ? s.workNotSpecified
                      : uiText(context, order.completedWork),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.tag,
                    size: 17,
                    color: Color(0xFF637B9E),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.faultCodeValue(
                        order.faultCode.isEmpty
                            ? s.notSpecified
                            : uiText(context, order.faultCode),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF637B9E),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28, color: Color(0xFFE8EDF4)),
              Row(
                children: [
                  const Icon(
                    LucideIcons.package,
                    size: 18,
                    color: Color(0xFF01408B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.usedExecutorMaterials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.materials.isEmpty)
                Text(
                  s.noMaterialsUsed,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A8597),
                  ),
                )
              else
                for (final material in uiText(
                  context,
                  order.materials,
                ).split('\n').where((line) => line.trim().isNotEmpty))
                  _materialRow(material.trim()),
              if (order.comment.isNotEmpty) ...[
                const Divider(height: 24, color: Color(0xFFE8EDF4)),
                Text(
                  s.comment,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF637B9E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  uiText(context, order.comment),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF172B4D),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 16),
            if (order.afterImages.isNotEmpty)
              PhotoAttachments(
                title: s.photosAfter,
                photos: order.afterImages,
                framed: false,
              ),
          ],
        ),
      );
    },
  );

  Widget _materialRow(String material) {
    final separator = material.lastIndexOf(':');
    final hasQuantity =
        separator > 0 &&
        RegExp(
          r'^\d+(?:[.,]\d+)?$',
        ).hasMatch(material.substring(separator + 1).trim());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              hasQuantity ? material.substring(0, separator).trim() : material,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF637B9E),
              ),
            ),
          ),
          if (hasQuantity) ...[
            const SizedBox(width: 12),
            Text(
              material.substring(separator + 1).trim(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notice(
    IconData icon,
    String text,
    Color background,
    Color foreground,
  ) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: foreground),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, height: 1.45, color: foreground),
          ),
        ),
      ],
    ),
  );

  Widget _fact(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 23, color: const Color(0xFF01408B)),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: Color(0xFF172B4D),
          ),
        ),
      ),
    ],
  );

  Widget _section(IconData icon, String title, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5EEFC)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0801408B),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1EFFF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: const Color(0xFF01408B), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
}
