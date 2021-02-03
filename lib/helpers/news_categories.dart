import 'package:ybb/models/news_category_model.dart';

List<NewsCategoryModel> getNewsCategories() {
  List<NewsCategoryModel> newsCategories = new List<NewsCategoryModel>();
  NewsCategoryModel newsCategoryModel = new NewsCategoryModel();

  //1
  newsCategoryModel.categoryName = "Degree";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  newsCategoryModel = new NewsCategoryModel();
//2
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Announcement";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //3
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Internship";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //4
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Fellowship";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //5
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Experience";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //6
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Registration";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

//7
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "News";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  //8
  newsCategoryModel = new NewsCategoryModel();
  newsCategoryModel.categoryName = "Uncategorized";
  newsCategoryModel.categroyImageUrl =
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80";
  newsCategories.add(newsCategoryModel);

  return newsCategories;
}
