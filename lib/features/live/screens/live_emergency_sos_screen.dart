/// ═══════════════════════════════════════════════════════════════════════════
/// LIVE MODULE — Screen 20: Emergency SOS Interface
/// Critical safety screen: SOS activation, auto-location sharing,
/// emergency contacts, countdown timer, authorities notification
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/live_models.dart';
import '../providers/live_provider.dart';
import '../widgets/live_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

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
          backgroundColor: _sosActivated ? const Color(0xFF1A1A1A) : AppColors.backgroundLight,
          appBar: _sosActivated
              ? AppBar(
                  backgroundColor: kLiveColor,
                  title: const Text('🚨 SOS ACTIVE', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                  centerTitle: true,
                  leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () {
                    setState(() => _sosActivated = false);
                    prov.cancelSOS();
                  }),
                )
              : const LiveAppBar(title: 'Emergency SOS'),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kLiveColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome, size: 14, color: kLiveColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kLiveColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
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

class _SOSSetupView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // SOS Button
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onLongPress: onActivate,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [kLiveColor, Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: kLiveColor.withOpacity(0.4), blurRadius: 24, spreadRadius: 4)],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sos, size: 40, color: Colors.white),
                        SizedBox(height: 4),
                        Text('HOLD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text('3 seconds', style: TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('LONG PRESS TO ACTIVATE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kLiveColor)),
              Text('Your location will be shared immediately', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
              _SOSToggle(label: '📍 Auto-share location', value: locationSharing, onChanged: onLocationSharingChanged),
              _SOSToggle(label: '🎤 Audio recording', value: audioRecording, onChanged: onAudioRecordingChanged),
            ],
          ),
        ),

        // Emergency Contacts
        LiveSectionCard(
          title: 'EMERGENCY CONTACTS',
          icon: Icons.contacts,
          iconColor: const Color(0xFF3B82F6),
          child: Column(
            children: contacts.map((c) => _ContactItem(contact: c)).toList(),
          ),
        ),

        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚠️ When SOS is activated:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kLiveColor)),
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

class _ActiveSOSView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kLiveColor,
                  boxShadow: [BoxShadow(color: kLiveColor.withOpacity(0.6), blurRadius: 30, spreadRadius: 8)],
                ),
                child: const Center(child: Icon(Icons.sos, size: 48, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              const Text('🚨 SOS IS ACTIVE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kLiveColor)),
              const SizedBox(height: 4),
              Text('Help is on the way', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Status indicators
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              _StatusRow(icon: Icons.location_on, label: 'Location sharing', active: locationSharing),
              _StatusRow(icon: Icons.mic, label: 'Audio recording', active: audioRecording),
              const _StatusRow(icon: Icons.notifications_active, label: 'Contacts notified', active: true),
              const _StatusRow(icon: Icons.headset_mic, label: 'Ops center alerted', active: true),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Emergency contacts (call buttons)
        const Text('QUICK CALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
        const SizedBox(height: 8),
        ...contacts.take(2).map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 18, color: Color(0xFF10B981)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(c.phone, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('CALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        )),

        const SizedBox(height: 24),

        // Deactivate button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onDeactivate,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('DEACTIVATE SOS', style: TextStyle(fontWeight: FontWeight.w700)),
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
          Switch(value: value, onChanged: onChanged, activeColor: kLiveColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
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
            backgroundColor: kLiveColor.withOpacity(0.1),
            child: Text(contact.name.substring(0, 1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kLiveColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${contact.type.name} • ${contact.phone}', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
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
