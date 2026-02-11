import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 2,
      shadowColor: AppColors.primaryColor.withOpacity(0.3),
      title: Text(
        'منصة التقييم النفسي',
        style: AppTextStyles.cairo20w700.copyWith(
          color: AppColors.whiteColor,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.people,
            color: AppColors.whiteColor,
            size: 24.r,
          ),
          tooltip: 'تقييم الطلاب',
          onPressed: () {
            Get.toNamed('/student-rating');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
