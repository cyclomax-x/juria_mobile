class DashboardData {
  final int totalOrders;
  final int confirmedOrders;
  final int shippedOrders;
  final List<RecentOrder> recentOrders;

  DashboardData({
    required this.totalOrders,
    required this.confirmedOrders,
    required this.shippedOrders,
    required this.recentOrders,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Parse status_counts array to get specific status counts
    final statusCounts = json['status_counts'] as List<dynamic>? ?? [];

    int totalOrders = 0;
    int confirmedOrders = 0; // status 1
    int shippedOrders = 0;   // status 5

    for (var statusCount in statusCounts) {
      final status = int.tryParse(statusCount['status']?.toString() ?? '0') ?? 0;
      final count = int.tryParse(statusCount['count']?.toString() ?? '0') ?? 0;

      totalOrders += count; // Sum all status counts for total

      if (status > 2) {
        confirmedOrders += count; // Include all statuses > 2 in confirmed count
      }

      if (status == 5) {
        shippedOrders = count;
      }
    }

    return DashboardData(
      totalOrders: totalOrders,
      confirmedOrders: confirmedOrders,
      shippedOrders: shippedOrders,
      recentOrders: (json['recent_orders'] as List<dynamic>?)
              ?.map((item) => RecentOrder.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class RecentOrder {
  final String reference;
  final String senderAddress;
  final String recipientAddress;
  final int status;

  RecentOrder({
    required this.reference,
    required this.senderAddress,
    required this.recipientAddress,
    required this.status,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      reference: json['reference']?.toString() ?? '',
      senderAddress: json['sender_address']?.toString() ?? '',
      recipientAddress: json['recipient_address']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
    );
  }

  String get route => '$senderAddress → $recipientAddress';

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
}