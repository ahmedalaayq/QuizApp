import 'package:flutter/material.dart';
import 'package:quiz_app/core/features/on_boarding/controller/on_boarding_controller.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_button_navbar.dart';
import 'package:quiz_app/core/features/on_boarding/widgets/custom_page_view.dart';

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

      bottomNavigationBar: CustomBottomNavBar(
        dotsCount: 3,
        nextStreamOutputData:
            OnBoardingController.onBoardingController.nextBtnOutputData,
        onTapDots:
            (position) => OnBoardingController.onBoardingController
                .onTapDotsIndicator(position),
        onTapNext: OnBoardingController.onBoardingController.onTapNextButton,
        onTapSkip: () {},
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
