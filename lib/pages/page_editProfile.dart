import 'package:flutter/material.dart';
import '../models/user.dart';

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
  String? _profileImage;

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
    _profileImage = user?.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _changeProfileImage() async {
    // Simple editable image: prompt for a URL or local path via dialog.
    final controller = TextEditingController(text: _profileImage ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change profile picture'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter image URL or asset path'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('OK')),
        ],
      ),
    );

    if (result != null) {
      setState(() => _profileImage = result.isEmpty ? null : result);
    }
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repo = UserRepository.instance;
    final user = repo.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user is logged in')));
      return;
    }

    user.fullName = _nameController.text.trim();
    user.email = _emailController.text.trim();
    user.phoneNumber = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    user.gender = _gender;
    user.location = _location;
    user.profileImage = _profileImage;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = const AssetImage('images/homesense-logo.png');
    final imageProvider = (_profileImage != null && _profileImage!.isNotEmpty)
        ? (NetworkImage(_profileImage!) as ImageProvider)
        : placeholder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1EAA83),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage: imageProvider,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: _changeProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.edit, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Full name
            const Text('Full name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(hintText: UserRepository.instance.currentUser?.fullName ?? 'Enter full name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),

            // Email
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: UserRepository.instance.currentUser?.email ?? 'Enter email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phone
            const Text('Phone number', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(hintText: UserRepository.instance.currentUser?.phoneNumber ?? 'Enter phone number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            // Gender
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _genderOptions.contains(_gender) ? _gender : null,
              items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _gender = v),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
            ),
            const SizedBox(height: 12),

            // Location
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _locationOptions.contains(_location) ? _location : null,
              items: _locationOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _location = v),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1EAA83), minimumSize: const Size(double.infinity, 52)),
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}
