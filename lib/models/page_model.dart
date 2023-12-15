import 'package:flutter/material.dart';

// for screen components
// NOTE : the title in this model is not for page title, it is for draweritem's name
@immutable
class PageModel{
  final Widget screen;
  final String title;

  const PageModel({
    required this.screen,
    required this.title,
  });
}