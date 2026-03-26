/// Models for the Q Points Market system.
/// These map to the backend entities and API response shapes.

// ────────────────────────────────────────────
// Enums
// ────────────────────────────────────────────

enum QPointOrderType { buy, sell }

enum QPointOrderStatus { open, filled, cancelled, expired }

extension QPointOrderTypeX on QPointOrderType {
  String get value => name; // 'buy' | 'sell'
  static QPointOrderType fromString(String s) =>
      QPointOrderType.values.firstWhere((e) => e.name == s,
          orElse: () => QPointOrderType.buy);
}

extension QPointOrderStatusX on QPointOrderStatus {
  static QPointOrderStatus fromString(String s) =>
      QPointOrderStatus.values.firstWhere((e) => e.name == s,
          orElse: () => QPointOrderStatus.open);
}

// ────────────────────────────────────────────
// Market Balance
// ────────────────────────────────────────────

class QPointMarketBalance {
  final double balance;
  final DateTime updatedAt;

  const QPointMarketBalance({required this.balance, required this.updatedAt});

  factory QPointMarketBalance.fromJson(Map<String, dynamic> j) =>
      QPointMarketBalance(
        balance: (j['balance'] as num).toDouble(),
        updatedAt: DateTime.parse(j['updated_at'] as String? ??
            (j['updatedAt'] as String? ?? DateTime.now().toIso8601String())),
      );
}

// ────────────────────────────────────────────
// Order
// ────────────────────────────────────────────

class QPointOrder {
  final String id;
  final String userId;
  final QPointOrderType type;
  final double price;
  final double quantity;
  final double filledQuantity;
  final QPointOrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QPointOrder({
    required this.id,
    required this.userId,
    required this.type,
    required this.price,
    required this.quantity,
    required this.filledQuantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingQuantity => quantity - filledQuantity;

  factory QPointOrder.fromJson(Map<String, dynamic> j) => QPointOrder(
        id: j['id'] as String,
        userId: j['userId'] as String? ?? j['user_id'] as String,
        type: QPointOrderTypeX.fromString(j['type'] as String),
        price: (j['price'] as num).toDouble(),
        quantity: (j['quantity'] as num).toDouble(),
        filledQuantity: (j['filledQuantity'] as num? ?? j['filled_quantity'] as num? ?? 0).toDouble(),
        status: QPointOrderStatusX.fromString(j['status'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String? ?? j['created_at'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String? ?? j['updated_at'] as String),
      );
}

// ────────────────────────────────────────────
// Trade
// ────────────────────────────────────────────

class QPointTrade {
  final String id;
  final double price;
  final double quantity;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;

  const QPointTrade({
    required this.id,
    required this.price,
    required this.quantity,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
  });

  factory QPointTrade.fromJson(Map<String, dynamic> j) => QPointTrade(
        id: j['id'] as String,
        price: (j['price'] as num).toDouble(),
        quantity: (j['quantity'] as num).toDouble(),
        buyerId: j['buyerId'] as String? ?? j['buyer_id'] as String,
        sellerId: j['sellerId'] as String? ?? j['seller_id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String? ?? j['created_at'] as String),
      );
}

// ────────────────────────────────────────────
// Order Book
// ────────────────────────────────────────────

class OrderBookLevel {
  final double price;
  final double quantity;
  final int count;

  const OrderBookLevel({
    required this.price,
    required this.quantity,
    required this.count,
  });

  factory OrderBookLevel.fromJson(Map<String, dynamic> j) => OrderBookLevel(
        price: (j['price'] as num).toDouble(),
        quantity: (j['quantity'] as num).toDouble(),
        count: (j['count'] as num).toInt(),
      );
}

class QPointOrderBook {
  final List<OrderBookLevel> buys;
  final List<OrderBookLevel> sells;

  const QPointOrderBook({required this.buys, required this.sells});

  double? get bestBid => buys.isNotEmpty ? buys.first.price : null;
  double? get bestAsk => sells.isNotEmpty ? sells.first.price : null;

  factory QPointOrderBook.fromJson(Map<String, dynamic> j) => QPointOrderBook(
        buys: (j['buys'] as List<dynamic>)
            .map((e) => OrderBookLevel.fromJson(e as Map<String, dynamic>))
            .toList(),
        sells: (j['sells'] as List<dynamic>)
            .map((e) => OrderBookLevel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ────────────────────────────────────────────
// Market Stats
// ────────────────────────────────────────────

class QPointMarketStats {
  final double? lastPrice;
  final double volume24h;
  final double? spreadPercent;
  final double? bestBid;
  final double? bestAsk;

  const QPointMarketStats({
    this.lastPrice,
    required this.volume24h,
    this.spreadPercent,
    this.bestBid,
    this.bestAsk,
  });

  factory QPointMarketStats.fromJson(Map<String, dynamic> j) =>
      QPointMarketStats(
        lastPrice: (j['lastPrice'] ?? j['last_price']) != null
            ? (j['lastPrice'] ?? j['last_price'] as num).toDouble()
            : null,
        volume24h: ((j['volume24h'] ?? j['volume_24h']) as num? ?? 0).toDouble(),
        spreadPercent: (j['spreadPercent'] ?? j['spread_percent']) != null
            ? ((j['spreadPercent'] ?? j['spread_percent']) as num).toDouble()
            : null,
        bestBid: (j['bestBid'] ?? j['best_bid']) != null
            ? ((j['bestBid'] ?? j['best_bid']) as num).toDouble()
            : null,
        bestAsk: (j['bestAsk'] ?? j['best_ask']) != null
            ? ((j['bestAsk'] ?? j['best_ask']) as num).toDouble()
            : null,
      );
}

// ────────────────────────────────────────────
// Notification
// ────────────────────────────────────────────

class QPointNotification {
  final String id;
  final String type;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  const QPointNotification({
    required this.id,
    required this.type,
    required this.message,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory QPointNotification.fromJson(Map<String, dynamic> j) =>
      QPointNotification(
        id: j['id'] as String,
        type: j['type'] as String,
        message: j['message'] as String,
        data: j['data'] as Map<String, dynamic>?,
        read: (j['read'] as bool?) ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String? ?? j['created_at'] as String),
      );
}
