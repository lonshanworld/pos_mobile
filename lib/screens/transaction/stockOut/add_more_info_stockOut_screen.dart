import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextArea_widget.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';
import 'package:pos_mobile/widgets/stockout_detail_box_widget.dart';
import 'package:pos_mobile/widgets/voucher_box_widget.dart';

import '../../../constants/enums.dart';
import '../../../controller/ui_controller.dart';
import '../../../models/item_model_folder/item_model.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../utils/formula.dart';
import '../../../widgets/cusTxt_widget.dart';

class AddMoreInfoStockOutScreen extends StatefulWidget {

  final Function({
    required double? deliveryChargesInfo,
    required double taxPercentageInfo,
    required double? additionalPromotionAmountInfo,
    required String? descriptionInfo,
    required String? customerNameInfo,
    required String? deliveryNameInfo,
    required ShoppingType shoppingTypeInfo,
    required PaymentMethod paymentMethodInfo,
    required PromotionModel? promotionModel,
  }) func;
  final List<UniqueItemModel> selectedUniqueItemList;
  final List<ItemModel> selectedItemModelList;
  final double? deliveryChargesInfo;
  final double taxPercentageInfo;
  final double? additionalPromotionAmountInfo;
  final String? descriptionInfo;
  final String? customerNameInfo;
  final String? deliveryNameInfo;
  final ShoppingType shoppingTypeInfo;
  final PaymentMethod paymentMethodInfo;
  final PromotionModel? promotionModel;
  const AddMoreInfoStockOutScreen({
    super.key,
    required this.func,
    required this.selectedUniqueItemList,
    required this.selectedItemModelList,
    required this.deliveryChargesInfo,
    required this.taxPercentageInfo,
    required this.additionalPromotionAmountInfo,
    required this.descriptionInfo,
    required this.customerNameInfo,
    required this.deliveryNameInfo,
    required this.shoppingTypeInfo,
    required this.paymentMethodInfo,
    required this.promotionModel,
  });

  @override
  State<AddMoreInfoStockOutScreen> createState() => _AddMoreInfoStockOutScreenState();
}

class _AddMoreInfoStockOutScreenState extends State<AddMoreInfoStockOutScreen> {

  final TextEditingController deliveryChargesController = TextEditingController();
  final TextEditingController taxPercentageController = TextEditingController();
  final TextEditingController additionalPromotionAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController deliveryNameController = TextEditingController();

  ShoppingType shoppingType = ShoppingType.shop;
  PaymentMethod paymentMethod = PaymentMethod.cash;
  PromotionModel? selectedPromotionModel;

