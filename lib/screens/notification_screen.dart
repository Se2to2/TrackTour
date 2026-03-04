import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tournament_service.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TournamentService _tournamentService = TournamentService();
  final AuthService _authService = AuthService();

  // Theme colors
  static const Color bgColor = Color(0xFF000000);
  static const Color purpleMain = Color(0xFF8B7CD6);
  static const Color purpleDark = Color(0xFF3D2C5C);
  static const Color cardColor = Color(0xFF1A0F2E);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Color(0xFF9B9B9B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(color: purpleMain),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tournamentService.getUserNotifications(_authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: purpleMain),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: subTextColor,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notif = snapshot.data!.docs[index];
              return _buildNotificationCard(
                notif.id,
                notif.data() as Map<String, dynamic>,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(String notifId, Map<String, dynamic> data) {
    bool isRead = data['read'] ?? false;
    String type = data['type'] ?? '';
    
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'match_starting':
        icon = Icons.access_time;
        iconColor = Colors.orange;
        break;
      case 'check_in_reminder':
        icon = Icons.fact_check_outlined;
        iconColor = Colors.blue;
        break;
      case 'match_completed':
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case 'result_disputed':
        icon = Icons.warning_amber_outlined;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        iconColor = purpleMain;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _tournamentService.markNotificationAsRead(
            _authService.currentUser!.uid,
            notifId,
          );
        }
        // TODO: Navigate to relevant screen
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? cardColor.withOpacity(0.3) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.transparent : purpleMain.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Notification',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['message'] ?? '',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTimestamp(data['createdAt']),
                    style: TextStyle(
                      color: subTextColor.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: purpleMain,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _markAllAsRead() {
    // TODO: Implement mark all as read
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        backgroundColor: purpleMain,
      ),
    );
  }
}