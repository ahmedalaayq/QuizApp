import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/core/features/on_boarding/models/custom_page_view_model.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/widgets/height_spacing.dart';
class CustomPageView extends StatelessWidget {
  const CustomPageView({super.key, required this.customPage});
  final CustomPageViewModel customPage ;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeightSpacing(115.h),
          SvgPicture.asset(
            width: 227.w,
            height: 398.h,
            customPage.image,
          ),
          HeightSpacing(108.h),
          Text(
            customPage.title,
            style: AppTextStyles.montserrat32w600.copyWith(color: Colors.black),
          ),
          HeightSpacing(24.h),
          SizedBox(
            width: 312.w,
            height:97.h ,
            child: Text(
              textAlign: TextAlign.center,
              customPage.subTitle,
              style: AppTextStyles.montserrat21w400.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );
    
  }
}
