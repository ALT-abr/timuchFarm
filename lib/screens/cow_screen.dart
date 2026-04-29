import 'package:flutter/material.dart';
import 'package:timuchmilk/database/farm_repository.dart';
import 'package:timuchmilk/models/cow_model.dart';
import 'package:timuchmilk/widgets/cow_stat_card.dart';
import 'package:timuchmilk/widgets/page_header_card.dart';
import 'package:timuchmilk/widgets/page_search_bar.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';

class CowPage extends StatefulWidget {
  const CowPage({super.key});

  @override
  State<CowPage> createState() => _CowPageState();
}

class _CowPageState extends State<CowPage> {
  late Future<List<CowModel>> _cowsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshCows();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _refreshCows() {
    _cowsFuture = FarmRepository.instance.getCows();
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text.trim().toLowerCase();
    if (nextQuery == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = nextQuery;
    });
  }

  Future<void> _showCowDialog([CowModel? cow]) async {
    final codeController = TextEditingController(text: cow?.code ?? '');
    final nameController = TextEditingController(text: cow?.name ?? '');
    final breedController = TextEditingController(text: cow?.breed ?? '');
    final ageController = TextEditingController(
      text: cow == null ? '' : '${cow.age}',
    );
    String status = cow?.status ?? 'Milking';
    String health = cow?.health ?? 'Healthy';
    String? errorText;

    final action = await showDialog<_CowDialogAction>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(cow == null ? 'Add New Cow' : 'Edit Cow'),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Cow ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: breedController,
                        decoration: const InputDecoration(
                          labelText: 'Breed',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Milking',
                            child: Text('Milking'),
                          ),
                          DropdownMenuItem(
                            value: 'Dry',
                            child: Text('Dry'),
                          ),
                          DropdownMenuItem(
                            value: 'Pregnant',
                            child: Text('Pregnant'),
                          ),
                          DropdownMenuItem(
                            value: 'Growing',
                            child: Text('Growing'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => status = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: health,
                        decoration: const InputDecoration(
                          labelText: 'Health',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Healthy',
                            child: Text('Healthy'),
                          ),
                          DropdownMenuItem(
                            value: 'In Heat',
                            child: Text('In Heat'),
                          ),
                          DropdownMenuItem(
                            value: 'Needs Check',
                            child: Text('Needs Check'),
                          ),
                          DropdownMenuItem(
                            value: 'Monitoring',
                            child: Text('Monitoring'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => health = value);
                        },
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
                if (cow != null)
                  TextButton.icon(
                    onPressed: () => Navigator.pop(
                      dialogContext,
                      _CowDialogAction.delete,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB64034),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    _CowDialogAction.cancel,
                  ),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final code = codeController.text.trim();
                    final name = nameController.text.trim();
                    final breed = breedController.text.trim();
                    final age = int.tryParse(ageController.text.trim());

                    if (code.isEmpty ||
                        name.isEmpty ||
                        breed.isEmpty ||
                        age == null ||
                        age <= 0) {
                      setDialogState(() {
                        errorText =
                            'Please fill in ID, name, breed, and a valid age.';
                      });
                      return;
                    }

                    final model = CowModel(
                      id: cow?.id,
                      code: code,
                      name: name,
                      breed: breed,
                      age: age,
                      status: status,
                      health: health,
                      createdAt: cow?.createdAt ?? DateTime.now(),
                    );

                    try {
                      if (cow == null) {
                        await FarmRepository.instance.addCow(model);
                      } else {
                        await FarmRepository.instance.updateCow(model);
                      }
                    } catch (_) {
                      setDialogState(() {
                        errorText = 'Cow ID already exists or data is invalid.';
                      });
                      return;
                    }

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(dialogContext, _CowDialogAction.saved);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();

    if (!mounted) {
      return;
    }

    if (action == _CowDialogAction.delete && cow?.id != null) {
      await _deleteCow(cow!);
      return;
    }

    if (action == _CowDialogAction.saved) {
      setState(_refreshCows);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cow == null
                ? 'Cow added successfully.'
                : 'Cow updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteCow(CowModel cow) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Cow'),
          content: Text(
            'Delete ${cow.name} (${cow.code}) from the list? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB64034),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await FarmRepository.instance.deleteCow(cow.id!);

    if (!mounted) {
      return;
    }

    setState(_refreshCows);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cow.name} deleted successfully.'),
      ),
    );
  }

  Widget _buildCowListHeader(bool compact) {
    final searchField = PageSearchBar(
      controller: _searchController,
      hintText: "Search...",
      width: compact ? 260 : 320,
      borderColor: const Color(0xFFD9D1D1),
      iconColor: const Color(0xFF8A838A),
      showClearButton: _searchQuery.isNotEmpty,
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cow List",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F2B39),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: searchField,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            "Cow List",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F2B39),
            ),
          ),
        ),
        searchField,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 900;

    return ResponsiveLayout(
      title: "C O W S",
      child: FutureBuilder<List<CowModel>>(
        future: _cowsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database error: ${snapshot.error}'));
          }

          final cows = snapshot.data ?? const <CowModel>[];
          final filteredCows = cows.where((cow) {
            if (_searchQuery.isEmpty) {
              return true;
            }

            return cow.code.toLowerCase().contains(_searchQuery) ||
                cow.name.toLowerCase().contains(_searchQuery) ||
                cow.breed.toLowerCase().contains(_searchQuery) ||
                cow.status.toLowerCase().contains(_searchQuery) ||
                cow.health.toLowerCase().contains(_searchQuery);
          }).toList();
          final milkingCount = filteredCows
              .where((cow) => cow.status.toLowerCase() == 'milking')
              .length;
          final dryCount = filteredCows
              .where((cow) => cow.status.toLowerCase() == 'dry')
              .length;
          final inHeatCount = filteredCows
              .where((cow) => cow.health.toLowerCase() == 'in heat')
              .length;
          final inHeatPercent =
              filteredCows.isEmpty
                  ? 0
                  : ((inHeatCount / filteredCows.length) * 100).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeaderCard(
                  title: "Cows Overview",
                  description:
                      "Manage your herd, track cow status, and review health information in one place.",
                  action: OutlinedButton.icon(
                    onPressed: _showCowDialog,
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF5D8B4F),
                    ),
                    label: const Text(
                      "Add New Cow",
                      style: TextStyle(
                        color: Color(0xFF5C4338),
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(190, 52),
                      side: const BorderSide(color: Color(0xFFD3C8C1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF5EEE8),
                      Color(0xFFF2E8DF),
                      Color(0xFFF8F5EF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  titleColor: const Color(0xFF71441F),
                  descriptionColor: const Color(0xFF7A6456),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 12.0;
                    final double width = constraints.maxWidth;
                    final int columns = width >= 920
                        ? 4
                        : width >= 760
                            ? 2
                            : 1;
                    final double cardWidth =
                        (width - (spacing * (columns - 1))) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        CowStatCard(
                          width: cardWidth,
                          icon: Icons.pets,
                          title: "Total Cows",
                          value: "${cows.length}",
                          startColor: const Color(0xFF8D552C),
                          endColor: const Color(0xFF6E3C17),
                          iconColor: Colors.white,
                          textColor: Colors.white,
                        ),
                        CowStatCard(
                          width: cardWidth,
                          icon: Icons.local_drink_outlined,
                          title: "Milking Cows",
                          value: "$milkingCount",
                          startColor: const Color(0xFF4E9146),
                          endColor: const Color(0xFF2D6D26),
                          iconColor: Colors.white,
                          textColor: Colors.white,
                        ),
                        CowStatCard(
                          width: cardWidth,
                          icon: Icons.cruelty_free_outlined,
                          title: "Dry Cows",
                          value: "$dryCount",
                          startColor: const Color(0xFFE78368),
                          endColor: const Color(0xFFCB664B),
                          iconColor: Colors.white,
                          textColor: Colors.white,
                        ),
                        CowStatCard(
                          width: cardWidth,
                          icon: Icons.favorite,
                          title: "In Heat",
                          value: "$inHeatPercent%",
                          startColor: const Color(0xFFFFF5D9),
                          endColor: const Color(0xFFF8E8B5),
                          iconColor: const Color(0xFFE0AF1B),
                          textColor: const Color(0xFF6B4A2B),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                _buildCowListHeader(compact),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2DCDC)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(Icons.view_agenda_outlined,
                                color: Color(0xFF87808A)),
                            SizedBox(width: 10),
                            Icon(Icons.image_outlined,
                                color: Color(0xFF87808A)),
                            SizedBox(width: 10),
                            Icon(Icons.inventory_2_outlined,
                                color: Color(0xFF87808A)),
                            SizedBox(width: 10),
                            Icon(Icons.view_headline,
                                color: Color(0xFF87808A)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      compact
                          ? Column(
                              children: filteredCows
                                  .map(
                                    (cow) => _CowMobileCard(
                                      cow: cow,
                                      onEdit: () => _showCowDialog(cow),
                                    ),
                                  )
                                  .toList(),
                            )
                          : Column(
                              children: [
                                const _CowTableHeader(),
                                ...filteredCows.map(
                                  (cow) => _CowTableRow(
                                    cow: cow,
                                    onEdit: () => _showCowDialog(cow),
                                  ),
                                ),
                              ],
                            ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: compact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Showing ${filteredCows.length} cows",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF534A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const _CowPagination(),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    "Showing ${filteredCows.length} cows",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF534A4A),
                                    ),
                                  ),
                                  const Spacer(),
                                  const _CowPagination(),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _CowDialogAction {
  cancel,
  saved,
  delete,
}

class _CowTableHeader extends StatelessWidget {
  const _CowTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text("ID", style: _tableHeaderStyle),
          ),
          Expanded(
            flex: 2,
            child: Text("Name", style: _tableHeaderStyle),
          ),
          Expanded(
            flex: 2,
            child: Text("Breed", style: _tableHeaderStyle),
          ),
          SizedBox(
            width: 90,
            child: Text("Age", style: _tableHeaderStyle),
          ),
          SizedBox(
            width: 160,
            child: Text("Status", style: _tableHeaderStyle),
          ),
          SizedBox(
            width: 170,
            child: Text("Health", style: _tableHeaderStyle),
          ),
          SizedBox(width: 84),
        ],
      ),
    );
  }
}

