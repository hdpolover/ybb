import 'dart:convert';

import 'package:html/parser.dart';
import 'package:ybb/models/article_model.dart';
import 'package:ybb/models/news_category_model.dart';
import 'package:http/http.dart' as http;

List<NewsCategoryModel> getNewsCategories() {
  List<NewsCategoryModel> newsCategories = new List<NewsCategoryModel>();
  NewsCategoryModel newsCategoryModel = new NewsCategoryModel();

  //1
  newsCategoryModel.categoryName = "Degree";
  newsCategoryModel.categoryId = 5;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  newsCategoryModel = new NewsCategoryModel();
//2
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Announcement";
  newsCategoryModel.categoryId = 10;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1601139144817-358064498084?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=752&q=80";
  newsCategories.add(newsCategoryModel);

  //3
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Internship";
  newsCategoryModel.categoryId = 6;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1606857521015-7f9fcf423740?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //4
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Fellowship";
  newsCategoryModel.categoryId = 7;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1507046393468-05089f3c03e0?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=753&q=80";
  newsCategories.add(newsCategoryModel);

  //5
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Experience";
  newsCategoryModel.categoryId = 8;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1587391987520-ae6ec108680d?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80";
  newsCategories.add(newsCategoryModel);

  //6
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Registration";
  newsCategoryModel.categoryId = 9;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523154410-31a6b052652b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=401&q=80";
  newsCategories.add(newsCategoryModel);

//7
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "News";
  newsCategoryModel.categoryId = 4;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1585829365295-ab7cd400c167?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //8
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Uncategorized";
  newsCategoryModel.categoryId = 1;
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1457369804613-52c61a468e7d?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  return newsCategories;
}

class NewsCategoriesData {
  List<ArticleModel> articles = [];

  Future<void> getArticles(int cat) async {
    String url =
        "https://youthbreaktheboundaries.com/wp-json/wp/v2/posts?_embed&categories=$cat";

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
                : element['_embedded']['wp:featuredmedia'][0]['source_url'],
            category: element['categories'][0]
            //"https://youthbreaktheboundaries.com/wp-content/uploads/2021/02/Salinan-dari-Copy-of-Scholarship-at-Columbia-University-by-The-Obama-Foundation-2021-02-01T082915.403.png",
            );

        articles.add(articleModel);
      });
    } else {
      throw Exception('Unexpected error occured!');
    }
  }
}
