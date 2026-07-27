import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:collection/collection.dart";
import "package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/constants/business_type_utils.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/services/pos_repository.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/models/groupingItem_models_folders/type_model.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import "package:pos_mobile/utils/formula.dart";
import "package:pos_mobile/widgets/business_item_detail_form.dart";
import "package:pos_mobile/widgets/btns_folder/cusTextOnlyBtn_widget.dart";
import "package:pos_mobile/widgets/btns_folder/cus_switch_btn_widget.dart";
import "package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart";
import "package:pos_mobile/widgets/cusTextField/cusTextArea_widget.dart";
import "package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:image_picker/image_picker.dart";
import "package:pos_mobile/services/public_document_storage.dart";
import "package:pos_mobile/services/image_upload_service.dart";
import "package:pos_mobile/screens/screen_data_loader.dart";

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController textAreaController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final GlobalKey<BusinessItemDetailFormState> _businessFormKey =
      GlobalKey<BusinessItemDetailFormState>();

  int? _selectedCategoryId;
  int? _selectedGroupId;
  int? _selectedTypeId;
  double originalPrice = 0;
  double profitPrice = 0;
  double taxPercentage = 0;
  bool _needStock = true;
  String? _selectedImagePath;
  String? _selectedImageSourceMimeType;

  @override
  void initState() {
    super.initState();
    unawaited(loadData());

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
        taxPercentage = double.tryParse(taxController.text.trim()) ?? 0;
      });
    });
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.items(context),
      ScreenDataLoader.shopInfo(context),
      ScreenDataLoader.users(context),
    ]);
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

  Future<void> _pickItemImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      // Keep the image-source actions opaque. The app-wide bottom-sheet theme
      // is transparent, which otherwise lets the modal barrier wash out the
      // entire item form behind it.
      backgroundColor: Theme.of(context).colorScheme.surface,
      barrierColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take with camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: ImageUploadService.maxDimension.toDouble(),
      maxHeight: ImageUploadService.maxDimension.toDouble(),
      imageQuality: 88,
    );
    if (picked == null) return;

    try {
      final prepared = await ImageUploadService.prepare(picked);
      final destination = kIsWeb
          ? prepared.dataUrl
          : await PublicDocumentStorage.saveBytes(
              bytes: prepared.bytes,
              fileName: prepared.fileName,
              directory: 'item_images',
            );
      if (mounted) {
        setState(() {
          _selectedImagePath = destination;
          _selectedImageSourceMimeType = prepared.sourceMimeType;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save item image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context
        .watch<ThemeCubit>()
        .state
        .themeModeType;
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final BusinessType businessType = context
        .watch<ShopInfoCubit>()
        .state
        .businessType;
    final shopInfoState = context.watch<ShopInfoCubit>().state;
    final bool showItemTax =
        shopInfoState.taxEnabled && shopInfoState.itemTaxEnabled;
    final bool allowExpiryTracking = businessType.allowsExpiryTracking;
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
    final TypeModel? selectedTypeModel = _selectedTypeId == null
        ? null
        : itemState.allActiveTypeList.firstWhereOrNull(
            (type) => type.id == _selectedTypeId,
          );

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
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
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
              Column(
                children: [
                  if (allowExpiryTracking) ...[
                    CusTxtWidget(
                      txtStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                      txt: "Expire tracking follows the selected $typeLabel.",
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
                          boolValue: selectedTypeModel?.hasExpire ?? false,
                          func: (bool value) {},
                          clr: Colors.blue,
                        ),
                      ],
                    ),
                  ],
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
              if (showItemTax)
                priceInputField(
                  hintTxt: "Enter tax percentage",
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
                    if (showItemTax && taxPercentage > 0)
                      resultRow(
                        "Tax",
                        CalculationFormula.getPercentageToMMK(
                          originalPrice + profitPrice,
                          taxPercentage,
                        ).toString(),
                      ),
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
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.grey),
                  txt: "Optional",
                ),
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.smallSpace,
                cusWidth: null,
              ),
              CusTextArea(
                txtController: textAreaController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding:
                    UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter description",
                txtStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: UIConstants.mediumSpace),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Item image (optional)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: UIConstants.smallSpace),
              Row(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    color: Colors.grey.withValues(alpha: 0.05),
                    child: _selectedImagePath == null
                        ? Center(
                            child: Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.grey.withValues(alpha: 0.25),
                            ),
                          )
                        : kIsWeb && _selectedImagePath!.startsWith('data:')
                        ? Image.memory(
                            base64Decode(
                              _selectedImagePath!.substring(
                                _selectedImagePath!.indexOf(',') + 1,
                              ),
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          )
                        : Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  OutlinedButton.icon(
                    onPressed: _pickItemImage,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add image'),
                  ),
                ],
              ),
              BusinessItemDetailForm(
                key: _businessFormKey,
                businessType: businessType,
                initialBarcode: null,
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.mediumSpace,
                cusWidth: null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Create",
                  clr: Colors.deepPurpleAccent,
                  func: () async {
                    if (selectedTypeModel == null) {
                      showValidationMessage("Choose a $typeLabel first");
                    } else if (itemNameController.text.trim().isEmpty) {
                      showValidationMessage("Item name should not be empty");
                    } else if (businessType != BusinessType.food &&
                        originalPrice < 1) {
                      showValidationMessage(
                        "Original price must be greater than zero",
                      );
                    } else if (double.tryParse(
                              sellPriceController.text.trim(),
                            ) ==
                            null ||
                        (showItemTax &&
                            double.tryParse(taxController.text.trim()) ==
                                null)) {
                      showValidationMessage(
                        "Sell price and tax must be valid numbers",
                      );
                    } else {
                      final businessError = _businessFormKey.currentState
                          ?.validate();
                      if (businessError != null) {
                        showValidationMessage(businessError);
                        return;
                      }

                      final loadingCubit = context.read<LoadingCubit>();
                      final itemCubit = context.read<ItemCubit>();
                      final navigator = Navigator.of(context);

                      final businessDetail = _businessFormKey.currentState
                          ?.buildDetail(0);
                      final itemBarcode = _businessFormKey.currentState
                          ?.buildItemBarcode();
                      if (itemBarcode != null &&
                          !await PosRepository.instance.isBarcodeAvailable(
                            itemBarcode,
                          )) {
                        showValidationMessage(
                          'This barcode is already in use. Please enter a different barcode.',
                        );
                        return;
                      }
                      loadingCubit.setLoading("Creating ...");
                      final value = await itemCubit.createNewItem(
                        userModel: userModel,
                        categoryId: _selectedCategoryId,
                        groupId: _selectedGroupId,
                        typeModel: selectedTypeModel,
                        name: itemNameController.text.trim(),
                        description: textAreaController.text.trim().isEmpty
                            ? null
                            : textAreaController.text.trim(),
                        hasExpire:
                            allowExpiryTracking && selectedTypeModel.hasExpire,
                        profitPrice: profitPrice,
                        originalPrice: originalPrice,
                        taxPercentage: showItemTax ? taxPercentage : 0,
                        needStock: businessType == BusinessType.food
                            ? _needStock
                            : true,
                        code: itemBarcode,
                        imagePath: _selectedImagePath,
                        imageSourceMimeType: _selectedImageSourceMimeType,
                        businessDetail: businessDetail,
                      );

                      if (!mounted) return;
                      if (value) {
                        loadingCubit.setSuccess("Success !", showDialog: false);
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      } else {
                        loadingCubit.setFail(
                          "Item could not be created. Please check the barcode and item details.",
                        );
                      }
                    }
                  },
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
