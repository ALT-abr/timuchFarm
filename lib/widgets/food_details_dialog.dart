import 'package:flutter/material.dart';
import 'package:timuchmilk/models/food_model.dart';

class FoodDetailsDialog extends StatelessWidget {
  final FoodModel food;
  final String purchaseDateLabel;
  final String quantityBoughtLabel;
  final String unitPriceLabel;
  final String totalPriceLabel;
  final String dailyConsumptionLabel;
  final String daysLeftLabel;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FoodDetailsDialog({
    super.key,
    required this.food,
    required this.purchaseDateLabel,
    required this.quantityBoughtLabel,
    required this.unitPriceLabel,
    required this.totalPriceLabel,
    required this.dailyConsumptionLabel,
    required this.daysLeftLabel,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeftValue = int.tryParse(daysLeftLabel.split(' ').first) ?? 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        food.name,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E3B22),
        ),
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stock details',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6C7561),
                ),
              ),
              const SizedBox(height: 18),
              _FoodDetailRow(label: 'Product name', value: food.name),
              _FoodDetailRow(
                label: 'Purchase date',
                value: purchaseDateLabel,
              ),
              _FoodDetailRow(
                label: 'Quantity bought',
                value: quantityBoughtLabel,
              ),
              _FoodDetailRow(
                label: 'Unit price',
                value: unitPriceLabel,
              ),
              _FoodDetailRow(
                label: 'Total price',
                value: totalPriceLabel,
              ),
              _FoodDetailRow(
                label: 'Daily consumption',
                value: dailyConsumptionLabel,
              ),
              _FoodDetailRow(
                label: 'Days left',
                value: daysLeftLabel,
                highlight: daysLeftValue <= 7,
              ),
              _FoodDetailRow(label: 'Category', value: food.category),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            FilledButton.tonal(
              onPressed: onEdit,
              child: const Text('Edit'),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onDelete,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB64034),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClose,
              child: const Text('Close'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FoodDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _FoodDetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFFFFF2E8)
              : const Color(0xFFF7F7F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight
                ? const Color(0xFFE8B17A)
                : const Color(0xFFE1E4D8),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF66705E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: highlight
                      ? const Color(0xFF9A4F18)
                      : const Color(0xFF2E3B22),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
