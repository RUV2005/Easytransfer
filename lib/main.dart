import 'dart:io'; // 添加此导入以检查平台
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/language_provider.dart';
import 'widgets/theme_notifier.dart';
import 'package:window_size/window_size.dart'; // 导入 window_size 包

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );

  // 确保在运行应用之前设置窗口大小
  if (Platform.isWindows) {
    setWindowTitle('易传');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
    setWindowFrame(Rect.fromLTWH(100, 100, 800, 1500));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLocale = 'zh'; // 默认语言

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeNotifier.instance,
      builder: (context, followSystemTheme, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w400), // Regular
              bodyLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w700), // Bold
              bodySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w300), // Light
              displayMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600), // Semibold
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: TextTheme(
              bodyMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w400),
              bodyLarge: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w700),
              bodySmall: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w300),
              displayMedium: TextStyle(fontFamily: 'MiSans', fontWeight: FontWeight.w600),
            ),
          ),
          themeMode: followSystemTheme ? ThemeMode.system : ThemeMode.light,
          locale: Locale(_currentLocale), // 使用当前语言
          home: const MyHomePage(),
        );
      },
    );
  }
}