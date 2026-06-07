import 'package:flutter/material.dart';
import 'package:jemenai/features/ai/views/chat_screen.dart';
import 'package:jemenai/features/ai/views/models_store_screen.dart';
import 'package:jemenai/features/dashboard/views/storage_dashboard_screen.dart';
import 'package:jemenai/features/home/views/home_screen.dart';
import 'package:jemenai/features/settings/views/settings_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        HomeScreen(),
        ModelsStoreScreen(),
        ChatScreen(),
        StorageDashboardScreen(),
        SettingsScreen(),
      ],
    );
  }
}
