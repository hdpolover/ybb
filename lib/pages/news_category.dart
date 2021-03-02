import 'package:flutter/material.dart';
import 'package:ybb/helpers/news_categories.dart';
import 'package:ybb/models/article.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/news_category_shimmer_layout.dart';

import 'news.dart';

class NewsCategory extends StatefulWidget {
  final String categoryName;
  final int categoryIndex;

  NewsCategory({this.categoryName, this.categoryIndex});

  @override
  _NewsCategoryState createState() => _NewsCategoryState();
}

class _NewsCategoryState extends State<NewsCategory>
    with AutomaticKeepAliveClientMixin<NewsCategory> {
  List<ArticleModel> articles = new List<ArticleModel>();
  var refreshkey = GlobalKey<RefreshIndicatorState>();

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    getNews();
  }

  getNews() async {
    NewsCategoriesData newsCategoriesData = new NewsCategoriesData();
    await newsCategoriesData.getArticles(widget.categoryIndex);

    articles = newsCategoriesData.articles;

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Null> refresh() async {
    refreshkey.currentState?.show(atTop: true);

    NewsCategoriesData newsCategoriesData = new NewsCategoriesData();

    articles = [];

    await newsCategoriesData.getArticles(widget.categoryIndex);
    articles = newsCategoriesData.articles;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: defaultAppBar(context, titleText: widget.categoryName),
      body: RefreshIndicator(
        key: refreshkey,
        onRefresh: refresh,
        child: SingleChildScrollView(
          child: _loading
              ? NewsCategoryShimmer()
              : Padding(
                  padding: EdgeInsets.all(15),
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
                        newsContent: articles[index].content,
                        newsDate: articles[index].date,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
