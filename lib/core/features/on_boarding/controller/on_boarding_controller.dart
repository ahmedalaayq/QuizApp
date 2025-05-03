import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:quiz_app/core/app_assets/app_assets.dart';
import 'package:quiz_app/core/features/on_boarding/models/custom_page_view_model.dart';

class OnBoardingController {
  OnBoardingController() {
    _dotsStreamController = StreamController<int>.broadcast();
    _dotsInputData = _dotsStreamController.sink;
    _dotsOutputData = _dotsStreamController.stream;
    _dotsInputData.add(_currentDotIndex);
    _pageController = PageController(initialPage: _currentDotIndex);
    pageCurve = Curves.easeInOut;

    // _pageStreamController = StreamController<bool>.broadcast();
    // _pageInputData = _pageStreamController.sink;
    // _pageOutputData = _pageStreamController.stream;
    // _pageInputData.add(isPageChanged);
  }
  static OnBoardingController onBoardingController = OnBoardingController();
  int _currentDotIndex = 0;
  bool isPageChanged = false;

  int get currentDotIndex => _currentDotIndex;

  late StreamController<int> _dotsStreamController;
  late Sink<int> _dotsInputData;
  late Stream<int> _dotsOutputData;
  Stream<int> get dotsOutputData => _dotsOutputData;
  late PageController _pageController;
  PageController get pageController => _pageController;
  late Curve pageCurve;

  // late StreamController<bool> _pageStreamController;
  // late Sink<bool> _pageInputData;
  // late Stream<bool> _pageOutputData;
  // Stream<bool> get pageOutputData => _pageOutputData;

  List<CustomPageViewModel> customPageList = [
    CustomPageViewModel(
      title: 'Synonyms for QUIZ',
      subTitle: 'Synonyms for QUIZ',
      image: AppAssets.assetsImagesOnboardingOne,
    ),
    CustomPageViewModel(
      title: 'Antonyms of QUIZ',
      subTitle:
          'Sunt in culpa qui officia\n deserunt mollit anim id\nest laborum.',
      image: AppAssets.assetsImagesOnboardingTwo,
    ),
    CustomPageViewModel(
      title: 'Cool Quiz',
      subTitle: 'Culpa qui officia deserunt\n mollit anim id est laborum.',
      image: AppAssets.assetsImagesOnboardingThree,
    ),
  ];

  void onTapDotsIndicator(int position) {
    _currentDotIndex = position;
    _dotsInputData.add(_currentDotIndex);
    _pageController.animateToPage(
      curve: pageCurve,
      _currentDotIndex,
      duration: Duration(milliseconds: 400),
    );
  }

  void onTapNextButton() {
    final int maxDots = customPageList.length;
    currentDotIndex < maxDots - 1 ? _currentDotIndex++ : null;
    _dotsInputData.add(_currentDotIndex);
    _pageController.animateToPage(
      _currentDotIndex,
      duration: Duration(milliseconds: 500),
      curve: pageCurve,
    );
  }

  disposeController() {
    _dotsInputData.close();
    _dotsStreamController.close();
    _pageController.dispose();
  }
}
