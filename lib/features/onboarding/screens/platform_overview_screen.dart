import 'package:flutter/material.dart';
import '../../../core/design/ive.dart';
import '../../../core/utils/responsive.dart';

/// Platform Overview Screen
///
/// Long-form, role-by-role explanation of what genie help is, who it serves,
/// and what it unlocks for each kind of user. Linked from the Welcome screen
/// so prospective users can understand the platform before signing up  without
/// cluttering the OS-style landing.
///
/// Visual contract: identical to the rest of onboarding 
///   bg     #08080F   surface #0E0E1A   border #1C1C2E
///   accent #22BDD8   text    #E8E8F0   dim    #6B6B88
class PlatformOverviewScreen extends StatelessWidget {
  const PlatformOverviewScreen({super.key});

  //  OS palette (mirrors splash/welcome) 
  static const Color _kBg        = IveTokens.bg;
  static const Color _kSurface   = IveTokens.surface;
  static const Color _kBorder    = IveTokens.hairline;
  static const Color _kAccent    = IveTokens.accent;
  static const Color _kText      = IveTokens.ink;
  static const Color _kTextDim   = IveTokens.ink2;
  static const Color _kTextMuted = IveTokens.mute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Responsive.constrained(
          child: CustomScrollView(
            slivers: [
              //  App bar 
              SliverAppBar(
                backgroundColor: _kBg,
                elevation: 0,
                pinned: true,
                centerTitle: false,
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: _kText, size: 20),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: _kAccent.withValues(alpha: 0.30)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PLATFORM OVERVIEW',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _kAccent.withValues(alpha: 0.90),
                          letterSpacing: 2.2,
                        ),
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: _kBorder),
                ),
              ),

              //  Body 
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    // Hero
                    const Text(
                      'genie help',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The global operating system for commerce.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _kTextDim,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _Paragraph(
                      'Welcome. Before you begin, here\'s what genie help means for '
                      'you  depending on who you are and what you want to do.',
                    ),

                    //  For Everyone 
                    const SizedBox(height: 28),
                    const _SectionHeader(label: 'FOR EVERYONE', step: '01'),
                    const SizedBox(height: 12),
                    const _Paragraph(
                      'genie help is a single, unified operating system that '
                      'replaces the many separate apps people use for payments, '
                      'shopping, ride-hailing, messaging, planning, and business '
                      'operations. It is not a marketplace where you pay '
                      'commissions; it is the infrastructure on which commerce '
                      'and daily life run  all from one account, one identity, '
                      'and one intelligent assistant (Genie AI).',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Once you join, you\'ll have access to modules like:',
                      style: TextStyle(
                          fontSize: 13, color: _kTextDim, height: 1.55),
                    ),
                    const SizedBox(height: 12),
                    const _ModuleList(items: [
                      _ModuleEntry('GO Wallet',
                          'Your personal digital wallet.'),
                      _ModuleEntry('Market',
                          'Browse and shop from local businesses.'),
                      _ModuleEntry('Live',
                          'Book rides and manage deliveries.'),
                      _ModuleEntry('QualChat',
                          'Messaging and business chat in one place.'),
                      _ModuleEntry('APRIL',
                          'AI-powered financial planning and daily assistant.'),
                      _ModuleEntry('Updates',
                          'Discover what\'s new and share your own moments.'),
                      _ModuleEntry('Enterprise',
                          'Tools for large organisations.'),
                      _ModuleEntry('Fintech',
                          'Access loans, deposits, and insurance from licensed institutions.'),
                    ]),
                    const SizedBox(height: 14),
                    const _Paragraph(
                      'Everything is available from a single home screen. And '
                      'Genie AI is present on every screen, offering insights, '
                      'forecasts, and fraud protection.',
                    ),

                    //  Role by Role 
                    const SizedBox(height: 32),
                    const _SectionHeader(label: 'ROLE BY ROLE', step: '02'),
                    const SizedBox(height: 6),
                    const Text(
                      'What genie help does for you, depending on who you are.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kTextMuted,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),
                    const _RoleCard(
                      code: 'IND',
                      title: 'Individual Owner',
                      subtitle: 'The role you get when you create a personal account.',
                      bullets: [
                        _Bullet('Unified digital wallet',
                            'Send and receive money instantly, pay for purchases, and track every transaction in one place. No more switching between mobile money apps.'),
                        _Bullet('Personalised shopping',
                            'Browse thousands of products from shops around you. Food, fashion, electronics  a few taps away.'),
                        _Bullet('Ride-hailing built in',
                            'Request a ride, track your driver in real time, and pay automatically from your wallet on arrival.'),
                        _Bullet('Social discovery',
                            'Follow your favourite businesses, see what\'s new in your area, and share recommendations.'),
                        _Bullet('Private messaging',
                            'Chat with friends and businesses without mixing commerce and personal messages; transaction history appears inside the conversation.'),
                        _Bullet('AI financial assistant (APRIL)',
                            'Let Genie help you budget, plan savings goals, track spending, and draft personal financial statements.'),
                        _Bullet('Become an entrepreneur',
                            'Turn your account into a business in minutes. Your first month is free.'),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const _RoleCard(
                      code: 'BIZ',
                      title: 'Business Staff Roles',
                      subtitle: 'When added to a business entity, you are assigned one of these roles by the business owner.',
                      groups: [
                        _RoleGroup(
                          name: 'Business Administrator',
                          bullets: [
                            _Bullet('Digital storefront',
                                'Full control over the business\'s digital presence: add products, set prices, manage inventory.'),
                            _Bullet('People operations',
                                'Manage staff: assign roles, schedule shifts, and track performance.'),
                            _Bullet('Network operations',
                                'Oversee branches, delivery zones, and vehicles.'),
                            _Bullet('Marketing',
                                'Create campaigns, schedule social posts, and view engagement analytics.'),
                            _Bullet('Financial reporting',
                                'Access detailed business financial reports and export transaction histories.'),
                          ],
                        ),
                        _RoleGroup(
                          name: 'Social Officer / Branch Social Officer',
                          bullets: [
                            _Bullet('Content',
                                'Create and publish posts on the business\'s social feed (Updates).'),
                            _Bullet('Campaigns',
                                'Run marketing campaigns across email, SMS, and in-app notifications.'),
                            _Bullet('Insight',
                                'Monitor engagement metrics and see what content performs best.'),
                            _Bullet('Audience',
                                'Manage the business\'s connections and topic interests.'),
                            _Bullet('Scope',
                                'Branch Social Officers can do all of this, but only for their assigned branch.'),
                          ],
                        ),
                        _RoleGroup(
                          name: 'Response Officer / Branch Response Officer',
                          bullets: [
                            _Bullet('Live operations',
                                'Handle incoming orders, returns, and package dispatch.'),
                            _Bullet('Driver coordination',
                                'Assign delivery drivers, track orders in real time, and update statuses.'),
                            _Bullet('Returns review',
                                'Approve or reject return requests and schedule return pickups.'),
                            _Bullet('Fulfilment',
                                'Create delivery packages, configure security verification, and monitor the fulfilment queue.'),
                            _Bullet('Analytics',
                                'Access operational analytics to improve delivery times and customer satisfaction.'),
                          ],
                        ),
                        _RoleGroup(
                          name: 'Monitor / Branch Monitor',
                          bullets: [
                            _Bullet('Read-only',
                                'View products, orders, staff lists, and branch performance without being able to make changes.'),
                            _Bullet('Audit-friendly',
                                'Ideal for auditors, supervisors, and compliance officers.'),
                            _Bullet('Scope',
                                'Branch Monitors see data scoped only to their branch.'),
                          ],
                        ),
                        _RoleGroup(
                          name: 'Branch Manager',
                          bullets: [
                            _Bullet('Branch authority',
                                'Full operational authority within a specific branch (store, warehouse, or depot).'),
                            _Bullet('Branch entities',
                                'Manage branch products, vehicles, staff, delivery zones, and customer accounts.'),
                            _Bullet('Local marketing',
                                'Run branch-level campaigns and social content.'),
                            _Bullet('Local operations',
                                'Oversee branch drivers and their performance, assign orders, monitor live ops.'),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const _RoleCard(
                      code: 'DRV',
                      title: 'Drivers',
                      subtitle: 'Drivers can be part of a shop\'s logistics team or a transport provider.',
                      groups: [
                        _RoleGroup(
                          name: 'Driver (Shop / Logistics)',
                          bullets: [
                            _Bullet('Assignments',
                                'Receive delivery assignments directly on your phone.'),
                            _Bullet('Routing',
                                'View package details, pickup and drop-off locations, and customer instructions.'),
                            _Bullet('Verification',
                                'Verify deliveries with PIN, photo, and signature collection.'),
                            _Bullet('Returns & transfers',
                                'Perform return pickups and multi-hop transfers between drivers.'),
                            _Bullet('Safety',
                                'Trigger an emergency SOS with location sharing if you ever feel unsafe.'),
                            _Bullet('Performance',
                                'Track your daily earnings, completed deliveries, and customer ratings.'),
                          ],
                        ),
                        _RoleGroup(
                          name: 'Driver (Transport)',
                          bullets: [
                            _Bullet('Ride requests',
                                'Accept ride requests and navigate to passengers.'),
                            _Bullet('Transparent fares',
                                'See fare estimates, pickup, and drop-off details before accepting.'),
                            _Bullet('Trip ops',
                                'Run trips with passenger identity verification and real-time route tracking.'),
                            _Bullet('Earnings',
                                'View your earnings per trip, daily totals, and performance stats.'),
                            _Bullet('Safety',
                                'Same emergency SOS and incident reporting as logistics drivers.'),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const _RoleCard(
                      code: 'ENT',
                      title: 'Enterprise Client',
                      subtitle: 'For large organisations that need a unified commerce infrastructure across many channels.',
                      bullets: [
                        _Bullet('Verified entity',
                            'Create a verified enterprise entity with multi-branch support.'),
                        _Bullet('API keys',
                            'Generate and manage keys to connect your e-commerce, POS, and ERP directly to genie help.'),
                        _Bullet('Unified orders',
                            'Aggregate orders from website, app, and physical stores into one fulfilment pipeline.'),
                        _Bullet('Logistics console',
                            'Manage warehousing, pick-pack-ship, and third-party logistics from one console.'),
                        _Bullet('AI Concierge',
                            'Automate customer service, order routing, and inventory replenishment.'),
                        _Bullet('Webhooks',
                            'Subscribe to real-time events on orders, payments, and deliveries.'),
                        _Bullet('Data ownership',
                            'Keep full ownership of your data; export everything at any time.'),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const _RoleCard(
                      code: 'FI',
                      title: 'Financial Institution Partner',
                      subtitle: 'For licensed banks, micro-finance institutions, and insurers offering products inside the genie help ecosystem.',
                      bullets: [
                        _Bullet('Loan origination',
                            'Manage loans inside the platform  set terms, approve applications, disburse funds.'),
                        _Bullet('Deposits',
                            'Customers can open savings or fixed deposits from their wallet.'),
                        _Bullet('Insurance',
                            'Offer motor, health, inventory, life and other policies with premium collection through the wallet.'),
                        _Bullet('Credit insights',
                            'Access credit history and scores built from a customer\'s full commerce activity (with consent).'),
                        _Bullet('Role granularity',
                            'Separate access levels for loan officers, tellers, and auditors.'),
                      ],
                    ),

                    //  Genie 
                    const SizedBox(height: 32),
                    const _SectionHeader(label: 'GENIE AI', step: '03'),
                    const SizedBox(height: 12),
                    const _Paragraph(
                      'No matter your role, Genie is always available. Tap the '
                      'sparkle icon on any screen to ask questions, get '
                      'recommendations, or automate tasks. Genie can:',
                    ),
                    const SizedBox(height: 12),
                    const _BulletList(items: [
                      _Bullet('Transactions',
                          'Explain your transactions and financial patterns.'),
                      _Bullet('Pricing',
                          'Suggest optimal pricing for your products.'),
                      _Bullet('Security',
                          'Flag unusual activity for security.'),
                      _Bullet('Inventory',
                          'Predict when you\'ll need to restock.'),
                      _Bullet('Threads',
                          'Summarise long chat threads.'),
                      _Bullet('Goals',
                          'Help you set savings goals and track progress.'),
                    ]),
                    const SizedBox(height: 14),
                    const _Paragraph(
                      'Genie works offline too  actions are queued and synced '
                      'when you reconnect.',
                    ),

                    //  Differentiators 
                    const SizedBox(height: 32),
                    const _SectionHeader(
                        label: 'WHAT MAKES IT DIFFERENT', step: '04'),
                    const SizedBox(height: 12),
                    const _BulletList(items: [
                      _Bullet('One place',
                          'No need for separate apps for money, shopping, transport, and chat.'),
                      _Bullet('You own your data',
                          'Whether individual or business, your information and customer relationships belong to you.'),
                      _Bullet('No sales commissions',
                          'Businesses keep 100% of what they earn.'),
                      _Bullet('AI from day one',
                          'Intelligence is built into every screen, not added as an afterthought.'),
                      _Bullet('Works offline',
                          'Core functions are available even on poor networks; everything syncs automatically.'),
                      _Bullet('Built for scale',
                          'Single user or multi-branch enterprise  the same robust platform.'),
                    ]),

                    //  Ready 
                    const SizedBox(height: 32),
                    const _SectionHeader(label: 'READY TO BEGIN', step: '05'),
                    const SizedBox(height: 12),
                    const _Paragraph(
                      'Tap GET STARTED to enter your phone number and set up '
                      'your account. The entire process takes only a few '
                      'minutes, and you\'ll have the full operating system at '
                      'your fingertips.',
                    ),

                    const SizedBox(height: 28),
                    Container(height: 1, color: _kBorder),
                    const SizedBox(height: 18),
                    const Text(
                      'Welcome to the future of commerce.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kTextDim,
                        letterSpacing: 0.3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'genie help  The Global Operating System for Commerce.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'HUMNX LIMITED    Accra, Ghana',
                      style: TextStyle(
                        fontSize: 10,
                        color: _kTextMuted,
                        letterSpacing: 2.0,
                      ),
                    ),

                    //  Back to Welcome 
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        button: true,
                        label: 'Back to welcome screen.',
                        child: TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            backgroundColor: _kSurface,
                            foregroundColor: _kAccent,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                  color: _kAccent.withValues(alpha: 0.35)),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          ),
                          child: const Text('BACK TO WELCOME'),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//  Building blocks 

class _SectionHeader extends StatelessWidget {
  final String label;
  final String step;
  const _SectionHeader({required this.label, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          step,
          style: TextStyle(
            fontSize: 11,
            color: PlatformOverviewScreen._kAccent.withValues(alpha: 0.90),
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 16,
          height: 1,
          color: PlatformOverviewScreen._kAccent.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PlatformOverviewScreen._kText,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        color: PlatformOverviewScreen._kText,
        height: 1.6,
      ),
    );
  }
}

class _ModuleEntry {
  final String name;
  final String desc;
  const _ModuleEntry(this.name, this.desc);
}

class _ModuleList extends StatelessWidget {
  final List<_ModuleEntry> items;
  const _ModuleList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PlatformOverviewScreen._kSurface,
        border:
            Border.all(color: PlatformOverviewScreen._kBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                color: PlatformOverviewScreen._kBorder,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 7, right: 10),
                  decoration: BoxDecoration(
                    color: PlatformOverviewScreen._kAccent
                        .withValues(alpha: 0.70),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: PlatformOverviewScreen._kText,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: items[i].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '    ${items[i].desc}',
                          style: const TextStyle(
                            color: PlatformOverviewScreen._kTextDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullet {
  final String heading;
  final String body;
  const _Bullet(this.heading, this.body);
}

class _BulletList extends StatelessWidget {
  final List<_Bullet> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 10),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: PlatformOverviewScreen._kAccent
                          .withValues(alpha: 0.70)),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: PlatformOverviewScreen._kText,
                      height: 1.55,
                    ),
                    children: [
                      TextSpan(
                        text: '${items[i].heading}  ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: items[i].body,
                        style: const TextStyle(
                          color: PlatformOverviewScreen._kTextDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RoleGroup {
  final String name;
  final List<_Bullet> bullets;
  const _RoleGroup({required this.name, required this.bullets});
}

class _RoleCard extends StatelessWidget {
  final String code;
  final String title;
  final String subtitle;
  final List<_Bullet>? bullets;
  final List<_RoleGroup>? groups;
  const _RoleCard({
    required this.code,
    required this.title,
    required this.subtitle,
    this.bullets,
    this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: PlatformOverviewScreen._kSurface,
        border:
            Border.all(color: PlatformOverviewScreen._kBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: PlatformOverviewScreen._kAccent
                          .withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: PlatformOverviewScreen._kAccent
                        .withValues(alpha: 0.95),
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: PlatformOverviewScreen._kText,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PlatformOverviewScreen._kTextDim,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(
              height: 1, color: PlatformOverviewScreen._kBorder),
          const SizedBox(height: 14),

          if (bullets != null) _BulletList(items: bullets!),

          if (groups != null)
            for (int i = 0; i < groups!.length; i++) ...[
              if (i > 0) const SizedBox(height: 18),
              Text(
                groups![i].name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: PlatformOverviewScreen._kAccent
                      .withValues(alpha: 0.95),
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              _BulletList(items: groups![i].bullets),
            ],
        ],
      ),
    );
  }
}
