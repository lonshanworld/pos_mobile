import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Frontend image contract shared by logo and item uploads.
///
/// The picker is also configured with these dimensions at the call site, but
/// doing the resize here makes the limit deterministic on every platform,
/// including Flutter Web and gallery providers that ignore picker options.
class PreparedImage {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final String sourceMimeType;

  const PreparedImage({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.sourceMimeType,
  });

  String get dataUrl => 'data:$mimeType;base64,${base64Encode(bytes)}';
}

class ImageUploadService {
  ImageUploadService._();

  static const int maxDimension = 240;
  static const int maxBytes = 500 * 1024;

  static String mimeTypeForName(String name) {
    final extension = name.toLowerCase().split('.').last;
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'bmp' => 'image/bmp',
      'tif' || 'tiff' => 'image/tiff',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'avif' => 'image/avif',
      'svg' => 'image/svg+xml',
      _ => 'image/unknown',
    };
  }

  static Future<PreparedImage> prepare(XFile source) async {
    final sourceMimeType = source.mimeType != null &&
            source.mimeType!.toLowerCase().startsWith('image/')
        ? source.mimeType!.toLowerCase()
        : mimeTypeForName(source.name);
    final original = img.decodeImage(await source.readAsBytes());
    if (original == null) {
      throw const FormatException('The selected file is not a supported image');
    }

    final longestSide = original.width > original.height
        ? original.width
        : original.height;
    final resized = longestSide > maxDimension
        ? img.copyResize(
            original,
            width: original.width >= original.height ? maxDimension : null,
            height: original.height > original.width ? maxDimension : null,
          )
        : original;

    // JPEG gives predictable, compact bytes for the backend's 500 KiB limit.
    // Lower quality only when necessary so small logos retain their detail.
    for (var quality = 88; quality >= 25; quality -= 7) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );
      if (encoded.lengthInBytes <= maxBytes) {
        return PreparedImage(
          bytes: encoded,
          fileName: 'image_${DateTime.now().microsecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
          sourceMimeType: sourceMimeType,
        );
      }
    }
    throw const ImageUploadException(
      'The image is still larger than 500 KiB after resizing',
    );
  }
}

class ImageUploadException implements Exception {
  final String message;
  const ImageUploadException(this.message);

  @override
  String toString() => message;
}
