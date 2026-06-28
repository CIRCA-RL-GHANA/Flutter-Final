library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design/ive.dart';
import '../../../core/routes/app_routes.dart';

class GoContextScreen extends StatelessWidget {
  const GoContextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.chevron_left_rounded, size: 24, color: IveTokens.ink2),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GO · FINANCIAL',
                        style: IveType.caption.copyWith(
                          color: IveTokens.mute,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('Choose context', style: IveType.title3),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total net worth card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: IveTokens.surface,
                      borderRadius: BorderRadius.circular(IveTokens.rContainer),
                      border: Border.all(color: IveTokens.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL NET WORTH · ALL CONTEXTS',
                          style: IveType.caption.copyWith(
                            color: IveTokens.mute,
                            letterSpacing: 0.7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₵ 48,320',
                          style: IveType.title1.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+ ₵ 1,240 this week',
                          style: IveType.footnote.copyWith(color: IveTokens.success),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'YOUR CONTEXTS',
                    style: IveType.caption.copyWith(
                      color: IveTokens.mute,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _ContextCard(
                    type: 'PERSONAL',
                    typeColor: IveTokens.accent,
                    name: 'Kwame Mensah',
                    netWorth: '₵ 12,840',
                    isActive: true,
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.goHub),
                  ),
                  const SizedBox(height: 10),
                  _ContextCard(
                    type: 'BUSINESS',
                    typeColor: IveTokens.success,
                    name: 'Mensah Trading Co.',
                    netWorth: '₵ 31,200',
                    isActive: false,
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.goHub),
                  ),
                  const SizedBox(height: 10),
                  _ContextCard(
                    type: 'BRANCH',
                    typeColor: const Color(0xFF8B5CF6),
                    name: 'Osu Retail Hub',
                    netWorth: '₵ 4,280',
                    isActive: false,
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.goHub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.type,
    required this.typeColor,
    required this.name,
    required this.netWorth,
    required this.isActive,
    required this.onTap,
  });

  final String type;
  final Color typeColor;
  final String name;
  final String netWorth;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: IveTokens.surface,
          borderRadius: BorderRadius.circular(IveTokens.rContainer),
          border: Border.all(
            color: isActive ? IveTokens.accent : IveTokens.hairline,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (isActive)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: IveTokens.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ACTIVE',
                        style: IveType.caption.copyWith(
                          color: IveTokens.success,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Switch  ›',
                    style: IveType.caption.copyWith(color: IveTokens.mute),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(name, style: IveType.headline),
            const SizedBox(height: 3),
            Text(
              'Net worth · $netWorth',
              style: IveType.footnote.copyWith(color: IveTokens.mute),
            ),
          ],
        ),
      ),
    );
  }
}
