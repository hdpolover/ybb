import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ybb/helpers/constants.dart';
import 'package:ybb/pages/home.dart';

class UserSuggestion extends StatefulWidget {
  final String userId;
  final String displayName;
  final String occupation;
  final String photUrl;

  UserSuggestion({
    this.userId,
    this.displayName,
    this.occupation,
    this.photUrl,
  });

  factory UserSuggestion.fromDocument(DocumentSnapshot doc) {
    return UserSuggestion(
      userId: doc['id'],
      displayName: doc['displayName'],
      occupation: doc['occupation'],
      photUrl: doc['photoUrl'],
    );
  }

  @override
  _UserSuggestionState createState() => _UserSuggestionState(
        userId: this.userId,
        displayName: this.displayName,
        occupation: this.occupation,
        photoUrl: this.photUrl,
      );
}

class _UserSuggestionState extends State<UserSuggestion> {
  final String userId;
  final String displayName;
  final String occupation;
  final String photoUrl;

  bool isFollowing = false;

  _UserSuggestionState({
    this.userId,
    this.displayName,
    this.occupation,
    this.photoUrl,
  });

  GestureDetector buildButton({String text, Function function}) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: isFollowing ? Colors.white : null,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isFollowing ? Colors.blue : Colors.white,
                fontSize: 12,
                fontFamily: fontName,
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    if (isFollowing) {
      return buildButton(
        text: "UNFOLLOW",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "FOLLOW",
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(userId)
        .collection('userFollowers')
        .doc(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .doc(userId)
        .collection('feedItems')
        .doc(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(userId)
        .collection('userFollowers')
        .doc(currentUser.id)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .doc(userId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .doc(userId)
        .collection('feedItems')
        .doc(currentUser.id)
        .set({
      "type": "follow",
      "ownerId": userId,
      "displayName": currentUser.displayName,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": DateTime.now(),
      "commentData": "",
      "mediaUrl": "",
      "postId": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                displayName.length > 20
                    ? displayName.substring(0, 15) + "..."
                    : displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontName,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.035,
              ),
              Text(
                occupation.length > 30
                    ? occupation.substring(0, 30) + "..."
                    : occupation,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: fontName,
                ),
              ),
            ],
          ),
          buildButton(),
        ],
      ),
    );
  }
}
