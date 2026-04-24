import 'package:flutter/material.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 980;

    return ResponsiveLayout(
      title: "S E T T I N G S",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF4F1EA),
                    Color(0xFFE7EFE4),
                    Color(0xFFF8F5F0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Wrap(
                spacing: 18,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFF5F7E3B),
                    child: Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D3228),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Manage your app preferences, notifications, and account behavior.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6E665E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (compact)
              const Column(
                children: [
                  _SettingsCard(
                    title: "General",
                    children: [
                      _SettingTile(
                        icon: Icons.language_rounded,
                        title: "Language",
                        subtitle: "English",
                      ),
                      _SettingTile(
                        icon: Icons.palette_outlined,
                        title: "Theme",
                        subtitle: "Light mode",
                      ),
                      _SettingTile(
                        icon: Icons.calendar_month_outlined,
                        title: "Date Format",
                        subtitle: "DD / MM / YYYY",
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _SettingsCard(
                    title: "Notifications",
                    children: [
                      _SwitchSettingTile(
                        icon: Icons.notifications_active_outlined,
                        title: "Farm Alerts",
                        subtitle: "Receive important alerts",
                        value: true,
                      ),
                      _SwitchSettingTile(
                        icon: Icons.note_alt_outlined,
                        title: "Notes Reminder",
                        subtitle: "Daily reminder at 8:00 AM",
                        value: true,
                      ),
                      _SwitchSettingTile(
                        icon: Icons.local_shipping_outlined,
                        title: "Stock Updates",
                        subtitle: "Notify when food stock is low",
                        value: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _SettingsCard(
                    title: "Security",
                    children: [
                      _SettingTile(
                        icon: Icons.lock_outline_rounded,
                        title: "Password",
                        subtitle: "Last changed 14 days ago",
                      ),
                      _SettingTile(
                        icon: Icons.fingerprint,
                        title: "Biometric Login",
                        subtitle: "Enabled on this device",
                      ),
                      _SettingTile(
                        icon: Icons.logout_rounded,
                        title: "Sign Out",
                        subtitle: "Disconnect this account",
                      ),
                    ],
                  ),
                ],
              )
            else
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SettingsCard(
                      title: "General",
                      children: [
                        _SettingTile(
                          icon: Icons.language_rounded,
                          title: "Language",
                          subtitle: "English",
                        ),
                        _SettingTile(
                          icon: Icons.palette_outlined,
                          title: "Theme",
                          subtitle: "Light mode",
                        ),
                        _SettingTile(
                          icon: Icons.calendar_month_outlined,
                          title: "Date Format",
                          subtitle: "DD / MM / YYYY",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: _SettingsCard(
                      title: "Notifications",
                      children: [
                        _SwitchSettingTile(
                          icon: Icons.notifications_active_outlined,
                          title: "Farm Alerts",
                          subtitle: "Receive important alerts",
                          value: true,
                        ),
                        _SwitchSettingTile(
                          icon: Icons.note_alt_outlined,
                          title: "Notes Reminder",
                          subtitle: "Daily reminder at 8:00 AM",
                          value: true,
                        ),
                        _SwitchSettingTile(
                          icon: Icons.local_shipping_outlined,
                          title: "Stock Updates",
                          subtitle: "Notify when food stock is low",
                          value: false,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: _SettingsCard(
                      title: "Security",
                      children: [
                        _SettingTile(
                          icon: Icons.lock_outline_rounded,
                          title: "Password",
                          subtitle: "Last changed 14 days ago",
                        ),
                        _SettingTile(
                          icon: Icons.fingerprint,
                          title: "Biometric Login",
                          subtitle: "Enabled on this device",
                        ),
                        _SettingTile(
                          icon: Icons.logout_rounded,
                          title: "Sign Out",
                          subtitle: "Disconnect this account",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0x14000000),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF372E2E),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAF8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E4DE)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8DE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF6D6356)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF362E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A736C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9D958E),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  const _SwitchSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAF8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E4DE)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8DE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF6D6356)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF362E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7A736C),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: (_) {},
              activeColor: const Color(0xFF5F7E3B),
            ),
          ],
        ),
      ),
    );
  }
}
