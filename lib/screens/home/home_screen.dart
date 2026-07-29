import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/weather_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        );
        ref.read(weatherProvider.notifier).loadWeather(
              position.latitude,
              position.longitude,
            );
      } else {
        ref.read(weatherProvider.notifier).loadByCity('London');
      }
    } catch (_) {
      ref.read(weatherProvider.notifier).loadByCity('London');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final wardrobe = ref.watch(wardrobeProvider);
    final weather = ref.watch(weatherProvider);

    final itemCount = wardrobe.valueOrNull?.length ?? 0;
    final displayName = profile.valueOrNull?.displayName ?? 'there';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadWeather();
          ref.read(wardrobeProvider.notifier).loadItems();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey, $displayName',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What are we wearing today?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.darkGray,
                    child: Icon(Icons.person, color: AppColors.electricBlue),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Weather card
              _WeatherCard(weather: weather),
              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  _StatCard(
                    icon: Icons.checkroom,
                    label: 'Wardrobe',
                    value: '$itemCount items',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.auto_awesome,
                    label: 'Pro',
                    value: profile.valueOrNull?.isPro == true ? 'Active' : 'Free',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _QuickActionCard(
                    icon: Icons.auto_awesome,
                    label: 'Generate Outfit',
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.camera_alt,
                    label: 'Scan Item',
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.checkroom,
                    label: 'My Wardrobe',
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.calendar_today,
                    label: 'Plan Week',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final AsyncValue weather;

  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: weather.when(
        data: (w) {
          if (w == null) {
            return const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, color: AppColors.matteBlack, size: 24),
                SizedBox(width: 8),
                Text('Weather unavailable', style: TextStyle(color: AppColors.matteBlack)),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      color: AppColors.matteBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    w.condition,
                    style: TextStyle(
                      color: AppColors.matteBlack.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${w.temperature.round()}\u00B0C',
                style: const TextStyle(
                  color: AppColors.matteBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(color: AppColors.matteBlack, strokeWidth: 2),
          ),
        ),
        error: (_, __) => const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: AppColors.matteBlack, size: 20),
            SizedBox(width: 8),
            Text('Weather unavailable', style: TextStyle(color: AppColors.matteBlack)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.electricBlue, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.mediumGray, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mediumGray.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.electricBlue, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
