import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MyButtons extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final bool isOutlined;
  final double width;
  
  const MyButtons({
    super.key,
    required this.onTap,
    required this.text,
    this.isOutlined = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        width: width,
        height: 56,
        decoration: BoxDecoration(
          boxShadow: isOutlined 
              ? [] 
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutlined ? Colors.transparent : AppColors.primary,
            foregroundColor: isOutlined ? AppColors.primary : Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isOutlined 
                  ? BorderSide(color: AppColors.primary, width: 2) 
                  : BorderSide.none,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
