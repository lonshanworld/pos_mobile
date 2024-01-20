import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/dependencies.dart';
import 'package:pos_mobile/features/accounts/domain/entities/user_entity.dart';
import 'package:pos_mobile/features/accounts/presentation/blocs/user_list/user_list_state/user_list_state.dart';

import '../../../domain/repos/accounts_repo.dart';



class UserListCubit extends Cubit<UserListState> {
  UserListCubit() : super(const UserListState.initial()){
    initData();
  }

  final AccountRepo accountRepo = Dependencies.accountRepo;

  void initData()async{
    emit(const UserListState.loading());
    List<UserEntity> dataList = await accountRepo.getAllUserList();
    emit(UserListState.loaded(dataList));
  }

  List<UserEntity> get allUserList => state.when(
    initial: ()=>[],
    loading: () => [],
    loaded: (List<UserEntity> dataList) => dataList,
    failed: (_) => [],
  );


  List<UserEntity> get activeUserList => state.when(
    initial: () => [],
    loading: () => [],
    loaded: (List<UserEntity> dataList) => dataList,
    failed: (_) => [],
  );


}
