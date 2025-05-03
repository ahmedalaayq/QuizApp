import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';

class CustomDotsIndicator extends StatelessWidget {
  const CustomDotsIndicator({
    super.key,
    required this.dotsStream,
    required this.onTapDots, required this.dotsCount,
  });
  final Stream<int> dotsStream;
  final Function(int) onTapDots;
  final int dotsCount;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dotsStream,
      builder: (context, snapshot) {
        return DotsIndicator(
          onTap: (position) => onTapDots(position),
          position: snapshot.data?.toDouble() ?? 0,
          dotsCount: dotsCount,
          decorator: DotsDecorator(
            color: AppColors.greyColor,
            activeColor: AppColors.secondaryColor,
            size: Size(12.w, 12.h),
            activeSize: Size(12.w, 12.h),
            spacing: EdgeInsets.symmetric(horizontal: 8.sp),
          ),
        );
      },
    );
  }
}
