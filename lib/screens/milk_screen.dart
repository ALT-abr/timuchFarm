import "package:flutter/material.dart";
import 'package:timuchmilk/database/farm_repository.dart';
import 'package:timuchmilk/models/cow_model.dart';
import 'package:timuchmilk/models/milk_production_model.dart';
import 'package:timuchmilk/widgets/milk_cart.dart';
import 'package:timuchmilk/widgets/page_header_card.dart';
import 'package:timuchmilk/widgets/responsive_layout.dart';

class MilkPage extends StatefulWidget {
  const MilkPage({super.key});

  @override
  State<MilkPage> createState() => _MilkPageState();
}

class _MilkPageState extends State<MilkPage> {
  late Future<_MilkPageData> _pageDataFuture;
  String _selectedCowStatus = 'milking';
  _MilkChartRange _selectedChartRange = _MilkChartRange.day;
  static const int _recentSessionsLimit = 3;

  @override
  void initState() {
    super.initState();
    _refreshPage();
  }

  void _refreshPage() {
    _pageDataFuture = _loadData();
  }

  Future<_MilkPageData> _loadData() async {
    final repo = FarmRepository.instance;
    final results = await Future.wait([
      repo.getMilkProductions(),
      repo.getCows(),
    ]);

    return _MilkPageData(
      productions: results[0] as List<MilkProductionModel>,
      cows: results[1] as List<CowModel>,
    );
  }

