import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mylibrary/helper/db_helper.dart';
import 'package:mylibrary/screens/main_screen.dart';
import 'package:mylibrary/utils/color_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DBHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyLibrary+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: ColorManager.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorManager.darkPink,
          primary: ColorManager.darkPink,
          secondary: ColorManager.pink,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorManager.darkPurple,
          foregroundColor: ColorManager.background,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
