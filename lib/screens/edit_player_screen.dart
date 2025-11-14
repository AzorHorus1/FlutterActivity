import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/level_slider.dart';

class EditPlayerScreen extends StatefulWidget {
  final Player player;
  final Function(Player) onUpdate;
  final Function(String) onDelete;

  const EditPlayerScreen({
    required this.player,
    required this.onUpdate,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  _EditPlayerScreenState createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _fullNameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _remarksController;
  late String _level;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.player.nickname);
    _fullNameController = TextEditingController(text: widget.player.fullName);
    _contactController =
        TextEditingController(text: widget.player.contactNumber);
    _emailController = TextEditingController(text: widget.player.email);
    _addressController = TextEditingController(text: widget.player.address);
    _remarksController = TextEditingController(text: widget.player.remarks);
    _level = widget.player.level;
  }

  void _updatePlayer() {
    if (_formKey.currentState!.validate()) {
      final updated = Player(
        id: widget.player.id,
        nickname: _nicknameController.text,
        fullName: _fullNameController.text,
        contactNumber: _contactController.text,
        email: _emailController.text,
        address: _addressController.text,
        remarks: _remarksController.text,
        level: _level,
      );
      widget.onUpdate(updated);
      Navigator.pop(context, updated);
    }
  }

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Player"),
        content: const Text(
            "Are you sure you want to permanently delete this player?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      widget.onDelete(widget.player.id);
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
          "Edit Player",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
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
                  validator: (v) => v!.isEmpty
                      ? 'Required'
                      : (!v.contains('@') ? 'Invalid email' : null),
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
                LevelSlider(
                  initialValue: _level,
                  onChanged: (level) => setState(() => _level = level),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text("Delete Player",
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: _updatePlayer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text("Update Player",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
