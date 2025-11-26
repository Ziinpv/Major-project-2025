import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../models/discovery_filters.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getProfile();
});

final discoveryProvider = FutureProvider.family<List<UserModel>, DiscoveryFilters>((ref, filters) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getDiscovery(filters);
});

