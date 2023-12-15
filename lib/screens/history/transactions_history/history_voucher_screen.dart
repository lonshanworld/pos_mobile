import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_person_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';

import '../../../blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import '../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../constants/enums.dart';
import '../../../controller/ui_controller.dart';
import '../../../error_handlers/error_handler.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/cusTxt_widget.dart';
import '../../../widgets/voucher_box_widget.dart';

class HistoryVoucherScreen extends StatefulWidget {
  
  final StockOutModel stockOutModel;
  const HistoryVoucherScreen({
    super.key,
    required this.stockOutModel,
  });

  @override
  State<HistoryVoucherScreen> createState() => _HistoryVoucherScreenState();
}

class _HistoryVoucherScreenState extends State<HistoryVoucherScreen> {
  bool showAdditionalPromotion = false;

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final GlobalKey printKey = GlobalKey();
    final BluetoothConnection? bluetoothConnection = context.watch<BluetoothPrinterCubit>().state.bluetoothConnection;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final List<UniqueItemModel> uniqueItemList = context.read<ItemCubit>().getSelectedUniqueItemFromStockOutId(widget.stockOutModel.id);
    final List<ItemModel> itemList = context.read<ItemCubit>().getItemListFromSelectedUniqueItemList(uniqueItemList);
    final CustomerModel? customerModel = widget.stockOutModel.customerId == null ? null : context.read<TransactionsCubit>().getCustomerModel(widget.stockOutModel.customerId!);
    final DeliveryModel? deliveryModel = widget.stockOutModel.deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(widget.stockOutModel.deliveryModelId!);
    final DeliveryPersonModel? deliveryPersonModel = widget.stockOutModel.deliveryPersonId == null ? null : context.read<TransactionsCubit>().getDeliveryPerson(widget.stockOutModel.deliveryPersonId!);

    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        centerTitle: true,
        title: const Text("Voucher"),
        actions: [
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
          CusTxtElevatedBtn(
            txt: "Print",
            verticalpadding: UIConstants.smallSpace,
            horizontalpadding: UIConstants.mediumSpace,
            bdrRadius: UIConstants.smallRadius,
            bgClr:  bluetoothConnection == BluetoothConnection.connected ? Colors.blue : Colors.grey,
            func: ()async{
              if( bluetoothConnection == BluetoothConnection.connected ){
                context.read<LoadingCubit>().setLoading("Printing ...");
                await context.read<BluetoothPrinterCubit>().printVoucher(printKey).then((_){
                  Future.delayed(const Duration(seconds: 5),(){
                    Navigator.of(context).pop();
                    context.read<LoadingCubit>().setSuccess("Print success !");
                  });
                });
              }else{
                errorHandlers.showErrorWithBtn(title: "Bluetooth Printer", txt: "Bluetooth Printer not found");
              }
            },
            txtStyle: Theme.of(context).textTheme.titleSmall!,
            txtClr: Colors.white,
          ),
          uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.bigSpace),
        ],
      ),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: printKey,
          child: VoucherBox(
            customerName: customerModel?.name,
            deliveryName: deliveryPersonModel?.name,
            selectedUniqueItemList: uniqueItemList,
            selectedItemModelList: itemList,
            shoppingType: widget.stockOutModel.shoppingType,
            paymentMethod: widget.stockOutModel.paymentMethod,
            additionalPromotionAmount: widget.stockOutModel.additionalPromotionAmount,
            deliCharges: deliveryModel?.deliveryCharges,
            description: widget.stockOutModel.description,
            barCode: widget.stockOutModel.code,
            taxPercentage: widget.stockOutModel.taxPercentage ?? 0,
            promotionModel: null,

            showAdditionalPromotion: showAdditionalPromotion,
          ),
        ),
      ),
    );
  }
}
