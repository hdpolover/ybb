import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ybb/pages/post_detail.dart';
import 'package:ybb/pages/profile.dart';

class Item {
  Item({this.postId, this.recipientId});
  final String postId, recipientId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => postId == null || postId.isEmpty
            ? Profile(
                isFromOutside: true,
                profileId: recipientId,
              )
            : PostDetail(
                userId: recipientId,
              ),
      ),
    );
  }
}
