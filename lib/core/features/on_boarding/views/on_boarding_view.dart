import 'package:flutter/material.dart';
import 'package:quiz_app/core/features/on_boarding/controller/on_boarding_controller.dart';
import 'package:quiz_app/core/features/on_boarding/models/custom_page_view_model.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_dots_indicator.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_page_view.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_text_button.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  @override
  void dispose() {
    OnBoardingController.onBoardingController.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SizedBox(
        width: 90,
        height: 90,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //! Custom Text Button
            CustomTextButton(
              buttonName: 'Skip',
              onPressed: () {},
              buttonTextStyle: AppTextStyles.montserrat15w400,
            ),
            CustomDotsIndicator(
              dotsStream:
                  OnBoardingController.onBoardingController.dotsOutputData,
              onTapDots:
                  (position) => OnBoardingController.onBoardingController
                      .onTapDotsIndicator(position),
            ),
            CustomTextButton(
              buttonName: 'Next',
              onPressed:
                  OnBoardingController.onBoardingController.onTapNextButton,
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: OnBoardingController.onBoardingController.pageController,
        onPageChanged:
            (index) => OnBoardingController.onBoardingController
                .onTapDotsIndicator(index),
        itemBuilder: (context, index) {
          return CustomPageView(
            customPage:
                OnBoardingController.onBoardingController.customPageList[index],
          );
        },
        itemCount:
            OnBoardingController.onBoardingController.customPageList.length,
      ),
    );
  }
}
