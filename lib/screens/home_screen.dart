import 'package:flutter/material.dart';
import 'package:timuchmilk/database/farm_repository.dart';
import 'package:timuchmilk/models/cow_model.dart';
import 'package:timuchmilk/models/food_model.dart';
import 'package:timuchmilk/models/milk_production_model.dart';
import 'package:timuchmilk/models/note_model.dart';
import 'package:timuchmilk/screens/milk_screen.dart';
import 'package:timuchmilk/screens/note_screen.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';
import 'package:timuchmilk/widgets/statcard_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<_HomePageData> _pageDataFuture;

  @override
  void initState() {
    super.initState();
    _pageDataFuture = _loadData();
  }

  Future<_HomePageData> _loadData() async {
    final repo = FarmRepository.instance;
    final results = await Future.wait([
      repo.getCows(),
      repo.getFoods(),
      repo.getNotes(),
      repo.getMilkProductions(),
    ]);

    return _HomePageData(
      cows: results[0] as List<CowModel>,
      foods: results[1] as List<FoodModel>,
      notes: results[2] as List<NoteModel>,
      productions: results[3] as List<MilkProductionModel>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 1100;

    return ResponsiveLayout(
      title: "T I M U C H  F A R M",
      child: FutureBuilder<_HomePageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database error: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _WelcomeSection(),
                const SizedBox(height: 24),
                _StatsSection(data: data),
                const SizedBox(height: 18),
                if (isWideScreen)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _NotesCard(notes: data.notes)),
                      const SizedBox(width: 18),
                      Expanded(child: _ProductionCard(productions: data.productions)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _NotesCard(notes: data.notes),
                      const SizedBox(height: 18),
                      _ProductionCard(productions: data.productions),
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

class _HomePageData {
  final List<CowModel> cows;
  final List<FoodModel> foods;
  final List<NoteModel> notes;
  final List<MilkProductionModel> productions;

  const _HomePageData({
    required this.cows,
    required this.foods,
    required this.notes,
    required this.productions,
  });
}

class _HomeNoteItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;

  const _HomeNoteItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
  });
}

class _StatsSection extends StatelessWidget {
  final _HomePageData data;

  const _StatsSection({
    required this.data,
  });

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyMilk = data.productions
        .where(
          (item) =>
              item.productionDate.year == now.year &&
              item.productionDate.month == now.month,
        )
        .fold<int>(0, (sum, item) => sum + item.quantity.round());
    final totalCows = data.cows.length;
    final foodStock = data.foods.fold<int>(
      0,
      (sum, item) => sum + item.stock.round(),
    );
    final screenWidth = MediaQuery.of(context).size.width;
    final forceSingleRow = screenWidth >= 1180;

    final cards = [
      StatCardHomePage(
        icon: Icons.water_drop_outlined,
        title: "Total milk produce",
        value: monthlyMilk,
        valueSigne: "L",
        valueColor: Colors.white,
        subTitle: now.isAfter(startOfMonth) ? "this month" : "today",
        textColor: const Color.fromARGB(217, 4, 3, 3),
        color: const Color.fromARGB(215, 37, 69, 1),
      ),
      StatCardHomePage(
        icon: Icons.pets,
        title: "Total Cows",
        value: totalCows,
        valueSigne: "cows",
        valueColor: Colors.white,
        subTitle: "in the farm",
        textColor: const Color.fromARGB(255, 38, 27, 27),
        color: const Color.fromARGB(222, 171, 131, 98),
      ),
      StatCardHomePage(
        icon: Icons.grass,
        title: "Food stock",
        value: foodStock,
        valueSigne: "Kg",
        valueColor: Colors.white,
        subTitle: "available",
        textColor: const Color.fromARGB(255, 39, 23, 23),
        color: const Color.fromARGB(214, 171, 203, 135),
      ),
      StatCardHomePage(
        icon: Icons.calendar_month_rounded,
        title: "Today Date",
        value: now.day,
        valueSigne: _months[now.month - 1],
        valueColor: const Color.fromARGB(255, 43, 27, 27),
        subTitle: "${now.year}",
        textColor: const Color.fromARGB(255, 47, 28, 0),
        color: const Color.fromARGB(214, 194, 180, 128),
      ),
    ];

