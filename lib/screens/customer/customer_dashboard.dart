import 'package:flutter/material.dart';
import 'pages/new_order_page.dart';
import 'pages/past_orders_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/dashboard_data.dart';
import '../auth/login_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  // Pages for bottom navigation
  List<Widget> get _pages => [
    const DashboardHome(),
    const PastOrdersPage(),
    NewOrderPage(
      onOrderCreated: () {
        setState(() {
          _selectedIndex = 0; // Navigate to home page after order creation
        });
      },
    ),
    const ProfilePage(),
    const SettingsPage(),
  ];

  // Page titles for the app bar
  final List<String> _pageTitles = [
    'Dashboard',
    'My Orders',
    '+ Create New Order',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(_pageTitles[_selectedIndex]),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications coming soon!'),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.power_settings_new_rounded),
                  tooltip: 'Logout',
                  onPressed: _showLogoutConfirmation,
                ),
              ],
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildBottomNavItem(
                1,
                Icons.history_outlined,
                Icons.history,
                'Orders',
              ),
              _buildNewOrderButton(),
              _buildBottomNavItem(
                3,
                Icons.person_outline,
                Icons.person,
                'Profile',
              ),
              _buildBottomNavItem(
                4,
                Icons.settings_outlined,
                Icons.settings,
                'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrderButton() {
    final isSelected = _selectedIndex == 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = 2;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            214,
            214,
            214,
          ), // Light grey background for the button
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 45,
          height: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Icon(
            Icons.add,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout? You will need to login again to access your account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _performLogout(); // Perform logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Perform logout operation
  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          );
        },
      );

      // Call logout service to clear token and user data
      await AuthService.logout();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to login screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ==========================================
// DASHBOARD HOME PAGE
// ==========================================
class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  DashboardData? _dashboardData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await OrderService.getMobileDashboardData();

      setState(() {
        _dashboardData = data;
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
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Welcome section
          Card(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texts on the left
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready to send a package?',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Logo on the right
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Image.asset(
                      'assets/images/juria_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Main action tiles
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context,
                  'New Order',
                  'Send a package',
                  Icons.add_box_outlined,
                  Colors.blue,
                  () {
                    // Navigate to new order page (index 2 in bottom navigation)
                    final customerDashboard = context.findAncestorStateOfType<_CustomerDashboardState>();
                    customerDashboard?.setState(() {
                      customerDashboard._selectedIndex = 2;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context,
                  'My Orders',
                  'Track packages',
                  Icons.local_shipping_outlined,
                  Colors.green,
                  () {
                    // Navigate to my orders page (index 1 in bottom navigation)
                    final customerDashboard = context.findAncestorStateOfType<_CustomerDashboardState>();
                    customerDashboard?.setState(() {
                      customerDashboard._selectedIndex = 1;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats section
          Text(
            'Order Statistics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _error != null
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Error loading dashboard',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadDashboardData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            _dashboardData?.totalOrders.toString() ?? '0',
                            'Total Orders',
                            Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            _dashboardData?.confirmedOrders.toString() ?? '0',
                            'Confirmed',
                            Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            _dashboardData?.shippedOrders.toString() ?? '0',
                            'Shipped',
                            Icons.local_shipping_outlined,
                          ),
                        ),
                      ],
                    ),
          const SizedBox(height: 20),

          const SizedBox(height: 20),

          // Recent orders
          Text(
            'Recent Orders',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            const SizedBox.shrink()
          else if (_dashboardData?.recentOrders.isEmpty ?? true)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recent orders',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Your recent orders will appear here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._dashboardData!.recentOrders.map((order) => _buildRecentOrderItem(
                  context,
                  order.reference,
                  order.route,
                  order.statusText,
                  _getStatusColor(order.status),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String number,
    String label,
    IconData icon,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
            const SizedBox(height: 8),
            Text(
              number,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xFFFF9800); // Orange - Pending
      case 1:
        return const Color(0xFF2196F3); // Blue - Confirmed
      case 2:
        return const Color(0xFFF44336); // Red - Rejected
      case 3:
        return const Color(0xFF9C27B0); // Purple - Picked Up
      case 4:
        return const Color(0xFF607D8B); // Blue Grey - In Warehouse
      case 5:
        return const Color(0xFF00BCD4); // Cyan - Shipped
      case 6:
        return const Color(0xFF4CAF50); // Green - Delivered
      default:
        return const Color(0xFF9E9E9E); // Grey - Unknown
    }
  }

  Widget _buildRecentOrderItem(
    BuildContext context,
    String orderNumber,
    String route,
    String status,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.inventory_2_outlined, color: statusColor),
        ),
        title: Text(
          orderNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(route),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // Navigate to My Orders page (index 1 in bottom navigation)
          final customerDashboard = context.findAncestorStateOfType<_CustomerDashboardState>();
          if (customerDashboard != null) {
            customerDashboard.setState(() {
              customerDashboard._selectedIndex = 1;
            });
          }
        },
      ),
    );
  }
}
