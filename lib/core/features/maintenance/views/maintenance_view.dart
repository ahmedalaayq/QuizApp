import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/maintenance_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/error_widgets.dart';
import 'package:quiz_app/core/services/logger_service.dart';

class MaintenanceView extends StatefulWidget {
  const MaintenanceView({super.key});

  @override
  State<MaintenanceView> createState() => _MaintenanceViewState();
}

class _MaintenanceViewState extends State<MaintenanceView> {
  late final MaintenanceService maintenanceService;

  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  Worker? _maintenanceWorker;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    try {
      if (Get.isRegistered<MaintenanceService>()) {
        maintenanceService = Get.find<MaintenanceService>();
      } else {
        maintenanceService = Get.put(MaintenanceService(), permanent: true);
      }

      _listenToMaintenance();

      setState(() {
        _isInitialized = true;
        _hasError = false;
        _errorMessage = '';
      });
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error initializing maintenance service',
        e,
        stackTrace,
      );

      setState(() {
        _hasError = true;
        _errorMessage = 'فشل في تهيئة خدمة الصيانة';
      });
    }
  }

  void _listenToMaintenance() {
    _maintenanceWorker?.dispose();

    _maintenanceWorker = ever<bool>(
      maintenanceService.isMaintenanceMode,
      (isMaintenance) {
        if (!isMaintenance) {
          Get.offAllNamed(AppRoutes.splashView);
        }
      },
    );
  }

  @override
  void dispose() {
    _maintenanceWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: ErrorScreen(
          title: 'خطأ في خدمة الصيانة',
          message: _errorMessage,
          actionText: 'إعادة المحاولة',
          onAction: _initializeService,
        ),
      );
    }

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
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
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
            Icon(
              Icons.construction,
              size: 100.r,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 30.h),
            Text(
              'التطبيق قيد الصيانة',
              style: AppTextStyles.cairo24w700.copyWith(
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Obx(() => Text(
                  maintenanceService.maintenanceMessage.value,
                  style: AppTextStyles.cairo16w700.copyWith(
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                )),
            SizedBox(height: 40.h),
            ElevatedButton.icon(
              onPressed: _refreshStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 14.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshStatus() async {
    try {
      await maintenanceService.refreshMaintenanceStatus();
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error refreshing maintenance status',
        e,
        stackTrace,
      );

      Get.snackbar(
        'خطأ',
        'فشل في التحقق من حالة الصيانة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
