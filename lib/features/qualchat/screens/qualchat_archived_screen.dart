/// qualChat Screen 9 — Archived Chats
/// Archive management: search, filter/sort, preview/restore/delete, storage

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qualchat_models.dart';
import '../providers/qualchat_provider.dart';
import '../widgets/qualchat_widgets.dart';
import '../../../core/services/ai_insights_notifier.dart';

class QualChatArchivedScreen extends StatefulWidget {
  const QualChatArchivedScreen({super.key});

  @override
  State<QualChatArchivedScreen> createState() => _QualChatArchivedScreenState();
}

class _QualChatArchivedScreenState extends State<QualChatArchivedScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  ArchiveFilter _selectedFilter = ArchiveFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArchivedChat> _getFilteredChats(List<ArchivedChat> allChats) {
    var filtered = allChats;

    // Apply filter
    filtered = filtered.where((chat) {
      if (_selectedFilter == ArchiveFilter.individual) {
        return chat.conversation.type == ChatType.direct;
      } else if (_selectedFilter == ArchiveFilter.group) {
        return chat.conversation.type == ChatType.group;
      } else if (_selectedFilter == ArchiveFilter.media) {
        return chat.mediaCount > 0;
      }
      return true;
    }).toList();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((chat) {
        return chat.conversation.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            chat.conversation.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QualChatProvider>(
      builder: (context, provider, _) {
        final archived = QualChatProvider.archivedChats;
        final filteredChats = _getFilteredChats(archived);
        final totalSize = provider.totalArchivedSizeMb;

        return WillPopScope(
          onWillPop: () async {
            _searchController.clear();
            _searchQuery = '';
            setState(() {});
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FE),
            appBar: QualChatAppBar(
              title: 'Archived Chats',
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
                  onSelected: (value) {
                    if (value == 'restore_all') {
                      _restoreAllArchived(context, provider);
                    } else if (value == 'empty') {
                      _showEmptyArchiveDialog(context, provider);
                    } else if (value == 'export') {
                      _exportArchive(context);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'restore_all', child: Text('🔄 Restore All')),
                    PopupMenuItem(
                        value: 'empty', child: Text('🗑️ Empty Archive')),
                    PopupMenuItem(
                        value: 'export', child: Text('📤 Export Archive')),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                Consumer<AIInsightsNotifier>(
                  builder: (context, ai, _) {
                    if (ai.insights.isEmpty) return const SizedBox.shrink();
                    return Container(
                      color: kChatColor.withOpacity(0.07),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 14, color: kChatColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI: ${ai.insights.first['title'] ?? ''}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kChatColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Storage info bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kChatColor.withOpacity(0.08), kChatColorLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.archive, color: kChatColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${filteredChats.length} Archived Conversations',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${totalSize.toStringAsFixed(1)} MB storage used',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kChatColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${totalSize.toStringAsFixed(1)} MB',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: kChatColorDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sort & Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Sort
                      Expanded(
                        child: DropdownButtonFormField<ArchiveSort>(
                          value: provider.archiveSort,
                          decoration: InputDecoration(
                            labelText: 'Sort by',
                            labelStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: ArchiveSort.newest,
                                child: Text('Newest',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: ArchiveSort.oldest,
                                child: Text('Oldest',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: ArchiveSort.name,
                                child:
                                    Text('A-Z', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: ArchiveSort.largest,
                                child: Text('Size ↓',
                                    style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) {
                            if (v != null) provider.setArchiveSort(v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter
                      Expanded(
                        child: DropdownButtonFormField<ArchiveFilter>(
                          value: _selectedFilter,
                          decoration: InputDecoration(
                            labelText: 'Filter',
                            labelStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: ArchiveFilter.all,
                                child:
                                    Text('All', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: ArchiveFilter.individual,
                                child: Text('Individual',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: ArchiveFilter.group,
                                child: Text('Groups',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: ArchiveFilter.media,
                                child: Text('Has Media',
                                    style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _selectedFilter = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search archived chats...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Archived list
                Expanded(
                  child: filteredChats.isEmpty
                      ? const QualChatEmptyState(
                          icon: Icons.archive_outlined,
                          title: 'No archived chats',
                          message: 'Conversations you archive will appear here',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = filteredChats[index];
                            return _ArchivedChatCard(
                              chat: chat,
                              onDelete: () => _deleteChat(context, chat, provider),
                              onRestore: () => _restoreChat(context, chat, provider),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _restoreAllArchived(BuildContext context, QualChatProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore All Archived Chats'),
        content: const Text(
          'This will restore all archived conversations to your main chat list. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.restoreAllArchived();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ All chats restored')),
              );
            },
            child: const Text('Restore All',
                style: TextStyle(color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  void _showEmptyArchiveDialog(BuildContext context, QualChatProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Archive'),
        content: const Text(
          'Permanently delete all archived chats? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.emptyArchive();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Archive emptied')),
              );
            },
            child: const Text('Delete All',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _deleteChat(BuildContext context, ArchivedChat chat, QualChatProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: Text(
          'Delete "${chat.conversation.title}" permanently? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteArchivedChat(chat.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✓ ${chat.conversation.title} deleted')),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _restoreChat(BuildContext context, ArchivedChat chat, QualChatProvider provider) {
    provider.restoreArchivedChat(chat.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✓ ${chat.conversation.title} restored')),
    );
  }

  void _exportArchive(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Archive export started')),
    );
  }
}

class _ArchiveAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ArchiveAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

