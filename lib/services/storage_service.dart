import 'dart:io';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<double> getTotalDiskSpaceGB() async {
    final double? totalDiskSpace = await DiskSpace.getTotalDiskSpace;
    return (totalDiskSpace ?? 128000.0) / 1024.0;
  }

  static Future<double> getFreeDiskSpaceGB() async {
    final double? freeDiskSpace = await DiskSpace.getFreeDiskSpace;
    return (freeDiskSpace ?? 64000.0) / 1024.0;
  }

  static Future<double> getAppDirectorySizeGB() async {
    double totalSize = 0;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      totalSize += _calculateFolderSize(docsDir);

      final supportDir = await getApplicationSupportDirectory();
      totalSize += _calculateFolderSize(supportDir);

      final cacheDir = await getTemporaryDirectory();
      totalSize += _calculateFolderSize(cacheDir);
    } catch (e) {
      print("Error calculating app size: $e");
    }
    return totalSize / (1024 * 1024 * 1024); // bytes to GB
  }

  static double _calculateFolderSize(Directory dir) {
    double totalSize = 0;
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      // Ignore access errors
    }
    return totalSize;
  }
}
