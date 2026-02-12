import 'package:flutter/material.dart';
import 'package:quiz_app/core/widgets/animated_widgets.dart';
import 'package:quiz_app/core/widgets/password_strength_widget.dart';

/// A complete password field with strength indicator
/// Perfect for registration forms
class PasswordFieldWithStrength extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final List<String>? autofillHints;
  final bool showStrengthIndicator;

  const PasswordFieldWithStrength({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.autofillHints,
    this.showStrengthIndicator = true,
  });

  @override
  State<PasswordFieldWithStrength> createState() =>
      _PasswordFieldWithStrengthState();
}

class _PasswordFieldWithStrengthState extends State<PasswordFieldWithStrength> {
  bool _obscureText = true;
  String _currentPassword = '';

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {
        _currentPassword = widget.controller?.text ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedTextField(
          label: widget.label,
          hint: widget.hint,
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          textInputAction: widget.textInputAction,
          prefixIcon: Icons.lock,
          suffixIcon: _obscureText ? Icons.visibility : Icons.visibility_off,
          onSuffixTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          autofillHints: widget.autofillHints ?? [AutofillHints.newPassword],
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
        ),

        // Password Strength Indicator
        if (widget.showStrengthIndicator)
          PasswordStrengthWidget(
            password: _currentPassword,
            showRequirements: _currentPassword.isNotEmpty,
          ),
      ],
    );
  }
}
