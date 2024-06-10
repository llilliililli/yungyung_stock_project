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


class StockYearUpdate extends StatefulWidget {
  const StockYearUpdate({super.key, required this.title});

  final String title;

  @override
  State<StockYearUpdate> createState() => _StockYearUpdatePageState();
}

class _StockYearUpdatePageState extends State<StockYearUpdate> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _fireauth = FirebaseAuth.instance;


 
  var koMoneyUnit = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  var moneyUnit = NumberFormat('###,###,###,###');
  String totalMoney = '10,000';
  String afterMoney = '+10,000';


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
                  const Text("현재 주식 정보"),
                  //Text(koMoneyUnit.format(calTotalMoney()))
                   FutureBuilder(
                    future: _firestore.collection('users').doc(_fireauth.currentUser!.uid).get(), 
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                        if (snapshot.hasData == false) {
                          return CircularProgressIndicator();
                        }
                        //error가 발생하게 될 경우 반환하게 되는 부분
                        else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 15),
                            ),
                          );
                        }
                        else { // 데이터를 정상적으로 받아오게 되면 다음 부분을 실행하게 되는 것이다.
                          int money = snapshot.data['money'];
                          String showMoney =  '';      

                          if (money > 0){ 
                            showMoney = '+'+money.toString();
                          }else{
                            showMoney = '-'+money.toString();
                          }

                          return Text(showMoney);
                        }
                    }
                  ),
                ],
              ),
            ),
            ),
            Flexible(
              flex: 9,
              child:     //주식정보연도
            Container(
              width: MediaQuery.of(context).size.width,
              height:  MediaQuery.of(context).size.height,
              color: Colors.white,
              margin: EdgeInsets.all(7),
              child: Column(
                children: [
                  const Text("주식정보연도"),
                  Container(height: 1, color: Colors.black,margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height:  600,
                    // color: Colors.brown,
                    child: 
                    StreamBuilder(
                        stream: _firestore.collection('year').snapshots(),
                        builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;

                          print('doc :: $docs');

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                            return
                            GestureDetector( // 제스처 기능 추가
                            onTap: (){
                              debugPrint(docs[index]["title"]);
                              showPopup(context, docs[index]["title"]);
                            },
                            child:  stockBuyUserContainer(
                              name: docs[index]["title"] as String,
                              //uid: docs[index]["uid"] as String,
                            ),
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





final TextEditingController _stockBuySellController = TextEditingController(text: '0');

void showPopup(context, year){ //구매/판매 팝업
  showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Flexible(
                  flex: 2,
                  child:  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(8), 
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                      child: Text(year),
                      ),
                ),
               

                const SizedBox(
                  height: 10,
                ),
               

                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    //변경 버튼
                    ElevatedButton.icon(onPressed: () => _changeStocks(year),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.blue,
                      ),
                      label: const Text('변경'),
                    ),
                    //생성버튼
                    ElevatedButton.icon(onPressed: () => _createStocks(year),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.blue,
                      ),
                      label: const Text('생성'),
                    ),
                    ElevatedButton.icon(onPressed: () {  //닫기 버튼
                      Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                      label: const Text('close'),
                    )
                    ],
                  ))
                
              ],
            ),
          ),
        );
      }
      );
  }


