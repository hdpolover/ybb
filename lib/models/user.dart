import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  String username;
  final String email;
  String photoUrl;
  String displayName;
  final String bio;
  final String occupation;
  final String interests;
  final DateTime registerDate;
  final String phoneNumber;
  final String instagram;
  final String facebook;
  final String website;
  final bool showContacts;

  AppUser({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
    this.occupation,
    this.interests,
    this.registerDate,
    this.phoneNumber,
    this.instagram,
    this.facebook,
    this.website,
    this.showContacts,
  });

  factory AppUser.fromDocument(DocumentSnapshot doc) {
    return AppUser(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      occupation: doc['occupation'],
      interests: doc['interests'],
      registerDate: doc['registerDate'].toDate(),
      phoneNumber: doc['phoneNumber'],
      showContacts: doc['showContacts'],
      instagram: doc['instagram'],
      facebook: doc['facebook'],
      website: doc['website'],
    );
  }
}
