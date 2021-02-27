import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String username;
  final String email;
  String photoUrl;
  String displayName;
  final String bio;
  final String occupation;
  final String interests;
  final DateTime timestamp;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.occupation,
    this.interests,
    this.timestamp,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      occupation: doc['occupation'],
      interests: doc['interests'],
      timestamp: doc['timestamp'].toDate(),
    );
  }
}
