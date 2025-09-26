import 'package:flutter/material.dart';

class BillingStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;
  final List<Map<String, dynamic>> packageList;
  final String selectedServiceType;
  final String Function() calculateTotalAmount;

  const BillingStep({
    super.key,
    required this.formKey,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.packageList,
    required this.selectedServiceType,
    required this.calculateTotalAmount,
  });

  @override
  State<BillingStep> createState() => _BillingStepState();
}

class _BillingStepState extends State<BillingStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Billing Information'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment_outlined),
                border: OutlineInputBorder(),
              ),
              items: ['Net Bank', 'Post Office', 'Cash']
                  .map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  )
                  .toList(),
              onChanged: (value) => widget.onPaymentMethodChanged(value!),
            ),
            const SizedBox(height: 20),
            _buildPriceBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.packageList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> package = entry.value;
              return _buildPriceRow(
                'Package ${index + 1}: ${package['description']}',
                '¥${package['price']?.toStringAsFixed(2) ?? '0.00'}',
              );
            }).toList(),
            const Divider(),
            _buildPriceRow(
              'Packages Subtotal (${widget.packageList.length})',
              '¥${widget.packageList.fold(0.0, (sum, package) => sum + (package['price'] ?? 0.0)).toStringAsFixed(2)}',
            ),
            if (widget.selectedServiceType == 'Door-to-Door Delivery')
              _buildPriceRow('Service Fee', '¥1,000.00'),
            const Divider(),
            _buildPriceRow(
              'Total Amount',
              '¥${widget.calculateTotalAmount()}',
              isTotal: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Payment Method: ${widget.selectedPaymentMethod}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
