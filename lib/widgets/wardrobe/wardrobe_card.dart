import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class WardrobeCard extends StatelessWidget {
  final String name;
  final String category;
  final String? imageUrl;
  final String? color;
  final VoidCallback? onTap;

  const WardrobeCard({
    super.key,
    required this.name,
    required this.category,
    this.imageUrl,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.matteBlack,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: imageUrl != null
                    ? Image.network(imageUrl!, fit: BoxFit.contain)
                    : const Icon(
                        Icons.checkroom,
                        size: 48,
                        color: AppColors.mediumGray,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.mediumGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
