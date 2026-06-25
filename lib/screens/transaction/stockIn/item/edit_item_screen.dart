import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../../../blocs/shop_info_bloc/shop_info_cubit.dart';
import '../../../../blocs/item_bloc/item_cubit.dart';
import '../../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../constants/business_hierarchy_config.dart';
import '../../../../constants/business_type_utils.dart';
import '../../../../constants/enums.dart';
import '../../../../constants/uiConstants.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../models/groupingItem_models_folders/type_model.dart';
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
  const EditItemScreen({super.key, required this.itemModel});

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
  int? _selectedCategoryId;
  int? _selectedGroupId;
  int? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    itemNameController.text = widget.itemModel.name;
    originalPriceController.text = widget.itemModel.originalPrice.toString();
    sellPriceController.text =
        (widget.itemModel.originalPrice + widget.itemModel.profitPrice)
            .toString();
    taxController.text = widget.itemModel.taxPercentage.toString();
    originalPrice = widget.itemModel.originalPrice;
    profitPrice = widget.itemModel.profitPrice;
    taxPercentage = widget.itemModel.taxPercentage ?? 0;
    _needStock = widget.itemModel.needStock;
    _selectedCategoryId = widget.itemModel.categoryId;
    _selectedGroupId = widget.itemModel.groupId;
    _selectedTypeId = widget.itemModel.typeId;

    originalPriceController.addListener(() {
      setState(() {
        final double newOriginalPrice =
            double.tryParse(originalPriceController.text.trim()) ?? 0;
        final double? sellPrice = double.tryParse(
          sellPriceController.text.trim(),
        );
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
        taxPercentage = taxController.text.trim() == ""
            ? 0
            : double.parse(taxController.text.trim());
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
    final ThemeModeType themeModeType = context
        .watch<ThemeCubit>()
        .state
        .themeModeType;
    final BusinessType businessType = context
        .watch<ShopInfoCubit>()
        .state
        .businessType;
    final bool allowExpiryTracking = businessType.allowsExpiryTracking;
    final businessDetail = context.read<ItemCubit>().getBusinessDetail(
      widget.itemModel.id,
    );
    final itemState = context.watch<ItemCubit>().state;
    final categoryLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.category,
    );
    final groupLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.group,
    );
    final typeLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.type,
    );
    final TypeModel? selectedTypeModel = itemState.allActiveTypeList
        .firstWhereOrNull((type) => type.id == _selectedTypeId);

    void showValidationMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
            uiController.sizedBox(
              cusHeight: null,
              cusWidth: UIConstants.mediumSpace,
            ),
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!,
              txt: labelTxt,
            ),
          ],
        ),
      );
    }

    Widget buildCatalogDropdown({
      required String label,
      required int? value,
      required List<DropdownMenuItem<int?>> items,
      required ValueChanged<int?> onChanged,
    }) {
      return DropdownButtonFormField<int?>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
        items: items,
        onChanged: onChanged,
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: const Text("Update Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
          vertical: UIConstants.mediumSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCatalogDropdown(
                label: categoryLabel,
                value: _selectedCategoryId,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text("No $categoryLabel"),
                  ),
                  ...itemState.allActiveCategoryList.map(
                    (category) => DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
              buildCatalogDropdown(
                label: groupLabel,
                value: _selectedGroupId,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text("No $groupLabel"),
                  ),
                  ...itemState.allActiveGroupList.map(
                    (group) => DropdownMenuItem<int?>(
                      value: group.id,
                      child: Text(group.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGroupId = value;
                  });
                },
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
              buildCatalogDropdown(
                label: typeLabel,
                value: _selectedTypeId,
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text("Select $typeLabel"),
                  ),
                  ...itemState.allActiveTypeList.map(
                    (type) => DropdownMenuItem<int?>(
                      value: type.id,
                      child: Text(type.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTypeId = value;
                  });
                },
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
              CusTextFieldLogin(
                txtController: itemNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding:
                    UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Item name",
                txtInputType: TextInputType.text,
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.bigSpace,
                cusWidth: null,
              ),
              if (allowExpiryTracking)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CusTxtWidget(
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txt: "Has Expired Date ?",
                    ),
                    CusSwitchBtnWidget(
                      boolValue: selectedTypeModel?.hasExpire ?? false,
                      func: (bool value) {},
                      clr: Colors.blue,
                    ),
                  ],
                ),
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
                uiController.sizedBox(
                  cusHeight: UIConstants.mediumSpace,
                  cusWidth: null,
                ),

              priceInputField(
                hintTxt: "Enter new purchased price",
                labelTxt: "MMK",
                textEditingController: originalPriceController,
              ),
              priceInputField(
                hintTxt: "Enter new sell price",
                labelTxt: "MMK",
                textEditingController: sellPriceController,
              ),
              priceInputField(
                hintTxt: "Enter new tax percentage",
                labelTxt: "% percentage",
                textEditingController: taxController,
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.bigSpace,
                cusWidth: null,
              ),
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
                    uiController.sizedBox(
                      cusHeight: UIConstants.mediumSpace,
                      cusWidth: null,
                    ),
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
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
              BusinessItemDetailForm(
                key: _businessFormKey,
                businessType: businessType,
                initialDetail: businessDetail,
                itemId: widget.itemModel.id,
                initialBarcode: widget.itemModel.code,
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Update",
                  func: () async {
                    if (selectedTypeModel == null) {
                      showValidationMessage("Choose a $typeLabel first");
                    } else if (itemNameController.text.trim().isEmpty) {
                      showValidationMessage("Item name should not be empty");
                    } else if (businessType != BusinessType.food && originalPrice < 1) {
                      showValidationMessage(
                        "Original price must be greater than zero",
                      );
                    } else {
                      final businessError = _businessFormKey.currentState
                          ?.validate();
                      if (businessError != null) {
                        showValidationMessage(businessError);
                        return;
                      }

                      context.read<LoadingCubit>().setLoading("Updating ...");
                      final detail = _businessFormKey.currentState?.buildDetail(
                        widget.itemModel.id,
                      );
                      final itemBarcode = _businessFormKey.currentState
                          ?.buildItemBarcode();
                      final value = await context.read<ItemCubit>().editItem(
                        userModel: userModel,
                        itemModel: widget.itemModel,
                        newName: itemNameController.text.trim(),
                        businessType: businessType,
                        categoryId: _selectedCategoryId,
                        groupId: _selectedGroupId,
                        typeId: selectedTypeModel.id,
                        newOriginalPrice: originalPrice,
                        newProfitPrice: profitPrice,
                        newTaxPercentage: taxPercentage,
                        needStock: businessType == BusinessType.food
                            ? _needStock
                            : true,
                        newCode: itemBarcode,
                        existingBusinessDetail: businessDetail,
                        businessDetail: detail,
                      );

                      if (!mounted) return;
                      if (value) {
                        context.read<LoadingCubit>().setSuccess("Success !");
                        Navigator.of(context).pop();
                      } else {
                        context.read<LoadingCubit>().setFail("Fail !");
                      }
                    }
                  },
                  clr: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: UIConstants.bigSpace * 2),
            ],
          ),
        ),
      ),
    );
  }
}
