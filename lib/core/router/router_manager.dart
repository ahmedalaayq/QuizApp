import 'package:flutter/material.dart';
import 'package:quiz_app/core/features/answer/views/answer_view.dart';
import 'package:quiz_app/core/features/login/views/login_view.dart';
import 'package:quiz_app/core/features/on_boarding/views/on_boarding_view.dart';
import 'package:quiz_app/core/features/quiz/views/quiz_view.dart';
import 'package:quiz_app/core/features/splash/views/splash_view.dart';
import 'package:quiz_app/core/router/app_routes.dart';

class RouterManager {
  static final Map<String, WidgetBuilder> mainAppRoutes = 
  {
    AppRoutes.splashView : (context)=> SplashView(),
    AppRoutes.onBoardingView : (context)=> OnBoardingView(),
    AppRoutes.loginView : (context)=> LoginView(),
    AppRoutes.quizView : (context)=> QuizView(),
    AppRoutes.answerView : (context)=> AnswerView(),
  };
}
