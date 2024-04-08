import 'package:flutter/material.dart';
import 'package:pverify/models/purchase_order_item.dart';

class PurchaseOrderListViewItem extends StatefulWidget {
  const PurchaseOrderListViewItem({
    super.key,
    required this.sku,
    required this.poNumber,
    required this.inspectButtonCallback,
    required this.goodsItem,
  });
  final String? sku;
  final String? poNumber;
  final Function inspectButtonCallback;

  final PurchaseOrderItem goodsItem;

  @override
  State<PurchaseOrderListViewItem> createState() =>
      _PurchaseOrderListViewItemState();
}

class _PurchaseOrderListViewItemState extends State<PurchaseOrderListViewItem> {
  late TextEditingController lotNumberController;

  late TextEditingController qtyRejectedController;

  late TextEditingController qtyShippedController;
  late TextEditingController packDateController;

  bool isComplete = false;

  bool isPartialComplete = false;

  @override
  void initState() {
    lotNumberController = TextEditingController();
    qtyRejectedController = TextEditingController();
    qtyShippedController = TextEditingController();
    packDateController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    lotNumberController.dispose();
    qtyRejectedController.dispose();
    qtyShippedController.dispose();
    packDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Name Placeholder",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "12345643",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Additional Info",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "Qty Rejected *",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: "Enter Qty Rejected",
              hintStyle: TextStyle(color: Colors.grey[600]),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
          Divider(
            color: Colors.grey[600],
            height: 10,
          ),
        ],
      ),
    );
  }

  String getPackDateType() {
    String dateTypeDesc = "Pack Date";
    String dateType = widget.goodsItem.packDate ?? '';
    if (dateType == "11") {
      dateTypeDesc = "Production Date";
    } else if (dateType == "12") {
      dateTypeDesc = "Due Date";
    } else if (dateType == "13") {
      dateTypeDesc = "Pack Date";
    } else if (dateType == "15") {
      dateTypeDesc = "Best Before Date";
    } else if (dateType == "16") {
      dateTypeDesc = "Sell By Date";
    } else if (dateType == "17") {
      dateTypeDesc = "Expiration Date";
    }
    return dateTypeDesc;
  }
}
