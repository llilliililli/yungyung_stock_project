import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:yungyung_stock_project/login.dart';
import 'package:yungyung_stock_project/stockView.dart';
 
import 'package:yungyung_stock_project/main.dart';
 
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
 
  @override
  _TmpPageState createState() => _TmpPageState();
}
 
class _TmpPageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context){
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
 
  @override
  void initState(){
    super.initState();
 
    //_permission();
    _logout();
    print('--home auth');
    _auth();
 
  }
 
  @override
  void dispose(){
    super.dispose();
  }
 
  // 제거해도 되는 부분이나, 추후 권한 설정과 관련된 포스팅 예정
  // _permission() async{
  //   Map<Permission, PermissionStatus> statuses = await [
  //       Permission.storage,
  //   ].request();
  //   //logger.i(statuses[Permission.storage]);
  // }
 
  _auth(){
    print('--home auth in');
    // 사용자 인증정보 확인. 딜레이를 두어 확인
    Future.delayed(const Duration(milliseconds: 10),() {
      print('--home delay');
      print(FirebaseAuth.instance);
      print('--home currentUser');
      print(FirebaseAuth.instance.currentUser);
      if(FirebaseAuth.instance.currentUser == null){
        Get.off(() => const LoginPage());
      } else {
        Get.off(() => const StockViewPage(title: '융융증권',));
      }
    });
  }
 
  _logout() async{
    await FirebaseAuth.instance.signOut();
  }
 
}