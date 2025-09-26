import 'package:flutter/foundation.dart';

class RegistrationResponse {
  final bool success;
  final String message;
  final UserData? user;
  final String? token;
  final Map<String, dynamic>? errors;

  RegistrationResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      token: json['token'],
      errors: json['errors'],
    );
  }

  factory RegistrationResponse.error(String message, {Map<String, dynamic>? errors}) {
    return RegistrationResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
}

class UserData {
  final int id;
  final String nickname;
  final String fullname;
  final String? nic;
  final String? city;
  final String? passport;
  final String? jpnAddress;
  final String? jpnPostalCode;
  final String? slAddress;
  final String? slPostalCode;
  final String jpnMobile;
  final String? slMobile;
  final String? email;
  final String? passportPhotoUrl;
  final String? createdAt;
  final String? updatedAt;

  UserData({
    required this.id,
    required this.nickname,
    required this.fullname,
    this.nic,
    this.city,
    this.passport,
    this.jpnAddress,
    this.jpnPostalCode,
    this.slAddress,
    this.slPostalCode,
    required this.jpnMobile,
    this.slMobile,
    this.email,
    this.passportPhotoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing UserData from JSON: $json');
    return UserData(
      id: json['id'] ?? 0,
      nickname: json['fullname'] ?? '',
      fullname: json['fullname'] ?? '',
      nic: json['nic'] ?? '',
      city: json['city'] ?? '',
      passport: json['passport'] ?? '',
      jpnAddress: json['address'] ?? '',
      jpnPostalCode: json['zipcode'] ?? '',
      slAddress: json['sl_address'] ?? '',
      slPostalCode: json['sl_zipcode'] ?? '',
      jpnMobile: json['mobile'] ?? json['tp'] ?? '',
      slMobile: json['sl_mobile'] ?? '',
      email: json['email'] ?? '',
      passportPhotoUrl: json['passport_photo'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'fullname': fullname,
      'nic': nic,
      'city': city,
      'passport': passport,
      'address': jpnAddress,
      'zipcode': jpnPostalCode,
      'sl_address': slAddress,
      'sl_zipcode': slPostalCode,
      'mobile': jpnMobile,
      'sl_mobile': slMobile,
      'email': email,
      'passport_photo': passportPhotoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}