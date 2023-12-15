part of 'transactions_cubit.dart';

@immutable
abstract class TransactionsState {
  final List<StockOutModel> activeStockOutList;
  final List<StockInModel> activeStockInList;
  final List<StockOutItemModel> stockOutItemList;
  final List<CustomerModel> customerList;
  final List<DeliveryModel> deliveryModelList;
  final List<DeliveryPersonModel> activeDeliveryPersonList;
  final List<StockOutModel> inActiveStockOutList;
  final List<StockInModel>inActiveStockInList;
  final List<DeliveryPersonModel> inActiveDeliveryPersonList;
  const TransactionsState({
    required this.activeStockInList,
    required this.activeStockOutList,
    required this.stockOutItemList,
    required this.customerList,
    required this.deliveryModelList,
    required this.activeDeliveryPersonList,
    required this.inActiveDeliveryPersonList,
    required this.inActiveStockInList,
    required this.inActiveStockOutList
  });
}

class TransactionsData extends TransactionsState {
  const TransactionsData({required super.activeStockInList, required super.activeStockOutList, required super.stockOutItemList, required super.customerList, required super.deliveryModelList, required super.activeDeliveryPersonList, required super.inActiveDeliveryPersonList, required super.inActiveStockInList, required super.inActiveStockOutList});
}
