import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
    theme: ThemeData(
      accentColor: Colors.green,
      scaffoldBackgroundColor: Colors.green[100],
      primaryColor: Colors.green,
    ),
    home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Strings to store the extracted Article titles
  String result1 = 'Result 1';
  String result2 = 'Result 2';
  String result3 = 'Result 3';

  // boolean to show CircularProgressIndication
  // while Web Scraping awaits
  bool isLoading = false;

  Future<List<String>> extractData() async {
    // Getting the response from the targeted url
    final response = await http.Client().get(Uri.parse(
        'https://www.transfermarkt.co.uk/spieler-statistik/wertvollstespieler/marktwertetop?page=' +
            '1'));

    // Status Code 200 means response has been received successfully
    if (response.statusCode == 200) {
      // Getting the html document from the response
      var document = parser.parse(response.body);
      try {
        // Scraping the first article title
        var table = document
            .getElementsByClassName('items')[0]
            .children[1]; // thead or tbody (we want tbody so 1)
        var player = table.children[0]; //player index (row selector)
        var playerDetails = player
            .children[1]
            // index number is 0 we want 1 for player details
            .children[0] // td container
            .children[0]; // inline table
        var playerName = playerDetails
            .children[0] // tbody child
            .children[1] // first child is the image second is the name
            .children[0] // inside the td there is a link for the player's name
            .innerHtml;
        var playerPosition = playerDetails.children[1].children[0].innerHtml;
        print(playerName);
        print(playerPosition);

        // var responseString1 = document.getElementsByClassName('hauptlink')[51];
        // print(responseString1.text.trim());

        // var responseString2 = document.getElementsByClassName('zentriert')[4];
        // print(responseString2.text.trim());

        // document
        //     .getElementsByClassName('articles-list')[0]
        //     .children[0]
        //     .children[0]
        //     .children[0];

        // print(responseString1.text.trim());

        // // Scraping the second article title
        // var responseString2 = document
        //     .getElementsByClassName('articles-list')[0]
        //     .children[1]
        //     .children[0]
        //     .children[0];

        // print(responseString2.text.trim());

        // // Scraping the third article title
        // var responseString3 = document
        //     .getElementsByClassName('articles-list')[0]
        //     .children[2]
        //     .children[0]
        //     .children[0];

        // print(responseString3.text.trim());

        // // Converting the extracted titles into
        // // string and returning a list of Strings
        return [
          // responseString1.text.trim(),
          // responseString2.text.trim(),
          // responseString3.text.trim()
        ];
      } catch (e) {
        return ['', '', 'ERROR!'];
      }
    } else {
      return ['', '', 'ERROR: ${response.statusCode}.'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeeksForGeeks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if isLoading is true show loader
            // else show Column of Texts
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Text(result1,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Text(result2,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Text(result3,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            MaterialButton(
              onPressed: () async {
                // Setting isLoading true to show the loader
                setState(() {
                  isLoading = true;
                });

                // Awaiting for web scraping function
                // to return list of strings
                final response = await extractData();

                // Setting the received strings to be
                // displayed and making isLoading false
                // to hide the loader
                setState(() {
                  // result1 = response[0];
                  // result2 = response[1];
                  // result3 = response[2];
                  isLoading = false;
                });
              },
              child: const Text(
                'Scrap Data',
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
