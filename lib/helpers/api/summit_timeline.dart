import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ybb/helpers/constants.dart';

class SummitTimeline {
  String summitTimelineId;
  String summitId;
  String description;
  String timeline;
  DateTime startTimeline;
  DateTime endTimeline;
  int status;

  SummitTimeline({
    this.summitTimelineId,
    this.summitId,
    this.description,
    this.timeline,
    this.startTimeline,
    this.endTimeline,
    this.status,
  });

  factory SummitTimeline.fromJSON(Map<String, dynamic> data) {
    return SummitTimeline(
      summitTimelineId: data['id_summit_timeline'],
      summitId: data['id_summit'],
      description: data['description'],
      timeline: data['timeline'],
      startTimeline: DateTime.parse(data['start_timeline']),
      endTimeline: DateTime.parse(data['end_timeline']),
      status: int.parse(data['status']),
    );
  }

  static Future<List<SummitTimeline>> getTimelines() async {
    String url = baseUrl + "/api/timeline";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> timelineList = (jsonData as Map<String, dynamic>)['data'];

      List<SummitTimeline> timelines = [];
      for (int i = 0; i < timelineList.length; i++) {
        timelines.add(SummitTimeline.fromJSON(timelineList[i]));
      }

      return timelines;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  static Future<SummitTimeline> getTimelinebyId(String id) async {
    String url = baseUrl + "/api/timeline/?id_summit_timeline=" + id;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      print(jsonData);

      List<dynamic> data = (jsonData as Map<String, dynamic>)['data'];
      return SummitTimeline.fromJSON(data[0]);
    } else {
      print(response.statusCode.toString() + ": error");
      return null;
    }
  }
}
