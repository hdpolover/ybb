import 'package:cloud_firestore/cloud_firestore.dart';

class Commenter {
  String id;
  String displayName;
  String photoUrl;

  Commenter({
    this.id,
    this.displayName,
    this.photoUrl,
  });

  factory Commenter.fromDocument(DocumentSnapshot doc) {
    return Commenter(
      id: doc['id'],
      displayName: doc['displayName'],
      photoUrl: doc['photoUrl'],
    );
  }
}
