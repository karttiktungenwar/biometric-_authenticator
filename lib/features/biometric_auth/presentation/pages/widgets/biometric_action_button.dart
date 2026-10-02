import 'package:flutter/material.dart';

class BiometricActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isAuthenticating;
  final bool isEnabled;

  const BiometricActionButton({
    super.key,
    required this.onPressed,
    required this.isAuthenticating,
    this.isEnabled = true,
  });

  @override
  State<BiometricActionButton> createState() => _BiometricActionButtonState();
}

class _BiometricActionButtonState extends State<BiometricActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final scale = widget.isAuthenticating ? _scaleAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: GestureDetector(
                onTap: widget.isEnabled && !widget.isAuthenticating
                    ? widget.onPressed
                    : null,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: widget.isEnabled
                          ? [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ]
                          : [Colors.grey.shade800, Colors.grey.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: widget.isEnabled
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: widget.isAuthenticating
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : const Icon(
                            Icons.fingerprint,
                            size: 64,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          widget.isAuthenticating
              ? 'Scanning fingerprint...'
              : widget.isEnabled
                  ? 'Tap fingerprint sensor to authenticate'
                  : 'Biometric authentication unavailable',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
