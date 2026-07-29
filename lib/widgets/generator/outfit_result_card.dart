import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/outfit.dart';

class OutfitResultCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onSave;
  final Function(int)? onRate;
  final VoidCallback? onRegenerate;

  const OutfitResultCard({
    super.key,
    required this.outfit,
    this.onSave,
    this.onRate,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.electricBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Outfit items display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
              _OutfitSlot(
                label: 'Top',
                hasItem: outfit.topId != null,
              ),
              _OutfitSlot(
                label: 'Bottom',
                hasItem: outfit.bottomId != null,
              ),
              _OutfitSlot(
                label: 'Shoes',
                hasItem: outfit.shoesId != null,
              ),
              if (outfit.outerwearId != null)
                _OutfitSlot(
                  label: 'Outer',
                  hasItem: true,
                ),
            ],
          ),
          if (outfit.accessoryIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${outfit.accessoryIds.length} accessory(ies)',
              style: const TextStyle(color: AppColors.electricBlue, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),

          // Weather info
          if (outfit.weatherCondition != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.matteBlack,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${outfit.temperature?.round() ?? "?"}°C - ${outfit.weatherCondition}',
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 12),
              ),
            ),

          const SizedBox(height: 16),

          // Feedback buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thumbs down
              _FeedbackButton(
                icon: Icons.thumb_down_outlined,
                isActive: outfit.rating != null && outfit.rating! <= 2,
                onTap: () => onRate?.call(1),
              ),
              const SizedBox(width: 24),
              // Thumbs up
              _FeedbackButton(
                icon: Icons.thumb_up_outlined,
                isActive: outfit.rating != null && outfit.rating! >= 4,
                onTap: () => onRate?.call(5),
              ),
              const SizedBox(width: 24),
              // Save
              _FeedbackButton(
                icon: outfit.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                isActive: outfit.isSaved,
                onTap: onSave,
              ),
              const SizedBox(width: 24),
              // Regenerate
              _FeedbackButton(
                icon: Icons.refresh,
                onTap: onRegenerate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutfitSlot extends StatelessWidget {
  final String label;
  final bool hasItem;

  const _OutfitSlot({required this.label, required this.hasItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: hasItem
                ? AppColors.electricBlue.withOpacity(0.1)
                : AppColors.matteBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasItem
                  ? AppColors.electricBlue.withOpacity(0.3)
                  : AppColors.mediumGray.withOpacity(0.2),
            ),
          ),
          child: Icon(
            label == 'Top'
                ? Icons.checkroom
                : label == 'Bottom'
                    ? Icons.checkroom
                    : label == 'Shoes'
                        ? Icons.directions_walk
                        : Icons.ac_unit,
            color: hasItem ? AppColors.electricBlue : AppColors.mediumGray.withOpacity(0.3),
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: hasItem ? AppColors.electricBlue : AppColors.mediumGray,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _FeedbackButton({
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.electricBlue.withOpacity(0.2)
              : AppColors.matteBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.electricBlue
                : AppColors.mediumGray.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.electricBlue : AppColors.mediumGray,
          size: 20,
        ),
      ),
    );
  }
}
