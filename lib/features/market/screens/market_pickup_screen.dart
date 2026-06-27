/// 
/// MARKET MODULE  Screen 8: Self-Pickup Process
/// 5 Phases: Preparation ' Arrival ' Verification ' Handoff ' Complete
/// 
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/design/ive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/market_models.dart';
import '../providers/market_provider.dart';
import '../widgets/market_widgets.dart';

class MarketPickupScreen extends StatefulWidget {
  const MarketPickupScreen({super.key});

  @override
  State<MarketPickupScreen> createState() => _MarketPickupScreenState();
}

class _MarketPickupScreenState extends State<MarketPickupScreen> {
  PickupPhase _phase = PickupPhase.preparation;

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, prov, _) {
        final order = prov.selectedOrder;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Self-Pickup')),
            body: const MarketEmptyState(
              icon: Icons.store,
              title: 'No order selected',
              subtitle: 'Go back and select an order',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const MarketAppBar(title: 'Self-Pickup'),
          body: Column(
            children: [

              // Phase progress
              _buildPhaseProgress(),
              // Phase content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPhaseContent(order, prov),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomAction(context, order),
        );
      },
    );
  }

  Widget _buildPhaseProgress() {
    const phases = PickupPhase.values;
    final currentIdx = phases.indexOf(_phase);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: IveTokens.surface,
      child: Column(
        children: [
          Row(
            children: List.generate(phases.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIdx = i ~/ 2;
                return Expanded(
                  child: Container(
                    height: 3,
                    color: stepIdx < currentIdx ? IveTokens.moduleMarket : IveTokens.hairline2,
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final isDone = stepIdx < currentIdx;
              final isCurrent = stepIdx == currentIdx;
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? IveTokens.moduleMarket
                      : isCurrent
                          ? IveTokens.moduleMarket.withValues(alpha: 0.15)
                          : IveTokens.surface,
                  border: Border.all(
                    color: isDone || isCurrent ? IveTokens.moduleMarket : IveTokens.hairline2,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCurrent ? IveTokens.moduleMarket : IveTokens.mute,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _phaseTitle(_phase),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent(MarketOrder order, MarketProvider prov) {
    switch (_phase) {
      case PickupPhase.preparation:
        return _PreparationPhase(order: order);
      case PickupPhase.arrival:
        return _ArrivalPhase(order: order);
      case PickupPhase.verification:
        return _VerificationPhase(order: order);
      case PickupPhase.handoff:
        return _HandoffPhase(order: order);
      case PickupPhase.complete:
        return _CompletePhase(order: order);
    }
  }

  Widget _buildBottomAction(BuildContext context, MarketOrder order) {
    final isLast = _phase == PickupPhase.complete;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      color: IveTokens.surface,
      child: Row(
        children: [
          if (_phase != PickupPhase.preparation && !isLast)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  const phases = PickupPhase.values;
                  final idx = phases.indexOf(_phase);
                  if (idx > 0) setState(() => _phase = phases[idx - 1]);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: IveTokens.moduleMarket,
                  side: const BorderSide(color: IveTokens.moduleMarket),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_phase != PickupPhase.preparation && !isLast)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (isLast) {
                  Navigator.pop(context);
                } else {
                  const phases = PickupPhase.values;
                  final idx = phases.indexOf(_phase);
                  setState(() => _phase = phases[idx + 1]);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: IveTokens.moduleMarket,
                foregroundColor: IveTokens.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                isLast ? 'Done' : _nextButtonText(_phase),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _phaseTitle(PickupPhase phase) {
    switch (phase) {
      case PickupPhase.preparation:
        return 'Order Preparation';
      case PickupPhase.arrival:
        return 'Arrival Confirmation';
      case PickupPhase.verification:
        return 'Identity Verification';
      case PickupPhase.handoff:
        return 'Order Handoff';
      case PickupPhase.complete:
        return 'Pickup Complete';
    }
  }

  String _nextButtonText(PickupPhase phase) {
    switch (phase) {
      case PickupPhase.preparation:
        return 'I\'m on my way';
      case PickupPhase.arrival:
        return 'I\'ve arrived';
      case PickupPhase.verification:
        return 'Verify identity';
      case PickupPhase.handoff:
        return 'Confirm received';
      case PickupPhase.complete:
        return 'Done';
    }
  }
}

//  Phase 1: Preparation 
class _PreparationPhase extends StatelessWidget {
  final MarketOrder order;

  const _PreparationPhase({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kMarketColorLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            children: [
              Icon(Icons.restaurant, size: 48, color: kMarketColor),
              SizedBox(height: 12),
              Text(
                'Your order is being prepared',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Estimated ready in 15-20 minutes',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Order details
        MarketSectionCard(
          title: 'Order Items',
          children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w600, color: kMarketColor)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14))),
                    Text('\$${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
        ),
        const SizedBox(height: 12),
        // Merchant location
        MarketSectionCard(
          title: 'Pickup Location',
          children: [
              MarketInfoRow(icon: Icons.store, label: 'Merchant', value: order.merchantName),
              MarketInfoRow(icon: Icons.location_on, label: 'Address', value: order.deliveryAddress ?? 'N/A'),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: IveTokens.accentSoft,
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                ),
                child: Center(
                  child: Icon(Icons.map, size: 40, color: IveTokens.mute),
                ),
              ),
            ],
        ),
      ],
    );
  }
}

//  Phase 2: Arrival 
class _ArrivalPhase extends StatelessWidget {
  final MarketOrder order;

  const _ArrivalPhase({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: IveTokens.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(IveTokens.rSm),
          ),
          child: const Column(
            children: [
              Icon(Icons.directions_walk, size: 48, color: AppColors.warning),
              SizedBox(height: 12),
              Text(
                'Head to the pickup point',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Let the merchant know when you arrive',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Navigation card
        MarketSectionCard(
          title: 'Directions',
          children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: IveTokens.accentSoft,
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation, size: 40, color: IveTokens.info),
                      const SizedBox(height: 8),
                      Text('Navigation Map', style: TextStyle(color: IveTokens.mute)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening navigation...')),
                        );
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IveTokens.info,
                        foregroundColor: IveTokens.ink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calling...')),
                        );
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: IveTokens.moduleMarket,
                        side: const BorderSide(color: IveTokens.moduleMarket),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(IveTokens.rSm)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
        ),
      ],
    );
  }
}

//  Phase 3: Verification 
class _VerificationPhase extends StatelessWidget {
  final MarketOrder order;

  const _VerificationPhase({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: IveTokens.accentSoft,
            borderRadius: BorderRadius.circular(IveTokens.rSm),
          ),
          child: Column(
            children: [
              Icon(Icons.qr_code, size: 64, color: IveTokens.accent),
              const SizedBox(height: 12),
              const Text(
                'Show this code to the merchant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              // QR/PIN display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: IveTokens.surface,
                  borderRadius: BorderRadius.circular(IveTokens.rSm),
                  border: Border.all(color: IveTokens.accent, width: 2),
                ),
                child: Text(
                  order.pickupCode ?? '${order.id.substring(0, 4).toUpperCase()}-${order.id.substring(4, 8).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: IveTokens.accent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Valid for this pickup only',
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const MarketSectionCard(
          title: 'Verification Steps',
          children: [
              _VerificationStep(step: 1, text: 'Show the pickup code to the merchant', isDone: true),
              _VerificationStep(step: 2, text: 'Merchant scans or enters your code', isDone: false),
              _VerificationStep(step: 3, text: 'Verify your items are correct', isDone: false),
            ],
        ),
      ],
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final int step;
  final String text;
  final bool isDone;

  const _VerificationStep({required this.step, required this.text, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? kMarketColor : AppColors.backgroundLight,
              border: Border.all(color: isDone ? kMarketColor : AppColors.inputBorder),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$step',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

//  Phase 4: Handoff 
class _HandoffPhase extends StatefulWidget {
  final MarketOrder order;

  const _HandoffPhase({required this.order});

  @override
  State<_HandoffPhase> createState() => _HandoffPhaseState();
}

class _HandoffPhaseState extends State<_HandoffPhase> {
  late final Set<String> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = {};
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kMarketColorLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            children: [
              Icon(Icons.handshake, size: 48, color: kMarketColor),
              SizedBox(height: 12),
              Text(
                'Verify your order items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Check each item before confirming receipt',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MarketSectionCard(
          title: 'Items Checklist',
          children: widget.order.items.map((item) {
              final itemKey = '${item.name}_${item.quantity}';
              // ignore: deprecated_member_use
              return CheckboxListTile(
                value: _checkedItems.contains(itemKey),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _checkedItems.add(itemKey);
                  } else {
                    _checkedItems.remove(itemKey);
                  }
                }),
                title: Text('${item.quantity}x ${item.name}', style: const TextStyle(fontSize: 14)),
                activeColor: kMarketColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
        ),
        const SizedBox(height: 12),
        // Report issue
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          color: AppColors.error.withValues(alpha: 0.05),
          child: ListTile(
            leading: const Icon(Icons.report_problem, color: AppColors.error),
            title: const Text('Report an issue', style: TextStyle(fontSize: 14)),
            subtitle: const Text('Missing or wrong items?', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.error),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.utilityHelp);
            },
          ),
        ),
      ],
    );
  }
}

//  Phase 5: Complete 
class _CompletePhase extends StatelessWidget {
  final MarketOrder order;

  const _CompletePhase({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: kMarketColorLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 60, color: kMarketColor),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pickup Complete!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Enjoy your order from ${order.merchantName}',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Rate experience
        MarketSectionCard(
          title: 'Rate your experience',
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < 4 ? Icons.star : Icons.star_border,
                      size: 40,
                      color: i < 4 ? AppColors.accent : AppColors.textTertiary,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Leave a review (optional)',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kMarketColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
        ),
        const SizedBox(height: 16),
        // QP earned
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IveTokens.rSm),
            gradient: LinearGradient(
              colors: [IveTokens.accent, IveTokens.accentPressed],
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.stars, size: 32, color: IveTokens.ink),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+25 QP Earned',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: IveTokens.ink),
                  ),
                  Text(
                    'From this pickup order',
                    style: TextStyle(fontSize: 12, color: IveTokens.ink.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
