import '../../core/services/api_service.dart';

class SwipeRepository {
  final _api = ApiService();

  Future<Map<String, dynamic>> swipe({
    required String userId,
    required String action, // 'like', 'pass', 'superlike'
  }) async {
    final response = await _api.post('/swipes', data: {
      'userId': userId,
      'action': action,
    });
    if (response.statusCode == 200) {
      return response.data['data'];
    } else {
      throw Exception('Failed to swipe');
    }
  }

  Future<List<dynamic>> getSwipeHistory() async {
    final response = await _api.get('/swipes/history');
    if (response.statusCode == 200) {
      return response.data['data']['history'] as List;
    } else {
      throw Exception('Failed to get swipe history');
    }
  }
}

