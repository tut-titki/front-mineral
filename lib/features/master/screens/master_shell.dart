import 'package:flutter/material.dart';

import 'package:mineral/core/api/api_services.dart';

import 'package:mineral/features/auth/widgets/auth_scope.dart';

import 'package:mineral/features/master/screens/dashboard_screen.dart';
import 'package:mineral/features/master/screens/master_profile_screen.dart';

import 'package:mineral/features/orders/models/work_order_api_models.dart';
import 'package:mineral/features/orders/screens/order_detail_screen.dart';
import 'package:mineral/features/orders/screens/order_screens.dart';

import 'package:mineral/l10n/language_switcher.dart';
import 'package:mineral/l10n/ui_localization.dart';

import 'package:mineral/shared/models/models.dart';
import 'package:mineral/shared/widgets/ui.dart';

// MARK: - Master Shell

class MasterShell extends StatefulWidget {
  const MasterShell({super.key, required this.api});

  final ApiServices api;

  @override
  State<MasterShell> createState() => _MasterShellState();
}

class _MasterShellState extends State<MasterShell> {
  int page = 0;

  bool _loggingOut = false;

  // MARK: - Logout

  Future<void> _logout() async {
    final session = AuthScope.maybeOf(context);

    if (session == null || _loggingOut) {
      return;
    }

    setState(() {
      _loggingOut = true;
    });

    try {
      await session.logout();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings(context).authNetworkError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  // MARK: - Navigation

  static const labels = [
    'Обзор смены',
    'Наряды',
    'Команда',
    'ИИ-контроль',
    'Отчёты',
    'Профиль',
  ];

  static const icons = [
    Icons.grid_view_rounded,
    Icons.assignment_outlined,
    Icons.groups_outlined,
    Icons.auto_awesome,
    Icons.bar_chart_rounded,
    Icons.person_outline,
  ];

  // MARK: - Backend order

  Future<void> openOrder(WorkOrderApiModel order) => openOrderId(order.id);

  Future<void> openOrderId(int id) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailScreen(api: widget.api, orderId: id),
      ),
    );
    if (mounted) widget.api.realtime.invalidate();
  }
  // MARK: - Create order

  Future<void> createOrder() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => CreateOrderScreen(api: widget.api),
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    widget.api.realtime.invalidate();
    // После создания переходим в реальные наряды.
    //
    // OrdersScreen при следующем создании экземпляра
    // выполнит GET /api/work-orders.
    setState(() {
      page = 1;
    });
  }

  // MARK: - Notifications

  void openNotifications() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(uiText(context, 'Уведомления'))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: NotificationsScreen(api: widget.api, onOrder: openOrderId),
          ),
        ),
      ),
    );
  }
  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final desktop = MediaQuery.sizeOf(context).width >= 1000;

        final content = switch (page) {
          0 => DashboardScreen(
            api: widget.api,
            onOrder: openOrder,
            onCreate: createOrder,
            onTeam: () {
              setState(() {
                page = 2;
              });
            },
          ),

          1 => OrdersScreen(
            api: widget.api,
            onOrder: openOrder,
            onCreate: createOrder,
          ),

          2 => TeamScreen(api: widget.api),

          3 => AiScreen(api: widget.api, onOrder: openOrder),

          4 => ReportsScreen(api: widget.api),

          _ => MasterProfileScreen(
            api: widget.api,
            onLogout: _logout,
            loggingOut: _loggingOut,
          ),
        };

        return Scaffold(
          // MARK: Mobile app bar
          appBar: desktop
              ? null
              : AppBar(
                  title: page == 5
                      ? Text(uiText(context, 'Профиль'))
                      : Image.asset(
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
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),

          // MARK: Mobile navigation
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: page,
                  onDestinationSelected: (value) {
                    setState(() {
                      page = value;
                    });
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view_rounded),
                      selectedIcon: const Icon(Icons.grid_view_rounded),
                      label: uiText(context, 'Смена'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.assignment_outlined),
                      selectedIcon: const Icon(Icons.assignment),
                      label: uiText(context, 'Наряды'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.groups_outlined),
                      selectedIcon: const Icon(Icons.groups),
                      label: uiText(context, 'Команда'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.auto_awesome_outlined),
                      selectedIcon: const Icon(Icons.auto_awesome),
                      label: uiText(context, 'ИИ'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.bar_chart_rounded),
                      selectedIcon: const Icon(Icons.bar_chart_rounded),
                      label: uiText(context, 'Отчёты'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: const Icon(Icons.person),
                      label: uiText(context, 'Профиль'),
                    ),
                  ],
                ),

          // MARK: Main layout
          body: Row(
            children: [
              // MARK: Desktop sidebar
              if (desktop)
                Container(
                  width: 240,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: border)),
                  ),
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                          child: Image.asset(
                            'assets/logo_blue.png',
                            width: 192,
                            height: 96,
                            fit: BoxFit.contain,
                            semanticLabel: 'Костанайские минералы',
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Text(
                            uiText(context, 'УПРАВЛЕНИЕ СМЕНОЙ'),
                            style: const TextStyle(
                              color: muted,
                              fontSize: 10,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),

                        for (var index = 0; index < labels.length; index++)
                          Padding(
                            padding: const EdgeInsets.symmetric(
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  page = index;
                                });
                              },
                            ),
                          ),

                        const Spacer(),

                        ListTile(
                          onTap: () => setState(() => page = 5),
                          leading: CircleAvatar(
                            backgroundColor: background,
                            child: Text(
                              uiText(
                                context,
                                AuthScope.maybeOf(context)?.user?.fullName
                                        .split(' ')
                                        .where((p) => p.isNotEmpty)
                                        .take(2)
                                        .map((p) => p[0])
                                        .join() ??
                                    '',
                              ),
                              style: const TextStyle(color: brand),
                            ),
                          ),
                          title: Text(
                            uiText(
                              context,
                              AuthScope.maybeOf(context)?.user?.fullName ??
                                  uiText(context, 'Мастер смены'),
                            ),
                          ),
                          subtitle: Text(uiText(context, 'Мастер смены')),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

              // MARK: Content
              Expanded(
                child: Column(
                  children: [
                    // MARK: Desktop header
                    if (desktop)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.factory_outlined, color: muted),

                            const SizedBox(width: 10),

                            Text(
                              uiText(context, 'Минеральный комплекс'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Text(uiText(context, 'Мастер смены')),

                            const Spacer(),

                            Text(
                              uiText(context, dateLabel(DateTime.now())),
                              style: const TextStyle(color: muted),
                            ),

                            const SizedBox(width: 14),

                            const LanguageSwitcher(),

                            IconButton(
                              tooltip: uiText(context, 'Уведомления'),
                              onPressed: openNotifications,
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                          ],
                        ),
                      ),

                    // MARK: Page
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(desktop ? 28 : 18),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
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
