import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/user_service.dart';
import '../../splash_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _darkMode = false;
  bool _biometricAuth = false;
  String _language = 'English';
  String _currency = 'JPY (¥)';
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0+1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive order updates and alerts'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications_outlined),
                  ),
                  if (_notificationsEnabled) ...[
                    // const Divider(height: 1),
                    // SwitchListTile(
                    //   title: const Text('Email Notifications'),
                    //   subtitle: const Text('Get updates via email'),
                    //   value: _emailNotifications,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _emailNotifications = value;
                    //     });
                    //   },
                    //   secondary: const Icon(Icons.email_outlined),
                    // ),
                    // const Divider(height: 1),
                    // SwitchListTile(
                    //   title: const Text('SMS Notifications'),
                    //   subtitle: const Text('Get updates via SMS'),
                    //   value: _smsNotifications,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _smsNotifications = value;
                    //     });
                    //   },
                    //   secondary: const Icon(Icons.sms_outlined),
                    // ),
                    // const Divider(height: 1),
                    // SwitchListTile(
                    //   title: const Text('Push Notifications'),
                    //   subtitle: const Text('Get updates on your device'),
                    //   value: _pushNotifications,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _pushNotifications = value;
                    //     });
                    //   },
                    //   secondary: const Icon(Icons.phone_android_outlined),
                    // ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            // _buildSectionHeader('Appearance'),
            // const SizedBox(height: 16),

            // Card(
            //   child: Column(
            //     children: [
            //       SwitchListTile(
            //         title: const Text('Dark Mode'),
            //         subtitle: const Text('Use dark theme'),
            //         value: _darkMode,
            //         onChanged: (value) {
            //           setState(() {
            //             _darkMode = value;
            //           });
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Dark mode feature coming soon!')),
            //           );
            //         },
            //         secondary: const Icon(Icons.dark_mode_outlined),
            //       ),
            //       const Divider(height: 1),
            //       ListTile(
            //         title: const Text('Language'),
            //         subtitle: Text(_language),
            //         leading: const Icon(Icons.language_outlined),
            //         trailing: const Icon(Icons.chevron_right),
            //         onTap: () => _showLanguageDialog(),
            //       ),
            //       const Divider(height: 1),
            //       ListTile(
            //         title: const Text('Currency'),
            //         subtitle: Text(_currency),
            //         leading: const Icon(Icons.monetization_on_outlined),
            //         trailing: const Icon(Icons.chevron_right),
            //         onTap: () => _showCurrencyDialog(),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader('Security'),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  // SwitchListTile(
                  //   title: const Text('Biometric Authentication'),
                  //   subtitle: const Text('Use fingerprint or face ID'),
                  //   value: _biometricAuth,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _biometricAuth = value;
                  //     });
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Biometric auth feature coming soon!')),
                  //     );
                  //   },
                  //   secondary: const Icon(Icons.fingerprint_outlined),
                  // ),
                  // const Divider(height: 1),
                  ListTile(
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    leading: const Icon(Icons.lock_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  // const Divider(height: 1),
                  // ListTile(
                  //   title: const Text('Two-Factor Authentication'),
                  //   subtitle: const Text('Add extra security to your account'),
                  //   leading: const Icon(Icons.security_outlined),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('2FA feature coming soon!')),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data & Privacy Section
            _buildSectionHeader('Data & Privacy'),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Privacy Policy'),
                    subtitle: const Text('Read our privacy policy'),
                    leading: const Icon(Icons.privacy_tip_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://cargo.juriacargo.com/data/privacy-policy',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not open privacy policy. Please try again later.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Terms of Service'),
                    subtitle: const Text('Read our terms of service'),
                    leading: const Icon(Icons.description_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://cargo.juriacargo.com/data/terms-of-service',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not open privacy policy. Please try again later.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  // const Divider(height: 1),
                  // ListTile(
                  //   title: const Text('Data Export'),
                  //   subtitle: const Text('Download your data'),
                  //   leading: const Icon(Icons.download_outlined),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Data export feature coming soon!')),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: Text(_appVersion),
                    leading: const Icon(Icons.info_outline),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Contact Support'),
                    subtitle: const Text('Get help with your account'),
                    leading: const Icon(Icons.support_agent_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening support chat...'),
                        ),
                      );
                    },
                  ),
                  // const Divider(height: 1),
                  // ListTile(
                  //   title: const Text('Rate App'),
                  //   subtitle: const Text('Rate us on the app store'),
                  //   leading: const Icon(Icons.star_outline),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Opening app store...')),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionHeader('Danger Zone', color: Colors.red),
            const SizedBox(height: 16),

            Card(
              color: Colors.red.shade50,
              child: ListTile(
                title: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Permanently delete your account and data',
                  style: TextStyle(color: Colors.red.shade600),
                ),
                leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade700),
                trailing: Icon(Icons.chevron_right, color: Colors.red.shade700),
                onTap: () => _showDeleteAccountDialog(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _language,
                onChanged: (value) {
                  setState(() {
                    _language = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('Japanese (日本語)'),
                value: 'Japanese',
                groupValue: _language,
                onChanged: (value) {
                  setState(() {
                    _language = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('Sinhala (සිංහල)'),
                value: 'Sinhala',
                groupValue: _language,
                onChanged: (value) {
                  setState(() {
                    _language = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Japanese Yen (¥)'),
                value: 'JPY (¥)',
                groupValue: _currency,
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('Sri Lankan Rupee (Rs)'),
                value: 'LKR (Rs)',
                groupValue: _currency,
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('US Dollar (\$)'),
                value: 'USD (\$)',
                groupValue: _currency,
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
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
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
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

                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
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
                                backgroundColor: result['success']
                                    ? Colors.green
                                    : Colors.red,
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Directly call delete - single confirmation only
                _performDeleteAccount();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  // COMMENTED OUT: Double confirmation with typing "DELETE"
  // Uncomment this later when testing is done
  // void _confirmDeleteAccount() async {
  //   final confirmController = TextEditingController();
  //   bool isDisposed = false;

  //   void safeDispose() {
  //     if (!isDisposed) {
  //       isDisposed = true;
  //       confirmController.dispose();
  //     }
  //   }

  //   final result = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           final isConfirmValid = confirmController.text.trim().toUpperCase() == 'DELETE';

  //           return AlertDialog(
  //             title: const Text('Final Confirmation'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 const Text(
  //                   'This is your last chance to cancel. Type "DELETE" to confirm account deletion.',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 TextField(
  //                   controller: confirmController,
  //                   decoration: const InputDecoration(
  //                     labelText: 'Type DELETE to confirm',
  //                     border: OutlineInputBorder(),
  //                   ),
  //                   onChanged: (value) {
  //                     setState(() {});
  //                   },
  //                 ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(dialogContext).pop(false);
  //                 },
  //                 child: const Text('Cancel'),
  //               ),
  //               ElevatedButton(
  //                 onPressed: isConfirmValid
  //                     ? () {
  //                         Navigator.of(dialogContext).pop(true);
  //                       }
  //                     : null,
  //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //                 child: const Text('Confirm Delete'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );

  //   // Dispose controller after dialog closes
  //   safeDispose();

  //   // Proceed with deletion if confirmed
  //   if (result == true) {
  //     _performDeleteAccount();
  //   }
  // }

  Future<void> _performDeleteAccount() async {
    debugPrint('Starting account deletion process...');
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
              Text('Deleting your account...'),
            ],
          ),
        );
      },
    );

    try {
      debugPrint('Calling UserService.deleteAccount()...');
      final result = await UserService.deleteAccount();
      debugPrint('Delete account API response received: $result');

      if (!mounted) {
        debugPrint('Widget not mounted, returning...');
        return;
      }

      // Close loading dialog
      debugPrint('Closing loading dialog...');
      Navigator.of(context).pop();

      if (result['success']) {
        debugPrint('Account deleted successfully, navigating to login...');

        // Clear user session data
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
          debugPrint('Session data cleared successfully');
        } catch (e) {
          debugPrint('Error clearing session data: $e');
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate back to login screen and clear all previous routes
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
        }
      } else {
        debugPrint('Account deletion failed: ${result['message']}');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during account deletion: $e');
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
