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
        appBar: AppBar(title: Text(s.resultOrderNumber(order.displayNumber))),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              onPressed: () => _open(context),
              child: Text(
                order.status == OrderStatus.rework ? s.goToRework : s.openOrder,
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              uiText(context, order.title),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${uiText(context, order.equipment)} · ${uiText(context, order.area)}',
              style: const TextStyle(color: Color(0xFF687385), height: 1.5),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  executorStatusText(context, order),
                  style: TextStyle(
                    color: order.status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (order.status == OrderStatus.review) ...[
              const SizedBox(height: 16),
              Text(
                s.reportAwaitingMaster,
                style: const TextStyle(color: Color(0xFF687385), height: 1.5),
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
                        : reason,
                  ),
                  style: const TextStyle(color: Color(0xFF8F5100), height: 1.5),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _section(Icons.star_outline, s.executionResult, [
              Text(
                order.masterScore == null
                    ? s.masterScorePending
                    : s.eventScore('${order.masterScore}'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              if (assessment == null)
                Text(
                  s.assessmentPending,
                  style: const TextStyle(color: Color(0xFF687385), height: 1.5),
                )
              else ...[
                Text(
                  s.assessmentVerdict(uiText(context, assessment.verdict)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (assessment.score != null) ...[
                  const SizedBox(height: 8),
                  Text(s.assessmentScore('${assessment.score}')),
                ],
                if (assessment.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    assessment.explanation,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
                if (assessment.strengths.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    s.assessmentStrengths(assessment.strengths),
                    style: const TextStyle(height: 1.5),
                  ),
                ],
                if (assessment.improvements.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    s.assessmentImprovements(assessment.improvements),
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ],
              const Divider(height: 32),
              Text(
                s.workMinutesValue(
                  '${order.workDuration(store.now).inMinutes}',
                ),
              ),
              if (order.normHours != null) ...[
                const SizedBox(height: 8),
                Text(s.normHoursValue('${order.normHours}')),
              ],
            ]),
            const SizedBox(height: 16),
            _section(Icons.assignment_outlined, s.yourReport, [
              Text(
                order.completedWork.isEmpty
                    ? s.workNotSpecified
                    : uiText(context, order.completedWork),
                style: const TextStyle(height: 1.5),
              ),
              const Divider(height: 32),
              Text(
                s.faultCodeValue(
                  order.faultCode.isEmpty
                      ? s.notSpecified
                      : uiText(context, order.faultCode),
                ),
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                s.usedExecutorMaterials,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                order.materials.isEmpty
                    ? s.noMaterialsUsed
                    : uiText(context, order.materials),
                style: const TextStyle(height: 1.5),
              ),
              if (order.comment.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  s.comment,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  uiText(context, order.comment),
                  style: const TextStyle(height: 1.5),
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

  Widget _section(IconData icon, String title, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E8ED)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF01408B), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      );
}
