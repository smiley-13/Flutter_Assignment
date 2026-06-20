import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchPosts(int page, int size) async {
    final start = page * size;
    final end = start + size - 1;
    
    final response = await client
        .from('posts')
        .select()
        .order('created_at', ascending: false)
        .order('id', ascending: true)
        .range(start, end);
        
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<String>> fetchLikedPosts(String userId) async {
    final response = await client
        .from('user_likes')
        .select('post_id')
        .eq('user_id', userId);
        
    return List<String>.from(response.map((row) => row['post_id'] as String));
  }

  static Future<void> toggleLike(String postId, String userId) async {
    await client.rpc('toggle_like', params: {
      'p_post_id': postId,
      'p_user_id': userId,
    });
  }
}