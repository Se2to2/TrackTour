import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/tournament_service.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_wave.dart';
import 'login_screen.dart';
import 'create_tournament_screen.dart';
import 'view_all_tournaments_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  bool _showProfileMenu = false;
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome section with galaxy background
                        _buildWelcomeSection(),
                        const SizedBox(height: 25),

                        // Main action buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildMainActions(),
                              const SizedBox(height: 25),

                              // Active Tournaments section
                              _buildActiveTournamentsSection(),
                              const SizedBox(height: 25),

                              // Stats section
                              _buildStatsSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom wave - using reusable component
          const BottomWave(),

          // Profile dropdown menu overlay
          if (_showProfileMenu) _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.purpleDark.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Image.asset('assets/Loge.png', width: 32, height: 32),
          const SizedBox(width: 10),
          const Text(
            'TRACKTOUR',
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const Spacer(),

          // Notification bell with badge
          FutureBuilder<int>(
            future: TournamentService().getUnreadNotificationCount(authService.currentUser!.uid),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data ?? 0;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textColor),
                    onPressed: () {
                      // TODO: Navigate to notifications screen
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(width: 5),

          // Profile picture
          GestureDetector(
            onTap: () {
              setState(() {
                _showProfileMenu = !_showProfileMenu;
              });
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.purpleMain,
              child: const Icon(Icons.person, color: AppColors.textColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/galaxy.png'),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<String>(
            future: authService.currentUser != null 
                ? authService.getUserName(authService.currentUser!.uid)
                : Future.value('USER'),
            builder: (context, snapshot) {
              String displayName = 'USER';
              if (snapshot.hasData && snapshot.data != null) {
                displayName = snapshot.data!;
              }
              return RichText(
                text: TextSpan(
                  text: 'Welcome Back, ',
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(
                      text: displayName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Create and Manage your gaming tournament easily.',
            style: TextStyle(
              color: AppColors.subTextColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.emoji_events_outlined,
            label: 'Create Tournament',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionCard(
            icon: Icons.calendar_month_outlined,
            label: 'View Calendar',
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'Create Tournament') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTournamentScreen(userRole: widget.role),
            ),
          );
        } else {
          // TODO: Add navigation for View Calendar
        }
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/galaxy.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.purpleMain.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTournamentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Tournaments',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewAllTournamentsScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.subTextColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.tune, color: AppColors.subTextColor, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Stream tournaments from Firestore
        StreamBuilder<QuerySnapshot>(
          stream: TournamentService().getTournamentsByStatus('ongoing'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.purpleMain),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.cardColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy, color: AppColors.subTextColor, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        'No active tournaments',
                        style: TextStyle(
                          color: AppColors.subTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Get first 4 tournaments for home screen
            var tournaments = snapshot.data!.docs.take(4).toList();

            // Display in 2x2 grid
            return Column(
              children: [
                Row(
                  children: [
                    if (tournaments.isNotEmpty)
                      Expanded(
                        child: _buildTournamentCardFromData(tournaments[0]),
                      ),
                    if (tournaments.length > 1) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTournamentCardFromData(tournaments[1]),
                      ),
                    ],
                  ],
                ),
                if (tournaments.length > 2) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTournamentCardFromData(tournaments[2]),
                      ),
                      if (tournaments.length > 3) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTournamentCardFromData(tournaments[3]),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTournamentCardFromData(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    
    return _buildTournamentCard(
      tournamentId: doc.id,
      game: data['name'] ?? 'Tournament',
      status: data['status'] ?? 'Ongoing',
      players: data['registeredPlayers'] ?? 0,
      date: _formatDate(data['startDate']),
      time: _formatTime(data['startDate']),
      venue: data['venue'] ?? data['server'] ?? 'TBA',
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'TBA';
    DateTime date = (timestamp as Timestamp).toDate();
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'TBA';
    DateTime date = (timestamp as Timestamp).toDate();
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    String period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildTournamentCard({
    required String tournamentId,
    required String game,
    required String status,
    required int players,
    required String date,
    required String time,
    required String venue,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to tournament details screen with tournamentId
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tournament ID: $tournamentId')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purpleDark.withOpacity(0.6), AppColors.purpleMain.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.videogame_asset, color: Colors.orange, size: 16),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    game,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Status: $status',
              style: const TextStyle(color: AppColors.subTextColor, fontSize: 11),
            ),
            Text(
              'Players: $players',
              style: const TextStyle(color: AppColors.subTextColor, fontSize: 11),
            ),
            Text(
              date,
              style: const TextStyle(color: AppColors.subTextColor, fontSize: 11),
            ),
            Text(
              time,
              style: const TextStyle(color: AppColors.subTextColor, fontSize: 11),
            ),
            Text(
              'Venue: $venue',
              style: const TextStyle(color: AppColors.subTextColor, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purpleMain,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(color: AppColors.textColor, fontSize: 11),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward, color: AppColors.textColor, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: TournamentService().getTournamentsByStatus('approved'),
      builder: (context, snapshot) {
        int totalTournaments = 0;
        int totalPlayers = 0;

        if (snapshot.hasData) {
          totalTournaments = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            totalPlayers += (data['registeredPlayers'] as int?) ?? 0;
          }
        }

        return Row(
          children: [
            Expanded(child: _buildStatCard('$totalTournaments', 'Tournaments')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('$totalPlayers', 'Players')),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/galaxy.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.purpleMain.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: AppColors.purpleMain,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subTextColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showProfileMenu = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Stack(
          children: [
            Positioned(
              top: 70,
              right: 15,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.purpleMain.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        onTap: () {
                          setState(() => _showProfileMenu = false);
                          // TODO: Navigate to profile
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {
                          setState(() => _showProfileMenu = false);
                          // TODO: Navigate to notifications
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {
                          setState(() => _showProfileMenu = false);
                          // TODO: Navigate to settings
                        },
                      ),
                      Divider(
                        color: AppColors.purpleMain.withOpacity(0.3),
                        height: 1,
                      ),
                      _buildMenuItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        onTap: () async {
                          if (_isLoggingOut) return;
                          
                          setState(() {
                            _showProfileMenu = false;
                            _isLoggingOut = true;
                          });
                          
                          await authService.logout();
                          await Future.delayed(const Duration(milliseconds: 500));
                          
                          if (!mounted) return;
                          
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}