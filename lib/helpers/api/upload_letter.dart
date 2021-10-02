import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:ybb/helpers/constants.dart';

import '../constants.dart';

class UploadLetter {
  int alId;
  String participantId;
  String filePath;

  UploadLetter({
    this.participantId,
    this.alId,
    this.filePath,
  });

  factory UploadLetter.fromJSON(Map<String, dynamic> data) {
    return UploadLetter(
      participantId: data['id_participant'],
      alId: int.parse(data['al_id']),
      filePath: data['file_path'],
    );
  }

  static Future<List<UploadLetter>> getFileStatus(String participantId) async {
    String url =
        baseUrl + "/api/upload_letter/?id_participant=" + participantId;
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> paymentTypeList =
          (jsonData as Map<String, dynamic>)['data'];

      List<UploadLetter> paymentTypes = [];
      for (int i = 0; i < paymentTypeList.length; i++) {
        paymentTypes.add(UploadLetter.fromJSON(paymentTypeList[i]));
      }

      return paymentTypes;
    } else {
      return [];
    }
  }

  static uploadFile(Map<String, dynamic> data, File letter) async {
    String url = baseUrl + "/api/upload_letter";

    Uri apiUrl = Uri.parse(url);

    final mimeTypeData =
        lookupMimeType(letter.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest = http.MultipartRequest('POST', apiUrl);

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', letter.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.files.add(file);
    imageUploadRequest.fields['id_participant'] = data['id_participant'];

    final streamedResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    var statusCode = response.statusCode;
    if (statusCode == 201 || statusCode == 200 || response.body != null) {
      print(statusCode);
      var responseData = await json.decode(json.encode(response.body));
      print(responseData);
      return responseData;
    } else {
      throw new Exception("An error occured : [Status Code : $statusCode]");
    }
  }
}
