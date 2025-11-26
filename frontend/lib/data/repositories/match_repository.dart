import '../models/match_model.dart';
import '../../core/services/api_service.dart';

class MatchRepository {
  final _api = ApiService();

  Future<List<MatchModel>> getMatches() async {
    final response = await _api.get('/matches');
    if (response.statusCode == 200) {
      final matches = response.data['data']['matches'] as List;
      return matches.map((match) => MatchModel.fromJson(match)).toList();
    } else {
      throw Exception('Failed to get matches');
    }
  }

  Future<MatchModel> getMatch(String matchId) async {
    final response = await _api.get('/matches/$matchId');
    if (response.statusCode == 200) {
      return MatchModel.fromJson(response.data['data']['match']);
    } else {
      throw Exception('Failed to get match');
    }
  }

  Future<void> unmatch(String matchId) async {
    final response = await _api.delete('/matches/$matchId');
    if (response.statusCode != 200) {
      throw Exception('Failed to unmatch');
    }
  }
}

