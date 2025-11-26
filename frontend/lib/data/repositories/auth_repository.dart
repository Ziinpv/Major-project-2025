import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/user_model.dart';
import '../../core/services/api_service.dart';

class AuthRepository {
  final _api = ApiService();

  Future<Map<String, dynamic>> loginWithFirebase(String firebaseToken) async {
    try {
      debugPrint('=== LOGIN START ===');
      debugPrint('Login with Firebase - Token length: ${firebaseToken.length}');
      developer.log('Login with Firebase - Token length: ${firebaseToken.length}', name: 'AuthRepo');
      
      final response = await _api.post('/auth/login/firebase', data: {
        'firebaseToken': firebaseToken,
      });

      debugPrint("=== RAW RESPONSE TYPE: ${response.data.runtimeType} ===");
      debugPrint("=== RAW RESPONSE DATA: ${response.data} ===");
      developer.log("RAW RESPONSE TYPE: ${response.data.runtimeType}", name: 'AuthRepo');
      developer.log("RAW RESPONSE DATA: ${response.data}", name: 'AuthRepo');
      debugPrint('Login response status: ${response.statusCode}');
      developer.log('Login response status: ${response.statusCode}', name: 'AuthRepo');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null || data['user'] == null) {
          final errorMessage = response.data['error'] ?? 'Không nhận được dữ liệu người dùng từ server';
          throw Exception(errorMessage);
        }
        print('Response data structure: $data');
        print('User data type: ${data['user'].runtimeType}');
        print('User data: ${data['user']}');
        
        // Handle case where user might be a List or Object
        dynamic userData = data['user'];
        if (userData is List && userData.isNotEmpty) {
          // If it's a list, take the first element
          userData = userData[0];
          print('User data was a List, using first element');
        }
        
        if (userData is! Map<String, dynamic>) {
          throw Exception('Invalid user data format: expected Map but got ${userData.runtimeType}');
        }
        
        // Ensure _id is converted to id for Flutter model
        if (userData['_id'] != null && userData['id'] == null) {
          userData['id'] = userData['_id'].toString();
        }
        
        // Ensure arrays are properly formatted
        if (userData['photos'] == null) {
          userData['photos'] = [];
        }
        if (userData['interests'] == null) {
          userData['interests'] = [];
        }
        if (userData['interestedIn'] == null) {
          userData['interestedIn'] = [];
        }
        
        // Ensure dateOfBirth is a string that can be parsed
        if (userData['dateOfBirth'] != null) {
          if (userData['dateOfBirth'] is! String) {
            userData['dateOfBirth'] = userData['dateOfBirth'].toString();
          }
        } else {
          // Default dateOfBirth if missing (18 years ago)
          final defaultDate = DateTime.now().subtract(const Duration(days: 365 * 18));
          userData['dateOfBirth'] = defaultDate.toIso8601String();
        }
        
        // Ensure gender exists
        if (userData['gender'] == null || userData['gender'] == '') {
          userData['gender'] = 'other';
        }
        
        // Ensure firstName and lastName exist
        if (userData['firstName'] == null || userData['firstName'] == '') {
          userData['firstName'] = 'User';
        }
        if (userData['lastName'] == null) {
          userData['lastName'] = '';
        }
        
        // Ensure email exists (should always be present)
        if (userData['email'] == null) {
          userData['email'] = 'user@example.com'; // Fallback, should not happen
        }
        
        print('Parsing user data: $userData');
        
        try {
          final user = UserModel.fromJson(userData);
          return {
            'user': user,
            'token': data['token'],
          };
        } catch (e, stackTrace) {
          print('Error parsing UserModel: $e');
          print('Stack trace: $stackTrace');
          print('UserData keys: ${userData.keys}');
          print('UserData: $userData');
          rethrow;
        }
      } else {
        print('Login failed - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerWithFirebase(
    String firebaseToken,
    Map<String, dynamic> userData,
  ) async {
    final response = await _api.post('/auth/register/firebase', data: {
      'firebaseToken': firebaseToken,
      ...userData,
    });

    if (response.statusCode == 201) {
      final data = response.data['data'];
      if (data == null || data['user'] == null) {
        final errorMessage = response.data['error'] ?? 'Không nhận được dữ liệu người dùng từ server';
        throw Exception(errorMessage);
      }
      print('Register response data: $data');
      print('User data type: ${data['user'].runtimeType}');
      
      // Handle case where user might be a List or Object
      dynamic userData = data['user'];
      if (userData is List && userData.isNotEmpty) {
        userData = userData[0];
        print('User data was a List, using first element');
      }
      
      if (userData is! Map<String, dynamic>) {
        throw Exception('Invalid user data format: expected Map but got ${userData.runtimeType}');
      }
      
      // Ensure _id is converted to id for Flutter model
      if (userData['_id'] != null && userData['id'] == null) {
        userData['id'] = userData['_id'].toString();
      }
      
      // Ensure arrays are properly formatted
      if (userData['photos'] == null) {
        userData['photos'] = [];
      }
      if (userData['interests'] == null) {
        userData['interests'] = [];
      }
      if (userData['interestedIn'] == null) {
        userData['interestedIn'] = [];
      }
      
      // Ensure dateOfBirth is a string that can be parsed
      if (userData['dateOfBirth'] != null) {
        if (userData['dateOfBirth'] is! String) {
          userData['dateOfBirth'] = userData['dateOfBirth'].toString();
        }
      } else {
        // Default dateOfBirth if missing
        final defaultDate = DateTime.now().subtract(const Duration(days: 365 * 18));
        userData['dateOfBirth'] = defaultDate.toIso8601String();
      }
      
      // Ensure gender exists
      if (userData['gender'] == null || userData['gender'] == '') {
        userData['gender'] = 'other';
      }
      
      try {
        return {
          'user': UserModel.fromJson(userData),
          'token': data['token'],
        };
      } catch (e, stackTrace) {
        print('Error parsing UserModel in register: $e');
        print('Stack trace: $stackTrace');
        print('UserData: $userData');
        rethrow;
      }
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _api.get('/auth/me');

    if (response.statusCode == 200) {
      final userData = response.data['data']['user'];
      
      // Handle case where user might be a List or Object
      dynamic user = userData;
      if (user is List && user.isNotEmpty) {
        user = user[0];
      }
      
      if (user is! Map<String, dynamic>) {
        throw Exception('Invalid user data format: expected Map but got ${user.runtimeType}');
      }
      
      // Ensure _id is converted to id for Flutter model
      if (user['_id'] != null && user['id'] == null) {
        user['id'] = user['_id'].toString();
      }
      
      // Ensure arrays are properly formatted
      if (user['photos'] == null) {
        user['photos'] = [];
      }
      if (user['interests'] == null) {
        user['interests'] = [];
      }
      if (user['interestedIn'] == null) {
        user['interestedIn'] = [];
      }
      
      return UserModel.fromJson(user);
    } else {
      throw Exception('Failed to get current user');
    }
  }
}

