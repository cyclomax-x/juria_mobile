# Juria Cargo Mobile App - Flutter Learning Journey

## Project Overview
**Project Name:** Juria Cargo Mobile App  
**Technology:** Flutter  
**Type:** Cargo Management System for Customers and Drivers  
**Backend:** CodeIgniter 4 (PHP) with MySQL Database  

## Current Status
- **Project Structure:** Custom Juria Cargo project with proper structure
- **Current Flutter SDK:** 3.9.0
- **Status:** Completed Phase 2 - Advanced UI with Multi-Step Forms ✅
- **Screens Completed:** Splash Screen + Login Screen + Advanced New Order Page
- **Next Phase:** Additional Customer Dashboard Features

## Project Requirements Summary (From SRS)

### Target Users
1. **Customers** - Registration, order management, tracking
2. **Drivers** - Order pickup, package handling, delivery coordination

### Key Features to Implement
#### Customer Module:
- Authentication & Registration (with passport photo upload)
- Dashboard with order statistics
- New order creation (pickup requests)
- Order history and tracking
- Profile management

#### Driver Module:
- Driver authentication
- Pending orders management
- Picked orders management with invoice generation
- Daily reports

### Technical Stack
- **Frontend:** Flutter (Cross-platform)
- **Backend:** Existing CodeIgniter 4 APIs (to be extended)
- **Database:** Existing MySQL database
- **Authentication:** JWT tokens or session-based
- **Communication:** RESTful APIs with JSON

## Learning Plan - Phase by Phase

### Phase 1: Flutter Fundamentals & Project Setup ⏳
**Learning Goals:**
- Understand Flutter basics (Widgets, State Management)
- Set up proper project structure
- Learn Dart language fundamentals
- Understand Material Design principles

**Tasks:**
- [ ] Learn basic Flutter concepts (Widgets, StatelessWidget, StatefulWidget)
- [ ] Understand project structure and file organization
- [ ] Set up development environment properly
- [ ] Create basic app structure with navigation
- [ ] Learn about pubspec.yaml and dependency management

### Phase 2: UI Development & Navigation 📱
**Learning Goals:**
- Master Flutter UI components
- Implement navigation between screens
- Create responsive layouts
- Learn state management basics

**Tasks:**
- [ ] Create authentication screens (Login, Register)
- [ ] Build customer dashboard UI
- [ ] Implement navigation system
- [ ] Learn about forms and validation
- [ ] Understand responsive design in Flutter

### Phase 3: API Integration & Networking 🌐
**Learning Goals:**
- Learn HTTP requests in Flutter
- Handle JSON data parsing
- Implement error handling
- Understand async programming in Dart

**Tasks:**
- [ ] Add HTTP dependency and configure
- [ ] Create API service classes
- [ ] Implement authentication API calls
- [ ] Learn about Future and async/await
- [ ] Handle network errors gracefully

### Phase 4: Advanced Features 🚀
**Learning Goals:**
- File upload/download
- Image handling and camera integration
- Local storage and data persistence
- Push notifications

**Tasks:**
- [ ] Implement image picker for passport photos
- [ ] Add local storage for user data
- [ ] Create order tracking functionality
- [ ] Implement file upload for images

### Phase 5: Testing & Deployment 🧪
**Learning Goals:**
- Unit testing in Flutter
- Integration testing
- App deployment process

**Tasks:**
- [ ] Write unit tests for core functions
- [ ] Test on different devices
- [ ] Prepare for app store deployment
- [ ] Performance optimization

## Development Sessions Log

### Session 1 - [September 2, 2025] ✅ COMPLETED
**What we accomplished:**
- ✅ Analyzed the SRS document and understood project requirements
- ✅ Renamed project from `flutter_application_1` to `juria_cargo`
- ✅ Set up proper assets folder structure (`assets/images/`, `assets/icons/`)
- ✅ Configured pubspec.yaml for assets management
- ✅ Replaced default demo with custom Juria Cargo splash screen
- ✅ Added Juria logo to splash screen
- ✅ Implemented auto-navigation with Timer (3 seconds)
- ✅ Created professional login screen with form validation
- ✅ Implemented navigation between screens

**Flutter Concepts Learned:**
1. **Project Setup & Structure**
   - pubspec.yaml configuration
   - Assets management (images, icons)
   - Project organization best practices

2. **Widget Fundamentals**
   - StatelessWidget vs StatefulWidget
   - Scaffold, SafeArea, Column, Row
   - Image.asset() vs Icon()
   - SizedBox for spacing

3. **Navigation System**
   - Navigator.of(context).pushReplacement()
   - MaterialPageRoute
   - Screen-to-screen navigation

4. **State Management**
   - setState() for UI updates
   - TextEditingController for forms
   - Form validation with GlobalKey<FormState>

5. **UI/UX Design**
   - Material Design 3
   - Theme.of(context).colorScheme
   - Button types: ElevatedButton, OutlinedButton, TextButton
   - Input field styling with contentPadding

6. **Advanced Features**
   - Timer for auto-navigation
   - Password visibility toggle
   - Form validation
   - SnackBar for user feedback

