import 'package:flutter/material.dart';

class AnimatedAddressText extends StatefulWidget {
  final String address;
  final TextStyle? style;
  final Duration animationDuration;

  const AnimatedAddressText({
    super.key,
    required this.address,
    this.style,
    this.animationDuration = const Duration(milliseconds: 20),
  });

  @override
  State<AnimatedAddressText> createState() => _AnimatedAddressTextState();
}

class _AnimatedAddressTextState extends State<AnimatedAddressText>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.address.length * 50).clamp(1000, 4000),
      ),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedAddressText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      _animationController.reset();
      _animationController.duration = Duration(
        milliseconds: (widget.address.length * 50).clamp(1000, 4000),
      );
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        try {
          final maxLength = (_animationController.value * widget.address.length)
              .toInt()
              .clamp(0, widget.address.length);
          final displayText = widget.address.substring(0, maxLength);
          return Text(
            displayText,
            style:
                widget.style ??
                const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
          );
        } catch (e) {
          return Text(
            widget.address,
            style:
                widget.style ??
                const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
          );
        }
      },
    );
  }
}
