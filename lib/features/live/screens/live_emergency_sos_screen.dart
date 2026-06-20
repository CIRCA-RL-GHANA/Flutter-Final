/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// LIVE MODULE — Screen 20: Emergency SOS Interface
/// Critical safety screen: SOS activation, auto-location sharing,
/// emergency contacts, countdown timer, authorities notification
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive_tokens.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';

class LiveEmergencySOSScreen extends StatefulWidget {
  const LiveEmergencySOSScreen({super.key});

  @override
  State<LiveEmergencySOSScreen> createState() => _LiveEmergencySOSScreenState();
}

class _LiveEmergencySOSScreenState extends State<LiveEmergencySOSScreen> {
  bool _sosActivated = false;
  bool _locationSharing = true;
  bool _audioRecording = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveProvider>(
      builder: (context, prov, _) {
        return Scaffold(
          // CRITICAL: hard-cut to red instantly — no animation, no easing (spec Move 08)
          backgroundColor: _sosActivated ? kLiveColor : const Color(0xFF08080F),
          appBar: _sosActivated
              ? AppBar(
                  backgroundColor: kLiveColor,
                  title: const Text(
                    'SOS ACTIVE',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() => _sosActivated = false);
                      prov.cancelSOS();
                    },
                  ),
                )
              : const LiveAppBar(title: 'Emergency SOS'),
          body: Column(
            children: [
              Expanded(
                child: _sosActivated ? _ActiveSOSView(
                  contacts: prov.emergencyContacts,
                  locationSharing: _locationSharing,
                  audioRecording: _audioRecording,
                  onDeactivate: () {
                    setState(() => _sosActivated = false);
                    prov.cancelSOS();
                  },
                ) : _SOSSetupView(
                  contacts: prov.emergencyContacts,
                  locationSharing: _locationSharing,
                  audioRecording: _audioRecording,
                  onLocationSharingChanged: (v) => setState(() => _locationSharing = v),
                  onAudioRecordingChanged: (v) => setState(() => _audioRecording = v),
                  onActivate: () {
                    HapticFeedback.heavyImpact();
                    setState(() => _sosActivated = true);
                    prov.triggerSOS();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SOSSetupView extends StatefulWidget {
  final List<EmergencyContact> contacts;
  final bool locationSharing;
  final bool audioRecording;
  final ValueChanged<bool> onLocationSharingChanged;
  final ValueChanged<bool> onAudioRecordingChanged;
  final VoidCallback onActivate;

  const _SOSSetupView({
    required this.contacts,
    required this.locationSharing,
    required this.audioRecording,
    required this.onLocationSharingChanged,
    required this.onAudioRecordingChanged,
    required this.onActivate,
  });

  @override
  State<_SOSSetupView> createState() => _SOSSetupViewState();
}

class _SOSSetupViewState extends State<_SOSSetupView>
    with SingleTickerProviderStateMixin {
  late AnimationController _holdCtrl;

  @override
  void initState() {
    super.initState();
    _holdCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          widget.onActivate();
        }
      });
  }

  @override
  void dispose() {
    _holdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // SOS Button with 3-second hold countdown ring
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onLongPressStart: (_) => _holdCtrl.forward(),
                onLongPressEnd: (_) {
                  if (_holdCtrl.status != AnimationStatus.completed) {
                    _holdCtrl.reverse();
                  }
                },
                onLongPressCancel: () => _holdCtrl.reverse(),
                child: AnimatedBuilder(
                  animation: _holdCtrl,
                  builder: (_, __) => SizedBox(
                    width: 148,
                    height: 148,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Countdown ring
                        SizedBox(
                          width: 148,
                          height: 148,
                          child: CircularProgressIndicator(
                            value: _holdCtrl.value,
                            strokeWidth: 4,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        // Flat red disc — no shadow
                        Container(
                          width: 132,
                          height: 132,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: kLiveColor,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sos, size: 40, color: Colors.white),
                                const SizedBox(height: 4),
                                const Text('HOLD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                                Text(
                                  _holdCtrl.value > 0
                                      ? '${(3 - (_holdCtrl.value * 3)).ceil()}s'
                                      : '3s',
                                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hold to activate',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kLiveColor),
              ),
              const SizedBox(height: 4),
              const Text(
                'Location shared instantly.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SOS Settings
        LiveSectionCard(
          title: 'SOS SETTINGS',
          icon: Icons.settings,
          iconColor: kLiveColor,
          child: Column(
            children: [
              _SOSToggle(label: 'Auto-share location', value: widget.locationSharing, onChanged: widget.onLocationSharingChanged),
              _SOSToggle(label: 'Audio recording', value: widget.audioRecording, onChanged: widget.onAudioRecordingChanged),
            ],
          ),
        ),

        // Emergency Contacts
        LiveSectionCard(
          title: 'EMERGENCY CONTACTS',
          icon: Icons.contacts,
          iconColor: const Color(0xFF3B82F6),
          child: Column(
            children: widget.contacts.map((c) => _ContactItem(contact: c)).toList(),
          ),
        ),

        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF1C0A0A), borderRadius: BorderRadius.circular(10), border: Border.all(color: kLiveColor.withValues(alpha: 0.3), width: 1)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('âš ï¸ When SOS is activated:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kLiveColor)),
              SizedBox(height: 4),
              Text('• Your real-time location is shared', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
              Text('• Emergency contacts are notified', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
              Text('• Operations center is alerted', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
              Text('• Audio recording begins (if enabled)', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ActiveSOSView extends StatefulWidget {
  final List<EmergencyContact> contacts;
  final bool locationSharing;
  final bool audioRecording;
  final VoidCallback onDeactivate;

  const _ActiveSOSView({
    required this.contacts,
    required this.locationSharing,
    required this.audioRecording,
    required this.onDeactivate,
  });

  @override
  State<_ActiveSOSView> createState() => _ActiveSOSViewState();
}

class _ActiveSOSViewState extends State<_ActiveSOSView> {
  // GPS coordinates auto-attached on SOS activation
  String _coords = 'Acquiring GPS...';

  @override
  void initState() {
    super.initState();
    _attachGPS();
  }

  Future<void> _attachGPS() async {
    // In production this calls the location service.
    // Simulating with a short delay for the UI demonstration.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _coords = '5.6037° N, 0.1870° W');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              // White SOS icon on red — no shadow per spec
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: const Center(child: Icon(Icons.sos, size: 44, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              const Text(
                'SOS IS ACTIVE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'Help is on the way.',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // GPS coordinates — auto-attached per spec
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.gps_fixed, size: 14, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                _coords,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 12,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Status rows
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _StatusRow(icon: Icons.location_on, label: 'Location sharing', active: widget.locationSharing),
              _StatusRow(icon: Icons.mic, label: 'Audio recording', active: widget.audioRecording),
              const _StatusRow(icon: Icons.notifications_active, label: 'Contacts notified', active: true),
              const _StatusRow(icon: Icons.headset_mic, label: 'Operations center alerted', active: true),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick-call contacts
        const Text(
          'QUICK CALL',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        ...widget.contacts.take(2).map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(c.phone, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${c.name}...')),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 24),

        // Deactivate
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onDeactivate,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Deactivate SOS', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _SOSToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SOSToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Switch(value: value, onChanged: onChanged, activeThumbColor: kLiveColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final EmergencyContact contact;
  const _ContactItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kLiveColor.withValues(alpha: 0.1),
            child: Text(contact.name.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kLiveColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${contact.type.name} • ${contact.phone}', style: const TextStyle(fontSize: 11, color: IveTokens.muteColor)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling...')),
            ),
            icon: const Icon(Icons.phone, size: 18, color: Color(0xFF10B981)),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFD1FAE5)),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _StatusRow({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: active ? const Color(0xFF10B981) : Colors.white30),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: active ? Colors.white : Colors.white30))),
          Icon(active ? Icons.check_circle : Icons.cancel, size: 16, color: active ? const Color(0xFF10B981) : Colors.white30),
        ],
      ),
    );
  }
}
