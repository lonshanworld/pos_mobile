import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/type_model.dart";
import "package:pos_mobile/utils/formula.dart";

import "../../../../blocs/item_bloc/item_cubit.dart";
import "../../../../blocs/loading_bloc/loading_cubit.dart";
import "../../../../blocs/userData_bloc/user_data_cubit.dart";
import "../../../../constants/uiConstants.dart";
import "../../../../controller/ui_controller.dart";
import "../../../../error_handlers/error_handler.dart";
import "../../../../models/groupingItem_models_folders/category_model.dart";
import "../../../../models/user_model_folder/user_model.dart";
import "../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart";
import "../../../../widgets/btns_folder/cus_switch_btn_widget.dart";
import "../../../../widgets/btns_folder/leadingBackIconBtn.dart";
import "../../../../widgets/cusTextField/cusTextArea_widget.dart";
import "../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart";
import "../../../../widgets/cusTxt_widget.dart";

class CreateItemScreen extends StatefulWidget {

  final TypeModel typeModel;
  const CreateItemScreen({
    super.key,
    required this.typeModel,
  });

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController textAreaController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  double originalPrice = 0;
  double profitPrice = 0;
  double taxPercentage = 0;

  @override
  void initState() {
    super.initState();
    originalPriceController.addListener(() {
      setState(() {
        originalPrice = originalPriceController.text.trim() == "" ? 0 : double.parse(originalPriceController.text.trim());
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
    textAreaController.dispose();
    originalPriceController.dispose();
    sellPriceController.dispose();
    taxController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final GroupModel groupModel = context.read<ItemCubit>().getGroup(widget.typeModel.groupId);
    final CategoryModel categoryModel = context.read<ItemCubit>().getCategory(groupModel.categoryId);

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
          "Create Item",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              CusTextFieldLogin(
                txtController: itemNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Item name",
                txtInputType: TextInputType.text,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Column(
                children: [
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                    ),
                    txt: "You cannot change this value because it only shows it's type has expired date or not.",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CusTxtWidget(
                        txtStyle: Theme.of(context).textTheme.bodyMedium!,
                        txt: "Has Expired Date ?",
                      ),
                      CusSwitchBtnWidget(
                        boolValue: widget.typeModel.hasExpire,
                        func: (bool value){

                        },
                        clr: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
              priceInputField(
                hintTxt: "Enter purchased price",
                labelTxt: "MMK (ကျပ်)   ",
                textEditingController: originalPriceController,
              ),
              priceInputField(
                hintTxt: "Enter sell price",
                labelTxt: "MMK (ကျပ်)   ",
                textEditingController: sellPriceController,
              ),
              priceInputField(
                hintTxt: "Enter tax percentage",
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
                    if(taxPercentage > 0)resultRow("Tax (ကျပ်)  ", CalculationFormula.getPercentageToMMK(originalPrice + profitPrice, taxPercentage).toString()),
                    uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
                    resultRow("Final Sell Price  ", CalculationFormula.getItemSellPrice(originalPrice: originalPrice, profitPrice: profitPrice, taxPercentage: taxPercentage).toString()),
                  ],
                ),
              ),
              
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.grey
                  ),
                  txt: "Optional",
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.smallSpace, cusWidth: null),
              CusTextArea(
                txtController: textAreaController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter description",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Create",
                  func: ()async{

                    if(itemNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(title: null, txt: "Item Name should not be empty");
                    }else if(originalPrice < 1){
                      errorHandlers.showErrorWithBtn(title: "Add price", txt: "Original Price must not be Empty or Zero or Negative");
                    }else{
                      context.read<LoadingCubit>().setLoading("Creating ...");
                      await context.read<ItemCubit>().createNewItem(
                        userModel: userModel,
                        categoryModel: categoryModel,
                        groupModel: groupModel,
                        typeModel: widget.typeModel,
                        name: itemNameController.text.trim(),
                        description:  (textAreaController.text.trim() == "" || textAreaController.text.trim().isEmpty)
                            ?
                        null
                            :
                        textAreaController.text.trim(),
                        hasExpire: widget.typeModel.hasExpire,
                        profitPrice: profitPrice,
                        originalPrice: originalPrice,
                        taxPercentage: taxPercentage,
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
