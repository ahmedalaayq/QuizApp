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

    _nextBtnStreamController = StreamController<int>.broadcast();
    _nextBtnInputData = _nextBtnStreamController.sink;
    _nextBtnOutputData = _nextBtnStreamController.stream;
    _nextBtnInputData.add(_currentDotIndex);
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

  late StreamController<int> _nextBtnStreamController;
  late Sink<int> _nextBtnInputData;
  late Stream<int> _nextBtnOutputData;
  Stream<int> get nextBtnOutputData => _nextBtnOutputData;

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
    if (_currentDotIndex < maxDots - 1) {
      _currentDotIndex++;
      _nextBtnInputData.add(_currentDotIndex);
    } else {
      _currentDotIndex = 2;
      _nextBtnInputData.add(_currentDotIndex);
    }
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
