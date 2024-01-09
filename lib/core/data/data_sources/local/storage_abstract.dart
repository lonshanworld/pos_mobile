
abstract class Storage{

  Future<void>onCreate();
  Future<void>onDelete();
  Future<void>onUpgrade();

  Future<List<dynamic>>getAllData();
  Future<List<dynamic>>getSingleData<T>(T data);

  Future<int>insertSingleData<T>(T data);

  Future<int>updateSingleLastUpdateTime<T>(T data);

  Future<int>deactivateSingleData<T>(T data);
  Future<int>deleteSingleData<T>(T data);
}