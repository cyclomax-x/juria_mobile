// ==========================================
// 1. IMPORTS SECTION
// ==========================================
// Import Flutter's core material design library
import 'package:flutter/material.dart';
// Import other screens for navigation
import 'registration_screen.dart';

// ==========================================
// 2. WIDGET DECLARATION
// ==========================================
// StatefulWidget = Dynamic UI that can change
// StatelessWidget = Static UI that never changes
class LoginScreen extends StatefulWidget {
  // const constructor for performance optimization
  const LoginScreen({super.key});

  // This creates the State object
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ==========================================
// 3. STATE CLASS (Where the magic happens!)
// ==========================================
class _LoginScreenState extends State<LoginScreen> {
  // ==========================================
  // 3A. STATE VARIABLES & CONTROLLERS
  // ==========================================
  
  // Form validation key
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers to get input values
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // State variable that can trigger UI rebuild
  bool _isPasswordVisible = false;

  // ==========================================
  // 3B. LIFECYCLE METHODS
  // ==========================================
  
  // Called when widget is removed from tree
  @override
  void dispose() {
    // IMPORTANT: Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // initState() - Called once when widget is created (not used here)
  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize things here
  // }

  // ==========================================
  // 3C. HELPER METHODS (Business Logic)
  // ==========================================
  
  void _handleLogin() {
    // Validate form using the form key
    if (_formKey.currentState!.validate()) {
      // Get values from controllers
      String username = _emailController.text;
      String password = _passwordController.text;
      
      // TODO: Implement actual login logic here
      print('Logging in with: $username');
      
      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login functionality coming soon!'),
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    // setState() triggers UI rebuild with new value
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _navigateToRegistration() {
    // Navigation using Navigator
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegistrationScreen(),
      ),
    );
  }

  // ==========================================
  // 3D. BUILD METHOD (UI Construction)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Scaffold provides basic app structure
    return Scaffold(
      // ==========================================
      // BODY SECTION
      // ==========================================
      body: SafeArea(  // Avoids system UI overlaps
        child: Padding(
          padding: const EdgeInsets.all(24.0),  // Spacing around content
          child: Center(
            child: SingleChildScrollView(  // Makes content scrollable
              child: Form(
                key: _formKey,  // Links form for validation
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ==========================================
                    // LOGO WIDGET
                    // ==========================================
                    Image.asset(
                      'assets/images/juria_logo.png',
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),  // Spacing widget
                    
                    // ==========================================
                    // TEXT STYLING EXAMPLES
                    // ==========================================
                    Text(
                      'Welcome Back!',
                      // Method 1: Use theme's predefined styles
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      'Sign in to your account',
                      // Method 2: Custom TextStyle
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      // OR use theme colors for consistency
                      // style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      //   color: Theme.of(context).colorScheme.onSurfaceVariant,
                      // ),
                    ),
                    const SizedBox(height: 32),
                    
                    // ==========================================
                    // FORM FIELDS
                    // ==========================================
                    TextFormField(
                      controller: _emailController,  // Links to controller
                      keyboardType: TextInputType.emailAddress,  // Shows email keyboard
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 12
                        ),
                      ),
                      // Validation function
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;  // null means valid
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // ==========================================
                    // PASSWORD FIELD WITH VISIBILITY TOGGLE
                    // ==========================================
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,  // Hides/shows text
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        // Suffix icon with interaction
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 12
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // ==========================================
                    // BUTTON STYLING EXAMPLES
                    // ==========================================
                    
                    // Primary Button (ElevatedButton)
                    SizedBox(
                      width: double.infinity,  // Full width
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          // Custom colors
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          // Custom shape
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // Custom padding
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Secondary Button (OutlinedButton)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _navigateToRegistration,
                        style: OutlinedButton.styleFrom(
                          // Border color
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Create New Account',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Text Button (minimal style)
                    TextButton(
                      onPressed: () {
                        // Inline function example
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Forgot password feature coming soon!'),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// KEY CONCEPTS SUMMARY:
// ==========================================
// 
// 1. STATE MANAGEMENT:
//    - setState() - Triggers UI rebuild
//    - Controllers - Manage text input
//    - Variables - Store UI state
//
// 2. WIDGET TREE:
//    - Everything is a widget
//    - Widgets are nested (parent-child)
//    - Build method creates widget tree
//
// 3. STYLING APPROACHES:
//    - Theme.of(context) - Use app theme
//    - Direct properties - Custom styles
//    - styleFrom() - Button styling
//
// 4. LAYOUT WIDGETS:
//    - Column/Row - Vertical/Horizontal layout
//    - SizedBox - Fixed spacing
//    - Padding - Space around widgets
//    - Center - Center alignment
//    - Expanded/Flexible - Responsive sizing
//
// 5. USER INTERACTION:
//    - onPressed - Button clicks
//    - onChanged - Input changes
//    - validator - Form validation
//    - Navigator - Screen navigation
//
// 6. BEST PRACTICES:
//    - Use const where possible (performance)
//    - Dispose controllers (memory management)
//    - Extract widgets/methods (clean code)
//    - Use theme colors (consistency)
//    - Handle null safety (? and !)