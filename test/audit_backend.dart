import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_performance_feed/constants/supabase_constants.dart';

void main() {
  test('Audit Backend', () async {
    final url = SupabaseConstants.supabaseUrl;
    final key = SupabaseConstants.supabaseAnonKey;
    
    final client = HttpClient();
    
    // Fetch buckets
    final bucketReq = await client.getUrl(Uri.parse('$url/storage/v1/bucket'));
    bucketReq.headers.add('Authorization', 'Bearer $key');
    bucketReq.headers.add('apikey', key);
    final bucketRes = await bucketReq.close();
    final bucketBody = await bucketRes.transform(utf8.decoder).join();
    
    try {
      final buckets = json.decode(bucketBody) as List;
      print('BUCKETS_FOUND: ${buckets.length}');
      for (var b in buckets) {
        print('BUCKET: ${b['name']} | PUBLIC: ${b['public']}');
      }
    } catch (e) {
      print('Failed to parse buckets: $e. Raw: $bucketBody');
    }
    
    // Fetch table schema via OpenAPI spec
    final schemaReq = await client.getUrl(Uri.parse('$url/rest/v1/?apikey=$key'));
    final schemaRes = await schemaReq.close();
    final schemaBody = await schemaRes.transform(utf8.decoder).join();
    
    // Find the 'posts' definition in OpenAPI schema
    try {
      final jsonSchema = json.decode(schemaBody);
      final definitions = jsonSchema['definitions'];
      if (definitions != null && definitions['posts'] != null) {
        print('POSTS_SCHEMA: ${json.encode(definitions['posts'])}');
      } else {
        // Fallback: check one row to derive schema
        final postsReq = await client.getUrl(Uri.parse('$url/rest/v1/posts?select=*&limit=1'));
        postsReq.headers.add('Authorization', 'Bearer $key');
        postsReq.headers.add('apikey', key);
        final postsRes = await postsReq.close();
        final postsBody = await postsRes.transform(utf8.decoder).join();
        print('POSTS_SAMPLE: $postsBody');
      }
    } catch (e) {
      print('Failed to fetch schema: $e');
    }

    client.close();
  });
}
