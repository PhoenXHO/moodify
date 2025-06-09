import 'package:flutter/material.dart';
import 'dart:math' show sin, pi;
import '../theme/app_colors.dart';

class AiTypingIndicator extends StatefulWidget {
  final bool isGeneratingPlaylist;
  
  const AiTypingIndicator({
    super.key,
    this.isGeneratingPlaylist = false,
  });

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _dotPosition1;
  late Animation<double> _dotPosition2;
  late Animation<double> _dotPosition3;
  late Animation<double> _gradientPosition;
  
  @override
  void initState() {
    super.initState();    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slightly longer for smoother gradient
    )..repeat();
    
    _dotPosition1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );
    
    _dotPosition2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _dotPosition3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeInOut),
      ),
    );
    
    // Use a 0-to-1 tween for better control over gradient animation
    _gradientPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.music_note, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4, // Narrower than message bubbles
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
            child: widget.isGeneratingPlaylist 
                ? _buildPlaylistGeneratingIndicator()
                : _buildDotsTypingIndicator(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDotsTypingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedDot(_dotPosition1),
            const SizedBox(width: 4),
            _buildAnimatedDot(_dotPosition2),
            const SizedBox(width: 4),
            _buildAnimatedDot(_dotPosition3),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -3 * animation.value * sin(animation.value * pi)),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8 + 0.2 * animation.value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }  Widget _buildPlaylistGeneratingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            // Calculate gradient positions for a continuous loop effect
            // This creates a smoother transition by moving the gradient across the text
            return LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.4),
                Colors.white,
                Colors.white,
                Colors.white,
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              // Left-to-right animation using proper alignment ranges
              // Using a larger range (3.0 total width) ensures the animation starts and ends outside text bounds
              begin: Alignment(_gradientPosition.value * 3.0 - 2, 0),  // Starts from -2 to 1
              end: Alignment(_gradientPosition.value * 3.0 + 0.5, 0),  // Ends at 0.5 to 3.5
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,  // Applies gradient only to the text
          child: Text(
            "Generating playlist...",
            style: TextStyle(
              color: Colors.white,  // Base color (will be masked by gradient)
              fontWeight: FontWeight.w600, // Slightly bolder for better visibility
              fontSize: 14,
              letterSpacing: 0.3, // Slight letter spacing for better readability
              shadows: [
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
