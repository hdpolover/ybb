import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/news_categories.dart';
import 'package:ybb/helpers/news_data.dart';
import 'package:ybb/pages/news_category.dart';
import 'package:ybb/pages/news_detail.dart';
import 'package:ybb/pages/timeline.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/models/news_category.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/widgets/shimmers/news_category_shimmer_layout.dart';

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> with AutomaticKeepAliveClientMixin<News> {
  List<NewsCategoryModel> newsCategories = [];
  List<ArticleModel> articles = [];
  var refreshkey = GlobalKey<RefreshIndicatorState>();

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    newsCategories = getNewsCategories();
    getNews();
  }

  getNews() async {
    try {
      articles = newsFromTimeline;
    } catch (e) {
      print("empty");
    }

    if (articles == null || articles.isEmpty) {
      NewsData newsData = new NewsData();

      articles = [];

      await newsData.getArticles();

      articles = newsData.articles;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Null> getNewsAgain() async {
    refreshkey.currentState?.show(atTop: true);
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
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        key: refreshkey,
        onRefresh: getNewsAgain,
        child: ConnectivityScreenWrapper(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  //categories
                  Container(
                    padding: EdgeInsets.only(top: 5.0, left: 5.0),
                    height: MediaQuery.of(context).size.height * 0.07,
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
                  _loading
                      ? NewsCategoryShimmer()
                      : Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              return ArticleTile(
                                newsCategory: convertNewsCategory(
                                    articles[index].category),
                                newsImageUrl: articles[index].imageUrl,
                                newsTitle: articles[index].title,
                                newsDesc: articles[index].desc,
                                newsUrl: articles[index].url,
                                newsContent: articles[index].content,
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
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.06,
                fit: BoxFit.cover,
                imageUrl: categoryImageUrl,
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: Colors.black45,
              ),
              child: Text(
                categoryName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  fontFamily: "OpenSans",
                  letterSpacing: 1,
                ),
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
      newsContent,
      newsUrl,
      newsDate,
      newsCategory;

  ArticleTile(
      {@required this.newsImageUrl,
      @required this.newsTitle,
      @required this.newsDesc,
      @required this.newsUrl,
      @required this.newsContent,
      @required this.newsDate,
      @required this.newsCategory});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetail(
              title: newsTitle,
              url: newsUrl,
              date: newsDate,
              category: newsCategory,
              content: newsContent,
              imageUrl: newsImageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: newsImageUrl,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.all(5),
              child: Text(
                newsTitle.trim(),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        convertDateTime(DateTime.parse(newsDate)).toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "OpenSans",
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.folder_open_outlined,
                        color: Colors.black,
                        size: 22,
                      ),
                      SizedBox(width: 5),
                      Text(
                        newsCategory,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "OpenSans",
                        ),
                      )
                    ],
                  ),
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
                  fontFamily: 'OpenSans',
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
