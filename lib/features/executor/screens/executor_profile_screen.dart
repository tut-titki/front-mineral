import 'package:mineral/features/auth/screens/change_password_screen.dart';
import 'package:mineral/features/auth/widgets/auth_scope.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';

class ExecutorProfileScreen extends StatelessWidget {
  const ExecutorProfileScreen({
    super.key,
    required this.store,
    required this.employeeId,
  });
  final ExecutorRepository store;
  final int employeeId;
  static const _blue = Color(0xFF01408B);

  @override
  Widget build(BuildContext context) {
    final employee = store.employee(employeeId);
    final rating = store.executorRating(employeeId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFDFEBFA),
              child: Text(
                employee.initials,
                style: const TextStyle(
                  color: _blue,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    uiText(context, employee.specialty),
                    style: const TextStyle(
                      color: Color(0xFF687385),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _panel(
          Column(
            children: [
              _detail(
                Icons.groups_outlined,
                uiText(context, 'Бригада'),
                uiText(context, employee.brigade),
              ),
              const Divider(height: 1),
              _detail(
                Icons.workspace_premium_outlined,
                uiText(context, 'Разряд'),
                '${employee.grade}',
              ),
              const Divider(height: 1),
              _detail(
                Icons.schedule,
                uiText(context, 'Смена'),
                employee.onShift
                    ? uiText(context, 'На смене')
                    : uiText(context, 'Не на смене'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _panel(
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_outline, color: _blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        uiText(context, 'Мой рейтинг'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (rating == null) ...[
                  Text(
                    uiText(context, 'Пока нет оценки'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uiText(
                      context,
                      'После проверки выполненных нарядов здесь появятся рейтинг и его объяснение.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF687385),
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  Text(
                    rating.score.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                    ),
                  ),
                  if (rating.explanation.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      rating.explanation,
                      style: const TextStyle(
                        height: 1.5,
                        color: Color(0xFF687385),
                      ),
                    ),
                  ],
                  if (rating.quality != null)
                    _detail(
                      Icons.verified_outlined,
                      uiText(context, 'Качество'),
                      '${rating.quality}',
                    ),
                  if (rating.onTimePercent != null)
                    _detail(
                      Icons.timer_outlined,
                      uiText(context, 'В срок'),
                      '${rating.onTimePercent}%',
                    ),
                  if (rating.reworkPercent != null)
                    _detail(
                      Icons.edit_note,
                      uiText(context, 'Доработки'),
                      '${rating.reworkPercent}%',
                    ),
                  if (rating.completedCount != null)
                    _detail(
                      Icons.task_alt,
                      uiText(context, 'Закрыто нарядов'),
                      '${rating.completedCount}',
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (AuthScope.maybeOf(context) != null) ...[
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            ),
            icon: const Icon(Icons.lock_outline),
            label: Text(strings(context).changePasswordTitle),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            foregroundColor: const Color(0xFFB42318),
            side: const BorderSide(color: Color(0xFFF1D5D2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {
            final session = AuthScope.maybeOf(context);
            if (session == null) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
              return;
            }
            try {
              await session.logout();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings(context).authNetworkError)),
                );
              }
            }
          },
          icon: const Icon(Icons.logout),
          label: Text(uiText(context, 'Выйти')),
        ),
      ],
    );
  }

  Widget _panel(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE5E8ED)),
    ),
    child: child,
  );

  Widget _detail(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF687385)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF687385))),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
