import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/tournament_service.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_wave.dart';
import '../models/game_config.dart';

class ViewAllTournamentsScreen extends StatefulWidget {
  const ViewAllTournamentsScreen({super.key});

  @override
  State<ViewAllTournamentsScreen> createState() => _ViewAllTournamentsScreenState();
}

class _ViewAllTournamentsScreenState extends State<ViewAllTournamentsScreen> {
  final _tournamentService = TournamentService();
  final _searchController = TextEditingController();
  
  String _selectedGame = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      appBar: AppBar(
        backgroundColor: AppColors.bgBlack,
        title: const Text(
          'All Tournaments',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search and Filters
              _buildSearchAndFilters(),

              // List
              Expanded(
                child: _buildTournamentList(),
              ),
            ],
          ),

          
          const BottomWave(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.purpleDark.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              hintText: 'Search by name, game, or ID...',
              hintStyle: const TextStyle(color: AppColors.hintColor, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.subTextColor),
              filled: true,
              fillColor: AppColors.fieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),

          // Filter
          Row(
            children: [
              // Game Filter
              Expanded(
                child: _buildGameDropdown(),
              ),
              const SizedBox(width: 12),
              // Status Filter
              Expanded(
                child: _buildStatusDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameDropdown() {
    List<String> games = ['All', ...GameConfig.gameCodeMap.keys.toList()];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: _selectedGame,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.fieldColor,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textColor),
        style: const TextStyle(color: AppColors.textColor, fontSize: 13),
        items: games.map((game) {
          return DropdownMenuItem(
            value: game,
            child: Text(game),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedGame = value!);
        },
      ),
    );
  }

  Widget _buildStatusDropdown() {
    List<String> statuses = ['All', 'Approved', 'Ongoing', 'Completed'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: _selectedStatus,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.fieldColor,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.textColor),
        style: const TextStyle(color: AppColors.textColor, fontSize: 13),
        items: statuses.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedStatus = value!);
        },
      ),
    );
  }

  Widget _buildTournamentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _tournamentService.getAllTournaments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.purpleMain),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, color: AppColors.subTextColor, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'No tournaments found',
                  style: TextStyle(
                    color: AppColors.subTextColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Filter tournaments
        var tournaments = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          
          // game filter
          if (_selectedGame != 'All' && data['game'] != _selectedGame) {
            return false;
          }

          // status filter
          if (_selectedStatus != 'All' && 
              data['status'].toString().toLowerCase() != _selectedStatus.toLowerCase()) {
            return false;
          }

          // search filter
          if (_searchQuery.isNotEmpty) {
            String name = (data['name'] ?? '').toString().toLowerCase();
            String game = (data['game'] ?? '').toString().toLowerCase();
            String tournamentId = doc.id.toLowerCase();
            
            if (!name.contains(_searchQuery) && 
                !game.contains(_searchQuery) && 
                !tournamentId.contains(_searchQuery)) {
              return false;
            }
          }

          return true;
        }).toList();

        if (tournaments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, color: AppColors.subTextColor, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'No tournaments match your filters',
                  style: TextStyle(
                    color: AppColors.subTextColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          itemCount: tournaments.length,
          itemBuilder: (context, index) {
            return _buildTournamentListCard(tournaments[index]);
          },
        );
      },
    );
  }

  Widget _buildTournamentListCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to tournament details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tournament ID: ${doc.id}')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purpleDark.withOpacity(0.4),
              AppColors.purpleMain.withOpacity(0.2)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.purpleMain.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Game Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.videogame_asset,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Tournament',
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['game'] ?? '',
                        style: const TextStyle(
                          color: AppColors.subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status
                _buildStatusBadge(data['status'] ?? ''),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.purpleMain.withOpacity(0.2), height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.people, '${data['registeredTeams'] ?? 0}/${data['maxTeams'] ?? 0} teams'),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.person, '${data['registeredPlayers'] ?? 0} players'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.location_on, data['venue'] ?? data['server'] ?? 'TBA'),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.access_time, _formatDate(data['startDate'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'ongoing':
        color = Colors.green;
        break;
      case 'approved':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.subTextColor, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.subTextColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'TBA';
    DateTime date = (timestamp as Timestamp).toDate();
    return '${date.month}/${date.day}/${date.year}';
  }
}