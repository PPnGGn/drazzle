import 'dart:ui';

import 'package:drazzle/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.isPassword = false,
    this.focusNode,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isPassword;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.labelText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
                obscureText: widget.isPassword ? _obscureText : false,
                onSubmitted: widget.onSubmitted != null
                    ? (_) => widget.onSubmitted!()
                    : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 8),
                  isDense: true,
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          onPressed: _toggleObscure,
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.white70,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    maxHeight: 24,
                    minHeight: 24,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.gray, width: 1.0),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondary,
                      width: 2.0,
                    ),
                  ),
                  hintText: widget.hintText,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white60,
                  ), // светлый hint
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
