import 'package:flutter/material.dart';
import 'package:timuchmilk/database/farm_repository.dart';
import 'package:timuchmilk/models/food_model.dart';
import 'package:timuchmilk/widgets/food_card.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late Future<List<FoodModel>> _foodsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedUnitFilter = 'All';

  @override
  void initState() {
    super.initState();
    _refreshFoods();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _refreshFoods() {
    _foodsFuture = FarmRepository.instance.getFoods();
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

  Future<void> _showAddFoodDialog() async {
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final unitPriceController = TextEditingController();
    final dailyConsumptionController = TextEditingController();
    String unit = 'Kg';
    String category = 'Fourrage';
    DateTime purchaseDate = DateTime.now();
    String? errorText;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text('Add New Stock'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Food name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: stockController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: unit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                          DropdownMenuItem(value: 'Botte', child: Text('Botte')),
                          DropdownMenuItem(value: 'Sac', child: Text('Sac')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => unit = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Fourrage',
                            child: Text('Fourrage'),
                          ),
                          DropdownMenuItem(
                            value: 'Concentre',
                            child: Text('Concentre'),
                          ),
                          DropdownMenuItem(
                            value: 'Complement',
                            child: Text('Complement'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => category = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: unitPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Unit price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dailyConsumptionController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Daily consumption',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: purchaseDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() => purchaseDate = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD0D6C6)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded),
                              const SizedBox(width: 10),
                              Text(
                                _formatDate(purchaseDate),
                                style: const TextStyle(fontSize: 16),
                              ),
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
                    final name = nameController.text.trim();
                    final stock = double.tryParse(
                      stockController.text.trim().replaceAll(',', '.'),
                    );
                    final unitPrice = double.tryParse(
                      unitPriceController.text.trim().replaceAll(',', '.'),
                    );
                    final dailyConsumption = double.tryParse(
                      dailyConsumptionController.text
                          .trim()
                          .replaceAll(',', '.'),
                    );

                    if (name.isEmpty ||
                        stock == null ||
                        stock <= 0 ||
                        unitPrice == null ||
                        unitPrice < 0 ||
                        dailyConsumption == null ||
                        dailyConsumption <= 0) {
                      setDialogState(() {
                        errorText =
                            'Please fill in name, stock, unit price, and daily consumption correctly.';
                      });
                      return;
                    }

                    try {
                      await FarmRepository.instance.addFood(
                        FoodModel(
                          name: name,
                          stock: stock,
                          unit: unit,
                          category: category,
                          purchaseDate: purchaseDate,
                          unitPrice: unitPrice,
                          dailyConsumption: dailyConsumption,
                        ),
                      );
                    } catch (_) {
                      setDialogState(() {
                        errorText =
                            'Food name already exists or the data is invalid.';
                      });
                      return;
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

    nameController.dispose();
    stockController.dispose();
    unitPriceController.dispose();
    dailyConsumptionController.dispose();

    if (created == true && mounted) {
      setState(_refreshFoods);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food stock added successfully.'),
        ),
      );
    }
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
      title: "F O O D",
      child: FutureBuilder<List<FoodModel>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database error: ${snapshot.error}'));
          }

          final foods = snapshot.data ?? const <FoodModel>[];
          final filteredFoods = foods.where((food) {
            if (_searchQuery.isEmpty) {
              if (_selectedUnitFilter == 'All') {
                return true;
              }

              return food.unit.toLowerCase() ==
                  _selectedUnitFilter.toLowerCase();
            }

            final matchesName = food.name.toLowerCase().contains(_searchQuery);
            final matchesUnit = _selectedUnitFilter == 'All'
                ? true
                : food.unit.toLowerCase() ==
                    _selectedUnitFilter.toLowerCase();

            return matchesName && matchesUnit;
          }).toList();

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
                        Color(0xFFF2F0E7),
                        Color(0xFFE6F0D7),
                        Color(0xFFF8F3E6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 20,
                    runSpacing: 18,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Food Overview",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E5A20),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Track feed stock, daily usage, and refill urgency across the farm with one quick view.",
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.45,
                                color: Color(0xFF5A644C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _showAddFoodDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Add New Stock"),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4E7A33),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(180, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Feed Inventory",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3B22),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildSearchField(260),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Feed Inventory",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3B22),
                              ),
                            ),
                          ),
                          _buildSearchField(320),
                        ],
                      ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _FilterChipCard(
                      label: "All",
                      isActive: _selectedUnitFilter == 'All',
                      onTap: () => _setUnitFilter('All'),
                    ),
                    _FilterChipCard(
                      label: "Botte",
                      isActive: _selectedUnitFilter == 'Botte',
                      onTap: () => _setUnitFilter('Botte'),
                    ),
                    _FilterChipCard(
                      label: "Sac",
                      isActive: _selectedUnitFilter == 'Sac',
                      onTap: () => _setUnitFilter('Sac'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredFoods
                        .map(
                          (food) => FoodCard(
                            photo: food.photoPath ?? _foodImage(food.name),
                            icon: _foodIcon(food.category),
                            title: food.name,
                            value: food.stock.round(),
                            valueSign: food.unit,
                            subValue:
                                food.dailyConsumption.toStringAsFixed(2),
                            date: _daysLeft(food).toString(),
                            dayMonth: "days",
                            cardColor: _foodCardColor(food.category),
                            iconColor: _foodIconColor(food.category),
                            titleColor: _foodTitleColor(food.category),
                            valueColor: _foodValueColor(food.category),
                            subValueColor: const Color(0xFF796353),
                            dateColor: _foodValueColor(food.category),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _daysLeft(FoodModel food) {
    if (food.dailyConsumption <= 0) {
      return 0;
    }

    return (food.stock / food.dailyConsumption).floor();
  }

  Widget _buildSearchField(double width) {
    return SizedBox(
      width: width,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD9DCCC)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search feed...",
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF7E8772),
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: _searchController.clear,
                    icon: const Icon(Icons.close, size: 18),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  void _setUnitFilter(String value) {
    if (_selectedUnitFilter == value) {
      return;
    }

    setState(() {
      _selectedUnitFilter = value;
    });
  }

  String _foodImage(String name) {
    switch (name.toUpperCase()) {
      case 'THUGA':
        return "assets/images/tugha.jpg";
      case 'ALIM':
        return "assets/images/alim.jpg";
      case 'ALIMENT':
        return "assets/images/aliment.jpg";
      default:
        return "assets/images/jombo20.jpg";
    }
  }

  IconData _foodIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fourrage':
        return Icons.eco;
      case 'concentre':
        return Icons.inventory_2_outlined;
      default:
        return Icons.grass;
    }
  }

  Color _foodCardColor(String category) {
    switch (category.toLowerCase()) {
      case 'fourrage':
        return const Color(0xFFF8FBF2);
      case 'concentre':
        return const Color(0xFFFFF7F0);
      default:
        return const Color(0xFFFFFBEE);
    }
  }

  Color _foodIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'fourrage':
        return const Color(0xFF3D7A3E);
      case 'concentre':
        return const Color(0xFF95622C);
      default:
        return const Color(0xFFAC9F2D);
    }
  }

  Color _foodTitleColor(String category) {
    switch (category.toLowerCase()) {
      case 'fourrage':
        return const Color(0xFF1F5B1F);
      case 'concentre':
        return const Color(0xFF825220);
      default:
        return const Color(0xFF877A10);
    }
  }

  Color _foodValueColor(String category) {
    switch (category.toLowerCase()) {
      case 'fourrage':
        return const Color(0xFF2D5E30);
      case 'concentre':
        return const Color(0xFF6C4314);
      default:
        return const Color(0xFF6F6500);
    }
  }
}

class _FilterChipCard extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _FilterChipCard({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF587B39) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? const Color(0xFF587B39) : const Color(0xFFD9DCCC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF66705E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
