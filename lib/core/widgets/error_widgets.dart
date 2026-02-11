import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              AnimatedCard(
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon ?? Icons.error_outline,
                    color: Colors.red,
                    size: 60.r,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Title
              AnimatedCard(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  title,
                  style: AppTextStyles.cairo20w700.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16.h),

              // Message
              AnimatedCard(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  message,
                  style: AppTextStyles.cairo14w400.copyWith(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 40.h),

              // Action Button
              if (actionText != null && onAction != null)
                AnimatedCard(
                  delay: const Duration(milliseconds: 600),
                  child: AnimatedButton(
                    text: actionText!,
                    onPressed: onAction,
                    icon: Icons.refresh,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80.r, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد اتصال بالإنترنت',
              style: AppTextStyles.cairo16w700.copyWith(
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
              style: AppTextStyles.cairo14w400.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              AnimatedButton(
                text: 'إعادة المحاولة',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const LoadingErrorWidget({
    super.key,
    this.message = 'حدث خطأ أثناء تحميل البيانات',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.r, color: Colors.orange),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTextStyles.cairo14w500.copyWith(
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 18.r),
                label: Text('إعادة المحاولة'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80.r, color: Colors.grey[400]),
            SizedBox(height: 24.h),
            Text(
              title,
              style: AppTextStyles.cairo18w700.copyWith(
                color: isDarkMode ? Colors.white : AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTextStyles.cairo14w400.copyWith(
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24.h),
              AnimatedButton(text: actionText!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

class ValidationErrorWidget extends StatelessWidget {
  final List<String> errors;

  const ValidationErrorWidget({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20.r),
              SizedBox(width: 8.w),
              Text(
                'يرجى تصحيح الأخطاء التالية:',
                style: AppTextStyles.cairo14w600.copyWith(color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...errors.map(
            (error) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: AppTextStyles.cairo12w500.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      error,
                      style: AppTextStyles.cairo12w500.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
