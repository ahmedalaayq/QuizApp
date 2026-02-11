import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimationService {
  // Animation Durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  // Slide Animations
  static Widget slideInFromLeft(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .slideX(
          begin: -1.0,
          end: 0.0,
          duration: duration ?? normalDuration,
          curve: curve,
        )
        .fadeIn(duration: duration ?? normalDuration, curve: curve);
  }

  static Widget slideInFromRight(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .slideX(
          begin: 1.0,
          end: 0.0,
          duration: duration ?? normalDuration,
          curve: curve,
        )
        .fadeIn(duration: duration ?? normalDuration, curve: curve);
  }

  static Widget slideInFromTop(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .slideY(
          begin: -1.0,
          end: 0.0,
          duration: duration ?? normalDuration,
          curve: curve,
        )
        .fadeIn(duration: duration ?? normalDuration, curve: curve);
  }

  static Widget slideInFromBottom(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .slideY(
          begin: 1.0,
          end: 0.0,
          duration: duration ?? normalDuration,
          curve: curve,
        )
        .fadeIn(duration: duration ?? normalDuration, curve: curve);
  }

  // Scale Animations
  static Widget scaleIn(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.elasticOut,
    double begin = 0.0,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .scale(
          begin: Offset(begin, begin),
          end: const Offset(1.0, 1.0),
          duration: duration ?? normalDuration,
          curve: curve,
        )
        .fadeIn(duration: duration ?? normalDuration, curve: curve);
  }

  static Widget bounceIn(Widget child, {Duration? duration, Duration? delay}) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          duration: duration ?? slowDuration,
          curve: Curves.bounceOut,
        )
        .fadeIn(duration: duration ?? slowDuration, curve: Curves.easeOut);
  }

  // Fade Animations
  static Widget fadeIn(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeIn,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? normalDuration, curve: curve);
  }

  static Widget fadeInUp(
    Widget child, {
    Duration? duration,
    Duration? delay,
    double distance = 30.0,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .fadeIn(duration: duration ?? normalDuration, curve: Curves.easeOut)
        .moveY(
          begin: distance,
          end: 0,
          duration: duration ?? normalDuration,
          curve: Curves.easeOut,
        );
  }

  // Rotation Animations
  static Widget rotateIn(
    Widget child, {
    Duration? duration,
    Duration? delay,
    double begin = -0.5,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .rotate(
          begin: begin,
          end: 0.0,
          duration: duration ?? normalDuration,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: duration ?? normalDuration, curve: Curves.easeOut);
  }

  // Shimmer Effect
  static Widget shimmer(
    Widget child, {
    Duration? duration,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration ?? const Duration(milliseconds: 1500),
          color: highlightColor ?? Colors.white.withValues(alpha: 0.5),
        );
  }

  // Pulse Animation
  static Widget pulse(
    Widget child, {
    Duration? duration,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration ?? const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
  }

  // Shake Animation
  static Widget shake(
    Widget child, {
    Duration? duration,
    double offset = 10.0,
  }) {
    return child.animate().shake(
      duration: duration ?? const Duration(milliseconds: 500),
      hz: 4,
      offset: Offset(offset, 0),
    );
  }

  // Flip Animation
  static Widget flipIn(
    Widget child, {
    Duration? duration,
    Duration? delay,
    Axis axis = Axis.horizontal,
  }) {
    return child
        .animate(delay: delay ?? Duration.zero)
        .flip(duration: duration ?? normalDuration, curve: Curves.easeOut)
        .fadeIn(duration: duration ?? normalDuration, curve: Curves.easeOut);
  }

  // Staggered List Animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration? duration,
    Duration? staggerDelay,
    Axis direction = Axis.vertical,
  }) {
    return Column(
      children:
          children
              .asMap()
              .entries
              .map(
                (entry) => slideInFromBottom(
                  entry.value,
                  duration: duration ?? normalDuration,
                  delay: Duration(
                    milliseconds:
                        entry.key *
                        (staggerDelay ?? const Duration(milliseconds: 100))
                            .inMilliseconds,
                  ),
                ),
              )
              .toList(),
    );
  }

  // Page Transition Animations
  static Widget pageSlideTransition(
    Widget child, {
    required AnimationController controller,
    SlideDirection direction = SlideDirection.rightToLeft,
  }) {
    late Offset begin;
    const Offset end = Offset.zero;

    switch (direction) {
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      child: child,
    );
  }

  // Loading Animation
  static Widget loadingDots({Color? color, double size = 8.0}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
              width: size,
              height: size,
              margin: EdgeInsets.symmetric(horizontal: size * 0.25),
              decoration: BoxDecoration(
                color: color ?? Colors.blue,
                shape: BoxShape.circle,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: const Duration(milliseconds: 600),
              delay: Duration(milliseconds: index * 200),
              curve: Curves.easeInOut,
            );
      }),
    );
  }

  // Success Animation
  static Widget successCheckmark({Color? color, double size = 50.0}) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white),
        )
        .animate()
        .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
        )
        .then()
        .shake(duration: const Duration(milliseconds: 200), hz: 2);
  }
}

enum SlideDirection { rightToLeft, leftToRight, topToBottom, bottomToTop }
