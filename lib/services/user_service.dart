import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import '../models/registration_response.dart';

class UserService {
  // Change user password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService.post('/api/v1/user/changePassword', {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      debugPrint('Change password API response: $response');

      // The backend returns status code as integer, not boolean success
      if (response['status'] == 201) {
        return {
          'success': true,
          'message': response['message'] ?? 'Password changed successfully!'
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to change password'
        };
      }
    } on ApiException catch (e) {
      debugPrint('Change password API error: $e');
      return {
        'success': false,
        'message': e.userMessage
      };
    } catch (e) {
      debugPrint('Change password error: $e');
      return {
        'success': false,
        'message': 'Failed to change password: ${e.toString()}'
      };
    }
  }

  // Update customer profile
  static Future<Map<String, dynamic>> updateCustomerProfile({
    required String fullName,
    required String email,
    required String phoneJp,
    required String phonesl,
    required String addressJp,
    required String addressSl,
    required String passportNumber,
    String? city,
    String? zipCodeJp,
    String? zipCodeSl,
    String? nic,
    File? profileImage,
    File? passportImage,
    bool fromApi = true,
  }) async {
    try {
      final formData = <String, String>{
        'customer_f_name': fullName,
        'customer_email': email,
        'customer_phone': phoneJp,  
        'customer_phone_sl': phonesl,
        'customer_address': addressJp,
        'customer_address_sl': addressSl,
        'customer_pass_no': passportNumber,
        'from_api': 'true', // Required parameter for API calls
      };

      // Add optional fields
      if (city != null) formData['customer_city'] = city;
      if (zipCodeJp != null) formData['customer_zip_jp'] = zipCodeJp;
      if (zipCodeSl != null) formData['customer_zip_sl'] = zipCodeSl;
      if (nic != null) formData['customer_nic'] = nic;

      debugPrint('Update profile API request: $formData');

      Map<String, dynamic> response;

      // Handle file uploads
      if (profileImage != null || passportImage != null) {
        if (profileImage != null) {
          response = await ApiService.postMultipart(
            '/api/v1/user/updateCustomerProfile',
            formData,
            file: profileImage,
            fileField: 'customer_prof_pic',
          );
        } else {
          response = await ApiService.postMultipart(
            '/api/v1/user/updateCustomerProfile',
            formData,
            file: passportImage,
            fileField: 'customer_passport_book',
          );
        }
      } else {
        // No file upload, use regular POST
        response = await ApiService.post('/api/v1/user/updateCustomerProfile', formData);
      }

      debugPrint('Update profile API response: $response');

      // The backend returns status code as integer
      if (response['status'] == 200) {
        // Update local storage with new customer data if available
        if (response['data'] != null) {
          try {
            await _updateLocalUserData(response['data']);
            debugPrint('Local user data updated successfully');
          } catch (e) {
            debugPrint('Failed to update local user data: $e');
            // Don't fail the whole operation if local storage update fails
          }
        }

        return {
          'success': true,
          'message': response['message'] ?? 'Profile updated successfully!'
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update profile'
        };
      }
    } on ApiException catch (e) {
      debugPrint('Update profile API error: $e');
      return {
        'success': false,
        'message': e.userMessage
      };
    } catch (e) {
      debugPrint('Update profile error: $e');
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}'
      };
    }
  }

  // Delete user account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      debugPrint('========================================');
      debugPrint('Initiating account deletion API call...');
      debugPrint('Endpoint: /api/v1/user/deleteAccount');
      debugPrint('Method: POST');

      final response = await ApiService.post('/api/v1/user/deleteAccount', {}).timeout(
        const Duration(seconds: 15), // Reduced timeout to 15 seconds
        onTimeout: () {
          debugPrint('!!! API call timed out after 15 seconds !!!');
          debugPrint('!!! The backend endpoint may not be implemented or is not responding !!!');
          throw Exception('The server is not responding. The delete account endpoint may not be available yet. Please contact support.');
        },
      );

      debugPrint('Delete account API response received: $response');
      debugPrint('Response status: ${response['status']}');
      debugPrint('Response message: ${response['message']}');
      debugPrint('========================================');

      // The backend returns status code as integer
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Account deleted successfully!'
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete account'
        };
      }
    } on ApiException catch (e) {
      debugPrint('!!! Delete account API error !!!');
      debugPrint('Error message: ${e.message}');
      debugPrint('Status code: ${e.statusCode}');
      debugPrint('Errors: ${e.errors}');
      debugPrint('========================================');
      return {
        'success': false,
        'message': e.userMessage
      };
    } catch (e) {
      debugPrint('!!! Delete account general error !!!');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('========================================');
      return {
        'success': false,
        'message': 'Failed to delete account: ${e.toString()}'
      };
    }
  }

  // Helper method to update local user data storage
  static Future<void> _updateLocalUserData(Map<String, dynamic> customerData) async {
    const String userKey = 'user_data';

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get current user data
      final userJson = prefs.getString(userKey);
      UserData currentUser;

      if (userJson != null && userJson.isNotEmpty) {
        final userMap = jsonDecode(userJson);
        currentUser = UserData.fromJson(userMap);
      } else {
        throw Exception('No current user data found');
      }

      debugPrint('Current local user data: ${customerData}');

      // Update user data with new customer information
      final updatedUser = UserData(
        id: currentUser.id,
        nickname: currentUser.nickname,
        fullname: customerData['FullName'] ?? currentUser.fullname,
        nic: customerData['NIC'] ?? currentUser.nic,
        city: customerData['city'] ?? currentUser.city,
        passport: customerData['passport'] ?? currentUser.passport,
        jpnAddress: customerData['Address'] ?? currentUser.jpnAddress,
        jpnPostalCode: customerData['zipcode'] ?? currentUser.jpnPostalCode,
        slAddress: customerData['sl_address'] ?? currentUser.slAddress,
        slPostalCode: customerData['sl_zipcode'] ?? currentUser.slPostalCode,
        jpnMobile: customerData['TP'] ?? currentUser.jpnMobile,
        slMobile: customerData['Mobile'] ?? currentUser.slMobile,
        email: customerData['email'] ?? currentUser.email,
        passportPhotoUrl: customerData['passport_photo'] ?? currentUser.passportPhotoUrl,
        createdAt: currentUser.createdAt,
        updatedAt: customerData['updated_at'] ?? currentUser.updatedAt,
      );

      // Save updated user data back to storage
      await prefs.setString(userKey, jsonEncode(updatedUser.toJson()));

      debugPrint('Updated local user data: ${updatedUser.slMobile}');
    } catch (e) {
      debugPrint('Error updating local user data: $e');
      throw e;
    }
  }
}