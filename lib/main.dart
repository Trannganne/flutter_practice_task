import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/firebase_options.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/explorepage.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/weather_background_service.dart';
import 'package:flutterpractisetasks/hub/dev_hub_screen.dart';
import 'package:flutterpractisetasks/permissions/hard/core/keys/app_key.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/field_report_screen.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/main_shell_screen.dart';
import 'package:flutterpractisetasks/permissions/medium/screens/home_screen.dart';
import 'package:flutterpractisetasks/push_notification/background_handler.dart';

import 'image_picker_demo.dart' as demo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo workmanager (dùng cho Smart Daily Planner - Local Notification Hard)
  WeatherBackgroundService().initBackgroundTask();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');

  // Đăng ký handler tổng — chỗ DUY NHẤT trong app gọi hàm này
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Lưu ý: KHÔNG khởi tạo sẵn cả 6 NotificationService ở đây nữa.
  // Mỗi bài (Easy/Medium/Hard của cả Push lẫn Local Notification) tự gọi
  // NotificationService.initialize() của chính nó ngay khi người dùng mở bài
  // đó từ DevHubScreen (xem lib/hub/dev_hub_screen.dart). Nhờ vậy:
  //  - Việc xin quyền notification chỉ hiện ra đúng lúc người dùng thực sự vào
  //    bài tập đó (đúng UX, không xin quyền tràn lan lúc mở app).
  //  - 3 module Push Notification không giẫm chân nhau khi đăng ký
  //    FirebaseMessaging.onBackgroundMessage (mỗi module có handler riêng).
  //  - Cả 3 module Local Notification (vốn trước đây KHÔNG hề được gọi
  //    initialize() ở đâu cả) giờ chắc chắn được khởi tạo plugin trước khi
  //    dùng, tránh lỗi "chưa initialize" khi bấm Test/Schedule.

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Practice Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DevHubScreen(),
      //home: const Explorepage(), //MainShellScreen(key: mainShellKey),
      // home: const demo.MyApp(),
    );
  }
}
