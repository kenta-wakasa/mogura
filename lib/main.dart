import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MoguraPage(),
    );
  }
}

class MoguraPage extends StatefulWidget {
  const MoguraPage({super.key});

  @override
  State<MoguraPage> createState() => _MoguraPageState();
}

class _MoguraPageState extends State<MoguraPage> {
  List<bool> moguras = List.generate(
    9,
    (index) => false,
  );

  int count = 0;

  int playTime = 10;

  void mainLoop() async {
    count = 0;
    playTime = 10;
    while (playTime > 0) {
      moguras = List.generate(
        9,
        (index) => Random().nextBool(),
      );
      playTime--;
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
    }
    moguras = List.generate(
      9,
      (index) => false,
    );
    playTime = 10;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モグラ叩き'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var y = 0; y <= 2; y++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var x = 0; x <= 2; x++)
                    InkWell(
                      onTap: () {
                        if (moguras[x + (y * 3)]) {
                          moguras[x + (y * 3)] = false;
                          count++;
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        color: moguras[x + (y * 3)] ? Colors.red : Colors.grey,
                        // child: Text('${x + (y * 3)}'),
                      ),
                    ),
                ],
              ),
            Text(
              '叩いた回数 $count',
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
            ElevatedButton(
              onPressed: playTime == 10 ? mainLoop : null,
              child: const Text('スタート！'),
            ),
          ],
        ),
      ),
    );
  }
}
