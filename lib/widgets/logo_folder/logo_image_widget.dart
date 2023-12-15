import "package:flutter/material.dart";

class LogoImageWidget extends StatelessWidget {

  final double widthandheight;
  const LogoImageWidget({
    super.key,
    required this.widthandheight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthandheight,
      height: widthandheight,
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/IMG_20230921_195426.png",
            ),
            fit: BoxFit.contain,
          )
      ),
    );
  }
}
