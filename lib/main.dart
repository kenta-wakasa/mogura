import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mogura/secret.dart';

const dynamicLinksUri =
    'https://firebasedynamiclinks.googleapis.com/v1/shortLinks';

Future<String> _buildDynamicUrl(
  Uri imageUrl,
  int score,
) async {
  final response = await post(
    Uri.parse(dynamicLinksUri)
        .replace(queryParameters: {'key': firebaseAPIKey}),
    body: jsonEncode({
      "dynamicLinkInfo": {
        "domainUriPrefix": "https://mogura.page.link",
        "navigationInfo": {
          "enableForcedRedirect": true,
        },
        "link": "https://mogura-tataki.web.app/",
        "socialMetaTagInfo": {
          "socialTitle": '光ったところを叩け',
          "socialDescription": 'わたしのスコアは $score 回でした。あなたはどうする？',
          "socialImageLink": imageUrl.toString(),
        }
      }
    }),
  );
  dev.log(response.body);
  return (jsonDecode(response.body) as Map<String, dynamic>)['shortLink'];
}

var url = '';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'モグラズ',
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
  static const playTime = 10;
  static const sideLength = 5;
  static const cellLength = 80.0;

  int count = 0;

  int timeLeft = playTime;

  List<bool> moguras = List.generate(
    sideLength * sideLength,
    (index) => false,
  );

  void mainLoop() async {
    count = 0;
    timeLeft = playTime;
    while (timeLeft > 0) {
      moguras = List.generate(
        sideLength * sideLength,
        (index) => Random().nextBool(),
      );
      timeLeft--;
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
    }
    moguras = List.generate(
      sideLength * sideLength,
      (index) => false,
    );
    url = await _buildDynamicUrl(
      Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/mogura-tataki.appspot.com/o/sns.png?alt=media&token=bc6a6224-d07e-4072-8451-8788cf1541a8'),
      count,
    );
    timeLeft = playTime;
    setState(() {});
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       content: Column(
    //         children: const [],
    //       ),
    //     );
    //   },
    // );
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
            const SizedBox(
              height: 40,
            ),
            for (var y = 0; y < sideLength; y++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var x = 0; x < sideLength; x++)
                    InkWell(
                      onTap: () {
                        if (moguras[x + (y * sideLength)]) {
                          moguras[x + (y * sideLength)] = false;
                          count++;
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: cellLength,
                        height: cellLength,
                        alignment: Alignment.center,
                        color: moguras[x + (y * sideLength)]
                            ? Colors.red
                            : Colors.grey,
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
              onPressed: timeLeft == playTime ? mainLoop : null,
              child: const Text('スタート！'),
            ),
            const SizedBox(height: 40),
            if (url.isNotEmpty)
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('コピーしました')),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('結果をシェアする'),
                    Icon(Icons.copy),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
