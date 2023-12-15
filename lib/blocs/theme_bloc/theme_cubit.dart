import "package:flutter_bloc/flutter_bloc.dart";
import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/database/theme_db.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeDB _themeDB = ThemeDB();

  ThemeCubit() : super(const ThemeDataState(themeModeType: ThemeModeType.light)){
    bool value = _themeDB.getThemeDbData();
    if(value == true){
      emit(const ThemeDataState(themeModeType: ThemeModeType.light));
    }else{
      emit(const ThemeDataState(themeModeType: ThemeModeType.dark));
    }
  }

  Future<void> switchTheme()async{
    if(state.themeModeType == ThemeModeType.light){
      _themeDB.setThemeDbData(false);
      emit(const ThemeDataState(themeModeType: ThemeModeType.dark));
    }else{
      _themeDB.setThemeDbData(true);
      emit(const ThemeDataState(themeModeType: ThemeModeType.light));
    }
  }

  ThemeMode getThemeMode(){
    bool value = _themeDB.getThemeDbData();
    if(value == true){
      return ThemeMode.light;
    }else{
      return ThemeMode.dark;
    }
  }

  // ThemeModeType getThemeModeType(){
  //   return state.themeModeType;
  // }
}
