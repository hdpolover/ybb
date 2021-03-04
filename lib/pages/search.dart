import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/activity_feed.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/people_suggestion.dart';
import 'package:ybb/pages/timeline.dart';
import 'package:ybb/widgets/shimmers/user_suggestion_shimmer_layout.dart';

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
  bool isSearchTapped = false;

  FocusNode focusNode;

  var queryResultSet = [];
  var tempSearchStore = [];

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    followingList = idFollowing;
  }

  @override
  void dispose() {
    focusNode.dispose();

    super.dispose();
  }

  displayNameSearch(String str) {
    if (str.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    if (queryResultSet.length == 0 && str.length == 1) {
      usersRef
          .where('dnSearchKey', isEqualTo: str.substring(0, 1).toUpperCase())
          .get()
          .then((QuerySnapshot snapshot) {
        for (int i = 0; i < snapshot.docs.length; ++i) {
          queryResultSet.add(snapshot.docs[i].data());

          setState(() {
            tempSearchStore.add(queryResultSet[i]);
          });
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['displayName'].toLowerCase().contains(str.toLowerCase()) ==
            true) {
          if (element['displayName'].toLowerCase().indexOf(str.toLowerCase()) ==
              0) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        }
      });
    }

    if (tempSearchStore.length == 0 && str.length > 1) {
      setState(() {});
    }

    setState(() {
      isSearchTapped = true;
    });
  }

  clearSearch() {
    focusNode.unfocus();
    searchController.clear();

    setState(() {
      isSearchTapped = false;
    });
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream: usersRef
          .orderBy('registerDate', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return UserSuggestionShimmer();
        }

        List<UserToFollow> userToFollow = [];
        snapshot.data.documents.forEach(
          (doc) {
            AppUser user = AppUser.fromDocument(doc);
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userToFollow.length > 0 ? buildSectionPeopleToFollow() : Text(''),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: userToFollow,
              ),
            ),
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
        child: TextField(
          focusNode: focusNode,
          onChanged: (value) {
            displayNameSearch(value);
          },
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
          //onFieldSubmitted: displayNameSearch(searchController.text),
        ),
      ),
    );
  }

  buildSectionPeopleToFollow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.person_add,
                color: Colors.black,
                size: 25,
              ),
              SizedBox(
                width: 8.0,
              ),
              Text(
                "People to follow",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontFamily: fontName,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
        ),
        FlatButton(
          textColor: Colors.blue,
          color: Colors.white10,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PeopleSuggestion()),
          ),
          child: Text(
            'See All',
            style: TextStyle(
                fontFamily: fontName,
                color: Colors.blue,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Container buildNoContent() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildUsersToFollow(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Container(
            margin:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.17),
            child: Column(
              children: [
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
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        ],
      ),
    );
  }

  buildNoSearchResult() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          buildUsersToFollow(),
        ],
      ),
    );
  }

  buildSearchResults() {
    return tempSearchStore.isEmpty
        ? buildNoSearchResult()
        : Column(
            children: tempSearchStore.map((e) {
            print(e);
            return buildResultLayout(e);
          }).toList());
  }

  Widget buildResultLayout(data) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: data['id']),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(data['photoUrl']),
              ),
              title: Text(
                data['displayName'],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontName,
                ),
              ),
              subtitle: Text(
                "@" + data['username'],
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: fontName,
                ),
              ),
            ),
          ),
        ],
      ),
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

    buildNoContent();
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: buildSearchField(),
      body: LiquidPullToRefresh(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.blue,
        animSpeedFactor: 2.5,
        backgroundColor: Colors.white,
        showChildOpacityTransition: false,
        onRefresh: refreshSearch,
        key: refreshKey,
        child: ConnectivityScreenWrapper(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: AlwaysScrollableScrollPhysics(),
            child: isSearchTapped ? buildSearchResults() : buildNoContent(),
          ),
        ),
      ),
    );
  }
}

class UserToFollow extends StatelessWidget {
  final AppUser user;

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
                  user.displayName.length > 10
                      ? user.displayName.substring(0, 10) + "..."
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
                  user.occupation.length > 10
                      ? user.occupation.substring(0, 10) + "..."
                      : user.occupation,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
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
  final AppUser user;

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
