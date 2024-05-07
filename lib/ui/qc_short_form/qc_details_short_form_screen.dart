import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/controller/qc_details_short_form_screen_controller.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/ui/qc_short_form/spec_analytical_table.dart';
import 'package:pverify/ui/side_drawer.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class QCDetailsShortFormScreen
    extends GetWidget<QCDetailsShortFormScreenController> {
  final String tag;
  const QCDetailsShortFormScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QCDetailsShortFormScreenController>(
      init: QCDetailsShortFormScreenController(),
      tag: tag,
      builder: (controller) {
        if (!controller.hasInitialised.value) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: SizedBox(
                        height: 25, width: 25, child: ProgressAdaptive())),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leadingWidth: 0,
            automaticallyImplyLeading: false,
            leading: const Offstage(),
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0,
            title: DrawerHeaderContentView(
              title: AppStrings.title_activity_q_c__details_short_form,
            ),
          ),
          drawer: SideDrawer(
            onDefectSaveAndCompleteTap: () async {
              await controller.saveContinue(context);
            },
            onDiscardTap: () async {
              await controller.deleteInspectionAndGotoMyInspectionScreen();
            },
            onCameraTap: () async {
              await controller.onCameraMenuTap();
            },
            onSpecInstructionTap: () async {
              await controller.onSpecialInstrMenuTap();
            },
            onSpecificationTap: () async {
              await controller.onSpecificationTap();
            },
            onGradeTap: () async {
              await JsonFileOperations.instance.viewGradePdf();
            },
            onInspectionTap: () async {
              await JsonFileOperations.instance.viewSpecInsPdf();
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: AppColors.textFieldText_Color,
                width: double.infinity,
                child: Text(
                  controller.partnerName ?? '-',
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w600,
                      textStyle: TextStyle(color: AppColors.white)),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              orderItemHeading(controller),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  gtinWidget(controller),
                                  glnWidget(controller),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  lotNumberWidget(controller),
                                  packDateWidget(controller, context),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  qcQtyShippedWidget(controller),
                                  uomWidget(controller),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 40, bottom: 10),
                                  child: SpecAnalyticalTable(tag: tag)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 20.h,
                        top: 20.h,
                      ),
                      color: AppColors.primaryColor,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            worksheetWidget(controller, context),
                            SizedBox(
                              width: 38.w,
                            ),
                            detailedFormWidget(context, controller),
                            SizedBox(
                              width: 20.w,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                size: 50,
                              ),
                              onPressed: () {
                                controller.onCameraMenuTap();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 20.h,
                        top: 20.h,
                      ),
                      color: AppColors.grey2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            defectDiscardWidget(context, controller),
                            SizedBox(
                              width: 38.w,
                            ),
                            saveAndContinueWidget(context, controller),
                          ],
                        ),
                      ),
                    ),
                    FooterContentView()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget saveAndContinueWidget(
      BuildContext context, QCDetailsShortFormScreenController controller) {
    return customButton(
        backgroundColor: AppColors.white,
        title: AppStrings.saveAndContinue,
        width: (MediaQuery.of(context).size.width / 2.3),
        height: 115,
        fontStyle: GoogleFonts.poppins(
            fontSize: 35.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(color: AppColors.textFieldText_Color)),
        onClickAction: () async {
          await controller.saveContinue(context);
        });
  }

  Widget defectDiscardWidget(
      BuildContext context, QCDetailsShortFormScreenController controller) {
    return customButton(
        backgroundColor: AppColors.white,
        title: AppStrings.defectDiscard,
        width: (MediaQuery.of(context).size.width / 2.3),
        height: 115,
        fontStyle: GoogleFonts.poppins(
            fontSize: 35.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(color: AppColors.textFieldText_Color)),
        onClickAction: () async {
          await controller.deleteInspectionAndGotoMyInspectionScreen();
        });
  }

  Widget detailedFormWidget(
      BuildContext context, QCDetailsShortFormScreenController controller) {
    return customButton(
        backgroundColor: AppColors.white,
        title: AppStrings.detailedForm,
        width: (MediaQuery.of(context).size.width / 2.5),
        height: 115,
        fontStyle: GoogleFonts.poppins(
            fontSize: 35.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(color: AppColors.textFieldText_Color)),
        onClickAction: () async {
          await controller.onLongFormClick();
        });
  }

  Widget worksheetWidget(
      QCDetailsShortFormScreenController controller, BuildContext context) {
    return customButton(
        backgroundColor:
            (controller.specificationTypeName != "Finished Goods Produce" &&
                    controller.specificationTypeName != "Raw Produce")
                ? AppColors.grey2
                : AppColors.white,
        title: AppStrings.inspectionWorksheet,
        width: (MediaQuery.of(context).size.width / 2.5),
        height: 115,
        fontStyle: GoogleFonts.poppins(
            fontSize: 35.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(color: AppColors.textFieldText_Color)),
        onClickAction: () async {
          await controller.onInspectionWorksheetClick();
        });
  }

  Expanded uomWidget(QCDetailsShortFormScreenController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.uom,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          DropdownButtonFormField<UOMItem>(
            value: controller.selectedUOM,
            onChanged: (UOMItem? value) {
              controller.selectedUOM = value;
              controller.update();
            },
            items: controller.uomList.map((UOMItem value) {
              return DropdownMenuItem<UOMItem>(
                value: value,
                child: Text(value.uomName ?? '-',
                    style:
                        Get.textTheme.bodyLarge!.copyWith(color: Colors.white)),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: AppStrings.uom,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                fontSize: 26.sp,
                color: AppColors.grey,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            dropdownColor: AppColors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Expanded qcQtyShippedWidget(QCDetailsShortFormScreenController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.qcQtyShipped,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.darkSkyBlue,
                height: 1,
              ),
            ],
          ),
          TextField(
            controller: controller.qtyShippedController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: AppStrings.qcQtyShipped,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Expanded packDateWidget(
      QCDetailsShortFormScreenController controller, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.packdate,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.darkSkyBlue,
                height: 1,
              ),
            ],
          ),
          TextField(
            controller: controller.packDateController,
            readOnly: true,
            autofocus: false,
            focusNode: controller.packDateFocusNode,
            decoration: InputDecoration(
              hintText: AppStrings.packdate,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              suffixIcon: GestureDetector(
                  onTap: () async {
                    await selectPackDate(context, controller);
                  },
                  child: const Icon(Icons.calendar_month_outlined)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Expanded lotNumberWidget(QCDetailsShortFormScreenController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.lotnumber,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.darkSkyBlue,
                height: 1,
              ),
            ],
          ),
          TextField(
            controller: controller.lotNoController,
            decoration: InputDecoration(
              hintText: AppStrings.lotnumber,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Expanded glnWidget(QCDetailsShortFormScreenController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.gln,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                    glnSuffix(controller),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.darkSkyBlue,
                height: 1,
              ),
            ],
          ),
          TextField(
            controller: controller.glnController,
            decoration: InputDecoration(
              hintText: AppStrings.gln,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Expanded gtinWidget(QCDetailsShortFormScreenController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.gtin,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                    gtinSuffix(controller),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.darkSkyBlue,
                height: 1,
              ),
            ],
          ),
          TextField(
            controller: controller.gtinController,
            decoration: InputDecoration(
              hintText: AppStrings.gtin,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Future<void> selectPackDate(
    BuildContext context,
    QCDetailsShortFormScreenController controller,
  ) async {
    await controller.selectDate(context,
        onDateSelected: (DateTime selectedDate) {
      controller.packDateController.text = Utils.formatDate(selectedDate);
      controller.packDate = selectedDate;
      controller.update();
    }, firstDate: controller.packDate, lastDate: DateTime(2100));
  }

  GestureDetector gtinSuffix(QCDetailsShortFormScreenController controller) {
    return GestureDetector(
      onTap: () async {
        await controller.scanBarcode(onScanResult: (scanResult) async {
          String? scannedCode = scanGTINResultContents(scanResult, controller);
          if (scannedCode != null) {
            controller.gtinController.text = scannedCode;
            controller.update();
          }
        });
      },
      child: Image.asset(
        AppImages.scanner,
        height: 30,
        width: 30,
      ),
    );
  }

  GestureDetector glnSuffix(QCDetailsShortFormScreenController controller) {
    return GestureDetector(
      onTap: () async {
        await controller.scanBarcode(onScanResult: (scanResult) {
          controller.glnController.text = scanResult;
          controller.update();
        });
      },
      child: Image.asset(
        AppImages.scanner,
        height: 30,
        width: 30,
      ),
    );
  }

  Widget orderItemHeading(QCDetailsShortFormScreenController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.itemSkuName ?? '-',
          textAlign: TextAlign.start,
          maxLines: 3,
          style: GoogleFonts.poppins(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        Text(
          controller.itemSKU ?? '-',
          textAlign: TextAlign.start,
          maxLines: 3,
          style: GoogleFonts.poppins(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }

  String? scanGTINResultContents(
      String scanResult, QCDetailsShortFormScreenController controller) {
    String barcoderesult = scanResult;

    String? gtin = '';
    String packdate2 = "";

    // TODO: implement this
    /*if (barcoderesult.length > 18) {
      String check01;
      if (barcoderesult.startsWith("(")) {
        check01 = barcoderesult.substring(1, 3);
        if (check01 == "01") {
          gtin = barcoderesult.substring(4, 18);
          print("gtin = $gtin");

          if (barcoderesult.length >= 28) {
            String check02 = barcoderesult.substring(19, 21);
            print("gtin 1 = $check02");

            if (check02 == "11" ||
                check02 == "12" ||
                check02 == "13" ||
                check02 == "15" ||
                check02 == "16" ||
                check02 == "17") {
              packdate2 = barcoderesult.substring(22, 28);
              print("gtin 2 = $packdate2");

              dateType = check02;
              if (check02 == "11") {
                dateTypeDesc = "Production Date";
              } else if (check02 == "12") {
                dateTypeDesc = "Due Date";
              } else if (check02 == "13") {
                dateTypeDesc = "Pack Date";
              } else if (check02 == "15") {
                dateTypeDesc = "Best Before Date";
              } else if (check02 == "16") {
                dateTypeDesc = "Sell By Date";
              } else if (check02 == "17") {
                dateTypeDesc = "Expiration Date";
              }

              DateFormat fromUser = DateFormat("yyMMdd");
              DateFormat myFormat = DateFormat("MM-dd-yyyy");

              try {
                pack_Date = myFormat.format(fromUser.parse(packdate2));
              } catch (e) {
                print(e);
              }

              edit_packDate.text = pack_Date;

              if (barcoderesult.length >= 32) {
                String check03 = barcoderesult.substring(29, 31);
                print("gtin 3 = $check03");
                if (check03 == "10") {
                  lot_No = barcoderesult.substring(32, barcoderesult.length);
                  print("gtin 3 = $lot_No");
                  edit_LotNo.text = lot_No;
                } else {
                  Fluttertoast.showToast(
                      msg: "Error reading GTIN Barcode",
                      toastLength: Toast.LENGTH_LONG);
                }
              } else {
                Fluttertoast.showToast(
                    msg: "Error reading GTIN Barcode",
                    toastLength: Toast.LENGTH_LONG);
              }
            } else if (check02 == "10") {
              lot_No = barcoderesult.substring(22, barcoderesult.length);
              print("gtin 3 = $lot_No");
              edit_LotNo.text = lot_No;
            } else {
              Fluttertoast.showToast(
                  msg: "Error reading GTIN Barcode",
                  toastLength: Toast.LENGTH_LONG);
            }
          } else {
            Fluttertoast.showToast(
                msg: "Error reading GTIN Barcode",
                toastLength: Toast.LENGTH_LONG);
          }
        } else {
          Fluttertoast.showToast(
              msg: "Error reading GTIN Barcode",
              toastLength: Toast.LENGTH_LONG);
        }
      }
    }*/

    return gtin;
  }
}
