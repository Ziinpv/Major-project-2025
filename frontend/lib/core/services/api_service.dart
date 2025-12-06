import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  late Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            SharedPreferences.getInstance().then((prefs) {
              prefs.remove('auth_token');
            });
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint('=== API POST: ${AppConfig.baseUrl}$path ===');
      debugPrint('=== API DATA: $data ===');
      developer.log('API POST: ${AppConfig.baseUrl}$path', name: 'ApiService');
      developer.log('Data: $data', name: 'ApiService');
      
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      
      debugPrint('=== API RESPONSE STATUS: ${response.statusCode} ===');
      debugPrint('=== API RESPONSE DATA: ${response.data} ===');
      developer.log('Response status: ${response.statusCode}', name: 'ApiService');
      developer.log('Response data: ${response.data}', name: 'ApiService');
      return response;
    } catch (e) {
      debugPrint('=== API ERROR: $e ===');
      developer.log('API Error: $e', name: 'ApiService', error: e);
      if (e is DioException) {
        debugPrint('=== ERROR RESPONSE: ${e.response?.data} ===');
        debugPrint('=== ERROR STATUS: ${e.response?.statusCode} ===');
        debugPrint('=== ERROR MESSAGE: ${e.message} ===');
        developer.log('Error response: ${e.response?.data}', name: 'ApiService');
        developer.log('Error status: ${e.response?.statusCode}', name: 'ApiService');
        developer.log('Error message: ${e.message}', name: 'ApiService');
      }
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadFile(String path, String filePath, {String? fieldName}) async {
    try {
      debugPrint('=== UPLOAD FILE: ${AppConfig.baseUrl}$path ===');
      debugPrint('=== FILE PATH: $filePath ===');
      debugPrint('=== FIELD NAME: ${fieldName ?? 'file'} ===');
      developer.log('Upload file: $path', name: 'ApiService');
      developer.log('File path: $filePath', name: 'ApiService');
      
      final formData = FormData.fromMap({
        fieldName ?? 'file': await MultipartFile.fromFile(filePath),
      });
      
      // Dio will automatically set Content-Type to multipart/form-data with boundary
      final response = await _dio.post(path, data: formData);
      
      debugPrint('=== UPLOAD RESPONSE STATUS: ${response.statusCode} ===');
      debugPrint('=== UPLOAD RESPONSE DATA: ${response.data} ===');
      developer.log('Upload response status: ${response.statusCode}', name: 'ApiService');
      developer.log('Upload response data: ${response.data}', name: 'ApiService');
      
      return response;
    } catch (e) {
      debugPrint('=== UPLOAD ERROR: $e ===');
      developer.log('Upload error: $e', name: 'ApiService', error: e);
      if (e is DioException) {
        debugPrint('=== UPLOAD ERROR RESPONSE: ${e.response?.data} ===');
        debugPrint('=== UPLOAD ERROR STATUS: ${e.response?.statusCode} ===');
        debugPrint('=== UPLOAD ERROR MESSAGE: ${e.message} ===');
        developer.log('Upload error response: ${e.response?.data}', name: 'ApiService');
        developer.log('Upload error status: ${e.response?.statusCode}', name: 'ApiService');
        developer.log('Upload error message: ${e.message}', name: 'ApiService');
      }
      rethrow;
    }
  }
}

