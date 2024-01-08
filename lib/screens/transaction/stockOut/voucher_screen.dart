import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

import '../../../blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import '../../../blocs/item_bloc/item_cubit.dart';
import '../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../blocs/transactions_bloc/transactions_cubit.dart';
import '../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../constants/uiConstants.dart';
import '../../../controller/ui_controller.dart';
import '../../../error_handlers/error_handler.dart';
import '../../../feature/code_generator_feature.dart';
import '../../../models/item_model_folder/item_model.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../models/promotion_model_folder/promotion_model.dart';
import '../../../models/user_model_folder/user_model.dart';
import '../../../utils/formula.dart';
import '../../../utils/ui_responsive_calculation.dart';
import '../../../widgets/btns_folder/cusTxtIconBtn_widget.dart';
import '../../../widgets/voucher_box_widget.dart';

class VoucherScreen extends StatefulWidget {

  final String? customerName;
  final String? deliveryName;
  final List<UniqueItemModel> selectedUniqueItemList;
  final List<ItemModel> selectedItemModelList;
  final ShoppingType shoppingType;
  final PaymentMethod paymentMethod;
  final double? additionalPromotionAmount;
  final double? deliCharges;
  final String? description;

  final double taxPercentage;
  final PromotionModel? promotionModel;
  final VoidCallback clearDataFunc;

  const VoucherScreen({
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

    required this.taxPercentage,
    required this.promotionModel,
    required this.clearDataFunc,
  });

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  bool showAdditionalPromotion = false;

