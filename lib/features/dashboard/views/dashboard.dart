import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/views/models_store_screen.dart';
import 'package:jemenai/features/dashboard/views/storage_dashboard_screen.dart';
import 'package:jemenai/features/home/views/home_screen.dart';
import 'package:jemenai/features/settings/views/settings_screen.dart';
import 'package:jemenai/shared/assets.dart';
import 'package:jemenai/shared/theme.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final navValue = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
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
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: const [
                HomeScreen(),
                ModelsStoreScreen(),
                StorageDashboardScreen(),
                SettingsScreen(),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: ValueListenableBuilder(
                  valueListenable: navValue,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      padding: EdgeInsets.all(5),
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
                        onTap: (a) => navValue.value = a,
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
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
                            iconMargin: EdgeInsets.only(top: 2),
                            icon: Assets.svg.home.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 0
                                      ? jc.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Home",
                          ),
                          Tab(
                            iconMargin: EdgeInsets.only(top: 2),
                            icon: Assets.svg.store.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 1
                                      ? jc.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Models",
                          ),
                          Tab(
                            iconMargin: EdgeInsets.only(top: 2),
                            icon: Assets.svg.hardDrive.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 2
                                      ? jc.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Storage",
                          ),
                          Tab(
                            iconMargin: EdgeInsets.only(top: 2),
                            icon: Assets.svg.settings.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 3
                                      ? jc.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Settings",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
