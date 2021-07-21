import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:ybb/helpers/constants.dart';

class SummitContent {
  SummitContent({
    this.idSummitContent,
    this.idAdmin,
    this.idSummit,
    this.description,
    this.filePath,
    this.createdDate,
    this.modifiedDate,
    this.status,
    this.title,
    this.fileType,
  });

  String idSummitContent;
  String idAdmin;
  int idSummit;
  String description;
  String filePath;
  DateTime createdDate;
  DateTime modifiedDate;
  String status;
  String fileType;
  String title;

  factory SummitContent.fromJSON(Map<String, dynamic> json) {
    return SummitContent(
      idSummitContent: json["id_summit_content"],
      idAdmin: json["id_admin"],
      idSummit: int.parse(json["id_summit"]),
      description: json["description"],
      filePath: json["file_path"],
      createdDate: DateTime.parse(json["created_date"]),
      modifiedDate: DateTime.parse(json["modified_date"]),
      status: json["status"],
      fileType: json["file_type"],
      title: json['title'],
    );
  }

  static Future<List<SummitContent>> getSummitContents() async {
    String url = baseUrl + "/api/summit_content/";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> summitContentList =
          (jsonData as Map<String, dynamic>)['data'];

      List<SummitContent> summitContents = [];
      for (int i = 0; i < summitContentList.length; i++) {
        summitContents.add(SummitContent.fromJSON(summitContentList[i]));
      }

      return summitContents;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }
}
