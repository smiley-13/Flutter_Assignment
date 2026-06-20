import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart';
import 'package:high_performance_feed/constants/supabase_constants.dart';

void main() {
  test('Check Supabase data', () async {
    final client = SupabaseClient(SupabaseConstants.supabaseUrl, SupabaseConstants.supabaseAnonKey);
    try {
      final response = await client.from('posts').select().limit(1);
      if (response.isNotEmpty) {
        print('DATA_PRESENT: TRUE');
        print('SAMPLE: $response');
      } else {
        print('DATA_PRESENT: FALSE (Empty table)');
      }
    } catch (e) {
      print('DATA_PRESENT: ERROR');
      print(e);
    }
  });
}
