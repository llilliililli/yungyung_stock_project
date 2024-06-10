import 'package:flutter/material.dart';
//import 'package:yungyung_stock_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:yungyung_stock_project/login.dart';
import 'package:yungyung_stock_project/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(); //입력되는 값을 제어
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  Widget _userIdWidget(){
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '이메일',
      ),
      validator: (String? value){
        if (value!.isEmpty) {// == null or isEmpty
          return '이메일을 입력해주세요.';
        }
        return null;
      },
    );
  }
 
  Widget _passwordWidget(){
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호',
      ),
      validator: (String? value){
        if (value!.isEmpty) {// == null or isEmpty
          return '비밀번호를 입력해주세요.';
        }
        return null;
      },
    );
  }

  Widget _nickNameWidget(){
    return TextFormField(
      controller: _nickNameController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '이름(닉네임)',
      ),
      validator: (String? value){
        if (value!.isEmpty) {// == null or isEmpty
          return '이름(닉네임)을 입력해주세요.';
        }
        return null;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("회원가입"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              //Image(width: 400.0, height: 250.0, image: AssetImage(_imageFile)),
              const SizedBox(height: 20.0),
              _userIdWidget(),
              const SizedBox(height: 20.0),
              _passwordWidget(),
              const SizedBox(height: 20.0),
              _nickNameWidget(),
              Container(
                height: 70,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8.0), // 8단위 배수가 보기 좋음
                child: ElevatedButton(
                    onPressed: () => _join(),
                    child: const Text("회원가입")
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }



   @override
  void initState() {
    //해당 클래스가 호출되었을떄
    super.initState();
  }
  @override
  void dispose() {
    // 해당 클래스가 사라질떄
    _emailController.dispose();
    _passwordController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }
 
  _join() async {
    //키보드 숨기기
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(FocusNode());
 
      // Firebase 사용자 인증, 사용자 등록
      try {

        String uid = "";

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text)
          .then((value) {
            //print('join value :: '+value.toString());
            print('join value.user :: '+value.user!.toString());
            print('join value.user.uid :: '+value.user!.uid.toString());

            uid = value.user!.uid.toString();

            
            if (value.user!.email == null) {
            } else {
              //Navigator.pop(context);
            }
            
            return value;


          });

           String year = "2023"; // 최초년도 기입
          var yearStocksList = [];
          await _firestore.collection("year").doc(year).collection('stocks').get().then((value) {
            for(var docSnapShot in value.docs){
                //print(docSnapShot.data());
                yearStocksList.add(docSnapShot.data());
            }
          });


          print(yearStocksList);

          String name =_nickNameController.text;
          int money = 200000; // 최초 자금 기입

          await _firestore.collection("users").doc(uid).set({
                "name" : name,
                "money" : money,
                "uid" : uid
          });


          for(var yearStock in yearStocksList){

            String name = yearStock["name"] as String;
            String pmoney = yearStock["pmoney"] as String;
            String smoney = yearStock["smoney"] as String;
            String title = yearStock["title"] as String;
            String stock ="0";

            print('join yaer :: '+year);
            print('join name :: '+name);
            print('join pmoney :: '+pmoney);
            print('join smoney :: '+smoney);
            print('join title :: '+title);

            await _firestore.collection("users").doc(uid).collection("stocks").doc(name).set({
                "name" : name,
                "pmoney" : pmoney,
                "smoney" : smoney,
                "stock": stock,
                "title" : title
            });

          }


        Navigator.pop(context);  

 
        Get.offAll(() => const LoginPage());
      } on FirebaseAuthException catch (e) {
        //logger.e(e);
        String message = '';

        print('_join e.code :: ');
        print(e.code);
 
         if (e.code == 'weak-password') {
            print('the password provided is too weak');
          } else if (e.code == 'email-already-in-use') {
            print('The account already exists for that email.');
          } else {
            print('11111');
          }
        

        print('_join message :: ');
        print(message);
 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
 
    }
  }

}