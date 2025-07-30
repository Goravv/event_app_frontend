import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final avatarText = (user.username.isNotEmpty)
        ? user.username[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                  ? NetworkImage(user.imageUrl!)
                  : null,
              child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                  ? Text(
                      avatarText,
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Username"),
              subtitle: Text(user.username),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text("Plan Type"),
              subtitle: Text(user.planType),
            ),
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text("Bids Left"),
              subtitle: Text(user.bidsLeft.toString()),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
