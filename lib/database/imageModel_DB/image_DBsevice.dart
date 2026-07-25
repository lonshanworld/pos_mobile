import 'package:pos_mobile/database/imageModel_DB/image_DBStorage.dart';
import 'package:sqflite/sqflite.dart';

class ImageDbService {
  static Future<void> initImageDb(Database db) async {
    await ImageDbStorage.onCreate(db);
  }

  static Future<void> deleteImageDb(Database db) async {
    await ImageDbStorage.onDelete(db);
  }

  static Future<int> insertImage(Database db, String imagePath) async {
    return await ImageDbStorage.insertImage(db, imagePath);
  }

  static Future<String?> getImagePath(Database db, int imageId) async {
    return await ImageDbStorage.getImagePath(db, imageId);
  }

  static Future<int> updateImagePath(
    Database db, {
    required int imageId,
    required String imagePath,
  }) async {
    return ImageDbStorage.updateImagePath(
      db,
      imageId: imageId,
      imagePath: imagePath,
    );
  }
}