// 주식 정보 변경 
 Future _changeStocks (year) async{
    
    print("주식 정보 변경");
    try{
      // print('money :: $money');
      print(_fireauth.currentUser?.uid);
      // print(widget.name);
      print(year);


      String message = '';
      // String stock_ch = _stockBuySellController.text;
      // int buyStockMoney = int.parse(pmoney) * int.parse(stock_ch);
      // int buyStock = int.parse(stock)+int.parse(stock_ch);

      print('yaerList ::: ');
      //String year = "2024";

      print(year);
      var yearStocksList = [];
      await _firestore.collection("year").doc(year).collection('stocks').get().then((value) {
        for(var docSnapShot in value.docs){
            //print(docSnapShot.data());
            yearStocksList.add(docSnapShot.data());
        }
      });


      print(yearStocksList);



      print('userList :: ');
      //var userList = [];
      await _firestore.collection("users").get().then((value) {
        for(var docSnapShot in value.docs){
            print(docSnapShot.data()['uid']);
            //userList.add(docSnapShot.data()['uid']);
            String uid = docSnapShot.data()['uid'];
            print(uid+"의 주식 ::");
            _firestore.collection("users").doc(uid).collection('stocks').get().then((value) {
            for(var docSnapShot in value.docs){
               print(docSnapShot.data());

              String userStockName = docSnapShot.data()["name"];

              for(var yearStock in yearStocksList){
                print(yearStock);
                String name = yearStock["name"] as String;
                String pmoney = yearStock["pmoney"] as String;
                String smoney = yearStock["smoney"] as String;
                String title = yearStock["title"] as String;
                

                if(userStockName == name ){
                  
                  String  userStockQty = docSnapShot.data()["stock"];
                  print('name :: '+name);
                  print('userStockQty :: '+userStockQty);

                _firestore.collection("users").doc(uid).collection('stocks').doc(name).set({
                  "name" : name,
                  "pmoney" : pmoney,
                  "smoney" : smoney,
                  "stock": userStockQty,
                  "title" : title
                  });
                }
                

                
              }


              }
            });


        }
      });

      message = year+"년으로 주가 변경을 완료하였습니다.";

      //print(userList[0]['uid']);

      // var userStocksList = [];
      // for (var user in userList){
      //   
      // }

      // print(userStocksList);




     

    // for(var user in userList){

    // }
      
      //String ppmoney = '1000000000';
      // else{
      //   print('구매완료');
      //   message = '구매완료';

        // await _firestore.collection("users").doc(_fireauth.currentUser?.uid).collection('stocks').doc(sname).set({
        //   "name" : sname,
        //   "pmoney" : pmoney,
        //   "smoney" : smoney,
        //   "stock": buyStock.toString(),
        //   "title" : title
        // });

      //   await _firestore.collection("users").doc(_fireauth.currentUser?.uid).set({
      //     "money": money-buyStockMoney,
      //     "name" : widget.name,
      //     "uid" : _fireauth.currentUser?.uid
      //   });
       
      // }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.deepOrange,
          ),
        );

      Navigator.pop(context);



    }on Exception catch(e){
      print(e);
    }
  }


// 주식정보 생성 JSON
var stockList = [
  {
      "title": "A_전자",
      "smoney": '35000',
      "name": 'A_elec',
      "pmoney": '45000'
    },
    {
      "title": "B_자동차",
      "smoney": '90000',
      "name": 'B_car',
      "pmoney": '100000'
    },
    {
      "title": "C_바이오",
      "smoney": '10000',
      "name": 'C_bio',
      "pmoney": '20000'
    },
    {
      "title": "D_게임",
      "smoney": '15000',
      "name": 'D_game',
      "pmoney": '10000'
    },
    {
      "title": "E_IT",
      "smoney": '10000',
      "name": 'E_it',
      "pmoney": '30000'
    },
    {
      "title": "F_엔터",
      "smoney": '5000',
      "name": 'F_ent',
      "pmoney": '10000'
    },
    {
      "title": "G_화학",
      "smoney": '3000',
      "name": 'G_chem',
      "pmoney": '10000'
    },
    {
      "title": "H_반도체",
      "smoney": '1000',
      "name": 'H_bando',
      "pmoney": '50000'
    }
  ];

// 주식정보 생성
 Future _createStocks (year) async{
    
    print("주식 정보 변경");
    try{
      // print('money :: $money');
      print(_fireauth.currentUser?.uid);
      // print(widget.name);
      //print(name);


      String message = '';
      // String stock_ch = _stockBuySellController.text;
      // int buyStockMoney = int.parse(pmoney) * int.parse(stock_ch);
      // int buyStock = int.parse(stock)+int.parse(stock_ch);


      for(var idx = 0; idx < stockList.length; idx++){

          String year = "2023"; // 생성 주식 년도 기입
          String name = stockList[idx]["name"] as String;
          String pmoney = stockList[idx]["pmoney"] as String;
          String smoney = stockList[idx]["smoney"] as String;
          String title = stockList[idx]["title"] as String;

          await _firestore.collection("year").doc(year).collection('stocks').doc(name).set({
          "name" : name,
          "pmoney" : pmoney,
          "smoney" :smoney,
          "title" : title
        });

      }

    

      

      
      //String ppmoney = '1000000000';
      // else{
      //   print('구매완료');
      //   message = '구매완료';

      //   await _firestore.collection("users").doc(_fireauth.currentUser?.uid).collection('stocks').doc(sname).set({
      //     "name" : sname,
      //     "pmoney" : pmoney,
      //     "smoney" : smoney,
      //     "stock": buyStock.toString(),
      //     "title" : title
      //   });

      //   await _firestore.collection("users").doc(_fireauth.currentUser?.uid).set({
      //     "money": money-buyStockMoney,
      //     "name" : widget.name,
      //     "uid" : _fireauth.currentUser?.uid
      //   });
       
      // }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.deepOrange,
          ),
        );

      Navigator.pop(context);



    }on Exception catch(e){
      print(e);
    }
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


