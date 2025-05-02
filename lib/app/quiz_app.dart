import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quiz_app/core/router/app_routes.dart';
import 'package:quiz_app/core/router/router_manager.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context,child)
      {
        return GetMaterialApp(
          initialRoute: AppRoutes.splashView,
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark(),
          routes: RouterManager.mainAppRoutes,
            
      );
      },
      designSize: Size(414, 896),
    );
  }
}