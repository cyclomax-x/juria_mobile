import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../services/order_service.dart';

class PastOrdersPage extends StatefulWidget {
  const PastOrdersPage({super.key});

  @override
  State<PastOrdersPage> createState() => _PastOrdersPageState();
}

class _PastOrdersPageState extends State<PastOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';

  // Real orders from API
  List<Order> _allOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders = await OrderService.getOrderHistory();

      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Order> get _filteredOrders {
    List<Order> orders = _allOrders;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        final searchLower = _searchQuery.toLowerCase();
        return order.reference.toLowerCase().contains(searchLower) ||
               order.senderName.toLowerCase().contains(searchLower) ||
               order.recipientName.toLowerCase().contains(searchLower) ||
               order.senderCity.toLowerCase().contains(searchLower) ||
               order.recipientCity.toLowerCase().contains(searchLower) ||
               (order.csljNo?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Filter by selected status
    switch (_selectedStatus) {
      case 'Pending':
        orders = orders.where((order) => order.status == 0).toList();
        break;
      case 'Confirmed':
        orders = orders.where((order) => order.status == 1).toList();
        break;
      case 'Rejected':
        orders = orders.where((order) => order.status == 2).toList();
        break;
      case 'Picked Up':
        orders = orders.where((order) => order.status == 3).toList();
        break;
      case 'In Warehouse':
        orders = orders.where((order) => order.status == 4).toList();
        break;
      case 'Shipped':
        orders = orders.where((order) => order.status == 5).toList();
        break;
      default: // All Orders
        break;
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading orders...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading orders',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Status Filter Panel
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surface,
                      child: Row(
                        children: [
                          // Text(
                          //   'Filter by Status:',
                          //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                underline: Container(),
                                isExpanded: true,
                                dropdownColor: Theme.of(context).colorScheme.surface,
                                style: Theme.of(context).textTheme.bodyMedium,
                                items: const [
                                  DropdownMenuItem(value: 'All', child: Text('All Orders')),
                                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                  DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                                  DropdownMenuItem(value: 'Picked Up', child: Text('Picked Up')),
                                  DropdownMenuItem(value: 'In Warehouse', child: Text('In Warehouse')),
                                  DropdownMenuItem(value: 'Shipped', child: Text('Shipped')),
                                ],
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      color: Theme.of(context).colorScheme.surface,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search orders...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),

                    // Orders List
                    Expanded(
                      child: _filteredOrders.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredOrders.length,
                                itemBuilder: (context, index) {
                                  final order = _filteredOrders[index];
                                  return _buildOrderCard(order);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Your orders will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.reference,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order.statusText,
                      style: TextStyle(
                        color: order.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // CSLJ and package info
              Row(
                children: [
                  if (order.csljNo != null) ...[
                    Icon(Icons.confirmation_number, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      order.csljNo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                  Text(
                    '${order.packages.length} package${order.packages.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${order.senderName} - ${order.senderCity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'To',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${order.recipientName} - ${order.recipientCity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.datetime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '¥${order.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // Service type indicator
              if (order.isDoorToDoor) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 16,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Door-to-Door',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => OrderDetailsBottomSheet(order: order),
    );
  }
}

class OrderDetailsBottomSheet extends StatelessWidget {
  final Order order;

  const OrderDetailsBottomSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildInfoSection(context, 'Order Information', [
                      _buildInfoRow('Reference', order.reference),
                      if (order.csljNo != null) _buildInfoRow('CSLJ No', order.csljNo!),
                      if (order.csl != null) _buildInfoRow('CSL', order.csl!),
                      _buildInfoRow('Date', order.datetime),
                      _buildInfoRow('Service Type', order.serviceType),
                      _buildInfoRow('Payment Method', order.paymentMethod),
                      _buildInfoRow('Total Amount', '¥${order.totalPrice.toStringAsFixed(2)}'),
                    ]),

                    const SizedBox(height: 16),

                    _buildInfoSection(context, 'Sender Information', [
                      _buildInfoRow('Name', order.senderName),
                      _buildInfoRow('Phone', order.senderTel),
                      _buildInfoRow('Address', '${order.senderAddress}, ${order.senderCity}'),
                      if (order.senderMail != null && order.senderMail!.isNotEmpty)
                        _buildInfoRow('Email', order.senderMail!),
                      if (order.passportNumber != null)
                        _buildInfoRow('Passport', order.passportNumber!),
                    ]),

                    const SizedBox(height: 16),

                    _buildInfoSection(context, 'Recipient Information', [
                      _buildInfoRow('Name', order.recipientName),
                      _buildInfoRow('Phone', order.recipientContact),
                      _buildInfoRow('Address', '${order.recipientAddress}, ${order.recipientCity}'),
                      if (order.recipientPassportNo != null)
                        _buildInfoRow('Passport', order.recipientPassportNo!),
                      if (order.postalCode != null)
                        _buildInfoRow('Postal Code', order.postalCode!),
                    ]),

                    const SizedBox(height: 16),

                    _buildInfoSection(context, 'Packages (${order.packages.length})',
                      order.packages.map((pkg) => _buildPackageCard(pkg)).toList(),
                    ),

                    if (order.riderName != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoSection(context, 'Delivery Information', [
                        _buildInfoRow('Rider', order.riderName!),
                        if (order.pickedDate != null)
                          _buildInfoRow('Picked Date', order.pickedDate!),
                        if (order.whHandoverDate != null)
                          _buildInfoRow('Warehouse Date', order.whHandoverDate!),
                        if (order.loadDate != null)
                          _buildInfoRow('Load Date', order.loadDate!),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(OrderPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            package.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Size: ${package.sizeText}'),
          Text('Weight: ${package.weight.toStringAsFixed(2)} kg'),
          Text('Volume: ${package.volume.toStringAsFixed(3)} m³'),
          Text(
            'Price: ¥${package.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}