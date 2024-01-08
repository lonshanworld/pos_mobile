import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/presentation/blocs/user_list/user_list_state/user_list_state.dart';

import '../../../../models/user_model_folder/user_model.dart';


class UserListCubit extends Cubit<UserListState> {
  UserListCubit() : super(const UserListState.initial()){

  }

  List<UserModel> get allUserList => state.when(
    initial: ()=>[],
    loading: () => [],
    loaded: (List<UserModel> dataList) => dataList,
    failed: (_) => [],
  );

  List<UserModel> get activeUserList => state.when(
    initial: () => [],
    loading: () => [],
    loaded: (List<UserModel> dataList){
      final List<UserModel> activeList = [];
      for(UserModel data in dataList){
        if(data.activeStatus) activeList.add(data);
      }
      return activeList;
    },
    failed: (_) => [],
  );
}
