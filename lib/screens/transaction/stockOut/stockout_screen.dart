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
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    List<ItemModel> activeItemList = context.watch<ItemCubit>().state.activeItemList;
    final CusShowSheet cusShowModelBottomSheet = CusShowSheet();


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
      if(mounted){
        setState(() {

        });
      }
      return dataSelection.length;
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
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: UIConstants.bigSpace * 4
                        ),
                        child: Wrap(
                          spacing: UIConstants.bigSpace,
                          runSpacing: UIConstants.bigSpace,
                          alignment: WrapAlignment.center,
                          children: searchController.text.trim().toString().isEmpty || searchController.text.trim() == ""
                              ?
                          activeItemList.map((e){
                            return StockOutItemBoxWidget(
                              itemModel: e,
                              reduceFunc: removeSellUniqueItemList,
                              addFunc: addSellUniqueItemList,
                              selectedUniqueItemList: sellUniqueItemModelList,
                              startIndex: getSearchIndex(e.id),
                            );
                          }).toList()
                              :
                          searchResultItemList.map((e){
                            return StockOutItemBoxWidget(
                              itemModel: e,
                              reduceFunc: removeSellUniqueItemList,
                              addFunc: addSellUniqueItemList,
                              selectedUniqueItemList: sellUniqueItemModelList,
                              startIndex: getSearchIndex(e.id),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: -10,
            child: RotatedBox(
              quarterTurns: 3,
              child: Builder(
                  builder: (ctx) {
                    return CusTxtIconElevatedBtn(
                      txt: "Check Voucher",
                      verticalpadding: UIConstants.smallSpace,
                      horizontalpadding: UIConstants.mediumSpace,
                      bdrRadius: UIConstants.smallRadius,
                      bgClr: uiController.getpureOppositeClr(themeModeType),
                      txtStyle: Theme.of(ctx).textTheme.titleSmall!,
                      txtClr: uiController.getpureDirectClr(themeModeType),
                      func: (){
                        Scaffold.of(ctx).openEndDrawer();
                      },
                      icon: Icons.arrow_drop_down,
                      iconSize: UIConstants.normalNormalIconSize,
                    );
                  }
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Builder(
                builder: (ctx) {
                  return CusTxtIconElevatedBtn(
                    txt: "Stock-out detail",
                    verticalpadding: UIConstants.smallSpace,
                    horizontalpadding: UIConstants.mediumSpace,
                    bdrRadius: UIConstants.smallRadius,
                    bgClr: Colors.amber,
                    txtStyle: Theme.of(ctx).textTheme.titleSmall!,
                    txtClr: Colors.purple,
                    func: (){
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
                          if(mounted){
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
                    icon: Icons.arrow_drop_down,
                    iconSize: UIConstants.normalNormalIconSize,
                  );
                }
            ),
          ),
        ],
      ),

    );
  }
}
