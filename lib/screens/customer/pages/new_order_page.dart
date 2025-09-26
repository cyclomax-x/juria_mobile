import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'new_order/steps/sender_details_step.dart';
import 'new_order/steps/receiver_details_step.dart';
import 'new_order/steps/package_details_step.dart';
import 'new_order/steps/service_details_step.dart';
import 'new_order/steps/billing_step.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/box_size.dart';
import '../../../models/agent.dart';
import '../../../models/order_request.dart';
import '../../../models/registration_response.dart';

class NewOrderPage extends StatefulWidget {
  final VoidCallback? onOrderCreated;

  const NewOrderPage({super.key, this.onOrderCreated});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();

  // Form Keys
  final _senderFormKey = GlobalKey<FormState>();
  final _receiverFormKey = GlobalKey<FormState>();
  final _packageFormKey = GlobalKey<FormState>();
  final _serviceFormKey = GlobalKey<FormState>();
  final _billingFormKey = GlobalKey<FormState>();

  // Sender Details Controllers
  final _senderFullNameController = TextEditingController();
  final _senderContactController = TextEditingController();
  final _senderCityController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _senderPassportController = TextEditingController();
  File? _senderPassportImage;

  // Receiver Details Controllers
  final _receiverFullNameController = TextEditingController();
  final _receiverContactController = TextEditingController();
  final _receiverCityController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverEmailController = TextEditingController();
  final _receiverPassportController = TextEditingController();
  final _receiverPostalCodeController = TextEditingController();
  File? _receiverPassportImage;

  // Package Details Controllers
  final _packageDescriptionController = TextEditingController();
  final _customWidthController = TextEditingController();
  final _customHeightController = TextEditingController();
  final _customLengthController = TextEditingController();
  final _customWeightController = TextEditingController();

  // Form state
  String _selectedServiceType = 'Door-to-Door Pickup';
  int _selectedBoxSizeId = 1;
  bool _isCustomSize = false;
  List<Map<String, dynamic>> _packageList = [];

  int? _selectedAgentId;
  int? _selectedLocationId;
  String _selectedPaymentMethod = 'Cash';

  // API Data
  List<BoxSize> _boxSizes = [];
  List<Agent> _agents = [];
  bool _isLoadingData = true;
  String? _dataLoadError;

  final List<String> _stepTitles = [
    'Sender Details',
    'Receiver Details',
    'Package Details',
    'Service Details',
    'Billing',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _senderFullNameController.dispose();
    _senderContactController.dispose();
    _senderCityController.dispose();
    _senderAddressController.dispose();
    _senderEmailController.dispose();
    _senderPassportController.dispose();
    _receiverFullNameController.dispose();
    _receiverContactController.dispose();
    _receiverCityController.dispose();
    _receiverAddressController.dispose();
    _receiverEmailController.dispose();
    _receiverPassportController.dispose();
    _receiverPostalCodeController.dispose();
    _packageDescriptionController.dispose();
    _customWidthController.dispose();
    _customHeightController.dispose();
    _customLengthController.dispose();
    _customWeightController.dispose();
    super.dispose();
  }

