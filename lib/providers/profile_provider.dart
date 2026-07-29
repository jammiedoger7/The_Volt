import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../services/subscription_service.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    loadProfile();
  }

  final _client = SupabaseService.instance.client;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final profile = UserProfile.fromMap(data);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({String? displayName, List<String>? preferredStyles}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (preferredStyles != null) updates['preferred_styles'] = preferredStyles;

      await _client.from('profiles').update(updates).eq('id', user.id);
      await loadProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> incrementGenerationCount() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client.rpc('increment_generation_count', params: {
        'user_id': user.id,
      });
      await loadProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool get isPro => SubscriptionService.instance.isPro;
}
