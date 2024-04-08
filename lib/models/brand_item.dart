class BrandItem {
  int? brandID;
  String? brandName;
  bool? privateLabel;

  BrandItem({this.brandID, this.brandName, this.privateLabel});

  BrandItem.fromJson(Map<String, dynamic> json) {
    brandID = json['brandID'];
    brandName = json['brandName'];
    privateLabel = json['privateLabel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['brandID'] = brandID;
    data['brandName'] = brandName;
    data['privateLabel'] = privateLabel;
    return data;
  }

  BrandItem copyWith({
    int? brandID,
    String? brandName,
    bool? privateLabel,
  }) {
    return BrandItem(
      brandID: brandID ?? this.brandID,
      brandName: brandName ?? this.brandName,
      privateLabel: privateLabel ?? this.privateLabel,
    );
  }
}
