import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const HelpPage({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  Future<void> _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      // Handle error
      debugPrint('Could not launch $url: $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Smart Farm App Support',
    );
    await _launchURL(emailUri.toString());
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await _launchURL(phoneUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Frequently Asked Questions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildFaqItem(
                    context,
                    'How do I set up soil moisture sensors?',
                    'Connect the soil moisture sensors to your Arduino/ESP32, then place them in the soil at a depth of 4-6 inches. Make sure they\'re properly calibrated in the app settings.',
                  ),
                  _buildFaqItem(
                    context,
                    'Why is automatic irrigation not working?',
                    'Check if Auto Mode is enabled in the Controls tab. Verify your moisture threshold settings and ensure your pump is properly connected to the relay module.',
                  ),
                  _buildFaqItem(
                    context,
                    'How often should I check sensor calibration?',
                    'We recommend checking sensor calibration once a month or if you notice unusual readings. You can calibrate sensors in the Settings menu.',
                  ),
                  _buildFaqItem(
                    context,
                    'Can I add more sensors to my system?',
                    'Yes! The app supports additional sensors. Connect them to your IoT device and add them through the "Add Sensor" option in the Settings menu.',
                  ),
                  _buildFaqItem(
                    context,
                    'What if my internet connection is lost?',
                    'The system will continue to operate based on the last settings. Once connection is restored, the app will sync with the latest data from your farm.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Video Tutorials',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildTutorialItem(
                    context,
                    'Getting Started with Smart Farm',
                    'Learn how to set up your account and connect your first device',
                    'https://www.example.com/tutorials/getting-started',
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.contact_support,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Contact Support',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email Support'),
                    subtitle: const Text('aqilirsyad2005@gmail.com'),
                    onTap: () => _sendEmail('aqilirsyad2005@gmail.com'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone Support'),
                    subtitle: const Text('+60 10 790 3468 '),
                    onTap: () => _makePhoneCall('+60107903468'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialItem(BuildContext context, String title, String description, String url) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.play_circle_outline),
      onTap: () => _launchURL(url),
    );
  }
}