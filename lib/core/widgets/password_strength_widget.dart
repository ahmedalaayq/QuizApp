import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';
import 'package:quiz_app/core/services/animation_service.dart';

class PasswordStrengthWidget extends StatefulWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthWidget({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  State<PasswordStrengthWidget> createState() => _PasswordStrengthWidgetState();
}

class _PasswordStrengthWidgetState extends State<PasswordStrengthWidget>
    with TickerProviderStateMixin {
  late AnimationController _strengthController;
  late AnimationController _requirementsController;
  late Animation<double> _strengthAnimation;
  late Animation<double> _requirementsAnimation;

  int _currentStrength = 0;
  List<PasswordRequirement> _requirements = [];

  @override
  void initState() {
    super.initState();
    _strengthController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _requirementsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _strengthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strengthController, curve: Curves.easeInOut),
    );

    _requirementsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _requirementsController, curve: Curves.easeInOut),
    );

    _updateStrength();
    _updateRequirements();

    if (widget.showRequirements) {
      _requirementsController.forward();
    }
  }

  @override
  void didUpdateWidget(PasswordStrengthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.password != oldWidget.password) {
      _updateStrength();
      _updateRequirements();
    }
    if (widget.showRequirements != oldWidget.showRequirements) {
      if (widget.showRequirements) {
        _requirementsController.forward();
      } else {
        _requirementsController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _strengthController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final newStrength = _calculatePasswordStrength(widget.password);
    if (_currentStrength != newStrength) {
      setState(() {
        _currentStrength = newStrength;
      });
      _strengthController.animateTo(newStrength / 4);
    }
  }

  void _updateRequirements() {
    setState(() {
      _requirements = _getRequirements();
    });
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'ضعيف';
      case 2:
        return 'متوسط';
      case 3:
        return 'قوي';
      case 4:
        return 'قوي جداً';
      default:
        return '';
    }
  }

  List<PasswordRequirement> _getRequirements() {
    return [
      PasswordRequirement(
        text: 'على الأقل 6 أحرف',
        isMet: widget.password.length >= 6,
        icon: Icons.text_fields,
      ),
      PasswordRequirement(
        text: 'حرف كبير واحد على الأقل (A-Z)',
        isMet: widget.password.contains(RegExp(r'[A-Z]')),
        icon: Icons.text_format,
      ),
      PasswordRequirement(
        text: 'رقم واحد على الأقل (0-9)',
        isMet: widget.password.contains(RegExp(r'[0-9]')),
        icon: Icons.numbers,
      ),
      PasswordRequirement(
        text: 'رمز خاص واحد على الأقل (!@#\$%^&*)',
        isMet: widget.password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
        icon: Icons.security,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final strengthColor = _getStrengthColor(_currentStrength);

    if (widget.password.isEmpty && !widget.showRequirements) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _requirementsAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDarkMode
                    ? const Color(0xFF2D3748).withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
                isDarkMode
                    ? const Color(0xFF1A202C).withValues(alpha: 0.8)
                    : Colors.grey.shade50.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: strengthColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: strengthColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Password Strength Indicator
              if (widget.password.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.security, color: strengthColor, size: 18.r),
                    SizedBox(width: 8.w),
                    Text(
                      'قوة كلمة المرور: ',
                      style: AppTextStyles.cairo12w600.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _getStrengthText(_currentStrength),
                      style: AppTextStyles.cairo12w700.copyWith(
                        color: strengthColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Strength Progress Bar
                AnimatedBuilder(
                  animation: _strengthAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _strengthAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                strengthColor,
                                strengthColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],

              // Requirements List
              if (widget.showRequirements) ...[
                Text(
                  'متطلبات كلمة المرور:',
                  style: AppTextStyles.cairo14w600.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),

                ..._requirements.asMap().entries.map((entry) {
                  final index = entry.key;
                  final requirement = entry.value;

                  return AnimationService.slideInFromLeft(
                    _RequirementTile(
                      requirement: requirement,
                      isDarkMode: isDarkMode,
                    ),
                    delay: Duration(milliseconds: 100 * index),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RequirementTile extends StatelessWidget {
  final PasswordRequirement requirement;
  final bool isDarkMode;

  const _RequirementTile({required this.requirement, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:
            requirement.isMet
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              requirement.isMet
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: requirement.isMet ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              requirement.isMet ? Icons.check : Icons.close,
              color: Colors.white,
              size: 12.r,
            ),
          ),
          SizedBox(width: 12.w),
          Icon(
            requirement.icon,
            color:
                requirement.isMet
                    ? Colors.green
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            size: 16.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              requirement.text,
              style: AppTextStyles.cairo12w500.copyWith(
                color:
                    requirement.isMet
                        ? Colors.green
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordRequirement {
  final String text;
  final bool isMet;
  final IconData icon;

  PasswordRequirement({
    required this.text,
    required this.isMet,
    required this.icon,
  });
}
