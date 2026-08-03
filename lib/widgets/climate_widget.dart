import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ClimateWidget extends StatelessWidget {
  final double temperature;
  final double humidity;

  const ClimateWidget({
    super.key,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3), // Light Yellow
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEF08A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.sun, color: Color(0xFFD97706), size: 16),
          const SizedBox(width: 4),
          Text(
            '$temperature°C',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF92400E)),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.droplets, color: Color(0xFFD97706), size: 16),
          const SizedBox(width: 4),
          Text(
            '$humidity%',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF92400E)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Monitor',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
            ),
          ),
        ],
      ),
    );
  }
}
