import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class ScheduleEntry {
  DateTime date;
  TimeOfDay start;
  TimeOfDay end;
  List<String> playerIds;

  ScheduleEntry({
    required this.date,
    required this.start,
    required this.end,
    this.playerIds = const [],
  });

  String display() {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final startStr = "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";
    final endStr = "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
    return "$dateStr $startStr - $endStr";
  }
}

class GameSchedule {
  DateTime dateTime;
  DateTime? endDateTime;
  List<String> playerIds;

  GameSchedule({
    required this.dateTime,
    this.endDateTime,
    this.playerIds = const [],
  });

  String get formattedDate {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }

  String get formattedTime {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String get formattedEndTime {
    if (endDateTime == null) return '';
    return "${endDateTime!.hour.toString().padLeft(2, '0')}:${endDateTime!.minute.toString().padLeft(2, '0')}";
  }

  String get display {
    if (endDateTime == null) {
      return "$formattedDate $formattedTime";
    }
    return "$formattedDate $formattedTime - $formattedEndTime";
  }
}

class Team {
  String id;
  String name;
  List<String> playerIds;

  Team({String? id, required this.name, this.playerIds = const []}) : id = id ?? const Uuid().v4();

  Team copyWith({String? name, List<String>? playerIds}) {
    return Team(
      id: id,
      name: name ?? this.name,
      playerIds: playerIds ?? this.playerIds,
    );
  }
}

class Game {
  String id;
  String title;
  String courtName;
  int numberOfPlayers;
  double shuttlecockCost;
  double courtCost;
  bool splitBill;
  List<String> playerIds; 
  List<GameSchedule> schedules;
  List<Team> teams;

  Game({
    String? id,
    required this.title,
    required this.courtName,
    required this.numberOfPlayers,
    required this.shuttlecockCost,
    required this.courtCost,
    this.splitBill = false,
    this.playerIds = const [],
    this.schedules = const [],
    this.teams = const [],
  }) : id = id ?? const Uuid().v4();

  Game copyWith({
    String? title,
    String? courtName,
    int? numberOfPlayers,
    double? shuttlecockCost,
    double? courtCost,
    bool? splitBill,
    List<String>? playerIds,
    List<GameSchedule>? schedules,
    List<Team>? teams,
  }) {
    return Game(
      id: id,
      title: title ?? this.title,
      courtName: courtName ?? this.courtName,
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
      shuttlecockCost: shuttlecockCost ?? this.shuttlecockCost,
      courtCost: courtCost ?? this.courtCost,
      splitBill: splitBill ?? this.splitBill,
      playerIds: playerIds ?? this.playerIds,
      schedules: schedules ?? this.schedules,
      teams: teams ?? this.teams,
    );
  }
}
