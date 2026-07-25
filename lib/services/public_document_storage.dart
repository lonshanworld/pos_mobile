import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Stores user-facing files in Documents/nanonux on Android.
/// Other platforms use the app Documents directory.
class PublicDocumentStorage {
  PublicDocumentStorage._();

  static const _channel = MethodChannel('nanonux/public_documents');

  static Future<String> saveBytes({
    required Uint8List bytes,
    required String fileName,
    required String directory,
  }) async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      // Android 10+ uses MediaStore and does not require legacy storage
      // permission. Older versions need WRITE_EXTERNAL_STORAGE.
      if (storageStatus.isPermanentlyDenied) {
        throw StateError('Storage permission is permanently denied.');
      }
      return await _channel.invokeMethod<String>('saveBytes', {
            'bytes': bytes,
            'fileName': fileName,
            'directory': directory,
          }) ??
          (throw StateError('Android did not return a saved file path.'));
    }

    final documents = await getApplicationDocumentsDirectory();
    final directoryPath = Directory('${documents.path}/nanonux/$directory');
    await directoryPath.create(recursive: true);
    final file = File('${directoryPath.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> copyFile({
    required String sourcePath,
    required String fileName,
    required String directory,
  }) async {
    return saveBytes(
      bytes: await File(sourcePath).readAsBytes(),
      fileName: fileName,
      directory: directory,
    );
  }

  static Future<Map<String, String>> migrateExistingFiles() async {
    if (!Platform.isAndroid) return {};

    final migrated = <String, String>{};
    final documents = await getApplicationDocumentsDirectory();
    final support = await getApplicationSupportDirectory();
    final external = await getExternalStorageDirectory();

    Future<void> migrateDirectory(Directory directory, String target) async {
      if (!await directory.exists()) return;
      await for (final entity in directory.list()) {
        if (entity is! File) continue;
        final destination = await copyFile(
          sourcePath: entity.path,
          fileName: entity.uri.pathSegments.last,
          directory: target,
        );
        migrated[entity.path] = destination;
      }
    }

    await migrateDirectory(
      Directory('${documents.path}/nanonux/vouchers'),
      'vouchers',
    );
    await migrateDirectory(
      Directory('${support.path}/nanonux_item_images'),
      'item_images',
    );
    await migrateDirectory(Directory('${support.path}/shop_logo'), 'shop_logo');
    if (external != null) {
      await migrateDirectory(external, 'reports');
    }
    return migrated;
  }
}
