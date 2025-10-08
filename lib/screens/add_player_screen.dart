import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../widgets/level_slider.dart';

class AddPlayerScreen extends StatefulWidget {
  final Function(Player) onSave;
  const AddPlayerScreen({required this.onSave, Key? key}) : super(key: key);

  @override
  _AddPlayerScreenState createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarksController = TextEditingController();
  String _level = "Mid Level F";

  void savePlayer() {
    if (_formKey.currentState!.validate()) {
      final newPlayer = Player(
        id: Uuid().v4(),
        nickname: _nicknameController.text,
        fullName: _fullNameController.text,
        contactNumber: _contactController.text,
        email: _emailController.text,
        address: _addressController.text,
        remarks: _remarksController.text,
        level: _level,
      );
      widget.onSave(newPlayer);
      Navigator.pop(context);
    }
  }

  Widget buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "New Player",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: savePlayer,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                buildInput(
                  label: "Nickname",
                  icon: Icons.account_circle_outlined,
                  controller: _nicknameController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                buildInput(
                  label: "Full Name",
                  icon: Icons.person_outline,
                  controller: _fullNameController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                buildInput(
                  label: "Mobile Number",
                  icon: Icons.phone_outlined,
                  controller: _contactController,
                  type: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final value = v.trim();
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Numbers only';
                    if (value.length < 7 || value.length > 13) return 'Invalid number length';
                    return null;
                  }),
                buildInput(
                  label: "Email Address",
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  type: TextInputType.emailAddress,
                  validator: (v) =>
                      v!.isEmpty ? 'Required' : (!v.contains('@') ? 'Invalid email' : null),
                ),
                buildInput(
                  label: "Home Address",
                  icon: Icons.location_on_outlined,
                  controller: _addressController,
                  maxLines: 2,
                ),
                buildInput(
                  label: "Remarks",
                  icon: Icons.menu_book_outlined,
                  controller: _remarksController,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "LEVEL",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                LevelSlider(onChanged: (level) => setState(() => _level = level)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
