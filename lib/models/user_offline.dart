import 'package:pverify/services/database/column_names.dart';

class UserOffline {
  int? id; // For SQLite row id
  String userId;
  String userHash;
  int enterpriseId;
  String? status;
  bool isSubscriptionExpired;
  int supplierId;
  int headquarterSupplierId;
  bool gtinScanning;

  UserOffline({
    this.id,
    required this.userId,
    required this.userHash,
    required this.enterpriseId,
    required this.status,
    required this.isSubscriptionExpired,
    required this.supplierId,
    required this.headquarterSupplierId,
    required this.gtinScanning,
  });

  Map<String, dynamic> toMap() {
    return {
      UserOfflineColumn.ID: id,
      UserOfflineColumn.USER_ID: userId,
      UserOfflineColumn.ACCESS: userHash,
      UserOfflineColumn.ENTERPRISEID: enterpriseId,
      UserOfflineColumn.STATUS: status,
      UserOfflineColumn.IS_SUBSCRIPTION_EXPIRED: isSubscriptionExpired ? 1 : 0,
      UserOfflineColumn.SUPPLIER_ID: supplierId,
      UserOfflineColumn.HEADQUATER_SUPPLIER_ID: headquarterSupplierId,
      UserOfflineColumn.GTIN_SCANNING: gtinScanning ? 1 : 0,
    };
  }

  factory UserOffline.fromMap(Map<String, dynamic> map) {
    return UserOffline(
      id: map[UserOfflineColumn.ID],
      userId: map[UserOfflineColumn.USER_ID],
      userHash: map[UserOfflineColumn.ACCESS],
      enterpriseId: map[UserOfflineColumn.ENTERPRISEID],
      status: map[UserOfflineColumn.STATUS],
      isSubscriptionExpired:
          map[UserOfflineColumn.IS_SUBSCRIPTION_EXPIRED] == 1,
      supplierId: map[UserOfflineColumn.SUPPLIER_ID],
      headquarterSupplierId: map[UserOfflineColumn.HEADQUATER_SUPPLIER_ID],
      gtinScanning: map[UserOfflineColumn.GTIN_SCANNING] == 1,
    );
  }

  // copyWith
  UserOffline copyWith({
    int? id,
    String? userId,
    String? userHash,
    int? enterpriseId,
    String? status,
    bool? isSubscriptionExpired,
    int? supplierId,
    int? headquarterSupplierId,
    bool? gtinScanning,
  }) {
    return UserOffline(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userHash: userHash ?? this.userHash,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      status: status ?? this.status,
      isSubscriptionExpired:
          isSubscriptionExpired ?? this.isSubscriptionExpired,
      supplierId: supplierId ?? this.supplierId,
      headquarterSupplierId:
          headquarterSupplierId ?? this.headquarterSupplierId,
      gtinScanning: gtinScanning ?? this.gtinScanning,
    );
  }
}
