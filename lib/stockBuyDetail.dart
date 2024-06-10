import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yungyung_stock_project/second.dart'; // 화면추가
import 'package:get/get.dart';
//import 'package:yungyung_stock_project/main.dart';
import 'package:yungyung_stock_project/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:yungyung_stock_project/model/users.dart';
import 'dart:convert';



class StockBuyDetailPage extends StatefulWidget {
  const StockBuyDetailPage({super.key, required this.name, required this.uid});

  final String name;
  final String uid;

  @override
  State<StockBuyDetailPage> createState() => _StockBuyDetailPageState();
}

class _StockBuyDetailPageState extends State<StockBuyDetailPage> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _fireauth = FirebaseAuth.instance;

  int money = 0; // 사용자 현금
  int stockMoney = 0; // 사용자 주식현금



 
  var koMoneyUnit = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
  var moneyUnit = NumberFormat('###,###,###,###');
  String totalMoney = '10,000';
  String afterMoney = '+10,000';

  var stockList = [];


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

  Map<String, dynamic> json = jsonDecode('{}');

  
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor:Colors.yellow,
        title: Center(child: Text("주식구매자-"+widget.name.toString(),style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
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
            // 총소지금액
            Flexible(
              flex: 2,
              child:  Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              color: Colors.white,
              margin: EdgeInsets.all(7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("총 소지금액"),
                  //Text("주식 : ${stockMoney.toString()}"),
                  //Text(koMoneyUnit.format(calTotalMoney()))

                  //  FutureBuilder(
                  //   future: _firestore.collection('users').doc(widget.uid).collection("stocks").get(), 
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
                  //         print('보유주식 현황 :: ');
                  //         print(snapshot.data);
                  //         print(snapshot.data);
                  //         //money = snapshot.data['money'];
                  //         String showMoney =  '';      

                  //         if (money > 0){ 
                  //           showMoney = '+'+money.toString();
                  //         }else{
                  //           showMoney = '-'+money.toString();
                  //         }

                  //         return Text("주식 : $showMoney");
                  //       }
                  //   }
                  // ),  
                  //

                  StreamBuilder(
                        //stream: _firestore.collection('stock').snapshots(),
                        stream: _firestore.collection('users').snapshots(),
                        builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;

                          print('docs :: ${docs}');

                          


                           // 사용자 현금가져오기
                           for(int i=0; i<docs.length;i++){
                              if(docs[i]['uid'] == widget.uid){
                                money = docs[i]['money'];
                              }
                           }

                          String showMoney =  '';      

                          if (money > 0){ 
                            showMoney = '+'+money.toString();
                          }else if(money == 0){
                            showMoney = money.toString();
                          }
                          else{
                            showMoney = '-'+money.toString();
                          }


                          

                          return Text("현금 : $showMoney");
                          
                        }
                      ),        

                  // FutureBuilder(
                  //   future: _firestore.collection('users').doc(widget.uid).get(), 
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
                  //         money = snapshot.data['money'];
                  //         String showMoney =  '';      

                  //         if (money > 0){ 
                  //           showMoney = '+'+money.toString();
                  //         }else{
                  //           showMoney = '-'+money.toString();
                  //         }

                  //         return Text("현금 : $showMoney");
                  //       }
                  //   }
                  // ),

                ],
              ),
            ),
            ),


            Flexible(
              flex: 8,
              child:     //주식보유현황
            Container(
              width: MediaQuery.of(context).size.width,
              height:  MediaQuery.of(context).size.height,
              color: Colors.white,
              margin: EdgeInsets.all(7),
              child: Column(
                children: [
                  const Text("보유 주식"),
                  Container(height: 1, color: Colors.black,margin: EdgeInsets.only(left: 10,right: 10,bottom: 10),),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height:  500,
                    // color: Colors.brown,
                    child:
                    StreamBuilder(
                        //stream: _firestore.collection('stock').snapshots(),
                        stream: _firestore.collection('users').doc(widget.uid).collection('stocks').snapshots(),
                        builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data!.docs;

                          print('docs :: ${docs}');


                           // 사용자 보유주식 넣기
                           for(int i=0; i<docs.length;i++){
                              stockList.add({
                                  "title":docs[i]['title'],
                                  "smoney":docs[i]['smoney'],
                                  "stock":docs[i]['stock'],
                                  "stock_ch":'0',
                                });
                           }
                       


                          

                          return 
                          ListView.builder( //part8 GridView builder

                            itemCount: docs.length,
                            itemBuilder: (BuildContext con, int index){
                               //_stockController.add(new TextEditingController());
                              return 
                            //   stockContainer(
                            //     title: docs[index]["title"] as String,
                            //     smoney: docs[index]["smoney"] as String,
                            //     stock:  docs[index]['stock'] as String,
                            //     index: index
                            // );
                             GestureDetector( // 제스처 기능 추가
                              onTap: (){
                                debugPrint(docs[index]["title"]);
                                showPopup(context, docs[index]["title"],docs[index]["name"], docs[index]["smoney"],docs[index]["pmoney"],docs[index]['stock']);
                              },
                              child:  stockContainer(
                                title: docs[index]["title"] as String,
                                pmoney: docs[index]["pmoney"] as String,
                                stock:  docs[index]['stock'] as String,
                              ),
                              );
                          });
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

  final List<TextEditingController> _stockController = [];

  Widget stockContainer({String title ='',String pmoney ='0',  String stock = '0', Color colorData = Colors.yellow, int index = 0}){ //주식리스트 Container
    return Container(
           width: MediaQuery.of(context).size.width,
           height: 100,
           margin: EdgeInsets.all(5),
           color: colorData,
           child: Container(
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(8), 
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                      child: Text(title),
                      )
                  ),

                  Flexible(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center, 
                      child: Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(alignment: Alignment.center,child: Text('현재금액'),),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(pmoney),
                          )
                        ],
                        )                   
                      )
                  ),

                  Flexible(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center, 
                      child: Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(alignment: Alignment.center,child: Text('보유주식'),),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(stock)
                          ),
                        ],
                        )                   
                      )
                  ), 

                  Flexible(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center, 
                      child: Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Container(alignment: Alignment.center,child: Text('합계'),),
                          ),
                          Flexible(
                            flex: 1,
                            child: Text(koMoneyUnit.format((int.parse(pmoney) * int.parse(stock))).toString()),
                          ),
                        ],
                        )                   
                      )
                  ), 

                          
                    // Flexible(
                    //         flex: 1,
                    //         child: Container(
                    //           alignment: Alignment.center, 
                    //           child: Column(
                    //             children: [
                    //               Flexible(
                    //                 flex: 1,
                    //                 child: Container(
                    //                   alignment: Alignment.center,
                    //                   child: 
                    //                   Text('구매/판매 주식수'),
                    //                   ),
                    //       ),
                    //       Flexible(
                    //         flex: 1,
                    //         child: 
                    //         //Text(stock),
                    //         TextField(
                    //            onChanged: (text) {
                    //             // 현재 텍스트필드의 텍스트를 출력
                    //             print("First text field: $text");
                    //           },
                    //           controller: _stockController[index],
                    //           textAlign: TextAlign.center,
                              
                    //           )
                    //       )
                    //             ],
                    //             )                   
                    //           )
                    //       ),

                ],
              )
           ),
          );
          // Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: 200,
          //   color: colorData,
          // ),
  }



