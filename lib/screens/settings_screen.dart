import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const shuttlecockCost = 75;
    const courtCost = 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Costs',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sports_tennis),
                  title: const Text('Shuttlecock'),
                  trailing: Text('₱ $shuttlecockCost', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Default price per shuttlecock'),
                ),
              ),
            const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sports_handball),
                  title: const Text('Court (per hour)'),
                  trailing: Text('₱ $courtCost', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Default court rate per hour'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
