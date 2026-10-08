import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shared pull-to-refresh appearance for every scrollable application page.
class AppRefreshIndicator extends StatefulWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.isLoading = false,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final bool isLoading;
  final ScrollNotificationPredicate notificationPredicate;

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      RefreshIndicator(
        onRefresh: _refresh,
        notificationPredicate: widget.notificationPredicate,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: widget.child,
      ),
      if (widget.isLoading && !_refreshing)
        const Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ),
    ],
  );
}
