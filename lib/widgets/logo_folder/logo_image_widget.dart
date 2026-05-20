import 'dart:io';

import "package:flutter/material.dart";

class LogoImageWidget extends StatelessWidget {
  final double widthandheight;
  final String? customLogoPath;

  const LogoImageWidget({
    super.key,
    required this.widthandheight,
    this.customLogoPath,
  });

  @override
  Widget build(BuildContext context) {
    final bool useCustom =
        customLogoPath != null && File(customLogoPath!).existsSync();

    return SizedBox(
      width: widthandheight,
      height: widthandheight,
      child: Image(
        image: useCustom
            ? FileImage(File(customLogoPath!)) as ImageProvider
            : const AssetImage('assets/images/ic_launcher_max.png'),
        fit: BoxFit.contain,
      ),
    );
  }
}

