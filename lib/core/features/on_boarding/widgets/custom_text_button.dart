import 'package:flutter/material.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.buttonName,
    required this.onPressed, this.buttonTextStyle,

  });
  final String buttonName;
  final VoidCallback onPressed;
  final TextStyle? buttonTextStyle;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        overlayColor: AppColors.secondaryColor,
        foregroundColor: AppColors.secondaryColor),
      onPressed: onPressed,
      child: Text(buttonName, style: buttonTextStyle ?? AppTextStyles.montserrat15w600),
    );
  }
}
