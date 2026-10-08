import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/ui_localization.dart';

class AppNotificationsButton extends StatelessWidget {
  const AppNotificationsButton({
    super.key,
    required this.onPressed,
    this.color,
  });

  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: uiText(context, 'Уведомления'),
    onPressed: onPressed,
    icon: Icon(LucideIcons.bell, size: 24, color: color),
  );
}