**Screens Built:**
1. **Splash Screen** - Logo, loading indicator, auto-navigation
2. **Login Screen** - Username/password form, validation, primary/secondary buttons

**Key Learnings:**
- Flutter's hot reload makes development incredibly fast
- StatefulWidget is needed for dynamic content (forms, timers)
- Navigation replaces screens in the stack
- Form validation provides excellent UX
- Material Design provides consistent, professional look

---

### Session 2 - [September 10, 2025] ✅ COMPLETED
**What we accomplished:**
- ✅ Built comprehensive multi-step new order form with 5 steps
- ✅ Implemented sender details with full form validation
- ✅ Added receiver details with postal code support
- ✅ Created advanced package details with service types and custom sizing
- ✅ Added service details with agent and location selection
- ✅ Implemented billing section with dynamic price calculation
- ✅ **REFACTORED CODE:** Separated each step into individual components for better maintainability
- ✅ Added image upload functionality for passport photos
- ✅ Implemented package list management (add/remove multiple packages)
- ✅ Built real-time price breakdown with dynamic totals

**Flutter Concepts Learned:**
1. **Advanced Form Management**
   - Multiple GlobalKey<FormState> for different form sections
   - Complex form validation across multiple steps
   - TextEditingController management and disposal
   - Custom form field validation logic

2. **Multi-Step Navigation**
   - PageController for smooth step transitions
   - Progress indicator implementation
   - Step-by-step validation before navigation
   - Back/Next button state management

3. **Image Handling**
   - ImagePicker integration for photo uploads
   - File handling and storage
   - Image display with proper formatting
   - Validation for required image uploads

4. **Dynamic UI Components**
   - Conditional widget rendering (custom size fields)
   - Dynamic dropdown population (agent-location mapping)
   - Real-time price calculation and display
   - List management with add/remove functionality

5. **Code Organization & Architecture**
   - **Component Separation:** Extracted each step into separate files
   - **File Structure:** Created organized folder hierarchy
   - **Reusable Widgets:** Built modular, reusable form components
   - **State Management:** Proper state passing between components
   - **Maintainability:** Clean code structure for easier maintenance

6. **Advanced Widget Usage**
   - DropdownButtonFormField with dynamic options
   - Conditional widget lists with spread operator
   - ListView.builder with dynamic content
   - Card and ListTile for structured displays
   - Container decorations with borders and colors

**New File Structure Created:**
```
lib/screens/customer/pages/new_order/
├── new_order_page.dart (Main controller)
└── steps/
    ├── sender_details_step.dart
    ├── receiver_details_step.dart
    ├── package_details_step.dart
    ├── service_details_step.dart
    └── billing_step.dart
```

**Key Features Implemented:**
- **Multi-step form** with progress tracking
- **Image upload** for passport photos (sender & receiver)
- **Dynamic pricing** with real-time calculation
- **Package management** with add/remove functionality
- **Service selection** with agent-location mapping
- **Custom sizing** with validation limits
- **Payment method** selection
- **Form validation** at each step
- **Responsive design** with proper spacing and styling

**Code Quality Improvements:**
- ✅ **Separation of Concerns:** Each step is now a separate component
- ✅ **Maintainability:** Easier to modify individual steps
- ✅ **Reusability:** Components can be reused in other forms
- ✅ **Testability:** Individual components can be tested separately
- ✅ **Readability:** Main file is cleaner and more focused

**Technical Achievements:**
- Successfully managed complex state across multiple components
- Implemented proper callback patterns for parent-child communication
- Created reusable form validation patterns
- Built dynamic UI that responds to user selections
- Established scalable file organization structure

**Next Session Goals:**
- 🎯 Implement order history and tracking features
- 📊 Build customer dashboard with statistics
- 🔍 Add search and filter functionality
- 📱 Enhance UI with animations and better UX
- 🔄 Implement data persistence with local storage

---

**Dependencies Needed (from SRS):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5 # API calls
  shared_preferences: ^2.0.15 # Local storage  
  provider: ^6.0.3 # State management
  image_picker: ^0.8.6 # Photo capture
  geolocator: ^9.0.2 # Location services
  local_auth: ^2.1.6 # Biometric authentication
  flutter_secure_storage: ^9.0.0 # Secure storage
```

**Questions for Future Research:**
1. How to structure a large Flutter project properly?
2. What's the best state management solution for this scale?
3. How to handle secure authentication in Flutter?
4. Best practices for API integration in Flutter?

## Flutter Learning Resources
- [ ] Flutter official documentation
- [ ] Dart language tour
- [ ] Flutter UI widget catalog
- [ ] State management guides (Provider pattern)
- [ ] HTTP networking in Flutter
- [ ] Flutter security best practices

## Notes for Teacher (Claude)
- Please guide step by step as a beginner
- Explain concepts before implementing
- Show both theory and practical examples  
- Help with debugging when issues arise
- Suggest best practices for enterprise-level apps

---
*This document will be updated after each learning session to track progress and learnings.*