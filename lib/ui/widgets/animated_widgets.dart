import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jarvis_lite/ui/theme/app_theme.dart';

/// Animated waveform widget for voice visualization
class AnimatedWaveform extends StatefulWidget {
  final bool isListening;
  final int barCount;
  final Duration animationDuration;

  const AnimatedWaveform({
    Key? key,
    this.isListening = false,
    this.barCount = 20,
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<AnimatedWaveform>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.barCount,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    if (widget.isListening) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].repeat(reverse: true);
      Future.delayed(
        Duration(milliseconds: 50 * i),
      ).then((_) => _controllers[i].forward());
    }
  }

  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(AnimatedWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _startAnimation();
    } else if (!widget.isListening && oldWidget.isListening) {
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
            widget.barCount,
            (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedBuilder(
                animation: _controllers[index],
                builder: (context, child) {
                  final height = 20 + (_controllers[index].value * 40);
                  return Container(
                    width: 3,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryBlue, AppTheme.accentCyan],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large circular voice button
class VoiceCommandButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final String label;

  const VoiceCommandButton({
    Key? key,
    required this.isListening,
    required this.onPressed,
    this.onLongPress,
    this.label = 'TAP TO SPEAK',
  }) : super(key: key);

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.isListening) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceCommandButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _controller.repeat();
    } else if (!widget.isListening && oldWidget.isListening) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 1,
        end: 1.1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: GestureDetector(
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.cyanGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: widget.isListening ? 10 : 0,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isListening ? Icons.mic : Icons.mic_none,
                  size: 40,
                  color: AppTheme.darkBg,
                ),
                SizedBox(height: 4),
                Text(
                  widget.isListening ? 'LISTENING' : 'TAP',
                  style: TextStyle(
                    color: AppTheme.darkBg,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status indicator widget
class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? activeColor;

  const StatusIndicator({
    Key? key,
    required this.label,
    required this.isActive,
    this.activeColor = AppTheme.successGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : AppTheme.textSecondary,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? activeColor : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Glowing text effect
class GlowingText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;

  const GlowingText(
    this.text, {
    Key? key,
    this.style,
    this.glowColor = AppTheme.accentCyan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(text, style: style),
    );
  }
}