class _CowTableRow extends StatelessWidget {
  final CowModel cow;
  final VoidCallback onEdit;

  const _CowTableRow({
    required this.cow,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final healthColor = _healthColor(cow.health);
    final healthIcon = _healthIcon(cow.health);
    final statusColor = _statusColor(cow.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE9E2E2)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(cow.code, style: _tableCellStyle)),
          Expanded(flex: 2, child: Text(cow.name, style: _tableCellStyle)),
          Expanded(flex: 2, child: Text(cow.breed, style: _tableCellStyle)),
          SizedBox(width: 90, child: Text("${cow.age}", style: _tableCellStyle)),
          SizedBox(
            width: 160,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(
                label: cow.status,
                color: statusColor,
              ),
            ),
          ),
          SizedBox(
            width: 170,
            child: Row(
              children: [
                Icon(healthIcon, color: healthColor, size: 22),
                const SizedBox(width: 6),
                Text(
                  cow.health,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: healthColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 84,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                side: const BorderSide(color: Color(0xFFD5D0D7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF7F7A82),
              ),
              label: const Text(
                "Edit",
                style: TextStyle(color: Color(0xFF7F7A82)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CowMobileCard extends StatelessWidget {
  final CowModel cow;
  final VoidCallback onEdit;

  const _CowMobileCard({
    required this.cow,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final healthColor = _healthColor(cow.health);
    final healthIcon = _healthIcon(cow.health);
    final statusColor = _statusColor(cow.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE9E2E2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cow.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF322C37),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text("Edit"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("ID: ${cow.code}", style: _tableCellStyle),
          const SizedBox(height: 6),
          Text("Breed: ${cow.breed}", style: _tableCellStyle),
          const SizedBox(height: 6),
          Text("Age: ${cow.age}", style: _tableCellStyle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _StatusBadge(label: cow.status, color: statusColor),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(healthIcon, color: healthColor, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    cow.health,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: healthColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CowPagination extends StatelessWidget {
  const _CowPagination();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _PageButton(
          label: "Previous",
          backgroundColor: const Color(0xFFF3F0F2),
          textColor: const Color(0xFF655C63),
          borderColor: const Color(0xFFD9D3D8),
        ),
        _PageButton(
          label: "1",
          backgroundColor: const Color(0xFF5F8A51),
          textColor: Colors.white,
          borderColor: const Color(0xFF5F8A51),
        ),
        _IconPageButton(
          icon: Icons.chevron_right,
          backgroundColor: const Color(0xFFF3F0F2),
          iconColor: const Color(0xFF655C63),
        ),
        _PageButton(
          label: "Next",
          backgroundColor: const Color(0xFFF3F0F2),
          textColor: const Color(0xFF655C63),
          borderColor: const Color(0xFFD9D3D8),
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _PageButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _IconPageButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _IconPageButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D3D8)),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'milking':
      return const Color(0xFF5E8E52);
    case 'dry':
      return const Color(0xFFD06E55);
    default:
      return const Color(0xFF6A9C5F);
  }
}

Color _healthColor(String health) {
  switch (health.toLowerCase()) {
    case 'in heat':
      return const Color(0xFFDAA313);
    default:
      return const Color(0xFF4E8A4F);
  }
}

IconData _healthIcon(String health) {
  switch (health.toLowerCase()) {
    case 'in heat':
      return Icons.thermostat_rounded;
    default:
      return Icons.check_circle;
  }
}

const TextStyle _tableHeaderStyle = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.bold,
  color: Color(0xFF5A545F),
);

const TextStyle _tableCellStyle = TextStyle(
  fontSize: 17,
  color: Color(0xFF3B333D),
);
