import 'package:flutter/material.dart';
import 'package:pverify/models/purchase_order_item.dart';

class PurchaseOrderListViewItem extends StatefulWidget {
  const PurchaseOrderListViewItem({
    super.key,
    required this.goodsItem,
    required this.infoTap,
    required this.inspectTap,
    required this.onTapEdit,
  });
  final Function()? infoTap;
  final Function()? inspectTap;
  final Function()? onTapEdit;

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          _InspectionNameIdInfo(),
          const SizedBox(
            height: 8,
          ),
          _InspectionStatusInfo(),
          const SizedBox(
            height: 8,
          ),
          // if (widget.goodsItem.isInspectionDone) _InspectionQuantity(),
          if (/*Random().nextBool()*/ true) _InspectionQuantity(),
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

  Widget _InspectionNameIdInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            widget.goodsItem.description ?? '-',
            // style: style,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 3,
          child: Text(
            widget.goodsItem.sku ?? '-',
            // style: style.copyWith(color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            // widget.goodsItem.isCompleted
            // Random().nextBool()
            true ? Icons.check_circle_outline : Icons.play_circle_outline,
            size: 36,
            color: Colors.black,
          ),
          onPressed: () {
            if (widget.inspectTap != null) {
              widget.inspectTap!();
            }
          },
        ),
        IconButton(
          // onPressed: widget.goodsItem.showInfo ? controller.onTapInfo() : null,
          onPressed: () {
            if (widget.infoTap != null) {
              widget.infoTap!();
            }
          },
          icon: Icon(
            Icons.info,
            size: 32,
            // color: widget.goodsItem.showInfo
            color: /*Random().nextBool()*/
                true ? Colors.purple[600] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _InspectionStatusInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Lot No. ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                if (widget.goodsItem.lotNumber != null)
                  TextSpan(
                    text: widget.goodsItem.lotNumber.toString(),
                    // style: style.copyWith(
                    //   color: Colors.grey[500],
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Pack Date ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                if (widget.goodsItem.packDate != null)
                  TextSpan(
                    // text: controller.formatDate(widget.goodsItem.packDate!),
                    text: (widget.goodsItem.packDate!),
                    // style: style.copyWith(
                    //   color: Colors.grey[500],
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          // child: widget.goodsItem.isInspectionDone
          child: /*Random().nextBool()*/
              true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 2),
                          decoration: BoxDecoration(
                            // color: widget.goodsItem.status
                            color: /*Random().nextBool()*/
                                true ? Colors.green : Colors.redAccent[700],
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Text(
                            // widget.goodsItem.status ? 'Accept' : 'Reject',
                            'Accept',
                            // style: style,
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        IconButton(
                          onPressed: () {
                            if (widget.onTapEdit != null) {
                              widget.onTapEdit!();
                            }
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
        ),
      ],
    );
  }

  Widget _InspectionQuantity() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Qty Shipped * ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                // if (widget.goodsItem.quantityShipped != null)
                TextSpan(
                  text: widget.goodsItem.lotNumber.toString(),
                  // style: style.copyWith(
                  //   color: Colors.grey[500],
                  //   fontWeight: FontWeight.normal,
                  // ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Qty Rejected * ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                if (widget.goodsItem.packDate != null)
                  TextSpan(
                    text: '200',
                    // style: style.copyWith(
                    //   color: Colors.grey[500],
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// TODO: implement above UI based on existing app logic
