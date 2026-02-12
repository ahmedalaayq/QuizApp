import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/features/admin/controller/admin_controller.dart';
import 'package:quiz_app/core/features/assessment/views/user_assessment_details_view.dart';
import 'package:quiz_app/core/services/auth_service.dart';
import 'package:quiz_app/core/services/super_admin_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';
import 'package:quiz_app/core/widgets/error_widgets.dart';

class AdminUsersTab extends StatelessWidget {
  final AdminController controller;
  final bool isDarkMode;

  // Focus nodes for search field
  final _searchFocus = FocusNode();

  AdminUsersTab({
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
          // Users Header with Actions
          _buildUsersHeader(),
          SizedBox(height: 16.h),

          // Search and Filter Bar
          _buildSearchAndFilter(),
          SizedBox(height: 16.h),

          // Users Statistics
          _buildUsersStatistics(),
          SizedBox(height: 16.h),

          // Users List
          _buildUsersList(),
        ],
      ),
    );
  }

  Widget _buildUsersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'إدارة المستخدمين',
            style: AppTextStyles.cairo18w700.copyWith(
              color: isDarkMode ? Colors.white : AppColors.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        ElevatedButton.icon(
          onPressed: () => _showAddUserDialog(),
          icon: Icon(Icons.add, size: 18.r),
          label: const Text('إضافة مستخدم'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          // Stack vertically on small screens
          return Column(
            children: [
              _buildSearchField(),
              SizedBox(height: 12.h),
              _buildRoleFilter(),
            ],
          );
        } else {
          // Side by side on larger screens
          return Row(
            children: [
              Expanded(flex: 3, child: _buildSearchField()),
              SizedBox(width: 12.w),
              Expanded(child: _buildRoleFilter()),
            ],
          );
        }
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      focusNode: _searchFocus,
      onChanged: (value) => controller.searchUsers(value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'البحث عن مستخدم...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2D3748) : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildRoleFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2D3748) : Colors.grey.shade100,
      ),
      hint: const Text('الدور'),
      items:
          ['الكل', 'طالب', 'معالج', 'مدير'].map((role) {
            return DropdownMenuItem(value: role, child: Text(role));
          }).toList(),
      onChanged: (value) {
        // Filter by role logic
      },
    );
  }

  Widget _buildUsersStatistics() {
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isDarkMode
                  ? const Color(0xFF4A5568)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 400) {
            // Stack in 2x2 grid on small screens
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'الطلاب',
                      '${controller.students.value}',
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'المعالجين',
                      '${controller.therapists.value}',
                      Colors.orange,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'المديرين',
                      '${controller.admins.value}',
                      Colors.red,
                    ),
                    _buildStatItem(
                      'النشطين',
                      '${controller.activeUserPercentage.toStringAsFixed(0)}%',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Single row on larger screens
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'الطلاب',
                  '${controller.students.value}',
                  Colors.blue,
                ),
                _buildStatItem(
                  'المعالجين',
                  '${controller.therapists.value}',
                  Colors.orange,
                ),
                _buildStatItem(
                  'المديرين',
                  '${controller.admins.value}',
                  Colors.red,
                ),
                _buildStatItem(
                  'النشطين',
                  '${controller.activeUserPercentage.toStringAsFixed(0)}%',
                  Colors.green,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Flexible(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.cairo18w700.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.cairo12w500.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Obx(() {
      if (controller.filteredUsers.isEmpty) {
        return const EmptyStateWidget(
          title: 'لا يوجد مستخدمين',
          message: 'لم يتم العثور على أي مستخدمين',
          icon: Icons.people_outline,
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredUsers.length,
        itemBuilder: (context, index) {
          final user = controller.filteredUsers[index];
          return _buildUserTile(user);
        },
      );
    });
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final isActive = user['isActive'] ?? true;
    final role = user['role'] ?? 'student';

    return AnimatedCard(
      onTap: () {
        // Navigate to user details
        final userId = user['uid'] ?? user['id'] ?? '';
        final userName = user['name'] ?? 'مستخدم غير معروف';

        if (userId.isNotEmpty) {
          Get.to(
            () => UserAssessmentDetailsView(userId: userId, userName: userName),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        } else {
          Get.snackbar(
            'خطأ',
            'معرف المستخدم غير صحيح',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(role).withValues(alpha: 0.2),
                  child: Icon(
                    _getRoleIcon(role),
                    color: _getRoleColor(role),
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'غير محدد',
                        style: AppTextStyles.cairo14w600.copyWith(
                          color:
                              isDarkMode ? Colors.white : AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user['email'] ?? '',
                        style: AppTextStyles.cairo12w400.copyWith(
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getRoleText(role),
                    style: AppTextStyles.cairo10w600.copyWith(
                      color: _getRoleColor(role),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.check_circle : Icons.cancel,
                        color: isActive ? Colors.green : Colors.red,
                        size: 16.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isActive ? 'نشط' : 'معطل',
                        style: AppTextStyles.cairo12w500.copyWith(
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.r,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'عرض التفاصيل',
                        style: AppTextStyles.cairo10w400.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildUserActions(user, isActive),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActions(Map<String, dynamic> user, bool isActive) {
    final authService = Get.find<AuthService>();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 200) {
          // Use popup menu on small screens
          return PopupMenuButton<String>(
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];

              // View details - available to all
              items.add(
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16.r),
                      SizedBox(width: 8.w),
                      const Text('عرض التفاصيل'),
                    ],
                  ),
                ),
              );

              // Edit - only for admins and superAdmins
              if (authService.isAdmin || authService.isSuperAdmin) {
                items.add(
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16.r),
                        SizedBox(width: 8.w),
                        const Text('تعديل'),
                      ],
                    ),
                  ),
                );
              }

              // Role change - only for admins and superAdmins
              if (authService.isAdmin || authService.isSuperAdmin) {
                items.add(
                  PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 16.r),
                        SizedBox(width: 8.w),
                        const Text('تغيير الدور'),
                      ],
                    ),
                  ),
                );
              }

              // Activate/Deactivate - only for admins and superAdmins
              if (authService.isAdmin || authService.isSuperAdmin) {
                items.add(
                  PopupMenuItem(
                    value: isActive ? 'deactivate' : 'activate',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.block : Icons.check_circle,
                          size: 16.r,
                          color: isActive ? Colors.red : Colors.green,
                        ),
                        SizedBox(width: 8.w),
                        Text(isActive ? 'تعطيل' : 'تفعيل'),
                      ],
                    ),
                  ),
                );
              }

              // Delete - only for superAdmins
              if (authService.isSuperAdmin) {
                items.add(
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16.r, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
          );
        } else {
          // Use icon buttons on larger screens
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View details - available to all
              IconButton(
                onPressed: () => _handleUserAction('view', user),
                icon: Icon(Icons.visibility, size: 18.r, color: Colors.blue),
                tooltip: 'عرض التفاصيل',
              ),

              // Edit - only for admins and superAdmins
              if (authService.isAdmin || authService.isSuperAdmin)
                IconButton(
                  onPressed: () => _handleUserAction('edit', user),
                  icon: Icon(Icons.edit, size: 18.r, color: Colors.blue),
                  tooltip: 'تعديل',
                ),

              // Role change - only for admins and superAdmins
              if (authService.isAdmin || authService.isSuperAdmin)
                IconButton(
                  onPressed: () => _handleUserAction('role', user),
                  icon: Icon(
                    Icons.admin_panel_settings,
                    size: 18.r,
                    color: Colors.orange,
                  ),
                  tooltip: 'تغيير الدور',
                ),

              // Activate/Deactivate - only for admins and superAdmins
              if (authService.isAdmin || authService.isSuperAdmin)
                IconButton(
                  onPressed:
                      () => _handleUserAction(
                        isActive ? 'deactivate' : 'activate',
                        user,
                      ),
                  icon: Icon(
                    isActive ? Icons.block : Icons.check_circle,
                    size: 18.r,
                    color: isActive ? Colors.red : Colors.green,
                  ),
                  tooltip: isActive ? 'تعطيل' : 'تفعيل',
                ),

              // Delete - only for superAdmins
              if (authService.isSuperAdmin)
                IconButton(
                  onPressed: () => _handleUserAction('delete', user),
                  icon: Icon(Icons.delete, size: 18.r, color: Colors.red),
                  tooltip: 'حذف',
                ),
            ],
          );
        }
      },
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'view':
        // Navigate to user details - available to all roles
        final userId = user['uid'] ?? user['id'] ?? '';
        final userName = user['name'] ?? 'مستخدم غير معروف';

        if (userId.isNotEmpty) {
          Get.to(
            () => UserAssessmentDetailsView(userId: userId, userName: userName),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        } else {
          Get.snackbar(
            'خطأ',
            'معرف المستخدم غير صحيح',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'role':
        _showRoleDialog(user);
        break;
      case 'activate':
        controller.toggleUserStatus(user['uid'], true);
        break;
      case 'deactivate':
        controller.toggleUserStatus(user['uid'], false);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showAddUserDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('إضافة مستخدم جديد'),
        content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: const Text('تعديل المستخدم'),
        content: const Text('سيتم تنفيذ هذه الميزة قريباً'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  void _showRoleDialog(Map<String, dynamic> user) {
    // Check if current user is therapist - therapists cannot change roles
    final authService = Get.find<AuthService>();
    if (authService.isTherapist) {
      Get.snackbar(
        'غير مسموح',
        'المعالجين النفسيين لا يمكنهم تغيير أدوار المستخدمين',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    String selectedRole = user['role'] ?? 'student';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تغيير دور المستخدم: ${user['name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('طالب'),
                  leading: Radio<String>(
                    value: 'student',
                    groupValue: selectedRole,
                    onChanged: (value) => setState(() => selectedRole = value!),
                  ),
                ),
                // Only admins and superAdmins can assign therapist role
                if (authService.isAdmin || authService.isSuperAdmin)
                  ListTile(
                    title: const Text('معالج'),
                    leading: Radio<String>(
                      value: 'therapist',
                      groupValue: selectedRole,
                      onChanged:
                          (value) => setState(() => selectedRole = value!),
                    ),
                  ),
                // Only superAdmins can assign admin role
                if (authService.isSuperAdmin)
                  ListTile(
                    title: const Text('مدير'),
                    leading: Radio<String>(
                      value: 'admin',
                      groupValue: selectedRole,
                      onChanged:
                          (value) => setState(() => selectedRole = value!),
                    ),
                  ),
                // Only superAdmins can assign superAdmin role
                if (authService.isSuperAdmin)
                  ListTile(
                    title: const Text('مدير عام'),
                    subtitle: const Text('صلاحيات كاملة للنظام'),
                    leading: Radio<String>(
                      value: 'superAdmin',
                      groupValue: selectedRole,
                      onChanged:
                          (value) => setState(() => selectedRole = value!),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();

                  // Check if changing to SuperAdmin role
                  if (selectedRole == 'superAdmin' &&
                      user['role'] != 'superAdmin') {
                    await _showSuperAdminPasswordDialog(
                      user['uid'],
                      selectedRole,
                    );
                  } else {
                    controller.updateUserRole(user['uid'], selectedRole);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSuperAdminPasswordDialog(
    String userId,
    String newRole,
  ) async {
    final passwordController = TextEditingController();
    final passwordFocus = FocusNode();
    bool isLoading = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.security, color: Colors.purple),
                SizedBox(width: 8.w),
                const Text('تأكيد كلمة مرور المدير العام'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'لتعيين دور "مدير عام"، يرجى إدخال كلمة مرور المدير العام:',
                  style: AppTextStyles.cairo14w400,
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) async {
                    if (passwordController.text.isNotEmpty && !isLoading) {
                      // Trigger the same logic as the confirm button
                      setState(() => isLoading = true);
                      // ... rest of the logic
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                if (isLoading) ...[
                  SizedBox(height: 16.h),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Get.back(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (passwordController.text.isEmpty) {
                            Get.snackbar('خطأ', 'يرجى إدخال كلمة المرور');
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            final isValid =
                                await SuperAdminService.verifySuperAdminPassword(
                                  passwordController.text,
                                );

                            if (isValid) {
                              // Log the action
                              await SuperAdminService.logSuperAdminAction(
                                'role_change',
                                'Changed user role to SuperAdmin',
                                {
                                  'userId': userId,
                                  'newRole': newRole,
                                  'timestamp': DateTime.now().toIso8601String(),
                                },
                              );

                              Get.back();
                              controller.updateUserRole(userId, newRole);

                              Get.snackbar(
                                'نجح',
                                'تم تغيير الدور بنجاح',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'خطأ',
                                'كلمة المرور غير صحيحة',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'خطأ',
                              'حدث خطأ أثناء التحقق: ${e.toString()}',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تأكيد'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user['name']}"؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteUser(user['uid']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
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
        return Icons.security;
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
}
