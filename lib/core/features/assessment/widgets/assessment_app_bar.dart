import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AssessmentAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 2,
      shadowColor: AppColors.primaryColor.withOpacity(0.3),
      title: Text(
        title,
        style: AppTextStyles.cairo18w700.copyWith(
          color: AppColors.whiteColor,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
        onPressed: () => Get.back(),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
