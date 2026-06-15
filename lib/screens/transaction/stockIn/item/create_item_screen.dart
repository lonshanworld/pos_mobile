import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/DB_helper.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/item_folder/no_selected_id_error_widget.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/type_model.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import "package:pos_mobile/utils/formula.dart";
import "package:pos_mobile/widgets/btns_folder/cusTextOnlyBtn_widget.dart";
import "package:pos_mobile/widgets/btns_folder/cus_switch_btn_widget.dart";
import "package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart";
import "package:pos_mobile/widgets/cusTextField/cusTextArea_widget.dart";
import "package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";

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
  late final Future<_CreateItemParents?> _parentsFuture;

  @override
  void initState() {
    super.initState();
    _parentsFuture = _loadParents();

    originalPriceController.addListener(() {
      setState(() {
        originalPrice = double.tryParse(originalPriceController.text.trim()) ?? 0;
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
        taxPercentage = double.tryParse(taxController.text.trim()) ?? 0;
      });
    });
  }

  Future<_CreateItemParents?> _loadParents() async {
    final GroupModel? groupModel = await DBHelper.getGroupById(widget.typeModel.groupId);
    if (groupModel == null) return null;

    final CategoryModel? categoryModel = await DBHelper.getCategoryById(groupModel.categoryId);
    if (categoryModel == null) return null;

    return _CreateItemParents(
      groupModel: groupModel,
      categoryModel: categoryModel,
    );
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
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;

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
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.smallSpace),
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
            ),
          ],
        ),
      );
    }

    Widget resultRow(String title, String txt) {
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

    return FutureBuilder<_CreateItemParents?>(
      future: _parentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final _CreateItemParents? parents = snapshot.data;
        if (parents == null) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: const CusLeadingBackIconBtn(),
              title: const Text("Create Item"),
            ),
            body: NoSelectedIdErrorWidget(
              txt: "This group has some error",
              func: () => Navigator.of(context).pop(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: const CusLeadingBackIconBtn(),
            title: const Text("Create Item"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.bigSpace),
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
                        txt: "You cannot change this value because it only shows its type has expired date or not.",
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
                            func: (bool value) {},
                            clr: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                  priceInputField(
                    hintTxt: "Enter purchased price",
                    labelTxt: "MMK",
                    textEditingController: originalPriceController,
                  ),
                  priceInputField(
                    hintTxt: "Enter sell price",
                    labelTxt: "MMK",
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
                      color: profitPrice < 0
                          ? Colors.red.withValues(alpha: 0.4)
                          : Colors.green.withValues(alpha: 0.4),
                      borderRadius: UIConstants.mediumBorderRadius,
                    ),
                    child: Column(
                      children: [
                        resultRow("Profit", profitPrice.toString()),
                        uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
                        if (taxPercentage > 0)
                          resultRow(
                            "Tax",
                            CalculationFormula.getPercentageToMMK(
                              originalPrice + profitPrice,
                              taxPercentage,
                            ).toString(),
                          ),
                        uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
                        resultRow(
                          "Final Sell Price",
                          CalculationFormula.getItemSellPrice(
                            originalPrice: originalPrice,
                            profitPrice: profitPrice,
                            taxPercentage: taxPercentage,
                          ).toString(),
                        ),
                      ],
                    ),
                  ),
                  uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CusTxtWidget(
                      txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.grey,
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
                      clr: Colors.deepPurpleAccent,
                      func: () async {
                        if (itemNameController.text.trim().isEmpty) {
                          showValidationMessage("Item name should not be empty");
                        } else if (originalPrice < 1) {
                          showValidationMessage("Original price must be greater than zero");
                        } else if (double.tryParse(sellPriceController.text.trim()) == null ||
                            double.tryParse(taxController.text.trim()) == null) {
                          showValidationMessage("Sell price and tax must be valid numbers");
                        } else {
                          final loadingCubit = context.read<LoadingCubit>();
                          final itemCubit = context.read<ItemCubit>();
                          final navigator = Navigator.of(context);

                          loadingCubit.setLoading("Creating ...");
                          final value = await itemCubit.createNewItem(
                            userModel: userModel,
                            categoryModel: parents.categoryModel,
                            groupModel: parents.groupModel,
                            typeModel: widget.typeModel,
                            name: itemNameController.text.trim(),
                            description: textAreaController.text.trim().isEmpty
                                ? null
                                : textAreaController.text.trim(),
                            hasExpire: widget.typeModel.hasExpire,
                            profitPrice: profitPrice,
                            originalPrice: originalPrice,
                            taxPercentage: taxPercentage,
                          );

                          if (!mounted) return;
                          if (value) {
                            loadingCubit.setSuccess("Success !");
                            navigator.pop();
                          } else {
                            loadingCubit.setFail("Fail !");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CreateItemParents {
  final GroupModel groupModel;
  final CategoryModel categoryModel;

  const _CreateItemParents({
    required this.groupModel,
    required this.categoryModel,
  });
}
