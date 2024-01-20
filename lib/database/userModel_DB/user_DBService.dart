// import 'package:pos_mobile/database/historyModel_DB/history_DBservice.dart';
// import 'package:pos_mobile/database/userModel_DB/user_DBstorage.dart';
// import 'package:pos_mobile/models/user_model_folder/user_model.dart';
// import 'package:pos_mobile/utils/debug_print.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../../constants/enums.dart';
//
// class UserDBService{
//
//   static Future<void>initUserDB(Database db)async{
//     await UserDBStorage.oncreate(db);
//   }
//
//   static Future<void>deleteUserDb(Database db)async{
//     await UserDBStorage.onDelete(db);
//   }
//
//   static Future<bool>createNewUser({
//     required String userName,
//     required String password,
//     required UserLevel userLevel,
//     required Database db,
//   })async{
//     int value = await UserDBStorage.insertNewUser(db,userName: userName, password: password, userLevel: userLevel);
//     if(value == -1){
//       return false;
//     }else{
//       return true;
//     }
//   }
//
//   static Future<List<UserModel>>getAllUsers(Database db)async{
//     List<dynamic> dataList = await UserDBStorage.getAllData(db);
//     List<UserModel> userModelList = dataList.map((e) => UserModel.fromJson(e)).toList();
//     cusDebugPrint("This is userlistLength ${userModelList.length}");
//     return userModelList;
//   }
//
//   static Future<bool> loginLogoutUserUpdate(Database db, UserModel userModel, bool isLogin)async{
//     DateTime dateTime = DateTime.now();
//     List<dynamic> oldUserRawList = await UserDBStorage.getSingleUser(db, userModel.id);
//     if(oldUserRawList.isEmpty){
//       return false;
//     }else{
//       int value = isLogin ? await UserDBStorage.updateLoginTime(db, userModel.id,dateTime) : await UserDBStorage.updateLogoutTime(db, userModel.id,dateTime);
//       if(value == -1){
//         return false;
//       }else{
//         List<dynamic> newUserRawList = await UserDBStorage.getSingleUser(db, userModel.id);
//         if(newUserRawList.isEmpty){
//           return false;
//         }else{
//           UserModel oldUser = UserModel.fromJson(oldUserRawList[0]);
//           UserModel newUser = UserModel.fromJson(newUserRawList[0]);
//           cusDebugPrint(oldUserRawList[0]);
//           cusDebugPrint(newUserRawList[0]);
//           if(!isLogin){
//             return await HistoryDBService.addHistoryData(
//               oldData: newUser, // TODO : this is an exception because the old data will not be stored anyway
//               newData: newUser,
//               updateType: UpdateType.update,
//               createPersonId: userModel.id,
//               db: db,
//               dateTime: dateTime,
//             );
//           }else{
//             return true;
//           }
//         }
//       }
//     }
//
//   }
// }