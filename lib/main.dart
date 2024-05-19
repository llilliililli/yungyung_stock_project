import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yungyung_stock_project/home.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:yungyung_stock_project/stockView.dart';
import 'firebase_options.dart';


var logger = Logger(
  printer: PrettyPrinter(),
);
 
Future<void> main() async{
  print('-- main');
  WidgetsFlutterBinding.ensureInitialized();
  print('-- WidgetsFlutterBinding.ensureInitialized');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('-- main: Firebase.initializeApp');
  runApp(const MyApp());
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const MyHomePage(),
    );
  }

  @override
  void initState() {
    super.initState();
 
  }
 
  @override
  dispose() async {
    super.dispose();
 
  }

 

}


