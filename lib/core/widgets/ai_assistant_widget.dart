import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_assistant_service.dart';
import '../theme/app_colors.dart';

/// Floating AI Assistant overlay button + expandable chat panel.
/// Add to your Scaffold as a floating widget or use as a bottom sheet.
class AIAssistantWidget extends StatefulWidget {
  final String modelId;
  final String? userId;
  final String title;
  final Color? primaryColor;

  const AIAssistantWidget({
    super.key,
    required this.modelId,
    this.userId,
    this.title = 'AI Assistant',
    this.primaryColor,
  });

  @override
  State<AIAssistantWidget> createState() => _AIAssistantWidgetState();
}

class _AIAssistantWidgetState extends State<AIAssistantWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final svc = context.read<AIAssistantService>();
    await svc.sendMessage(
      modelId: widget.modelId,
      message: text,
      userId:  widget.userId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor ?? AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_expanded) _buildChatPanel(color),
        const SizedBox(height: 10),
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.0).animate(_animCtrl),
          child: FloatingActionButton.extended(
            heroTag:         'ai_assistant_fab',
            backgroundColor: color,
            onPressed:       _toggle,
            icon:  Icon(_expanded ? Icons.close : Icons.auto_awesome,
                color: Colors.white),
            label: Text(
              _expanded ? 'Close' : 'AI',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatPanel(Color color) {
    return Consumer<AIAssistantService>(
      builder: (context, svc, _) {
        return Container(
          width:            340,
          height:           400,
          decoration: BoxDecoration(
            color:        Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset:     const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:        color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const Spacer(),
                    if (svc.history.isNotEmpty)
                      GestureDetector(
                        onTap: svc.clearHistory,
                        child: const Icon(Icons.refresh,
                            color: Colors.white70, size: 18),
                      ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: svc.history.isEmpty
                    ? _buildEmptyState(color)
                    : ListView.builder(
                        controller: _scrollController,
                        padding:    const EdgeInsets.all(12),
                        itemCount:  svc.history.length,
                        itemBuilder: (_, i) =>
                            _AiMessageBubble(message: svc.history[i]),
                      ),
              ),

              if (svc.isLoading)
                LinearProgressIndicator(
                  minHeight:  2,
                  valueColor: AlwaysStoppedAnimation(color),
                ),

              if (svc.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(svc.error!,
                      style: TextStyle(
                          color: Colors.red.shade400, fontSize: 11)),
                ),

              // Input row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText:       'Ask anything…',
                          hintStyle:      const TextStyle(fontSize: 13),
                          isDense:        true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border:         OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:   BorderSide.none,
                          ),
                          filled:     true,
                          fillColor:  Theme.of(context).hoverColor,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius:          18,
                      backgroundColor: color,
                      child: IconButton(
                        padding:     EdgeInsets.zero,
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 16),
                        onPressed: svc.isLoading ? null : _send,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_outlined,
              size: 40, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          const Text('How can I help you today?',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  final AiChatMessage message;
  const _AiMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.65),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.backgroundLight,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(12),
            topRight:    const Radius.circular(12),
            bottomLeft:  Radius.circular(isUser ? 12 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            _SentimentChip(metadata: message.metadata),
          ],
        ),
      ),
    );
  }
}

/// Small chip showing AI sentiment label if available.
class _SentimentChip extends StatelessWidget {
  final Map<String, dynamic>? metadata;
  const _SentimentChip({this.metadata});

  @override
  Widget build(BuildContext context) {
    final sentiment = metadata?['sentiment'] as Map<String, dynamic>?;
    if (sentiment == null) return const SizedBox.shrink();
    final label = sentiment['label'] as String? ?? '';
    final color = label == 'positive'
        ? Colors.green
        : label == 'negative'
            ? Colors.red
            : Colors.grey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
