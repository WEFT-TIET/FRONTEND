import 'package:flutter/material.dart';
class GradientIcon extends StatelessWidget {
  const GradientIcon({super.key, 
    required this.icon,
    required this.gradient,
    this.size,
  });

  final IconData icon;
  final Gradient gradient;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // This color will be overwritten by the gradient
      ),
    );
  }
}