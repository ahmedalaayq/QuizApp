import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class CustomRadioTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String title;
  final String? subtitle;
  final Color? activeColor;

  const CustomRadioTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == groupValue;
    final color = activeColor ?? AppColors.primaryColor;

    return InkWell(
      onTap: () => onChanged?.call(value),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cairo14w500.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.cairo12w400.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
