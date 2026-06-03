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
  
  // Pagination state
  final int stockInOffset;
  final int stockOutOffset;
  final bool hasMoreStockIn;
  final bool hasMoreStockOut;
  final bool isLoadingMoreStockIn;
  final bool isLoadingMoreStockOut;

  const TransactionsState({
    required this.activeStockInList,
    required this.activeStockOutList,
    required this.stockOutItemList,
    required this.customerList,
    required this.deliveryModelList,
    required this.activeDeliveryPersonList,
    required this.inActiveDeliveryPersonList,
    required this.inActiveStockInList,
    required this.inActiveStockOutList,
    this.stockInOffset = 0,
    this.stockOutOffset = 0,
    this.hasMoreStockIn = true,
    this.hasMoreStockOut = true,
    this.isLoadingMoreStockIn = false,
    this.isLoadingMoreStockOut = false,
  });
}

class TransactionsData extends TransactionsState {
  const TransactionsData({
    required super.activeStockInList,
    required super.activeStockOutList,
    required super.stockOutItemList,
    required super.customerList,
    required super.deliveryModelList,
    required super.activeDeliveryPersonList,
    required super.inActiveDeliveryPersonList,
    required super.inActiveStockInList,
    required super.inActiveStockOutList,
    super.stockInOffset = 0,
    super.stockOutOffset = 0,
    super.hasMoreStockIn = true,
    super.hasMoreStockOut = true,
    super.isLoadingMoreStockIn = false,
    super.isLoadingMoreStockOut = false,
  });
}
