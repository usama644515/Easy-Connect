import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const COLOR_PRIMARY = kbgColor;
const COLOR_PRIMARY_DARK = Colors.white;
const COLOR_ACCENT = Color(0xFFFFBD00);
const COLOR_BACKGROUND_DARK = Color(0xFF171822);
const COLOR_BACKGROUND = Colors.white;
const COLOR_BACKGROUND_LIGHT = Color(0xFFF1F3F6);
const COLOR_BLACK = Color(0xFF000000);

const kbuttonColor = Colors.lightBlueAccent;
const kbgColor = Color(0xFF56b7e6);

// const kcardColor = Color(0xECEA6DF5);
const kcardColor = Color(0xFFCECEC1);

ThemeData lightTheme = ThemeData(
  splashColor: Color.fromARGB(255, 128, 204, 248),
  shadowColor: const Color(0XFFFFF0F0),
  hintColor: Colors.black,
  accentColor: Color(0xFF56b7e6),
  brightness: Brightness.light,
  backgroundColor: COLOR_BACKGROUND,
  primaryColor: COLOR_PRIMARY,
  cardColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  iconTheme: const IconThemeData(
    color: Color(0xFF000000),
  ),
  textTheme: TextTheme(
    titleSmall: TextStyle(
      color: Colors.black,
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: COLOR_BACKGROUND_LIGHT,
      primary: Color(0xFF000000),
      brightness: Brightness.light),
);

ThemeData darkTheme = ThemeData(
  splashColor: COLOR_BACKGROUND_DARK,
  shadowColor: const Color(0xFF212330),
  hintColor: Colors.white,
  accentColor: Colors.white,
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF212330),
  backgroundColor: COLOR_BACKGROUND_DARK,
  dialogBackgroundColor: COLOR_BACKGROUND_DARK,
  textTheme: TextTheme(
    titleSmall: TextStyle(
      color: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xffffffff),
  ),
  scaffoldBackgroundColor: Colors.black,
  cardColor: const Color(0xFF212330),
  colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: COLOR_BACKGROUND_LIGHT,
      primary: Colors.white,
      brightness: Brightness.dark),
);
