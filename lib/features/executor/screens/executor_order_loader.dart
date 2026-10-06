import 'package:flutter/material.dart';
import 'package:mineral/features/auth/data/auth_session.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/models/models.dart';
import '../data/executor_repository.dart';
import 'executor_order_screen.dart';
import 'executor_result_screen.dart';

class ExecutorOrderLoader extends StatefulWidget {
  const ExecutorOrderLoader({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
    this.showResult,
  });
  final ExecutorRepository store;
  final WorkOrder order;
  final int employeeId;
  final bool? showResult;
  @override
  State<ExecutorOrderLoader> createState() => _ExecutorOrderLoaderState();
}

class _ExecutorOrderLoaderState extends State<ExecutorOrderLoader> {
  late Future<WorkOrder> _order = widget.store.loadExecutorOrder(
    widget.employeeId,
    widget.order,
  );
  @override
  Widget build(BuildContext context) => FutureBuilder<WorkOrder>(
    future: _order,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final order = snapshot.data!;
        final result =
            widget.showResult ??
            {
              OrderStatus.review,
              OrderStatus.rework,
              OrderStatus.closed,
            }.contains(order.status);
        return result
            ? ExecutorResultScreen(
                store: widget.store,
                order: order,
                employeeId: widget.employeeId,
              )
            : ExecutorOrderScreen(
                store: widget.store,
                order: order,
                employeeId: widget.employeeId,
              );
      }
      final error = snapshot.error;
      return Scaffold(
        appBar: AppBar(
          title: Text(strings(context).orderNumber(widget.order.displayNumber)),
        ),
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        error is ApiException && error.message.isNotEmpty
                            ? error.message
                            : error is ApiException &&
                                  (error.status == 403 || error.status == 404)
                            ? strings(context).orderUnavailable
                            : strings(context).authNetworkError,
                      ),
                    ),
                    if (error is ApiException &&
                        (error.status == 403 || error.status == 404))
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(strings(context).back),
                      )
                    else
                      TextButton(
                        onPressed: () => setState(() {
                          _order = widget.store.loadExecutorOrder(
                            widget.employeeId,
                            widget.order,
                          );
                        }),
                        child: Text(uiText(context, 'Повторить')),
                      ),
                  ],
                ),
        ),
      );
    },
  );
}
