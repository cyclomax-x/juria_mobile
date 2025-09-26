import 'package:flutter/material.dart';

class Order {
  final int id;
  final String reference;
  final String serviceType;
  final String? parcelDes;
  final int pRequestId;
  final String senderName;
  final String senderAddress;
  final String senderCity;
  final String senderTel;
  final String? senderMail;
  final String? passportNumber;
  final String? passportPhoto;
  final String? recipientName2;
  final String recipientName;
  final String recipientAddress;
  final String recipientContact;
  final String recipientCity;
  final String? recipientPassportNo;
  final String? recipientPassportPhoto;
  final String? enableExchange;
  final String paymentMethod;
  final String datetime;
  final String createdUser;
  final String? boxId;
  final int status;
  final int? riderId;
  final String? pickupDate;
  final String? whHandover;
  final String? loadingDate;
  final int? agentId;
  final int? agentLocationId;
  final int d2d;
  final String createdAt;
  final String updatedAt;
  final String? postalCodeJp;
  final String? postalCode;
  final String accNo;
  final String? extraFee;
  final int passportCopy;
  final int cDocument;
  final int cashCollecting;
  final String? conformedDate;
  final String? pickedDate;
  final String? whHandoverDate;
  final String? loadDate;
  final double? paidAmount;
  final int? gift;
  final String? csljNo;
  final String? csl;
  final String? riderName;
  final List<OrderPackage> packages;
  final double totalPrice;

