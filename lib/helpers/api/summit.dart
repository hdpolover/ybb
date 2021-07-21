import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ybb/helpers/constants.dart';

class Summit {
  String summitId;
  String desc;
  String registFee;
  String programFee;
  int status;

  Summit({
    this.summitId,
    this.desc,
    this.registFee,
    this.programFee,
    this.status,
  });

  factory Summit.fromJSON(Map<String, dynamic> data) {
    return Summit(
      summitId: data['id_summit'],
      desc: data['description'],
      registFee: data['regist_fee'],
      programFee: data['program_fee'],
      status: int.parse(data['status']),
    );
  }

  static Future<List<Summit>> getSummits() async {
    String url = baseUrl + "/api/summit";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> summitList = (jsonData as Map<String, dynamic>)['data'];

      List<Summit> summits = [];
      for (int i = 0; i < summitList.length; i++) {
        summits.add(Summit.fromJSON(summitList[i]));
      }

      return summits;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  static Future<List<Summit>> getSummitById(int summitId) async {
    String url = baseUrl + "/api/summit/?id_summit=" + summitId.toString();

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> summitList = (jsonData as Map<String, dynamic>)['data'];

      List<Summit> summits = [];
      for (int i = 0; i < summitList.length; i++) {
        summits.add(Summit.fromJSON(summitList[i]));
      }

      return summits;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }
}
