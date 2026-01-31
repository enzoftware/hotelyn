import 'package:flutter/material.dart';
import 'package:hotelyn/components/theme/hotelyn_colors.dart';

class HotelynButton extends StatefulWidget {
  const HotelynButton({
    required this.message,
    super.key,
    this.onPressed,
    this.height = 56,
    this.width = double.infinity,
    this.color = PrimaryColors.blue,
    this.textColor = PrimaryColors.white,
    this.isLoading = false,
  });

  factory HotelynButton.secondary({
    required String message,
    VoidCallback? onPressed,
    double? height,
    double? width,
    Color? color,
    Color? textColor,
    bool isLoading = false,
  }) {
    return HotelynButton(
      message: message,
      onPressed: onPressed,
      height: height ?? 56,
      width: width ?? double.infinity,
      color: color ?? PrimaryColors.white,
      textColor: textColor ?? PrimaryColors.blue,
      isLoading: isLoading,
    );
  }

  final VoidCallback? onPressed;
  final String message;
  final double height;
  final double width;
  final Color color;
  final Color textColor;
  final bool isLoading;

  @override
  State<HotelynButton> createState() => _HotelynButtonState();
}

class _HotelynButtonState extends State<HotelynButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.isLoading || widget.onPressed == null) return;
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: MaterialButton(
          minWidth: widget.width,
          onPressed: widget.isLoading ? () {} : _handlePress,
          height: widget.height,
          shape: const StadiumBorder(),
          color: widget.color,
          textColor: widget.textColor,
          elevation: 0,
          child: widget.isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                  ),
                )
              : Text(widget.message),
        ),
      ),
    );
  }
}
