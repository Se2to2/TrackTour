import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/tournament_service.dart';
import '../models/game_config.dart';

class CreateTournamentScreen extends StatefulWidget {
  final String userRole;

  const CreateTournamentScreen({super.key, required this.userRole});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _rulesController = TextEditingController();
  final _authService = AuthService();
  final _tournamentService = TournamentService();

  bool _isLoading = false;
  String _selectedGame = 'Valorant';
  String _selectedType = 'lan';
  int _maxTeams = 8;
  int _teamSize = 5;
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);

  // Theme colors
  static const Color bgColor = Color(0xFF0A0A0A);
  static const Color accentColor = Color(0xFF7B6EF6);
  static const Color fieldColor = Color(0xFF1E1E1E);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Color(0xFF888888);
  static const Color labelColor = Color(0xFF9B9B9B);

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: textColor,
              surface: fieldColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
              onPrimary: textColor,
              surface: fieldColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // tournament ID
    String gameCode = GameConfig.gameCodeMap[_selectedGame] ?? 'GAME';
    String dateStr = '${_startDate.year}${_startDate.month.toString().padLeft(2, '0')}${_startDate.day.toString().padLeft(2, '0')}';
    String randomCode = DateTime.now().millisecondsSinceEpoch.toString().substring(9, 13);
    String tournamentId = '${gameCode}_${dateStr}_$randomCode';

    DateTime startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    try {
      await FirebaseFirestore.instance.collection('tournaments').doc(tournamentId).set({
        'tournamentId': tournamentId,
        'name': _nameController.text.trim(),
        'game': _selectedGame,
        'tournamentType': _selectedType,
        'venue': _selectedType != 'online' ? _venueController.text.trim() : null,
        'server': _selectedType == 'online' ? _venueController.text.trim() : null,
        'rules': _rulesController.text.trim(),
        'maxTeams': _maxTeams,
        'teamSize': _teamSize,
        'registeredTeams': 0,
        'registeredPlayers': 0,
        'status': widget.userRole == 'admin' ? 'approved' : 'pending',
        'createdBy': _authService.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'startDate': Timestamp.fromDate(startDateTime),
        'teams': [],
        'bracket': null,
      });

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.userRole == 'admin'
                ? 'Tournament created successfully!'
                : 'Tournament submitted for approval!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Create Tournament',
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament Name
                  _buildLabel('TOURNAMENT NAME'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'NCST Valorant Championship',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter tournament name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Game Selection
                  _buildLabel('GAME'),
                  const SizedBox(height: 8),
                  _buildGameSelector(),
                  const SizedBox(height: 20),

                  // Tournament Type
                  _buildLabel('TOURNAMENT TYPE'),
                  const SizedBox(height: 8),
                  _buildTypeSelector(),
                  const SizedBox(height: 20),

                  // Venue/Server
                  _buildLabel(_selectedType == 'online' ? 'SERVER/PLATFORM' : 'VENUE'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _venueController,
                    hint: _selectedType == 'online'
                        ? 'Discord + NA Server'
                        : 'Engineering Building, Room 301',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ${_selectedType == 'online' ? 'server' : 'venue'}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('MAX TEAMS'),
                            const SizedBox(height: 8),
                            _buildTeamCountSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TEAM SIZE'),
                            const SizedBox(height: 8),
                            _buildTeamSizeField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('START DATE'),
                            const SizedBox(height: 8),
                            _buildDateSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('START TIME'),
                            const SizedBox(height: 8),
                            _buildTimeSelector(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _rulesController,
                    hint: 'Best of 3. No cheating. Be respectful.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createTournament,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: textColor,
                        disabledBackgroundColor: accentColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.userRole == 'admin'
                                  ? 'Create Tournament'
                                  : 'Submit for Approval',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom wave
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _BottomWaveClipper(),
              child: Container(
                height: 80,
                color: accentColor.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: labelColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 14,
        ),
        filled: true,
        fillColor: fieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildGameSelector() {
    List<String> games = GameConfig.gameCodeMap.keys.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedGame,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: fieldColor,
        style: const TextStyle(color: textColor, fontSize: 14),
        items: games.map((game) {
          return DropdownMenuItem(
            value: game,
            child: Text(game),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGame = value!;
            _teamSize = GameConfig.getDefaultTeamSize(value);
          });
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      children: [
        _buildTypeChip('lan', 'LAN Tournament', Icons.location_on),
        const SizedBox(height: 8),
        _buildTypeChip('online', 'Online Tournament', Icons.wifi),
        const SizedBox(height: 8),
        _buildTypeChip('semi-lan', 'Semi-LAN (BYOD)', Icons.laptop),
      ],
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    bool selected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.2) : fieldColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? accentColor : subTextColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? textColor : subTextColor,
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCountSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: _maxTeams,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: fieldColor,
        style: const TextStyle(color: textColor, fontSize: 14),
        items: [2, 4, 8, 16, 32].map((count) {
          return DropdownMenuItem(
            value: count,
            child: Text('$count teams'),
          );
        }).toList(),
        onChanged: (value) => setState(() => _maxTeams = value!),
      ),
    );
  }

  Widget _buildTeamSizeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$_teamSize players',
        style: const TextStyle(color: textColor, fontSize: 14),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: accentColor, size: 18),
            const SizedBox(width: 12),
            Text(
              '${_startDate.month}/${_startDate.day}/${_startDate.year}',
              style: const TextStyle(color: textColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: accentColor, size: 18),
            const SizedBox(width: 12),
            Text(
              _startTime.format(context),
              style: const TextStyle(color: textColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.6,
      size.width, size.height * 0.2,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}