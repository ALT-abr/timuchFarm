import 'dart:io';

import 'package:flutter/material.dart';

class FoodCard extends StatefulWidget {
  final String photo;
  final IconData icon;
  final String title;
  final int value;
  final String valueSign;
  final String subValue;
  final String date;
  final String dayMonth;
  final Color cardColor;
  final Color iconColor;
  final Color titleColor;
  final Color valueColor;
  final Color subValueColor;
  final Color dateColor;

  const FoodCard({
    super.key,
    required this.photo,
    required this.icon,
    required this.title,
    required this.value,
    required this.valueSign,
    required this.subValue,
    required this.date,
    required this.dayMonth,
    required this.cardColor,
    required this.iconColor,
    required this.titleColor,
    required this.valueColor,
    required this.subValueColor,
    required this.dateColor,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 450),
        tween: Tween(begin: 0.96, end: 1),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: _isHovered ? 1.02 : scale,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: 250,
          constraints: const BoxConstraints(minHeight: 390),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.16 : 0.10),
                blurRadius: _isHovered ? 24 : 14,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: widget.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 156,
                        width: double.infinity,
                        child: _buildImage(),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 170),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.icon, color: widget.iconColor, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: widget.titleColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: widget.iconColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.iconColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: widget.titleColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Feed inventory item",
                                    style: TextStyle(
                                      color: Color(0xFF7D8276),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "${widget.value} ${widget.valueSign}",
                          style: TextStyle(
                            color: widget.valueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Current stock available",
                          style: TextStyle(
                            color: widget.subValueColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _MetricLine(
                          label: "Daily feed",
                          value: widget.subValue,
                          unit: "unit/day",
                          color: widget.subValueColor,
                        ),
                        const SizedBox(height: 14),
                        _ProgressStripe(color: widget.iconColor),
                        const SizedBox(height: 14),
                        _MetricLine(
                          label: "Stock days left",
                          value: widget.date,
                          unit: widget.dayMonth,
                          color: widget.dateColor,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE3E3DA),
                                  ),
                                ),
                                child: Text(
                                  widget.date == "30"
                                      ? "Stable stock"
                                      : "Watch stock",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: widget.dateColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final source = widget.photo.trim();

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    if (source.isNotEmpty) {
      return Image.file(
        File(source),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB8C99E),
            Color(0xFF7D9B61),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricLine({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6D7269),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "$value $unit",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ProgressStripe extends StatelessWidget {
  final Color color;

  const _ProgressStripe({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 9,
        color: color.withOpacity(0.12),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Container(color: color),
            ),
            Expanded(
              flex: 3,
              child: Container(color: color.withOpacity(0.22)),
            ),
          ],
        ),
      ),
    );
  }
}
