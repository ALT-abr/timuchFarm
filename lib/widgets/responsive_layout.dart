import 'package:flutter/material.dart';
import 'package:timuchmilk/widgets/side_menu.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.title,
  });

  static const double desktopBreakpoint = 950;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= desktopBreakpoint;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const SideMenuFixed(),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const SideMenuDrawer(),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              SafeArea(child: child),
              Positioned(
                top: 14,
                left: 14,
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.menu_rounded,
                        color: Color(0xFF255400),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
