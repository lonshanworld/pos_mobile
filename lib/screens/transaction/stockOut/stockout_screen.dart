import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/screens/transaction/stockOut/voucher_screen.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart';
import 'package:pos_mobile/widgets/itemBox/stockout_item_box_widget.dart';

import '../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../constants/enums.dart';
import '../../../constants/uiConstants.dart';
import '../../../controller/ui_controller.dart';
import '../../../features/cus_showmodelbottomsheet.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../widgets/loading_widget.dart';
import 'add_more_info_stockOut_screen.dart';

// TODO : please refix stockout screen by using bloc

class StockOutScreen extends StatefulWidget {
  static const String routeName = "/stockoutscreen";

  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final TextEditingController searchController = TextEditingController();
  List<ItemModel> searchResultItemList = [];
  List<ItemModel> sellItemModelList = [];
  List<UniqueItemModel> sellUniqueItemModelList = [];
  bool showLoading = false;

  double? deliveryCharges;
  double taxPercentage = 0;
  double? additionalPromotionAmount;
  String? description;
  String? customerName;
  String? deliveryName;
  ShoppingType shoppingType = ShoppingType.shop;
  PaymentMethod paymentMethod = PaymentMethod.cash;
  PromotionModel? promotion;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ItemModel> activeItemList = context.watch<ItemCubit>().state.activeItemList;
    final CusShowSheet cusShowModelBottomSheet = CusShowSheet();
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;


    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(50),
    );

    void searchItemFunc(String value){
      if(mounted){
        setState(() {
          searchResultItemList.clear();
          if(value.trim() != ""){
            for(int i = 0; i < activeItemList.length; i++){
              if(activeItemList[i].name.trim().toLowerCase().contains(value.trim().toLowerCase())){
                searchResultItemList.add(activeItemList[i]);
              }
            }
          }
        });
      }
    }

    void addSellItemModel(){
      if(mounted){
        sellItemModelList.clear();
      }
      for(int a = 0; a < sellUniqueItemModelList.length; a++){
        if(!sellItemModelList.map((e) => e.id).contains(sellUniqueItemModelList[a].itemId)){
          ItemModel? item = context.read<ItemCubit>().getItem(sellUniqueItemModelList[a].itemId);
          if(item != null){
            if(mounted){
              setState(() {
                sellItemModelList.add(item);
              });
            }
          }
        }
      }
    }

    void addSellUniqueItemList(UniqueItemModel data){
      if(mounted){
        setState(() {
          sellUniqueItemModelList.add(data);
        });
      }

      addSellItemModel();
    }

    void removeSellUniqueItemList(ItemModel data){
      List<UniqueItemModel> dataSelection = [];
      for(int i = 0; i < sellUniqueItemModelList.length; i++){
        if(data.id == sellUniqueItemModelList[i].itemId){
          dataSelection.add(sellUniqueItemModelList[i]);
        }
      }

      for(int i = 0; i < sellUniqueItemModelList.length; i++){
        if(sellUniqueItemModelList[i].id == dataSelection.last.id){
          if(mounted){
            setState(() {
              sellUniqueItemModelList.removeAt(i);
            });
          }
        }
      }
      addSellItemModel();
    }

  
    int getSearchIndex(int itemId){
      List<UniqueItemModel> dataSelection = [];
      for(int i = 0; i < sellUniqueItemModelList.length; i++){
        if(itemId == sellUniqueItemModelList[i].itemId){
          dataSelection.add(sellUniqueItemModelList[i]);
        }
      }
      return dataSelection.length;
    }

    void showInfoSnack(String txt) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(txt),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    void clearAllData(){
      if(mounted){
        setState(() {
          showLoading = true;
          searchController.clear();
          searchResultItemList.clear();
          sellItemModelList.clear();
          sellUniqueItemModelList.clear();
          deliveryCharges = null;
          taxPercentage = 0;
          additionalPromotionAmount = null;
          description = null;
          customerName = null;
          deliveryName = null;
          shoppingType = ShoppingType.shop;
          paymentMethod = PaymentMethod.cash;
          promotion = null;
        });
      }
      Future.delayed(const Duration(seconds: 3),(){
        if (!mounted) return;
        setState(() {
          showLoading = false;
        });
      });
    }

    return Scaffold(
      endDrawer: VoucherScreen(
        customerName: customerName,
        deliveryName: deliveryName,
        shoppingType: shoppingType,
        paymentMethod: paymentMethod,
        additionalPromotionAmount: additionalPromotionAmount,
        deliCharges: deliveryCharges,
        description: description,

        taxPercentage: taxPercentage,
        promotionModel: promotion,
        selectedUniqueItemList: sellUniqueItemModelList,
        selectedItemModelList: sellItemModelList,
        clearDataFunc: (){
          clearAllData();
        },
      ),

      body: showLoading
          ?
      const Center(
        child: LoadingWidget(),
      )
          :
      Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.bigSpace,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: UIConstants.mediumSpace
                    ),
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      style: Theme.of(context).textTheme.bodyLarge!,
                      onChanged: searchItemFunc,
                      decoration: InputDecoration(
                          labelText: "Search Items ...",
                          labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey,
                          ),
                          filled: false,
                          prefixIcon: const Icon(
                            Icons.search,
                            size: UIConstants.bigIcon,
                            color: Colors.grey,
                          ),
                          border: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.bigSpace,
                            vertical: UIConstants.mediumSpace,
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: UIConstants.bigSpace * 4
                      ),
                      child: Builder(
                        builder: (context) {
                          final isSearching = searchController.text.trim().isNotEmpty;
                          final itemsToShow = isSearching ? searchResultItemList : activeItemList;
                          
                          if (itemsToShow.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    isSearching ? "No items found matching '${searchController.text}'" : "No items available",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return GridView.builder(
                            padding: const EdgeInsets.all(UIConstants.smallSpace),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 300,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: UIConstants.mediumSpace,
                              mainAxisSpacing: UIConstants.mediumSpace,
                            ),
                            itemCount: itemsToShow.length,
                            itemBuilder: (context, index) {
                              final item = itemsToShow[index];
                              return StockOutItemBoxWidget(
                                itemModel: item,
                                reduceFunc: removeSellUniqueItemList,
                                addFunc: addSellUniqueItemList,
                                selectedUniqueItemList: sellUniqueItemModelList,
                                startIndex: getSearchIndex(item.id),
                              );
                            },
                          );
                        }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: UIConstants.bigSpace,
                right: UIConstants.bigSpace,
                top: UIConstants.mediumSpace,
                bottom: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom
                    : UIConstants.mediumSpace,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CusTxtIconElevatedBtn(
                      txt: "Add Details",
                      verticalpadding: 14,
                      horizontalpadding: UIConstants.smallSpace,
                      bdrRadius: UIConstants.smallRadius,
                      txtClr: Colors.white,
                      bgClr: Colors.amber,
                      txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      func: () {
                        cusShowModelBottomSheet.showCusBottomSheet(AddMoreInfoStockOutScreen(
                          func: ({
                            required double? additionalPromotionAmountInfo,
                            required String? customerNameInfo,
                            required double? deliveryChargesInfo,
                            required String? deliveryNameInfo,
                            required String? descriptionInfo,
                            required PaymentMethod paymentMethodInfo,
                            required ShoppingType shoppingTypeInfo,
                            required double taxPercentageInfo,
                            required PromotionModel? promotionModel,
                          }) {
                            if (mounted) {
                              setState(() {
                                additionalPromotionAmount = additionalPromotionAmountInfo;
                                customerName = customerNameInfo;
                                deliveryCharges = deliveryChargesInfo;
                                deliveryName = deliveryNameInfo;
                                description = descriptionInfo;
                                paymentMethod = paymentMethodInfo;
                                shoppingType = shoppingTypeInfo;
                                taxPercentage = taxPercentageInfo;
                                promotion = promotionModel;
                              });
                            }
                          },
                          selectedItemModelList: sellItemModelList,
                          selectedUniqueItemList: sellUniqueItemModelList,
                          deliveryChargesInfo: deliveryCharges,
                          taxPercentageInfo: taxPercentage,
                          additionalPromotionAmountInfo: additionalPromotionAmount,
                          descriptionInfo: description,
                          customerNameInfo: customerName,
                          deliveryNameInfo: deliveryName,
                          shoppingTypeInfo: shoppingType,
                          paymentMethodInfo: paymentMethod,
                          promotionModel: promotion,
                        ));
                      },
                      icon: Icons.edit_note,
                      iconSize: 22,
                    ),
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  Expanded(
                    flex: 4,
                    child: Builder(builder: (ctx) {
                      return CusTxtIconElevatedBtn(
                        txt: "Checkout (${sellUniqueItemModelList.length})",
                        verticalpadding: 14,
                        horizontalpadding: UIConstants.smallSpace,
                        bdrRadius: UIConstants.smallRadius,
                        bgClr: uiController.getpureOppositeClr(themeModeType),
                        txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        txtClr: uiController.getpureDirectClr(themeModeType),
                        func: () {
                          if (sellUniqueItemModelList.isEmpty) {
                            showInfoSnack("Please add at least one item before checkout.");
                            return;
                          }
                          Scaffold.of(ctx).openEndDrawer();
                        },
                        icon: Icons.shopping_cart_checkout,
                        iconSize: 22,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}
