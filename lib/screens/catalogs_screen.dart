import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/constants/business_hierarchy_config.dart';
import 'package:pos_mobile/screens/transaction/stockIn/category/category_screen.dart';
import 'package:pos_mobile/screens/transaction/stockIn/group/group_screen.dart';
import 'package:pos_mobile/screens/transaction/stockIn/type/type_screen.dart';
import 'package:pos_mobile/screens/screen_data_loader.dart';

class CatalogsScreen extends StatefulWidget {
  static const String routeName = "/catalogsscreen";

  const CatalogsScreen({super.key});

  @override
  State<CatalogsScreen> createState() => _CatalogsScreenState();
}

class _CatalogsScreenState extends State<CatalogsScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.items(context),
      ScreenDataLoader.shopInfo(context),
    ]);
  }

  @override
  Widget build(BuildContext context) => const _CatalogsContent();
}

class _CatalogsContent extends StatelessWidget {
  const _CatalogsContent();

  @override
  Widget build(BuildContext context) {
    final businessType = context.watch<ShopInfoCubit>().state.businessType;
    final categoryLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.category,
    );
    final groupLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.group,
    );
    final typeLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.type,
    );

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: categoryLabel),
              Tab(text: groupLabel),
              Tab(text: typeLabel),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                CategoryScreen(isStorage: true),
                GroupScreen(isStorage: true),
                TypeScreen(isStorage: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
