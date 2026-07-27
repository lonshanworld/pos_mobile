import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';

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
    if (kIsWeb) {
      final extension = fileName.toLowerCase().split('.').last;
      final mimeType = switch (extension) {
        'pdf' => MimeType.pdf,
        'xlsx' => MimeType.microsoftExcel,
        'xls' => MimeType.microsoftExcel,
        'csv' => MimeType.csv,
        'jpg' || 'jpeg' => MimeType.jpeg,
        'png' => MimeType.png,
        'webp' => MimeType.webp,
        'gif' => MimeType.gif,
        _ => MimeType.other,
      };
      final dot = fileName.lastIndexOf('.');
      final name = dot > 0 ? fileName.substring(0, dot) : fileName;
      final ext = dot > 0 ? fileName.substring(dot + 1) : '';
      final saved = await FileSaver.instance.saveFile(
        name: name,
        bytes: bytes,
        fileExtension: ext,
        mimeType: mimeType,
      );
      return saved;
    }
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
    if (kIsWeb && sourcePath.startsWith('data:')) return sourcePath;
    return saveBytes(
      bytes: await File(sourcePath).readAsBytes(),
      fileName: fileName,
      directory: directory,
    );
  }

  /// Saves an image selected by image_picker.
  ///
  /// Reading the bytes from XFile is important on web, where [XFile.path]
  /// can be a browser blob URL rather than a readable native file path.
  static Future<String> copyXFile({
    required XFile source,
    required String fileName,
    required String directory,
  }) async {
    return saveBytes(
      bytes: await source.readAsBytes(),
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
