import 'package:flutter/material.dart';

class PageSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final List<BoxShadow>? boxShadow;
  final bool showClearButton;
  final EdgeInsetsGeometry contentPadding;

  const PageSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.width,
    required this.borderColor,
    required this.iconColor,
    this.height = 50,
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.boxShadow,
    this.showClearButton = false,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor),
          boxShadow: boxShadow,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              Icons.search,
              color: iconColor,
            ),
            suffixIcon: showClearButton
                ? IconButton(
                    onPressed: controller.clear,
                    icon: const Icon(Icons.close, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: contentPadding,
          ),
        ),
      ),
    );
  }
}
