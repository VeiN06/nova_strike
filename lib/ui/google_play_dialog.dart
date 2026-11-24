import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class GooglePlayComplianceDialog extends StatelessWidget {
  const GooglePlayComplianceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF101026),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user, color: Color(0xFF00E5FF), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        Localization.text('store_privacy'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF1E293B)),
              const SizedBox(height: 12),
              _buildSection(
                title: 'Data Safety & Privacy Policy',
                content:
                    'Nova Strike: Cyber Galaxy does not collect, store, or transmit any personal identifiable user data or tracking info. Game progress, high scores, and upgrades are stored strictly locally on your device.',
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: 'Target SDK & Compliance',
                content:
                    'Built with Android 14+ (targetSdk 34/35) compliance. Uses 60/120 FPS hardware acceleration with zero background network drain or unauthorized permissions.',
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: 'Age Rating & Content Guidelines',
                content:
                    'Content Rating: PEGI 3 / Everyone. Sci-fi arcade fantasy action with no violence, gambling, or adult content.',
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for rating Nova Strike!'),
                        backgroundColor: const Color(0xFF00E5FF),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.star, color: Colors.black),
                  label: Text(
                    'RATE ON GOOGLE PLAY',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
