import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentCard {
  final String id;
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final bool isDefault;
  final String cardType;
  final DateTime addedAt;

  PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.isDefault,
    required this.cardType,
    required this.addedAt,
  });

  String get maskedNumber => '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
}

class CardsProvider extends ChangeNotifier {
  List<PaymentCard> cards = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCards() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      cards = [
        PaymentCard(
          id: 'card_1',
          cardNumber: '4532015112830366',
          cardholderName: 'John Doe',
          expiryDate: '12/26',
          isDefault: true,
          cardType: 'Visa',
          addedAt: DateTime.now().subtract(Duration(days: 180)),
        ),
        PaymentCard(
          id: 'card_2',
          cardNumber: '5425233010103010',
          cardholderName: 'John Doe',
          expiryDate: '08/27',
          isDefault: false,
          cardType: 'Mastercard',
          addedAt: DateTime.now().subtract(Duration(days: 90)),
        ),
      ];
    } catch (e) {
      error = 'Failed to load cards: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(String cardNumber, String cardholderName, String expiryDate) async {
    try {
      if (!_validateCardNumber(cardNumber)) {
        throw Exception('Invalid card number (Luhn validation failed)');
      }

      final newCard = PaymentCard(
        id: 'card_${DateTime.now().millisecondsSinceEpoch}',
        cardNumber: cardNumber,
        cardholderName: cardholderName,
        expiryDate: expiryDate,
        isDefault: cards.isEmpty,
        cardType: _detectCardType(cardNumber),
        addedAt: DateTime.now(),
      );

      cards.add(newCard);
      notifyListeners();
    } catch (e) {
      error = 'Failed to add card: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      cards.removeWhere((c) => c.id == cardId);
      if (cards.isNotEmpty && cards.every((c) => !c.isDefault)) {
        cards[0] = PaymentCard(
          id: cards[0].id,
          cardNumber: cards[0].cardNumber,
          cardholderName: cards[0].cardholderName,
          expiryDate: cards[0].expiryDate,
          isDefault: true,
          cardType: cards[0].cardType,
          addedAt: cards[0].addedAt,
        );
      }
      notifyListeners();
    } catch (e) {
      error = 'Failed to delete card: $e';
      notifyListeners();
    }
  }

  Future<void> setDefault(String cardId) async {
    try {
      cards = cards.map((c) {
        return PaymentCard(
          id: c.id,
          cardNumber: c.cardNumber,
          cardholderName: c.cardholderName,
          expiryDate: c.expiryDate,
          isDefault: c.id == cardId,
          cardType: c.cardType,
          addedAt: c.addedAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      error = 'Failed to set default card: $e';
      notifyListeners();
    }
  }

  bool _validateCardNumber(String cardNumber) {
    String digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool isEven = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  String _detectCardType(String cardNumber) {
    String digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    if (digits.startsWith('3')) return 'American Express';
    if (digits.startsWith('6')) return 'Discover';
    return 'Unknown';
  }
}

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    await context.read<CardsProvider>().loadCards();
  }

  void _showAddCardDialog() {
    String cardNumber = '';
    String cardholderName = '';
    String expiryDate = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                  hintText: '4532 0151 1283 0366',
                ),
                onChanged: (val) => cardNumber = val,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => cardholderName = val,
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                  hintText: 'MM/YY',
                ),
                onChanged: (val) => expiryDate = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (cardNumber.isNotEmpty && cardholderName.isNotEmpty && expiryDate.isNotEmpty) {
                context.read<CardsProvider>().addCard(cardNumber, cardholderName, expiryDate);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Cards'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<CardsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCards,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.cards.isEmpty) {
            return const Center(child: Text('No cards added yet'));
          }

          return RefreshIndicator(
            onRefresh: _loadCards,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: provider.cards.map((card) => _buildCardItem(context, provider, card)).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, CardsProvider provider, PaymentCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              card.cardType == 'Visa'
                  ? Icons.credit_card
                  : card.cardType == 'Mastercard'
                      ? Icons.credit_card
                      : Icons.card_giftcard,
            ),
            title: Text(card.cardType),
            subtitle: Text(card.maskedNumber),
            trailing: card.isDefault ? const Chip(label: Text('Default')) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expires: ${card.expiryDate}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    if (!card.isDefault)
                      TextButton(
                        onPressed: () => provider.setDefault(card.id),
                        child: const Text('Set Default'),
                      ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Card?'),
                            content: const Text('This action cannot be undone'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  provider.deleteCard(card.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Card deleted')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
}
