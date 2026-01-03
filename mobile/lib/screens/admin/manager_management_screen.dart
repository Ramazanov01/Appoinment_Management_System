import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ManagerManagementScreen extends StatefulWidget {
  const ManagerManagementScreen({super.key});

  @override
  State<ManagerManagementScreen> createState() =>
      _ManagerManagementScreenState();
}

class _ManagerManagementScreenState extends State<ManagerManagementScreen> {
  List managers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadManagers();
  }

  Future<void> _loadManagers() async {
    final result = await ApiService.getAllManagers();
    if (result['success']) {
      setState(() {
        managers = result['data'];
        isLoading = false;
      });
    }
  }

  Future<void> _deleteManager(String id) async {
    final success = await ApiService.deleteManager(id);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      _loadManagers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Management')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: managers.length,
              itemBuilder: (context, index) {
                final manager = managers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      '${manager['first_name']} ${manager['last_name']}',
                    ),
                    subtitle: Text(
                      '${manager['department']} - ${manager['email']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _showDeleteDialog(manager['id'].toString()),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Manager?'),
        content: const Text(
          'This action cannot be undone and will remove the doctor record as well.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteManager(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
