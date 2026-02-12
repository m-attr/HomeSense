import 'package:flutter/material.dart';
import '../models/user.dart';

typedef VoidCallbackNullable = void Function()?;

class WidgetMenuDrawer extends StatelessWidget {
  final VoidCallbackNullable onHome;
  final VoidCallbackNullable onProfile;
  final VoidCallbackNullable onAbout;
  final VoidCallbackNullable onInsights;
  final VoidCallbackNullable onNotifications;
  final VoidCallbackNullable onSettings;
  final VoidCallbackNullable onLogout;
  final VoidCallbackNullable onChangeProfileImage;

  const WidgetMenuDrawer({
    Key? key,
    this.onHome,
    this.onProfile,
    this.onAbout,
    this.onInsights,
    this.onNotifications,
    this.onSettings,
    this.onLogout,
    this.onChangeProfileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repo = UserRepository.instance;
    final user = repo.currentUser;
    final placeholder = const AssetImage('images/homesense-logo.png');
    final imageProvider = (user?.profileImage != null && user!.profileImage!.isNotEmpty)
        ? (user.profileImage!.startsWith('http') ? NetworkImage(user.profileImage!) : AssetImage(user.profileImage!)) as ImageProvider
        : placeholder;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 220,
            color: const Color(0xFF1EAA83),
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 34,
                            backgroundImage: imageProvider,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: onChangeProfileImage,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.edit, size: 18, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Guest',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              if (onHome != null) onHome!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('MyProfile'),
            onTap: () {
              Navigator.pop(context);
              if (onProfile != null) onProfile!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              if (onAbout != null) onAbout!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Insights'),
            onTap: () {
              Navigator.pop(context);
              if (onInsights != null) onInsights!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              if (onNotifications != null) onNotifications!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              if (onSettings != null) onSettings!();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              if (onLogout != null) onLogout!();
            },
          ),
        ],
      ),
    );
  }
}
