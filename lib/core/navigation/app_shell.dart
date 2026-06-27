import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design/ive_tokens.dart';
import '../../core/design/ive_text.dart';
import '../../features/go/screens/go_hub_screen.dart';
import '../../features/market/screens/market_hub_screen.dart';
import '../../features/april/screens/april_dashboard_screen.dart';
import '../../genie/genie_screen.dart';

/// 4-tab shell: Home · GO · Market · APRIL
class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  static const _screens = [
    GenieScreen(),
    GoHubScreen(),
    MarketHubScreen(),
    AprilDashboardScreen(),
  ];

  static const _tabs = [
    _NavTab(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: 'Home'),
    _NavTab(icon: Icons.diamond_outlined,      activeIcon: Icons.diamond,      label: 'GO'),
    _NavTab(icon: Icons.storefront_outlined,   activeIcon: Icons.storefront,   label: 'Market'),
    _NavTab(icon: Icons.mic_none_outlined,     activeIcon: Icons.mic,          label: 'APRIL'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onTap: _onTap,
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavTab({required this.icon, required this.activeIcon, required this.label});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavTab> tabs;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.tabs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: IveTokens.surface,
        border: Border(top: BorderSide(color: IveTokens.hairline, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final active = i == currentIndex;
          return Expanded(
            child: Semantics(
              label: tab.label,
              button: true,
              selected: active,
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: active ? IveTokens.genie : IveTokens.labelTertiary,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: IveType.caption.copyWith(
                          color: active ? IveTokens.genie : IveTokens.labelTertiary,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
