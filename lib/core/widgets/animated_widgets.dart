import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:quiz_app/core/services/animation_service.dart';
import 'package:quiz_app/core/styles/app_colors.dart';
import 'package:quiz_app/core/styles/app_text_styles.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    this.delay,
    this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimationService.fadeInUp(child, delay: delay, duration: duration),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final IconData? icon;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? AppColors.primaryColor)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  widget.isLoading
                      ? AnimationService.loadingDots(
                        color: widget.textColor ?? Colors.white,
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.textColor ?? Colors.white,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            widget.text,
                            style: AppTextStyles.cairo16w700.copyWith(
                              color: widget.textColor ?? Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  const AnimatedTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: AppColors.primaryColor,
    ).animate(_controller);

    _focusNode.addListener(() {
      if (!_disposed && mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
          if (_isFocused) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String>? _getAutofillHints() {
    if (widget.keyboardType == TextInputType.emailAddress) {
      return [AutofillHints.email];
    }
    if (widget.obscureText) {
      return [AutofillHints.password];
    }
    if (widget.keyboardType == TextInputType.name) {
      return [AutofillHints.name];
    }
    if (widget.keyboardType == TextInputType.phone) {
      return [AutofillHints.telephoneNumber];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: AppTextStyles.cairo14w600.copyWith(
            color:
                _isFocused
                    ? AppColors.primaryColor
                    : (isDarkMode ? Colors.white : AppColors.primaryDark),
          ),
          child: Text(widget.label),
        ),
        SizedBox(height: 8.h),
        AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              autofillHints: _getAutofillHints(),
              style: AppTextStyles.cairo14w500.copyWith(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyles.cairo14w400.copyWith(
                  color: Colors.grey,
                ),
                prefixIcon:
                    widget.prefixIcon != null
                        ? Icon(
                          widget.prefixIcon,
                          color: _colorAnimation.value,
                          size: 20.r,
                        )
                        : null,
                suffixIcon:
                    widget.suffixIcon != null
                        ? GestureDetector(
                          onTap: widget.onSuffixTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: _colorAnimation.value,
                            size: 20.r,
                          ),
                        )
                        : null,
                filled: true,
                fillColor:
                    isDarkMode
                        ? Theme.of(context).cardColor
                        : Colors.grey.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: _colorAnimation.value ?? Colors.grey,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AnimatedTypewriterText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration? speed;

  const AnimatedTypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: style ?? AppTextStyles.cairo16w700,
          speed: speed ?? const Duration(milliseconds: 100),
        ),
      ],
      totalRepeatCount: 1,
    );
  }
}

class AnimatedWaveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color>? colors;

  const AnimatedWaveText({
    super.key,
    required this.text,
    this.style,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText(
          text,
          textStyle: style ?? AppTextStyles.cairo20w700,
          speed: const Duration(milliseconds: 200),
        ),
      ],
      isRepeatingAnimation: true,
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final Duration? duration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.duration,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 8.h,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.progressColor ?? AppColors.primaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedCounterText extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration? duration;
  final String? suffix;
  final String? prefix;

  const AnimatedCounterText({
    super.key,
    required this.value,
    this.style,
    this.duration,
    this.suffix,
    this.prefix,
  });

  @override
  State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState extends State<AnimatedCounterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _counterAnimation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );
    _counterAnimation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _counterAnimation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_counterAnimation.value}${widget.suffix ?? ''}',
          style: widget.style ?? AppTextStyles.cairo20w700,
        );
      },
    );
  }
}

class PulsingWidget extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final double minScale;
  final double maxScale;

  const PulsingWidget({
    super.key,
    required this.child,
    this.duration,
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulsingWidget> createState() => _PulsingWidgetState();
}

class _PulsingWidgetState extends State<PulsingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
