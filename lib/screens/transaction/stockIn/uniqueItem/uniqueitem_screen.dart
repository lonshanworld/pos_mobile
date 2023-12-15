import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/models/item_model_folder/item_model.dart";
import "package:pos_mobile/models/item_model_folder/uniqueItem_model.dart";
import "package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart";
import "package:pos_mobile/widgets/itemBox/uniqueitem_box_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";

import "../../../../constants/uiConstants.dart";

class UniqueItemScreen extends StatelessWidget {
  static const String routeName = "/uniqueItemScreen";

  final ItemModel item;
  const UniqueItemScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // final List<UniqueItemModel> activeUniqueItemList = context.watch<ItemCubit>().state.activeUniqueItemList;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        leading: const CusLeadingBackIconBtn(),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: BlocBuilder<ItemCubit, ItemState>(
            builder: (ctx, state){
              final List<UniqueItemModel> activeUniqueItemList = ctx.read<ItemCubit>().getSelectedUniqueItemList(item.id);
              return  activeUniqueItemList.isEmpty 
                  ?
              const Center(
                child: NoItemWidget(noItemTxt: "There is no item"),
              )
                  :
              Wrap(
                alignment: WrapAlignment.center,
                spacing: UIConstants.bigSpace,
                runSpacing: UIConstants.bigSpace,
                children: activeUniqueItemList.map((e) => UniqueItemBoxWidget(
                  uniqueItemModel: e,
                  index: activeUniqueItemList.indexOf(e),
                )).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
