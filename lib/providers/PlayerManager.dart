import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class PlayerManager with ChangeNotifier {
  Future<List<String>> getRandomPlayer() async {
    // Getting the response from the targeted url
    Random rnd = Random();
    var playerRandNumb = rnd.nextInt(24);
    var pageRandNumb = 1 + rnd.nextInt(9);
    var playerTeamImage = "";
    var playerImage = "";

    final response = await http.Client().get(Uri.parse(
        'https://www.transfermarkt.co.uk/spieler-statistik/wertvollstespieler/marktwertetop?page=' +
            pageRandNumb.toString()));
    print(response.statusCode);
    // Status Code 200 means response has been received successfully
    if (response.statusCode == 200) {
      // Getting the html document from the response
      var document = parser.parse(response.body);
      try {
        var table = document
            .getElementsByClassName('items')[0]
            .children[1]; // thead or tbody (we want tbody so 1)

        var player =
            table.children[playerRandNumb]; //player index (row selector)
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

        var newLink = await http.Client()
            .get(Uri.parse('https://www.transfermarkt.co.uk' + playerLink));
        if (newLink.statusCode == 200) {
          var newDocument = parser.parse(newLink.body);
          print(
              newDocument.getElementsByClassName("modal-trigger")[0].innerHtml);
          try {
            var playerTeamImage = newDocument
                .getElementsByClassName("dataZusatzImage")[0]
                .children[0]
                .innerHtml
                .split('"')[1]
                .split(',')[0]
                .trim()
                .split(' ')[0];
            var playerImage = newDocument
                .getElementsByClassName("modal-trigger")[0]
                .innerHtml
                .trim()
                .split('"')[5];
          } catch (e) {
            return ['', '', 'ERROR!'];
          }
        }
        print(playerImage);
        return [
          playerName,
          playerPosition,
          playerTeamImage,
          playerImage,
          playerValue,
          playerValueNumb,
          pageRandNumb.toString(),
        ];
      } catch (e) {
        return ['', '', 'ERROR!'];
      }
    } else {
      return ['', '', 'ERROR: ${response.statusCode}.'];
    }
  }

  Future<List<String>> getSecondPlayer(
      int otherPlayerPage, double otherPlayerValue) async {
    // Getting the response from the targeted url
    Random rnd = Random();
    var playerRandNumb = rnd.nextInt(24);

    int min = otherPlayerPage - 1;
    int max = otherPlayerPage + 1;

    var pageRandNumb = min + rnd.nextInt(max - min);

    final response = await http.Client().get(Uri.parse(
        'https://www.transfermarkt.co.uk/spieler-statistik/wertvollstespieler/marktwertetop?page=' +
            pageRandNumb.toString()));

    // Status Code 200 means response has been received successfully
    if (response.statusCode == 200) {
      // Getting the html document from the response
      var document = parser.parse(response.body);
      try {
        var table = document
            .getElementsByClassName('items')[0]
            .children[1]; // thead or tbody (we want tbody so 1)
        var player =
            table.children[playerRandNumb]; //player index (row selector)
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
            double.parse(playerValue.replaceAll("£", "").replaceAll("m", ""));
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
        var playerImage = newDocument
            .getElementsByClassName("modal-trigger")[0]
            .innerHtml
            .trim()
            .split('"')[5];

        if (otherPlayerValue == playerValueNumb) {
          return getSecondPlayer(otherPlayerPage, otherPlayerValue);
        }

        print(playerName);
        print(playerValue);
        print(pageRandNumb);
        return [
          playerName,
          playerPosition,
          playerTeamImage,
          playerImage,
          playerValue,
          playerValueNumb.toString(),
          pageRandNumb.toString()
        ];
      } catch (e) {
        return [];
      }
    } else {
      return ['ERROR: ${response.statusCode}.'];
    }
  }
}
