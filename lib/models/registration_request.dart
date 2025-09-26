import 'dart:io';

class RegistrationRequest {
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
  final File? passportPhoto;
  final String? password; // Optional, only for registration

  RegistrationRequest({
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
    this.passportPhoto,
    this.password,
  });

  // Convert to form data for API
  Map<String, String> toFormData() {
    final Map<String, String> data = {
      'nickname': nickname,
      'fullname': fullname,
      'jpn_mobile': jpnMobile,
      if (password != null && password!.isNotEmpty) 'password': password!,
    };

    // Add optional fields only if they are not null or empty
    if (nic?.isNotEmpty == true) data['nic'] = nic!;
    if (city?.isNotEmpty == true) data['city'] = city!;
    if (passport?.isNotEmpty == true) data['passport'] = passport!;
    if (jpnAddress?.isNotEmpty == true) data['jpn_address'] = jpnAddress!;
    if (jpnPostalCode?.isNotEmpty == true) data['jpn_postal_code'] = jpnPostalCode!;
    if (slAddress?.isNotEmpty == true) data['sl_address'] = slAddress!;
    if (slPostalCode?.isNotEmpty == true) data['sl_postal_code'] = slPostalCode!;
    if (slMobile?.isNotEmpty == true) data['sl_mobile'] = slMobile!;
    if (email?.isNotEmpty == true) data['email'] = email!;

    return data;
  }

  // Convert to JSON for API (without file)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nickname': nickname,
      'fullname': fullname,
      'jpn_mobile': jpnMobile,
      if (password != null && password!.isNotEmpty) 'password': password!,
    };

    // Add optional fields
    if (nic?.isNotEmpty == true) data['nic'] = nic;
    if (city?.isNotEmpty == true) data['city'] = city;
    if (passport?.isNotEmpty == true) data['passport'] = passport;
    if (jpnAddress?.isNotEmpty == true) data['jpn_address'] = jpnAddress;
    if (jpnPostalCode?.isNotEmpty == true) data['jpn_postal_code'] = jpnPostalCode;
    if (slAddress?.isNotEmpty == true) data['sl_address'] = slAddress;
    if (slPostalCode?.isNotEmpty == true) data['sl_postal_code'] = slPostalCode;
    if (slMobile?.isNotEmpty == true) data['sl_mobile'] = slMobile;
    if (email?.isNotEmpty == true) data['email'] = email;

    return data;
  }

  // Validation method
  Map<String, String>? validate() {
    Map<String, String> errors = {};

    // Required fields validation
    if (nickname.trim().isEmpty) {
      errors['nickname'] = 'Nickname is required';
    }
    
    if (fullname.trim().isEmpty) {
      errors['fullname'] = 'Full name is required';
    }
    
    if (jpnMobile.trim().isEmpty) {
      errors['jpn_mobile'] = 'Mobile number is required';
    }

    if (password != null && password!.isNotEmpty) {
      if (password!.length < 6) {
        errors['password'] = 'Password must be at least 6 characters';
      }
    }

    // Optional field validations
    if (nic != null && nic!.isNotEmpty) {
      if (nic!.length < 10 || nic!.length > 12) {
        errors['nic'] = 'NIC must be between 10-12 characters';
      }
    }

    if (jpnPostalCode != null && jpnPostalCode!.isNotEmpty) {
      if (jpnPostalCode!.length < 7 || jpnPostalCode!.length > 8) {
        errors['jpn_postal_code'] = 'Japan postal code must be 7-8 characters';
      }
    }

    if (slPostalCode != null && slPostalCode!.isNotEmpty) {
      if (slPostalCode!.length != 5 || !RegExp(r'^\d+$').hasMatch(slPostalCode!)) {
        errors['sl_postal_code'] = 'Sri Lanka postal code must be exactly 5 digits';
      }
    }

    if (email != null && email!.isNotEmpty) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
        errors['email'] = 'Please enter a valid email address';
      }
    }

    return errors.isEmpty ? null : errors;
  }
}