import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.green[100],
      primaryColor: Colors.green,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
    ),
    home: const MyApp()));

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
        var playerValue = player.children[5].children[0].innerHtml;
        var playerValueNumb =
            playerValue.replaceAll("£", "").replaceAll("m", "");
        var playerLink = playerDetails
            .children[0] // tbody child
            .children[1] // first child is the image second is the name
            .innerHtml
            .split(
                '"')[3]; // inside the td there is a link for the player's name
        // print(playerValue);
        // print(playerValueNumb);
        var newLink = await http.Client()
            .get(Uri.parse('https://www.transfermarkt.co.uk' + playerLink));

        var newDocument = parser.parse(newLink.body);

        var playerTeamImage = newDocument
            .getElementsByClassName("dataZusatzImage")[0]
            .children[0]
            .innerHtml
            .split('"')[1]
            .split(',')[0]
            .trim()
            .split(' ')[0];
        var playerImage =
            newDocument.getElementsByClassName("modal-trigger")[0].innerHtml;

        print(playerImage);
        // print(playerTeamImage);

        // print(playerName);
        // print(playerPosition);
        // print(playerLink);
        // var responseString1 = docu
        // // Converting the extracted titles into
        // // string and returning a list of Strings
        return [playerName, playerPosition, playerTeamImage];
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
                    children: [Image.network(result1)],
                  ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            MaterialButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                final response = await extractData();

                setState(() {
                  result1 = response[2];
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
