import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/category.dart';
import '../models/user.dart';
import 'category_detail_screen.dart';
import 'notification_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'venue_search_screen.dart';
import 'travel_screen.dart';
import 'retail_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser? userFromLogin;

  const HomeScreen({super.key, this.userFromLogin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  AppUser? _user;

  AppUser get currentUser =>
      _user ??
      AppUser(
        username: "Guest User",
        email: "",
        password: "",
        planType: "Free Plan",
        bidsLeft: 0,
        imageUrl: null,
      );

  @override
  void initState() {
    super.initState();
    _user = widget.userFromLogin;
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([fetchUser(), fetchCategories()]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchUser() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:5000/api/user'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _user ??= AppUser.fromJson(jsonData);
      } else {
        debugPrint("User API error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('User fetch error: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:5000/api/categories'),
      );
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        final categories = jsonData
            .map((item) => Category.fromJson(item))
            .toList();
        _categories.clear();
        _categories.addAll(categories);
        _filteredCategories = categories;
      } else {
        debugPrint("Categories API error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Category fetch error: $e');
    }
  }

  void filterCategories(String query) {
    final searchLower = query.toLowerCase();
    final filtered = _categories.where((cat) {
      return cat.name.toLowerCase().contains(searchLower) ||
          cat.description.toLowerCase().contains(searchLower);
    }).toList();

    setState(() {
      _filteredCategories = filtered;
    });
  }
  
  Widget buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        final name = category.name.toLowerCase();
        if (name.contains("banquet") || name.contains("venue")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VenueSearchScreen()),
          );
        } else if (name.contains("travel") || name.contains("stay")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TravelScreen()),
          );
        } else if (name.contains("retail")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RetailScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryDetailScreen(category: category),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                category.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
    Widget buildTopSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar, user info, notification
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (_user == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        user: currentUser,
                        onLogout: () {
                          setState(() {
                            _user = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  currentUser.imageUrl != null &&
                          currentUser.imageUrl!.isNotEmpty
                      ? CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(currentUser.imageUrl!),
                        )
                      : CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal,
                          child: Text(
                            currentUser.username.isNotEmpty
                                ? currentUser.username[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_user != null)
                        Text(
                          currentUser.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Plan Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentUser.planType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Bids left: ${currentUser.bidsLeft}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "You have ${currentUser.bidsLeft} bids left. Upgrade now to get more bids.",
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Search bar
        TextField(
          controller: _searchController,
          onChanged: filterCategories,
          decoration: InputDecoration(
            hintText: "Search categories...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        const Text(
          "Categories",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTopSection(),
                    ..._filteredCategories.map(buildCategoryCard),
                  ],
                ),
              ),
      ),
    );
  }
}