    if (forceSingleRow) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i != cards.length - 1) const SizedBox(width: 10),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: cards,
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 700;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 16,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6F8D42),
                Color(0xFF3A4F1C),
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
            Icons.agriculture_rounded,
            size: 58,
            color: Colors.white,
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to Timuch Farm !",
                style: TextStyle(
                  fontSize: compact ? 28 : 34,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF261A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Hello, it me TASEDA",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B1F1F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Her's an overview of your farm stats:",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B4A4A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Widget child;
  final String actionLabel;
  final VoidCallback? onActionPressed;

  const _DashboardPanel({
    required this.title,
    required this.titleColor,
    required this.child,
    required this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0x22000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 6,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  side: BorderSide(
                    color: Colors.brown.shade100,
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF5A3434),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final List<NoteModel> notes;

  const _NotesCard({
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final items = notes.take(5).map(_mapHomeNote).toList();

    return _DashboardPanel(
      title: "N O T E S",
      titleColor: const Color(0xFF5A3030),
      actionLabel: "View All Notes",
      onActionPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotePage()),
        );
      },
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotePage()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF0E7E0),
                foregroundColor: const Color(0xFF6D4D3B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add, size: 28),
              label: const Text(
                "Add New Note",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "No notes available.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7D7070),
                ),
              ),
            ),
          for (final note in items) ...[
            _NoteTile(
              icon: note.icon,
              iconColor: note.iconColor,
              title: note.title,
              date: note.date,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  _HomeNoteItem _mapHomeNote(NoteModel note) {
    final category = note.category.toLowerCase();

    IconData icon;
    Color iconColor;

    switch (category) {
      case 'urgent':
        icon = Icons.priority_high_rounded;
        iconColor = const Color(0xFFD75E4A);
        break;
      case 'planning':
        icon = Icons.calendar_month_rounded;
        iconColor = const Color(0xFFB5964A);
        break;
      case 'supply':
        icon = Icons.check_rounded;
        iconColor = const Color(0xFF6D9151);
        break;
      case 'maintenance':
        icon = Icons.build_circle_outlined;
        iconColor = const Color(0xFF6E86B2);
        break;
      default:
        icon = Icons.lightbulb_outline_rounded;
        iconColor = const Color(0xFFC59B3B);
        break;
    }

    return _HomeNoteItem(
      icon: icon,
      iconColor: iconColor,
      title: note.title,
      date:
          "${_monthLabel(note.dueDate.month)} ${note.dueDate.day}, ${note.dueDate.year}",
    );
  }

  String _monthLabel(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

class _NoteTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;

  const _NoteTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7DCDC)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotePage()),
          );
        },
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF322525),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFF9A8F95),
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFB3A8AF),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF322525),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFF9A8F95),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB3A8AF),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProductionCard extends StatefulWidget {
  final List<MilkProductionModel> productions;

  const _ProductionCard({
    required this.productions,
  });

  @override
  State<_ProductionCard> createState() => _ProductionCardState();
}

class _ProductionCardState extends State<_ProductionCard> {
  _ProductionRange _selectedRange = _ProductionRange.month;

