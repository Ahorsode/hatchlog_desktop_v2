import 'package:flutter/material.dart';
import '../models/flock.dart';

class FlockCard extends StatelessWidget {
  final Flock flock;

  const FlockCard({super.key, required this.flock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                flock.id,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF034530)),
              ),
              _buildStatusBadge(flock.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${flock.breed} • ${flock.initialCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} birds',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${flock.currentAgeDays}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                'Target: ${flock.targetDays} Days',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (flock.currentAgeDays / flock.targetDays).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF017A3E),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetric('Mortality Rate', '${flock.mortalityRate.toStringAsFixed(1)}%'),
              const SizedBox(width: 48),
              _buildMetric('Est. FCR', flock.fcr.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'healthy':
        color = const Color(0xFF014722);
        break;
      case 'warning':
        color = const Color(0xFFE8833A);
        break;
      case 'critical':
        color = const Color(0xFFC53030);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }
}
