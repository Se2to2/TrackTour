class GameConfig {
  static const Map<String, String> gameCodeMap = {
    'Valorant': 'VAL',
    'Mobile Legends': 'ML',
    'Dota 2': 'DOTA',
    'CS2': 'CS2',
    'League of Legends': 'LOL',
    'Call of Duty': 'COD',
    'Apex Legends': 'APEX',
    'PUBG': 'PUBG',
    'Fortnite': 'FN',
    'Rocket League': 'RL',
  };

  static const Map<String, int> defaultTeamSize = {
    'Valorant': 5,
    'CS2': 5,
    'Mobile Legends': 5,
    'Dota 2': 5,
    'League of Legends': 5,
    'Call of Duty': 4,
    'Apex Legends': 3,
    'PUBG': 4,
    'Fortnite': 3,
    'Rocket League': 3,
  };

  static int getDefaultTeamSize(String game) {
    return defaultTeamSize[game] ?? 5;
  }
}