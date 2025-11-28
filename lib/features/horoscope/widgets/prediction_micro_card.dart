import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PredictionMicroCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;
  final int delay;

  const PredictionMicroCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
    this.delay = 0,
  });

  @override
  State<PredictionMicroCard> createState() => _PredictionMicroCardState();
}

class _PredictionMicroCardState extends State<PredictionMicroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Entrance animation
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        _handleTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isExpanded ? null : 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.grey[900]?.withOpacity(0.7)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.color.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(_isPressed ? 0.2 : 0.1),
                      blurRadius: _isPressed ? 15 : 10,
                      offset: Offset(0, _isPressed ? 8 : 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withOpacity(0.2),
                                widget.color.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: _isExpanded ? 0.5 : 0,
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: widget.color,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Rating indicator
                    Row(
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            index < _getRating()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: widget.color.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      secondChild: Text(
                        widget.content,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      crossFadeState:
                          _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.color.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates_rounded,
                              size: 14,
                              color: widget.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getTip(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _getRating() {
    switch (widget.title.toLowerCase()) {
      case 'love':
        return 4;
      case 'career':
        return 3;
      case 'health':
        return 4;
      case 'finance':
        return 3;
      default:
        return 3;
    }
  }

  String _getTip() {
    switch (widget.title.toLowerCase()) {
      case 'love':
        return 'Express your feelings openly today';
      case 'career':
        return 'Focus on teamwork and collaboration';
      case 'health':
        return 'Stay hydrated and take breaks';
      case 'finance':
        return 'Review your budget and savings';
      default:
        return 'Trust your instincts';
    }
  }
}


