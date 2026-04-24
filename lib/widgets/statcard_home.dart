import 'package:flutter/material.dart';

class StatCardHomePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final String valueSigne;
  final Color valueColor;
  final String subTitle;
  final Color textColor;
  final Color color;

  const StatCardHomePage({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.valueSigne,
    required this.valueColor,
    required this.subTitle,
    required this.textColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 255,
      height: 96,
      child: Card(
        elevation: 3,
        shadowColor: const Color(0x16000000),
        color: color,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "$value $valueSigne",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: valueColor,
                            ),
                          ),
                          TextSpan(
                            text: "  $subTitle",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
