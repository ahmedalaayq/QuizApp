import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/features/admin/controller/admin_controller.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';

class AdminDashboardTab extends StatelessWidget {
  final AdminController controller;
  final bool isDarkMode;

  const AdminDashboardTab({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Overview
          _buildQuickStatsGrid(),
          SizedBox(height: 24.h),

          // System Status Cards
          _buildSystemStatusCards(),
          SizedBox(height: 24.h),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 1.3,
          children: [
            _buildDashboardCard(
              'إجمالي المستخدمين',
              '${controller.totalUsers.value}',
              Icons.people,
              AppColors.primaryColor,
            ),
            _buildDashboardCard(
              'المستخدمين النشطين',
              '${controller.activeUsers.value}',
              Icons.person_add_rounded,
              Colors.green,
            ),
            _buildDashboardCard(
              'إجمالي التقييمات',
              '${controller.totalAssessments.value}',
              Icons.assignment,
              Colors.blue,
            ),
            _buildDashboardCard(
              'تقييمات اليوم',
              '${controller.todayAssessments.value}',
              Icons.today,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSystemStatusCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حالة النظام',
          style: AppTextStyles.cairo18w700.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'وضع الصيانة',
                controller.isMaintenanceMode.value ? 'مفعل' : 'معطل',
                controller.isMaintenanceMode.value
                    ? Icons.build
                    : Icons.check_circle,
                controller.isMaintenanceMode.value
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatusCard(
                'إصدار التطبيق',
                controller.appVersion.value,
                Icons.info,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاط الأخير',
          style: AppTextStyles.cairo18w700.copyWith(
            color: isDarkMode ? Colors.white : AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                      : [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color:
                  isDarkMode
                      ? const Color(0xFF4A5568)
                      : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child:
              controller.recentUsers.isEmpty
                  ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48.r,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'لا توجد بيانات مستخدمين',
                            style: AppTextStyles.cairo14w500.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children:
                        controller.recentUsers.map((user) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? const Color(
                                        0xFF1A202C,
                                      ).withValues(alpha: 0.5)
                                      : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: _getRoleColor(
                                  user['role'] ?? 'student',
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                // User Avatar with Role Color
                                Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getRoleColor(
                                          user['role'] ?? 'student',
                                        ),
                                        _getRoleColor(
                                          user['role'] ?? 'student',
                                        ).withValues(alpha: 0.7),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getRoleIcon(user['role'] ?? 'student'),
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              user['name'] ?? 'غير محدد',
                                              style: AppTextStyles.cairo14w600
                                                  .copyWith(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white
                                                            : AppColors
                                                                .primaryDark,
                                                  ),
                                            ),
                                          ),
                                          // Role Badge
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getRoleColor(
                                                user['role'] ?? 'student',
                                              ).withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: _getRoleColor(
                                                  user['role'] ?? 'student',
                                                ).withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Text(
                                              _getRoleText(
                                                user['role'] ?? 'student',
                                              ),
                                              style: AppTextStyles.cairo10w600
                                                  .copyWith(
                                                    color: _getRoleColor(
                                                      user['role'] ?? 'student',
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            size: 14.r,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              user['email'] ?? 'غير محدد',
                                              style: AppTextStyles.cairo12w400
                                                  .copyWith(color: Colors.grey),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14.r,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            _getLastActivityText(user),
                                            style: AppTextStyles.cairo11w400
                                                .copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Status Indicator
                                Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color:
                                        user['isActive'] == true
                                            ? Colors.green
                                            : Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (user['isActive'] == true
                                                ? Colors.green
                                                : Colors.red)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedCard(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                    : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.r),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cairo12w400.copyWith(
                    color:
                        isDarkMode ? const Color(0xFFA0AEC0) : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.cairo18w700.copyWith(
                    color: isDarkMode ? const Color(0xFFF7FAFC) : color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkMode
                  ? [const Color(0xFF2D3748), const Color(0xFF1A202C)]
                  : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isDarkMode
                  ? const Color(0xFF4A5568)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cairo12w500.copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'superAdmin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'therapist':
        return Colors.orange;
      case 'student':
      default:
        return AppColors.primaryColor;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'superAdmin':
        return Icons.supervisor_account;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'therapist':
        return Icons.psychology;
      case 'student':
      default:
        return Icons.school;
    }
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'superAdmin':
        return 'مدير عام';
      case 'admin':
        return 'مدير';
      case 'therapist':
        return 'معالج';
      case 'student':
      default:
        return 'طالب';
    }
  }

  String _getLastActivityText(Map<String, dynamic> user) {
    try {
      // Check for lastLoginAt first
      if (user['lastLoginAt'] != null) {
        final lastLogin = user['lastLoginAt'];
        if (lastLogin is Timestamp) {
          final loginTime = lastLogin.toDate();
          final now = DateTime.now();
          final difference = now.difference(loginTime);

          if (difference.inMinutes < 60) {
            return 'منذ ${difference.inMinutes} دقيقة';
          } else if (difference.inHours < 24) {
            return 'منذ ${difference.inHours} ساعة';
          } else {
            return 'منذ ${difference.inDays} يوم';
          }
        } else if (lastLogin is String) {
          try {
            final loginTime = DateTime.parse(lastLogin);
            final now = DateTime.now();
            final difference = now.difference(loginTime);

            if (difference.inMinutes < 60) {
              return 'منذ ${difference.inMinutes} دقيقة';
            } else if (difference.inHours < 24) {
              return 'منذ ${difference.inHours} ساعة';
            } else {
              return 'منذ ${difference.inDays} يوم';
            }
          } catch (e) {
            // Fall through to createdAt
          }
        }
      }

      // Fall back to createdAt
      if (user['createdAt'] != null) {
        final created = user['createdAt'];
        if (created is Timestamp) {
          final createdTime = created.toDate();
          final now = DateTime.now();
          final difference = now.difference(createdTime);

          if (difference.inDays < 1) {
            return 'انضم اليوم';
          } else if (difference.inDays < 7) {
            return 'انضم منذ ${difference.inDays} يوم';
          } else {
            return 'انضم منذ ${(difference.inDays / 7).floor()} أسبوع';
          }
        } else if (created is String) {
          try {
            final createdTime = DateTime.parse(created);
            final now = DateTime.now();
            final difference = now.difference(createdTime);

            if (difference.inDays < 1) {
              return 'انضم اليوم';
            } else if (difference.inDays < 7) {
              return 'انضم منذ ${difference.inDays} يوم';
            } else {
              return 'انضم منذ ${(difference.inDays / 7).floor()} أسبوع';
            }
          } catch (e) {
            return 'انضم حديثاً';
          }
        }
      }

      return 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }
}
