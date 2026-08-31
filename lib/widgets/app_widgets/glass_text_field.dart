import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final VoidCallback? toggleVisibility;
  final bool isLast;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? prefixText;
  final String? suffixText;

  const GlassTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.toggleVisibility,
    this.isLast = false,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.prefixText,
    this.suffixText,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        style: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: widget.icon != null
              ? Icon(widget.icon, color: Colors.black54, size: 20)
              : null,
          suffixIcon: widget.toggleVisibility != null
              ? IconButton(
            icon: Icon(
              widget.obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: widget.toggleVisibility,
          )
              : widget.suffixIcon,

          prefixText: widget.prefixText,
          suffixText: widget.suffixText,

          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.8),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryAccent,
              width: 1.5,
            ),
          ),
          errorStyle: const TextStyle(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
        obscureText: widget.obscureText,
        validator: widget.validator,
        textInputAction: widget.isLast
            ? TextInputAction.done
            : TextInputAction.next,
      ),
    );
  }
}
