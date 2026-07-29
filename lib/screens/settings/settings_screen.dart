import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import '../auth/login_screen.dart';
import 'paywall_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 20),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),

          // Profile card
          profile.when(
            data: (p) => p != null
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkGray,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.electricBlue.withOpacity(0.2),
                          child: Text(
                            (p.displayName ?? p.email)[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.electricBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.displayName ?? p.email.split('@').first,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.email,
                                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (p.isPro)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: AppColors.matteBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(height: 72, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 32),

          // Account
          _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              _showEditProfileDialog(context, ref);
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () async {
              final email = AuthService.instance.currentUser?.email;
              if (email != null) {
                await AuthService.instance.resetPassword(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // Preferences
          _SectionHeader('Preferences'),
          _SettingsTile(
            icon: Icons.style_outlined,
            title: 'Style Preferences',
            onTap: () => _showStylePreferences(context, ref),
          ),
          _SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Location',
            subtitle: 'Auto-detected',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Pro
          _SectionHeader('The Volt Pro'),
          _SettingsTile(
            icon: Icons.star_outline,
            title: SubscriptionService.instance.isPro ? 'Volt Pro Active' : 'Upgrade to Pro',
            subtitle: SubscriptionService.instance.isPro
                ? 'You have unlimited generations'
                : '£4.99/month - Unlimited generations',
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
              if (result == true) {
                ref.read(profileProvider.notifier).loadProfile();
              }
            },
            trailing: !SubscriptionService.instance.isPro
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: AppColors.matteBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const Icon(Icons.check_circle, color: AppColors.success),
          ),

          const SizedBox(height: 24),

          // Support
          _SectionHeader('Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.mail_outline,
            title: 'Contact Us',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Sign out
          TextButton(
            onPressed: () async {
              await AuthService.instance.signOut();
              await SubscriptionService.instance.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(profileProvider).valueOrNull?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.white)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Display Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(profileProvider.notifier).updateProfile(
                    displayName: controller.text.trim(),
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: AppColors.electricBlue)),
          ),
        ],
      ),
    );
  }

  void _showStylePreferences(BuildContext context, WidgetRef ref) {
    final styles = ['casual', 'formal', 'streetwear', 'athletic', 'smart', 'vintage'];
    final current = ref.read(profileProvider).valueOrNull?.preferredStyles ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Style Preferences',
                    style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text('Select your preferred styles to improve outfit generation',
                    style: TextStyle(color: AppColors.mediumGray, fontSize: 13)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: styles.map((style) {
                    final isSelected = current.contains(style);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(style[0].toUpperCase() + style.substring(1)),
                      onSelected: (_) {
                        if (isSelected) {
                          current.remove(style);
                        } else {
                          current.add(style);
                        }
                        setModalState(() {});
                      },
                      selectedColor: AppColors.electricBlue,
                      backgroundColor: AppColors.matteBlack,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.matteBlack : AppColors.white,
                      ),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(profileProvider.notifier).updateProfile(
                            preferredStyles: List.from(current),
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('Save Preferences'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.electricBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.zero),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.mediumGray),
        title: Text(title, style: const TextStyle(color: AppColors.white, fontSize: 15)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: const TextStyle(color: AppColors.mediumGray, fontSize: 12))
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.mediumGray, size: 20),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}
