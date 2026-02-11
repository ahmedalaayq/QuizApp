import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/maintenance_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class MaintenanceView extends StatefulWidget {
  const MaintenanceView({super.key});

  @override
  State<MaintenanceView> createState() => _MaintenanceViewState();
}

class _MaintenanceViewState extends State<MaintenanceView> {
  late MaintenanceService maintenanceService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    try {
      // Try to get existing service first
      if (Get.isRegistered<MaintenanceService>()) {
        maintenanceService = Get.find<MaintenanceService>();
      } else {
        maintenanceService = Get.put(MaintenanceService());
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // If there's an error, create a new service
      maintenanceService = Get.put(MaintenanceService(), permanent: true);
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (maintenanceService.isLoading.value) {
            return _buildLoadingState();
          }

          if (!maintenanceService.isMaintenanceMode.value) {
            // If maintenance mode is off, navigate to splash
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(AppRoutes.splashView);
            });
            return const SizedBox.shrink();
          }

          return _buildMaintenanceContent();
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري التحقق من حالة النظام...',
            style: AppTextStyles.cairo16w600.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceContent() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated maintenance icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withValues(alpha: 0.1),
                          AppColors.primaryColor.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.construction,
                      size: 80.r,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40.h),

            // Animated title
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      'التطبيق قيد الصيانة',
                      style: AppTextStyles.cairo24w700.copyWith(
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),

            // Animated message
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      maintenanceService.maintenanceMessage.value,
                      style: AppTextStyles.cairo16w700.copyWith(
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40.h),

            // Animated info card
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1400),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.blue.shade100.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 32.r,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'نعمل على تحسين التطبيق لتقديم أفضل تجربة لك',
                            style: AppTextStyles.cairo14w400.copyWith(
                              color: Colors.blue[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'سنعود قريباً!',
                            style: AppTextStyles.cairo14w600.copyWith(
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 40.h),

            // Animated refresh button
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1600),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: ElevatedButton.icon(
                      onPressed: () => _refreshWithAnimation(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 16.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primaryColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _refreshWithAnimation() async {
    // Show loading animation
    setState(() {});

    try {
      await maintenanceService.refreshMaintenanceStatus();
    } catch (e) {
      // Handle error gracefully
      Get.snackbar(
        'خطأ',
        'فشل في التحقق من حالة الصيانة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
