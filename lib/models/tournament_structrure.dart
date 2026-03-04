// UPDATED Tournament Data Structure for Firestore
// Includes: Scheduling, Notifications, Check-in, Match Reporting, Activity Feed, Team Profiles

/*
tournaments/
  {tournamentId}/
    
    // Basic Info
    - tournamentId: "VAL_20260225_0001"
    - name: "NCST Valorant Championship"
    - game: "Valorant"
    - tournamentType: "lan" | "online" | "semi-lan"
    - venue: "Engineering Building"
    - rules: "Best of 3. Map pool: Haven, Bind, Ascent. No camping."
    
    // Team/Player Info
    - maxTeams: 8
    - teamSize: 5
    - registeredTeams: 6
    - registeredPlayers: 30
    
    // Status & Dates
    - status: "pending" | "approved" | "registration_open" | "ongoing" | "completed"
    - createdBy: userId
    - createdAt: timestamp
    - approvedBy: adminUserId
    - approvedAt: timestamp
    - startDate: timestamp
    - endDate: timestamp
    - checkInTime: timestamp (30 mins before first match)
    
    // Teams Array (with check-in status)
    - teams: [
        {
          teamId: "TEAM_001",
          teamName: "Team Alpha",
          captain: "John Doe",
          players: ["John Doe", "Jane Smith", "Bob Lee", "Alice Wong", "Charlie Brown"],
          registeredBy: userId,
          registeredAt: timestamp,
          seed: 1,
          checkedIn: true,
          checkedInAt: timestamp,
          wins: 0,
          losses: 0
        }
      ]
    
    // Bracket with Match Scheduling & Reporting
    - bracket: {
        rounds: [
          {
            roundNumber: 1,
            roundName: "Quarterfinals",
            matches: [
              {
                matchId: "VAL_20260225_0001_R1_M1",
                matchNumber: 1,
                scheduledTime: timestamp,
                team1: {
                  teamId: "TEAM_001",
                  teamName: "Team Alpha",
                  score: 13,
                  reportedResult: {
                    score: 13,
                    reportedBy: userId,
                    reportedAt: timestamp,
                    screenshotUrl: "https://..."
                  }
                },
                team2: {
                  teamId: "TEAM_008",
                  teamName: "The Underdogs",
                  score: 7,
                  reportedResult: {
                    score: 7,
                    reportedBy: userId,
                    reportedAt: timestamp,
                    screenshotUrl: "https://..."
                  }
                },
                winner: "TEAM_001",
                status: "scheduled" | "live" | "disputed" | "completed",
                resultsMatch: true, // Both teams reported same result
                completedAt: timestamp,
                notificationsSent: true
              }
            ]
          }
        ]
      }
    
    // Activity Feed
    - activityFeed: [
        {
          activityId: "ACT_001",
          type: "match_completed" | "team_registered" | "check_in" | "dispute" | "winner",
          message: "Team Alpha advanced to Finals",
          timestamp: timestamp,
          relatedMatchId: "VAL_20260225_0001_R2_M1",
          relatedTeamId: "TEAM_001"
        },
        {
          activityId: "ACT_002",
          type: "screenshot_uploaded",
          message: "Match result screenshot uploaded",
          timestamp: timestamp,
          screenshotUrl: "https://...",
          uploadedBy: userId
        }
      ]
    
    // Results
    - winner: "Team Alpha"
    - winnerTeamId: "TEAM_001"
    - runnerUp: "Phoenix Squad"
    - completedAt: timestamp

teams/
  {teamId}/  // Separate collection for team profiles
    - teamId: "TEAM_001"
    - teamName: "Team Alpha"
    - captain: "John Doe"
    - players: ["John Doe", "Jane Smith", ...]
    - createdBy: userId
    - createdAt: timestamp
    - tournamentHistory: [
        {
          tournamentId: "VAL_20260225_0001",
          tournamentName: "NCST Valorant Championship",
          placement: 1,
          result: "winner"
        }
      ]
    - stats: {
        totalTournaments: 5,
        wins: 12,
        losses: 3,
        winRate: 0.8
      }

notifications/
  {userId}/
    notifications/
      {notificationId}/
        - notificationId: "NOTIF_001"
        - type: "match_starting" | "check_in_reminder" | "match_completed" | "result_disputed"
        - title: "Match Starting Soon"
        - message: "Your match starts in 15 minutes"
        - tournamentId: "VAL_20260225_0001"
        - matchId: "VAL_20260225_0001_R1_M1"
        - read: false
        - createdAt: timestamp
        - scheduledFor: timestamp (for scheduled notifications)

match_reports/
  {matchId}/
    reports/
      {teamId}/
        - teamId: "TEAM_001"
        - reportedBy: userId
        - score: 13
        - opponentScore: 7
        - screenshotUrl: "https://..."
        - reportedAt: timestamp
        - notes: "GG, close match"
*/

// Notification Types
enum NotificationType {
  matchStarting,      // "Your match starts in 15 minutes"
  checkInReminder,    // "Check in for your tournament"
  matchCompleted,     // "Your match result has been recorded"
  resultDisputedAdmin, // "Match result disputed - needs admin review"
  resultDisputed,     // "Opponent reported different result"
  tournamentStarting, // "Tournament starts tomorrow"
  teamAdvanced,       // "Your team advanced to next round"
  tournamentComplete, // "Tournament completed"
}

// Activity Types
enum ActivityType {
  matchCompleted,
  teamRegistered,
  checkIn,
  screenshotUploaded,
  dispute,
  winner,
  matchScheduled,
}

// Match Status
enum MatchStatus {
  scheduled,   // Match scheduled but not started
  checkIn,     // Waiting for teams to check in
  live,        // Match is currently being played
  reporting,   // Waiting for teams to report results
  disputed,    // Results don't match, admin review needed
  completed,   // Match finished and verified
}