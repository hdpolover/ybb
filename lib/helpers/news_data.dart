import 'dart:convert';

import 'package:ybb/models/article_model.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class NewsData {
  List<ArticleModel> articles = [];
  List<String> articleImageLinks = [];

  Future<void> getArticles() async {
    String url = "https://youthbreaktheboundaries.com/wp-json/wp/v2/posts";

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
          featuredMedia: element['featured_media'].toString(),
          imageUrl:
              "https://youthbreaktheboundaries.com/wp-content/uploads/2021/02/Salinan-dari-Copy-of-Scholarship-at-Columbia-University-by-The-Obama-Foundation-2021-02-01T082915.403.png",
        );

        articles.add(articleModel);
      });
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  Future<void> getFeaturedMedia() async {
    articles.forEach((element) async {
      String fm = element.featuredMedia;

      String url =
          "https://youthbreaktheboundaries.com/wp-json/wp/v2/media?parent=$fm";
      print(url);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        jsonData.forEach((element) {
          articleImageLinks.add(element['title']['rendered']);
          print(element['title']['rendered']);
        });
      } else {
        throw Exception('Unexpected error occured!');
      }
    });
  }
}
