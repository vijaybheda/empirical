import 'dart:convert';

class LoginData {
  int? id;
  int? status;
  String? userName;
  String? access1;
  String? language;
  bool? displayCarriers;
  bool? gtinScanning;
  bool? subscriptionExpired;
  SystemLabels? systemLabels;
  List<String>? features;
  int? enterpriseId;
  int? supplierId;
  int? headquarterSupplierId;

  LoginData({
    this.id,
    this.status,
    this.userName,
    this.access1,
    this.language,
    this.displayCarriers,
    this.gtinScanning,
    this.subscriptionExpired,
    this.systemLabels,
    this.features,
    this.enterpriseId,
    this.supplierId,
    this.headquarterSupplierId,
  });

  LoginData.fromStringJson(String myJsonString) {
    Map<String, dynamic> jsonData = jsonDecode(myJsonString);
    id = jsonData['id'];
    status = jsonData['status'];
    userName = jsonData['userName'];
    access1 = jsonData['access1'];
    language = jsonData['language'];
    displayCarriers = jsonData['displayCarriers'];
    gtinScanning = jsonData['gtinScanning'];
    subscriptionExpired = jsonData['subscriptionExpired'];
    systemLabels = jsonData['systemLabels'] != null
        ? SystemLabels.fromJson(jsonData['systemLabels'])
        : null;
    features = jsonData['features'].cast<String>();
    enterpriseId = jsonData['enterpriseId'];
    supplierId = jsonData['supplierId'];
    headquarterSupplierId = jsonData['headquarterSupplierId'];
  }

  LoginData.fromJson(Map<String, dynamic> jsonData) {
    id = jsonData['id'];
    status = jsonData['status'];
    userName = jsonData['userName'];
    access1 = jsonData['access1'];
    language = jsonData['language'];
    displayCarriers = jsonData['displayCarriers'];
    gtinScanning = jsonData['gtinScanning'];
    subscriptionExpired = jsonData['subscriptionExpired'];
    systemLabels = jsonData['systemLabels'] != null
        ? SystemLabels.fromJson(jsonData['systemLabels'])
        : null;
    features = jsonData['features'].cast<String>();
    enterpriseId = jsonData['enterpriseId'];
    supplierId = jsonData['supplierId'];
    headquarterSupplierId = jsonData['headquarterSupplierId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['userName'] = userName;
    data['access1'] = access1;
    data['language'] = language;
    data['displayCarriers'] = displayCarriers;
    data['gtinScanning'] = gtinScanning;
    data['subscriptionExpired'] = subscriptionExpired;
    if (systemLabels != null) {
      data['systemLabels'] = systemLabels!.toJson();
    }
    data['features'] = features;
    data['enterpriseId'] = enterpriseId;
    data['supplierId'] = supplierId;
    data['headquarterSupplierId'] = headquarterSupplierId;
    return data;
  }

  // copyWith
  LoginData copyWith({
    int? id,
    int? status,
    String? userName,
    String? access1,
    String? language,
    bool? displayCarriers,
    bool? gtinScanning,
    bool? subscriptionExpired,
    SystemLabels? systemLabels,
    List<String>? features,
    int? enterpriseId,
    int? supplierId,
    int? headquarterSupplierId,
  }) {
    return LoginData(
      id: id ?? this.id,
      status: status ?? this.status,
      userName: userName ?? this.userName,
      access1: access1 ?? this.access1,
      language: language ?? this.language,
      displayCarriers: displayCarriers ?? this.displayCarriers,
      gtinScanning: gtinScanning ?? this.gtinScanning,
      subscriptionExpired: subscriptionExpired ?? this.subscriptionExpired,
      systemLabels: systemLabels ?? this.systemLabels,
      features: features ?? this.features,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      supplierId: supplierId ?? this.supplierId,
      headquarterSupplierId:
          headquarterSupplierId ?? this.headquarterSupplierId,
    );
  }
}

class SystemLabels {
  String? iTEMGROUP1;

  SystemLabels({this.iTEMGROUP1});

  SystemLabels.fromJson(Map<String, dynamic> json) {
    iTEMGROUP1 = json['ITEM_GROUP_1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ITEM_GROUP_1'] = iTEMGROUP1;
    return data;
  }

  // copyWith
  SystemLabels copyWith({
    String? iTEMGROUP1,
  }) {
    return SystemLabels(
      iTEMGROUP1: iTEMGROUP1 ?? this.iTEMGROUP1,
    );
  }
}
