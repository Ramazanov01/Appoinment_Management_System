import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  List<Map<String, dynamic>> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final data = await ApiService.getAllProviders();
    setState(() {
      _providers = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Providers')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
          ? const Center(child: Text('No providers found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      provider['full_name'] ?? 'Unknown Doctor',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      provider['specialization'] ?? 'General Medicine',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      // İsteğe bağlı: Doktor detayına gitme
                    },
                  ),
                );
              },
            ),
    );
  }
}
