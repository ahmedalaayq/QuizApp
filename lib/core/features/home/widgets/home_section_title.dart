import 'package:flutter/material.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const HomeSectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.cairo18w700.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

