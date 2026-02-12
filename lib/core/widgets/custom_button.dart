import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.buttonName,
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.size,
    this.radiusValue,
    this.buttonTextStyle,
    this.isGradient = false,
  });

  final VoidCallback? onPressed;
  final String buttonName;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? overlayColor;
  final Size? size;
  final double? radiusValue;
  final TextStyle? buttonTextStyle;
  final bool isGradient;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = 0.97);
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => setState(() => _scale = 1.0),
        child: Container(
          width: widget.size?.width ?? 350.w,
          height: widget.size?.height ?? 60.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radiusValue?.r ?? 16.r),
            gradient:
                widget.isGradient && !isDisabled
                    ? const LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color:
                widget.isGradient
                    ? null
                    : isDisabled
                    ? AppColors.greyMediumColor
                    : widget.backgroundColor ?? AppColors.primaryColor,
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                widget.radiusValue?.r ?? 16.r,
              ),
              onTap: widget.onPressed,
              overlayColor: WidgetStateProperty.all(
                widget.overlayColor ?? Colors.white.withOpacity(0.08),
              ),
              child: Center(
                child: Text(
                  widget.buttonName,
                  style:
                      widget.buttonTextStyle ??
                      TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.foregroundColor ?? AppColors.whiteColor,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
