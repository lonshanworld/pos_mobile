import 'dart:convert';
import 'dart:io';

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:pos_mobile/services/network_environment.dart";

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
    final resolvedLogoPath =
        customLogoPath != null && customLogoPath!.startsWith('/api/images/')
        ? '${NetworkConfiguration.backendBaseUrl}$customLogoPath'
        : customLogoPath;
    if (kIsWeb && customLogoPath?.startsWith('data:') == true) {
      final dataUrl = customLogoPath!;
      final separator = dataUrl.indexOf(',');
      if (separator >= 0) {
        final bytes = base64Decode(dataUrl.substring(separator + 1));
        return SizedBox(
          width: widthandheight,
          height: widthandheight,
          child: Image.memory(bytes, fit: BoxFit.contain),
        );
      }
    }
    if (resolvedLogoPath != null &&
        (resolvedLogoPath.startsWith('http://') ||
            resolvedLogoPath.startsWith('https://'))) {
      return SizedBox(
        width: widthandheight,
        height: widthandheight,
        child: Image.network(
          resolvedLogoPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/ic_launcher_max.png',
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    final bool useCustom =
        !kIsWeb && customLogoPath != null && File(customLogoPath!).existsSync();

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
