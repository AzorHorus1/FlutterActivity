import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';

class AddEditGameScreen extends StatefulWidget {
  final Game? game;
  final void Function(Game) onSave;
  final List<Player> availablePlayers;

  const AddEditGameScreen({
    Key? key,
    this.game,
    required this.onSave,
    this.availablePlayers = const [],
  }) : super(key: key);

  @override
  State<AddEditGameScreen> createState() => _AddEditGameScreenState();
}

class _AddEditGameScreenState extends State<AddEditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _courtCtrl;
  late TextEditingController _shuttleCtrl;
  late TextEditingController _courtCostCtrl;
  int _players = 4;
  bool _split = false;
  List<ScheduleEntry> _schedules = [];
  List<Team> _teams = [];
  List<String> _selectedPlayerNicknames = [];

  @override
  void initState() {
    super.initState();
    final g = widget.game;
    _titleCtrl = TextEditingController(text: g?.title ?? '');
    _courtCtrl = TextEditingController(text: g?.courtName ?? '');
    _shuttleCtrl = TextEditingController(text: g?.shuttlecockCost.toStringAsFixed(0) ?? '75');
    _courtCostCtrl = TextEditingController(text: g?.courtCost.toStringAsFixed(0) ?? '400');
    _players = g?.numberOfPlayers ?? 4;
    _split = g?.splitBill ?? false;
    _selectedPlayerNicknames = List.from(g?.playerIds ?? []);
    _teams = g?.teams.map((t) => t.copyWith()).toList() ?? [];
    
    if (g?.schedules != null) {
      _schedules = g!.schedules.map((gs) {
        final startTime = TimeOfDay(hour: gs.dateTime.hour, minute: gs.dateTime.minute);
        final endTime = gs.endDateTime != null 
          ? TimeOfDay(hour: gs.endDateTime!.hour, minute: gs.endDateTime!.minute)
          : TimeOfDay(hour: (gs.dateTime.hour + 1) % 24, minute: gs.dateTime.minute);
        return ScheduleEntry(date: gs.dateTime, start: startTime, end: endTime, playerIds: List.from(gs.playerIds));
      }).toList();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _courtCtrl.dispose();
    _shuttleCtrl.dispose();
    _courtCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (start == null) return;
    
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute),
    );
    if (end == null) return;
    
    setState(() {
      _schedules.add(ScheduleEntry(date: date, start: start, end: end));
    });
  }

  void _removeSchedule(int i) {
    setState(() => _schedules.removeAt(i));
  }

  void _assignPlayersToSchedule(int scheduleIndex) {
    final schedule = _schedules[scheduleIndex];

    final eligiblePlayers = widget.availablePlayers
        .where((p) => _selectedPlayerNicknames.contains(p.nickname))
        .toList();

    List<String> tempSelectedPlayers = schedule.playerIds
        .where((id) => _selectedPlayerNicknames.contains(id))
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Players to ${schedule.display()}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eligiblePlayers.isEmpty)
                  const Text('No players selected for this game', style: TextStyle(color: Colors.orange))
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('${tempSelectedPlayers.length} / $_players selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  ...eligiblePlayers.map((player) {
                    final isSelected = tempSelectedPlayers.contains(player.nickname);
                    final canToggle = isSelected || tempSelectedPlayers.length < _players;
                    return CheckboxListTile(
                      title: Text(player.nickname),
                      subtitle: Text(player.fullName),
                      value: isSelected,
                      onChanged: canToggle
                          ? (selected) {
                              setDialogState(() {
                                if (selected == true) {
                                  if (!tempSelectedPlayers.contains(player.nickname)) {
                                    tempSelectedPlayers.add(player.nickname);
                                  }
                                } else {
                                  tempSelectedPlayers.removeWhere((p) => p == player.nickname);
                                }
                              });
                            }
                          : null,
                    );
                  }),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _schedules[scheduleIndex].playerIds = tempSelectedPlayers
                      .where((id) => _selectedPlayerNicknames.contains(id))
                      .toList();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _addTeam() {
    _showTeamEditor();
  }

  void _editTeam(int index) {
    _showTeamEditor(editIndex: index);
  }

  void _showTeamEditor({int? editIndex}) {
    final isEdit = editIndex != null;
    String name = isEdit ? _teams[editIndex].name : '';
    List<String> tempSelected = isEdit ? List.from(_teams[editIndex].playerIds) : <String>[];

    final eligiblePlayers = widget.availablePlayers.where((p) => _selectedPlayerNicknames.contains(p.nickname)).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Team' : 'New Team'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Team name'),
                  controller: TextEditingController(text: name),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 8),
                if (eligiblePlayers.isEmpty)
                  const Text('No players selected for this game', style: TextStyle(color: Colors.orange))
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('${tempSelected.length} selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  ...eligiblePlayers.map((p) {
                    final isSelected = tempSelected.contains(p.nickname);
                    return CheckboxListTile(
                      title: Text(p.nickname),
                      value: isSelected,
                      onChanged: (sel) {
                        setDialogState(() {
                          if (sel == true) {
                            if (!tempSelected.contains(p.nickname)) tempSelected.add(p.nickname);
                          } else {
                            tempSelected.removeWhere((id) => id == p.nickname);
                          }
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () {
              if (name.trim().isEmpty) return;
              setState(() {
                if (isEdit) {
                  for (final tm in _teams) {
                    if (tm != _teams[editIndex]) {
                      tm.playerIds.removeWhere((id) => tempSelected.contains(id));
                    }
                  }
                  _teams[editIndex] = _teams[editIndex].copyWith(name: name.trim(), playerIds: List.from(tempSelected));
                } else {
                  for (final tm in _teams) {
                    tm.playerIds.removeWhere((id) => tempSelected.contains(id));
                  }
                  _teams.add(Team(name: name.trim(), playerIds: List.from(tempSelected)));
                }
              });
              Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one schedule'))
      );
      return;
    }

    final title = _titleCtrl.text.trim().isEmpty 
      ? _schedules.first.date.toIso8601String().split('T').first 
      : _titleCtrl.text.trim();
    final shuttle = double.tryParse(_shuttleCtrl.text) ?? 75.0;
    final court = double.tryParse(_courtCostCtrl.text) ?? 400.0;
    
    final gameSchedules = _schedules.map((se) {
      final startDt = DateTime(se.date.year, se.date.month, se.date.day, se.start.hour, se.start.minute);
      final endDt = DateTime(se.date.year, se.date.month, se.date.day, se.end.hour, se.end.minute);
      final pruned = se.playerIds.where((id) => _selectedPlayerNicknames.contains(id)).toList();
      return GameSchedule(dateTime: startDt, endDateTime: endDt, playerIds: pruned);
    }).toList();

    final g = (widget.game ?? Game(
      title: title,
      courtName: _courtCtrl.text.trim(),
      numberOfPlayers: _players,
      shuttlecockCost: shuttle,
      courtCost: court,
      splitBill: _split,
      playerIds: _selectedPlayerNicknames,
      schedules: gameSchedules,
      teams: _teams,
    )).copyWith(
      title: title,
      courtName: _courtCtrl.text.trim(),
      numberOfPlayers: _players,
      shuttlecockCost: shuttle,
      courtCost: court,
      splitBill: _split,
      playerIds: _selectedPlayerNicknames,
      schedules: gameSchedules,
      teams: _teams,
    );

    widget.onSave(g);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Add New Game' : 'Edit Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Game Title (optional)',
                  hintText: 'Will use date if empty',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courtCtrl,
                decoration: const InputDecoration(labelText: 'Court Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter court name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Number of players:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _players,
                    items: [2, 4, 6, 8]
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
                    onChanged: (v) => setState(() => _players = v ?? 4),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shuttleCtrl,
                decoration: const InputDecoration(labelText: 'Shuttlecock Cost (₱)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter shuttlecock cost';
                  final d = double.tryParse(v);
                  if (d == null || d < 0) return 'Enter a valid positive number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courtCostCtrl,
                decoration: const InputDecoration(labelText: 'Court Cost (₱)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter court cost';
                  final d = double.tryParse(v);
                  if (d == null || d < 0) return 'Enter a valid positive number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Split bill among players'),
                value: _split,
                onChanged: (v) => setState(() => _split = v),
              ),
              const SizedBox(height: 16),
              const Text('Select Players', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Max players: $_players', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (widget.availablePlayers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('No players available. Add players from the Players tab first.', 
                    style: TextStyle(color: Colors.orange, fontSize: 12)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.availablePlayers.length,
                  itemBuilder: (context, idx) {
                    final player = widget.availablePlayers[idx];
                    final isSelected = _selectedPlayerNicknames.contains(player.nickname);
                    final canSelect = isSelected || _selectedPlayerNicknames.length < _players;
                    
                    return CheckboxListTile(
                      title: Text(player.nickname),
                      subtitle: Text('${player.fullName} • Level: ${player.level}'),
                      value: isSelected,
                      enabled: canSelect,
                      onChanged: canSelect
                          ? (selected) {
                              setState(() {
                                if (selected == true) {
                                  if (!_selectedPlayerNicknames.contains(player.nickname)) {
                                    _selectedPlayerNicknames.add(player.nickname);
                                  }
                                } else {
                                  _selectedPlayerNicknames.removeWhere((p) => p == player.nickname);
                                  for (final se in _schedules) {
                                    if (se.playerIds.contains(player.nickname)) {
                                      se.playerIds.removeWhere((id) => id == player.nickname);
                                    }
                                  }
                                  for (final tm in _teams) {
                                    if (tm.playerIds.contains(player.nickname)) {
                                      tm.playerIds.removeWhere((id) => id == player.nickname);
                                    }
                                  }
                                }
                              });
                            }
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 16),
              const Text('Teams', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (_teams.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No teams created', style: TextStyle(color: Colors.grey)),
                )
              else
                ..._teams.asMap().entries.map((entry) {
                  final ti = entry.key;
                  final team = entry.value;
                  return Card(
                    child: ListTile(
                      title: Text(team.name),
                      subtitle: team.playerIds.isEmpty
                        ? const Text('No members', style: TextStyle(color: Colors.grey, fontSize: 12))
                        : Text(team.playerIds.join(', '), style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTeam(ti),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() => _teams.removeAt(ti));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addTeam,
                  icon: const Icon(Icons.add),
                  label: const Text('Add team'),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Schedules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ..._schedules.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(s.display()),
                    subtitle: s.playerIds.isEmpty
                      ? const Text('No players assigned', style: TextStyle(color: Colors.grey, fontSize: 12))
                      : Text(
                          widget.availablePlayers
                              .where((p) => s.playerIds.contains(p.nickname))
                              .map((p) => p.nickname)
                              .join(', '),
                          style: const TextStyle(fontSize: 12),
                        ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.people),
                          onPressed: () => _assignPlayersToSchedule(i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeSchedule(i),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickSchedule,
                icon: const Icon(Icons.add),
                label: const Text('Add schedule'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Game'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}

