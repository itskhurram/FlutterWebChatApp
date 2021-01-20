import 'package:myuwi/Values/AppValues.dart';
import 'package:flutter/material.dart';

class AppCustomDivider extends StatelessWidget {
  AppCustomDivider({
    this.width = AppSizes.WIDTH_80,
    this.height = AppSizes.HEIGHT_1,
    this.color = AppColors.white,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
    );
  }
}
