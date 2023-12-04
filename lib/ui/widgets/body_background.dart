import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BodyBackground extends StatelessWidget {
  const BodyBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          "assets/images/background.svg",
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}
