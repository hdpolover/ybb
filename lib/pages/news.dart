import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ybb/helpers/news_categories.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/main.dart';
import 'package:ybb/pages/news_category.dart';
import 'package:ybb/pages/news_detail.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/models/news_category.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/widgets/progress.dart';

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> with AutomaticKeepAliveClientMixin<News> {
  List<NewsCategoryModel> newsCategories = new List<NewsCategoryModel>();
  List<ArticleModel> articles = new List<ArticleModel>();

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    newsCategories = getNewsCategories();
    getNews();
  }

  getNews() async {
    articles = articlesFromMain;

    if (articles == null || articles.isEmpty) {
      getNewsAgain();
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Null> getNewsAgain() async {
    NewsData newsData = new NewsData();

    articles = [];

    await newsData.getArticles();
    articles = newsData.articles;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: defaultAppBar(context, titleText: "News", removeBackButton: true),
      body: RefreshIndicator(
        onRefresh: getNewsAgain,
        child: SingleChildScrollView(
          child: _loading
              ? circularProgress()
              : Container(
                  child: Column(
                    children: <Widget>[
                      //categories
                      Container(
                        padding: EdgeInsets.only(top: 5.0, left: 5.0),
                        height: 55.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: newsCategories.length,
                          itemBuilder: (context, index) {
                            return CategoryTile(
                              categoryName: newsCategories[index].categoryName,
                              categoryImageUrl:
                                  newsCategories[index].categroyImageUrl,
                              categoryIndex: newsCategories[index].categoryId,
                            );
                          },
                        ),
                      ),
                      //articles
                      Container(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            return ArticleTile(
                              newsCategory:
                                  convertNewsCategory(articles[index].category),
                              newsImageUrl: articles[index].imageUrl,
                              newsTitle: articles[index].title,
                              newsDesc: articles[index].desc,
                              newsUrl: articles[index].url,
                              newsDate: articles[index].date,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

String convertNewsCategory(int index) {
  switch (index) {
    case 1:
      return "Uncategorized";
      break;
    case 4:
      return "News";
      break;
    case 5:
      return "Degree";
      break;
    case 6:
      return "Internship";
      break;
    case 7:
      return "Fellowship";
      break;
    case 8:
      return "Experience";
      break;
    case 9:
      return "Registration";
      break;
    case 10:
      return "Announcement";
      break;
    default:
      return "Uncategorized";
      break;
  }
}

class CategoryTile extends StatelessWidget {
  final categoryName, categoryImageUrl;
  final categoryIndex;

  CategoryTile({this.categoryName, this.categoryImageUrl, this.categoryIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsCategory(
            categoryName: categoryName,
            categoryIndex: categoryIndex,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(right: 8.0),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: CachedNetworkImage(
                width: 120.0,
                height: 60.0,
                fit: BoxFit.cover,
                imageUrl: categoryImageUrl,
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 60.0,
              width: 120.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.black26,
              ),
              child: Text(
                categoryName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String convertDateTime(DateTime postedDate) {
  return DateFormat.yMMMd().format(postedDate);
}

class ArticleTile extends StatelessWidget {
  final String newsImageUrl,
      newsTitle,
      newsDesc,
      newsUrl,
      newsDate,
      newsCategory;

  ArticleTile(
      {@required this.newsImageUrl,
      @required this.newsTitle,
      @required this.newsDesc,
      @required this.newsUrl,
      @required this.newsDate,
      @required this.newsCategory});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetail(url: newsUrl),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: newsImageUrl,
              width: MediaQuery.of(context).size.width,
              height: 180.0,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.all(5),
              child: Text(
                newsTitle.trim(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 10),
                ActionChip(
                  avatar: Icon(Icons.calendar_today_rounded),
                  label: Text(
                      convertDateTime(DateTime.parse(newsDate)).toString()),
                  onPressed: () {},
                ),
                SizedBox(width: 10),
                InputChip(
                  avatar: Icon(Icons.folder_open),
                  label: Text(newsCategory),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                newsDesc,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
