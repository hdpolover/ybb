import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../constants.dart';

class SummitParticipant {
  //participant main
  final String participantId;
  final String email;
  final int summitId;
  final String qrCode;
  final int isFullyFunded;
  final DateTime createdDate;
  final int status;

  SummitParticipant({
    this.participantId,
    this.summitId,
    this.email,
    this.qrCode,
    this.isFullyFunded,
    this.createdDate,
    this.status,
  });

  factory SummitParticipant.fromJSON(Map<String, dynamic> data) {
    return SummitParticipant(
      participantId: data['id_participant'],
      summitId: int.parse(data['id_summit']),
      email: data['email'],
      status: int.parse(data['status']),
      qrCode: data['qr_code'],
      createdDate: DateTime.parse(data['created_date']),
      isFullyFunded: int.parse(data['is_fully_funded']),
    );
  }

  static Future<SummitParticipant> getParticipant(String id) async {
    String url = baseUrl + "/api/participant/?id_participant=" + id;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      print(jsonData);

      List<dynamic> data = (jsonData as Map<String, dynamic>)['data'];
      return SummitParticipant.fromJSON(data[0]);
    } else {
      print(response.statusCode.toString() + ": error");
      return null;
    }
  }

  static Future<SummitParticipant> registerParticipant(
      Map<String, dynamic> participantData) async {
    String url = baseUrl + "/api/participant";

    final response = await http.post(
      url,
      body: {
        "id_participant": participantData['id_participant'],
        "id_summit": participantData['id_summit'],
        "email": participantData['email'],
      },
    );

    if (response.statusCode == 201 ||
        response.statusCode == 200 ||
        response.statusCode == 500) {
      var jsonData = jsonDecode(response.body);

      print(jsonData);

      List<dynamic> data = (jsonData as Map<String, dynamic>)['data'];
      return SummitParticipant.fromJSON(data[0]);
    } else {
      print(response.statusCode);
      throw Exception('Unexpected error occured!');
    }
  }

  static updateParticipantStatus(String id, String status) async {
    String url = baseUrl + "/api/participant";

    final response = await http.put(
      url,
      body: {
        "id_participant": id,
        "status": status,
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      print(jsonData);
      return true;
    } else {
      print(response.statusCode);
      throw Exception('Unexpected error occured!');
    }
  }
}
