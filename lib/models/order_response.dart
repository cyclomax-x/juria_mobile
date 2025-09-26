class OrderResponse {
  final bool success;
  final String message;
  final int? status;
  final String? action;
  final String? orderId;
  final String? reference;
  final Map<String, dynamic>? errors;

  OrderResponse({
    required this.success,
    required this.message,
    this.status,
    this.action,
    this.orderId,
    this.reference,
    this.errors,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['status'] == 200,
      message: json['message'] ?? '',
      status: json['status'],
      action: json['action'],
      orderId: json['id']?.toString(),
      reference: json['reference']?.toString(),
      errors: json['errors'],
    );
  }

  factory OrderResponse.error(String message, {Map<String, dynamic>? errors}) {
    return OrderResponse(
      success: false,
      message: message,
      status: 400,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'action': action,
      'id': orderId,
      'reference': reference,
      'errors': errors,
    };
  }

  // Get user-friendly error message
  String get userMessage {
    if (errors != null && errors!.isNotEmpty) {
      List<String> errorMessages = [];
      errors!.forEach((field, messages) {
        if (messages is List) {
          errorMessages.addAll(messages.map((msg) => msg.toString()));
        } else {
          errorMessages.add(messages.toString());
        }
      });
      if (errorMessages.isNotEmpty) {
        return '$message\n\n${errorMessages.join('\n')}';
      }
    }
    return message;
  }
}