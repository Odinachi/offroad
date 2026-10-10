import 'dart:io';
import 'dart:isolate';

import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  /// Device capacity in GB, or null if the platform doesn't report it.
  static Future<double?> getTotalDiskSpaceGB() async {
    try {
      final mb = await DiskSpace.getTotalDiskSpace;
      return mb == null || mb <= 0 ? null : mb / 1024.0;
    } catch (_) {
      return null;
    }
  }

  /// Free space in GB, or null if the platform doesn't report it.
  static Future<double?> getFreeDiskSpaceGB() async {
    try {
      final mb = await DiskSpace.getFreeDiskSpace;
      return mb == null || mb < 0 ? null : mb / 1024.0;
    } catch (_) {
      return null;
    }
  }

  /// Everything OffRoad stores (models, chats, caches), in GB.
  static Future<double> getAppDirectorySizeGB() async {
    try {
      final paths = [
        (await getApplicationDocumentsDirectory()).path,
        (await getApplicationSupportDirectory()).path,
        (await getTemporaryDirectory()).path,
      ];
      // Walking multi-GB model folders is blocking IO; keep it off the UI
      // thread.
      final bytes = await Isolate.run(
        () => paths.fold<int>(0, (sum, p) => sum + _folderSize(Directory(p))),
      );
      return bytes / (1024 * 1024 * 1024);
    } catch (e) {
      debugPrint('Error calculating app size: $e');
      return 0;
    }
  }

  static int _folderSize(Directory dir) {
    var total = 0;
    try {
      if (!dir.existsSync()) return 0;
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is File) total += entity.lengthSync();
      }
    } catch (_) {
      // Unreadable entries are skipped.
    }
    return total;
  }
}
