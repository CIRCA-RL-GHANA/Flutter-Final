import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final double rating;
  final int reviews;
  final String image;
  final int stock;
  final String vendorId;
  final String vendorName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.image,
    required this.stock,
    required this.vendorId,
    required this.vendorName,
  });
}

class MarketProvider extends ChangeNotifier {
  List<Product> allProducts = [];
  List<Product> displayProducts = [];
  bool isLoading = false;
  String? error;
  int currentPage = 0;
  String selectedCategory = 'All';
  double minPrice = 0;
  double maxPrice = 10000;

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      allProducts = _generateMockProducts();
      _applyFilters();
    } catch (e) {
      error = 'Failed to load products: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  List<Product> _generateMockProducts() {
    return [
      Product(
        id: 'prod_1',
        name: 'Wireless Headphones',
        description: 'Premium noise-cancelling headphones',
        price: 299.99,
        category: 'Electronics',
        rating: 4.8,
        reviews: 245,
        image: 'assets/headphones.png',
        stock: 15,
        vendorId: 'vendor_1',
        vendorName: 'TechStore',
      ),
      Product(
        id: 'prod_2',
        name: 'Laptop Stand',
        description: 'Adjustable aluminum laptop stand',
        price: 49.99,
        category: 'Accessories',
        rating: 4.5,
        reviews: 128,
        image: 'assets/stand.png',
        stock: 32,
        vendorId: 'vendor_2',
        vendorName: 'OfficeGear',
      ),
      Product(
        id: 'prod_3',
        name: 'USB-C Cable',
        description: 'Fast charging USB-C cable 2m',
        price: 15.99,
        category: 'Cables',
        rating: 4.6,
        reviews: 542,
        image: 'assets/cable.png',
        stock: 100,
        vendorId: 'vendor_1',
        vendorName: 'TechStore',
      ),
      Product(
        id: 'prod_4',
        name: 'Mechanical Keyboard',
        description: 'RGB Mechanical Gaming Keyboard',
        price: 129.99,
        category: 'Electronics',
        rating: 4.7,
        reviews: 189,
        image: 'assets/keyboard.png',
        stock: 8,
        vendorId: 'vendor_3',
        vendorName: 'GamingHub',
      ),
      Product(
        id: 'prod_5',
        name: 'Phone Case',
        description: 'Protective silicone phone case',
        price: 19.99,
        category: 'Accessories',
        rating: 4.4,
        reviews: 312,
        image: 'assets/case.png',
        stock: 45,
        vendorId: 'vendor_4',
        vendorName: 'PhoneGuard',
      ),
    ];
  }

  void setCategory(String category) {
    selectedCategory = category;
    currentPage = 0;
    _applyFilters();
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    minPrice = min;
    maxPrice = max;
    currentPage = 0;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    displayProducts = allProducts.where((p) {
      if (selectedCategory != 'All' && p.category != selectedCategory) return false;
      if (p.price < minPrice || p.price > maxPrice) return false;
      return true;
    }).toList();
  }

  Future<void> searchProducts(String query) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      if (query.isEmpty) {
        _applyFilters();
      } else {
        displayProducts = allProducts
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.description.toLowerCase().contains(query.toLowerCase()) ||
                p.category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      error = 'Search failed: $e';
      notifyListeners();
    }
  }

  List<String> getCategories() {
    final categories = <String>{'All'};
    categories.addAll(allProducts.map((p) => p.category));
    return categories.toList();
  }
}

class MarketBrowseScreen extends StatefulWidget {
  const MarketBrowseScreen({Key? key}) : super(key: key);

  @override
  State<MarketBrowseScreen> createState() => _MarketBrowseScreenState();
}

class _MarketBrowseScreenState extends State<MarketBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await context.read<MarketProvider>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        elevation: 0,
      ),
      body: Consumer<MarketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            child: Column(
              children: [
                _buildSearchBar(provider),
                _buildCategoryFilter(provider),
                Expanded(
                  child: provider.displayProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: provider.displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = provider.displayProducts[index];
                            return _buildProductCard(context, product);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(MarketProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.searchProducts('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (val) {
          setState(() {});
          provider.searchProducts(val);
        },
      ),
    );
  }

  Widget _buildCategoryFilter(MarketProvider provider) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: provider.getCategories().map((category) {
          final isSelected = provider.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => provider.setCategory(category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => _showProductDetail(context, product),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image, size: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        ' ${product.rating}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        ' (${product.reviews})',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetail(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    Text(' ${product.rating} • ${product.reviews} reviews'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(product.description),
                const SizedBox(height: 16),
                Text('Vendor: ${product.vendorName}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart')),
                          );
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Icon(Icons.favorite_border),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
