import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool developerFeaturesEnabled;
  final ValueChanged<bool> onDeveloperFeaturesChanged;
  final VoidCallback onResetAllToDefaults;

  const SettingsScreen({
    super.key,
    required this.developerFeaturesEnabled,
    required this.onDeveloperFeaturesChanged,
    required this.onResetAllToDefaults,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _devFeatures;

  @override
  void initState() {
    super.initState();
    _devFeatures = widget.developerFeaturesEnabled;
  }

  void _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121E),
        title: const Text(
          'Reset to Defaults?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove all customizations and restore all settings '
          'and timer profiles to their defaults.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      widget.onResetAllToDefaults();
      setState(() => _devFeatures = false);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // ── Developer Features section ─────────────────
          const Text(
            'DEVELOPER FEATURES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    color: Colors.deepPurpleAccent.withOpacity(0.12),
                    border: Border.all(
                      color: Colors.deepPurpleAccent.withOpacity(0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.developer_mode_rounded,
                    size: 18,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Developer Features',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Unlocks advanced display options across all screens',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _devFeatures,
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (v) {
                    setState(() => _devFeatures = v);
                    widget.onDeveloperFeaturesChanged(v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── App Data section ───────────────────────────
          const Text(
            'APP DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.redAccent.withOpacity(0.06),
                border:
                    Border.all(color: Colors.redAccent.withOpacity(0.15)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _confirmReset,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent.withOpacity(0.12),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.restore_rounded,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset to Defaults',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              'Removes all customizations and restores all '
                              'settings and timer profiles to their defaults',
                              style: TextStyle(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
