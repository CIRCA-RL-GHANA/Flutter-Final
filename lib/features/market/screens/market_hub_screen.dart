import 'package:flutter/material.dart';
import '../../../core/design/ive_tokens.dart';
import '../../../core/design/ive_text.dart';
import '../../../core/design/genie_strip.dart';

class MarketHubScreen extends StatefulWidget {
  const MarketHubScreen({super.key});

  @override
  State<MarketHubScreen> createState() => _MarketHubScreenState();
}

class _MarketHubScreenState extends State<MarketHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IveTokens.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: IveTokens.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: IveTokens.s5),
              Text('Market', style: IveType.title1),
              const SizedBox(height: IveTokens.s4),
              _SearchBar(),
              const SizedBox(height: IveTokens.s4),
              _FeaturedBanner(),
              const SizedBox(height: IveTokens.s4),
              GenieStrip(
                message: 'These three pair well — bundle and save 8%.',
              ),
              const SizedBox(height: IveTokens.s4),
              _ProductGrid(),
              const SizedBox(height: IveTokens.s4),
              _TrackDeliveryButton(),
              const SizedBox(height: IveTokens.s8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: IveTokens.s3),
          const Icon(Icons.search_rounded, color: IveTokens.mute, size: 18),
          const SizedBox(width: IveTokens.s2),
          Text(
            'Search Makola, Osu, anywhere',
            style: IveType.callout.copyWith(color: IveTokens.mute),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            left: IveTokens.s4,
            bottom: IveTokens.s4,
            child: Text(
              'FEATURED · FRESH FROM MAKOLA',
              style: IveType.monoCaps,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  static const _products = [
    _Product(category: 'TEXTILE', name: 'Kente tote', price: '120', cents: '.00'),
    _Product(category: 'BEAUTY', name: 'Shea butter', price: '35', cents: '.00'),
    _Product(category: 'KITCHEN', name: 'Jollof kit', price: '60', cents: '.00'),
    _Product(category: 'SNACK', name: 'Cocoa bar', price: '18', cents: '.00'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: IveTokens.s3,
      mainAxisSpacing: IveTokens.s3,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _products.map((p) => _ProductCard(product: p)).toList(),
    );
  }
}

class _Product {
  const _Product({
    required this.category,
    required this.name,
    required this.price,
    required this.cents,
  });

  final String category;
  final String name;
  final String price;
  final String cents;
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final _Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(IveTokens.s3),
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.category, style: IveType.monoCaps),
          const SizedBox(height: IveTokens.s1),
          Text(
            product.name,
            style: IveType.callout.copyWith(
              color: IveTokens.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₵${product.price}',
                style: IveType.headline.copyWith(color: IveTokens.ink),
              ),
              Text(
                product.cents,
                style: IveType.footnote.copyWith(color: IveTokens.ink2),
              ),
            ],
          ),
          const SizedBox(height: IveTokens.s2),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: IveTokens.s3,
                vertical: IveTokens.s1,
              ),
              decoration: BoxDecoration(
                color: IveTokens.info,
                borderRadius: BorderRadius.circular(IveTokens.rPill),
              ),
              child: Text(
                'Add',
                style: IveType.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackDeliveryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: IveTokens.surface,
        borderRadius: BorderRadius.circular(IveTokens.rContainer),
        border: Border.all(color: IveTokens.hairline, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Track your delivery',
            style: IveType.callout.copyWith(color: IveTokens.ink),
          ),
          const SizedBox(width: IveTokens.s2),
          const Icon(
            Icons.arrow_forward_rounded,
            color: IveTokens.ink,
            size: 16,
          ),
        ],
      ),
    );
  }
}
