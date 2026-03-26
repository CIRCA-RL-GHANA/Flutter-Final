/// APRIL Screen 3 — Smart Calendar
/// 5 view modes: day, week, month, agenda, year
/// Event creation, meeting scheduling, day timeline

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../models/april_models.dart';
import '../providers/april_provider.dart';
import '../widgets/april_widgets.dart';

class AprilCalendarScreen extends StatelessWidget {
  const AprilCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AprilProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AprilAppBar(
            title: '📅 Calendar',
            actions: [
              IconButton(
                icon: const Icon(Icons.today, size: 22),
                onPressed: () => provider.setSelectedDate(DateTime.now()),
              ),
              PopupMenuButton<CalendarView>(
                icon: const Icon(Icons.view_module, size: 22),
                onSelected: provider.setCalendarView,
                itemBuilder: (_) => CalendarView.values.map((v) => PopupMenuItem(
                  value: v,
                  child: Row(
                    children: [
                      Icon(
                        _viewIcon(v),
                        size: 18,
                        color: provider.calendarView == v ? kAprilColorDark : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        v.name[0].toUpperCase() + v.name.substring(1),
                        style: TextStyle(
                          fontWeight: provider.calendarView == v ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
          body: Column(
            children: [
              // View Mode Chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  children: CalendarView.values.map((v) => GestureDetector(
                    onTap: () => provider.setCalendarView(v),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: provider.calendarView == v ? kAprilColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: provider.calendarView == v ? kAprilColor : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        v.name[0].toUpperCase() + v.name.substring(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: provider.calendarView == v ? Colors.black : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),

              // AI Event Insights strip
              Consumer<AIInsightsNotifier>(
                builder: (ctx, aiNotifier, _) {
                  final insights = aiNotifier.insights;
                  if (insights.isEmpty) return const SizedBox.shrink();
                  final first = insights.first;
                  final label = first['label']?.toString() ?? first['text']?.toString() ?? '';
                  if (label.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: kAprilColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: kAprilColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 13, color: kAprilColorDark),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'AI: $label',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kAprilColorDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Calendar Body
              Expanded(
                child: _buildCalendarView(context, provider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEvent(context, provider),
            backgroundColor: kAprilColor,
            foregroundColor: Colors.black,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(BuildContext context, AprilProvider provider) {
    switch (provider.calendarView) {
      case CalendarView.day:
        return _DayView(provider: provider);
      case CalendarView.week:
        return _WeekView(provider: provider);
      case CalendarView.month:
        return _MonthView(provider: provider);
      case CalendarView.agenda:
        return _AgendaView(provider: provider);
      case CalendarView.year:
        return _YearView(provider: provider);
    }
  }

  IconData _viewIcon(CalendarView v) {
    switch (v) {
      case CalendarView.day: return Icons.view_day;
      case CalendarView.week: return Icons.view_week;
      case CalendarView.month: return Icons.calendar_month;
      case CalendarView.agenda: return Icons.view_agenda;
      case CalendarView.year: return Icons.calendar_today;
    }
  }

  void _showAddEvent(BuildContext context, AprilProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('New Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Quick add or create detailed event', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),

            // Quick Event Types
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const _EventTypeChip(emoji: '📞', label: 'Call', type: EventType.call),
                const _EventTypeChip(emoji: '🤝', label: 'Meeting', type: EventType.meeting),
                const _EventTypeChip(emoji: '🏠', label: 'Personal', type: EventType.personal),
                const _EventTypeChip(emoji: '⏰', label: 'Reminder', type: EventType.reminder),
                const _EventTypeChip(emoji: '✈️', label: 'Travel', type: EventType.travel),
                const _EventTypeChip(emoji: '🎯', label: 'Deadline', type: EventType.deadline),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Add Field
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g., "Team standup at 9am"',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.bolt, color: kAprilColorDark),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAprilColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create Event', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// DAY VIEW — Timeline
// ═══════════════════════════════════════════
class _DayView extends StatelessWidget {
  final AprilProvider provider;
  const _DayView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final events = provider.eventsForDate(provider.selectedDate);
    return Column(
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => provider.setSelectedDate(
                  provider.selectedDate.subtract(const Duration(days: 1)),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _formatDate(provider.selectedDate),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${events.length} events',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => provider.setSelectedDate(
                  provider.selectedDate.add(const Duration(days: 1)),
                ),
              ),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: events.isEmpty
              ? const AprilEmptyState(
                  icon: Icons.event_available,
                  title: 'No events today',
                  message: 'Tap + to add a new event',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: events.map((e) => CalendarEventTile(event: e)).toList(),
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

// ═══════════════════════════════════════════
// WEEK VIEW
// ═══════════════════════════════════════════
class _WeekView extends StatelessWidget {
  final AprilProvider provider;
  const _WeekView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final start = provider.selectedDate.subtract(Duration(days: provider.selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => start.add(Duration(days: i)));

    return Column(
      children: [
        // Week Day Headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: weekDays.map((d) {
              final isToday = _isSameDay(d, DateTime.now());
              final isSelected = _isSameDay(d, provider.selectedDate);
              final dayEvents = provider.eventsForDate(d);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.setSelectedDate(d);
                    provider.setCalendarView(CalendarView.day);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kAprilColor
                          : isToday
                              ? kAprilColor.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.black : null,
                          ),
                        ),
                        if (dayEvents.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : kAprilColorDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 1),

        // Selected Day Events
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _formatDate(provider.selectedDate),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...provider.eventsForDate(provider.selectedDate).map(
                (e) => CalendarEventTile(event: e),
              ),
              if (provider.eventsForDate(provider.selectedDate).isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No events this day', style: TextStyle(color: Color(0xFF6B7280))),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ═══════════════════════════════════════════
// MONTH VIEW — Calendar Grid
// ═══════════════════════════════════════════
class _MonthView extends StatelessWidget {
  final AprilProvider provider;
  const _MonthView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final sel = provider.selectedDate;
    final firstDay = DateTime(sel.year, sel.month, 1);
    final daysInMonth = DateTime(sel.year, sel.month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon

    return Column(
      children: [
        // Month Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => provider.setSelectedDate(DateTime(sel.year, sel.month - 1, 1)),
              ),
              Text(
                '${_monthName(sel.month)} ${sel.year}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => provider.setSelectedDate(DateTime(sel.year, sel.month + 1, 1)),
              ),
            ],
          ),
        ),

        // Day Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),

        // Calendar Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42,
            itemBuilder: (_, i) {
              final dayNum = i - (startWeekday - 1) + 1;
              if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();

              final date = DateTime(sel.year, sel.month, dayNum);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, sel);
              final hasEvents = provider.eventsForDate(date).isNotEmpty;

              return GestureDetector(
                onTap: () {
                  provider.setSelectedDate(date);
                  provider.setCalendarView(CalendarView.day);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kAprilColor
                        : isToday
                            ? kAprilColor.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? Colors.black : null,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : kAprilColorDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int m) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[m - 1];
  }
}

// ═══════════════════════════════════════════
// AGENDA VIEW — Scrollable Event List
// ═══════════════════════════════════════════
class _AgendaView extends StatelessWidget {
  final AprilProvider provider;
  const _AgendaView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final next7 = List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: next7.map((d) {
        final events = provider.eventsForDate(d);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isSameDay(d, today) ? kAprilColor : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _isSameDay(d, today) ? 'Today' : _formatDate(d),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isSameDay(d, today) ? Colors.black : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${events.length} events', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 12),
                child: Text('No events', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              )
            else
              ...events.map((e) => CalendarEventTile(event: e)),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

// ═══════════════════════════════════════════
// YEAR VIEW — Compact 12-Month Grid
// ═══════════════════════════════════════════
class _YearView extends StatelessWidget {
  final AprilProvider provider;
  const _YearView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final year = provider.selectedDate.year;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (_, m) {
        final month = m + 1;
        final isCurrent = month == DateTime.now().month && year == DateTime.now().year;
        return GestureDetector(
          onTap: () {
            provider.setSelectedDate(DateTime(year, month, 1));
            provider.setCalendarView(CalendarView.month);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent ? kAprilColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? kAprilColor : const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _monthName(month),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent ? kAprilColorDark : null,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _MiniMonthGrid(year: year, month: month, provider: provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}

class _MiniMonthGrid extends StatelessWidget {
  final int year, month;
  final AprilProvider provider;
  const _MiniMonthGrid({required this.year, required this.month, required this.provider});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (_, i) {
        final dayNum = i - (firstWeekday - 1) + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();
        final isToday = dayNum == DateTime.now().day &&
            month == DateTime.now().month &&
            year == DateTime.now().year;
        return Center(
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isToday ? kAprilColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$dayNum',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EventTypeChip extends StatelessWidget {
  final String emoji, label;
  final EventType type;
  const _EventTypeChip({required this.emoji, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kAprilColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kAprilColor.withOpacity(0.2)),
      ),
      child: Text('$emoji $label', style: const TextStyle(fontSize: 13)),
    );
  }
}
