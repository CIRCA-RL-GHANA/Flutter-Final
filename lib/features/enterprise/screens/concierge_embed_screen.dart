/// Enterprise › Concierge Embed Screen
/// Allows enterprise accounts to test and manage their AI Concierge sessions —
/// open a session, send messages, and view the response thread.

import 'package:flutter/material.dart';
import '../../../core/services/enterprise_service.dart';

const _kGold = Color(0xFFD4A017);
const _kCyan = Color(0xFF00BCD4);
const _kBg = Color(0xFF0A0A0F);
const _kCard = Color(0xFF1A1A2E);

class ConciergeEmbedScreen extends StatefulWidget {
  final String entityId;
  const ConciergeEmbedScreen({super.key, required this.entityId});

  @override
  State<ConciergeEmbedScreen> createState() => _ConciergeEmbedScreenState();
}

class _ConciergeEmbedScreenState extends State<ConciergeEmbedScreen> {
  final _svc = EnterpriseService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String? _sessionId;
  List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() => _loading = true);
    final res = await _svc.createConciergeSession(
      entityId: widget.entityId,
      endUserId: 'enterprise_test_user',
      topic: 'Enterprise concierge test session',
    );
    if (mounted) {
      setState(() {
        _sessionId = res.data?['id'] as String?;
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty || _sessionId == null) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': msg});
      _sending = true;
    });
    _scrollToBottom();

    final res = await _svc.sendConciergeMessage(_sessionId!, msg);
    if (mounted) {
      setState(() {
        if (res.success && res.data != null) {
          _messages.add({
            'role': 'assistant',
            'content': res.data!['reply'] as String? ?? '…',
            'detectedIntent': res.data!['detectedIntent'],
          });
        }
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _endSession() async {
    if (_sessionId == null) return;
    await _svc.closeConciergeSession(_sessionId!);
    if (mounted) {
      setState(() {
        _sessionId = null;
        _messages.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: Colors.white,
        title: const Text('AI Concierge Embed',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_sessionId != null)
            TextButton(
              onPressed: _endSession,
              child: const Text('End Session', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: _sessionId == null ? _buildStartView() : _buildChatView(),
    );
  }

  Widget _buildStartView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.smart_toy_outlined, size: 72, color: _kGold),
              const SizedBox(height: 20),
              const Text(
                'Genie Agentic Concierge',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              const SizedBox(height: 12),
              const Text(
                'Start a session to test the AI concierge that you can embed into your app or website via the API.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loading ? null : _startSession,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Text('Start Concierge Session',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );

  Widget _buildChatView() => Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          if (_sending)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kCyan),
                  ),
                  const SizedBox(width: 8),
                  const Text('Genie is typing…',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      );

  Widget _bubble(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final intent = msg['detectedIntent'] as String?;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? _kGold.withOpacity(0.15) : _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isUser ? _kGold.withOpacity(0.4) : const Color(0xFF2D2D44)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['content'] as String? ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            if (!isUser && intent != null) ...[
              const SizedBox(height: 4),
              Text(
                'intent: $intent',
                style: const TextStyle(
                    color: _kCyan, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: _kCard,
            border: Border(top: BorderSide(color: Color(0xFF2D2D44))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Ask the concierge…',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF0A0A0F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.send, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ),
      );
}
