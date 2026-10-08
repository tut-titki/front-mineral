import 'dart:async';
import 'package:flutter/material.dart';
import 'app_refresh_indicator.dart';

/// Keeps the refresh gesture waiting until every visible data loader finishes.
class BackendRefreshController extends ChangeNotifier {
  final _loaders = <Future<void> Function()>{};
  final _initialLoads = <Object>{};
  bool _notificationPending = false;
  bool _disposed = false;

  bool get isLoading => _initialLoads.isNotEmpty;

  void setInitialLoading(Object owner, bool loading) {
    if (_disposed) return;
    final changed = loading
        ? _initialLoads.add(owner)
        : _initialLoads.remove(owner);
    if (!changed || _notificationPending) return;
    _notificationPending = true;
    scheduleMicrotask(() {
      _notificationPending = false;
      if (!_disposed) notifyListeners();
    });
  }

  void register(Future<void> Function() loader) => _loaders.add(loader);
  void unregister(Future<void> Function() loader) => _loaders.remove(loader);

  Future<void> refresh() async {
    await Future.wait(_loaders.toList().map((loader) => loader()));
  }

  @override
  void dispose() {
    _disposed = true;
    _loaders.clear();
    _initialLoads.clear();
    super.dispose();
  }
}

class BackendRefreshScope extends InheritedWidget {
  const BackendRefreshScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final BackendRefreshController controller;

  static BackendRefreshController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BackendRefreshScope>()
      ?.controller;

  @override
  bool updateShouldNotify(BackendRefreshScope oldWidget) =>
      controller != oldWidget.controller;
}

class BackendRefreshView extends StatefulWidget {
  const BackendRefreshView({
    super.key,
    required this.child,
    this.padding,
    this.onRefresh,
    this.scrollController,
    this.isLoading = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final ScrollController? scrollController;
  final bool isLoading;

  @override
  State<BackendRefreshView> createState() => _BackendRefreshViewState();
}

class _BackendRefreshViewState extends State<BackendRefreshView> {
  final _controller = BackendRefreshController();

  Future<void> _refresh() async {
    await widget.onRefresh?.call();
    await _controller.refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BackendRefreshScope(
    controller: _controller,
    child: ListenableBuilder(
      listenable: _controller,
      builder: (context, child) => AppRefreshIndicator(
        onRefresh: _refresh,
        isLoading: widget.isLoading || _controller.isLoading,
        child: child!,
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        child: widget.child,
      ),
    ),
  );
}
