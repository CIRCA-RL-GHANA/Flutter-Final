import 'package:flutter/material.dart';
import '../core/services/enterprise_service.dart';

/// Pathway 4 — Embeddable Agentic Concierge chat widget.
///
/// Embeds a Genie AI conversation into any screen.  Manages its own
/// session lifecycle (create → send → close).
///
/// Usage:
/// ```dart
/// GenieConciergeWidget(
///   entityId: 'ent_123',
///   externalUserId: 'cust_abc',
///   language: 'en',
///   greeting: 'How can I help you today?',
/// )
/// ```
class GenieConciergeWidget extends StatefulWidget {
  const GenieConciergeWidget({
    super.key,
    required this.entityId,
    required this.externalUserId,
    this.language = 'en',
    this.greeting,
    this.accentColor,
  });

  final String entityId;
  final String externalUserId;
  final String language;
  final String? greeting;
  final Color? accentColor;

  @override
  State<GenieConciergeWidget> createState() => _GenieConciergeWidgetState();
}

class _GenieConciergeWidgetState extends State<GenieConciergeWidget> {
  final _svc = EnterpriseService();
  final _scrollCtrl = ScrollController();
  final _textCtrl = TextEditingController();

  String? _sessionId;
  bool _loading = false;
  bool _starting = true;
  String? _error;

  final List<_ChatMessage> _messages = [];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    if (_sessionId != null) {
      _svc.closeConciergeSession(_sessionId!).ignore();
    }
    _scrollCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  Future<void> _startSession() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final resp = await _svc.createConciergeSession(
        entityId: widget.entityId,
        endUserId: widget.externalUserId,
        context: {'language': widget.language},
      );
      if (resp.data == null) throw Exception(resp.message ?? 'Session failed');
      setState(() {
        _sessionId = resp.data!['sessionId'] as String? ?? resp.data!['id'] as String;
        final greeting = widget.greeting ??
            (resp.data!['greeting'] as String? ?? 'Hello! How can I help?');
        _messages.add(_ChatMessage(role: 'agent', text: greeting));
        _starting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not start session: $e';
        _starting = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _sessionId == null) return;

    _textCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _loading = true;
    });
    _scrollToBottom();

    try {
      final resp = await _svc.sendConciergeMessage(_sessionId!, text);
      final reply = resp.data?['text'] as String? ??
          resp.data?['card']?.toString() ??
          '…';
      setState(() => _messages.add(_ChatMessage(role: 'agent', text: reply)));
    } catch (e) {
      setState(() =>
          _messages.add(_ChatMessage(role: 'agent', text: 'Sorry, something went wrong.')));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? const Color(0xFF6C3CE1);
    final theme = Theme.of(context);

    if (_starting) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _startSession, child: const Text('Retry')),
        ],
      );
    }

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: accent,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.auto_awesome, color: Color(0xFF6C3CE1), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Genie Concierge',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
            ],
          ),
        ),

        // ── Message list ─────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _MessageBubble(
              message: _messages[i],
              accentColor: accent,
            ),
          ),
        ),

        // ── Input bar ────────────────────────────────────────────────────────
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Type a message…',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send_rounded, color: accent),
                onPressed: _loading ? null : _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────

class _ChatMessage {
  final String role; // 'user' | 'agent'
  final String text;
  const _ChatMessage({required this.role, required this.text});
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.accentColor});
  final _ChatMessage message;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? accentColor : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14),
        ),
      ),
    );
  }
}
