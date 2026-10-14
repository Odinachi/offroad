import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/views/models_store_screen.dart';
import 'package:jemenai/features/dashboard/views/storage_dashboard_screen.dart';
import 'package:jemenai/features/home/views/home_screen.dart';
import 'package:jemenai/features/settings/views/settings_screen.dart';
import 'package:jemenai/shared/assets.dart';
import 'package:jemenai/shared/navigator/app_router.dart';
import 'package:jemenai/shared/theme.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final navValue = AppRouter.dashboardTab;

  @override
  void initState() {
    super.initState();
    navValue.value = AppRouter.homeTab;
    _tabController = TabController(length: 4, vsync: this);
    navValue.addListener(_syncTab);
  }

  void _syncTab() {
    if (_tabController.index != navValue.value) {
      _tabController.animateTo(navValue.value);
    }
  }

  @override
  void dispose() {
    navValue.removeListener(_syncTab);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jc = theme.jColors;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: const [
            HomeScreen(callback: AppRouter.openDashboardTab),
            ModelsStoreScreen(),
            StorageDashboardScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      // As the Scaffold's bottom bar (not a Stack overlay) so floating
      // SnackBars are laid out above it instead of covering it.
      bottomNavigationBar: Builder(
        builder: (context) {
          return SafeArea(
            child: ValueListenableBuilder(
              valueListenable: navValue,
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: jc.navBackground,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.jmIndigo.withValues(
                          alpha: isDark ? .08 : .15,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: jc.border),
                  ),
                  height: 60,
                  child: TabBar(
                    physics: const NeverScrollableScrollPhysics(),
                    onTap: (a) => navValue.value = a,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: jc.jmIndigo.withAlpha(20),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    controller: _tabController,
                    unselectedLabelStyle: JemenaiTheme.fontBody(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                    ),
                    labelStyle: JemenaiTheme.fontBody(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: jc.jmIndigo,
                    ),
                    tabs: [
                      Tab(
                        iconMargin: const EdgeInsets.only(top: 2),
                        icon: Assets.svg.home.svg(
                          width: 23,
                          height: 23,
                          color: value == 0 ? jc.jmIndigo : AppColors.grey,
                        ),
                        text: "Home",
                      ),
                      Tab(
                        iconMargin: const EdgeInsets.only(top: 2),
                        icon: Assets.svg.store.svg(
                          width: 23,
                          height: 23,
                          color: value == 1 ? jc.jmIndigo : AppColors.grey,
                        ),
                        text: "Models",
                      ),
                      Tab(
                        iconMargin: const EdgeInsets.only(top: 2),
                        icon: Assets.svg.hardDrive.svg(
                          width: 23,
                          height: 23,
                          color: value == 2 ? jc.jmIndigo : AppColors.grey,
                        ),
                        text: "Storage",
                      ),
                      Tab(
                        iconMargin: const EdgeInsets.only(top: 2),
                        icon: Assets.svg.settings.svg(
                          width: 23,
                          height: 23,
                          color: value == 3 ? jc.jmIndigo : AppColors.grey,
                        ),
                        text: "Settings",
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
