import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final db = ChamaDatabase();
  List<Map<String, dynamic>> members = [];
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  String? photoPath;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final data = await db.getMembers();
    setState(() => members = data);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked!= null) setState(() => photoPath = picked.path);
  }

  Future<void> _addMember() async {
    if (nameController.text.isEmpty) return;
    await db.insertMember({
      'name': nameController.text,
      'phone': phoneController.text,
      'id_number': idController.text,
      'photo_path': photoPath,
      'savings_balance': 0,
      'welfare_balance': 0,
      'shares': 1,
    });
    nameController.clear();
    phoneController.clear();
    idController.clear();
    photoPath = null;
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'ID Number')),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(onPressed: _pickPhoto, child: const Text('Take Photo')),
                const SizedBox(width: 10),
                if (photoPath!= null) const Text('Photo captured', style: TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _addMember, child: const Text('Add Member')),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (_, i) {
                  final m = members[i];
                  return Card(
                    child: ListTile(
                      leading: m['photo_path']!= null
                         ? CircleAvatar(backgroundImage: FileImage(File(m['photo_path'])))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(m['name']),
                      subtitle: Text('Phone: ${m['phone']}\nSavings: KES ${m['savings_balance']}\nWelfare: KES ${m['welfare_balance']}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
