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

// ────────────────────────────────────────────
// Terms of Service Models
// ────────────────────────────────────────────

/// Full ToS document returned by GET /qpoints/tos
class QPointsTosContent {
  final String version;
  final String effectiveDate;
  final String contentHash;
  final String text;

  const QPointsTosContent({
    required this.version,
    required this.effectiveDate,
    required this.contentHash,
    required this.text,
  });

  factory QPointsTosContent.fromJson(Map<String, dynamic> j) =>
      QPointsTosContent(
        version: j['version'] as String,
        effectiveDate: j['effectiveDate'] as String,
        contentHash: j['contentHash'] as String,
        text: j['text'] as String,
      );
}

/// Acceptance status returned by GET /qpoints/tos/status
class QPointsTosStatus {
  final bool accepted;
  final String version;
  final String effectiveDate;

  const QPointsTosStatus({
    required this.accepted,
    required this.version,
    required this.effectiveDate,
  });

  factory QPointsTosStatus.fromJson(Map<String, dynamic> j) =>
      QPointsTosStatus(
        accepted: (j['accepted'] as bool?) ?? false,
        version: j['version'] as String,
        effectiveDate: j['effectiveDate'] as String,
      );
}

// ────────────────────────────────────────────
// Fee Schedule (TOS §7.1)
// ────────────────────────────────────────────

/// Fee schedule returned by GET /qpoints/fees (TOS Section 7.1)
class QPointFeeSchedule {
  /// Per-trade fee charged to the taker in USD
  final double tradeFeePerTrade;
  final String feeChargeTo;
  final String pegRate;
  final String description;

  const QPointFeeSchedule({
    required this.tradeFeePerTrade,
    required this.feeChargeTo,
    required this.pegRate,
    required this.description,
  });

  factory QPointFeeSchedule.fromJson(Map<String, dynamic> j) =>
      QPointFeeSchedule(
        tradeFeePerTrade:
            ((j['tradeFeePerTrade'] ?? j['trade_fee_per_trade']) as num)
                .toDouble(),
        feeChargeTo: j['feeChargeTo'] as String? ?? j['fee_charge_to'] as String? ?? 'taker',
        pegRate: j['pegRate'] as String? ?? j['peg_rate'] as String? ?? '1.00 Q Points = \$1.00 USD (fixed)',
        // Backend returns 'taxDisclosure' — map it to description field
        description: j['taxDisclosure'] as String? ??
            j['description'] as String? ?? '',
      );
}

// ────────────────────────────────────────────
// Facilitator Models (TOS §2.2)
// ────────────────────────────────────────────

/// Option for a select-type account field (e.g. account type choices).
class QPointFieldOption {
  final String value;
  final String label;

  const QPointFieldOption({required this.value, required this.label});

  factory QPointFieldOption.fromJson(Map<String, dynamic> j) =>
      QPointFieldOption(
        value: j['value'] as String,
        label: j['label'] as String,
      );
}

/// A single field the user must provide to register with a facilitator.
class QPointFacilitatorField {
  final String key;
  final String label;
  final String type; // 'text' | 'phone' | 'select'
  final bool required;
  final List<QPointFieldOption> options;

  const QPointFacilitatorField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  factory QPointFacilitatorField.fromJson(Map<String, dynamic> j) =>
      QPointFacilitatorField(
        key: j['key'] as String,
        label: j['label'] as String,
        type: j['type'] as String,
        required: (j['required'] as bool?) ?? false,
        options: (j['options'] as List<dynamic>? ?? [])
            .map((e) => QPointFieldOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A payment facilitator available for a jurisdiction (from GET /qpoints/facilitators).
class QPointFacilitatorInfo {
  final String provider;
  final String displayName;
  final String description;
  final List<String> supportedCountries;
  final List<String> currencies;
  final List<QPointFacilitatorField> accountFields;

  const QPointFacilitatorInfo({
    required this.provider,
    required this.displayName,
    required this.description,
    required this.supportedCountries,
    required this.currencies,
    required this.accountFields,
  });

  factory QPointFacilitatorInfo.fromJson(Map<String, dynamic> j) =>
      QPointFacilitatorInfo(
        provider: j['provider'] as String,
        displayName: j['displayName'] as String,
        description: j['description'] as String,
        supportedCountries: (j['supportedCountries'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        currencies: (j['currencies'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        accountFields: (j['accountFields'] as List<dynamic>? ?? [])
            .map((e) => QPointFacilitatorField.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A registered facilitator account for the current user (from GET /qpoints/payment/accounts).
class QPointFacilitatorAccount {
  final String id;
  final String provider;
  /// Provider-specific external account / recipient ID (masked for display).
  final String externalId;
  final DateTime createdAt;

  const QPointFacilitatorAccount({
    required this.id,
    required this.provider,
    required this.externalId,
    required this.createdAt,
  });

  factory QPointFacilitatorAccount.fromJson(Map<String, dynamic> j) =>
      QPointFacilitatorAccount(
        id: j['id'] as String,
        provider: j['provider'] as String,
        externalId: j['externalId'] as String? ?? j['external_id'] as String? ?? '',
        createdAt: DateTime.parse(
          j['createdAt'] as String? ?? j['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );
}

