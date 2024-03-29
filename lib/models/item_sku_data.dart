class FinishedGoodsItemSKU {
  String? SKU_ID;
  String? Code;
  String? Commodity_ID;
  String? Name;
  String? Description;
  String? Status;
  String? ItemGroup1_ID;
  String? ItemGroup2_ID;
  String? GradeID;
  String? Packaging_ID;
  String? Usage_Type;
  String? Commodity_Category_ID;
  String? Item_Type;
  String? Global_Partner_Id;
  String? Company_Id;
  String? Division_Id;
  String? Branded;
  String? FTL;

  FinishedGoodsItemSKU({
    this.SKU_ID,
    this.Code,
    this.Commodity_ID,
    this.Name,
    this.Description,
    this.Status,
    this.ItemGroup1_ID,
    this.ItemGroup2_ID,
    this.GradeID,
    this.Packaging_ID,
    this.Usage_Type,
    this.Commodity_Category_ID,
    this.Item_Type,
    this.Global_Partner_Id,
    this.Company_Id,
    this.Division_Id,
    this.Branded,
    this.FTL,
  });

  factory FinishedGoodsItemSKU.fromJson(Map<String, dynamic> json) {
    return FinishedGoodsItemSKU(
      SKU_ID: json['SKU_ID'],
      Code: json['Code'],
      Commodity_ID: json['Commodity_ID'],
      Name: json['Name'],
      Description: json['Description'],
      Status: json['Status'],
      ItemGroup1_ID: json['ItemGroup1_ID'],
      ItemGroup2_ID: json['ItemGroup2_ID'],
      GradeID: json['GradeID'],
      Packaging_ID: json['Packaging_ID'],
      Usage_Type: json['Usage_Type'],
      Commodity_Category_ID: json['Commodity_Category_ID'],
      Item_Type: json['Item_Type'],
      Global_Partner_Id: json['Global_Partner_Id'],
      Company_Id: json['Company_Id'],
      Division_Id: json['Division_Id'],
      Branded: json['Branded'],
      FTL: json['FTL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SKU_ID': SKU_ID,
      'Code': Code,
      'Commodity_ID': Commodity_ID,
      'Name': Name,
      'Description': Description,
      'Status': Status,
      'ItemGroup1_ID': ItemGroup1_ID,
      'ItemGroup2_ID': ItemGroup2_ID,
      'GradeID': GradeID,
      'Packaging_ID': Packaging_ID,
      'Usage_Type': Usage_Type,
      'Commodity_Category_ID': Commodity_Category_ID,
      'Item_Type': Item_Type,
      'Global_Partner_Id': Global_Partner_Id,
      'Company_Id': Company_Id,
      'Division_Id': Division_Id,
      'Branded': Branded,
      'FTL': FTL,
    };
  }
}
