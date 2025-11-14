import 'package:flutter/material.dart';
import 'player_list_screen.dart';
import 'all_games_screen.dart';
import 'settings_screen.dart';
import 'add_player_screen.dart';
import 'add_edit_game_screen.dart';
import '../models/player.dart';
import '../models/game.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Player> players = [];
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addPlayer(Player player) {
    setState(() {
      players.add(player);
    });
  }

  void _addGame(Game game) {
    setState(() {
      final idx = games.indexWhere((g) => g.id == game.id);
      if (idx >= 0) {
        games[idx] = game;
      } else {
        games.add(game);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton Queue'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w600, fontSize: 20),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Players'),
            Tab(icon: Icon(Icons.sports_tennis), text: 'Games'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
            onPressed: () {
              if (_tabController.index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => AddPlayerScreen(
                      onSave: _addPlayer,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => AddEditGameScreen(
                      onSave: _addGame,
                      availablePlayers: players,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PlayerListScreen(showScaffold: false, onPlayerAdded: _addPlayer, initialPlayers: players),
          AllGamesScreen(showScaffold: false, onGameAdded: _addGame, initialGames: games, availablePlayers: players),
        ],
      ),
    );
  }
}
