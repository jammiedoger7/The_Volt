import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;
  GoTrueClient get auth => client.auth;
  PostgrestQueryBuilder get wardrobe => client.from('wardrobe_items');
  PostgrestQueryBuilder get outfits => client.from('outfits');
  PostgrestQueryBuilder get profiles => client.from('profiles');
}
