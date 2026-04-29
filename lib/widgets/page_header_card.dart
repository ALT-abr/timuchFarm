import 'package:flutter/material.dart';

class PageHeaderCard extends StatelessWidget {
  final String title;
  final String? description;
  final Widget action;
  final Gradient gradient;
  final Color titleColor;
  final Color descriptionColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double runSpacing;
  final double maxContentWidth;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  const PageHeaderCard({
    super.key,
    required this.title,
    required this.action,
    required this.gradient,
    required this.titleColor,
    required this.descriptionColor,
    this.description,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(24),
    this.spacing = 20,
    this.runSpacing = 16,
    this.maxContentWidth = 720,
    this.titleStyle,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final baseTitleStyle =
        titleStyle ??
        TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: titleColor,
        );
    final baseDescriptionStyle =
        descriptionStyle ??
        TextStyle(
          fontSize: 16,
          color: descriptionColor,
        );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: spacing,
        runSpacing: runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: baseTitleStyle),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(description!, style: baseDescriptionStyle),
                ],
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}
