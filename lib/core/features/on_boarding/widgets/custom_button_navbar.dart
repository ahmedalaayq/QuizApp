import 'package:flutter/material.dart';
import 'package:quiz_app/core/features/on_boarding/controller/on_boarding_controller.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_dots_indicator.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_text_button.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.nextStreamOutputData,
    required this.onTapSkip,
    required this.onTapNext,
    required this.onTapDots,
    required this.dotsCount,
  });
  final Stream<int> nextStreamOutputData;
  final VoidCallback onTapSkip;
  final VoidCallback onTapNext;
  final Function(int) onTapDots;
  final int dotsCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextButton(
            buttonName: 'Skip',
            onPressed: onTapSkip,
            buttonTextStyle: AppTextStyles.montserrat15w400,
          ),
          CustomDotsIndicator(
            dotsCount: dotsCount,
            dotsStream:
                OnBoardingController.onBoardingController.dotsOutputData,
            onTapDots: (position) => onTapDots(position),
          ),
          StreamBuilder<int>(
            initialData: 0,
            stream: nextStreamOutputData,
            builder: (context, snapshot) {
              return CustomTextButton(
                buttonName:
                    snapshot.data == null
                        ? 'Next'
                        : snapshot.data == dotsCount - 1
                        ? 'Start'
                        : 'Next',
                onPressed: onTapNext,
              );
            },
          ),
        ],
      ),
    );
  }
}
