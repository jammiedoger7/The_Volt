import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/outfit_provider.dart';
import '../../models/outfit.dart';
import '../../services/outfit_generator.dart';
import '../../models/weather_data.dart';
import '../../widgets/generator/outfit_result_card.dart';
import 'calendar_screen.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  bool _isGenerating = false;
  Outfit? _generatedOutfit;
  String? _selectedOccasion;
  List<Outfit> _generatedOutfits = [];

  final _occasions = ['Casual', 'Work', 'Gym', 'Date Night', 'Formal', 'Travel'];

  Future<void> _generateOutfit() async {
    final wardrobe = ref.read(wardrobeProvider).valueOrNull;
    final weather = ref.read(weatherProvider).valueOrNull;

    if (wardrobe == null || wardrobe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add items to your wardrobe first!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Use local generator first (no API dependency)
      final outfit = OutfitGenerator.instance.generateOutfit(
        wardrobe: wardrobe,
        weather: weather ?? WeatherData(temperature: 18, condition: 'Unknown', humidity: 50, windSpeed: 0, description: ''),
        preferredStyles: [],
        occasion: _selectedOccasion,
      );

      setState(() {
        _generatedOutfits = [outfit];
        _generatedOutfit = outfit;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateMore() async {
    final wardrobe = ref.read(wardrobeProvider).valueOrNull;
    final weather = ref.read(weatherProvider).valueOrNull;

    if (wardrobe == null || wardrobe.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      final outfit = OutfitGenerator.instance.generateOutfit(
        wardrobe: wardrobe,
        weather: weather ?? WeatherData(temperature: 18, condition: 'Unknown', humidity: 50, windSpeed: 0, description: ''),
        preferredStyles: [],
        occasion: _selectedOccasion,
      );

      setState(() {
        _generatedOutfits.add(outfit);
        _generatedOutfit = outfit;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveOutfit() async {
    if (_generatedOutfit == null) return;

    try {
      await ref.read(outfitProvider.notifier).saveOutfit(_generatedOutfit!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outfit saved!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _rateOutfit(int rating) async {
    if (_generatedOutfit == null) return;

    try {
      await ref.read(outfitProvider.notifier).rateOutfit(_generatedOutfit!.id, rating);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);
    final weather = ref.watch(weatherProvider);
    final itemCount = wardrobe.valueOrNull?.length ?? 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Outfit Generator',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarScreen()),
                  ),
                  icon: const Icon(Icons.calendar_today, color: AppColors.electricBlue),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Weather + item count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                weather.when(
                  data: (w) => w != null
                      ? Text(
                          '${w.temperature.round()}°C - ${w.condition}',
                          style: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
                        )
                      : const Text('Weather loading...', style: TextStyle(color: AppColors.mediumGray, fontSize: 14)),
                  loading: () => const Text('', style: TextStyle(fontSize: 14)),
                  error: (_, __) => const Text('', style: TextStyle(fontSize: 14)),
                ),
                const Text('  |  ', style: TextStyle(color: AppColors.mediumGray)),
                Text(
                  '$itemCount items',
                  style: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Occasion chips
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _occasions.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedOccasion == _occasions[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(_occasions[index]),
                      onSelected: (_) => setState(() {
                        _selectedOccasion = isSelected ? null : _occasions[index];
                      }),
                      selectedColor: AppColors.electricBlue,
                      backgroundColor: AppColors.darkGray,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.matteBlack : AppColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Outfit result or placeholder
            Expanded(
              child: _generatedOutfit != null
                  ? OutfitResultCard(
                      outfit: _generatedOutfit!,
                      onSave: _saveOutfit,
                      onRate: _rateOutfit,
                      onRegenerate: _generateMore,
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.electricBlue.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isGenerating ? Icons.hourglass_empty : Icons.checkroom,
                            size: 64,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isGenerating ? 'Generating outfit...' : 'Your outfit will appear here',
                            style: const TextStyle(color: AppColors.mediumGray, fontSize: 16),
                          ),
                          if (!_isGenerating && itemCount == 0) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Add items to your wardrobe first',
                              style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateOutfit,
                icon: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.matteBlack),
                      )
                    : const Icon(Icons.auto_awesome, color: AppColors.matteBlack),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Outfit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
