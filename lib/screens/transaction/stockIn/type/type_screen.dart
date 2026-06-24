import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/screens/transaction/stockIn/type/create_type_screen.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/cusSelectTypeBtn_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";

class TypeScreen extends StatelessWidget {
  final bool isStorage;

  const TypeScreen({
    super.key,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    final businessType = UIController.instance.businessType;
    final typeLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.type,
    );
    final itemCubit = context.read<ItemCubit>();
    final typeList = context.select((ItemCubit cubit) => cubit.state.activeTypeList);

    return Scaffold(
      body: Stack(
        children: [
          if (typeList.isEmpty)
            Positioned.fill(
              child: NoItemWidget(
                noItemTxt: "No ${typeLabel.toLowerCase()} found",
              ),
            ),
          if (typeList.isNotEmpty)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.bigSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.label_outline_rounded, color: Colors.grey),
                        const SizedBox(width: UIConstants.smallSpace),
                        CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.titleSmall!,
                          txt: "${typeList.length} ${typeLabel.toLowerCase()}s",
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.mediumSpace),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: UIConstants.mediumSpace,
                          runSpacing: UIConstants.mediumSpace,
                          children: [
                            for (final typeModel in typeList)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CusSelectTypeBtnWidget(
                                    isSelected: false,
                                    typeModel: typeModel,
                                    func: () {},
                                    isStorage: isStorage,
                                    afterDeleteFunc: () {},
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: UIConstants.smallSpace,
                                      top: 4,
                                    ),
                                    child: Text(
                                      "${itemCubit.getItemCountForType(typeModel.id)} items",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isStorage)
            CreateItemBtnWidget(
              txt: "Create $typeLabel",
              widget: const CreateTypeScreen(),
            ),
        ],
      ),
    );
  }
}
