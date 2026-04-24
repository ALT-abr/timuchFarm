import 'package:flutter/material.dart';
import 'package:timuchmilk/database/farm_repository.dart';
import 'package:timuchmilk/models/cow_model.dart';
import 'package:timuchmilk/models/milk_production_model.dart';
import 'package:timuchmilk/models/user_model.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<_AdminPageData> _pageDataFuture;

  @override
  void initState() {
    super.initState();
    _refreshPage();
  }

  void _refreshPage() {
    _pageDataFuture = _loadData();
  }

  Future<_AdminPageData> _loadData() async {
    final repo = FarmRepository.instance;
    final results = await Future.wait([
      repo.getLatestUser(),
      repo.getCows(),
      repo.getMilkProductions(),
    ]);

    return _AdminPageData(
      user: results[0] as UserModel?,
      cows: results[1] as List<CowModel>,
      productions: results[2] as List<MilkProductionModel>,
    );
  }

  Future<void> _showEditProfileDialog(UserModel? user) async {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final firstNameController =
        TextEditingController(text: user?.firstName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');
    DateTime creationDate = user?.creationDate ?? DateTime.now();
    String? errorText;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(user == null ? 'Create User Profile' : 'Edit Profile'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: creationDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() => creationDate = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCFC6BF)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_outlined),
                              const SizedBox(width: 10),
                              Text(_formatDate(creationDate)),
                            ],
                          ),
                        ),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final username = usernameController.text.trim();
                    final firstName = firstNameController.text.trim();
                    final email = emailController.text.trim();
                    final phone = phoneController.text.trim();
                    final address = addressController.text.trim();

                    if (username.isEmpty ||
                        firstName.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        address.isEmpty) {
                      setDialogState(() {
                        errorText = 'Please fill in all profile fields.';
                      });
                      return;
                    }

                    final profile = UserModel(
                      id: user?.id,
                      username: username,
                      firstName: firstName,
                      password: user?.password ?? '12345678',
                      email: email,
                      phone: phone,
                      creationDate: creationDate,
                      address: address,
                    );

                    if (user == null) {
                      await FarmRepository.instance.addUser(profile);
                    } else {
                      await FarmRepository.instance.updateUser(profile);
                    }

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    usernameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    if (saved == true && mounted) {
      setState(_refreshPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user == null
                ? 'User profile created successfully.'
                : 'Profile updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _showChangePasswordDialog(UserModel? user) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a user profile before changing password.'),
        ),
      );
      return;
    }

    final passwordController = TextEditingController();
    String? errorText;

    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Change Password'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final password = passwordController.text.trim();

                    if (password.length < 6) {
                      setDialogState(() {
                        errorText = 'Password must be at least 6 characters.';
                      });
                      return;
                    }

                    await FarmRepository.instance.updateUser(
                      UserModel(
                        id: user.id,
                        username: user.username,
                        firstName: user.firstName,
                        password: password,
                        email: user.email,
                        phone: user.phone,
                        creationDate: user.creationDate,
                        address: user.address,
                      ),
                    );

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();

    if (changed == true && mounted) {
      setState(_refreshPage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully.'),
        ),
      );
    }
  }

  void _shareProfile(UserModel? user) {
    final name = user?.username ?? 'User';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile for $name is ready to share.'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 900;

    return ResponsiveLayout(
      title: "A D M I N",
      child: FutureBuilder<_AdminPageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Database error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          final user = data.user;
          final avgMilk = data.productions.isEmpty
              ? 0.0
              : data.productions
                      .map((item) => item.quantity)
                      .reduce((a, b) => a + b) /
                  data.productions.length;

          return SingleChildScrollView(
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
                        Color(0xFFF4EEE7),
                        Color(0xFFE9F0E0),
                        Color(0xFFF7F4EF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 20,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6A8743),
                              Color(0xFF39541F),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Admin Profile",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3D2C22),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user?.username.toUpperCase() ?? "NO USER",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF547033),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Manage your farm account, review contact details, and keep your main profile information up to date.",
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.45,
                                color: Color(0xFF6D665B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;
                    final width = constraints.maxWidth;
                    final columns = width >= 980
                        ? 3
                        : width >= 640
                            ? 2
                            : 1;
                    final cardWidth =
                        (width - (spacing * (columns - 1))) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _AdminStatCard(
                          width: cardWidth,
                          title: "Farm Since",
                          value: user == null
                              ? "--"
                              : "${user.creationDate.year}",
                          subTitle: "active",
                          icon: Icons.agriculture_rounded,
                          color: const Color(0xFF6C8B43),
                        ),
                        _AdminStatCard(
                          width: cardWidth,
                          title: "Total Cows",
                          value: "${data.cows.length}",
                          subTitle: "in farm",
                          icon: Icons.pets,
                          color: const Color(0xFF9B6A3C),
                        ),
                        _AdminStatCard(
                          width: cardWidth,
                          title: "Avg Milk",
                          value: "${avgMilk.round()} L",
                          subTitle: "per entry",
                          icon: Icons.water_drop_outlined,
                          color: const Color(0xFF5A8A8A),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                if (compact)
                  Column(
                    children: [
                      _AdminInfoCard(
                        user: user,
                        cowsCount: data.cows.length,
                        averageMilk: avgMilk,
                      ),
                      const SizedBox(height: 18),
                      _AdminActionsCard(
                        hasUser: user != null,
                        onEditProfile: () => _showEditProfileDialog(user),
                        onChangePassword: () => _showChangePasswordDialog(user),
                        onShareProfile: () => _shareProfile(user),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _AdminInfoCard(
                          user: user,
                          cowsCount: data.cows.length,
                          averageMilk: avgMilk,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 2,
                        child: _AdminActionsCard(
                          hasUser: user != null,
                          onEditProfile: () => _showEditProfileDialog(user),
                          onChangePassword: () => _showChangePasswordDialog(user),
                          onShareProfile: () => _shareProfile(user),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminPageData {
  final UserModel? user;
  final List<CowModel> cows;
  final List<MilkProductionModel> productions;

  const _AdminPageData({
    required this.user,
    required this.cows,
    required this.productions,
  });
}

class _AdminStatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subTitle;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subTitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shadowColor: const Color(0x16000000),
        margin: EdgeInsets.zero,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 7,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
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
    );
  }
}

class _AdminInfoCard extends StatelessWidget {
  final UserModel? user;
  final int cowsCount;
  final double averageMilk;

  const _AdminInfoCard({
    required this.user,
    required this.cowsCount,
    required this.averageMilk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0x15000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Profile Details",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF342828),
              ),
            ),
            const SizedBox(height: 18),
            _AdminInfoTile(
              icon: Icons.person_outline_rounded,
              title: "Username",
              subtitle: user?.username ?? "--",
            ),
            _AdminInfoTile(
              icon: Icons.lock_outline_rounded,
              title: "Password",
              subtitle: user == null ? "--" : "***********",
            ),
            _AdminInfoTile(
              icon: Icons.phone_outlined,
              title: "Phone Number",
              subtitle: user?.phone ?? "--",
            ),
            _AdminInfoTile(
              icon: Icons.mail_outline_rounded,
              title: "Email Address",
              subtitle: user?.email ?? "--",
            ),
            _AdminInfoTile(
              icon: Icons.event_outlined,
              title: "Farm Created",
              subtitle: user == null
                  ? "--"
                  : "${user!.creationDate.day.toString().padLeft(2, '0')}/${user!.creationDate.month.toString().padLeft(2, '0')}/${user!.creationDate.year}",
            ),
            _AdminInfoTile(
              icon: Icons.home_outlined,
              title: "Address",
              subtitle: user?.address ?? "--",
            ),
            _AdminInfoTile(
              icon: Icons.pets_outlined,
              title: "Number of Cows",
              subtitle: "$cowsCount",
            ),
            _AdminInfoTile(
              icon: Icons.local_drink_outlined,
              title: "Average Milk Production",
              subtitle: "${averageMilk.toStringAsFixed(1)} L",
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminInfoTile({
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
          color: const Color(0xFFFCFAF8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E1DC)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEFE7DF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF6F5747)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7B736E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF322727),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionsCard extends StatelessWidget {
  final bool hasUser;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onShareProfile;

  const _AdminActionsCard({
    required this.hasUser,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onShareProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0x15000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF342828),
              ),
            ),
            const SizedBox(height: 18),
            _ActionButton(
              icon: Icons.edit_outlined,
              label: hasUser ? "Edit Profile" : "Create Profile",
              color: const Color(0xFF5C8241),
              onPressed: onEditProfile,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.lock_reset_outlined,
              label: "Change Password",
              color: const Color(0xFF8A6A41),
              onPressed: onChangePassword,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.share_outlined,
              label: "Share Profile",
              color: const Color(0xFF6E7F91),
              onPressed: onShareProfile,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2ED),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Note",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF4A3A32),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Keep your contact details updated so the team can manage deliveries, checks, and farm coordination more easily.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF73665F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
