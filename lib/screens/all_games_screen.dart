import 'package:flutter/material.dart';
import '../models/game.dart';
import '../models/player.dart';
import 'add_edit_game_screen.dart';
import 'settings_screen.dart';

class AllGamesScreen extends StatefulWidget {
  final bool showScaffold;
  final Function(Game)? onGameAdded;
  final List<Game> initialGames;
  final List<Player> availablePlayers;

  const AllGamesScreen({
    Key? key,
    this.showScaffold = true,
    this.onGameAdded,
    this.initialGames = const [],
    this.availablePlayers = const [],
  }) : super(key: key);

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  late List<Game> games;
  String query = '';

  List<Game> get filtered {
    if (query.trim().isEmpty) return games;
    final q = query.toLowerCase();
    return games.where((g) => 
      g.title.toLowerCase().contains(q) || 
      g.courtName.toLowerCase().contains(q)
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    games = List.from(widget.initialGames);
  }

  @override
  void didUpdateWidget(AllGamesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var parentGame in widget.initialGames) {
      final idx = games.indexWhere((g) => g.id == parentGame.id);
      if (idx >= 0) {
        if (games[idx].title != parentGame.title || 
            games[idx].numberOfPlayers != parentGame.numberOfPlayers) {
          games[idx] = parentGame;
        }
      } else {
        games.add(parentGame);
      }
    }
  }

  void _addOrUpdate(Game g) {
    final idx = games.indexWhere((x) => x.id == g.id);
    setState(() {
      if (idx == -1) {
        games.add(g);
        widget.onGameAdded?.call(g);
      } else {
        games[idx] = g;
        widget.onGameAdded?.call(g);
      }
    });
  }

  void _delete(int idx) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Delete this game?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Yes')),
        ],
      ),
    );
    if (res == true) setState(() => games.removeAt(idx));
  }

  void _openEdit(Game g) {
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => AddEditGameScreen(game: g, onSave: (updated) => _addOrUpdate(updated), availablePlayers: widget.availablePlayers)));
  }

  void _openAdd() {
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => AddEditGameScreen(onSave: (newGame) => _addOrUpdate(newGame), availablePlayers: widget.availablePlayers)));
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by name or court',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(query.isNotEmpty ? 'No games found' : 'No games yet'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final g = filtered[index];
                    final globalIndex = games.indexOf(g);
                    final displayTitle = g.schedules.isNotEmpty 
                        ? '${g.title} (${g.schedules.first.display})'
                        : g.title;
                    return Dismissible(
                      key: ValueKey(g.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (d) async {
                        final res = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Confirm delete'),
                            content: const Text('Delete this game?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes')),
                            ],
                          ),
                        );
                        return res == true;
                      },
                      onDismissed: (d) => _delete(globalIndex),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(displayTitle),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${g.courtName} • ${g.numberOfPlayers} players'),
                              if (g.schedules.isNotEmpty)
                                Text('📅 ${g.schedules.map((s) => s.display).join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                              if (g.playerIds.isNotEmpty)
                                Text('👥 ${g.playerIds.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                            ],
                          ),
                          onTap: () => _showGameDetails(g),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEdit(g)),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.showScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Games'),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _openAdd),
            IconButton(icon: const Icon(Icons.settings), onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {}));
            }),
          ],
        ),
        body: body,
      );
    }

    return body;
  }

  void _showGameDetails(Game game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(game.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Court: ${game.courtName}'),
              const SizedBox(height: 8),
              Text('Players: ${game.numberOfPlayers}'),
              const SizedBox(height: 8),
              Text('Shuttle: ₱${game.shuttlecockCost.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              Text('Court: ₱${game.courtCost.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Total: ₱${(game.shuttlecockCost + game.courtCost).toStringAsFixed(2)}'),
              if (game.playerIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Per player: ₱${((game.shuttlecockCost + game.courtCost) / game.numberOfPlayers).toStringAsFixed(2)}'),
              ],
              if (game.schedules.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Schedules:'),
                const SizedBox(height: 6),
                ...game.schedules.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(s.display),
                )).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
