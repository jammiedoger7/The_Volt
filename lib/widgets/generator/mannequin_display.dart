import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MannequinDisplay extends StatelessWidget {
  final String? topId;
  final String? bottomId;
  final String? shoesId;
  final String? outerwearId;
  final List<String> accessoryIds;

  const MannequinDisplay({
    super.key,
    this.topId,
    this.bottomId,
    this.shoesId,
    this.outerwearId,
    this.accessoryIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MannequinSlot(
          label: outerwearId != null ? 'Outerwear' : null,
          icon: Icons.ac_unit,
          isActive: outerwearId != null,
        ),
        const SizedBox(height: 4),
        _MannequinSlot(
          label: topId != null ? 'Top' : null,
          icon: Icons.checkroom,
          isActive: topId != null,
        ),
        const SizedBox(height: 4),
        _MannequinSlot(
          label: bottomId != null ? 'Bottom' : null,
          icon: Icons.checkroom,
          isActive: bottomId != null,
        ),
        const SizedBox(height: 4),
        _MannequinSlot(
          label: shoesId != null ? 'Shoes' : null,
          icon: Icons.directions_walk,
          isActive: shoesId != null,
        ),
        if (accessoryIds.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              accessoryIds.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.diamond,
                  size: 16,
                  color: AppColors.electricBlue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MannequinSlot extends StatelessWidget {
  final String? label;
  final IconData icon;
  final bool isActive;

  const _MannequinSlot({
    this.label,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.electricBlue.withOpacity(0.1)
            : AppColors.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.electricBlue.withOpacity(0.3)
              : AppColors.mediumGray.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: label != null
            ? Text(
                label!,
                style: const TextStyle(
                  color: AppColors.electricBlue,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Icon(icon, color: AppColors.mediumGray.withOpacity(0.3), size: 24),
      ),
    );
  }
}
