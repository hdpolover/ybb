import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/models/user.dart';
import 'package:ybb/pages/home.dart';
import 'package:ybb/pages/messaging.dart';
import 'package:ybb/widgets/default_appbar.dart';
import 'package:ybb/widgets/shimmers/comment_shimmer_layout.dart';

// ignore: must_be_immutable
class CreateNewMessage extends StatefulWidget {
  @override
  _CreateNewMessage createState() => _CreateNewMessage();
}

class _CreateNewMessage extends State<CreateNewMessage> {
  List<String> userIds = [];
  List<UserNewMessage> results;

  @override
  void initState() {
    super.initState();

    getFollowing().then((value) => getUsers());
  }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    setState(() {
      userIds = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> getUsers() async {
    List<UserNewMessage> users = [];
    userIds.forEach((element) async {
      if (element != currentUser.id) {
        DocumentSnapshot snapshot = await usersRef.doc(element).get();

        AppUser user = AppUser.fromDocument(snapshot);
        UserNewMessage userNewMessage = UserNewMessage(user);

        users.add(userNewMessage);

        setState(() {
          results = users;
        });
      }
    });
  }

  Container buildNoContent() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_notif.svg',
              height: MediaQuery.of(context).size.width * 0.4,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Nothing to see here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildFollowResults() {
    if (results == null) {
      return CommentShimmer();
    } else {
      return results.length == 0
          ? buildNoContent()
          : ListView(children: results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, titleText: "New Message"),
      body: buildFollowResults(),
    );
  }
}

class UserNewMessage extends StatelessWidget {
  final AppUser user;

  UserNewMessage(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Messaging(
                    selectedUser: user,
                  ),
                ),
              );
            },
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
