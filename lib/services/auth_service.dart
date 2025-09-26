import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/registration_request.dart';
import '../models/registration_response.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Register new client
  static Future<RegistrationResponse> register(
    RegistrationRequest request,
  ) async {
    try {
      // Validate request data first
      final validationErrors = request.validate();
      if (validationErrors != null) {
        return RegistrationResponse.error(
          'Please fix the following errors:',
          errors: validationErrors,
        );
      }

      // Prepare form data
      final formData = request.toFormData();

      // Make API call with multipart if passport photo is provided
      Map<String, dynamic> response;
      if (request.passportPhoto != null) {
        response = await ApiService.postMultipart(
          '/client/register',
          formData,
          file: request.passportPhoto,
          fileField: 'passport_photo',
        );
      } else {
        response = await ApiService.post('/client/register', request.toJson());
      }

      debugPrint('Registration API response - pure: $response');

      final registrationResponse = RegistrationResponse.fromJson(response);

      print('Registration API response: $response');

      // Registration endpoint only returns success message, no token or user data
      // User will need to login separately after registration
      return registrationResponse;
    } on ApiException catch (e) {
      return RegistrationResponse.error(e.userMessage, errors: e.errors);
    } catch (e) {
      return RegistrationResponse.error('Registration failed: ${e.toString()}');
    }
  }

  // Login client
  static Future<RegistrationResponse> login(
    String username,
    String password,
  ) async {
    try {
      final response = await ApiService.post('/api/auth/login', {
        'username': username,
        'password': password,
      });

      debugPrint('Login API response: $response');
      final loginResponse = RegistrationResponse.fromJson(response);

      // Save token and user data if login successful
      if (loginResponse.success && loginResponse.token != null) {
        debugPrint(
          'Saving auth data: token=${loginResponse.token}, user=${loginResponse.user}',
        );
        await _saveAuthData(loginResponse.token!, loginResponse.user!);
      }

      return loginResponse;
    } on ApiException catch (e) {
      debugPrint('Login API response - ApiException: $e');
      return RegistrationResponse.error(e.userMessage, errors: e.errors);
    } catch (e) {
      debugPrint('Login API response - catch: $e');
      return RegistrationResponse.error('Login failed: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);

      // Optionally call logout API
      try {
        await ApiService.post('/client/logout', {});
      } catch (e) {
        // Ignore logout API errors
      }
    } catch (e) {
      // Handle logout errors silently
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get stored user data
  static Future<UserData?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      debugPrint('Retrieved user JSON: $userJson');
      if (userJson != null && userJson.isNotEmpty) {
        Map<String, dynamic> userMap;
        
        // Try to parse as JSON first (new format)
        try {
          userMap = jsonDecode(userJson);
        } catch (jsonError) {
          // If JSON parsing fails, it's likely the old toString() format
          // Clear the old data and return null - user will need to login again
          debugPrint('Old format user data detected, clearing storage');
          await prefs.remove(_userKey);
          await prefs.remove(_tokenKey);
          return null;
        }
        
        debugPrint('Parsed user map: $userMap');
        return UserData.fromJson(userMap);
      }
      debugPrint('No user data found in storage');
      return null;
    } catch (e) {
      debugPrint('Error parsing user data: $e');
      return null;
    }
  }

  // Refresh user data from API
  static Future<UserData?> refreshUserData() async {
    try {
      final response = await ApiService.get('/client/profile');
      final userData = UserData.fromJson(response['user']);

      // Update stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData.toJson()));

      return userData;
    } catch (e) {
      return null;
    }
  }

  // Save authentication data to local storage
  static Future<void> _saveAuthData(String token, UserData user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      throw Exception('Failed to save authentication data');
    }
  }

  // Update user profile
  static Future<RegistrationResponse> updateProfile(
    RegistrationRequest request,
  ) async {
    try {
      // Validate request data first
      final validationErrors = request.validate();
      if (validationErrors != null) {
        return RegistrationResponse.error(
          'Please fix the following errors:',
          errors: validationErrors,
        );
      }

      // Prepare form data
      final formData = request.toFormData();

      // Make API call with multipart if passport photo is provided
      Map<String, dynamic> response;
      if (request.passportPhoto != null) {
        response = await ApiService.postMultipart(
          '/client/profile/update',
          formData,
          file: request.passportPhoto,
          fileField: 'passport_photo',
        );
      } else {
        response = await ApiService.post(
          '/client/profile/update',
          request.toJson(),
        );
      }

      final updateResponse = RegistrationResponse.fromJson(response);

      // Update stored user data if successful
      if (updateResponse.success && updateResponse.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _userKey,
          jsonEncode(updateResponse.user!.toJson()),
        );
      }

      return updateResponse;
    } on ApiException catch (e) {
      return RegistrationResponse.error(e.userMessage, errors: e.errors);
    } catch (e) {
      return RegistrationResponse.error(
        'Profile update failed: ${e.toString()}',
      );
    }
  }

  // Verify email or phone
  static Future<RegistrationResponse> verify(String code, String type) async {
    try {
      final response = await ApiService.post('/client/verify', {
        'code': code,
        'type': type, // 'email' or 'phone'
      });

      return RegistrationResponse.fromJson(response);
    } on ApiException catch (e) {
      return RegistrationResponse.error(e.userMessage, errors: e.errors);
    } catch (e) {
      return RegistrationResponse.error('Verification failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<RegistrationResponse> resetPassword(String identifier) async {
    try {
      final response = await ApiService.post('/client/reset-password', {
        'identifier': identifier,
      });

      return RegistrationResponse.fromJson(response);
    } on ApiException catch (e) {
      return RegistrationResponse.error(e.userMessage, errors: e.errors);
    } catch (e) {
      return RegistrationResponse.error(
        'Password reset failed: ${e.toString()}',
      );
    }
  }
}
