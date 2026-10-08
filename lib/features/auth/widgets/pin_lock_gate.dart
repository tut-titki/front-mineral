import 'package:flutter/material.dart';

import '../data/pin_lock_controller.dart';
import '../screens/pin_lock_screen.dart';

/// Sits above the entire Navigator, including dialogs and notification routes.
/// Keeps the current form alive while the application is locked.
class PinLockGate extends StatefulWidget {
  const PinLockGate({super.key, required this.controller, required this.child});
  final PinLockController controller;
  final Widget child;

  @override
  State<PinLockGate> createState() => _PinLockGateState();
}

class _PinLockGateState extends State<PinLockGate> with WidgetsBindingObserver {
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      widget.controller.lock();
    }
    // Inactive also covers permission sheets; mask the app without forcing a
    // new PIN just for a transient system dialog.
    setState(() => _obscured = state != AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final blocking = widget.controller.blocking;
      final obscure = _obscured && widget.controller.session.authenticated;
      return Stack(
        fit: StackFit.expand,
        children: [
          Offstage(
            offstage: blocking || obscure,
            child: TickerMode(
              enabled: !blocking && !obscure,
              child: FocusScope(
                canRequestFocus: !blocking && !obscure,
                child: widget.child,
              ),
            ),
          ),
          if (blocking)
            PinLockScreen(
              key: ValueKey(
                '${widget.controller.status}:${widget.controller.session.user?.id}',
              ),
              controller: widget.controller,
            ),
          if (obscure)
            const Positioned.fill(
              child: ColoredBox(
                key: ValueKey('pin-privacy-cover'),
                color: Colors.white,
                child: Center(child: Icon(Icons.lock_outline, size: 48)),
              ),
            ),
        ],
      );
    },
  );
}
