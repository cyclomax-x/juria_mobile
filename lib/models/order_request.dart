import 'dart:io';

class OrderRequest {
  // Sender details
  final String senderName;
  final String senderTel;
  final String senderAddress;
  final String senderCity;
  final String? senderMail;
  final String? passportNumber;
  final File? senderPassportImage;

  // Receiver details
  final String recipientName;
  final String? recipientName2;
  final String recipientContact;
  final String recipientAddress;
  final String recipientCity;
  final String? recipientPassportNo;
  final File? receiverPassportImage;
  final String? postalCode;

  // Package details
  final String serviceType;
  final String? packageDescription;
  final int boxSizeId;
  final bool isCustomSize;
  final double? customWidth;
  final double? customHeight;
  final double? customLength;
  final double? customWeight;

  // Service details
  final int? riderId;
  final int? agentId;
  final int? locationId;

  // Payment details
  final String paymentMethod;
  final String? gift;

  // Action type
  final String action; // 'save' or 'finalize'

  OrderRequest({
    required this.senderName,
    required this.senderTel,
    required this.senderAddress,
    required this.senderCity,
    this.senderMail,
    this.passportNumber,
    this.senderPassportImage,
    required this.recipientName,
    this.recipientName2,
    required this.recipientContact,
    required this.recipientAddress,
    required this.recipientCity,
    this.recipientPassportNo,
    this.receiverPassportImage,
    this.postalCode,
    required this.serviceType,
    this.packageDescription,
    required this.boxSizeId,
    this.isCustomSize = false,
    this.customWidth,
    this.customHeight,
    this.customLength,
    this.customWeight,
    this.riderId,
    this.agentId,
    this.locationId,
    required this.paymentMethod,
    this.gift,
    this.action = 'finalize',
  });

  // Convert to form data for multipart requests
  Map<String, String> toFormData() {
    final Map<String, String> data = {
      // Sender details
      'shipper_name': senderName,
      'shipper_contact': senderTel,
      'shipper_address': senderAddress,
      'shipper_city': senderCity,
      
      // Receiver details
      'consignee_name': recipientName,
      'consignee_contact': recipientContact,
      'consignee_address': recipientAddress,
      'consignee_city': recipientCity,
      
      // Service and payment
      'service_type': serviceType,
      'payment_method': paymentMethod,
      'box_size_id': boxSizeId.toString(),
      'action': action,
    };

    // Add optional sender fields
    if (senderMail?.isNotEmpty == true) data['shipper_mail'] = senderMail!;
    if (passportNumber?.isNotEmpty == true) data['passport_no'] = passportNumber!;
    
    // Add optional receiver fields
    if (recipientName2?.isNotEmpty == true) data['other_consignee_names'] = recipientName2!;
    if (recipientPassportNo?.isNotEmpty == true) data['consignee_passport_no'] = recipientPassportNo!;
    if (postalCode?.isNotEmpty == true) data['postal_code'] = postalCode!;
    
    // Add package details
    if (packageDescription?.isNotEmpty == true) data['package_description'] = packageDescription!;
    
    // Add custom size fields
    if (isCustomSize) {
      data['is_custom_size'] = '1';
      if (customWidth != null) data['custom_width'] = customWidth!.toString();
      if (customHeight != null) data['custom_height'] = customHeight!.toString();
      if (customLength != null) data['custom_length'] = customLength!.toString();
      if (customWeight != null) data['custom_weight'] = customWeight!.toString();
    } else {
      data['is_custom_size'] = '0';
    }

    // Add service details
    if (riderId != null) data['assigned_rider'] = riderId!.toString();
    if (agentId != null) data['collecting_agent_id'] = agentId!.toString();
    if (locationId != null) data['location_id'] = locationId!.toString();
    
    // Add optional fields
    if (gift?.isNotEmpty == true) data['gift'] = gift!;

    return data;
  }

  // Convert to JSON for regular POST requests
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Sender details
      'shipper_name': senderName,
      'shipper_contact': senderTel,
      'shipper_address': senderAddress,
      'shipper_city': senderCity,
      
      // Receiver details
      'consignee_name': recipientName,
      'consignee_contact': recipientContact,
      'consignee_address': recipientAddress,
      'consignee_city': recipientCity,
      
      // Service and payment
      'service_type': serviceType,
      'payment_method': paymentMethod,
      'box_size_id': boxSizeId,
      'action': action,
    };

    // Add optional sender fields
    if (senderMail?.isNotEmpty == true) data['shipper_mail'] = senderMail;
    if (passportNumber?.isNotEmpty == true) data['passport_no'] = passportNumber;
    
    // Add optional receiver fields
    if (recipientName2?.isNotEmpty == true) data['other_consignee_names'] = recipientName2;
    if (recipientPassportNo?.isNotEmpty == true) data['consignee_passport_no'] = recipientPassportNo;
    if (postalCode?.isNotEmpty == true) data['postal_code'] = postalCode;
    
    // Add package details
    if (packageDescription?.isNotEmpty == true) data['package_description'] = packageDescription;
    
    // Add custom size fields
    if (isCustomSize) {
      data['is_custom_size'] = 1;
      if (customWidth != null) data['custom_width'] = customWidth;
      if (customHeight != null) data['custom_height'] = customHeight;
      if (customLength != null) data['custom_length'] = customLength;
      if (customWeight != null) data['custom_weight'] = customWeight;
    } else {
      data['is_custom_size'] = 0;
    }

    // Add service details
    if (riderId != null) data['assigned_rider'] = riderId;
    if (agentId != null) data['collecting_agent_id'] = agentId;
    if (locationId != null) data['location_id'] = locationId;
    
    // Add optional fields
    if (gift?.isNotEmpty == true) data['gift'] = gift;

    return data;
  }

  // Validation method
  Map<String, String>? validate() {
    Map<String, String> errors = {};

    // Required sender fields
    if (senderName.trim().isEmpty) {
      errors['shipper_name'] = 'Sender name is required';
    }
    if (senderTel.trim().isEmpty) {
      errors['shipper_contact'] = 'Sender contact is required';
    }
    if (senderAddress.trim().isEmpty) {
      errors['shipper_address'] = 'Sender address is required';
    }
    if (senderCity.trim().isEmpty) {
      errors['shipper_city'] = 'Sender city is required';
    }

    // Required receiver fields
    if (recipientName.trim().isEmpty) {
      errors['consignee_name'] = 'Recipient name is required';
    }
    if (recipientContact.trim().isEmpty) {
      errors['consignee_contact'] = 'Recipient contact is required';
    }
    if (recipientAddress.trim().isEmpty) {
      errors['consignee_address'] = 'Recipient address is required';
    }
    if (recipientCity.trim().isEmpty) {
      errors['consignee_city'] = 'Recipient city is required';
    }

    // Required service fields
    if (serviceType.trim().isEmpty) {
      errors['service_type'] = 'Service type is required';
    }
    if (paymentMethod.trim().isEmpty) {
      errors['payment_method'] = 'Payment method is required';
    }

    // Custom size validation
    if (isCustomSize) {
      if (customWidth == null || customWidth! <= 0) {
        errors['custom_width'] = 'Custom width is required';
      }
      if (customHeight == null || customHeight! <= 0) {
        errors['custom_height'] = 'Custom height is required';
      }
      if (customLength == null || customLength! <= 0) {
        errors['custom_length'] = 'Custom length is required';
      }
      if (customWeight == null || customWeight! <= 0) {
        errors['custom_weight'] = 'Custom weight is required';
      }
    }

    return errors.isEmpty ? null : errors;
  }
}