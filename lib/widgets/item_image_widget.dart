import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos_mobile/controller/DB_helper.dart';

class ItemImageWidget extends StatefulWidget {
  final int? imageId;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  const ItemImageWidget({
    super.key,
    required this.imageId,
    this.fallbackIcon = Icons.inventory_2_rounded,
    this.fallbackIconSize = 40,
  });

  @override
  State<ItemImageWidget> createState() => _ItemImageWidgetState();
}

class _ItemImageWidgetState extends State<ItemImageWidget> {
  late Future<String?> _imagePathFuture;

  @override
  void initState() {
    super.initState();
    _imagePathFuture = _loadImagePath();
  }

  @override
  void didUpdateWidget(covariant ItemImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageId != widget.imageId) {
      _imagePathFuture = _loadImagePath();
    }
  }

  Future<String?> _loadImagePath() {
    final imageId = widget.imageId;
    return imageId == null
        ? Future.value(null)
        : DBHelper.getImagePath(imageId);
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
    return FutureBuilder<String?>(
      future: _imagePathFuture,
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null || !File(path).existsSync()) return _fallback();

        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      },
    );
  }
}
