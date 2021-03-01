import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/timeline.dart';
import 'package:ybb/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  List<String> followingList;

  bool isAllUsersFollowed = true;

  @override
  void initState() {
    super.initState();

    followingList = idFollowing;
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("displayName", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      searchResultsFuture = null;
    });
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream:
          usersRef.orderBy('timestamp', descending: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<UserToFollow> userToFollow = [];
        snapshot.data.documents.forEach(
          (doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);
            // remove auth user from recommended list
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserToFollow userResult = UserToFollow(user);
              userToFollow.add(userResult);

              if (userToFollow.length > 0) {
                isAllUsersFollowed = false;
              } else {
                isAllUsersFollowed = true;
              }
            }
          },
        );

        return Column(
          children: [
            userToFollow.length > 0
                ? Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.person_add,
                          color: Theme.of(context).primaryColor,
                          size: 25,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          "People to follow",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18.0,
                            fontFamily: fontName,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(''),
            Row(children: userToFollow),
          ],
        );
      },
    );
  }

  AppBar buildSearchField() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.blue,
      title: Container(
        height: MediaQuery.of(context).size.height * 0.045,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Colors.grey[200]),
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
            hintText: "Search",
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            ),
          ),
          onFieldSubmitted: handleSearch,
        ),
      ),
    );
  }

  Container buildNoContent() {
    return Container(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: buildUsersToFollow(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          SvgPicture.asset(
            'assets/images/no_search.svg',
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          SizedBox(height: 10),
          Text(
            "Find people to broaden your network.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontFamily: fontName,
            ),
          ),
        ],
      ),
    );
  }

  buildNoSearchResult() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_search_result.svg',
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              "Oops! We can't find anything on that keyword. Try something else.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });

        return searchResults.length == 0
            ? buildNoSearchResult()
            : Column(
                children: searchResults,
              );
      },
    );
  }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<Null> refreshSearch() async {
    refreshKey.currentState?.show(atTop: true);

    await getFollowing();

    await searchResultsFuture == null ? buildNoContent() : buildSearchResults();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: buildSearchField(),
      resizeToAvoidBottomPadding: false,
      body: RefreshIndicator(
        onRefresh: refreshSearch,
        key: refreshKey,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: AlwaysScrollableScrollPhysics(),
          child: searchResultsFuture == null
              ? buildNoContent()
              : buildSearchResults(),
        ),
      ),
    );
  }
}

class UserToFollow extends StatelessWidget {
  final User user;

  UserToFollow(this.user);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showProfile(context, profileId: user.id),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.21,
        width: MediaQuery.of(context).size.width * 0.35,
        margin: EdgeInsets.only(right: 5, left: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.1,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  user.displayName.length > 13
                      ? user.displayName.substring(0, 13) + "..."
                      : user.displayName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontName,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                Text(
                  user.occupation.length > 30
                      ? user.occupation.substring(0, 30) + "..."
                      : user.occupation,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: fontName,
                  ),
                ),
              ],
            ),
            //buildButton(),
          ],
        ),
      ),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontName,
                ),
              ),
              subtitle: Text(
                "@" + user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: fontName,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
