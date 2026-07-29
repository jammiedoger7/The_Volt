import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outfit.dart';
import '../services/supabase_service.dart';

final outfitProvider = StateNotifierProvider<OutfitNotifier, AsyncValue<List<Outfit>>>((ref) {
  return OutfitNotifier();
});

class OutfitNotifier extends StateNotifier<AsyncValue<List<Outfit>>> {
  OutfitNotifier() : super(const AsyncValue.loading()) {
    loadOutfits();
  }

  final _client = SupabaseService.instance.client;

  Future<void> loadOutfits() async {
    state = const AsyncValue.loading();
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final data = await _client
          .from('outfits')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final outfits = (data as List).map((e) => Outfit.fromMap(e)).toList();
      state = AsyncValue.data(outfits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveOutfit(Outfit outfit) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final newOutfit = Outfit(
        userId: user.id,
        name: outfit.name,
        topId: outfit.topId,
        bottomId: outfit.bottomId,
        shoesId: outfit.shoesId,
        outerwearId: outfit.outerwearId,
        accessoryIds: outfit.accessoryIds,
        weatherCondition: outfit.weatherCondition,
        temperature: outfit.temperature,
        isSaved: true,
      );

      await _client.from('outfits').insert(newOutfit.toMap());
      await loadOutfits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rateOutfit(String outfitId, int rating) async {
    try {
      await _client.from('outfits').update({'rating': rating}).eq('id', outfitId);
      await loadOutfits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      await _client.from('outfits').delete().eq('id', id);
      await loadOutfits();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<Outfit> get savedOutfits =>
      state.valueOrNull?.where((o) => o.isSaved).toList() ?? [];

  List<Outfit> get recentOutfits =>
      state.valueOrNull?.take(10).toList() ?? [];
}