  Order({
    required this.id,
    required this.reference,
    required this.serviceType,
    this.parcelDes,
    required this.pRequestId,
    required this.senderName,
    required this.senderAddress,
    required this.senderCity,
    required this.senderTel,
    this.senderMail,
    this.passportNumber,
    this.passportPhoto,
    this.recipientName2,
    required this.recipientName,
    required this.recipientAddress,
    required this.recipientContact,
    required this.recipientCity,
    this.recipientPassportNo,
    this.recipientPassportPhoto,
    this.enableExchange,
    required this.paymentMethod,
    required this.datetime,
    required this.createdUser,
    this.boxId,
    required this.status,
    this.riderId,
    this.pickupDate,
    this.whHandover,
    this.loadingDate,
    this.agentId,
    this.agentLocationId,
    required this.d2d,
    required this.createdAt,
    required this.updatedAt,
    this.postalCodeJp,
    this.postalCode,
    required this.accNo,
    this.extraFee,
    required this.passportCopy,
    required this.cDocument,
    required this.cashCollecting,
    this.conformedDate,
    this.pickedDate,
    this.whHandoverDate,
    this.loadDate,
    this.paidAmount,
    this.gift,
    this.csljNo,
    this.csl,
    this.riderName,
    required this.packages,
    required this.totalPrice,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reference: json['reference']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      parcelDes: json['parcel_des']?.toString(),
      pRequestId: int.tryParse(json['p_request_id']?.toString() ?? '0') ?? 0,
      senderName: json['sender_name']?.toString() ?? '',
      senderAddress: json['sender_address']?.toString() ?? '',
      senderCity: json['sender_city']?.toString() ?? '',
      senderTel: json['sender_tel']?.toString() ?? '',
      senderMail: json['sender_mail']?.toString(),
      passportNumber: json['passport_number']?.toString(),
      passportPhoto: json['passport_photo']?.toString(),
      recipientName2: json['recipient_name2']?.toString(),
      recipientName: json['recipient_name']?.toString() ?? '',
      recipientAddress: json['recipient_address']?.toString() ?? '',
      recipientContact: json['recipient_contact']?.toString() ?? '',
      recipientCity: json['recipient_city']?.toString() ?? '',
      recipientPassportNo: json['recipient_passport_no']?.toString(),
      recipientPassportPhoto: json['recipient_passport_photo']?.toString(),
      enableExchange: json['enable_exchange']?.toString(),
      paymentMethod: json['payment_method']?.toString() ?? '',
      datetime: json['datetime']?.toString() ?? '',
      createdUser: json['created_user']?.toString() ?? '',
      boxId: json['box_id']?.toString(),
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      riderId: int.tryParse(json['rider_id']?.toString() ?? '0'),
      pickupDate: json['pickup_date']?.toString(),
      whHandover: json['wh_handover']?.toString(),
      loadingDate: json['loading_date']?.toString(),
      agentId: int.tryParse(json['agent_id']?.toString() ?? '0'),
      agentLocationId: int.tryParse(json['agent_location_id']?.toString() ?? '0'),
      d2d: int.tryParse(json['d2d']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      postalCodeJp: json['postal_code_jp']?.toString(),
      postalCode: json['postal_code']?.toString(),
      accNo: json['acc_no']?.toString() ?? '',
      extraFee: json['extra_fee']?.toString(),
      passportCopy: int.tryParse(json['passport_copy']?.toString() ?? '0') ?? 0,
      cDocument: int.tryParse(json['c_document']?.toString() ?? '0') ?? 0,
      cashCollecting: int.tryParse(json['cash_collecting']?.toString() ?? '0') ?? 0,
      conformedDate: json['conformed_date']?.toString(),
      pickedDate: json['picked_date']?.toString(),
      whHandoverDate: json['wh_handover_date']?.toString(),
      loadDate: json['load_date']?.toString(),
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0'),
      gift: int.tryParse(json['gift']?.toString() ?? '0'),
      csljNo: json['cslj_no']?.toString(),
      csl: json['csl']?.toString(),
      riderName: json['rider_name']?.toString(),
      packages: (json['packages'] as List<dynamic>?)
              ?.map((p) => OrderPackage.fromJson(p))
              .toList() ??
          [],
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
    );
  }

  // Helper methods for status
  String get statusText {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Rejected';
      case 3:
        return 'Picked Up';
      case 4:
        return 'In Warehouse';
      case 5:
        return 'Shipped';
      case 6:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 0:
        return const Color(0xFFFF9800); // Orange
      case 1:
        return const Color(0xFF2196F3); // Blue
      case 2:
        return const Color(0xFFF44336); // Red
      case 3:
        return const Color(0xFF9C27B0); // Purple
      case 4:
        return const Color(0xFF607D8B); // Blue Grey
      case 5:
        return const Color(0xFF00BCD4); // Cyan
      case 6:
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  bool get isDoorToDoor => d2d == 1;
}

class OrderPackage {
  final int id;
  final String reference;
  final String packageType;
  final int boxId;
  final double height;
  final double width;
  final double length;
  final String createdAt;
  final String updatedAt;
  final double weight;
  final double price;
  final double volume;
  final String description;
  final int customSize;
  final String? chassieNo;
  final String? engineNo;

  OrderPackage({
    required this.id,
    required this.reference,
    required this.packageType,
    required this.boxId,
    required this.height,
    required this.width,
    required this.length,
    required this.createdAt,
    required this.updatedAt,
    required this.weight,
    required this.price,
    required this.volume,
    required this.description,
    required this.customSize,
    this.chassieNo,
    this.engineNo,
  });

  factory OrderPackage.fromJson(Map<String, dynamic> json) {
    return OrderPackage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      reference: json['reference']?.toString() ?? '',
      packageType: json['package_type']?.toString() ?? '',
      boxId: int.tryParse(json['box_id']?.toString() ?? '0') ?? 0,
      height: double.tryParse(json['h']?.toString() ?? '0') ?? 0.0,
      width: double.tryParse(json['w']?.toString() ?? '0') ?? 0.0,
      length: double.tryParse(json['l']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      volume: double.tryParse(json['volume']?.toString() ?? '0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      customSize: int.tryParse(json['custom_size']?.toString() ?? '0') ?? 0,
      chassieNo: json['chassie_no']?.toString(),
      engineNo: json['engine_no']?.toString(),
    );
  }

  bool get isCustomSize => customSize == 1;

  String get sizeText {
    if (isCustomSize) {
      return 'Custom (${width}×${height}×${length}m)';
    }
    return 'Box ID: $boxId';
  }
}