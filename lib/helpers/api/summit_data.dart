import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ybb/helpers/api/summit_models/summit.dart';

class SummitData {
  static Future<List<Summit>> getSummits() async {
    String url = "http://192.168.1.9/ybbadminweb/api/summit";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> summitList = (jsonData as Map<String, dynamic>)['data'];

      List<Summit> summits = [];
      for (int i = 0; i < summitList.length; i++) {
        summits.add(Summit.fromJSON(summitList[i]));
      }

      return summits;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  registerParticipant() {}

  loginParticipant() {}

  // getParticipantDetail() async {
  //   String url =
  //       "https://youthbreaktheboundaries.com/wp-json/wp/v2/posts?_embed";

  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     var jsonData = jsonDecode(response.body);

  //     jsonData.forEach((element) {
  //       participant = SummitParticipant(
  //           // title: element['title']['rendered'],
  //           // desc: parse((element['excerpt']['rendered']).toString())
  //           //     .documentElement
  //           //     .text,
  //           // content: parse((element['content']['rendered']).toString())
  //           //     .documentElement
  //           //     .text,
  //           // date: element['date'],
  //           // url: element['link'],
  //           // imageUrl: element['_embedded']['wp:featuredmedia'] == null
  //           //     ? "https://i.postimg.cc/SK25RYGY/placeholder-ybb-news.jpg"
  //           //     : element['_embedded']['wp:featuredmedia'][0]['source_url'],
  //           // category: element['categories'][0]
  //           //"https://youthbreaktheboundaries.com/wp-content/uploads/2021/02/Salinan-dari-Copy-of-Scholarship-at-Columbia-University-by-The-Obama-Foundation-2021-02-01T082915.403.png",
  //           );
  //     });
  //   } else {
  //     throw Exception('Unexpected error occured!');
  //   }
  // }
}
