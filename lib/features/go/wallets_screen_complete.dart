import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wallet {
  final String id;
  final String currency;
  final double balance;
  final String type;
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.currency,
    required this.balance,
    required this.type,
    required this.createdAt,
  });
}

class WalletsProvider extends ChangeNotifier {
  List<Wallet> wallets = [];
  String? selectedWalletId;
  bool isLoading = false;
  String? error;
  Map<String, double> exchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'NGN': 411.5,
  };

  Future<void> loadWallets() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      wallets = [
        Wallet(
          id: 'wallet_1',
          currency: 'USD',
          balance: 5250.75,
          type: 'Primary',
          createdAt: DateTime.now().subtract(Duration(days: 90)),
        ),
        Wallet(
          id: 'wallet_2',
          currency: 'EUR',
          balance: 3150.50,
          type: 'Secondary',
          createdAt: DateTime.now().subtract(Duration(days: 60)),
        ),
        Wallet(
          id: 'wallet_3',
          currency: 'GBP',
          balance: 1850.25,
          type: 'Secondary',
          createdAt: DateTime.now().subtract(Duration(days: 30)),
        ),
        Wallet(
          id: 'wallet_4',
          currency: 'NGN',
          balance: 850000.00,
          type: 'Local',
          createdAt: DateTime.now().subtract(Duration(days: 15)),
        ),
      ];
      selectedWalletId = wallets.first.id;
    } catch (e) {
      error = 'Failed to load wallets: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createWallet(String currency) async {
    try {
      final newWallet = Wallet(
        id: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        currency: currency,
        balance: 0.0,
        type: 'Secondary',
        createdAt: DateTime.now(),
      );
      wallets.add(newWallet);
      selectedWalletId = newWallet.id;
      notifyListeners();
    } catch (e) {
      error = 'Failed to create wallet: $e';
      notifyListeners();
    }
  }

  Future<void> transferBetweenWallets(
    String fromWalletId,
    String toWalletId,
    double amount,
  ) async {
    try {
      final fromIdx = wallets.indexWhere((w) => w.id == fromWalletId);
      final toIdx = wallets.indexWhere((w) => w.id == toWalletId);

      if (fromIdx == -1 || toIdx == -1) throw Exception('Wallet not found');
      if (wallets[fromIdx].balance < amount) {
        throw Exception('Insufficient funds');
      }

      // Calculate conversion rate
      final fromRate = exchangeRates[wallets[fromIdx].currency] ?? 1.0;
      final toRate = exchangeRates[wallets[toIdx].currency] ?? 1.0;
      final convertedAmount = amount * (fromRate / toRate);

      wallets[fromIdx] = Wallet(
        id: wallets[fromIdx].id,
        currency: wallets[fromIdx].currency,
        balance: wallets[fromIdx].balance - amount,
        type: wallets[fromIdx].type,
        createdAt: wallets[fromIdx].createdAt,
      );

      wallets[toIdx] = Wallet(
        id: wallets[toIdx].id,
        currency: wallets[toIdx].currency,
        balance: wallets[toIdx].balance + convertedAmount,
        type: wallets[toIdx].type,
        createdAt: wallets[toIdx].createdAt,
      );

      notifyListeners();
    } catch (e) {
      error = 'Transfer failed: $e';
      notifyListeners();
    }
  }

  Wallet? get selectedWallet {
    if (selectedWalletId == null) return null;
    return wallets.firstWhere(
      (w) => w.id == selectedWalletId,
      orElse: () => wallets.first,
    );
  }

  double getTotalBalance() {
    return wallets.fold(0, (sum, w) {
      final rate = exchangeRates[w.currency] ?? 1.0;
      return sum + (w.balance * rate);
    });
  }
}

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({Key? key}) : super(key: key);

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    await context.read<WalletsProvider>().loadWallets();
  }

  void _showAddWalletDialog() {
    String selectedCurrency = 'EUR';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Wallet'),
        content: DropdownButton<String>(
          value: selectedCurrency,
          isExpanded: true,
          items: ['USD', 'EUR', 'GBP', 'NGN']
              .map((curr) => DropdownMenuItem(value: curr, child: Text(curr)))
              .toList(),
          onChanged: (val) => selectedCurrency = val ?? 'EUR',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<WalletsProvider>().createWallet(selectedCurrency);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wallet created successfully')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    final provider = context.read<WalletsProvider>();
    String? fromWalletId = provider.wallets.first.id;
    String? toWalletId = provider.wallets.length > 1 ? provider.wallets[1].id : null;
    double amount = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Transfer Between Wallets'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: fromWalletId,
                  isExpanded: true,
                  items: provider.wallets
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text('${w.currency} - \$${w.balance.toStringAsFixed(2)}'),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => fromWalletId = val),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: toWalletId,
                  isExpanded: true,
                  items: provider.wallets
                      .where((w) => w.id != fromWalletId)
                      .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text('${w.currency} - \$${w.balance.toStringAsFixed(2)}'),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => toWalletId = val),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                  onChanged: (val) => amount = double.tryParse(val) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (fromWalletId != null && toWalletId != null && amount > 0) {
                  provider.transferBetweenWallets(fromWalletId!, toWalletId!, amount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Transfer successful')));
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWalletDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<WalletsProvider>(
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
                    onPressed: _loadWallets,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.wallets.isEmpty) {
            return const Center(
              child: Text('No wallets yet. Create one to get started!'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadWallets,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTotalBalanceCard(provider),
                const SizedBox(height: 24),
                const Text('My Wallets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...provider.wallets.map((wallet) => _buildWalletCard(context, provider, wallet)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalBalanceCard(WalletsProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Total Balance', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              '\$${provider.getTotalBalance().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showTransferDialog,
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletsProvider provider, Wallet wallet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              wallet.currency,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        title: Text('${wallet.type} - ${wallet.currency}'),
        subtitle: Text('Created ${wallet.createdAt.difference(DateTime.now()).inDays.abs()} days ago'),
        trailing: Text(
          '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () {
          provider.selectedWalletId = wallet.id;
          provider.notifyListeners();
        },
      ),
    );
  }
}
