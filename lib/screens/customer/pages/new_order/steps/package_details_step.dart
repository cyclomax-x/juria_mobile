import 'package:flutter/material.dart';
import '../../../../../models/box_size.dart';
import '../../../../../services/order_service.dart';

class PackageDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController packageDescriptionController;
  final TextEditingController customWidthController;
  final TextEditingController customHeightController;
  final TextEditingController customLengthController;
  final TextEditingController customWeightController;
  final String selectedServiceType;
  final int selectedBoxSizeId;
  final List<BoxSize> boxSizes;
  final bool isCustomSize;
  final List<Map<String, dynamic>> packageList;
  final Function(String) onServiceTypeChanged;
  final Function(int) onBoxSizeChanged;
  final VoidCallback onAddPackage;
  final Function(int) onRemovePackage;

  const PackageDetailsStep({
    super.key,
    required this.formKey,
    required this.packageDescriptionController,
    required this.customWidthController,
    required this.customHeightController,
    required this.customLengthController,
    required this.customWeightController,
    required this.selectedServiceType,
    required this.selectedBoxSizeId,
    required this.boxSizes,
    required this.isCustomSize,
    required this.packageList,
    required this.onServiceTypeChanged,
    required this.onBoxSizeChanged,
    required this.onAddPackage,
    required this.onRemovePackage,
  });

  @override
  State<PackageDetailsStep> createState() => _PackageDetailsStepState();
}

class _PackageDetailsStepState extends State<PackageDetailsStep> {
  bool _isCalculatingPrice = false;
  double? _calculatedPrice;
  double? _calculatedVolume;
  String? _priceError;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Package Details'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.selectedServiceType,
              decoration: const InputDecoration(
                labelText: 'Service Type',
                prefixIcon: Icon(Icons.delivery_dining_outlined),
                border: OutlineInputBorder(),
              ),
              items: ['Door-to-Door Pickup']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) => widget.onServiceTypeChanged(value!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.packageDescriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Package Description',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe the package';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: widget.selectedBoxSizeId,
              decoration: const InputDecoration(
                labelText: 'Box Size',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
              items: [
                // Add API provided box sizes
                ...widget.boxSizes
                    .map(
                      (boxSize) => DropdownMenuItem(
                        value: boxSize.id,
                        child: Text(boxSize.displayText),
                      ),
                    )
                    .toList(),
                // Add Custom Size option
                const DropdownMenuItem(
                  value: 999, // Special ID for custom size
                  child: Text('Custom Size'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onBoxSizeChanged(value);
                }
              },
            ),
            if (widget.isCustomSize) ..._buildCustomSizeFields(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Maximum dimensions: 2m × 2m × 2m, Weight: 30kg',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Packages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onAddPackage,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Package'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPackageList(),
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

  List<Widget> _buildCustomSizeFields() {
    return [
      const SizedBox(height: 12),
      Text(
        'Custom Dimensions',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.customWidthController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Width (m)',
                border: OutlineInputBorder(),
              ),
              onChanged: _onDimensionChanged,
              validator: (value) {
                if (widget.isCustomSize && (value == null || value.isEmpty)) {
                  return 'Required';
                }
                if (widget.isCustomSize && value != null) {
                  final width = double.tryParse(value);
                  if (width == null || width <= 0) {
                    return 'Invalid width';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: widget.customHeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Height (m)',
                border: OutlineInputBorder(),
              ),
              onChanged: _onDimensionChanged,
              validator: (value) {
                if (widget.isCustomSize && (value == null || value.isEmpty)) {
                  return 'Required';
                }
                if (widget.isCustomSize && value != null) {
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Invalid height';
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.customLengthController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Length (m)',
                border: OutlineInputBorder(),
              ),
              onChanged: _onDimensionChanged,
              validator: (value) {
                if (widget.isCustomSize && (value == null || value.isEmpty)) {
                  return 'Required';
                }
                if (widget.isCustomSize && value != null) {
                  final length = double.tryParse(value);
                  if (length == null || length <= 0) {
                    return 'Invalid length';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: widget.customWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (widget.isCustomSize && (value == null || value.isEmpty)) {
                  return 'Required';
                }
                if (widget.isCustomSize && value != null) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Invalid weight';
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _buildVolumeAndPriceDisplay(),
      if (_priceError != null) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _priceError!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  Widget _buildVolumeAndPriceDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Volume & Price Calculation',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_calculatedVolume != null) ...[
            Text(
              'Volume: ${_calculatedVolume!.toStringAsFixed(3)} m³',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
          ],
          if (_calculatedPrice != null) ...[
            Text(
              'Calculated Price: ¥${_calculatedPrice!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ] else if (_isCalculatingPrice) ...[
            const Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Calculating price...', style: TextStyle(fontSize: 12)),
              ],
            ),
          ] else ...[
            const Text(
              'Enter dimensions to calculate price',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  void _onDimensionChanged(String value) {
    if (!widget.isCustomSize) return;

    // Get current dimension values
    final width = double.tryParse(widget.customWidthController.text);
    final height = double.tryParse(widget.customHeightController.text);
    final length = double.tryParse(widget.customLengthController.text);

    // Reset states
    setState(() {
      _priceError = null;
      _calculatedPrice = null;
      _calculatedVolume = null;
    });

    // Check if all dimensions are entered
    if (width != null && height != null && length != null &&
        width > 0 && height > 0 && length > 0) {

      // Calculate volume
      final volume = width * height * length;

      // Validate volume (max 0.2 cubic meters)
      if (volume > 0.2) {
        setState(() {
          _priceError = 'Volume exceeds maximum allowed (0.2 m³). Current: ${volume.toStringAsFixed(3)} m³';
          _calculatedVolume = volume;
        });
        return;
      }

      // Calculate price via API
      _calculatePrice(width, height, length);
    }
  }

  Future<void> _calculatePrice(double width, double height, double length) async {
    setState(() {
      _isCalculatingPrice = true;
      _priceError = null;
    });

    try {
      final response = await OrderService.calculatePrice(
        width: width,
        height: height,
        length: length,
      );

      if (response['success'] == true) {
        setState(() {
          _calculatedPrice = double.tryParse(response['price']?.toString() ?? '0') ?? 0.0;
          _calculatedVolume = double.tryParse(response['volume']?.toString() ?? '0') ?? 0.0;
          _isCalculatingPrice = false;
        });
      } else {
        setState(() {
          _priceError = response['message'] ?? 'Failed to calculate price';
          _isCalculatingPrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _priceError = 'Error calculating price: ${e.toString()}';
        _isCalculatingPrice = false;
      });
    }
  }

  Widget _buildPackageList() {
    if (widget.packageList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No packages added yet. Add your first package above.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.packageList.length,
      itemBuilder: (context, index) {
        final package = widget.packageList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(package['description']),
            subtitle: Text('${package['serviceType']} • ${package['size']} • ¥${package['price']?.toStringAsFixed(2) ?? '0.00'}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => widget.onRemovePackage(index),
            ),
          ),
        );
      },
    );
  }
}
