import 'package:myuwi/Values/AppValues.dart';
import 'package:myuwi/Widgets/AppSpaces.dart';
import 'package:flutter/material.dart';

class AppCustomButton extends StatelessWidget {
  AppCustomButton({
    this.title,
    this.onPressed,
//    this.width = Sizes.WIDTH_150,
    this.height = AppSizes.HEIGHT_50,
    this.elevation = AppSizes.ELEVATION_1,
    this.borderRadius = AppSizes.RADIUS_24,
    this.color = AppColors.blackShade5,
    this.borderSide = AppBorders.defaultPrimaryBorder,
    this.textStyle,
    this.icon,
    this.hasIcon = false,
  });

  final VoidCallback onPressed;
//  final double width;
  final double height;
  final double elevation;
  final double borderRadius;
  final String title;
  final Color color;
  final BorderSide borderSide;
  final TextStyle textStyle;
  final Widget icon;
  final bool hasIcon;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: elevation,
//      minWidth: width ?? MediaQuery.of(context).size.width,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderSide,
      ),

      height: height,
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          hasIcon ? icon : Container(),
          hasIcon ? SpaceW8() : Container(),
          title != null
              ? Text(
                  title,
                  style: textStyle,
                )
              : Container(),
        ],
      ),
    );
  }
}
