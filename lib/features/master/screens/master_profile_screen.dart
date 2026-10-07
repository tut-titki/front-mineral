import '../../../l10n/language_switcher.dart';
import 'package:flutter/material.dart';

import '../../../core/api/api_services.dart';
import '../../../l10n/ui_localization.dart';
import '../../auth/screens/change_password_screen.dart';
import '../../auth/widgets/auth_scope.dart';
import '../../orders/data/references_api.dart';

class MasterProfileScreen extends StatefulWidget {
  const MasterProfileScreen({
    super.key,
    required this.api,
    required this.onLogout,
    required this.loggingOut,
  });

  final ApiServices api;
  final VoidCallback onLogout;
  final bool loggingOut;

  @override
  State<MasterProfileScreen> createState() => _MasterProfileScreenState();
}

class _MasterProfileScreenState extends State<MasterProfileScreen> {
  static const _blue = Color(0xFF01408B);
  int? _brigadeId;
  Future<List<BrigadeReference>>? _brigades;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brigadeId = AuthScope.maybeOf(context)?.user?.brigadeId;
    if (_brigadeId != brigadeId) {
      _brigadeId = brigadeId;
      _brigades = brigadeId == null
          ? null
          : widget.api.references.getBrigades();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = AuthScope.maybeOf(context);
    final user = session?.user;
    final name = user?.fullName ?? uiText(context, 'Мастер смены');
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFDFEBFA),
              child: Text(
                initials,
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
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    uiText(context, 'Мастер смены'),
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E8ED)),
          ),
          child: Column(
            children: [
              if (_brigades != null) ...[
                FutureBuilder<List<BrigadeReference>>(
                  future: _brigades,
                  builder: (context, snapshot) {
                    final brigade = snapshot.data
                        ?.where((brigade) => brigade.id == _brigadeId)
                        .firstOrNull;
                    return Column(
                      children: [
                        _detail(
                          Icons.groups_outlined,
                          uiText(context, 'Бригада'),
                          brigade == null ? '—' : uiText(context, brigade.name),
                        ),
                        if (snapshot.hasError)
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _brigades = widget.api.references.getBrigades();
                            }),
                            icon: const Icon(Icons.refresh),
                            label: Text(uiText(context, 'Повторить')),
                          ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
              ],
              if ((user?.grade ?? 0) > 0) ...[
                _detail(
                  Icons.workspace_premium_outlined,
                  uiText(context, 'Разряд'),
                  '${user!.grade}',
                ),
                const Divider(height: 1),
              ],
              _detail(
                Icons.schedule,
                uiText(context, 'Смена'),
                user == null
                    ? '—'
                    : uiText(
                        context,
                        user.isOnShift ? 'На смене' : 'Не на смене',
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFDCE4EE)),
          ),
          clipBehavior: Clip.antiAlias,
          child: const ProfileLanguageTile(),
        ),
        if (session != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            ),
            icon: const Icon(Icons.lock_outline),
            label: Text(strings(context).changePasswordTitle),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              foregroundColor: const Color(0xFFB42318),
              side: const BorderSide(color: Color(0xFFF1D5D2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: widget.loggingOut ? null : widget.onLogout,
            icon: const Icon(Icons.logout),
            label: Text(uiText(context, 'Выйти')),
          ),
        ],
      ],
    );
  }

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
