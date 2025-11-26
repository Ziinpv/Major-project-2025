import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../repositories/match_repository.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final matchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final repository = ref.watch(matchRepositoryProvider);
  return await repository.getMatches();
});

final matchProvider = FutureProvider.family<MatchModel, String>((ref, matchId) async {
  final repository = ref.watch(matchRepositoryProvider);
  return await repository.getMatch(matchId);
});

