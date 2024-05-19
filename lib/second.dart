import 'package:flutter/material.dart';

class SecondView extends StatefulWidget {
  const SecondView({super.key});

  @override
  State<SecondView> createState() => _SecondViewState();
}

class _SecondViewState extends State<SecondView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( // 상단 타이틀
        title: const Text("TEST App"),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
            child: Container(child: const Text("This is the second view"), padding: const EdgeInsets.all(15), color: Colors.blue, ),
          ),
      ),
    );
  }
}