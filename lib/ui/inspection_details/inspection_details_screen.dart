import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/inspection_details_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class InspectionDetailsScreen extends StatelessWidget {
  final String uniqueTag;
  const InspectionDetailsScreen({super.key, required this.uniqueTag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionDetailsController>(
      init: InspectionDetailsController(),
      tag: uniqueTag,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leading: const Offstage(),
            leadingWidth: 0,
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            title: HeaderContentView(
              title: AppStrings.inspectionDetails,
            ),
          ),
          body: Column(
            children: [
              // 1 Partner Name
              _widgetPartnerNameWidget(controller),

              // 2 Commodity
              _widgetCommodityInfoWidget(controller),

              // 3 Specification Drop Down
              _widgetCommonDropDown<String>(
                AppStrings.specification,
                controller.specificationArray,
                controller.selectedSpecification,
                (value) async {
                  if (value != null) {
                    controller.onSpinnerChange(value);
                  }
                },
                (item) => Text(item),
                AppStrings.selectSpecification,
                height: 50,
              ),

              // 4 GTIN Packaging Drop Down
              _widgetCommonDropDown<String>(
                AppStrings.gtin,
                controller.specificationPackagingGTINArray,
                controller.selectedSpecificationPackagingGTIN,
                (value) {
                  controller.selectedSpecificationPackagingGTIN = value;
                  controller.update();
                },
                (item) => Text(item),
                "",
                height: 30,
              ),

              // 5 Quality Control  Details
              const SizedBox(height: 20),
              _widgetQualityControlDetails(
                onTap: () {
                  controller.onQualityControllDetailsButtonClick();
                },
                context: context,
              ),

              // 6 Overridden Result
              const SizedBox(height: 60),
              _widgetOvveriddenResult(
                context: context,
                controller: controller,
                onTap: () {
                  controller.onEditInspectionButtonClick();
                },
              ),
              const Spacer(),
              FooterContentView(
                hasLeftButton: false,
              ),
              _widgetBottomButtons(
                context,
                controller: controller,
                onQcHeaderClick: () {
                  controller.onQcHeaderButtonClick();
                },
                onCalculateResultClick: () {
                  controller.calculateButtonClick(context);
                },
                onSaveClick: () {
                  controller.onSaveButtonClick();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Partner Name Widget
  Widget _widgetPartnerNameWidget(InspectionDetailsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.textFieldText_Color,
      width: double.infinity,
      child: Text(
        controller.partnerName,
        textAlign: TextAlign.start,
        maxLines: 3,
        style: Get.textTheme.titleLarge!
            .copyWith(fontSize: 38.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  //Commodity Info Widget
  Widget _widgetCommodityInfoWidget(InspectionDetailsController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.orange,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.commodityName,
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            controller.varietyName,
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetCommonDropDown<T>(
    String labelText,
    List<T> itemList,
    T? selectedItem,
    ValueChanged<T?> onChanged,
    Widget Function(T) itemBuilder,
    String hintText, {
    required double height,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: height),
          Text(
            labelText,
            style: Get.textTheme.titleLarge!.copyWith(fontSize: 36.sp),
          ),
          DropdownButtonFormField<T>(
            iconSize: 30,
            iconEnabledColor: AppColors.grey2,
            iconDisabledColor: AppColors.grey2,
            value: selectedItem,
            onChanged: onChanged,
            items: itemList.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: itemBuilder(item),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 24.sp,
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
            ),
            dropdownColor: AppColors.grey,
          ),
          const SizedBox(height: 10),
          // Divider(
          //   color: AppColors.lightGrey,
          //   height: 1,
          //   thickness: 1,
          // ),
        ],
      ),
    );
  }

  Widget _widgetQualityControlDetails({
    required Function() onTap,
    required BuildContext context,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.89,
        decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.black,
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(AppImages.circleDone, height: 30),
              Text(
                AppStrings.qualityControlButton,
                style: Get.textTheme.titleLarge!.copyWith(
                  color: AppColors.textFieldText_Color,
                  fontSize: 44.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(AppImages.editPencil, height: 30)
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetOvveriddenResult(
      {required InspectionDetailsController controller,
      required BuildContext context,
      required Function() onTap}) {
    return Visibility(
      visible: controller.isShowSaveButton.value,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: AppColors.orange,
            ),
            borderRadius: BorderRadius.circular(20)),
        width: MediaQuery.of(context).size.width * 0.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.inspectionResultText,
                    style: Get.textTheme.titleLarge!.copyWith(
                      color: controller.inspectionTextColor,
                      fontSize: 44.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                      onTap: onTap,
                      child: Image.asset(AppImages.editPencil, height: 30))
                ],
              ),
              Visibility(
                visible: controller.rejectionLayout.value,
                child: _commonRowTextFieldView(
                  context,
                  AppStrings.qtyRejected,
                  controller.qtyRejectedController.text,
                  controller.qtyRejectedController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetBottomButtons(
    BuildContext context, {
    required Function onQcHeaderClick,
    required Function onCalculateResultClick,
    required Function onSaveClick,
    required InspectionDetailsController controller,
  }) {
    return Container(
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
            customButton(
              backgroundColor: AppColors.white,
              title: AppStrings.qc_header,
              width: (MediaQuery.of(context).size.width / 4),
              height: 115,
              fontStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textFieldText_Color,
              ),
              onClickAction: onQcHeaderClick,
            ),
            SizedBox(width: 78.w),
            customButton(
              backgroundColor: AppColors.white,
              title: AppStrings.inspectionCalculateResultButton,
              width: (MediaQuery.of(context).size.width / 3.3),
              height: 115,
              fontStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textFieldText_Color,
              ),
              onClickAction: onCalculateResultClick,
            ),
            SizedBox(width: 78.w),
            controller.isShowSaveButton.value
                ? customButton(
                    backgroundColor: AppColors.white,
                    title: AppStrings.save,
                    width: (MediaQuery.of(context).size.width / 4.3),
                    height: 115,
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFieldText_Color,
                    ),
                    onClickAction: onSaveClick,
                  )
                : SizedBox(
                    width: (MediaQuery.of(context).size.width / 4.3),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _commonRowTextFieldView(
    BuildContext context,
    String labelTitle,
    String placeHolder,
    TextEditingController controller, {
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Text(
          labelTitle,
          style: Get.textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          width: 350.w,
          child: Container(
            alignment: Alignment.center,
            height: 105.h,
            child: TextFormField(
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (value) {},
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              autofocus: false,
              minLines: 1,
              maxLines: 1,
              onTap: () {},
              enabled: enabled,
              readOnly: readOnly,
              keyboardType: TextInputType.name,
              controller: controller,
              style: Get.textTheme.titleLarge!.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.hintColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                hintText: placeHolder,
                hintStyle: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                suffixIcon: hasValidOrderNo(controller)
                    ? null
                    : IconButton(
                        icon:
                            const Icon(Icons.info, color: Colors.red, size: 24),
                        onPressed: () {
                          AppSnackBar.error(
                              message: "Please enter a valid value");
                        },
                      ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool hasValidOrderNo(TextEditingController controller) {
    return controller.text.trim().isNotEmpty;
  }
}
