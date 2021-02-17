import 'dart:convert';

import 'package:ybb/models/article_model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

Future<List> fetchWpPosts() async {
  final response = await http.get(
      "https://youthbreaktheboundaries.com/wp-json/wp/v2/posts?_embed",
      headers: {"Accept": "application/json"});

  var convertDatatoJson = jsonDecode(response.body);

  return convertDatatoJson;
}

class NewsData {
  List<ArticleModel> articles = [];

  Future<void> getArticles() async {
    String url =
        "https://youthbreaktheboundaries.com/wp-json/wp/v2/posts?_embed";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      jsonData.forEach((element) {
        ArticleModel articleModel = ArticleModel(
            title: element['title']['rendered'],
            desc: parse((element['excerpt']['rendered']).toString())
                .documentElement
                .text,
            content: parse((element['content']['rendered']).toString())
                .documentElement
                .text,
            date: element['date'],
            url: element['link'],
            imageUrl: element['_embedded']['wp:featuredmedia'] == null
                ? "https://jooinn.com/images/sky-view-8.jpg"
                : element['_embedded']['wp:featuredmedia'][0]['source_url']
            //"https://youthbreaktheboundaries.com/wp-content/uploads/2021/02/Salinan-dari-Copy-of-Scholarship-at-Columbia-University-by-The-Obama-Foundation-2021-02-01T082915.403.png",
            );

        articles.add(articleModel);
      });
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  getFeaturedMedia() async {
    dynamic link;

    String url =
        "https://youthbreaktheboundaries.com/wp-json/wp/v2/posts?_embed";

    final response = await http.get(url);

    var jsonData = jsonDecode(response.body);

    jsonData.forEach((element) {
      link = element['_embedded']['wp:featuredmedia'][0]['source_url'];
      print("1234//" + link);
    });
  }
}
