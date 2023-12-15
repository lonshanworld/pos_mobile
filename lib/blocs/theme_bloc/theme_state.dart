part of 'theme_cubit.dart';

@immutable
abstract class ThemeState {
  final ThemeModeType themeModeType;
  const ThemeState({
    required this.themeModeType,
  });
}

class ThemeDataState extends ThemeState {
  const ThemeDataState({required super.themeModeType});
}