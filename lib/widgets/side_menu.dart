import 'package:flutter/material.dart';
import 'package:timuchmilk/screens/admin_screen.dart';
import 'package:timuchmilk/screens/cow_screen.dart';
import 'package:timuchmilk/screens/food_screen.dart';
import 'package:timuchmilk/screens/home_screen.dart';
import 'package:timuchmilk/screens/milk_screen.dart';
import 'package:timuchmilk/screens/note_screen.dart';
import 'package:timuchmilk/screens/setting_screen.dart';

class SideMenuContent extends StatelessWidget {
  const SideMenuContent({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    final scaffoldState = Scaffold.maybeOf(context);
    final isDrawerOpen = scaffoldState?.isDrawerOpen ?? false;

    if (isDrawerOpen) {
      Navigator.pop(context);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF2F0EA),
            Color(0xFFE9E7E1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEEF4E4),
                      Color(0xFFDCE8CB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFF335F16),
                      child: Icon(
                        Icons.agriculture_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Timuch Farm",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF255400),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Farm management dashboard",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6A735E),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const _MenuSectionLabel("Overview"),
                    _MenuTile(
                      icon: Icons.home_rounded,
                      label: "Home Page",
                      color: const Color(0xFF5F7E3B),
                      onTap: () => _navigateTo(context, const HomePage()),
                    ),
                    _MenuTile(
                      icon: Icons.water_drop_rounded,
                      label: "Milk Page",
                      color: const Color(0xFF5C8AA8),
                      onTap: () => _navigateTo(context, const MilkPage()),
                    ),
                    _MenuTile(
                      icon: Icons.pets_rounded,
                      label: "Cows Page",
                      color: const Color(0xFF9A6A41),
                      onTap: () => _navigateTo(context, const CowPage()),
                    ),
                    _MenuTile(
                      icon: Icons.grass_rounded,
                      label: "Food Page",
                      color: const Color(0xFF769341),
                      onTap: () => _navigateTo(context, const FoodPage()),
                    ),
                    _MenuTile(
                      icon: Icons.note_alt_rounded,
                      label: "Notes Page",
                      color: const Color(0xFF8A6A5D),
                      onTap: () => _navigateTo(context, const NotePage()),
                    ),
                    const SizedBox(height: 14),
                    const _MenuSectionLabel("Account"),
                    _MenuTile(
                      icon: Icons.account_circle_outlined,
                      label: "Admin",
                      color: const Color(0xFF6D7F91),
                      onTap: () => _navigateTo(context, const AdminPage()),
                    ),
                    _MenuTile(
                      icon: Icons.settings_outlined,
                      label: "Setting Page",
                      color: const Color(0xFF7A7A7A),
                      onTap: () => _navigateTo(context, const SettingPage()),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1DDD6)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: Color(0xFF5A7B34),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Healthy farm, better tracking.",
                        style: TextStyle(
                          color: Color(0xFF5E6557),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSectionLabel extends StatelessWidget {
  final String label;

  const _MenuSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w700,
          color: Color(0xFF80786F),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4DFD8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D3636),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9C948A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SideMenuContent(),
    );
  }
}

class SideMenuFixed extends StatelessWidget {
  const SideMenuFixed({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 280,
      child: SideMenuContent(),
    );
  }
}
