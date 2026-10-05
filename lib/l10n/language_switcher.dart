import 'package:flutter/material.dart';
import 'package:mineral/l10n/app_locale.dart';
import 'package:mineral/l10n/ui_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) => PopupMenuButton<Locale>(
    tooltip: strings(context).language,
    icon: const Icon(Icons.language),
    onSelected: (locale) => appLocale.value = locale,
    itemBuilder: (_) => const [
      PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
      PopupMenuItem(value: Locale('kk'), child: Text('Қазақша')),
    ],
  );
}
