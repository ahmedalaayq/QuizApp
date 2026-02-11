import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/reusable_components.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Offline Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_off, size: 60.r, color: Colors.grey),
              ),

              SizedBox(height: 32.h),

              Text(
                'لا يوجد اتصال بالإنترنت',
                style: AppTextStyles.cairo24w700.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              Text(
                'يتطلب التطبيق اتصالاً بالإنترنت للعمل بشكل صحيح. يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
                style: AppTextStyles.cairo16w700.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // Connection Status
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Theme.of(context).cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            connectivityService.isConnected.value
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color:
                                connectivityService.isConnected.value
                                    ? Colors.green
                                    : Colors.red,
                            size: 24.r,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حالة الاتصال',
                                  style: AppTextStyles.cairo14w600.copyWith(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : AppColors.primaryDark,
                                  ),
                                ),
                                Text(
                                  connectivityService.isConnected.value
                                      ? 'متصل - ${connectivityService.connectionTypeString}'
                                      : 'غير متصل',
                                  style: AppTextStyles.cairo12w400.copyWith(
                                    color:
                                        connectivityService.isConnected.value
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Retry Button
              CustomElevatedButton(
                label: 'إعادة المحاولة',
                onPressed: () async {
                  final isConnected =
                      await connectivityService.checkConnection();
                  if (isConnected) {
                    Get.offAllNamed(AppRoutes.loginView);
                  } else {
                    Get.snackbar(
                      'لا يوجد اتصال',
                      'لا يزال لا يوجد اتصال بالإنترنت',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: Icons.refresh,
              ),

              SizedBox(height: 16.h),

              // Tips
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue, size: 20.r),
                        SizedBox(width: 8.w),
                        Text(
                          'نصائح للاتصال',
                          style: AppTextStyles.cairo14w600.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '• تأكد من تشغيل WiFi أو البيانات الخلوية\n'
                      '• تحقق من إعدادات الشبكة\n'
                      '• جرب الاتصال بشبكة أخرى\n'
                      '• أعد تشغيل التطبيق',
                      style: AppTextStyles.cairo12w400.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
