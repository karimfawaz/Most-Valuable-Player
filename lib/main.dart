import 'package:flutter/material.dart';

import 'package:mvp/providers/PlayerManager.dart';
import 'package:provider/provider.dart';

void main() => runApp(MVP());

class MVP extends StatelessWidget {
  const MVP({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerManager>(create: (_) => PlayerManager()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.green[100],
          primaryColor: Colors.green,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
        ),
        home: const MyApp(),
        // routes: {
        //   // ContactUsScreen.routeName: (ctx) => ContactUsScreen(),
        //   // onTap: () {
        //   //               Navigator.of(context)
        //   //                   .pushNamed(AppointmentScreen.routeName);
        // }
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Strings to store the extracted Article titles
  String result1 =
      'https://www.axelspringer.com/data/uploads/2019/04/transfermarkt.jpg';
  String result2 =
      'https://www.axelspringer.com/data/uploads/2019/04/transfermarkt.jpg';
  String result3 = 'Result 3';

  // boolean to show CircularProgressIndication
  // while Web Scraping awaits
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var playerData = Provider.of<PlayerManager>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Most Valuable Player')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Image.network(result1),
                      Image.network(result2),
                      Text(
                        result3,
                      ),
                    ],
                  ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            MaterialButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                playerData.getRandomPlayer();
                // print(response[6]);
                // final secondPlayer = await playerData.getSecondPlayer(
                //     int.parse(response[6]), double.parse(response[5]));

                setState(() {
                  // result1 = response[2];
                  // result2 = response[3];
                  // result3 = response[5];
                  isLoading = false;
                });
              },
              child: const Text(
                'Scrape Data',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.green,
            )
          ],
        )),
      ),
    );
  }
}
