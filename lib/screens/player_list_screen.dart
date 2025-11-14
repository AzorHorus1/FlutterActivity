import 'package:flutter/material.dart';
import '../models/player.dart';
import 'add_player_screen.dart';
import 'edit_player_screen.dart';

class PlayerListScreen extends StatefulWidget {
  final bool showScaffold;
  final Function(Player)? onPlayerAdded;
  final List<Player> initialPlayers;

  const PlayerListScreen({
    Key? key,
    this.showScaffold = true,
    this.onPlayerAdded,
    this.initialPlayers = const [],
  }) : super(key: key);

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  late List<Player> players;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    players = List.from(widget.initialPlayers);
  }

  @override
  void didUpdateWidget(PlayerListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    players = List.from(widget.initialPlayers);
  }

  void _addPlayer(Player newPlayer) {
    setState(() => players.add(newPlayer));
    widget.onPlayerAdded?.call(newPlayer);
  }

  void _updatePlayer(Player updatedPlayer) {
    setState(() {
      final index = players.indexWhere((p) => p.id == updatedPlayer.id);
      if (index != -1) players[index] = updatedPlayer;
    });
  }

  void _deletePlayer(String id) {
    setState(() => players.removeWhere((p) => p.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlayers = players
        .where((p) =>
            p.nickname.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.fullName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    final content = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or nick name",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),

          // 👥 Player List
          Expanded(
            child: filteredPlayers.isEmpty
                ? const Center(
                    child: Text(
                      "No players found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredPlayers.length,
                    itemBuilder: (context, index) {
                      final player = filteredPlayers[index];
                      final color = Colors.primaries[
                          player.nickname.hashCode %
                              Colors.primaries.length];
                      return Dismissible(
                        key: ValueKey(player.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Player"),
                              content: const Text(
                                  "Are you sure you want to delete this player?"),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text("Delete")),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => _deletePlayer(player.id),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          elevation: 0,
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Text(
                                player.nickname[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              player.nickname,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "${player.fullName} • ${player.level}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPlayerScreen(
                                    player: player,
                                    onUpdate: _updatePlayer,
                                    onDelete: _deletePlayer,
                                  ),
                                ),
                              );
                              if (updated != null) _updatePlayer(updated);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (widget.showScaffold) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "All Players",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              onPressed: () async {
                final newPlayer = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPlayerScreen(onSave: _addPlayer),
                  ),
                );
                if (newPlayer != null) _addPlayer(newPlayer);
              },
            )
          ],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: content,
      );
    }

    return content;
  }
}
