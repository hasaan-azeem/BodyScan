import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitlyzer/screens/meal/meal_suggestion_screen.dart';
import 'package:fitlyzer/screens/profile/profile_screen.dart';
import 'package:fitlyzer/screens/upload/report_screen.dart';
import 'package:fitlyzer/screens/upload/upload_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const ReportScreen(reportHistory: [], history: []),
    const UploadScreen(),
    const SettingsTab(),
  ];

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: switchTab,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload_outlined),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ————————————————————— Home Tab —————————————————————

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  User? user;
  String welcomeText = "Welcome";

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _setWelcomeText();
  }

  void _setWelcomeText() {
    if (user != null) {
      final metadata = user!.metadata;
      final isNewUser =
          metadata.creationTime?.difference(metadata.lastSignInTime!) ==
          Duration.zero;
      setState(() {
        welcomeText = isNewUser ? "Welcome" : "Welcome Back!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();

    if (user == null) {
      return const Center(child: Text('Please log in to continue'));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                String userName = "Fitness Warrior 💪";
                if (snapshot.hasData && snapshot.data!.exists) {
                  userName =
                      (snapshot.data!.data() as Map<String, dynamic>)['name'] ??
                      user!.displayName ??
                      "Fitness Warrior 💪";
                } else {
                  userName = user!.displayName ?? "Fitness Warrior 💪";
                }

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: AssetImage('assets/user_avatar.png'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$welcomeText 👋",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "“Every progress starts with a first step.”",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureCard(
                  icon: Icons.image_outlined,
                  title: "Upload Image",
                  onTap: () => homeState?.switchTab(2),
                ),
                _buildFeatureCard(
                  icon: Icons.analytics_outlined,
                  title: "Strength Report",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const ReportScreen(
                              reportHistory: [],
                              history: [],
                            ),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.fastfood_outlined,
                  title: "Meal Suggestion",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealSuggestionsScreen(),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () => homeState?.switchTab(3),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.health_and_safety, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "💧 Drink at least 8 glasses of water a day to stay hydrated and energized!",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
