class UserOffline {
  int? id; // For SQLite row id
  String userId;
  String userHash;
  int enterpriseId;
  String status;
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
      'id': id,
      'User_ID': userId,
      'Access': userHash,
      'EnterpriseId': enterpriseId,
      'Status': status,
      'IsSubscriptionExpired': isSubscriptionExpired ? 1 : 0,
      'Supplier_Id': supplierId,
      'Headquater_Supplier_Id': headquarterSupplierId,
      'GtinScanning': gtinScanning ? 1 : 0,
    };
  }

  factory UserOffline.fromMap(Map<String, dynamic> map) {
    return UserOffline(
      id: map['id'],
      userId: map['User_ID'],
      userHash: map['Access'],
      enterpriseId: map['EnterpriseId'],
      status: map['Status'],
      isSubscriptionExpired: map['IsSubscriptionExpired'] == 1,
      supplierId: map['Supplier_Id'],
      headquarterSupplierId: map['Headquater_Supplier_Id'],
      gtinScanning: map['GtinScanning'] == 1,
    );
  }
}
