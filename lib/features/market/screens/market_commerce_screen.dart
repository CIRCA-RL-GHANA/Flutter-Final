import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thepg/core/providers/service_providers.dart';
import '../widgets/market_widgets.dart';

class MarketCommerceScreen extends ConsumerStatefulWidget {
  const MarketCommerceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketCommerceScreen> createState() =>
      _MarketCommerceScreenState();
}

class _MarketCommerceScreenState extends ConsumerState<MarketCommerceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final searchController = TextEditingController();
  String selectedCategory = 'All';

  final categories = ['All', 'Electronics', 'Fashion', 'Food', 'Books', 'Sports'];
  final products = [
    {'name': 'Wireless Earbuds', 'category': 'Electronics', 'price': 79.99, 'rating': 4.5},
    {'name': 'Summer T-Shirt', 'category': 'Fashion', 'price': 19.99, 'rating': 4.0},
    {'name': 'Organic Coffee', 'category': 'Food', 'price': 12.99, 'rating': 4.8},
    {'name': 'Flutter Guide', 'category': 'Books', 'price': 39.99, 'rating': 4.7},
    {'name': 'Yoga Mat', 'category': 'Sports', 'price': 24.99, 'rating': 4.3},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Shop'),
            Tab(text: 'Cart'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: Column(
        children: [
          Consumer<AIInsightsNotifier>(
            builder: (context, ai, _) {
              if (ai.insights.isEmpty) return const SizedBox.shrink();
              return Container(
                color: kMarketColor.withOpacity(0.07),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(children: [
                  const Icon(Icons.auto_awesome, size: 14, color: kMarketColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text('AI: ${ai.insights.first['title'] ?? ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: kMarketColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              );
            },
          ),
          Expanded(child: TabBarView(
            controller: _tabController,
        children: [
          // Shop Tab
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Category filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Products grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  Text(
                                    (product['rating'] as double).toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${(product['price'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product['name']} added to cart'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  child: const Text('Add', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Cart Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Your cart is empty'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _tabController.index = 0;
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          ),

          // Orders Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No orders yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _tabController.index = 0;
                  },
                  child: const Text('Start Shopping'),
                ),
              ],
            ),
          ),
        ],
          )),
        ],
      ),
    );
  }
}
