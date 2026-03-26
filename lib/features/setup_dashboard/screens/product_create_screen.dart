/// ═══════════════════════════════════════════════════════════════════════════
/// SD1.1-CREATE: PRODUCT CREATE WIZARD — 7-Step Form
/// Steps: Basic Info → Pricing → Inventory → Media → Variants → SEO → Review
/// RBAC: Admin(full), BM(branch), SO(full), BSO(branch)
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ai_insights_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../prompt/providers/context_provider.dart';
import '../providers/setup_dashboard_provider.dart';
import '../widgets/shared_widgets.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  int _currentStep = 0;
  static const _stepCount = 7;
  static const _stepLabels = [
    'Basic Info',
    'Pricing',
    'Inventory',
    'Media',
    'Variants',
    'SEO',
    'Review',
  ];

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _comparePriceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _lowStockCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _metaTitleCtrl = TextEditingController();
  final _metaDescCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String _selectedCategory = 'General';
  bool _trackInventory = true;
  bool _allowBackorder = false;
  bool _isPublished = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _comparePriceCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    _lowStockCtrl.dispose();
    _barcodeCtrl.dispose();
    _metaTitleCtrl.dispose();
    _metaDescCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Product created successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SetupDashboardProvider, ContextProvider>(
      builder: (context, setupProv, ctxProv, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          appBar: SetupAppBar(
            title: 'New Product',
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
          body: Column(
            children: [
              Consumer<AIInsightsNotifier>(
                builder: (context, ai, _) {
                  if (ai.insights.isEmpty) return const SizedBox.shrink();
                  return Container(
                    color: kSetupColor.withOpacity(0.07),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: kSetupColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI: ${ai.insights.first[\'title\'] ?? \'\'}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kSetupColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Step Progress Indicator
              _StepIndicator(
                currentStep: _currentStep,
                stepCount: _stepCount,
                labels: _stepLabels,
              ),
              // Step Content
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _BasicInfoStep(
                      nameCtrl: _nameCtrl,
                      descCtrl: _descCtrl,
                      skuCtrl: _skuCtrl,
                      category: _selectedCategory,
                      onCategoryChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                    _PricingStep(
                      priceCtrl: _priceCtrl,
                      comparePriceCtrl: _comparePriceCtrl,
                      costCtrl: _costCtrl,
                    ),
                    _InventoryStep(
                      stockCtrl: _stockCtrl,
                      lowStockCtrl: _lowStockCtrl,
                      barcodeCtrl: _barcodeCtrl,
                      trackInventory: _trackInventory,
                      allowBackorder: _allowBackorder,
                      onTrackChanged: (v) => setState(() => _trackInventory = v),
                      onBackorderChanged: (v) => setState(() => _allowBackorder = v),
                    ),
                    const _MediaStep(),
                    const _VariantsStep(),
                    _SEOStep(
                      metaTitleCtrl: _metaTitleCtrl,
                      metaDescCtrl: _metaDescCtrl,
                      tagsCtrl: _tagsCtrl,
                    ),
                    _ReviewStep(
                      name: _nameCtrl.text,
                      sku: _skuCtrl.text,
                      category: _selectedCategory,
                      price: _priceCtrl.text,
                      stock: _stockCtrl.text,
                      isPublished: _isPublished,
                      onPublishedChanged: (v) => setState(() => _isPublished = v),
                    ),
                  ],
                ),
              ),
              // Bottom Nav
              _WizardNavBar(
                currentStep: _currentStep,
                stepCount: _stepCount,
                onNext: _nextStep,
                onPrev: _prevStep,
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final List<String> labels;

  const _StepIndicator({
    required this.currentStep,
    required this.stepCount,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / stepCount,
              backgroundColor: kSetupColor.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(kSetupColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 10),
          // Step label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $stepCount',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: kSetupColor,
                ),
              ),
              Text(
                labels[currentStep],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Basic Info ──────────────────────────────────────────────────────

class _BasicInfoStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController skuCtrl;
  final String category;
  final ValueChanged<String> onCategoryChanged;

  const _BasicInfoStep({
    required this.nameCtrl,
    required this.descCtrl,
    required this.skuCtrl,
    required this.category,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Product Name',
          hint: 'Enter product name',
          controller: nameCtrl,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Description',
          hint: 'Describe your product',
          controller: descCtrl,
          maxLines: 4,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'SKU',
          hint: 'Stock keeping unit',
          controller: skuCtrl,
        ),
        const SizedBox(height: 14),
        Text(
          'Category',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: category,
              items: ['General', 'Electronics', 'Food & Beverage', 'Fashion', 'Home & Garden', 'Health']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onCategoryChanged(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 2: Pricing ─────────────────────────────────────────────────────────

class _PricingStep extends StatelessWidget {
  final TextEditingController priceCtrl;
  final TextEditingController comparePriceCtrl;
  final TextEditingController costCtrl;

  const _PricingStep({
    required this.priceCtrl,
    required this.comparePriceCtrl,
    required this.costCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Selling Price (₵)',
          hint: '0.00',
          controller: priceCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Compare-at Price (₵)',
          hint: '0.00 — Show strikethrough for discounts',
          controller: comparePriceCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Cost per Item (₵)',
          hint: '0.00 — Used for margin calculations',
          controller: costCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.info),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Margin will be auto-calculated when both price and cost are provided.',
                  style: TextStyle(fontSize: 12, color: AppColors.info.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 3: Inventory ───────────────────────────────────────────────────────

class _InventoryStep extends StatelessWidget {
  final TextEditingController stockCtrl;
  final TextEditingController lowStockCtrl;
  final TextEditingController barcodeCtrl;
  final bool trackInventory;
  final bool allowBackorder;
  final ValueChanged<bool> onTrackChanged;
  final ValueChanged<bool> onBackorderChanged;

  const _InventoryStep({
    required this.stockCtrl,
    required this.lowStockCtrl,
    required this.barcodeCtrl,
    required this.trackInventory,
    required this.allowBackorder,
    required this.onTrackChanged,
    required this.onBackorderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _SwitchTile(
          title: 'Track Inventory',
          subtitle: 'Monitor stock levels for this product',
          value: trackInventory,
          onChanged: onTrackChanged,
        ),
        if (trackInventory) ...[
          const SizedBox(height: 14),
          SetupFormField(
            label: 'Initial Stock',
            hint: '0',
            controller: stockCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          SetupFormField(
            label: 'Low Stock Threshold',
            hint: '10 — Alert when stock falls below this',
            controller: lowStockCtrl,
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Barcode',
          hint: 'Scan or enter barcode',
          controller: barcodeCtrl,
        ),
        const SizedBox(height: 14),
        _SwitchTile(
          title: 'Allow Backorders',
          subtitle: 'Allow orders even when out of stock',
          value: allowBackorder,
          onChanged: onBackorderChanged,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 4: Media ───────────────────────────────────────────────────────────

class _MediaStep extends StatelessWidget {
  const _MediaStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SetupSectionTitle(title: 'Product Images', icon: Icons.image),
        const SizedBox(height: 8),
        // Upload area
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: kSetupColor.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: kSetupColor.withOpacity(0.4)),
                const SizedBox(height: 8),
                const Text(
                  'Tap to upload images',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG up to 5MB · Max 8 images',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SetupSectionTitle(title: 'Video', icon: Icons.videocam),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, size: 28, color: AppColors.textTertiary.withOpacity(0.5)),
                const SizedBox(height: 4),
                const Text(
                  'Add product video (optional)',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 5: Variants ────────────────────────────────────────────────────────

class _VariantsStep extends StatelessWidget {
  const _VariantsStep();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSetupColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSetupColor.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: kSetupColor),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Add variants if this product comes in different sizes, colors, or other options.',
                  style: TextStyle(fontSize: 12, color: kSetupColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Option types
        ...['Size', 'Color', 'Material'].map((option) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 20, color: kSetupColor),
                  const SizedBox(width: 12),
                  Text(
                    'Add $option variants',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
                ],
              ),
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 20, color: kSetupColor),
              const SizedBox(width: 12),
              const Text(
                'Custom option type...',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 6: SEO ─────────────────────────────────────────────────────────────

class _SEOStep extends StatelessWidget {
  final TextEditingController metaTitleCtrl;
  final TextEditingController metaDescCtrl;
  final TextEditingController tagsCtrl;

  const _SEOStep({
    required this.metaTitleCtrl,
    required this.metaDescCtrl,
    required this.tagsCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        SetupFormField(
          label: 'Page Title',
          hint: 'SEO-optimized product title',
          controller: metaTitleCtrl,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Meta Description',
          hint: 'Short description for search engines (max 160 chars)',
          controller: metaDescCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        SetupFormField(
          label: 'Tags',
          hint: 'Comma-separated tags (e.g., organic, fresh, dairy)',
          controller: tagsCtrl,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.search, size: 16, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'SEO Preview',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                metaTitleCtrl.text.isNotEmpty ? metaTitleCtrl.text : 'Product Name',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A0DAB)),
              ),
              const SizedBox(height: 2),
              Text(
                'yourstore.com/products/...',
                style: TextStyle(fontSize: 11, color: AppColors.success),
              ),
              const SizedBox(height: 2),
              Text(
                metaDescCtrl.text.isNotEmpty ? metaDescCtrl.text : 'Product description will appear here...',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Step 7: Review ──────────────────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  final String name;
  final String sku;
  final String category;
  final String price;
  final String stock;
  final bool isPublished;
  final ValueChanged<bool> onPublishedChanged;

  const _ReviewStep({
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.isPublished,
    required this.onPublishedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSetupColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSetupColor.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: kSetupColor),
              const SizedBox(width: 10),
              const Text(
                'Review your product details before publishing',
                style: TextStyle(fontSize: 12, color: kSetupColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SetupSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SetupSectionTitle(title: 'Product Summary', icon: Icons.inventory_2),
              SetupInfoRow(label: 'Name', value: name.isNotEmpty ? name : '—'),
              SetupInfoRow(label: 'SKU', value: sku.isNotEmpty ? sku : '—'),
              SetupInfoRow(label: 'Category', value: category),
              SetupInfoRow(label: 'Price', value: price.isNotEmpty ? '₵$price' : '—'),
              SetupInfoRow(label: 'Stock', value: stock.isNotEmpty ? stock : '—'),
            ],
          ),
        ),

        // Publish toggle
        SetupSectionCard(
          child: Row(
            children: [
              const Icon(Icons.public, size: 20, color: kSetupColor),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Publish immediately',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Make product visible to customers',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPublished,
                onChanged: onPublishedChanged,
                activeColor: kSetupColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─── Wizard Nav Bar ──────────────────────────────────────────────────────────

class _WizardNavBar extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const _WizardNavBar({
    required this.currentStep,
    required this.stepCount,
    required this.onNext,
    required this.onPrev,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentStep == 0;
    final isLast = currentStep == stepCount - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isFirst)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            if (!isFirst) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLast ? onSubmit : onNext,
                icon: Icon(isLast ? Icons.check : Icons.arrow_forward, size: 18),
                label: Text(isLast ? 'Create Product' : 'Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? AppColors.success : kSetupColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Helpers ──────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kSetupColor,
          ),
        ],
      ),
    );
  }
}