  @override
  Widget build(BuildContext context) {
    final chartData = _selectedRange == _ProductionRange.month
        ? _buildWeeklyChartData(widget.productions)
        : _buildYearlyChartData(widget.productions);
    final totalValue = chartData.values.fold<double>(0, (sum, item) => sum + item);
    final selectedIndex = _resolveHighlightedIndex(chartData.values);
    final highlightedLabel = chartData.labels.isEmpty
        ? ''
        : chartData.labels[selectedIndex];
    final highlightedValue = chartData.values.isEmpty
        ? 0
        : chartData.values[selectedIndex].round();
    final summaryLabel = _selectedRange == _ProductionRange.month
        ? 'Total Milk Produced This Month:'
        : 'Total Milk Produced This Year:';

    return _DashboardPanel(
      title: "P R O D U C T I O N",
      titleColor: const Color(0xFF709293),
      actionLabel: "View Full Report",
      onActionPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MilkPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 8,
            spacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                summaryLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2323),
                ),
              ),
              Text(
                "${totalValue.round()} L",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF446132),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE6DCDC)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F1F1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabChip(
                          label: "Month",
                          isActive: _selectedRange == _ProductionRange.month,
                          onTap: () {
                            setState(() {
                              _selectedRange = _ProductionRange.month;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _TabChip(
                          label: "Year",
                          isActive: _selectedRange == _ProductionRange.year,
                          onTap: () {
                            setState(() {
                              _selectedRange = _ProductionRange.year;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _TooltipBox(
                          title: highlightedLabel,
                          value: "$highlightedValue L",
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 260,
                        child: _BarChart(
                          values: chartData.values,
                          labels: chartData.labels,
                          highlightedIndex: selectedIndex,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ChartData _buildWeeklyChartData(List<MilkProductionModel> productions) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final labels = <String>['W1', 'W2', 'W3', 'W4', 'W5'];
    final values = List<double>.filled(labels.length, 0);

    for (final item in productions) {
      final date = item.productionDate;
      if (date.isBefore(startOfMonth) || !date.isBefore(startOfNextMonth)) {
        continue;
      }

      final weekIndex = ((date.day - 1) ~/ 7).clamp(0, labels.length - 1);
      values[weekIndex] += item.quantity;
    }

    return _ChartData(
      labels: labels,
      values: values,
    );
  }

  _ChartData _buildYearlyChartData(List<MilkProductionModel> productions) {
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];

    for (int month = 1; month <= 12; month++) {
      labels.add(_monthLabel(month));
      final total = productions
          .where(
            (item) =>
                item.productionDate.year == now.year &&
                item.productionDate.month == month,
          )
          .fold<double>(0, (sum, item) => sum + item.quantity);
      values.add(total);
    }

    return _ChartData(labels: labels, values: values);
  }

  int _resolveHighlightedIndex(List<double> values) {
    for (int index = values.length - 1; index >= 0; index--) {
      if (values[index] > 0) {
        return index;
      }
    }

    return values.isEmpty ? 0 : values.length - 1;
  }

  String _monthLabel(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

class _ChartData {
  final List<double> values;
  final List<String> labels;

  const _ChartData({
    required this.values,
    required this.labels,
  });
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabChip({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF667B42) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isActive ? Colors.white : const Color(0xFF615356),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TooltipBox extends StatelessWidget {
  final String title;
  final String value;

  const _TooltipBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A2B2B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF53713A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final int highlightedIndex;

  const _BarChart({
    required this.values,
    required this.labels,
    required this.highlightedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final peakValue = values.isEmpty
        ? 100
        : values.reduce((a, b) => a > b ? a : b);
    final maxValue = peakValue <= 0 ? 100.0 : (peakValue * 1.2).ceilToDouble();
    final yLabels = List<int>.generate(
      6,
      (index) => ((maxValue / 5) * index).round(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: yLabels.reversed
                    .map(
                      (value) => Text(
                        "$value",
                        style: const TextStyle(
                          color: Color(0xFF857C82),
                          fontSize: 13,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFE7E0E0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(values.length, (index) {
                            final value = values[index];
                            final height = (value / maxValue) *
                                (constraints.maxHeight - 44);
                            final bool isHighlighted = index == highlightedIndex;

                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height:
                                          height.clamp(24.0, 190.0).toDouble(),
                                      decoration: BoxDecoration(
                                        color: isHighlighted
                                            ? const Color(0xFF5E7339)
                                            : const Color(0xFF8CA06E),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      labels[index],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isHighlighted
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: const Color(0xFF5A4A4A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _ProductionRange {
  month,
  year,
}
