import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yungyung_stock_project/second.dart'; // 화면추가
import 'package:get/get.dart';
//import 'package:yungyung_stock_project/main.dart';
import 'package:yungyung_stock_project/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:yungyung_stock_project/stockBuyDetail.dart';


class StockBuyMainPage extends StatefulWidget {
  const StockBuyMainPage({super.key, required this.title});

  final String title;

  @override
  State<StockBuyMainPage> createState() => _StockBuyMainPageState();
}

class _StockBuyMainPageState extends State<StockBuyMainPage> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _fireauth = FirebaseAuth.instance;


 
  var koMoneyUnit = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  var moneyUnit = NumberFormat('###,###,###,###');
  String totalMoney = '10,000';
  String afterMoney = '+10,000';

  var stockList = [
    {
      "title": "T_자동차",
      "smoney": '100000',
      "stock": '2',
      "pmoney": '200000',
      "percent": '25%'
    },
    {
      'title': "S_전자",
      'smoney': '50000',
      'stock': '3',
      'pmoney': '4500',
      'percent': '-25%'
    },
    {
      'title': "Y_엔터",
      'smoney': '10000',
      'stock': '5',
      'pmoney': '9000',
      'percent': '-25%'
    },
    {
      'title': "P_바이오",
      'smoney': '1000',
      'stock': '2',
      'pmoney': '10000',
      'percent': '1000%'
    },
    {
      'title': "G_뷰티",
      'smoney': '2000',
      'stock': '7',
      'pmoney': '1000',
      'percent': '-100%'
    },
    {
      'title': "J_조선",
      'smoney': '20000',
      'stock': '2',
      'pmoney': '20000',
      'percent': '0%'
    },
    {
      'title': "K_IT",
      'smoney': '30000',
      'stock': '1',
      'pmoney': '20000',
      'percent': '10%'
    },
    {
      'title': "Z_화학",
      'smoney': '10000',
      'stock': '1',
      'pmoney': '1000',
      'percent': '-1000%'
    },
  ];


  //총평가금액 계산
  int calTotalMoney(){
    int total = 0;


    for(int i=0 ; i<stockList.length;i++){
     String pmoney = stockList[i]['pmoney'] as String;
     String stock = stockList[i]['stock'] as String;
     total = total+(int.parse(pmoney)*int.parse(stock));
    }
   
    return total;
    
  }

  //작년금액/대비 계산
  String calAfterMoney(String chk){
    int after = 0; // 작년금액
    int total = 0; //현재평가금액
    int cal = 0; //작년대비 계산 (금액)
    double per = 0; //작년대비 계산 (%)
    for(int i=0 ; i<stockList.length;i++){
     //String smoney = stockList[i]['smoney'] as String;
     String pmoney = stockList[i]['pmoney'] as String;
     String stock = stockList[i]['stock'] as String;
     total = total+(int.parse(pmoney)*int.parse(stock));
     after = after+int.parse(pmoney);
    }

    String afterS = '';

    if(chk == 'm'){ //작년금액 
      afterS = moneyUnit.format(after);

      if (after > 0){ 
        afterS = '+'+afterS;
      }else{
        afterS = '-'+afterS;
      }
    }else if(chk =='e'){ //작년대비
      cal = total - after;
      per = after/(total/100);
      afterS =  moneyUnit.format(cal);

      if (after > 0){ 
        afterS = '+'+afterS+' ( +'+per.toStringAsFixed(0)+'% )';
      }else{
        afterS = '-'+afterS+' ( -'+per.toStringAsFixed(0)+'% )';
      }
    }


    return afterS;
  }

  //수익율 계산
  String calRate(String smoney, String pmoney){
    String rate =''; //수익율
    int sint = int.parse(smoney); // 매입금액
    int pint = int.parse(pmoney); // 현재금액

    double cal = pint/(sint/100)-100;

    rate = cal.toStringAsFixed(0)+'%';

    return rate;
  }
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor:Colors.yellow,
        title: Center(child: Text(widget.title,style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color.fromARGB(238, 233, 230, 230),
          child: 
          Column(
          children: <Widget>[
            // 주식구매자 선택
            Flexible(
              flex: 1,
              child:  Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.white,
              margin: EdgeInsets.all(7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("주식구매자 선택"),
                  //Text(koMoneyUnit.format(calTotalMoney()))
                  //  FutureBuilder(
                  //   future: _firestore.collection('users').doc(_fireauth.currentUser!.uid).get(), 
                  //   builder: (BuildContext context, AsyncSnapshot snapshot){
                  //       if (snapshot.hasData == false) {
                  //         return CircularProgressIndicator();
                  //       }
                  //       //error가 발생하게 될 경우 반환하게 되는 부분
                  //       else if (snapshot.hasError) {
                  //         return Padding(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Text(
                  //             'Error: ${snapshot.error}',
                  //             style: TextStyle(fontSize: 15),
                  //           ),
                  //         );
                  //       }
                  //       else { // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                  //         int money = snapshot.data['money'];
                  //         String showMoney =  '';      

                  //         if (money > 0){ 
                  //           showMoney = '+'+money.toString();
                  //         }else{
                  //           showMoney = '-'+money.toString();
                  //         }

                  //         return Text(showMoney);
                  //       }
                  //   }
                  // ),
                ],
              ),
            ),
            ),
            Flexible(
              flex: 9,
              child:     //구매자명단
            Container(
              width: MediaQuery.of(context).size.width,
              height:  MediaQuery.of(context).size.height,
              color: Colors.white,
              margin: EdgeInsets.all(7),
              child: Column(
                children: [
                  const Text("구매자 명단"),
                  Container(height: 1, color: Colors.black,margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height:  600,
                    // color: Colors.brown,
                    child: 
                    StreamBuilder(
                        stream: _firestore.collection('users').snapshots(),
                        builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;

                          print('doc.length ::'+docs.length.toString());

                          print('doc :: $docs');
                          print('uid1 :: '+docs[0]['uid'].toString());
                          print('uid2 :: '+docs[1]['uid'].toString());

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                            return 
                            stockBuyUserContainer(
                              name: docs[index]["name"] as String,
                              uid: docs[index]["uid"] as String,
                            );
                              }
                            );
                        }
                      )
                  )       
                ],
              ),
            ),
          ),
        
          ],
        ),
        )
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), 
    );
  }

  void goBuyDetail(String name,String uid){
    print('goBuyDetail :: name :: '+name+' / uid :: '+uid);
    Get.to(() => StockBuyDetailPage(name: name,uid: uid));
  }


  Widget stockBuyUserContainer({String name ='',String uid = '',Color colorData = Colors.yellow}){ //주식 Container
    return Container(
           width: MediaQuery.of(context).size.width,
           height: 100,
           margin: EdgeInsets.all(5),
           color: colorData,
           child: Container(
              alignment: Alignment.center,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: colorData,
                  textStyle: const TextStyle(
                    fontSize: 20,
                  )
                ),
                onPressed: () => {
                  goBuyDetail(name,uid)
                },
                child: Text(name),
              ),
            ),
          );
  }

   @override
  void initState(){
    super.initState();
 
  }

  // 로그아웃 
  Future signOut() async {
    try {
      print('sign out complete');
      Get.off(() => const LoginPage());
      return await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('sign out failed');
      print(e.toString());

      String message = '';

      message = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.deepOrange,
        ),
      );

      return null;
      
    }
  }

}


