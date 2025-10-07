import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ReceiverDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController contactController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final TextEditingController passportController;
  final TextEditingController postalCodeController;
  final File? passportImage;
  final Function(File?) onImageSelected;

  const ReceiverDetailsStep({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.contactController,
    required this.cityController,
    required this.addressController,
    required this.emailController,
    required this.passportController,
    required this.postalCodeController,
    required this.passportImage,
    required this.onImageSelected,
  });

  @override
  State<ReceiverDetailsStep> createState() => _ReceiverDetailsStepState();
}

class _ReceiverDetailsStepState extends State<ReceiverDetailsStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Receiver Information'),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.passportController,
              decoration: const InputDecoration(
                labelText: 'Passport No.',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passport number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code',
                prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter postal code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildImageUploadSection(
              'Passport Image (Optional)',
              widget.passportImage,
              widget.onImageSelected,
            ),
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

  Widget _buildImageUploadSection(
    String title,
    File? image,
    Function(File?) onImageSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text:
                'We suggest you to submit a passport photo to verify receiver identity at custom clearance of your packages. We do not share your/receiver information with third parties and will be kept confidential. See our ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final url = Uri.parse(
                      'https://cargo.juriacargo.com/data/privacy-policy',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
              ),
              const TextSpan(text: ' for more details.'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => onImageSelected(null), // This will be handled by parent
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload $title',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
