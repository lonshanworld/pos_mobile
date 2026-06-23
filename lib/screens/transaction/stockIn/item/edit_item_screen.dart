import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/shop_info_bloc/shop_info_cubit.dart';
import '../../../../blocs/item_bloc/item_cubit.dart';
import '../../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../constants/enums.dart';
import '../../../../constants/uiConstants.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../models/item_model_folder/item_model.dart';
import '../../../../models/user_model_folder/user_model.dart';
import '../../../../utils/formula.dart';
import '../../../../widgets/btns_folder/cus_switch_btn_widget.dart';
import '../../../../widgets/business_item_detail_form.dart';
import '../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import '../../../../widgets/btns_folder/leadingBackIconBtn.dart';
import '../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart';
import '../../../../widgets/cusTxt_widget.dart';

class EditItemScreen extends StatefulWidget {

  final ItemModel itemModel;
  const EditItemScreen({
    super.key,
    required this.itemModel,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final GlobalKey<BusinessItemDetailFormState> _businessFormKey =
      GlobalKey<BusinessItemDetailFormState>();

  double originalPrice = 0;
  double profitPrice = 0;
  double taxPercentage = 0;
  bool _needStock = true;

  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        itemNameController.text = widget.itemModel.name;
        originalPriceController.text = widget.itemModel.originalPrice.toString();
        sellPriceController.text = (widget.itemModel.originalPrice + widget.itemModel.profitPrice).toString();
        taxController.text = widget.itemModel.taxPercentage.toString();
        originalPrice = widget.itemModel.originalPrice;
        profitPrice =  widget.itemModel.profitPrice;
        taxPercentage = widget.itemModel.taxPercentage ?? 0;
        _needStock = widget.itemModel.needStock;
      });
    }
    originalPriceController.addListener(() {
      setState(() {
        final double newOriginalPrice =
            double.tryParse(originalPriceController.text.trim()) ?? 0;
        final double? sellPrice =
            double.tryParse(sellPriceController.text.trim());
        originalPrice = newOriginalPrice;
        profitPrice = sellPrice == null
            ? 0
            : CalculationFormula.getItemProfitPrice(
                originalPrice: newOriginalPrice,
                sellPrice: sellPrice,
              );
      });
    });
    sellPriceController.addListener(() {
      setState(() {
        final sellPrice = double.tryParse(sellPriceController.text.trim());
        profitPrice = sellPrice == null
            ? 0
            : CalculationFormula.getItemProfitPrice(
                originalPrice: originalPrice,
                sellPrice: sellPrice,
              );
      });
    });
    taxController.addListener(() {
      setState(() {
        taxPercentage = taxController.text.trim() == "" ? 0 : double.parse(taxController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    itemNameController.dispose();
    originalPriceController.dispose();
    sellPriceController.dispose();
    taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final BusinessType businessType =
        context.watch<ShopInfoCubit>().state.businessType;
    final businessDetail =
        context.read<ItemCubit>().getBusinessDetail(widget.itemModel.id);

    void showValidationMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Widget priceInputField({
      required String hintTxt,
      required String labelTxt,
      required TextEditingController textEditingController,
    }){
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: UIConstants.smallSpace
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              child: CusTextFieldLogin(
                txtController: textEditingController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace,
                hintTxt: hintTxt,
                txtInputType: TextInputType.number,
                txtStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.mediumSpace),
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!,
              txt: labelTxt,
            )
          ],
        ),
      );
    }

    Widget resultRow(String title, String txt){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: title,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.smallSpace,
              horizontal: UIConstants.mediumSpace,
            ),
            decoration: BoxDecoration(
              color: uiController.getpureOppositeClr(themeModeType),
              borderRadius: UIConstants.mediumBorderRadius,
            ),
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: uiController.getpureDirectClr(themeModeType),
              ),
              txt: txt,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: const Text(
          "Update Item",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
          vertical: UIConstants.mediumSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CusTextFieldLogin(
                txtController: itemNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Item name",
                txtInputType: TextInputType.text,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              if (businessType == BusinessType.food)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CusTxtWidget(
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txt: "Track Stock ?",
                    ),
                    CusSwitchBtnWidget(
                      boolValue: _needStock,
                      func: (bool value) {
                        setState(() {
                          _needStock = value;
                        });
                      },
                      clr: Colors.blue,
                    ),
                  ],
                ),
              if (businessType == BusinessType.food)
                uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),

              priceInputField(
                hintTxt: "Enter new purchased price",
                labelTxt: "MMK (ကျပ်)   ",
                textEditingController: originalPriceController,
              ),
              priceInputField(
                hintTxt: "Enter new sell price",
                labelTxt: "MMK (ကျပ်)   ",
                textEditingController: sellPriceController,
              ),
              priceInputField(
                hintTxt: "Enter new tax percentage",
                labelTxt: "% percentage",
                textEditingController: taxController,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.mediumSpace,
                  horizontal: UIConstants.bigSpace,
                ),
                decoration: BoxDecoration(
                  color: profitPrice< 0 ? Colors.red.withValues(alpha: 0.4) : Colors.green.withValues(alpha: 0.4),
                  borderRadius: UIConstants.mediumBorderRadius,
                ),
                child: Column(
                  children: [
                    resultRow("Profit (ကျပ်)  ", profitPrice.toString()),
                    uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
                    resultRow("Final Sell Price  ", CalculationFormula.getItemSellPrice(originalPrice: originalPrice, profitPrice: profitPrice, taxPercentage: taxPercentage).toString()),
                  ],
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              BusinessItemDetailForm(
                key: _businessFormKey,
                businessType: businessType,
                initialDetail: businessDetail,
                itemId: widget.itemModel.id,
              ),
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Update",
                  func: ()async{

                    if(itemNameController.text.trim().isEmpty){
                      showValidationMessage("Item name should not be empty");
                    }else if(originalPrice < 1){
                      showValidationMessage("Original price must be greater than zero");
                    }else{
                      final businessError =
                          _businessFormKey.currentState?.validate();
                      if (businessError != null) {
                        showValidationMessage(businessError);
                        return;
                      }

                      context.read<LoadingCubit>().setLoading("Updating ...");
                      final detail = _businessFormKey.currentState
                          ?.buildDetail(widget.itemModel.id);
                      final value = await context.read<ItemCubit>().editItem(
                        userModel: userModel,
                        itemModel: widget.itemModel,
                        newName: itemNameController.text.trim(),
                        newOriginalPrice: originalPrice,
                        newProfitPrice: profitPrice,
                        newTaxPercentage: taxPercentage,
                        needStock: businessType == BusinessType.food ? _needStock : true,
                        businessDetail: detail,
                      );

                      if (!mounted) return;
                      if(value){
                        context.read<LoadingCubit>().setSuccess("Success !");
                        Navigator.of(context).pop();
                      }else{
                        context.read<LoadingCubit>().setFail("Fail !");
                      }
                    }
                  },
                  clr: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
