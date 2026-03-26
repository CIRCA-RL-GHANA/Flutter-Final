import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketCategoriesScreen extends StatelessWidget {
  const MarketCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Electronics', Icons.devices),
      ('Accessories', Icons.watch),
      ('Cables', Icons.cable),
      ('Fashion', Icons.shopping_bag),
      ('Books', Icons.book),
      ('Home & Garden', Icons.home),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), elevation: 0),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final (name, icon) = categories[index];
          return GestureDetector(
            onTap: () {
              context.read<MarketProvider>().setCategory(name);
              Navigator.pop(context);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon as IconData, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoreDetailsScreen extends StatelessWidget {
  final String vendorId;
  final String vendorName;

  const StoreDetailsScreen({Key? key, required this.vendorId, required this.vendorName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vendorName), elevation: 0),
      body: ListView(
        children: [
          Container(
            height: 200,
            color: Colors.blue.shade100,
            child: Center(
              child: Icon(Icons.store, size: 80, color: Colors.blue.shade300),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendorName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const Text(' 4.7 • 2,341 reviews'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('About Store'),
                const SizedBox(height: 8),
                const Text(
                  'Premium quality electronics and accessories at competitive prices. Fast shipping and excellent customer service.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Following store'))),
                        icon: const Icon(Icons.favorite),
                        label: const Text('Follow'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message),
                        label: const Text('Contact'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Store Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _storeInfoRow('Joined', 'January 2022'),
                _storeInfoRow('Location', 'New York, USA'),
                _storeInfoRow('Response Rate', '99.8%'),
                _storeInfoRow('Response Time', '< 1 hour'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final String productName;
  final double price;
  final double rating;
  final int reviews;

  const ProductDetailsScreen({
    Key? key,
    required this.productName,
    required this.price,
    required this.rating,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details'), elevation: 0),
      body: ListView(
        children: [
          Container(
            height: 300,
            color: Colors.grey.shade200,
            child: const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(' $rating • $reviews reviews'),
                  ],
                ),
                const SizedBox(height: 16),
                Text('\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 16),
                const Text('Description'),
                const SizedBox(height: 8),
                const Text(
                  'Premium quality product with excellent features. Perfect for everyday use with reliable performance.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('Specifications'),
                const SizedBox(height: 8),
                _specRow('Color', 'Black'),
                _specRow('Material', 'Aluminum'),
                _specRow('Weight', '250g'),
                _specRow('Warranty', '2 years'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Added to cart'))),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      child: const Icon(Icons.favorite_border),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'Wireless Headphones', 'price': 299.99, 'quantity': 1},
    {'name': 'USB-C Cable', 'price': 15.99, 'quantity': 2},
  ];

  double get total => cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart'), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price'].toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (item['quantity'] > 1) {
                            setState(() => item['quantity']--);
                          }
                        },
                      ),
                      Text('${item['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => item['quantity']++),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => cartItems.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('\$${total.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping'),
                    const Text('\$10.00'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax'),
                    Text('\$${(total * 0.1).toStringAsFixed(2)}'),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${(total + 10 + (total * 0.1)).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/checkout'),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Shipping Address', [
            _field('John Doe', 'Name'),
            _field('123 Main Street, New York, NY 10001', 'Address'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Shipping Method', [
            _shipMethod('Standard (5-7 days)', '\$5.00'),
            _shipMethod('Express (2-3 days)', '\$15.00'),
            _shipMethod('Overnight', '\$25.00'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Payment Method', [
            _paymentMethod('Visa ending in 3366'),
            _paymentMethod('Add new card'),
          ]),
          const SizedBox(height: 24),
          const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Subtotal'), Text('\$329.97')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Shipping'), Text('\$5.00')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Tax'), Text('\$33.00')],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$367.97', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _field(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _shipMethod(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Radio(value: 1, groupValue: 1, onChanged: (_) {}),
          title: Text(name),
          trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _paymentMethod(String method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Radio(value: 1, groupValue: 1, onChanged: (_) {}),
          title: Text(method),
        ),
      ),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': '#ORD001', 'items': 3, 'total': '\$329.97', 'status': 'Delivered', 'date': '2026-03-15'},
      {'id': '#ORD002', 'items': 1, 'total': '\$99.99', 'status': 'In Transit', 'date': '2026-03-10'},
      {'id': '#ORD003', 'items': 2, 'total': '\$149.98', 'status': 'Processing', 'date': '2026-03-08'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Order History'), elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final statusColor = order['status'] == 'Delivered'
              ? Colors.green
              : order['status'] == 'In Transit'
                  ? Colors.blue
                  : Colors.orange;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(order['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${order['items']} items • ${order['date']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(order['total'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(order['status'] as String, style: TextStyle(color: statusColor, fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {'author': 'John D.', 'rating': 5, 'comment': 'Excellent product! Highly recommended.', 'date': '2 days ago'},
      {
        'author': 'Sarah M.',
        'rating': 4,
        'comment': 'Good quality, fast shipping. Would buy again.',
        'date': '1 week ago'
      },
      {
        'author': 'Mike T.',
        'rating': 5,
        'comment': 'Perfect! Exactly as described. Great value for money.',
        'date': '2 weeks ago'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Product Reviews'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Overall Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('4.7', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber)),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star_half, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Based on 248 reviews'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...reviews.map((review) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review['author'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(review['date'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < (review['rating'] as int) ? Icons.star : Icons.star_outline,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(review['comment'] as String),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
