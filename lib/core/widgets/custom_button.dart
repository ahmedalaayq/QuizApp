import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    this.buttonName,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.radiusValue, this.buttonTextStyle, this.overlayColor,
  });
  final VoidCallback? onPressed;
  final String? buttonName;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? overlayColor;
  final Size? size;
  final double? radiusValue;
  final TextStyle? buttonTextStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        elevation: 5,
        overlayColor: overlayColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusValue?.r ?? 20),
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        foregroundColor: foregroundColor ?? AppColors.whiteColor,
        minimumSize: size ?? Size(350.w, 70.h),
      ),
      onPressed: onPressed,
      child: Text(buttonName ?? "",style: buttonTextStyle,),
    );
  }
}
