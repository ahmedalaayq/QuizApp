import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/models/assessment_model.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AssessmentAnswerTile extends StatefulWidget {
  final Answer answer;
  final VoidCallback onTap;
  final bool isSelected;

  const AssessmentAnswerTile({
    super.key,
    required this.answer,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<AssessmentAnswerTile> createState() => _AssessmentAnswerTileState();
}

class _AssessmentAnswerTileState extends State<AssessmentAnswerTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      widget.isSelected
                          ? AppColors.primaryColor
                          : (isDarkMode
                              ? const Color(0xFF30363D)
                              : AppColors.primaryLight.withValues(alpha: 0.3)),
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                borderRadius: BorderRadius.circular(12.r),
                color:
                    widget.isSelected
                        ? AppColors.primaryColor.withValues(alpha: 0.1)
                        : (isDarkMode ? const Color(0xFF161B22) : Colors.white),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.isSelected
                            ? AppColors.primaryColor.withValues(alpha: 0.2)
                            : Colors.black.withValues(
                              alpha: isDarkMode ? 0.1 : 0.05,
                            ),
                    blurRadius: widget.isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Selection Indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            widget.isSelected
                                ? AppColors.primaryColor
                                : (isDarkMode
                                    ? const Color(0xFF8B949E)
                                    : Colors.grey),
                        width: 2,
                      ),
                      color:
                          widget.isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                    ),
                    child:
                        widget.isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 14.r)
                            : null,
                  ),

                  SizedBox(width: 16.w),

                  // Answer Text
                  Expanded(
                    child: Text(
                      widget.answer.text,
                      style: AppTextStyles.cairo14w500.copyWith(
                        color:
                            widget.isSelected
                                ? AppColors.primaryColor
                                : (isDarkMode
                                    ? const Color(0xFFF0F6FC)
                                    : AppColors.primaryDark),
                        height: 1.6,
                        fontWeight:
                            widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                      ),
                    ),
                  ),

                  // Score Indicator (if needed)
                  if (widget.answer.score > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${widget.answer.score}',
                        style: AppTextStyles.cairo12w600.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
