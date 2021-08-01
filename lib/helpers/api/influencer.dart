import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ybb/helpers/constants.dart';

class Influencer {
  String referralCode;
  int status;

  Influencer({
    this.referralCode,
    this.status,
  });

  factory Influencer.fromJSON(Map<String, dynamic> data) {
    return Influencer(
      referralCode: data['referral_code'],
      status: int.parse(data['status']),
    );
  }

  static Future<List<Influencer>> getInfluencerRefCodes() async {
    String url = baseUrl + "/api/influencer";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> summitList = (jsonData as Map<String, dynamic>)['data'];

      List<Influencer> summits = [];
      for (int i = 0; i < summitList.length; i++) {
        summits.add(Influencer.fromJSON(summitList[i]));
      }

      return summits;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }
}
