import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/models/promotion_model_folder/promotion_model.dart";
import "package:pos_mobile/widgets/tables_folder/voucherTable.dart";
import "package:qr_flutter/qr_flutter.dart";

import "../blocs/promotion_bloc/promotion_cubit.dart";
import "../constants/enums.dart";
import "../constants/txtconstants.dart";
import "../constants/uiConstants.dart";
import "../controller/ui_controller.dart";
import "../feature/printer_font_changer.dart";
import "../models/item_model_folder/item_model.dart";
import "../models/item_model_folder/uniqueItem_model.dart";
import "../utils/formula.dart";
import "../utils/txt_formatters.dart";
import "cusTxt_widget.dart";
import "dividers/cus_divider_widget.dart";
import "logo_folder/logo_image_widget.dart";

class VoucherBox extends StatelessWidget {

  final String? customerName;
  final String? deliveryName;
  final List<UniqueItemModel> selectedUniqueItemList;
  final List<ItemModel> selectedItemModelList;
  final ShoppingType shoppingType;
  final PaymentMethod paymentMethod;
  final double? additionalPromotionAmount;
  final double? deliCharges;
  final String? description;
  final String? barCode;
  final double taxPercentage;
  final PromotionModel? promotionModel;

  final bool showAdditionalPromotion;
  const VoucherBox({
    super.key,
    required this.customerName,
    required this.deliveryName,
    required this.selectedUniqueItemList,
    required this.selectedItemModelList,
    required this.shoppingType,
    required this.paymentMethod,
    required this.additionalPromotionAmount,
    required this.deliCharges,
    required this.description,
    required this.barCode,
    required this.taxPercentage,
    required this.promotionModel,
    // required this.showItem,
    required this.showAdditionalPromotion,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final PrinterFontChanger printerFontChanger = PrinterFontChanger.instance;

    Widget cusTxtWidgetBodyMedium(String value) => CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Colors.black,
        fontSize: printerFontChanger.printerFontSize,
      ),
      txt: value,
    );

    Widget cusTxtWidgetTitleSmall(String value) => CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
        color: Colors.black,
        fontSize: printerFontChanger.printerFontSize,
      ),
      txt: value,
    );

    Widget cusTxtWidgetTitleMedium(String value) => CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: Colors.black,
        fontSize:printerFontChanger.printerFontSize * 1.4 ,
      ),
      txt: value,
    );

    double getAllPrice(){
      double price = 0;
      for(int i = 0; i < selectedUniqueItemList.length; i++){
        final PromotionModel? promotionData = context.read<PromotionCubit>().getSinglePromotionFromItemId(selectedUniqueItemList[i].itemId);

        price = price + CalculationFormula.getItemAfterPromotionPrice(
          sellPrice: CalculationFormula.getItemSellPrice(
            originalPrice: selectedUniqueItemList[i].originalPrice,
            profitPrice: selectedUniqueItemList[i].profitPrice,
            taxPercentage: selectedUniqueItemList[i].taxPercentage,
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

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: UIConstants.mediumSpace,
        vertical: UIConstants.bigSpace * 1.5,
      ),
      child: Column(
        children: [
          const LogoImageWidget(widthandheight: 140),
          Align(
            alignment: Alignment.center,
            child: Text(
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize * 0.8,
                overflow: TextOverflow.fade,
              ),
              TxtConstants.shopAddress,
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize * 1.1,
              ),
              txt: TxtConstants.phNum,
            ),
          ),
          uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
          Align(
            alignment: Alignment.centerLeft,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize,
              ),
              txt: TextFormatters.getDateTime(DateTime.now()),
            ),
          ),
          if(customerName != null && customerName != "")Align(
            alignment: Alignment.centerLeft,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize * 0.8,
              ),
              txt: "Customer Name -  ${customerName ?? ""}",
            ),
          ),
          if(deliveryName != null && deliveryName != "")Align(
            alignment: Alignment.centerLeft,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize * 0.8,
              ),
              txt: "Deli Name -  ${deliveryName ?? ""}",
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize,
              ),
              txt: "MMK (ကျပ်)",
            ),
          ),
          VoucherTable(uniqueItemList: selectedUniqueItemList, itemModelList: selectedItemModelList),
          const CusDividerWidget(clr: Colors.black),
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
            cusTxtWidgetBodyMedium(CalculationFormula.getPercentageToMMK(getAllPrice(), taxPercentage).toString()),
          ),
          if(additionalPromotionAmount != null && additionalPromotionAmount != 0 && showAdditionalPromotion)dataRow(
            cusTxtWidgetTitleSmall("Additional Promotion"),
            cusTxtWidgetTitleSmall(additionalPromotionAmount.toString()),
          ),
          if(promotionModel != null)dataRow(
            cusTxtWidgetTitleSmall(promotionModel!.promotionPrice != null ? "Promotion (MMK)" : "Promotion (%)"),
            cusTxtWidgetTitleSmall(promotionModel!.promotionPrice != null ? promotionModel!.promotionPrice.toString() : promotionModel!.promotionPercentage.toString()),
          ),
          if(deliCharges != null && deliCharges != 0)dataRow(
            cusTxtWidgetBodyMedium("Deli-Charges"),
            cusTxtWidgetBodyMedium(deliCharges.toString()),
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
                      taxPrice: CalculationFormula.getPercentageToMMK(getAllPrice(), taxPercentage),
                      additionalPromotionPrice: additionalPromotionAmount ?? 0,
                      deliCharges: deliCharges ?? 0,
                      promotionPercentage: promotionModel == null ? 0 : promotionModel!.promotionPercentage ?? 0,
                      promotionPrice: promotionModel == null ? 0 : promotionModel!.promotionPrice ?? 0,
                  ).toString()
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize,
              ),
              txt: "**********************",
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: printerFontChanger.printerFontSize,
                color: Colors.black,
              ),
              txt: "Thank you for your purchase",
            ),
          ),
          if(description != null && description != "")uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
          if(description != null && description != "")Align(
            alignment: Alignment.center,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize * 0.8,
              ),
              txt: "NOTE -  $description",
            ),
          ),
          if( barCode != null)QrImageView(
            data: barCode!,
            version: QrVersions.auto,
            size: 140,
            // embeddedImage: NetworkImage("https://media.istockphoto.com/id/1194465593/photo/young-japanese-woman-looking-confident.jpg?s=1024x1024&w=is&k=20&c=4hVpkslRGJNtl2cMKlrBul-h3gcSXncwkGYAg3LGqlg="),
            // embeddedImageStyle: QrEmbeddedImageStyle(
            //   size: Size(80, 80),
            // ),
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            errorStateBuilder: (cxt, err) {
              return const Center(
                child: Text(
                  "Uh oh! Something went wrong...",
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.center,
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize.toDouble(),
              ),
              txt: TxtConstants.noReturnNote,
            ),
          ),
        ],
      ),
    );
  }
}