commonDialog(message){
  showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                new Text("알림"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message,
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton(
                child: new Text("확인"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
}


final TextEditingController _stockBuySellController = TextEditingController(text: '0');

void showPopup(context, title, sname,smoney,pmoney,stock){ //구매/판매 팝업
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
                      child: Text(title),
                      ),
                ),
               

                const SizedBox(
                  height: 10,
                ),


                Flexible(
                  flex: 2,
                  child:  
                  Container(
                    alignment: Alignment.center,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                       Text("현재금액", 
                        style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                        ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8),
                        child: Text(
                          pmoney,
                          maxLines: 1, //최대 몇줄까지 표시하는지 지정
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[500]
                          ),
                          textAlign: TextAlign.center,
                        ),),
                    ],)
                    ),

                    Flexible(
                      flex: 2,
                      child: Column(
                        children: [
                          Text("보유주식", style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                            ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8),
                            child: Text(
                              stock,
                              maxLines: 1, //최대 몇줄까지 표시하는지 지정
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[500]
                              ),
                              textAlign: TextAlign.center,
                            ),),
                        ],)
                      ),
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              Text("구매/판매 주식수", 
                                style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey
                                ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _stockBuySellController,
                                  maxLines: 1, //최대 몇줄까지 표시하는지 지정
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[500]
                                  ),
                                  textAlign: TextAlign.center,
                                ),),
                            ],)
                        ),
                  ],
                ),
                  ),
                ),
               

                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //구매 버튼
                      ElevatedButton.icon(onPressed: () => _buyStocks(title,sname,smoney,pmoney,stock),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.blue,
                      ),
                      label: const Text('구매'),
                    ),
                    //판매 버튼
                    ElevatedButton.icon(
                      onPressed: ()  => _sellStocks(title,sname,smoney,pmoney,stock),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.red,
                      ),
                      label: const Text('판매'),
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


