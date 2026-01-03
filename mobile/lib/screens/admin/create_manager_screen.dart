import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateManagerScreen extends StatefulWidget {
  const CreateManagerScreen({super.key});

  @override
  State<CreateManagerScreen> createState() => _CreateManagerScreenState();
}

class _CreateManagerScreenState extends State<CreateManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedManagerLevel;

  final List<String> _departments = [
    'Select Department',
    'Consultation',
    'Check-up',
    'Therapy',
    'Cardiology',
    'Neurology',
    'General Medicine',
    'Pediatrics',
    'Surgery',
  ];

  final List<String> _managerLevels = [
    'Department Manager',
    'Senior Manager',
    'Operations Manager',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  // create_manager_screen.dart içindeki metot
  void _createManager() async {
    if (_formKey.currentState!.validate()) {
      //1. Veriyi hazırla
      final managerData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text, // Şifre eklendi
        'department': _selectedDepartment,
        'managerLevel': _selectedManagerLevel,
        'permissions': {},
      };

      // 2. Yükleniyor göstergesi göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 3. API'ye isteği at
      final result = await ApiService.createManager(managerData);

      // 4. Loading'i kapat
      if (!mounted) return;
      Navigator.pop(context);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Listeye geri dön
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manager Role Management',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create and assign new manager roles to the system.',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildCreateManagerSection(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _createManager,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Create Manager',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateManagerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.person_add,
                color: Color(0xFF4CAF50),
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Manager Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'First name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Last name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!value!.contains('@')) return 'Invalid email format';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true, // Şifreyi gizli gösterir
          decoration: const InputDecoration(
            labelText: 'Initial Password',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: (value) => (value?.length ?? 0) < 6
              ? 'Password must be at least 6 characters'
              : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          decoration: const InputDecoration(
            labelText: 'Department',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _departments.map((String department) {
            return DropdownMenuItem<String>(
              value: department == 'Select Department' ? null : department,
              child: Text(department),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedDepartment = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a department' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedManagerLevel,
          decoration: const InputDecoration(
            labelText: 'Manager Level',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: _managerLevels.map((String level) {
            return DropdownMenuItem<String>(value: level, child: Text(level));
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedManagerLevel = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a manager level' : null,
        ),
      ],
    );
  }
}
