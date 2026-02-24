import 'dart:async';
import 'package:flutter/material.dart';
import '../helpers/nav_helper.dart';
import '../models/user.dart';
import 'page_dashboard.dart' show DashboardPage;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _gender;
  String? _location;
  

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> _locationOptions = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    final user = UserRepository.instance.currentUser;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _gender = user?.gender;
    _location = user?.location;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repo = UserRepository.instance;
    final user = repo.currentUser;
    if (user == null) {
      // dispaly message no user logged in 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user is logged in')));
      return;
    }

    user.fullName = _nameController.text.trim();
    user.email = _emailController.text.trim();
    user.phoneNumber = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    user.gender = _gender;
    user.location = _location;

    // show transient overlay popup confirming changes saved
    _showSavedPopup();
  }

  OverlayEntry? _savedOverlay;

  void _showSavedPopup() {
    // remove existing if present
    _savedOverlay?.remove();

    _savedOverlay = OverlayEntry(builder: (context) {
      final top = MediaQuery.of(context).padding.top + 80.0;
      return Positioned(
        top: top,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1EAA83)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF1EAA83)),
                SizedBox(width: 8),
                Expanded(child: Text('Changes saved', style: TextStyle(color: Color(0xFF1EAA83), fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      );
    });

    final overlay = Overlay.of(context);
    if (_savedOverlay != null) {
      overlay.insert(_savedOverlay!);
      Timer(const Duration(seconds: 3), () {
        _savedOverlay?.remove();
        _savedOverlay = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    const Color dark = Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Green app bar with rounded bottom corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: Container(
                width: double.infinity,
                color: green,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 4,
                  right: 8,
                  bottom: 12,
                ),
                child: SizedBox(
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => navigateWithLoading(
                                context,
                                destination: const DashboardPage(),
                                replace: true,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 6.0),
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Center(
                        child: Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Form container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person_outline, color: green, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: dark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Full name
                        Text('Full name', style: TextStyle(fontWeight: FontWeight.w600, color: dark, fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: UserRepository.instance.currentUser?.fullName ?? 'Enter full name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: dark, fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: UserRepository.instance.currentUser?.email ?? 'Enter email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter an email';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        Text('Phone number', style: TextStyle(fontWeight: FontWeight.w600, color: dark, fontSize: 14)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: UserRepository.instance.currentUser?.phoneNumber ?? 'Enter phone number',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
                            final pattern = RegExp(r'^[89][0-9]{7}$');
                            if (!pattern.hasMatch(cleaned)) return 'Phone must be 8 digits and start with 8 or 9';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Gender
                        Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, color: dark, fontSize: 14)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _genderOptions.contains(_gender) ? _gender : null,
                          items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _gender = v),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        Text('Location', style: TextStyle(fontWeight: FontWeight.w600, color: dark, fontSize: 14)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _locationOptions.contains(_location) ? _location : null,
                          items: _locationOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                          onChanged: (v) => setState(() => _location = v),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
