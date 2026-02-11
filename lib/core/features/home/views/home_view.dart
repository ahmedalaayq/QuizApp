import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/connectivity_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/features/home/widgets/home_app_bar.dart';
import 'package:quiz_app/core/features/home/widgets/home_assessment_card.dart';
import 'package:quiz_app/core/features/home/widgets/home_features_section.dart';
import 'package:quiz_app/core/features/home/widgets/home_section_title.dart';
import 'package:quiz_app/core/features/home/widgets/home_welcome_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final connectivityService = Get.find<ConnectivityService>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.backgroundColor,
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _refreshHomeData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Banner
              Obx(
                () =>
                    !connectivityService.isConnected.value
                        ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wifi_off,
                                color: Colors.orange,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'وضع عدم الاتصال - بعض الميزات قد لا تعمل',
                                  style: AppTextStyles.cairo12w500.copyWith(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
              ),

              // User Welcome
              Obx(
                () =>
                    authService.isLoggedIn.value
                        ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isDarkMode
                                      ? [
                                        const Color(0xFF1E2A3A),
                                        const Color(0xFF2D3748),
                                      ]
                                      : [
                                        AppColors.primaryColor.withValues(
                                          alpha: 0.05,
                                        ),
                                        AppColors.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? const Color(0xFF4A5568)
                                      : AppColors.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isDarkMode
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.primaryColor.withValues(
                                        alpha: 0.8,
                                      ),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28.r,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مرحباً، ${authService.currentUserName.isNotEmpty ? authService.currentUserName : "المستخدم"}',
                                      style: AppTextStyles.cairo18w700.copyWith(
                                        color:
                                            isDarkMode
                                                ? const Color(0xFFF7FAFC)
                                                : AppColors.primaryDark,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getRoleColor(
                                          authService,
                                        ).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Obx(
                                        () => Text(
                                          authService.isSuperAdmin
                                              ? 'مدير عام'
                                              : authService.isAdmin
                                              ? 'مدير النظام'
                                              : authService.isTherapist
                                              ? 'معالج نفسي'
                                              : 'طالب',
                                          style: AppTextStyles.cairo12w600
                                              .copyWith(
                                                color: _getRoleColor(
                                                  authService,
                                                ),
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  // Refresh Role Button (for testing)
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.blue.withValues(alpha: 0.1),
                                  //     borderRadius: BorderRadius.circular(8.r),
                                  //   ),
                                  //   child: IconButton(
                                  //     onPressed: () async {
                                  //       await authService.refreshUserRole();
                                  //       Get.snackbar(
                                  //         'تم',
                                  //         'تم إعادة تحميل دور المستخدم',
                                  //         backgroundColor: Colors.green,
                                  //         colorText: Colors.white,
                                  //       );
                                  //     },
                                  //     icon: Icon(
                                  //       Icons.refresh,
                                  //       color: Colors.blue,
                                  //       size: 18.r,
                                  //     ),
                                  //     tooltip: 'إعادة تحميل الدور',
                                  //   ),
                                  // ),
                                  SizedBox(width: 8.w),
                                  // Logout Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: IconButton(
                                      onPressed: () => authService.signOut(),
                                      icon: Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                        size: 20.r,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : const HomeWelcomeCard(),
              ),

              SizedBox(height: 24.h),

              // Quick Actions
              _buildQuickActions(isDarkMode),
              SizedBox(height: 32.h),

              const HomeSectionTitle(title: 'الاختبارات المتاحة'),
              SizedBox(height: 16.h),

              HomeAssessmentCard(
                title: 'مقياس الاكتئاب والقلق والإجهاد',
                subtitle: 'DASS-21',
                description: 'قياس مستويات الاكتئاب والقلق والإجهاد لديك',
                icon: Icons.psychology,
                color: AppColors.goodColor,
                questions: '21 سؤال',
                onTap: () => Get.toNamed('/assessments-list'),
              ),
              SizedBox(height: 16.h),

              HomeAssessmentCard(
                title: 'مقياس التوحد',
                subtitle: 'Autism Spectrum Screening',
                description: 'تقييم خصائص طيف التوحد والتواصل الاجتماعي',
                icon: Icons.psychology,
                color: AppColors.warningColor,
                questions: '10 أسئلة',
                onTap: () => Get.toNamed('/assessments-list'),
              ),
              SizedBox(height: 32.h),

              const HomeFeaturesSection(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDarkMode) {
    final authService = Get.find<AuthService>();

    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.bar_chart,
            title: 'الإحصائيات',
            color: Colors.blue,
            isDarkMode: isDarkMode,
            onTap: () => Get.toNamed(AppRoutes.statistics),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.emoji_events,
            title: 'الإنجازات',
            color: Colors.amber,
            isDarkMode: isDarkMode,
            onTap: () => Get.toNamed(AppRoutes.achievements),
          ),
        ),
        SizedBox(width: 12.w),
        // Show admin panel for SuperAdmin, Admin, and Therapist with reactive updates
        Obx(() {
          if (authService.isSuperAdmin ||
              authService.isAdmin ||
              authService.isTherapist) {
            return Expanded(
              child: _buildQuickActionCard(
                icon: Icons.admin_panel_settings,
                title: 'لوحة التحكم',
                color: authService.isSuperAdmin ? Colors.purple : Colors.red,
                isDarkMode: isDarkMode,
                onTap: () => Get.toNamed(AppRoutes.adminPanel),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        // Add spacing only if admin panel is shown with reactive updates
        Obx(() {
          if (authService.isSuperAdmin ||
              authService.isAdmin ||
              authService.isTherapist) {
            return SizedBox(width: 12.w);
          }
          return const SizedBox.shrink();
        }),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.settings,
            title: 'الإعدادات',
            color: Colors.grey,
            isDarkMode: isDarkMode,
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                isDarkMode
                    ? const Color(0xFF4A5568)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24.r),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: AppTextStyles.cairo12w600.copyWith(
                color:
                    isDarkMode
                        ? const Color(0xFFF7FAFC)
                        : AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(AuthService authService) {
    if (authService.isSuperAdmin) return Colors.purple;
    if (authService.isAdmin) return Colors.red;
    if (authService.isTherapist) return Colors.orange;
    return AppColors.excellentColor.withValues(alpha: 0.5);
  }

  Future<void> _refreshHomeData() async {
    final authService = Get.find<AuthService>();
    final connectivityService = Get.find<ConnectivityService>();

    try {
      // Refresh connectivity status
      await connectivityService.checkConnection();

      // Refresh user role from Firestore
      await authService.refreshUserRole();

      // Show success message
      Get.snackbar(
        'تم التحديث',
        'تم تحديث بيانات الصفحة الرئيسية بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'خطأ',
        'فشل في تحديث البيانات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
