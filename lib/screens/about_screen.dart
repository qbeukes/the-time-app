import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = info.version);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App branding ────────────────────────────────
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'The Time App',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_version.isNotEmpty)
                    Text(
                      'Version $_version',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ── Links ───────────────────────────────────────
            _AboutLinkTile(
              icon: Icons.language_rounded,
              iconColor: Colors.cyanAccent,
              label: 'Website',
              subtitle: 'time.veryeasy.co.za',
              onTap: () => _openUrl('https://time.veryeasy.co.za'),
            ),
            _AboutLinkTile(
              icon: Icons.copyright_rounded,
              iconColor: const Color(0xFFB388FF),
              label: 'Copyright',
              subtitle: 'time.veryeasy.co.za/copyright',
              onTap: () =>
                  _openUrl('https://time.veryeasy.co.za/copyright'),
            ),
            _AboutLinkTile(
              icon: Icons.privacy_tip_rounded,
              iconColor: Colors.tealAccent,
              label: 'Privacy Policy',
              subtitle: 'time.veryeasy.co.za/privacy.html',
              onTap: () =>
                  _openUrl('https://time.veryeasy.co.za/privacy.html'),
            ),

            const SizedBox(height: 28),

            // ── Hypothesis section ──────────────────────────
            const Text(
              'HYPOTHESIS OF TIME & CHANGE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Hypothesis of Change proposes that Time has an '
                    'underlying architecture — a twelve-segment cycle called '
                    'the 12 Temporal Resonance Architecture (12TRA) — derived '
                    'from anthropological and astronomical patterns observed '
                    'across history. Each segment carries distinct qualities '
                    'of Change that repeat with each cycle, offering a '
                    'framework for navigating life with greater awareness of '
                    'the temporal forces shaping each moment.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openUrl(
                        'https://time.veryeasy.co.za/hypothesis.html'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: Colors.deepPurpleAccent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Read the full hypothesis',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurpleAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Link tile widget ────────────────────────────────────────

class _AboutLinkTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _AboutLinkTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.12),
                border: Border.all(color: iconColor.withOpacity(0.25)),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
