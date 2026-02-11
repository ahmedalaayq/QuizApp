import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AppTheme {
  // Light Theme
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
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
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
      displayLarge: AppTextStyles.cairo24w700.copyWith(color: Colors.black),
      displayMedium: AppTextStyles.cairo20w700.copyWith(color: Colors.black),
      displaySmall: AppTextStyles.cairo18w700.copyWith(color: Colors.black),
      headlineMedium: AppTextStyles.cairo16w700.copyWith(color: Colors.black),
      bodyLarge: AppTextStyles.cairo14w400.copyWith(color: Colors.black87),
      bodyMedium: AppTextStyles.cairo13w400.copyWith(color: Colors.black87),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: const Color(0xFF161B22),
      surfaceContainerHighest: const Color(0xFF21262D),
      surfaceContainer: const Color(0xFF1C2128),
      surfaceContainerHigh: const Color(0xFF30363D),
      error: AppColors.criticalColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF0F6FC),
      onSurfaceVariant: const Color(0xFF8B949E),
      outline: const Color(0xFF30363D),
      outlineVariant: const Color(0xFF21262D),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppTextStyles.cairo20w700.copyWith(color: Colors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: const Color(0xFF161B22),
      shadowColor: Colors.black.withValues(alpha: 0.3),
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
      displayLarge: AppTextStyles.cairo24w700.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      displayMedium: AppTextStyles.cairo20w700.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      displaySmall: AppTextStyles.cairo18w700.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      headlineMedium: AppTextStyles.cairo16w700.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      bodyLarge: AppTextStyles.cairo14w400.copyWith(
        color: const Color(0xFFE6EDF3),
      ),
      bodyMedium: AppTextStyles.cairo13w400.copyWith(
        color: const Color(0xFFE6EDF3),
      ),
      labelLarge: AppTextStyles.cairo14w600.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      labelMedium: AppTextStyles.cairo12w500.copyWith(
        color: const Color(0xFF8B949E),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF21262D),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF30363D), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF30363D), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: AppTextStyles.cairo14w500.copyWith(
        color: const Color(0xFF8B949E),
      ),
      hintStyle: AppTextStyles.cairo14w400.copyWith(
        color: const Color(0xFF6E7681),
      ),
      errorStyle: AppTextStyles.cairo12w500.copyWith(color: Colors.red),
      prefixIconColor: const Color(0xFF8B949E),
      suffixIconColor: const Color(0xFF8B949E),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: const Color(0xFF161B22),
      textColor: const Color(0xFFF0F6FC),
      iconColor: const Color(0xFF8B949E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF30363D),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF161B22),
      selectedItemColor: Color(0xFFF0F6FC),
      unselectedItemColor: Color(0xFF8B949E),
      type: BottomNavigationBarType.fixed,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0D1117)),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF161B22),
      titleTextStyle: AppTextStyles.cairo18w700.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      contentTextStyle: AppTextStyles.cairo14w400.copyWith(
        color: const Color(0xFFE6EDF3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF21262D),
      contentTextStyle: AppTextStyles.cairo14w500.copyWith(
        color: const Color(0xFFF0F6FC),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
