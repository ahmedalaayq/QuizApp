import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

/// Reusable Card Component
class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation ?? 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Reusable Button Component
class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryColor,
        padding:
            padding ?? EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
      ),
      icon:
          isLoading
              ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.whiteColor,
                  ),
                  strokeWidth: 2,
                ),
              )
              : icon != null
              ? Icon(icon, color: textColor ?? AppColors.whiteColor)
              : SizedBox.shrink(),
      label: Text(
        label,
        style:
            textStyle ??
            AppTextStyles.cairo14w600.copyWith(
              color: textColor ?? AppColors.whiteColor,
            ),
      ),
    );

    return isFullWidth ? SizedBox.expand(child: button) : button;
  }
}

/// Reusable Input Field
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final Color? backgroundColor;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cairo12w600),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.cairo12w400.copyWith(color: Colors.grey),
            filled: true,
            fillColor: backgroundColor ?? Colors.grey[100],
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon:
                suffixIcon != null
                    ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Progress Indicator
class CustomProgressBar extends StatelessWidget {
  final double value;
  final String? label;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.label,
    this.backgroundColor,
    this.valueColor,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label!, style: AppTextStyles.cairo12w600),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.cairo12w600.copyWith(
                  color: valueColor ?? AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: value,
            minHeight: height.h,
            backgroundColor: backgroundColor ?? Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Score Display Card
class ScoreCard extends StatelessWidget {
  final String title;
  final int score;
  final int maxScore;
  final Color? cardColor;
  final String? subtitle;

  const ScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.maxScore,
    this.cardColor,
    this.subtitle,
  });

  Color _getColorByScore(double percentage) {
    if (percentage < 0.25) return Colors.green;
    if (percentage < 0.5) return Colors.amber;
    if (percentage < 0.75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = score / maxScore;
    final scoreColor = _getColorByScore(percentage);

    return CustomCard(
      backgroundColor: cardColor ?? scoreColor.withOpacity(0.1),
      border: Border.all(color: scoreColor, width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cairo14w600),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: AppTextStyles.cairo12w400.copyWith(color: Colors.grey),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$score / $maxScore',
                style: AppTextStyles.cairo18w600.copyWith(color: scoreColor),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: AppTextStyles.cairo14w600.copyWith(color: scoreColor),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CustomProgressBar(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: scoreColor,
            height: 6,
          ),
        ],
      ),
    );
  }
}

/// Reusable List Item
class CustomListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const CustomListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              if (leading != null) ...[leading!, SizedBox(width: 12.w)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cairo14w600),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: AppTextStyles.cairo12w400.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable Alert Dialog
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.cairo16w700),
      content: Text(message, style: AppTextStyles.cairo14w400),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: Text(cancelText!, style: AppTextStyles.cairo12w600),
          ),
        TextButton(
          onPressed: onConfirm ?? () => Navigator.pop(context),
          child: Text(
            confirmText!,
            style: AppTextStyles.cairo12w600.copyWith(
              color: confirmColor ?? AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Responsive Spacing Helper
class ResponsiveSpacing {
  static EdgeInsetsGeometry padding(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    return EdgeInsets.symmetric(
      horizontal: isSmall ? 16.w : 24.w,
      vertical: isSmall ? 12.h : 20.h,
    );
  }

  static double horizontalPadding(BuildContext context) {
    return MediaQuery.of(context).size.width < 600 ? 16.w : 24.w;
  }

  static double verticalPadding(BuildContext context) {
    return MediaQuery.of(context).size.width < 600 ? 12.h : 20.h;
  }
}