// 주식구매 
 Future _buyStocks (title,sname,smoney,pmoney,stock) async{
    
    print("주식구매");
    try{
      print('money :: $money');
      print(widget.uid);
      print(widget.name);
      print(sname);
      print(pmoney);
      print(smoney);
      print(stock);
      print(title);
      print(_stockBuySellController.text);

      String message = '';
      String stock_ch = _stockBuySellController.text;
      int buyStockMoney = int.parse(pmoney) * int.parse(stock_ch);
      int buyStock = int.parse(stock)+int.parse(stock_ch);
      
      //String ppmoney = '1000000000';
      if(int.parse(stock_ch) == 0){
        print('수량부족');
        message = '구매할 주식 수량을 입력해주세요.';
      }
      else if(money < buyStockMoney ){
        print('현금부족');
        print(money.toString());
        print(buyStockMoney);
        message = '현금이 부족하여 결제가 불가능합니다.';
        
      }else{
        print('구매완료');
        message = '구매완료';

        await _firestore.collection("users").doc(widget.uid).collection('stocks').doc(sname).set({
          "name" : sname,
          "pmoney" : pmoney,
          "smoney" : smoney,
          "stock": buyStock.toString(),
          "title" : title
        });

        await _firestore.collection("users").doc(widget.uid).set({
          "money": money-buyStockMoney,
          "name" : widget.name,
          "uid" : widget.uid
        });
       
      }

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


  // 주식판매 
  Future _sellStocks (title,sname,smoney,pmoney,stock) async{
    
    print("주식판매");
    try{
      print('money :: $money');
      print(widget.uid);
      print(widget.name);
      print(sname);
      print(pmoney);
      print(smoney);
      print(stock);
      print(title);
      

      String message = '';
      String stock_ch = _stockBuySellController.text;
      int sellStockMoney = int.parse(pmoney) * int.parse(stock_ch);
      int sellStock = int.parse(stock)-int.parse(stock_ch);

      print(stock_ch);
      print(stock_ch);
      print(sellStockMoney.toString());
      print(sellStock.toString());
      
      //String ppmoney = '1000000000';
      if(int.parse(stock_ch) == 0){
        print('수량부족');
        message = '판매할 주식 수량을 입력해주세요.';
      }
      else if(int.parse(stock) < int.parse(stock_ch) ){
        print('주식부족');
        print(money.toString());
        print(int.parse(stock_ch));
        message = '판매할 주식 갯수가 부족하여 결제가 불가능합니다.';
        
      }
      else{
        print('판매완료');
        message = '판매완료';

        await _firestore.collection("users").doc(widget.uid).collection('stocks').doc(sname).set({
          "name" : sname,
          "pmoney" : pmoney,
          "smoney" : smoney,
          "stock": sellStock.toString(),
          "title" : title
        });

        await _firestore.collection("users").doc(widget.uid).set({
          "money": money+sellStockMoney,
          "name" : widget.name,
          "uid" : widget.uid
        });
       
      }

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