  @override
  Widget build(BuildContext context) {
    final GlobalKey printKey = GlobalKey();
    final UIutils uIutils = UIutils();
    final UIController uiController = UIController.instance;
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final BluetoothConnection? bluetoothConnection = context.watch<BluetoothPrinterCubit>().state.bluetoothConnection;
    final String barCode = CodeGenerator.getUniqueCodeForStockOut();
    final List<PromotionModel> activePromotionList = context.watch<PromotionCubit>().state.activePromotionList;
    final List<ItemPromotionModel> itemPromotionList = context.watch<PromotionCubit>().state.activeItemPromotionList;

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

    Widget paintWidget = RepaintBoundary(
      key: printKey,
      child: VoucherBox(
        customerName: widget.customerName,
        deliveryName: widget.deliveryName,
        selectedUniqueItemList: widget.selectedUniqueItemList,
        selectedItemModelList: widget.selectedItemModelList,
        shoppingType: widget.shoppingType,
        paymentMethod: widget.paymentMethod,
        additionalPromotionAmount: widget.additionalPromotionAmount,
        deliCharges: widget.deliCharges,
        description: widget.description,
        barCode: barCode,
        taxPercentage: widget.taxPercentage,
        promotionModel: widget.promotionModel,

        showAdditionalPromotion : showAdditionalPromotion,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 30,
      ),
      child: Drawer(
        width: uIutils.voucherWidth(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(UIConstants.bigRadius),
              bottomLeft:  Radius.circular(UIConstants.bigRadius),
            )
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height : 30,
                    padding: const EdgeInsets.only(
                      top: UIConstants.mediumSpace,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          txt: "Show additional Promotion",
                        ),
                        SizedBox(
                          child: Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              activeColor: Colors.green.shade700,
                              activeTrackColor: Colors.green.shade200,
                              value: showAdditionalPromotion,
                              onChanged: (bool data){
                                if(mounted){
                                  setState(() {
                                    showAdditionalPromotion = data;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all( UIConstants.mediumSpace),
                        child: paintWidget,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 100,
              color: Colors.lightBlueAccent.shade100.withOpacity(0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CusTxtIconElevatedBtn(
                        txt: "Print",
                        verticalpadding: UIConstants.smallSpace,
                        horizontalpadding: UIConstants.mediumSpace,
                        bdrRadius: UIConstants.smallRadius,
                        bgClr:  bluetoothConnection == BluetoothConnection.connected ? Colors.blue : Colors.grey,
                        txtStyle: Theme.of(context).textTheme.titleSmall!,
                        txtClr: Colors.white,
                        func: ()async{
                          if( bluetoothConnection == BluetoothConnection.connected ){
                            context.read<LoadingCubit>().setLoading("Printing ...");
                            await context.read<BluetoothPrinterCubit>().printVoucher(printKey).then((_){
                              Future.delayed(const Duration(seconds: 5),(){
                                context.read<LoadingCubit>().setSuccess("Print success !");
                              });

                            });
                          }else{
                            errorHandlers.showErrorWithBtn(title: "Bluetooth Printer", txt: "Bluetooth Printer not found");
                          }

                        },
                        icon: Icons.print,
                        iconSize: 25,
                      ),
                      uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.bigSpace),
                      CusTxtIconElevatedBtn(
                        txt: "Complete",
                        verticalpadding: UIConstants.smallSpace,
                        horizontalpadding: UIConstants.mediumSpace,
                        bdrRadius: UIConstants.smallRadius,
                        bgClr: Colors.blueAccent,
                        txtStyle: Theme.of(context).textTheme.titleSmall!,
                        txtClr: Colors.white,
                        func: ()async{

                          if(widget.selectedItemModelList.isEmpty){
                            errorHandlers.showErrorWithBtn(title: "No Item", txt: "There is no item in stock-out.");
                          }else{
                            context.read<LoadingCubit>().setLoading("Completing ...");

                            await context.read<TransactionsCubit>().createStockOutModel(
                              uniqueItemList: widget.selectedUniqueItemList,
                              dataList: context.read<ItemCubit>().getItemListWithCountFromUniqueItemListWithPromotion(
                                uniqueItemList: widget.selectedUniqueItemList,
                                itemModelList: widget.selectedItemModelList,
                                activePromotionList: activePromotionList,
                                itemPromotionList: itemPromotionList,
                              ),
                              userModel: userModel,
                              deliveryCharges: widget.deliCharges,
                              taxPercentage: widget.taxPercentage,
                              additionalPromotionAmount: widget.additionalPromotionAmount,
                              description: widget.description,
                              customerName: widget.customerName,
                              deliveryName: widget.deliveryName,
                              shoppingType: widget.shoppingType,
                              paymentMethod: widget.paymentMethod,
                              barcode: barCode,
                              finalTotalPrice :  CalculationFormula.getFinalStockOutTotalPriceWithDeliCharges(
                                  totalPrice: getAllPrice(),
                                  taxPrice: CalculationFormula.getPercentageToMMK(getAllPrice(), widget.taxPercentage),
                                  promotionPrice: widget.promotionModel == null ? 0 : widget.promotionModel!.promotionPrice ?? 0,
                                  deliCharges: widget.deliCharges ?? 0,
                                  promotionPercentage: widget.promotionModel == null ? 0 : widget.promotionModel!.promotionPercentage ?? 0,
                                  additionalPromotionPrice: widget.additionalPromotionAmount ?? 0,
                              ),
                              promotionModel: widget.promotionModel,
                            ).then((value){
                              if(value){
                                context.read<ItemCubit>().reloadAllItem().then((_){
                                  widget.clearDataFunc();
                                  Navigator.of(context).pop();
                                  context.read<LoadingCubit>().setSuccess("Success !");
                                });
                              }else{
                                context.read<LoadingCubit>().setFail("Fail !");
                              }
                            });
                          }

                        },
                        icon: Icons.check,
                        iconSize: 25,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 200,
                    child: CusTxtIconElevatedBtn(
                      txt: "Print and Complete",
                      verticalpadding: UIConstants.smallSpace,
                      horizontalpadding: UIConstants.mediumSpace,
                      bdrRadius: UIConstants.smallRadius,
                      bgClr: Colors.blueAccent,
                      txtStyle: Theme.of(context).textTheme.titleSmall!,
                      txtClr: Colors.white,
                      func: ()async{
                        if(widget.selectedUniqueItemList.isEmpty){
                          errorHandlers.showErrorWithBtn(title: "No Item", txt: "There is no item in stock-out.");
                        }else{
                          if( bluetoothConnection == BluetoothConnection.connected ){
                            context.read<LoadingCubit>().setLoading("Print and completing ...");
                            await context.read<BluetoothPrinterCubit>().printVoucher(printKey).then((_)async{

                              await context.read<TransactionsCubit>().createStockOutModel(
                                uniqueItemList: widget.selectedUniqueItemList,
                                dataList: context.read<ItemCubit>().getItemListWithCountFromUniqueItemListWithPromotion(
                                  uniqueItemList: widget.selectedUniqueItemList,
                                  itemModelList: widget.selectedItemModelList,
                                  activePromotionList: activePromotionList,
                                  itemPromotionList: itemPromotionList,
                                ),
                                userModel: userModel,
                                deliveryCharges: widget.deliCharges,
                                taxPercentage: widget.taxPercentage,
                                additionalPromotionAmount: widget.additionalPromotionAmount,
                                description: widget.description,
                                customerName: widget.customerName,
                                deliveryName: widget.deliveryName,
                                shoppingType: widget.shoppingType,
                                paymentMethod: widget.paymentMethod,
                                barcode: barCode,
                                finalTotalPrice:  CalculationFormula.getFinalStockOutTotalPriceWithDeliCharges(
                                    totalPrice: getAllPrice(),
                                    taxPrice: CalculationFormula.getPercentageToMMK(getAllPrice(), widget.taxPercentage),
                                    promotionPrice: widget.promotionModel == null ? 0 : widget.promotionModel!.promotionPrice ?? 0,
                                    deliCharges: widget.deliCharges ?? 0,
                                    additionalPromotionPrice: widget.additionalPromotionAmount ?? 0,
                                    promotionPercentage: widget.promotionModel == null ? 0 : widget.promotionModel!.promotionPercentage ?? 0,
                                ),
                                promotionModel: widget.promotionModel,
                              ).then((value){
                                if(value){
                                  context.read<ItemCubit>().reloadAllItem().then((_){

                                    Future.delayed(const Duration(seconds: 5),(){
                                      widget.clearDataFunc();
                                      Navigator.of(context).pop();
                                      context.read<LoadingCubit>().setSuccess("Success !");
                                    });
                                  });
                                }else{
                                  context.read<LoadingCubit>().setFail("Fail !");
                                }
                              });
                            });
                          }else{
                            errorHandlers.showErrorWithBtn(title: "Bluetooth Printer", txt: "Bluetooth Printer not found");
                          }
                        }
                      },
                      icon: Icons.print,
                      iconSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
