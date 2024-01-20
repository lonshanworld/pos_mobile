
abstract class Storage{

  Future<void>onCreate();
  Future<void>onDelete();
  Future<void>onUpgrade();

  Future<List<dynamic>>getAllData();
  Future<List<dynamic>>getSingleData(int data);

  Future<int>insertSingleData <T>(T data);


  Future<int>deactivateSingleData(int id);
  Future<int>deleteSingleData(int id);
}