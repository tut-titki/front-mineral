import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

class WorkTimer extends StatefulWidget {
  const WorkTimer({super.key, required this.order, required this.store});
  final WorkOrder order;
  final DemoStore store;
  @override
  State<WorkTimer> createState() => _WorkTimerState();
}

class _WorkTimerState extends State<WorkTimer> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.order.status == OrderStatus.working) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.order.workDuration(widget.store.now);
    String digits(int value) => value.toString().padLeft(2, '0');
    final time =
        '${digits(duration.inHours)}:${digits(duration.inMinutes.remainder(60))}:${digits(duration.inSeconds.remainder(60))}';
    return Semantics(
      label: 'Время в работе: $time',
      child: Text(
        time,
        style: const TextStyle(
          color: Color(0xFF01408B),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
