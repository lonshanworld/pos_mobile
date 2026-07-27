import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_mobile/services/network_environment.dart';
import 'package:pos_mobile/services/pos_repository.dart';

class ItemImageWidget extends StatefulWidget {
  final int? imageId;
  final String? imageUrl;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const ItemImageWidget({
    super.key,
    required this.imageId,
    this.imageUrl,
    this.fallbackIcon = Icons.inventory_2_rounded,
    this.fallbackIconSize = 40,
  });

  @override
  State<ItemImageWidget> createState() => _ItemImageWidgetState();
}

class _ItemImageWidgetState extends State<ItemImageWidget> {
  late Future<Object?> _imageDataFuture;

  @override
  void initState() {
    super.initState();
    _imageDataFuture = _loadImageData();
  }

  @override
  void didUpdateWidget(covariant ItemImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageId != widget.imageId ||
        oldWidget.imageUrl != widget.imageUrl) {
      _imageDataFuture = _loadImageData();
    }
  }

  Future<Object?> _loadImageData() async {
    final imageUrl = widget.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl.startsWith('/')
          ? '${NetworkConfiguration.backendBaseUrl}$imageUrl'
          : imageUrl;
    }
    final imageId = widget.imageId;
    if (imageId == null) return null;
    if (NetworkConfiguration.usesBackend) {
      // The public endpoint streams bytes with an image content type. This
      // lets Flutter use the response as a normal cached image URL and keeps
      // BLOB bytes out of JSON responses.
      return PosRepository.instance.publicImageUrl(imageId);
    }
    if (kIsWeb) return null;
    return DBHelper.getImagePath(imageId);
  }

  Widget _fallback() {
    return Center(
      child: Icon(
        widget.fallbackIcon,
        size: widget.fallbackIconSize,
        color: Colors.grey.withValues(alpha: 0.25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: _imageDataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data is Uint8List) {
          return Image.memory(
            data,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          );
        }
        final path = data as String?;
        if (path != null &&
            (path.startsWith('http://') || path.startsWith('https://'))) {
          return Image.network(
            path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallback(),
          );
        }
        if (kIsWeb && path != null && path.startsWith('data:')) {
          final separator = path.indexOf(',');
          if (separator >= 0) {
            return Image.memory(
              base64Decode(path.substring(separator + 1)),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallback(),
            );
          }
        }
        if (kIsWeb) return _fallback();
        if (path == null || !File(path).existsSync()) return _fallback();

        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
        );
      },
    );
  }
}
