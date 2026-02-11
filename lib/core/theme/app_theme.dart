import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: Colors.white,
      error: AppColors.criticalColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      elevation: 2,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyles.cairo20w700.copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: AppTextStyles.cairo16w700,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.cairo24w700,
      displayMedium: AppTextStyles.cairo20w700,
      displaySmall: AppTextStyles.cairo18w700,
      headlineMedium: AppTextStyles.cairo16w700,
      bodyLarge: AppTextStyles.cairo14w400,
      bodyMedium: AppTextStyles.cairo13w400,
    ),
  );


  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: const Color(0xFF1E1E1E),
      error: AppColors.criticalColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 2,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyles.cairo20w700.copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: const Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: AppTextStyles.cairo16w700,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.cairo24w700.copyWith(color: Colors.white),
      displayMedium: AppTextStyles.cairo20w700.copyWith(color: Colors.white),
      displaySmall: AppTextStyles.cairo18w700.copyWith(color: Colors.white),
      headlineMedium: AppTextStyles.cairo16w700.copyWith(color: Colors.white),
      bodyLarge: AppTextStyles.cairo14w400.copyWith(color: Colors.white70),
      bodyMedium: AppTextStyles.cairo13w400.copyWith(color: Colors.white70),
    ),
  );
}
