import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/game_models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final player = authProvider.currentPlayer;
    if (player != null) {
      _nameController.text = player.name;
      _emailController.text = player.isGuest ? '' : 'user@example.com';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final player = authProvider.currentPlayer;
            if (player == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Аватар и основная информация
                  _buildProfileHeader(player),
                  const SizedBox(height: 30),

                  // Статистика
                  _buildStatsSection(player),
                  const SizedBox(height: 30),

                  // Настройки профиля
                  _buildProfileSettings(player),
                  const SizedBox(height: 30),

                  // Действия
                  _buildActionsSection(authProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Player player) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              player.name.isNotEmpty ? player.name[0].toUpperCase() : 'G',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            player.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: player.isGuest ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              player.isGuest ? 'Гость' : 'Пользователь',
              style: TextStyle(
                color: player.isGuest ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Player player) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Монеты',
                  '${player.coins}',
                  Icons.monetization_on,
                  Colors.yellow,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Уровень',
                  '${player.level}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Опыт',
                  '${player.experience}',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Скины',
                  '${player.unlockedSkins.length}',
                  Icons.palette,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettings(Player player) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Настройки профиля',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Имя',
            _nameController,
            Icons.person,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Email',
            _emailController,
            Icons.email,
            enabled: _isEditing && !player.isGuest,
          ),
          if (_isEditing && !player.isGuest) ...[
            const SizedBox(height: 16),
            _buildTextField(
              'Пароль',
              _passwordController,
              Icons.lock,
              enabled: true,
              obscureText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = false,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildActionsSection(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Действия',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Синхронизировать данные',
            Icons.sync,
            () async {
              await authProvider.syncWithServer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Данные синхронизированы'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'Выйти',
            Icons.logout,
            () async {
              await authProvider.logout();
              Navigator.of(context).pop();
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text,
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль обновлен'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка обновления профиля'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
