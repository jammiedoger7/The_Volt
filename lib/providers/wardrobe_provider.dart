import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wardrobe_item.dart';
import '../services/supabase_service.dart';

final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, AsyncValue<List<WardrobeItem>>>((ref) {
  return WardrobeNotifier();
});

class WardrobeNotifier extends StateNotifier<AsyncValue<List<WardrobeItem>>> {
  WardrobeNotifier() : super(const AsyncValue.loading()) {
    loadItems();
  }

  final _client = SupabaseService.instance.client;

  Future<void> loadItems() async {
    state = const AsyncValue.loading();
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final data = await _client
          .from('wardrobe_items')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final items = (data as List).map((e) => WardrobeItem.fromMap(e)).toList();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(WardrobeItem item) async {
    try {
      await _client.from('wardrobe_items').insert(item.toMap());
      await loadItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _client.from('wardrobe_items').delete().eq('id', id);
      await loadItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateItem(WardrobeItem item) async {
    try {
      await _client.from('wardrobe_items').update(item.toMap()).eq('id', item.id);
      await loadItems();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<WardrobeItem> filterByCategory(ClothingCategory category) {
    return state.valueOrNull?.where((item) => item.category == category).toList() ?? [];
  }
}