  // Load initial data (box sizes, agents, and user data)
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoadingData = true;
        _dataLoadError = null;
      });

      // Load box sizes, agents, and current user data in parallel
      final results = await Future.wait([
        OrderService.getBoxSizes(),
        OrderService.getAgents(),
        AuthService.getCurrentUser(),
      ]);

      final boxSizes = results[0] as List<BoxSize>;
      final agents = results[1] as List<Agent>;
      final userData = results[2] as UserData?;

      setState(() {
        _boxSizes = boxSizes;
        _agents = agents;
        _isLoadingData = false;

        debugPrint('Box sizes loaded: ${_boxSizes.map((b) => '${b.description} (custom: ${b.isCustomSize})').toList()}');

        // Set default selections
        if (_boxSizes.isNotEmpty) {
          _selectedBoxSizeId = _boxSizes.first.id;
        }
        if (_agents.isNotEmpty) {
          _selectedAgentId = _agents.first.id;
        }

        // Auto-fill sender details with logged-in user data
        if (userData != null) {
          _fillSenderDetailsFromUser(userData);
        } else {
          debugPrint('No user data available to auto-fill sender details');
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
        _dataLoadError = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fill sender details with user data
  void _fillSenderDetailsFromUser(UserData userData) {
    debugPrint('Filling sender details with user data: ${userData.jpnAddress}');
    _senderFullNameController.text = userData.fullname;
    _senderContactController.text = userData.jpnMobile;
    _senderEmailController.text = userData.email ?? '';
    _senderPassportController.text = userData.passport ?? '';

    // Fill address and city based on Japanese address
    if (userData.jpnAddress != null && userData.jpnAddress!.isNotEmpty) {
      _senderAddressController.text = userData.jpnAddress!;
    }

    if (userData.city != null && userData.city!.isNotEmpty) {
      _senderCityController.text = userData.city!;
    }

    // Load passport image from URL if available
    if (userData.passportPhotoUrl != null &&
        userData.passportPhotoUrl!.isNotEmpty) {
      _loadPassportImageFromUrl(userData.passportPhotoUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading order data...'),
                ],
              ),
            )
          : _dataLoadError != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _dataLoadError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    children: List.generate(_stepTitles.length, (index) {
                      bool isCompleted = index < _currentStep;
                      bool isCurrent = index == _currentStep;
                      bool isActive = index <= _currentStep;

                      return Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  // Step indicator circle with number
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? Colors.green
                                          : isCurrent
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: isCompleted
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: isActive
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Progress bar
                                  Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Connector line (except for last item)
                            if (index < _stepTitles.length - 1)
                              Container(
                                width: 20,
                                height: 2,
                                margin: const EdgeInsets.only(bottom: 18),
                                color: index < _currentStep
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                // Main content area
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SenderDetailsStep(
                        formKey: _senderFormKey,
                        fullNameController: _senderFullNameController,
                        contactController: _senderContactController,
                        cityController: _senderCityController,
                        addressController: _senderAddressController,
                        emailController: _senderEmailController,
                        passportController: _senderPassportController,
                        passportImage: _senderPassportImage,
                        onImageSelected: (file) => _pickImageForSender(),
                      ),
                      ReceiverDetailsStep(
                        formKey: _receiverFormKey,
                        fullNameController: _receiverFullNameController,
                        contactController: _receiverContactController,
                        cityController: _receiverCityController,
                        addressController: _receiverAddressController,
                        emailController: _receiverEmailController,
                        passportController: _receiverPassportController,
                        postalCodeController: _receiverPostalCodeController,
                        passportImage: _receiverPassportImage,
                        onImageSelected: (file) => _pickImageForReceiver(),
                      ),
                      PackageDetailsStep(
                        formKey: _packageFormKey,
                        packageDescriptionController:
                            _packageDescriptionController,
                        customWidthController: _customWidthController,
                        customHeightController: _customHeightController,
                        customLengthController: _customLengthController,
                        customWeightController: _customWeightController,
                        selectedServiceType: _selectedServiceType,
                        selectedBoxSizeId: _selectedBoxSizeId,
                        boxSizes: _boxSizes,
                        isCustomSize: _isCustomSize,
                        packageList: _packageList,
                        onServiceTypeChanged: (value) {
                          setState(() {
                            _selectedServiceType = value;
                          });
                        },
                        onBoxSizeChanged: (boxSizeId) {
                          setState(() {
                            _selectedBoxSizeId = boxSizeId;
                            // Check if custom size selected (ID 999)
                            if (boxSizeId == 999) {
                              _isCustomSize = true;
                              debugPrint('Custom size selected');
                            } else {
                              final selectedBox = _boxSizes.firstWhere(
                                (box) => box.id == boxSizeId,
                              );
                              _isCustomSize = selectedBox.isCustomSize;
                              debugPrint('Box size changed: ID=$boxSizeId, Description=${selectedBox.description}, IsCustom=${selectedBox.isCustomSize}');
                            }
                          });
                        },
                        onAddPackage: _addPackageToList,
                        onRemovePackage: (index) {
                          setState(() {
                            _packageList.removeAt(index);
                          });
                        },
                      ),
                      ServiceDetailsStep(
                        formKey: _serviceFormKey,
                        selectedAgentId: _selectedAgentId,
                        selectedLocationId: _selectedLocationId,
                        agents: _agents,
                        onAgentChanged: (agentId) {
                          setState(() {
                            _selectedAgentId = agentId;
                            _selectedLocationId =
                                null; // Reset location when agent changes
                          });
                        },
                        onLocationChanged: (locationId) {
                          setState(() {
                            _selectedLocationId = locationId;
                          });
                        },
                      ),
                      BillingStep(
                        formKey: _billingFormKey,
                        selectedPaymentMethod: _selectedPaymentMethod,
                        onPaymentMethodChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        packageList: _packageList,
                        selectedServiceType: _selectedServiceType,
                        calculateTotalAmount: _calculateTotalAmount,
                      ),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: _goToPreviousStep,
              child: const Text('Back'),
            )
          else
            const SizedBox(),

          ElevatedButton(
            onPressed: _currentStep < 4 ? _goToNextStep : _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(_currentStep < 4 ? 'Next' : 'Create Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageForSender() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _senderPassportImage = File(image.path);
      });
    }
  }

  Future<void> _pickImageForReceiver() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _receiverPassportImage = File(image.path);
      });
    }
  }

  // Load passport image from URL (for sender auto-fill)
  Future<void> _loadPassportImageFromUrl(String imageUrl) async {
    try {
      // Note: This is a simplified approach. In a production app, you might want to:
      // 1. Download and cache the image locally
      // 2. Show a placeholder or loading indicator
      // 3. Handle network errors gracefully

      // For now, we'll just show a message that the user has an existing passport photo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Existing passport photo found in profile'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // TODO: Implement actual image download and conversion to File if needed
      // This would require additional dependencies like http and path_provider
    } catch (e) {
      // Handle error silently or show a subtle notification
      debugPrint('Failed to load passport image from URL: $e');
    }
  }

  void _addPackageToList() async {
    if (_packageDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in package description first'),
        ),
      );
      return;
    }

    double packagePrice = 0.0;
    BoxSize? selectedBox;

    // Handle custom size (ID 999)
    if (_selectedBoxSizeId == 999) {
      packagePrice = 0.0; // Will be calculated below
      selectedBox = null; // No box size for custom
    } else {
      selectedBox = _boxSizes.firstWhere(
        (box) => box.id == _selectedBoxSizeId,
      );
      packagePrice = selectedBox.price;
    }

    // For custom sizes, calculate price via API
    if (_isCustomSize) {
      final width = double.tryParse(_customWidthController.text);
      final height = double.tryParse(_customHeightController.text);
      final length = double.tryParse(_customLengthController.text);
      final weight = double.tryParse(_customWeightController.text);

      if (width == null || height == null || length == null || weight == null ||
          width <= 0 || height <= 0 || length <= 0 || weight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid custom dimensions and weight'),
          ),
        );
        return;
      }

      // Validate volume
      final volume = width * height * length;
      if (volume > 0.2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Volume exceeds maximum allowed (0.2 m³). Current: ${volume.toStringAsFixed(3)} m³'),
          ),
        );
        return;
      }

      // Calculate price
      try {
        final response = await OrderService.calculatePrice(
          width: width,
          height: height,
          length: length,
        );

        if (response['success'] == true) {
          packagePrice = double.tryParse(response['price']?.toString() ?? '0') ?? 0.0;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to calculate price: ${response['message'] ?? 'Unknown error'}'),
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating price: ${e.toString()}'),
          ),
        );
        return;
      }
    }

    final package = {
      'description': _packageDescriptionController.text,
      'serviceType': _selectedServiceType,
      'size': _isCustomSize
          ? 'Custom (${_customWidthController.text}×${_customHeightController.text}×${_customLengthController.text}m, ${_customWeightController.text}kg)'
          : selectedBox?.displayText ?? 'Unknown Size',
      'price': packagePrice,
      'boxSizeId': _selectedBoxSizeId,
      'isCustomSize': _isCustomSize,
      'customWidth': _isCustomSize
          ? double.tryParse(_customWidthController.text)
          : null,
      'customHeight': _isCustomSize
          ? double.tryParse(_customHeightController.text)
          : null,
      'customLength': _isCustomSize
          ? double.tryParse(_customLengthController.text)
          : null,
      'customWeight': _isCustomSize
          ? double.tryParse(_customWeightController.text)
          : null,
    };

    setState(() {
      _packageList.add(package);
      _packageDescriptionController.clear();
      if (_isCustomSize) {
        _customWidthController.clear();
        _customHeightController.clear();
        _customLengthController.clear();
        _customWeightController.clear();
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Package added successfully')));
  }

  void _goToNextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _senderFormKey.currentState!.validate();
        if (isValid && _senderPassportImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload passport image')),
          );
          isValid = false;
        }
        break;
      case 1:
        isValid = _receiverFormKey.currentState!.validate();
        if (isValid && _receiverPassportImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload passport image')),
          );
          isValid = false;
        }
        break;
      case 2:
        if (_packageList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one package')),
          );
          isValid = false;
        } else {
          isValid = true;
        }
        break;
      case 3:
        isValid = _serviceFormKey.currentState!.validate();
        break;
      case 4:
        isValid = _billingFormKey.currentState!.validate();
        break;
    }

    if (isValid) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _calculateTotalAmount() {
    double packageTotal = _packageList.fold(0.0, (sum, package) {
      return sum + (package['price'] ?? 0.0);
    });
    double serviceFee = _selectedServiceType == 'Door-to-Door Delivery'
        ? 1000.0
        : 0.0;
    return (packageTotal + serviceFee).toStringAsFixed(2);
  }

  void _submitOrder() async {
    if (_billingFormKey.currentState!.validate()) {
      // Show loading dialog
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
                Text('Creating your order...'),
              ],
            ),
          );
        },
      );

      try {
        // First save the order to get reference
        final orderRequest = OrderRequest(
          senderName: _senderFullNameController.text.trim(),
          senderTel: _senderContactController.text.trim(),
          senderAddress: _senderAddressController.text.trim(),
          senderCity: _senderCityController.text.trim(),
          senderMail: _senderEmailController.text.trim(),
          passportNumber: _senderPassportController.text.trim(),
          senderPassportImage: _senderPassportImage,
          recipientName: _receiverFullNameController.text.trim(),
          recipientName2: null,
          recipientContact: _receiverContactController.text.trim(),
          recipientAddress: _receiverAddressController.text.trim(),
          recipientCity: _receiverCityController.text.trim(),
          recipientPassportNo: _receiverPassportController.text.trim(),
          receiverPassportImage: _receiverPassportImage,
          postalCode: _receiverPostalCodeController.text.trim(),
          serviceType: _selectedServiceType,
          packageDescription: '', // Empty for save action
          boxSizeId: _selectedBoxSizeId,
          isCustomSize: false,
          agentId: _selectedAgentId,
          locationId: _selectedLocationId,
          paymentMethod: _selectedPaymentMethod,
          action: 'create', // create first to get reference
        );

        final orderResponse = await OrderService.createOrder(orderRequest);

        if (!orderResponse.success) {
          // Close loading dialog and show error
          if (mounted) Navigator.of(context).pop();
          if (mounted) {
            _showOrderErrorDialog(orderResponse.userMessage);
          }
          return;
        }

        // Get the reference from the response
        final reference = orderResponse.reference;
        if (reference == null || reference.isEmpty) {
          // Close loading dialog and show error
          if (mounted) Navigator.of(context).pop();
          if (mounted) {
            _showOrderErrorDialog('Failed to get order reference');
          }
          return;
        }

        // Now add packages to the order
        for (int i = 0; i < _packageList.length; i++) {
          final package = _packageList[i];
          try {
            await OrderService.addPackage(
              reference: reference,
              // packageType: package['serviceType'] ?? 'Package',
              packageType: 'package',
              packageDescription: package['description'] ?? '',
              boxSizeId: package['boxSizeId'] ?? 1,
              packagePrice: package['price'] ?? 0.0,
              isCustomSize: package['isCustomSize'] ?? false,
              customWidth: package['customWidth'],
              customHeight: package['customHeight'],
              customLength: package['customLength'],
              customWeight: package['customWeight'],
              customPrice: package['price'],
              extraFee: package['isCustomSize'] == true
                  ? 0.0
                  : null, // Extra fee for custom size
            );
          } catch (e) {
            debugPrint('Failed to add package ${i + 1}: $e');
            // Continue adding other packages even if one fails
          }
        }

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (!mounted) return;

        // Show success dialog
        _showOrderSuccessDialog(orderResponse);
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          _showOrderErrorDialog('Failed to create order: ${e.toString()}');
        }
      }
    }
  }

  void _showOrderSuccessDialog(dynamic response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Order Created Successfully!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                'Your order has been created successfully.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (response.orderId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Order ID: ${response.orderId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              if (response.reference != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Reference: ${response.reference}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Call the callback to navigate back to home page in dashboard
                if (widget.onOrderCreated != null) {
                  widget.onOrderCreated!();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Creation Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
