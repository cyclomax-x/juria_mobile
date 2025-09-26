import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'http://192.168.1.98/Juria';
  static const String baseUrl = 'http://43.204.136.204';
  
  // HTTP client with timeout
  static final http.Client _client = http.Client();
  
  // List of endpoints that don't require authentication
  static const List<String> _publicEndpoints = [
    '/client/register',
    '/api/auth/login',
  ];

  // Headers for API requests
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getStoredToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Headers for multipart requests
  static Future<Map<String, String>> _getMultipartHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getStoredToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Get stored token from SharedPreferences
  static Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  // Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final includeAuth = !_publicEndpoints.contains(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final includeAuth = !_publicEndpoints.contains(endpoint);
      final headers = await _getHeaders(includeAuth: includeAuth);
      
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart POST request (for file uploads)
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, 
    Map<String, String> fields, 
    {File? file, String? fileField}
  ) async {
    try {
      final includeAuth = !_publicEndpoints.contains(endpoint);
      final headers = await _getMultipartHeaders(includeAuth: includeAuth);
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      
      // Add headers
      request.headers.addAll(headers);
      
      // Add fields
      request.fields.addAll(fields);
      
      // Add file if provided
      if (file != null && fileField != null) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(fileField, stream, length,
            filename: file.path.split('/').last);
        request.files.add(multipartFile);
      }

      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          message: data['message'] ?? 'An error occurred',
          statusCode: response.statusCode,
          errors: data['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }

  // Handle errors
  static ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } else if (error.toString().contains('TimeoutException')) {
      return ApiException(
        message: 'Connection timeout. Please try again.',
        statusCode: 0,
      );
    } else {
      return ApiException(
        message: 'An unexpected error occurred: ${error.toString()}',
        statusCode: 0,
      );
    }
  }

  // Dispose client
  static void dispose() {
    _client.close();
  }
}

// Custom API Exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }

  // Get user-friendly error message
  String get userMessage {
    if (statusCode == 0) return message;
    if (statusCode == 422 && errors != null) {
      // Validation errors
      final List<String> errorMessages = [];
      errors!.forEach((field, messages) {
        if (messages is List) {
          errorMessages.addAll(messages.map((msg) => msg.toString()));
        } else {
          errorMessages.add(messages.toString());
        }
      });
      return errorMessages.join('\n');
    }
    return message;
  }
}