import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/item_bloc/item_cubit.dart';
import '../../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../constants/enums.dart';
import '../../../../constants/uiConstants.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../error_handlers/error_handler.dart';
import '../../../../models/item_model_folder/item_model.dart';
import '../../../../models/user_model_folder/user_model.dart';
import '../../../../utils/formula.dart';
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

  double originalPrice = 0;
  double profitPrice = 0;
  double taxPercentage = 0;

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
      });
    }
    originalPriceController.addListener(() {
      setState(() {
        originalPrice = originalPriceController.text.trim() == "" ? 0 : double.parse(originalPriceController.text.trim());
        profitPrice = double.parse(sellPriceController.text.trim()) - double.parse(originalPriceController.text.trim());
      });
    });
    sellPriceController.addListener(() {
      setState(() {
        profitPrice = sellPriceController.text.trim() == "" ? 0 : CalculationFormula.getItemProfitPrice(originalPrice: originalPrice, sellPrice: double.parse(sellPriceController.text.trim()));
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
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

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
                  color: profitPrice< 0 ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4),
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
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Update",
                  func: ()async{

                    if(itemNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(title: null, txt: "Item Name should not be empty");
                    }else if(originalPrice < 1){
                      errorHandlers.showErrorWithBtn(title: "Update price", txt: "Original Price must not be Empty or Zero or Negative");
                    }else{
                      context.read<LoadingCubit>().setLoading("Updating ...");
                      await context.read<ItemCubit>().editItem(
                        userModel: userModel,
                        itemModel: widget.itemModel,
                        newName: itemNameController.text.trim(),
                        newOriginalPrice: originalPrice,
                        newProfitPrice: profitPrice,
                        newTaxPercentage: taxPercentage,
                      ).then((value){
                        if(value){
                          Navigator.of(context).pop();
                          context.read<LoadingCubit>().setSuccess("Success !");

                        }else{
                          context.read<LoadingCubit>().setFail("Fail !");
                        }
                      });
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
