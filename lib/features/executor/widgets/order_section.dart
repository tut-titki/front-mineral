import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';

class OrderSection extends StatelessWidget {
  const OrderSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF65748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              uiText(context, title),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      child,
    ],
  );
}
