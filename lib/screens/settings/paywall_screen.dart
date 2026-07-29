import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../services/subscription_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isPurchasing = false;

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);
    try {
      final success = await SubscriptionService.instance.purchaseProMonthly();
      if (success && mounted) {
        ref.read(profileProvider.notifier).loadProfile();
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to Volt Pro!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handleRestore() async {
    await SubscriptionService.instance.restorePurchases();
    if (mounted) {
      ref.read(profileProvider.notifier).loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchases restored'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(SubscriptionService.instance.isPro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.mediumGray),
                ),
              ),
              const SizedBox(height: 20),
              // Lightning bolt icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 56,
                  color: AppColors.matteBlack,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Upgrade to Volt Pro',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock the full power of AI styling',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Features
              _FeatureRow(
                icon: Icons.auto_awesome,
                title: 'Unlimited Generations',
                description: 'Generate as many outfits as you want, daily',
              ),
              const SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.palette,
                title: 'Advanced Colour Matching',
                description: 'AI-powered colour theory for perfect combinations',
              ),
              const SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.flight,
                title: 'Travel Packing Assistant',
                description: 'Pack light with smart outfit planning for trips',
              ),
              const SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.calendar_month,
                title: 'Week Planner',
                description: 'Plan your entire week of outfits in advance',
              ),
              const SizedBox(height: 20),
              _FeatureRow(
                icon: Icons.history,
                title: 'Style History & Insights',
                description: 'Track your style evolution and get trend reports',
              ),

              const SizedBox(height: 40),

              // Price card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Monthly',
                      style: TextStyle(
                        color: AppColors.matteBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '£4.99/month',
                      style: TextStyle(
                        color: AppColors.matteBlack,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cancel anytime',
                      style: TextStyle(
                        color: AppColors.matteBlack.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Purchase button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPurchasing ? null : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.matteBlack,
                    foregroundColor: AppColors.electricBlue,
                    side: const BorderSide(color: AppColors.electricBlue, width: 2),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.electricBlue,
                          ),
                        )
                      : const Text(
                          'Start Free Trial',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Restore
              TextButton(
                onPressed: _handleRestore,
                child: const Text(
                  'Restore Purchase',
                  style: TextStyle(color: AppColors.mediumGray),
                ),
              ),

              const SizedBox(height: 12),
              Text(
                '7-day free trial. Then £4.99/month. Cancel anytime.',
                style: TextStyle(
                  color: AppColors.mediumGray.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.electricBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.mediumGray,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
