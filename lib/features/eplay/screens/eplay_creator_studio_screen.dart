/// ═══════════════════════════════════════════════════════════════════════════
/// e-PLAY MODULE — Creator Studio Screen
/// Creators open their "digital branch", upload content, manage royalties.
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_insights_notifier.dart';
import 'eplay_hub_screen.dart' show kEPlayColor, kEPlayColorDark;

class EPlayCreatorStudioScreen extends StatefulWidget {
  const EPlayCreatorStudioScreen({super.key});

  @override
  State<EPlayCreatorStudioScreen> createState() => _EPlayCreatorStudioScreenState();
}

class _EPlayCreatorStudioScreenState extends State<EPlayCreatorStudioScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _hasProfile = false; // stub: false = not yet opened digital branch
  String _selectedType = 'music';
  bool _uploading = false;
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInsightsNotifier>(
      builder: (context, ai, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: kEPlayColorDark,
            foregroundColor: Colors.white,
            title: const Text('Creator Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            bottom: _hasProfile
                ? TabBar(
                    controller: _tabs,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: AppColors.accent,
                    tabs: const [Tab(text: 'My Content'), Tab(text: 'Upload'), Tab(text: 'Analytics')],
                  )
                : null,
          ),
          body: _hasProfile ? _buildStudio(ai) : _buildOnboarding(),
        );
      },
    );
  }

  // ── Onboarding: Open digital branch ──────────────────────────────────────

  Widget _buildOnboarding() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: kEPlayColor.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.storefront, color: kEPlayColor, size: 50),
          ),
          const SizedBox(height: 20),
          const Text('Open Your Digital Branch', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text(
            'Sell music, movies, podcasts, e-books and shows directly to your audience. You keep 85% — Genie keeps 15%.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _onboardingStat('85%', 'Creator royalty'),
          _onboardingStat('∞',   'Content you can upload'),
          _onboardingStat('DRM', 'IP protected by default'),
          _onboardingStat('QP',  'Micro-payment ready'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _hasProfile = true),
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Open Digital Branch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kEPlayColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _onboardingStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: kEPlayColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(value, style: const TextStyle(color: kEPlayColor, fontWeight: FontWeight.bold, fontSize: 14))),
        ),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      ]),
    );
  }

  // ── Creator Studio ────────────────────────────────────────────────────────

  Widget _buildStudio(AIInsightsNotifier ai) {
    return TabBarView(
      controller: _tabs,
      children: [
        _buildMyContent(),
        _buildUploadTab(),
        _buildAnalyticsTab(ai),
      ],
    );
  }

  Widget _buildMyContent() {
    final items = ['Afrobeats Vol. 3', 'Summer Mix 2025', 'Live at Accra'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, i) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: kEPlayColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.music_note, color: kEPlayColor),
          ),
          title: Text(items[i], style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Published · ₵5 QP', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          trailing: PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'unpublish', child: Text('Unpublish')),
            ],
            onSelected: (_) {},
          ),
        ),
      ),
    );
  }

  Widget _buildUploadTab() {
    final types = ['music', 'movie', 'podcast', 'ebook', 'show'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: types.map((t) => ChoiceChip(
              label: Text(t.toUpperCase()),
              selected: _selectedType == t,
              selectedColor: kEPlayColor,
              labelStyle: TextStyle(color: _selectedType == t ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
              onSelected: (_) => setState(() => _selectedType = t),
            )).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(controller: _titleCtrl, decoration: InputDecoration(hintText: 'e.g. Afrobeats Vol. 4', filled: true, fillColor: AppColors.inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          const Text('Price (Q Points)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'e.g. 5', prefixText: 'QP ', filled: true, fillColor: AppColors.inputFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          const SizedBox(height: 16),
          // Upload area
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity, height: 120,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid),
              ),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.textTertiary),
                SizedBox(height: 8),
                Text('Tap to upload encrypted content file', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('Your file is encrypted before reaching our servers', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : () => setState(() => _uploading = !_uploading),
              icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.upload),
              label: Text(_uploading ? 'Uploading…' : 'Upload & Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kEPlayColor, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(AIInsightsNotifier ai) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (ai.insights.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kEPlayColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: kEPlayColor.withOpacity(0.2))),
            child: Row(children: [
              const Icon(Icons.auto_awesome, color: kEPlayColor, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(ai.insights.first['title'] ?? '', style: const TextStyle(fontSize: 12))),
            ]),
          ),
        _analyticsCard('Total Earnings', '₵127 QP', Icons.account_balance_wallet, Colors.teal),
        _analyticsCard('Total Plays',    '4,820',    Icons.play_circle,             kEPlayColor),
        _analyticsCard('Unique Buyers',  '312',      Icons.people,                  AppColors.success),
        _analyticsCard('Avg. Rating',    '4.7 ★',    Icons.star,                    AppColors.warning),
      ],
    );
  }

  Widget _analyticsCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        trailing: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
