import 'package:collection/collection.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/core/domain/entities/error_entity/error_entity.dart';
import 'package:pos_mobile/error_handlers/error_handler.dart';
import 'package:pos_mobile/features/accounts/domain/entities/user_entity.dart';
import 'package:pos_mobile/features/auth/domain/entities/user_form_entity/user_form_entity.dart';
import '../../../../accounts/presentation/blocs/user_list/user_list_cubit.dart';
import 'auth_state/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final UserListCubit _userListCubit;
  AuthCubit(UserListCubit userListCubit)
      :
        _userListCubit = userListCubit,
        super(const AuthState.initial());

  final ErrorHandlers _errorHandlers = ErrorHandlers();

  Future<Either<ErrorEntity, UserEntity>>checkUserList(UserFormEntity userFormEntity)async{
    List<UserEntity> userList = _userListCubit.activeUserList;
    UserEntity? userEntity =  userList.firstWhereOrNull((element){
      if(userFormEntity.userName == element.userName &&
        userFormEntity.password == element.password &&
        userFormEntity.userLevel == element.userLevel){
        return true;
      }
      return false;
    });
    if(userEntity == null){
      return Left(ErrorEntity(
        title: "Authentication Failed",
        txt: "User not found",
      ));
    }else{
      return Right(userEntity);
    }
  }

  Future<void>login(UserFormEntity userFormEntity)async{
    emit(const AuthState.loading());
    Either<ErrorEntity, UserEntity> userEntity = await checkUserList(userFormEntity);
    if(userEntity.isLeft){
      emit(AuthState.fail(userEntity.left));
    }else{
      emit(AuthState.success(userEntity.right));
    }

  }
}
