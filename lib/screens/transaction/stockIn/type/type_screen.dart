import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/screens/transaction/stockIn/type/create_type_screen.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/cusSelectTypeBtn_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";
import "package:pos_mobile/screens/screen_data_loader.dart";

class TypeScreen extends StatefulWidget {
  final bool isStorage;

  const TypeScreen({super.key, required this.isStorage});

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() => ScreenDataLoader.items(context);

  @override
  Widget build(BuildContext context) {
    final businessType = UIController.instance.businessType;
    final typeLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.type,
    );
    final typeList = context.select(
      (ItemCubit cubit) => cubit.state.activeTypeList,
    );
    final canCreate =
        widget.isStorage &&
        context.watch<UserDataCubit>().state.userModel?.userLevel ==
            UserLevel.merchant;

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
                        const Icon(
                          Icons.label_outline_rounded,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: UIConstants.smallSpace),
                        CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.titleSmall!,
                          txt: "${typeList.length} ${typeLabel.toLowerCase()}s",
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.mediumSpace),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.smallSpace,
                        ),
                        itemCount: typeList.length,
                        separatorBuilder: (_, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final typeModel = typeList[index];
                          return CusSelectTypeBtnWidget(
                            isSelected: false,
                            typeModel: typeModel,
                            func: () {},
                            isStorage: widget.isStorage,
                            afterDeleteFunc: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (canCreate)
            CreateItemBtnWidget(
              txt: "Create $typeLabel",
              widget: const CreateTypeScreen(),
            ),
        ],
      ),
    );
  }
}