  Future<void> _showAddMilkDialog() async {
    final quantityController = TextEditingController();
    String moment = 'morning';
    DateTime productionDate = DateTime.now();
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
              title: const Text('Add Milk Production'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Quantity (L)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: moment,
                        decoration: const InputDecoration(
                          labelText: 'Moment',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'morning',
                            child: Text('Morning'),
                          ),
                          DropdownMenuItem(
                            value: 'evening',
                            child: Text('Evening'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => moment = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: productionDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() => productionDate = picked);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFB9C5BC)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded),
                              const SizedBox(width: 10),
                              Text(
                                _formatDate(productionDate),
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
                    final quantity = double.tryParse(
                      quantityController.text.trim().replaceAll(',', '.'),
                    );

                    if (quantity == null || quantity <= 0) {
                      setDialogState(() {
                        errorText = 'Please enter a valid quantity.';
                      });
                      return;
                    }

                    await FarmRepository.instance.addMilkProduction(
                      MilkProductionModel(
                        quantity: quantity,
                        productionDate: productionDate,
                        moment: moment,
                      ),
                    );

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

    quantityController.dispose();

    if (created == true && mounted) {
      setState(_refreshPage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Milk production added successfully.'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _showAllMilkSessionsDialog(
    List<MilkProductionModel> productions,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('All Milking Sessions'),
          content: SizedBox(
            width: 640,
            child: productions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No milk production recorded yet.',
                      style: TextStyle(
                        color: Color.fromARGB(255, 118, 118, 118),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 42,
                      dataRowMinHeight: 38,
                      dataRowMaxHeight: 46,
                      horizontalMargin: 10,
                      columnSpacing: 28,
                      columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Moment")),
                        DataColumn(label: Text("Milk Produced")),
                      ],
                      rows: productions
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(_formatDate(item.productionDate))),
                                DataCell(Text(_momentLabel(item.moment))),
                                DataCell(Text("${item.quantity.round()} L")),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool cards3InRow = screenWidth > 1200;
    final bool cards2InRow = screenWidth > 900 && screenWidth <= 1200;
    final bool stackedLayout = screenWidth < 1100;

    return ResponsiveLayout(
      title: "S T A T I S T I C",
      child: FutureBuilder<_MilkPageData>(
        future: _pageDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Database error: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeaderCard(
                  title: "Milk Tracking Page",
                  action: FilledButton.icon(
                    onPressed: _showAddMilkDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5E8E52),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(190, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      "Add Milk Production",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEAF3EE),
                      Color(0xFFF1F6F4),
                      Color(0xFFF7F9F8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  titleColor: const Color.fromARGB(255, 90, 104, 98),
                  descriptionColor: const Color.fromARGB(255, 90, 104, 98),
                  spacing: 12,
                  runSpacing: 12,
                  titleStyle: const TextStyle(
                    color: Color.fromARGB(255, 90, 104, 98),
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: stackedLayout
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLeftSection(
                                cards3InRow,
                                cards2InRow,
                                data.productions,
                              ),
                              const SizedBox(height: 14),
                              _buildRightSection(false, data),
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildLeftSection(
                                cards3InRow,
                                cards2InRow,
                                data.productions,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 3,
                              child: _buildRightSection(true, data),
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

  Widget _buildLeftSection(
    bool cards3InRow,
    bool cards2InRow,
    List<MilkProductionModel> productions,
  ) {
    final totalProduced = productions.fold<double>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final lastProduced = productions.isEmpty ? 0 : productions.first.quantity;
    final averageProduced =
        productions.isEmpty ? 0 : totalProduced / productions.length;
    final chartData = _buildMilkChartData(productions);
    final selectedPointIndex = _resolveHighlightedIndex(chartData.values);
    final selectedPointLabel = chartData.labels.isEmpty
        ? '-'
        : chartData.labels[selectedPointIndex];
    final selectedPointValue = chartData.values.isEmpty
        ? 0
        : chartData.values[selectedPointIndex].round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (cards3InRow) {
              return Row(
                children: [
                  Expanded(
                    child: MilkCart(
                      icon: Icons.water_drop,
                      iconColor: const Color.fromARGB(255, 70, 135, 97),
                      title: "Total Milk Produced",
                      titleColor: Colors.blueGrey,
                      value: totalProduced.round(),
                      valueColor: const Color.fromARGB(255, 45, 45, 45),
                      valueSigne: "L",
                      cardColor: const Color.fromARGB(255, 133, 181, 144),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MilkCart(
                      icon: Icons.opacity,
                      iconColor: const Color.fromARGB(255, 85, 145, 194),
                      title: "Milk Produced",
                      titleColor: Colors.blueGrey,
                      value: lastProduced.round(),
                      valueColor: const Color.fromARGB(255, 45, 45, 45),
                      valueSigne: "L",
                      cardColor: const Color.fromARGB(255, 171, 202, 227),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MilkCart(
                      icon: Icons.bar_chart,
                      iconColor: const Color.fromARGB(255, 86, 144, 138),
                      title: "Average Daily",
                      titleColor: Colors.blueGrey,
                      value: averageProduced.round(),
                      valueColor: const Color.fromARGB(255, 45, 45, 45),
                      valueSigne: "L",
                      cardColor: const Color.fromARGB(255, 192, 220, 217),
                    ),
                  ),
                ],
              );
            }

            if (cards2InRow) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MilkCart(
                          icon: Icons.water_drop,
                          iconColor: const Color.fromARGB(255, 70, 135, 97),
                          title: "Total Milk Produced",
                          titleColor: Colors.blueGrey,
                          value: totalProduced.round(),
                          valueColor: const Color.fromARGB(255, 45, 45, 45),
                          valueSigne: "L",
                          cardColor: const Color.fromARGB(255, 133, 181, 144),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MilkCart(
                          icon: Icons.opacity,
                          iconColor: const Color.fromARGB(255, 85, 145, 194),
                          title: "Milk Produced",
                          titleColor: Colors.blueGrey,
                          value: lastProduced.round(),
                          valueColor: const Color.fromARGB(255, 45, 45, 45),
                          valueSigne: "L",
                          cardColor: const Color.fromARGB(255, 171, 202, 227),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MilkCart(
                    icon: Icons.bar_chart,
                    iconColor: const Color.fromARGB(255, 86, 144, 138),
                    title: "Average Daily",
                    titleColor: Colors.blueGrey,
                    value: averageProduced.round(),
                    valueColor: const Color.fromARGB(255, 45, 45, 45),
                    valueSigne: "L",
                    cardColor: const Color.fromARGB(255, 192, 220, 217),
                  ),
                ],
              );
            }

            return Column(
              children: [
                MilkCart(
                  icon: Icons.water_drop,
                  iconColor: const Color.fromARGB(255, 70, 135, 97),
                  title: "Total Milk Produced",
                  titleColor: Colors.blueGrey,
                  value: totalProduced.round(),
                  valueColor: const Color.fromARGB(255, 45, 45, 45),
                  valueSigne: "L",
                  cardColor: const Color.fromARGB(255, 133, 181, 144),
                ),
                const SizedBox(height: 12),
                MilkCart(
                  icon: Icons.opacity,
                  iconColor: const Color.fromARGB(255, 85, 145, 194),
                  title: "Milk Produced",
                  titleColor: Colors.blueGrey,
                  value: lastProduced.round(),
                  valueColor: const Color.fromARGB(255, 45, 45, 45),
                  valueSigne: "L",
                  cardColor: const Color.fromARGB(255, 171, 202, 227),
                ),
                const SizedBox(height: 12),
                MilkCart(
                  icon: Icons.bar_chart,
                  iconColor: const Color.fromARGB(255, 86, 144, 138),
                  title: "Average Daily",
                  titleColor: Colors.blueGrey,
                  value: averageProduced.round(),
                  valueColor: const Color.fromARGB(255, 45, 45, 45),
                  valueSigne: "L",
                  cardColor: const Color.fromARGB(255, 192, 220, 217),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 480,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Milk Production Overview",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 45, 45, 45),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Spacer(),
                      _periodButton(
                        "Day",
                        _selectedChartRange == _MilkChartRange.day,
                        () {
                          setState(() {
                            _selectedChartRange = _MilkChartRange.day;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _periodButton(
                        "Month",
                        _selectedChartRange == _MilkChartRange.month,
                        () {
                          setState(() {
                            _selectedChartRange = _MilkChartRange.month;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _periodButton(
                        "Year",
                        _selectedChartRange == _MilkChartRange.year,
                        () {
                          setState(() {
                            _selectedChartRange = _MilkChartRange.year;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  painter: _MilkLinePainter(
                                    values: chartData.values,
                                    labels: chartData.labels,
                                    highlightedIndex: selectedPointIndex,
                                  ),
                                  child: Container(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 107, 164, 112),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Milk Produced (L)",
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F4EE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$selectedPointLabel: $selectedPointValue L',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 71, 93, 77),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Container(
                          width: 1,
                          color: Colors.grey.withOpacity(0.25),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_drink_outlined,
                                size: 70,
                                color: Colors.blueGrey.withOpacity(0.7),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Milk Quality",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 107, 164, 112),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("A Quality"),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 186, 214, 181),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("B Quality"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightSection(bool expandTableCard, _MilkPageData data) {
    final milkingCount =
        data.cows.where((cow) => cow.status.toLowerCase() == 'milking').length;
    final dryCount =
        data.cows.where((cow) => cow.status.toLowerCase() == 'dry').length;
    final totalForPie = milkingCount + dryCount;
    final pieValue = totalForPie == 0 ? 0.5 : milkingCount / totalForPie;
    final bool milkingSelected = _selectedCowStatus == 'milking';
    final int selectedCount = milkingSelected ? milkingCount : dryCount;
    final String selectedLabel = milkingSelected ? 'Milking' : 'Dry';
    final double selectedPercent = totalForPie == 0
        ? 0
        : (selectedCount / totalForPie) * 100;
    final recentProductions =
        data.productions.take(_recentSessionsLimit).toList();
    final hasMoreSessions = data.productions.length > _recentSessionsLimit;

    final recentCard = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: expandTableCard ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                "Recent Milking Sessions",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              ),
              const SizedBox(height: 10),
              Flexible(
                fit: expandTableCard ? FlexFit.tight : FlexFit.loose,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 42,
                    dataRowMinHeight: 32,
                    dataRowMaxHeight: 40,
                    horizontalMargin: 10,
                    columnSpacing: 30,
                    columns: const [
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Moment")),
                      DataColumn(label: Text("Milk Produced")),
                    ],
                    rows: recentProductions
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  "${item.productionDate.day.toString().padLeft(2, '0')}/${item.productionDate.month.toString().padLeft(2, '0')}/${item.productionDate.year}",
                                ),
                              ),
                              DataCell(Text(_momentLabel(item.moment))),
                              DataCell(Text("${item.quantity.round()} L")),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              if (recentProductions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "No milk production recorded yet.",
                  style: TextStyle(
                    color: Color.fromARGB(255, 118, 118, 118),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (hasMoreSessions || recentProductions.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showAllMilkSessionsDialog(data.productions),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: Color.fromARGB(255, 58, 115, 79),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Cow Milking",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(180, 180),
                          painter: _PieChartPainter(
                            value: pieValue,
                            selectedSegment: _selectedCowStatus,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${selectedPercent.round()}%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 55, 66, 61),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 90, 104, 98),
                              ),
                            ),
                            Text(
                              '$selectedCount cows',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 118, 118, 118),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CowStatusLegendButton(
                        label: 'Milking',
                        count: milkingCount,
                        color: const Color.fromARGB(255, 54, 155, 88),
                        selected: milkingSelected,
                        onTap: () {
                          setState(() {
                            _selectedCowStatus = 'milking';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CowStatusLegendButton(
                        label: 'Dry',
                        count: dryCount,
                        color: const Color.fromARGB(255, 219, 184, 28),
                        selected: !milkingSelected,
                        onTap: () {
                          setState(() {
                            _selectedCowStatus = 'dry';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (expandTableCard)
          Expanded(child: recentCard)
        else
          recentCard,
      ],
    );
  }

  _MilkChartData _buildMilkChartData(List<MilkProductionModel> productions) {
    switch (_selectedChartRange) {
      case _MilkChartRange.day:
        return _buildDayChartData(productions);
      case _MilkChartRange.month:
        return _buildMonthChartData(productions);
      case _MilkChartRange.year:
        return _buildYearChartData(productions);
    }
  }

  _MilkChartData _buildDayChartData(List<MilkProductionModel> productions) {
    final now = DateTime.now();
    double morning = 0;
    double evening = 0;

    for (final item in productions) {
      if (item.productionDate.year != now.year ||
          item.productionDate.month != now.month ||
          item.productionDate.day != now.day) {
        continue;
      }

      if (item.moment.toLowerCase() == 'morning') {
        morning += item.quantity;
      } else if (item.moment.toLowerCase() == 'evening') {
        evening += item.quantity;
      }
    }

    return _MilkChartData(
      labels: const ['Morning', 'Evening'],
      values: [morning, evening],
    );
  }

  _MilkChartData _buildMonthChartData(List<MilkProductionModel> productions) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final labels = <String>[];
    final values = <double>[];

    for (int day = 1; day <= daysInMonth; day++) {
      labels.add(day.toString());
      final total = productions
          .where(
            (item) =>
                item.productionDate.year == now.year &&
                item.productionDate.month == now.month &&
                item.productionDate.day == day,
          )
          .fold<double>(0, (sum, item) => sum + item.quantity);
      values.add(total);
    }

    return _MilkChartData(labels: labels, values: values);
  }

  _MilkChartData _buildYearChartData(List<MilkProductionModel> productions) {
    final now = DateTime.now();
    const labels = [
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
    final values = <double>[];

    for (int month = 1; month <= 12; month++) {
      final total = productions
          .where(
            (item) =>
                item.productionDate.year == now.year &&
                item.productionDate.month == month,
          )
          .fold<double>(0, (sum, item) => sum + item.quantity);
      values.add(total);
    }

    return _MilkChartData(labels: labels, values: values);
  }

  int _resolveHighlightedIndex(List<double> values) {
    for (int index = values.length - 1; index >= 0; index--) {
      if (values[index] > 0) {
        return index;
      }
    }

    return values.isEmpty ? 0 : values.length - 1;
  }

  Widget _periodButton(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromARGB(255, 132, 181, 132)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color.fromARGB(255, 132, 181, 132)
                : Colors.grey.withOpacity(0.25),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? Colors.white
                : const Color.fromARGB(255, 90, 90, 90),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _momentLabel(String moment) {
    switch (moment.toLowerCase()) {
      case 'morning':
      case 'matin':
        return 'Morning';
      case 'evening':
      case 'soir':
        return 'Evening';
      default:
        return moment;
    }
  }
}

class _MilkPageData {
  final List<MilkProductionModel> productions;
  final List<CowModel> cows;

  const _MilkPageData({
    required this.productions,
    required this.cows,
  });
}

class _PieChartPainter extends CustomPainter {
  final double value;
  final String selectedSegment;

  _PieChartPainter({
    required this.value,
    required this.selectedSegment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool milkingSelected = selectedSegment == 'milking';
    final Paint aPaint = Paint()
      ..color = milkingSelected
          ? const Color.fromARGB(255, 54, 155, 88)
          : const Color.fromARGB(255, 54, 155, 88).withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    final Paint bPaint = Paint()
      ..color = milkingSelected
          ? const Color.fromARGB(255, 219, 184, 28).withOpacity(0.45)
          : const Color.fromARGB(255, 219, 184, 28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    final Paint trackPaint = Paint()
      ..color = const Color.fromARGB(255, 230, 235, 232)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.6;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final double mainAngle = 2 * 3.141592653589793 * value;
    const double startAngle = -3.141592653589793 / 2;

    canvas.drawArc(rect, 0, 2 * 3.141592653589793, false, trackPaint);
    canvas.drawArc(rect, startAngle, mainAngle, false, aPaint);
    canvas.drawArc(
      rect,
      startAngle + mainAngle,
      2 * 3.141592653589793 - mainAngle,
      false,
      bPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.selectedSegment != selectedSegment;
  }
}

class _CowStatusLegendButton extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CowStatusLegendButton({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : const Color.fromARGB(255, 223, 223, 223),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label ($count)',
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilkChartData {
  final List<String> labels;
  final List<double> values;

  const _MilkChartData({
    required this.labels,
    required this.values,
  });
}

enum _MilkChartRange {
  day,
  month,
  year,
}

class _MilkLinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final int highlightedIndex;

  _MilkLinePainter({
    required this.values,
    required this.labels,
    required this.highlightedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || labels.isEmpty) {
      return;
    }

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.18)
      ..strokeWidth = 1;

    final Paint linePaint = Paint()
      ..color = const Color.fromARGB(255, 104, 164, 112)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = const Color.fromARGB(255, 104, 164, 112).withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final Paint pointPaint = Paint()
      ..color = const Color.fromARGB(255, 104, 164, 112)
      ..style = PaintingStyle.fill;

    const double leftPad = 40;
    const double bottomPad = 35;
    const double topPad = 12;
    final double chartWidth = size.width - leftPad - 10;
    final double chartHeight = size.height - topPad - bottomPad;
    final double peakValue = values.reduce((a, b) => a > b ? a : b);
    final double maxValue =
        peakValue <= 0 ? 100.0 : (peakValue * 1.2).ceilToDouble();

    for (int i = 0; i < 4; i++) {
      final y = topPad + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartWidth, y),
        gridPaint,
      );
    }

    final int segmentCount = values.length > 1 ? values.length - 1 : 1;

    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (chartWidth / segmentCount) * i;
      canvas.drawLine(
        Offset(x, topPad),
        Offset(x, topPad + chartHeight),
        gridPaint,
      );
    }

    final points = List<Offset>.generate(values.length, (index) {
      final normalized = (values[index] / maxValue).clamp(0.0, 1.0);
      final x = values.length == 1
          ? leftPad + (chartWidth / 2)
          : leftPad + (chartWidth / segmentCount) * index;
      final y = topPad + chartHeight - (chartHeight * normalized);
      return Offset(x, y);
    });

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final controlX = (prev.dx + curr.dx) / 2;
      path.cubicTo(controlX, prev.dy, controlX, curr.dy, curr.dx, curr.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, topPad + chartHeight)
      ..lineTo(points.first.dx, topPad + chartHeight)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    for (int index = 0; index < points.length; index++) {
      final point = points[index];
      canvas.drawCircle(point, index == highlightedIndex ? 6 : 5, pointPaint);
    }

    final textStyle = TextStyle(color: Colors.blueGrey, fontSize: 12);
    final yLabels = List<String>.generate(
      4,
      (index) => '${(maxValue - ((maxValue / 3) * index)).round()} L',
    );

    for (int i = 0; i < yLabels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = topPad + (chartHeight / 3) * i - 8;
      tp.paint(canvas, Offset(0, y));
    }

    for (int i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = values.length == 1
          ? leftPad + (chartWidth / 2) - (tp.width / 2)
          : leftPad + (chartWidth / segmentCount) * i - (tp.width / 2);
      tp.paint(canvas, Offset(x, topPad + chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _MilkLinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.highlightedIndex != highlightedIndex;
  }
}
