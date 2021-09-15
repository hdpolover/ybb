import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:ybb/helpers/constants.dart';

class SummitParticipantDetails {
  //participant main
  final String participantId;

//participant details
  final String photo;
  final String fullName;
  final String birthdate;
  final String nationality;
  final String address;
  final String gender;
  final String occupation;
  final String fieldOfStudy;
  final String institution;
  final String emergencyContact;
  final String contactRelation;
  final String waNumber;
  final String igAccount;
  final String tshirtSize;
  final String diseaseHistory;
  final int isVegetarian;
  final String essay;
  final String subtheme;
  final String socialProjects;
  final String talents;
  final String achievements;
  final String experience;
  final String knowProgramFrom;
  final String sourceAccountName;
  final String videoLink;

  SummitParticipantDetails({
    this.participantId,
    this.photo,
    this.fullName,
    this.birthdate,
    this.nationality,
    this.address,
    this.gender,
    this.occupation,
    this.fieldOfStudy,
    this.institution,
    this.emergencyContact,
    this.contactRelation,
    this.waNumber,
    this.igAccount,
    this.tshirtSize,
    this.diseaseHistory,
    this.isVegetarian,
    this.essay,
    this.achievements,
    this.experience,
    this.knowProgramFrom,
    this.socialProjects,
    this.sourceAccountName,
    this.subtheme,
    this.talents,
    this.videoLink,
  });

  factory SummitParticipantDetails.fromJSON(Map<String, dynamic> data) {
    return SummitParticipantDetails(
      participantId: data['id_participant'],
      photo: data['photo'],
      fullName: data['full_name'],
      gender: data['gender'],
      birthdate: data['birthdate'],
      nationality: data['nationality'],
      address: data['address'],
      occupation: data['occupation'],
      fieldOfStudy: data['field_of_study'],
      igAccount: data['ig_account'],
      waNumber: data['wa_number'],
      institution: data['institution'],
      isVegetarian: int.parse(data['is_vegetarian']),
      contactRelation: data['contact_relation'],
      talents: data['talents'],
      tshirtSize: data['tshirt_size'],
      diseaseHistory: data['disease_history'],
      emergencyContact: data['emergency_contact'],
      essay: data['essay'],
      experience: data['experiences'],
      socialProjects: data['social_projects'],
      sourceAccountName: data['source_account_name'],
      knowProgramFrom: data['know_program_from'],
      achievements: data['achievements'],
      subtheme: data['subtheme'],
      videoLink: data['video_link'],
    );
  }

  static Future<SummitParticipantDetails> getParticipantDetails(
      String id) async {
    String url = baseUrl + "/api/participant_detail/?id_participant=" + id;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      print(jsonData);

      List<dynamic> data = (jsonData as Map<String, dynamic>)['data'];
      return SummitParticipantDetails.fromJSON(data[0]);
    } else {
      print(response.statusCode.toString() + ": error");
      return null;
    }
  }

  static addParticipantDetails(Map<String, dynamic> data, File image) async {
    String url = baseUrl + "/api/participant_detail";

    Uri apiUrl = Uri.parse(url);

    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Intilize the multipart request
    final imageUploadRequest = http.MultipartRequest('POST', apiUrl);

    // Attach the file in the request
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.files.add(file);
    imageUploadRequest.fields['id_participant'] = data['id_participant'];
    imageUploadRequest.fields['full_name'] = data['full_name'];
    imageUploadRequest.fields['birthdate'] = data['birthdate'];
    imageUploadRequest.fields['gender'] = data['gender'];
    imageUploadRequest.fields['address'] = data['address'];
    imageUploadRequest.fields['nationality'] = data['nationality'];
    imageUploadRequest.fields['occupation'] = data['occupation'];
    imageUploadRequest.fields['field_of_study'] = data['field_of_study'];
    imageUploadRequest.fields['ig_account'] = data['ig_account'];
    imageUploadRequest.fields['wa_number'] = data['wa_number'];
    imageUploadRequest.fields['institution'] = data['institution'];
    imageUploadRequest.fields['is_vegetarian'] =
        data['is_vegetarian'].toString();
    imageUploadRequest.fields['contact_relation'] = data['contact_relation'];
    imageUploadRequest.fields['talents'] = data['talents'];
    imageUploadRequest.fields['tshirt_size'] = data['tshirt_size'];
    imageUploadRequest.fields['disease_history'] = data['disease_history'];
    imageUploadRequest.fields['emergency_contact'] = data['emergency_contact'];
    imageUploadRequest.fields['essay'] = data['essay'];
    imageUploadRequest.fields['experiences'] = data['experiences'];
    imageUploadRequest.fields['social_projects'] = data['social_projects'];
    imageUploadRequest.fields['source_account_name'] =
        data['source_account_name'];
    imageUploadRequest.fields['know_program_from'] = data['know_program_from'];
    imageUploadRequest.fields['achievements'] = data['achievements'];
    imageUploadRequest.fields['subtheme'] = data['subtheme'];
    imageUploadRequest.fields['video_link'] = data['video_link'];
    imageUploadRequest.fields['referral_code'] = data['referral_code'];

    final streamedResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamedResponse);
    // if (response.statusCode != 200) {
    //   print("errrr: " + response.statusCode.toString());
    //   return null;
    // }
    final statusCode = response.statusCode;
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
