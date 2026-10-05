import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/l10n/language_switcher.dart';
import 'package:mineral/features/master/screens/dashboard_screen.dart';

import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/screens/order_screens.dart';
import 'package:mineral/shared/widgets/ui.dart';

class MasterShell extends StatefulWidget {
  const MasterShell({super.key, required this.store});

  final DemoStore store;

  @override
  State<MasterShell> createState() => _MasterShellState();
}

class _MasterShellState extends State<MasterShell> {
  int page = 0;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    refreshTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  static const labels = [
    'Обзор смены',
    'Наряды',
    'Команда',
    'ИИ-контроль',
    'Отчёты',
  ];

  static const icons = [
    Icons.grid_view_rounded,
    Icons.assignment_outlined,
    Icons.groups_outlined,
    Icons.auto_awesome,
    Icons.bar_chart_rounded,
  ];

  void openOrder(WorkOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailScreen(store: widget.store, order: order),
      ),
    );
  }

  void createOrder() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CreateOrderScreen(store: widget.store),
      ),
    );
  }

  void openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(uiText(context, 'Уведомления'))),
          body: ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) => SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: NotificationsScreen(
                store: widget.store,
                onOrder: openOrder,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final desktop = MediaQuery.sizeOf(context).width >= 1000;
        final visiblePage = !desktop && page == 3 ? 0 : page;

        final content = switch (visiblePage) {
          0 => DashboardScreen(
            store: widget.store,
            onOrder: openOrder,
            onCreate: createOrder,
            onTeam: () => setState(() => page = 2),
          ),
          1 => OrdersScreen(
            store: widget.store,
            onOrder: openOrder,
            onCreate: createOrder,
          ),
          2 => TeamScreen(store: widget.store),
          3 => AiScreen(store: widget.store, onOrder: openOrder),
          _ => ReportsScreen(store: widget.store),
        };

        return Scaffold(
          appBar: desktop
              ? null
              : AppBar(
                  title: Image.asset(
                    'assets/logo_blue.png',
                    width: 110,
                    height: 48,
                    fit: BoxFit.contain,
                    semanticLabel: 'Костанайские минералы',
                  ),
                  actions: [
                    const LanguageSwitcher(),
                    IconButton(
                      tooltip: uiText(context, 'Уведомления'),
                      onPressed: openNotifications,
                      icon: Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: visiblePage == 4 ? 3 : visiblePage,
                  onDestinationSelected: (value) {
                    setState(() => page = value == 3 ? 4 : value);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: uiText(context, 'Смена'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assignment_outlined),
                      label: uiText(context, 'Наряды'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.groups_outlined),
                      label: uiText(context, 'Команда'),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_rounded),
                      label: uiText(context, 'Отчёты'),
                    ),
                  ],
                ),
          body: Row(
            children: [
              if (desktop)
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: border)),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
                          child: Image.asset(
                            'assets/logo_blue.png',
                            width: 192,
                            height: 96,
                            fit: BoxFit.contain,
                            semanticLabel: 'Костанайские минералы',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 32),
                          child: Text(
                            uiText(context, 'УПРАВЛЕНИЕ СМЕНОЙ'),
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        for (var index = 0; index < labels.length; index++)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            child: ListTile(
                              selected: page == index,
                              selectedColor: brand,
                              selectedTileColor: lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              leading: Icon(icons[index]),
                              title: Text(
                                uiText(context, labels[index]),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () => setState(() => page = index),
                            ),
                          ),
                        Spacer(),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: background,
                            child: Text(
                              uiText(context, 'СО'),
                              style: TextStyle(color: brand),
                            ),
                          ),
                          title: Text(uiText(context, 'Серик Омаров')),
                          subtitle: Text(uiText(context, 'Мастер смены')),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    if (desktop)
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.factory_outlined, color: muted),
                            SizedBox(width: 10),
                            Text(
                              uiText(context, 'Минеральный комплекс'),
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 18),
                            StatusTag(
                              'Смена №1 · 08:00–20:00',
                              color: Color(0xFF059669),
                            ),
                            Spacer(),
                            Text(
                              uiText(context, dateLabel(DateTime.now())),
                              style: TextStyle(color: muted),
                            ),
                            SizedBox(width: 14),
                            const LanguageSwitcher(),
                            IconButton(
                              tooltip: uiText(context, 'Уведомления'),
                              onPressed: openNotifications,
                              icon: Icon(Icons.notifications_outlined),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(desktop ? 28 : 18),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1400),
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
