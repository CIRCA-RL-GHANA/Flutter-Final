import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Investment {
  final String id;
  final String name;
  final double initialAmount;
  final double currentValue;
  final double returns;
  final double roi;
  final String status;
  final DateTime startDate;
  final DateTime? maturityDate;

  Investment({
    required this.id,
    required this.name,
    required this.initialAmount,
    required this.currentValue,
    required this.returns,
    required this.roi,
    required this.status,
    required this.startDate,
    this.maturityDate,
  });
}

class InvestmentsProvider extends ChangeNotifier {
  List<Investment> investments = [];
  bool isLoading = false;
  String? error;

  Future<void> loadInvestments() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      investments = [
        Investment(
          id: 'inv_1',
          name: 'Tech Stocks Fund',
          initialAmount: 5000.00,
          currentValue: 5750.00,
          returns: 750.00,
          roi: 15.0,
          status: 'active',
          startDate: DateTime.now().subtract(Duration(days: 180)),
          maturityDate: DateTime.now().add(Duration(days: 180)),
        ),
        Investment(
          id: 'inv_2',
          name: 'Bond Portfolio',
          initialAmount: 10000.00,
          currentValue: 10450.00,
          returns: 450.00,
          roi: 4.5,
          status: 'active',
          startDate: DateTime.now().subtract(Duration(days: 365)),
          maturityDate: DateTime.now().add(Duration(days: 365)),
        ),
        Investment(
          id: 'inv_3',
          name: 'Real Estate Investment Trust',
          initialAmount: 7500.00,
          currentValue: 8100.00,
          returns: 600.00,
          roi: 8.0,
          status: 'active',
          startDate: DateTime.now().subtract(Duration(days: 90)),
        ),
      ];
    } catch (e) {
      error = 'Failed to load investments: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createInvestment(String name, double amount) async {
    try {
      final newInvestment = Investment(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        initialAmount: amount,
        currentValue: amount,
        returns: 0.0,
        roi: 0.0,
        status: 'active',
        startDate: DateTime.now(),
        maturityDate: DateTime.now().add(Duration(days: 365)),
      );
      investments.add(newInvestment);
      notifyListeners();
    } catch (e) {
      error = 'Failed to create investment: $e';
      notifyListeners();
    }
  }

  Future<void> withdrawInvestment(String investmentId) async {
    try {
      final idx = investments.indexWhere((i) => i.id == investmentId);
      if (idx == -1) throw Exception('Investment not found');

      investments[idx] = Investment(
        id: investments[idx].id,
        name: investments[idx].name,
        initialAmount: investments[idx].initialAmount,
        currentValue: investments[idx].currentValue,
        returns: investments[idx].returns,
        roi: investments[idx].roi,
        status: 'withdrawn',
        startDate: investments[idx].startDate,
        maturityDate: investments[idx].maturityDate,
      );

      notifyListeners();
    } catch (e) {
      error = 'Failed to withdraw investment: $e';
      notifyListeners();
    }
  }

  double getTotalInvested() => investments.fold(0, (sum, i) => sum + i.initialAmount);
  double getTotalValue() => investments.fold(0, (sum, i) => sum + i.currentValue);
  double getTotalReturns() => investments.fold(0, (sum, i) => sum + i.returns);
}

class InvestmentsDashboard extends StatefulWidget {
  const InvestmentsDashboard({Key? key}) : super(key: key);

  @override
  State<InvestmentsDashboard> createState() => _InvestmentsDashboardState();
}

class _InvestmentsDashboardState extends State<InvestmentsDashboard> {
  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    await context.read<InvestmentsProvider>().loadInvestments();
  }

  void _showInvestDialog() {
    String investmentName = '';
    double amount = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Investment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Investment Name', border: OutlineInputBorder()),
                onChanged: (val) => investmentName = val,
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (USD)', border: OutlineInputBorder()),
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (investmentName.isNotEmpty && amount > 0) {
                context.read<InvestmentsProvider>().createInvestment(investmentName, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Investment created successfully')),
                );
              }
            },
            child: const Text('Invest'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Portfolio'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInvestDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<InvestmentsProvider>(
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
                    onPressed: _loadInvestments,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.investments.isEmpty) {
            return const Center(child: Text('No investments yet. Get started!'));
          }

          return RefreshIndicator(
            onRefresh: _loadInvestments,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPortfolioCard(provider),
                const SizedBox(height: 24),
                const Text('My Investments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...provider.investments.map((inv) => _buildInvestmentItem(context, provider, inv)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortfolioCard(InvestmentsProvider provider) {
    final totalValue = provider.getTotalValue();
    final totalInvested = provider.getTotalInvested();
    final totalReturns = provider.getTotalReturns();
    final overallROI = totalInvested > 0 ? (totalReturns / totalInvested * 100) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Portfolio Summary', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Invested', '\$${totalInvested.toStringAsFixed(2)}'),
                _buildStatItem('Current Value', '\$${totalValue.toStringAsFixed(2)}'),
                _buildStatItem('Returns', '\$${totalReturns.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: overallROI >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Overall ROI: ${overallROI.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: overallROI >= 0 ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInvestmentItem(BuildContext context, InvestmentsProvider provider, Investment inv) {
    final gainLoss = inv.currentValue - inv.initialAmount;
    final color = gainLoss >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.trending_up, color: color),
        ),
        title: Text(inv.name),
        subtitle: Text('Invested: \$${inv.initialAmount.toStringAsFixed(2)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${inv.currentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${inv.roi > 0 ? '+' : ''}${inv.roi.toStringAsFixed(2)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () => _showInvestmentDetail(context, provider, inv),
      ),
    );
  }

  void _showInvestmentDetail(BuildContext context, InvestmentsProvider provider, Investment inv) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inv.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _detailRow('Initial Investment', '\$${inv.initialAmount.toStringAsFixed(2)}'),
            _detailRow('Current Value', '\$${inv.currentValue.toStringAsFixed(2)}'),
            _detailRow('Gains/Loss', '\$${(inv.currentValue - inv.initialAmount).toStringAsFixed(2)}'),
            _detailRow('ROI', '${inv.roi.toStringAsFixed(2)}%'),
            _detailRow('Start Date', _formatDate(inv.startDate)),
            if (inv.maturityDate != null) _detailRow('Maturity Date', _formatDate(inv.maturityDate!)),
            _detailRow('Status', inv.status),
            const SizedBox(height: 16),
            if (inv.status == 'active')
              ElevatedButton(
                onPressed: () {
                  provider.withdrawInvestment(inv.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Investment withdrawn successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Withdraw Investment'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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

  String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
}
