import '../models/user_model.dart';
import '../models/discovery_filters.dart';
import '../../core/services/api_service.dart';

class UserRepository {
  final _api = ApiService();

  Future<UserModel> getProfile() async {
    final response = await _api.get('/users/profile');
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['data']['user']);
    } else {
      throw Exception('Failed to get profile');
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.patch('/users/profile', data: data);
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['data']['user']);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<UserModel> updateProfilePhotos({
    required List<Map<String, dynamic>> photos,
    List<String>? removedPhotoIds,
  }) async {
    final payload = {
      'photos': photos,
      if (removedPhotoIds != null && removedPhotoIds.isNotEmpty)
        'removedPhotoIds': removedPhotoIds,
    };
    final response = await _api.patch('/users/profile/photos', data: payload);
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['data']['user']);
    } else {
      throw Exception('Failed to update photos');
    }
  }

  Future<List<UserModel>> getDiscovery(DiscoveryFilters filters) async {
    final queryParams = filters.toQueryParameters();
    final response = await _api.get('/discover', queryParameters: queryParams);
    if (response.statusCode == 200) {
      final users = response.data['data']['users'] as List;
      return users.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw Exception('Failed to get discovery');
    }
  }

  Future<UserModel> updateLocation({
    required String province,
    required String city,
    String? district,
    String? address,
    String country = 'Vietnam',
  }) async {
    final payload = {
      'province': province,
      'city': city,
      'country': country,
      if (district != null && district.isNotEmpty) 'district': district,
      if (address != null && address.isNotEmpty) 'address': address,
    };

    final response = await _api.put('/users/location', data: payload);
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data['data']['user']);
    } else {
      throw Exception('Failed to update location');
    }
  }
}

