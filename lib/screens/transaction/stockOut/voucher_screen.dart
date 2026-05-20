import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

import '../../../blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import '../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../blocs/item_bloc/item_cubit.dart';
import '../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../blocs/transactions_bloc/transactions_cubit.dart';
import '../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../constants/uiConstants.dart';
import '../../../controller/ui_controller.dart';
import '../../../error_handlers/error_handler.dart';
import '../../../features/code_generator_feature.dart';
import '../../../models/item_model_folder/item_model.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../models/promotion_model_folder/promotion_model.dart';
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
  late final GlobalKey _printKey;
  late final String _barCode;

  @override
  void initState() {
    super.initState();
    _printKey = GlobalKey();
    _barCode = CodeGenerator.getUniqueCodeForStockOut();
  }

  void _showSavedPathToast(BuildContext context, String savedPath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher PDF saved: $savedPath'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _getAllPrice(BuildContext context) {
    double price = 0;
    for (int i = 0; i < widget.selectedUniqueItemList.length; i++) {
      final PromotionModel? promotionData = context
          .read<PromotionCubit>()
          .getSinglePromotionFromItemId(widget.selectedUniqueItemList[i].itemId);

      price = price +
          CalculationFormula.getItemAfterPromotionPrice(
            sellPrice: CalculationFormula.getItemSellPrice(
              originalPrice: widget.selectedUniqueItemList[i].originalPrice,
              profitPrice: widget.selectedUniqueItemList[i].profitPrice,
              taxPercentage: widget.selectedUniqueItemList[i].taxPercentage,
            ),
            promotionPercentage:
                promotionData == null ? 0 : promotionData.promotionPercentage,
            promotionPrice:
                promotionData == null ? 0 : promotionData.promotionPrice,
          );
    }
    return price;
  }

  double _getFinalTotal(BuildContext context) {
    final allPrice = _getAllPrice(context);
    return CalculationFormula.getFinalStockOutTotalPriceWithDeliCharges(
      totalPrice: allPrice,
      taxPrice: CalculationFormula.getPercentageToMMK(allPrice, widget.taxPercentage),
      promotionPrice: widget.promotionModel == null
          ? 0
          : widget.promotionModel!.promotionPrice ?? 0,
      deliCharges: widget.deliCharges ?? 0,
      promotionPercentage: widget.promotionModel == null
          ? 0
          : widget.promotionModel!.promotionPercentage ?? 0,
      additionalPromotionPrice: widget.additionalPromotionAmount ?? 0,
    );
  }

  Future<void> _handlePrint(GlobalKey printKey) async {
    final loadingCubit = context.read<LoadingCubit>();
    final printerCubit = context.read<BluetoothPrinterCubit>();
    final errorHandlers = ErrorHandlers();
    final bluetoothConnection =
        context.read<BluetoothPrinterCubit>().state.bluetoothConnection;

    if (bluetoothConnection == BluetoothConnection.connected) {
      loadingCubit.setLoading("Printing ...");
      final success = await printerCubit.printVoucher(printKey);
      if (!mounted) return;
      if (success) {
        loadingCubit.setSuccess("Print command sent !");
      } else {
        loadingCubit.setFail("Print failed.");
      }
    } else {
      errorHandlers.showErrorWithBtn(
          title: "Bluetooth Printer", txt: "Bluetooth Printer not connected. Check devices in Settings.");
    }
  }

  Future<void> _handleDownloadPdf(GlobalKey printKey, String barCode) async {
    final loadingCubit = context.read<LoadingCubit>();
    final printerCubit = context.read<BluetoothPrinterCubit>();

    loadingCubit.setLoading("Generating PDF ...");
    final savedPath = await printerCubit.downloadVoucherPdf(
      printKey,
      fileName: 'voucher_$barCode',
    );

    if (!mounted) return;
    if (savedPath != null) {
      loadingCubit.setSuccess("Voucher PDF downloaded.");
      _showSavedPathToast(context, savedPath);
    } else {
      loadingCubit.setFail("Failed to download voucher PDF.");
    }
  }

  Future<void> _handleComplete(String barCode) async {
    final loadingCubit = context.read<LoadingCubit>();
    final transactionsCubit = context.read<TransactionsCubit>();
    final itemCubit = context.read<ItemCubit>();
    final userModel = context.read<UserDataCubit>().state.userModel;
    final activePromotionList =
        context.read<PromotionCubit>().state.activePromotionList;
    final itemPromotionList =
        context.read<PromotionCubit>().state.activeItemPromotionList;
    final errorHandlers = ErrorHandlers();

    if (widget.selectedItemModelList.isEmpty) {
      errorHandlers.showErrorWithBtn(
          title: "No Item", txt: "There is no item in stock-out.");
      return;
    }

    loadingCubit.setLoading("Completing ...");

    final value = await transactionsCubit.createStockOutModel(
      uniqueItemList: widget.selectedUniqueItemList,
      dataList: itemCubit.getItemListWithCountFromUniqueItemListWithPromotion(
        uniqueItemList: widget.selectedUniqueItemList,
        itemModelList: widget.selectedItemModelList,
        activePromotionList: activePromotionList,
        itemPromotionList: itemPromotionList,
      ),
      userModel: userModel!,
      deliveryCharges: widget.deliCharges,
      taxPercentage: widget.taxPercentage,
      additionalPromotionAmount: widget.additionalPromotionAmount,
      description: widget.description,
      customerName: widget.customerName,
      deliveryName: widget.deliveryName,
      shoppingType: widget.shoppingType,
      paymentMethod: widget.paymentMethod,
      barcode: barCode,
      finalTotalPrice: _getFinalTotal(context),
      promotionModel: widget.promotionModel,
    );

    if (!mounted) return;

    if (value) {
      await itemCubit.reloadAllItem();
      if (!mounted) return;
      loadingCubit.setSuccess("Success !");
      widget.clearDataFunc();
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      loadingCubit.setFail("Fail !");
    }
  }

  Future<void> _handlePrintAndComplete(GlobalKey printKey, String barCode) async {
    final loadingCubit = context.read<LoadingCubit>();
    final printerCubit = context.read<BluetoothPrinterCubit>();
    final bluetoothConnection =
        context.read<BluetoothPrinterCubit>().state.bluetoothConnection;
    final errorHandlers = ErrorHandlers();

    if (widget.selectedUniqueItemList.isEmpty) {
      errorHandlers.showErrorWithBtn(
          title: "No Item", txt: "There is no item in stock-out.");
      return;
    }

    if (bluetoothConnection != BluetoothConnection.connected) {
      errorHandlers.showErrorWithBtn(
          title: "Bluetooth Printer", txt: "Bluetooth Printer not connected. Check devices in Settings.");
      return;
    }

    loadingCubit.setLoading("Printing & completing ...");
    final success = await printerCubit.printVoucher(printKey);
    
    if (!success) {
      if (!mounted) return;
      loadingCubit.setFail("Print failed.");
      return;
    }

    if (!mounted) return;

    await _handleCompleteLogic(barCode);

    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    loadingCubit.setSuccess("Success !");
    widget.clearDataFunc();
    Navigator.of(context).pop();
  }

  Future<void> _handleCompleteLogic(String barCode) async {
    final transactionsCubit = context.read<TransactionsCubit>();
    final itemCubit = context.read<ItemCubit>();
    final userModel = context.read<UserDataCubit>().state.userModel;
    final activePromotionList =
        context.read<PromotionCubit>().state.activePromotionList;
    final itemPromotionList =
        context.read<PromotionCubit>().state.activeItemPromotionList;
    final loadingCubit = context.read<LoadingCubit>();

    final value = await transactionsCubit.createStockOutModel(
      uniqueItemList: widget.selectedUniqueItemList,
      dataList: itemCubit.getItemListWithCountFromUniqueItemListWithPromotion(
        uniqueItemList: widget.selectedUniqueItemList,
        itemModelList: widget.selectedItemModelList,
        activePromotionList: activePromotionList,
        itemPromotionList: itemPromotionList,
      ),
      userModel: userModel!,
      deliveryCharges: widget.deliCharges,
      taxPercentage: widget.taxPercentage,
      additionalPromotionAmount: widget.additionalPromotionAmount,
      description: widget.description,
      customerName: widget.customerName,
      deliveryName: widget.deliveryName,
      shoppingType: widget.shoppingType,
      paymentMethod: widget.paymentMethod,
      barcode: barCode,
      finalTotalPrice: _getFinalTotal(context),
      promotionModel: widget.promotionModel,
    );

    if (!mounted) return;

    if (value) {
      await itemCubit.reloadAllItem();
    } else {
      loadingCubit.setFail("Fail !");
    }
  }

  @override
  Widget build(BuildContext context) {
    final UIutils uIutils = UIutils();
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final BluetoothConnection? bluetoothConnection =
        context.watch<BluetoothPrinterCubit>().state.bluetoothConnection;

    Widget paintWidget = RepaintBoundary(
      key: _printKey,
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
        barCode: _barCode,
        taxPercentage: widget.taxPercentage,
        promotionModel: widget.promotionModel,
        showAdditionalPromotion: showAdditionalPromotion,
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
          bottomLeft: Radius.circular(UIConstants.bigRadius),
        )),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 30,
                    padding: const EdgeInsets.only(
                      top: UIConstants.mediumSpace,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CusTxtWidget(
                          txtStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          txt: "Show additional Promotion",
                        ),
                        SizedBox(
                          child: Transform.scale(
                            scale: 0.6,
                            child: Switch.adaptive(
                              activeThumbColor: Colors.green.shade700,
                              activeTrackColor: Colors.green.shade200,
                              value: showAdditionalPromotion,
                              onChanged: (bool data) {
                                if (mounted) {
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
                        padding: const EdgeInsets.all(UIConstants.mediumSpace),
                        child: paintWidget,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                vertical: UIConstants.bigSpace,
                horizontal: UIConstants.mediumSpace,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CusTxtIconElevatedBtn(
                            txt: "Print",
                            verticalpadding: 12,
                            horizontalpadding: UIConstants.smallSpace,
                            bdrRadius: UIConstants.smallRadius,
                            bgClr: bluetoothConnection ==
                                    BluetoothConnection.connected
                                ? uiController.getpureOppositeClr(themeModeType)
                                : Colors.grey.shade400,
                            txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            txtClr: bluetoothConnection == BluetoothConnection.connected
                                ? uiController.getpureDirectClr(themeModeType)
                                : Colors.white,
                            func: () => _handlePrint(_printKey),
                            icon: Icons.print,
                            iconSize: 20,
                          ),
                        ),
                        const SizedBox(width: UIConstants.mediumSpace),
                        Expanded(
                          child: CusTxtIconElevatedBtn(
                            txt: "Download PDF",
                            verticalpadding: 12,
                            horizontalpadding: UIConstants.smallSpace,
                            bdrRadius: UIConstants.smallRadius,
                            bgClr: Colors.blue,
                            txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            txtClr: Colors.white,
                            func: () => _handleDownloadPdf(_printKey, _barCode),
                            icon: Icons.download,
                            iconSize: 20,
                          ),
                        ),
                        const SizedBox(width: UIConstants.mediumSpace),
                        Expanded(
                          child: CusTxtIconElevatedBtn(
                            txt: "Complete",
                            verticalpadding: 12,
                            horizontalpadding: UIConstants.smallSpace,
                            bdrRadius: UIConstants.smallRadius,
                            bgClr: Colors.amber,
                            txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            txtClr: Colors.white,
                            func: () => _handleComplete(_barCode),
                            icon: Icons.check_circle,
                            iconSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.mediumSpace),
                    CusTxtIconElevatedBtn(
                      txt: "Print & Complete",
                      verticalpadding: 14,
                      horizontalpadding: UIConstants.mediumSpace,
                      bdrRadius: UIConstants.smallRadius,
                      bgClr: bluetoothConnection ==
                              BluetoothConnection.connected
                          ? uiController.getpureOppositeClr(themeModeType)
                          : Colors.grey.shade400,
                      txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      txtClr: bluetoothConnection == BluetoothConnection.connected
                          ? uiController.getpureDirectClr(themeModeType)
                          : Colors.white,
                        func: () => _handlePrintAndComplete(_printKey, _barCode),
                      icon: Icons.print_rounded,
                      iconSize: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
