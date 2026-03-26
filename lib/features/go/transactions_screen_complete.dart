import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String description;
  final DateTime timestamp;
  final String status;
  final String category;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.timestamp,
    required this.status,
    required this.category,
  });
}

class TransactionsProvider extends ChangeNotifier {
  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];
  bool isLoading = false;
  String? error;
  String? selectedType;
  DateTime? startDate;
  DateTime? endDate;
  int currentPage = 0;
  bool hasMore = true;

  Future<void> loadTransactions() async {
    isLoading = true;
    error = null;
    currentPage = 0;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      allTransactions = _generateMockTransactions();
      _applyFilters();
    } catch (e) {
      error = 'Failed to load transactions: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  List<Transaction> _generateMockTransactions() {
    return [
      Transaction(
        id: 'txn_1',
        type: 'debit',
        amount: 150.00,
        currency: 'USD',
        description: 'Grocery Store',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        status: 'completed',
        category: 'Shopping',
      ),
      Transaction(
        id: 'txn_2',
        type: 'credit',
        amount: 2500.00,
        currency: 'USD',
        description: 'Salary Deposit',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        status: 'completed',
        category: 'Income',
      ),
      Transaction(
        id: 'txn_3',
        type: 'debit',
        amount: 45.99,
        currency: 'USD',
        description: 'Netflix Subscription',
        timestamp: DateTime.now().subtract(Duration(days: 3)),
        status: 'completed',
        category: 'Entertainment',
      ),
      Transaction(
        id: 'txn_4',
        type: 'transfer',
        amount: 500.00,
        currency: 'USD',
        description: 'Sent to John',
        timestamp: DateTime.now().subtract(Duration(days: 5)),
        status: 'completed',
        category: 'Transfer',
      ),
      Transaction(
        id: 'txn_5',
        type: 'debit',
        amount: 89.50,
        currency: 'USD',
        description: 'Fuel',
        timestamp: DateTime.now().subtract(Duration(days: 7)),
        status: 'completed',
        category: 'Transport',
      ),
    ];
  }

  void setTypeFilter(String? type) {
    selectedType = type;
    currentPage = 0;
    _applyFilters();
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    currentPage = 0;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    filteredTransactions = allTransactions.where((txn) {
      if (selectedType != null && txn.type != selectedType) return false;
      if (startDate != null && txn.timestamp.isBefore(startDate!)) return false;
      if (endDate != null && txn.timestamp.isAfter(endDate!)) return false;
      return true;
    }).toList();

    filteredTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    hasMore = filteredTransactions.length > (currentPage + 1) * 10;
  }

  void loadMore() {
    if (hasMore) {
      currentPage++;
      hasMore = filteredTransactions.length > (currentPage + 1) * 10;
      notifyListeners();
    }
  }

  Future<void> searchTransactions(String query) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      filteredTransactions = allTransactions
          .where((txn) =>
              txn.description.toLowerCase().contains(query.toLowerCase()) ||
              txn.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      error = 'Search failed: $e';
      notifyListeners();
    }
  }

  List<Transaction> get paginatedTransactions {
    final start = currentPage * 10;
    final end = start + 10;
    return filteredTransactions.sublist(start, end > filteredTransactions.length ? filteredTransactions.length : end);
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await context.read<TransactionsProvider>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
      ),
      body: Consumer<TransactionsProvider>(
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
                    onPressed: _loadTransactions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTransactions,
            child: Column(
              children: [
                _buildSearchAndFilter(provider),
                Expanded(
                  child: provider.filteredTransactions.isEmpty
                      ? const Center(child: Text('No transactions found'))
                      : ListView(
                          children: [
                            ...provider.paginatedTransactions
                                .map((txn) => _buildTransactionTile(txn))
                                .toList(),
                            if (provider.hasMore)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ElevatedButton(
                                  onPressed: () => provider.loadMore(),
                                  child: const Text('Load More'),
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
    );
  }

  Widget _buildSearchAndFilter(TransactionsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              if (val.isEmpty) {
                provider.loadTransactions();
              } else {
                provider.searchTransactions(val);
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  hint: const Text('Type'),
                  value: provider.selectedType,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Types')),
                    const DropdownMenuItem(value: 'debit', child: Text('Debit')),
                    const DropdownMenuItem(value: 'credit', child: Text('Credit')),
                    const DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                  ],
                  onChanged: (val) => provider.setTypeFilter(val),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (range != null) {
                    provider.setDateRange(range.start, range.end);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Date'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction txn) {
    Color color = txn.type == 'credit' || txn.type == 'transfer' ? Colors.green : Colors.red;
    String prefix = txn.type == 'credit' || txn.type == 'transfer' ? '+' : '-';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          txn.type == 'credit'
              ? Icons.arrow_downward
              : txn.type == 'debit'
                  ? Icons.arrow_upward
                  : Icons.swap_horiz,
          color: color,
        ),
      ),
      title: Text(txn.description),
      subtitle: Text(txn.category),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$prefix${txn.currency} ${txn.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            _formatDate(txn.timestamp),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}
