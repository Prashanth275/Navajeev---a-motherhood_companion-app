import 'package:flutter/material.dart';

class AnimatedTrimesterProgress extends StatefulWidget {
  final double progress;
  final Color progressColor;

  const AnimatedTrimesterProgress({
    super.key,
    required this.progress,
    required this.progressColor,
  });

  @override
  State<AnimatedTrimesterProgress> createState() =>
      _AnimatedTrimesterProgressState();
}

class _AnimatedTrimesterProgressState
    extends State<AnimatedTrimesterProgress>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedTrimesterProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: 0,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: _animation.value,
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor:
            AlwaysStoppedAnimation(widget.progressColor),
          ),
        );
      },
    );
  }
}