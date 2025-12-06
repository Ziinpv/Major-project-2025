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

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final payload = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      print('🔐 Calling API: PUT /users/password');
      final response = await _api.put('/users/password', data: payload);
      
      print('✅ Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return;
      }
    } on Exception catch (e) {
      print('❌ Exception caught: $e');
      // Try to extract error from DioException
      final errorString = e.toString();
      
      // Extract error message from DioException if available
      if (errorString.contains('DioException')) {
        try {
          // Get the actual exception object
          final dynamic dioError = e;
          final response = (dioError as dynamic).response;
          
          if (response != null) {
            print('Response status code: ${response.statusCode}');
            print('Response data: ${response.data}');
            
            final data = response.data;
            if (data is Map && data.containsKey('error')) {
              final errorMsg = data['error'] as String;
              print('Error message from backend: $errorMsg');
              throw Exception(errorMsg);
            }
            
            // Fallback based on status code
            if (response.statusCode == 400) {
              throw Exception('You signed in with Google/Firebase. Please use password reset to set a password first.');
            } else if (response.statusCode == 401) {
              throw Exception('Current password is incorrect');
            }
          }
        } catch (extractError) {
          print('Error extracting message: $extractError');
          // If extraction fails, check if error already contains useful message
          if (errorString.contains('Cannot change password')) {
            rethrow;
          }
        }
      }
      
      // If we get here, rethrow or provide generic message
      throw Exception('Failed to change password. Please try again or contact support.');
    }
  }

  Future<void> deleteAccount({required String password}) async {
    try {
      final payload = {
        'password': password,
      };

      print('🗑️ Calling API: DELETE /users/account');
      final response = await _api.delete('/users/account', data: payload);
      
      print('✅ Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return;
      }
    } on Exception catch (e) {
      print('❌ Exception caught: $e');
      final errorString = e.toString();
      
      if (errorString.contains('DioException')) {
        try {
          final dynamic dioError = e;
          final response = (dioError as dynamic).response;
          
          if (response != null) {
            print('Response status code: ${response.statusCode}');
            print('Response data: ${response.data}');
            
            final data = response.data;
            if (data is Map && data.containsKey('error')) {
              final errorMsg = data['error'] as String;
              print('Error message from backend: $errorMsg');
              throw Exception(errorMsg);
            }
            
            if (response.statusCode == 401) {
              throw Exception('Incorrect password');
            } else if (response.statusCode == 400) {
              throw Exception('Account is already deleted or invalid request');
            }
          }
        } catch (extractError) {
          print('Error extracting message: $extractError');
          if (extractError is Exception) {
            rethrow;
          }
        }
      }
      
      throw Exception('Failed to delete account. Please try again.');
    }
  }
}