  void reloadScreen(){
    if(mounted){
      setState(() {

      });
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if(widget.deliveryChargesInfo != null){
        deliveryChargesController.text = widget.deliveryChargesInfo.toString();
      }

      if(widget.additionalPromotionAmountInfo != null){
        additionalPromotionAmountController.text = widget.additionalPromotionAmountInfo.toString();
      }

      taxPercentageController.text = widget.taxPercentageInfo.toString();

      descriptionController.text = widget.descriptionInfo ?? "";
      customerNameController.text = widget.customerNameInfo ?? "";
      deliveryNameController.text = widget.deliveryNameInfo ?? "";
      shoppingType = widget.shoppingTypeInfo;
      paymentMethod = widget.paymentMethodInfo;
      selectedPromotionModel = widget.promotionModel;
    });
    deliveryChargesController.addListener(() {
      reloadScreen();
    });
    taxPercentageController.addListener(() {
      reloadScreen();
    });
    additionalPromotionAmountController.addListener(() {
      reloadScreen();
    });
    descriptionController.addListener(() {
      reloadScreen();
    });
    customerNameController.addListener(() {
      reloadScreen();
    });
    deliveryNameController.addListener(() {
      reloadScreen();
    });

  }

  @override
  void dispose() {
    deliveryChargesController.dispose();
    taxPercentageController.dispose();
    additionalPromotionAmountController.dispose();
    descriptionController.dispose();
    customerNameController.dispose();
    // descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final List<PromotionModel> promotionList = context.watch<PromotionCubit>().state.activePromotionList;

    //
    // double getAllPrice(){
    //   double price = 0;
    //
    //   for(int i = 0; i < widget.selectedUniqueItemList.length; i++){
    //     final PromotionModel? promotionData = context.read<PromotionCubit>().getSinglePromotionFromItemId(widget.selectedUniqueItemList[i].itemId);
    //     price = price + CalculationFormula.getItemAfterPromotionPrice(
    //
    //       sellPrice: CalculationFormula.getItemSellPrice(
    //         originalPrice: widget.selectedUniqueItemList[i].originalPrice,
    //         profitPrice: widget.selectedUniqueItemList[i].profitPrice,
    //         taxPercentage: widget.selectedUniqueItemList[i].taxPercentage,
    //       ),
    //       promotionPrice: promotionData == null ? 0 : promotionData.promotionPrice,
    //       promotionPercentage: promotionData == null ? 0 : promotionData.promotionPercentage,
    //     );
    //   }
    //   return price;
    // }

    Widget cusTxtFieldStockOut({
      required TextEditingController txtController,
      required String hintTxt,
      required TextInputType txtInputType,
    }){
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.mediumSpace,
        ),
        child: CusTextFieldLogin(
          txtController: txtController,
          verticalPadding: UIConstants.mediumSpace,
          horizontalPadding: UIConstants.bigSpace,
          hintTxt: hintTxt,
          txtInputType: txtInputType,
          txtStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    Widget nameWidget(String name){
      return Align(
        alignment: Alignment.centerLeft,
        child: CusTxtWidget(
          txtStyle: Theme.of(context).textTheme.titleSmall!,
          txt: name,
        ),
      );
    }

    Widget cusTxtWidgetBodyMedium(String value) => CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.bodyMedium!,
      txt: value,
    );

    Widget cusTxtWidgetTitleSmall(String value) => CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.titleSmall!,
      txt: value,
    );

    Widget cusTxtWidgetTitleMedium(String value) => CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.titleMedium!,
      txt: value,
    );

    double getAllPrice(){
      double price = 0;
      for(int i = 0; i < widget.selectedUniqueItemList.length; i++){
        final PromotionModel? promotionData = context.read<PromotionCubit>().getSinglePromotionFromItemId(widget.selectedUniqueItemList[i].itemId);

        price = price + CalculationFormula.getItemAfterPromotionPrice(
          sellPrice: CalculationFormula.getItemSellPrice(
            originalPrice: widget.selectedUniqueItemList[i].originalPrice,
            profitPrice: widget.selectedUniqueItemList[i].profitPrice,
            taxPercentage: widget.selectedUniqueItemList[i].taxPercentage,
          ),
          promotionPercentage: promotionData == null ? 0 : promotionData.promotionPercentage,
          promotionPrice: promotionData == null ? 0 : promotionData.promotionPrice,
        );
      }
      return price;
    }

    Widget dataRow(Widget titleWidget, Widget txtWidget){
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: UIConstants.smallSpace
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            titleWidget,
            txtWidget,
          ],
        ),
      );
    }



    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add more Info"),
        leading: const CusLeadingBackIconBtn(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.bigSpace,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: Alignment.center,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.grey,
                  ),
                  txt: "Details",
                ),
              ),
              if(customerNameController.text.trim().isNotEmpty && customerNameController.text.trim() != "")nameWidget(
                  "Customer Name -  ${customerNameController.text.trim()}",
              ),
              if(deliveryNameController.text.trim().isNotEmpty && deliveryNameController.text.trim() != "")nameWidget(
                  "Delivery Name -  ${deliveryNameController.text.trim()}",
              ),
              ...widget.selectedItemModelList.asMap().entries.map((e){
                List<UniqueItemModel> dataList = [];
                for(int a =0; a < widget.selectedUniqueItemList.length; a++){
                  if(widget.selectedUniqueItemList[a].itemId == e.value.id){
                    dataList.add(widget.selectedUniqueItemList[a]);
                  }
                }
                PromotionModel? promotion = context.read<PromotionCubit>().getSinglePromotionFromItemId(e.value.id);
                double sellPrice = CalculationFormula.getItemSellPrice(
                  originalPrice: e.value.originalPrice,
                  profitPrice: e.value.profitPrice,
                  taxPercentage: e.value.taxPercentage ?? 0,
                );
                double finalSellPrice = sellPrice;
                if(promotion != null){
                  finalSellPrice = CalculationFormula.getItemAfterPromotionPrice(
                      sellPrice: sellPrice,
                      promotionPercentage: promotion.promotionPercentage,
                      promotionPrice: promotion.promotionPrice,
                  );
                }

                return StockOutDetailBoxWidget(
                  itemName: e.value.name,
                  count: dataList.length.toString(),
                  sellPrice: sellPrice.toString(),
                  finalSellPrice: promotion == null ? " -- " : finalSellPrice.toString(),
                  totalPrice: (finalSellPrice *  dataList.length).toString(),
                  index: (e.key + 1).toString(),
                );
              }).toList(),

              dataRow(
                cusTxtWidgetTitleSmall("Price"),
                cusTxtWidgetTitleSmall(getAllPrice().toString()),
              ),
              dataRow(
                cusTxtWidgetBodyMedium("Shopping Type"),
                cusTxtWidgetBodyMedium(shoppingType.name.toUpperCase()),
              ),
              dataRow(
                cusTxtWidgetBodyMedium("Payment Method"),
                cusTxtWidgetBodyMedium(paymentMethod.name.toUpperCase()),
              ),
              dataRow(
                cusTxtWidgetBodyMedium("Tax (MMK)"),
                cusTxtWidgetBodyMedium(CalculationFormula.getPercentageToMMK(getAllPrice(), double.tryParse(taxPercentageController.text.trim()) ?? 0).toString()),
              ),
              if(additionalPromotionAmountController.text.trim().isNotEmpty && additionalPromotionAmountController.text.trim() != "")dataRow(
                cusTxtWidgetTitleSmall("Additional Promotion"),
                cusTxtWidgetTitleSmall(additionalPromotionAmountController.text.trim().toString()),
              ),
              if(selectedPromotionModel != null)dataRow(
                cusTxtWidgetTitleSmall(selectedPromotionModel!.promotionPrice != null ? "Promotion (MMK)" : "Promotion (%)"),
                cusTxtWidgetTitleSmall(selectedPromotionModel!.promotionPrice != null ? selectedPromotionModel!.promotionPrice.toString() : selectedPromotionModel!.promotionPercentage.toString()),
              ),
              if(deliveryChargesController.text.trim().isNotEmpty && deliveryChargesController.text.trim() != "")dataRow(
                cusTxtWidgetBodyMedium("Deli-Charges"),
                cusTxtWidgetBodyMedium(deliveryChargesController.text.trim().toString()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.bigSpace,
                ),
                child: dataRow(
                  cusTxtWidgetTitleMedium("Total Price"),
                  cusTxtWidgetTitleMedium(
                      CalculationFormula.getFinalStockOutTotalPriceWithDeliCharges(
                        totalPrice: getAllPrice(),
                        taxPrice: CalculationFormula.getPercentageToMMK(getAllPrice(), double.tryParse(taxPercentageController.text.trim()) ?? 0),
                        additionalPromotionPrice: double.tryParse(additionalPromotionAmountController.text.trim()) ?? 0,
                        deliCharges: double.tryParse(deliveryChargesController.text.trim()) ?? 0,
                        promotionPercentage: selectedPromotionModel == null ? 0 : selectedPromotionModel!.promotionPercentage ?? 0,
                        promotionPrice: selectedPromotionModel == null ? 0 : selectedPromotionModel!.promotionPrice ?? 0,
                      ).toString()
                  ),
                ),
              ),

              if(descriptionController.text.trim().isNotEmpty && descriptionController.text.trim() != "")uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              if(descriptionController.text.trim().isNotEmpty && descriptionController.text.trim() != "")Align(
                alignment: Alignment.center,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txt: "NOTE -  ${descriptionController.text.trim()}",
                ),
              ),

              const CusDividerWidget(clr: Colors.grey),
              Align(
                alignment: Alignment.center,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.grey,
                  ),
                  txt: "These are optional and don't need to fill out all",
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              cusTxtFieldStockOut(
                txtController: customerNameController,
                hintTxt: "Enter customer name",
                txtInputType: TextInputType.text,
              ),

              cusTxtFieldStockOut(
                txtController: deliveryChargesController,
                hintTxt: "Enter delivery charges",
                txtInputType: TextInputType.number,
              ),
              cusTxtFieldStockOut(
                txtController: deliveryNameController,
                hintTxt: "Enter deli-person name",
                txtInputType: TextInputType.text,
              ),
              cusTxtFieldStockOut(
                txtController: taxPercentageController,
                hintTxt: "Enter tax percentage",
                txtInputType: TextInputType.number,
              ),
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              CusTxtWidget(
                txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.grey,
                ),
                txt: "Promotions",
              ),

              DropdownButton(
                value: selectedPromotionModel,
                dropdownColor: uiController.getpureDirectClr(themeModeType),
                borderRadius: UIConstants.mediumBorderRadius,
                items: promotionList.map((e) => DropdownMenuItem<PromotionModel>(
                  value: e,
                  child: Text(
                    e.promotionPercentage == null ? "${e.promotionPrice} MMK" : "${e.promotionPercentage} %",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
                hint: Text(
                  "Select pre-created promotions",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey,
                  ),
                ),
                onChanged: (data){
                  if(mounted){
                    setState(() {
                      selectedPromotionModel = data;
                    });
                  }
                },
              ),
              if(selectedPromotionModel != null)CusTxtElevatedBtn(
                txt: "Remove selected promotion",
                verticalpadding: UIConstants.smallSpace,
                horizontalpadding: UIConstants.mediumSpace,
                bdrRadius: UIConstants.smallRadius,
                bgClr: Colors.red,
                func: (){
                  if(mounted){
                    setState(() {
                      selectedPromotionModel = null;
                    });
                  }
                },
                txtStyle: Theme.of(context).textTheme.titleSmall!,
                txtClr: Colors.white,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),

              cusTxtFieldStockOut(
                txtController: additionalPromotionAmountController,
                hintTxt: "Enter additional promotion amount MMK(ကျပ်)",
                txtInputType: TextInputType.number,
              ),

              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              CusTextArea(
                txtController: descriptionController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace,
                hintTxt: "Enter note or description",
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleSmall!,
                    txt: "Choose Shopping Type   ",
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: DropdownButton(
                      dropdownColor: uiController.getpureDirectClr(themeModeType),
                      borderRadius: UIConstants.mediumBorderRadius,
                      value: shoppingType,
                      items: ShoppingType.values.map((e) => DropdownMenuItem<ShoppingType>(
                        value: e,
                        child: Text(
                          e.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      )).toList(),
                      onChanged: (data){
                        if(data != null){
                          if(mounted){
                            setState(() {
                              shoppingType = data;
                            });
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleSmall!,
                    txt: "Choose Payment   ",
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: DropdownButton(
                      dropdownColor: uiController.getpureDirectClr(themeModeType),
                      borderRadius: UIConstants.mediumBorderRadius,
                      value: paymentMethod,
                      items: PaymentMethod.values.map((e) => DropdownMenuItem<PaymentMethod>(
                        value: e,
                        child: Text(
                          e.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      )).toList(),
                      onChanged: (data){
                        if(mounted){
                          setState(() {
                            paymentMethod = data!;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              CusTxtElevatedBtn(
                txt: "Save",
                verticalpadding: UIConstants.smallSpace,
                horizontalpadding: UIConstants.mediumSpace,
                bdrRadius: UIConstants.smallRadius,
                bgClr: Colors.green,
                func: (){
                  widget.func(
                    deliveryChargesInfo: double.tryParse(deliveryChargesController.text.trim()),
                    taxPercentageInfo: double.tryParse(taxPercentageController.text.trim()) ?? 0,
                    additionalPromotionAmountInfo: double.tryParse(additionalPromotionAmountController.text.trim()),
                    descriptionInfo: descriptionController.text.trim() == "" ? null : descriptionController.text.trim(),
                    customerNameInfo: customerNameController.text.trim() == "" ? null : customerNameController.text.trim(),
                    deliveryNameInfo: deliveryNameController.text.trim() == "" ? null : deliveryNameController.text.trim(),
                    shoppingTypeInfo: shoppingType,
                    paymentMethodInfo: paymentMethod,
                    promotionModel: selectedPromotionModel,
                  );
                  Navigator.of(context).pop();
                },
                txtStyle: Theme.of(context).textTheme.titleSmall!,
                txtClr: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
