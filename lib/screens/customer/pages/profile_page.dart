import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/user_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/registration_response.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneJpController = TextEditingController();
  final _phoneSlController = TextEditingController();
  final _addressJpController = TextEditingController();
  final _addressSlController = TextEditingController();
  final _passportNumberController = TextEditingController();
  
  File? _profileImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneJpController.dispose();
    _phoneSlController.dispose();
    _addressJpController.dispose();
    _addressSlController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    try {
      final userData = await AuthService.getCurrentUser();

      if (userData != null) {
        debugPrint('User data found - profile edit: ${userData.slMobile}');
        setState(() {
          // Map UserData fields to form controllers
          _fullNameController.text = userData.fullname ?? '';
          _emailController.text = userData.email ?? '';
          _phoneJpController.text = userData.jpnMobile ?? '';
          _phoneSlController.text = userData.slMobile ?? '';
          _addressJpController.text = userData.jpnAddress ?? '';
          _addressSlController.text = userData.slAddress ?? '';
          _passportNumberController.text = userData.passport ?? '';
        });
      } else {
        // Fallback to default values if no user data available
        _setDefaultValues();
        debugPrint('No user data found in storage, using defaults');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Fallback to default values on error
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    _fullNameController.text = '';
    _emailController.text = '';
    _phoneJpController.text = '';
    _phoneSlController.text = '';
    _addressJpController.text = '';
    _addressSlController.text = '';
    _passportNumberController.text = '';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Save changes
                  _saveProfile();
                }
              });
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture Section
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _fullNameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passportNumberController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Passport Number',
                  prefixIcon: Icon(Icons.assignment_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your passport number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneJpController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (Japan)',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Japan phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneSlController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (Sri Lanka)',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Sri Lanka phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Address Information Section
              _buildSectionHeader('Address Information'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressJpController,
                enabled: _isEditing,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address (Japan)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Japan address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressSlController,
                enabled: _isEditing,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address (Sri Lanka)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Sri Lanka address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons Section
              if (!_isEditing) ...[
                _buildActionButton(
                  'Change Password',
                  Icons.lock_outline,
                  () => _showChangePasswordDialog(),
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  'Logout',
                  Icons.exit_to_app,
                  () => _showLogoutDialog(),
                  color: Colors.red,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }


  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(title, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: color ?? Theme.of(context).colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
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
                Text('Updating profile...'),
              ],
            ),
          );
        },
      );

      try {
        final result = await UserService.updateCustomerProfile(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneJp: _phoneJpController.text,
          phonesl: _phoneSlController.text,
          addressJp: _addressJpController.text,
          addressSl: _addressSlController.text,
          passportNumber: _passportNumberController.text,
          profileImage: _profileImage,
          fromApi: true,
        );

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show result message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: result['success'] ? Colors.green : Colors.red,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (currentPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('New passwords do not match'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      final result = await UserService.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: result['success'] ? Colors.green : Colors.red,
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}