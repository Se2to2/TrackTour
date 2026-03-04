import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============ FEATURE 1: Match Scheduling & Notifications ============

  // Schedule a match
  Future<void> scheduleMatch({
    required String tournamentId,
    required String matchId,
    required DateTime scheduledTime,
  }) async {
    await _firestore.collection('tournaments').doc(tournamentId).update({
      'bracket.rounds': FieldValue.arrayUnion([
        // Update specific match scheduledTime
      ])
    });

    // Schedule notifications for 30 mins, 15 mins, and at start time
    await _scheduleMatchNotifications(tournamentId, matchId, scheduledTime);
  }

  Future<void> _scheduleMatchNotifications(
    String tournamentId,
    String matchId,
    DateTime matchTime,
  ) async {
    // Get teams in the match
    var tournament = await _firestore.collection('tournaments').doc(tournamentId).get();
    var bracket = tournament.data()!['bracket'];
    
    // Find the match and get team IDs
    // Create notifications for both teams
    List<String> teamUserIds = []; // Get user IDs from teams

    for (var userId in teamUserIds) {
      // 30 min warning
      await _createNotification(
        userId: userId,
        type: 'match_starting',
        title: 'Match Starting Soon',
        message: 'Your match starts in 30 minutes',
        tournamentId: tournamentId,
        matchId: matchId,
        scheduledFor: matchTime.subtract(const Duration(minutes: 30)),
      );

      // 15 min warning
      await _createNotification(
        userId: userId,
        type: 'match_starting',
        title: 'Match Starting Very Soon!',
        message: 'Your match starts in 15 minutes. Get ready!',
        tournamentId: tournamentId,
        matchId: matchId,
        scheduledFor: matchTime.subtract(const Duration(minutes: 15)),
      );
    }
  }

  // Create notification
  Future<void> _createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    required String tournamentId,
    String? matchId,
    DateTime? scheduledFor,
  }) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('notifications')
        .add({
      'type': type,
      'title': title,
      'message': message,
      'tournamentId': tournamentId,
      'matchId': matchId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledFor': scheduledFor,
    });
  }

  // Get user's notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    var snapshot = await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  // ============ FEATURE 2: Check-in System ============

  // Check in team for tournament
  Future<Map<String, dynamic>> checkInTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    try {
      var tournamentRef = _firestore.collection('tournaments').doc(tournamentId);
      var tournament = await tournamentRef.get();
      var teams = List<Map<String, dynamic>>.from(tournament.data()!['teams']);

      // Find and update team check-in status
      int teamIndex = teams.indexWhere((t) => t['teamId'] == teamId);
      if (teamIndex != -1) {
        teams[teamIndex]['checkedIn'] = true;
        teams[teamIndex]['checkedInAt'] = FieldValue.serverTimestamp();

        await tournamentRef.update({'teams': teams});

        // Add activity
        await _addActivity(
          tournamentId: tournamentId,
          type: 'check_in',
          message: '${teams[teamIndex]['teamName']} checked in',
          relatedTeamId: teamId,
        );

        return {'success': true, 'message': 'Checked in successfully'};
      }

      return {'success': false, 'message': 'Team not found'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check if team has checked in
  Future<bool> hasTeamCheckedIn(String tournamentId, String teamId) async {
    var tournament = await _firestore.collection('tournaments').doc(tournamentId).get();
    var teams = List<Map<String, dynamic>>.from(tournament.data()!['teams']);
    
    var team = teams.firstWhere((t) => t['teamId'] == teamId, orElse: () => {});
    return team['checkedIn'] ?? false;
  }

  // Auto-forfeit teams that didn't check in
  Future<void> processCheckInForfeits(String tournamentId) async {
    var tournament = await _firestore.collection('tournaments').doc(tournamentId).get();
    var teams = List<Map<String, dynamic>>.from(tournament.data()!['teams']);

    for (var team in teams) {
      if (!(team['checkedIn'] ?? false)) {
        // Team didn't check in - forfeit them
        await _forfeitTeam(tournamentId, team['teamId']);
      }
    }
  }

  Future<void> _forfeitTeam(String tournamentId, String teamId) async {
    // Remove team from bracket and award wins to opponents
    // Implementation depends on bracket structure
  }

  // ============ FEATURE 3: Match Reporting ============

  // Report match result
  Future<Map<String, dynamic>> reportMatchResult({
    required String tournamentId,
    required String matchId,
    required String teamId,
    required int score,
    required int opponentScore,
    String? screenshotUrl,
    String? notes,
  }) async {
    try {
      var reportRef = _firestore
          .collection('match_reports')
          .doc(matchId)
          .collection('reports')
          .doc(teamId);

      await reportRef.set({
        'teamId': teamId,
        'reportedBy': _auth.currentUser!.uid,
        'score': score,
        'opponentScore': opponentScore,
        'screenshotUrl': screenshotUrl,
        'notes': notes,
        'reportedAt': FieldValue.serverTimestamp(),
      });

      // Check if both teams have reported
      var reports = await _firestore
          .collection('match_reports')
          .doc(matchId)
          .collection('reports')
          .get();

      if (reports.docs.length == 2) {
        // Both teams reported - verify results
        await _verifyMatchResults(tournamentId, matchId);
      }

      return {'success': true, 'message': 'Result reported successfully'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> _verifyMatchResults(String tournamentId, String matchId) async {
    var reports = await _firestore
        .collection('match_reports')
        .doc(matchId)
        .collection('reports')
        .get();

    var report1 = reports.docs[0].data();
    var report2 = reports.docs[1].data();

    // Check if results match
    bool resultsMatch = (report1['score'] == report2['opponentScore']) &&
        (report1['opponentScore'] == report2['score']);

    if (resultsMatch) {
      // Results match - auto-accept
      await _completeMatch(
        tournamentId: tournamentId,
        matchId: matchId,
        team1Score: report1['score'],
        team2Score: report1['opponentScore'],
        verified: true,
      );
    } else {
      // Results don't match - flag for admin review
      await _flagMatchForReview(tournamentId, matchId);
    }
  }

  Future<void> _completeMatch({
    required String tournamentId,
    required String matchId,
    required int team1Score,
    required int team2Score,
    required bool verified,
  }) async {
    // Update match in bracket
    // Add to activity feed
    await _addActivity(
      tournamentId: tournamentId,
      type: 'match_completed',
      message: 'Match completed',
      relatedMatchId: matchId,
    );
  }

  Future<void> _flagMatchForReview(String tournamentId, String matchId) async {
    // Update match status to 'disputed'
    // Notify admin
    // Send notifications to both teams
  }

  // Admin: Resolve disputed match
  Future<void> resolveDisputedMatch({
    required String tournamentId,
    required String matchId,
    required String winnerTeamId,
    required int team1Score,
    required int team2Score,
  }) async {
    await _completeMatch(
      tournamentId: tournamentId,
      matchId: matchId,
      team1Score: team1Score,
      team2Score: team2Score,
      verified: true,
    );

    await _addActivity(
      tournamentId: tournamentId,
      type: 'dispute',
      message: 'Match dispute resolved by admin',
      relatedMatchId: matchId,
    );
  }

  // ============ FEATURE 4: Activity Feed ============

  Future<void> _addActivity({
    required String tournamentId,
    required String type,
    required String message,
    String? relatedMatchId,
    String? relatedTeamId,
    String? screenshotUrl,
  }) async {
    await _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('activityFeed')
        .add({
      'type': type,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'relatedMatchId': relatedMatchId,
      'relatedTeamId': relatedTeamId,
      'screenshotUrl': screenshotUrl,
      'uploadedBy': _auth.currentUser?.uid,
    });
  }

  Stream<QuerySnapshot> getActivityFeed(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('activityFeed')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // ============ FEATURE 5: Team Profiles ============

  // Create team profile
  Future<String> createTeamProfile({
    required String teamName,
    required String captain,
    required List<String> players,
  }) async {
    var teamRef = await _firestore.collection('teams').add({
      'teamName': teamName,
      'captain': captain,
      'players': players,
      'createdBy': _auth.currentUser!.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'tournamentHistory': [],
      'stats': {
        'totalTournaments': 0,
        'wins': 0,
        'losses': 0,
        'winRate': 0.0,
      },
    });

    return teamRef.id;
  }

  // Get team profile
  Future<DocumentSnapshot> getTeamProfile(String teamId) async {
    return await _firestore.collection('teams').doc(teamId).get();
  }

  // Update team stats after tournament
  Future<void> updateTeamStats({
    required String teamId,
    required String tournamentId,
    required String tournamentName,
    required int placement,
    required int wins,
    required int losses,
  }) async {
    var teamRef = _firestore.collection('teams').doc(teamId);
    var team = await teamRef.get();
    var stats = team.data()!['stats'];

    await teamRef.update({
      'tournamentHistory': FieldValue.arrayUnion([
        {
          'tournamentId': tournamentId,
          'tournamentName': tournamentName,
          'placement': placement,
          'result': placement == 1 ? 'winner' : 'participant',
        }
      ]),
      'stats.totalTournaments': stats['totalTournaments'] + 1,
      'stats.wins': stats['wins'] + wins,
      'stats.losses': stats['losses'] + losses,
      'stats.winRate': (stats['wins'] + wins) / ((stats['wins'] + wins) + (stats['losses'] + losses)),
    });
  }

  // Get teams by user
  Stream<QuerySnapshot> getUserTeams(String userId) {
    return _firestore
        .collection('teams')
        .where('createdBy', isEqualTo: userId)
        .snapshots();
  }

  // ============ General Tournament Functions ============

  // Get all tournaments
  Stream<QuerySnapshot> getAllTournaments() {
    return _firestore
        .collection('tournaments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get tournament by ID
  Future<DocumentSnapshot> getTournament(String tournamentId) async {
    return await _firestore.collection('tournaments').doc(tournamentId).get();
  }

  // Get tournaments by status
  Stream<QuerySnapshot> getTournamentsByStatus(String status) {
    return _firestore
        .collection('tournaments')
        .where('status', isEqualTo: status)
        .orderBy('startDate')
        .snapshots();
  }

  // Get tournaments by game
  Stream<QuerySnapshot> getTournamentsByGame(String game) {
    return _firestore
        .collection('tournaments')
        .where('game', isEqualTo: game)
        .orderBy('startDate', descending: true)
        .snapshots();
  }
}