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
                      padding: EdgeInsets.all(5),
                      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.jmIndigo.withValues(alpha: .2),
                            blurRadius: 5,
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
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
                          color: AppColors.jmIndigo.withAlpha(20),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        controller: _tabController,
                        unselectedLabelStyle: JemenaiTheme.fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey,
                        ),
                        labelStyle: JemenaiTheme.fontBody(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.jmIndigo,
                        ),
                        tabs: [
                          Tab(
                            icon: Assets.svg.home.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 0
                                      ? AppColors.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Home",
                          ),
                          Tab(
                            icon: Assets.svg.store.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 1
                                      ? AppColors.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Models",
                          ),
                          Tab(
                            icon: Assets.svg.hardDrive.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 2
                                      ? AppColors.jmIndigo
                                      : AppColors.grey,
                            ),
                            text: "Storage",
                          ),
                          Tab(
                            icon: Assets.svg.settings.svg(
                              width: 23,
                              height: 23,
                              color:
                                  value == 3
                                      ? AppColors.jmIndigo
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
