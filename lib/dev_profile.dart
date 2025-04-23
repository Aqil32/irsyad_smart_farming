import 'package:flutter/material.dart';

class DevProfilePage extends StatelessWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const DevProfilePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Profile'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage('assets/profile_pic.png'),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'MUHAMMAD AQIL IRSYAD RIDUAN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Student in KKTM Petaling Jaya',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Me',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Just a curious soul crafting digital solutions with a passion for electronics and code. Always learning, always building, always dreaming.",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Skills',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildSkillRow('Server Development', 0.8),
                      _buildSkillRow('Mobile App Development', 0.7),
                      _buildSkillRow('Web Development', 0.7),
                      _buildSkillRow('Python', 0.5),
                      _buildSkillRow('Arduino', 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: const Text('aqilirsyad2005@gmail.com'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: const Text('+60 10 790 3468'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('GitHub'),
                        subtitle: const Text('github.com/Aqil32'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact form will open here')),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildSkillRow(String skill, double level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(skill, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: level,
            backgroundColor: Colors.grey[300],
            minHeight: 6,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
