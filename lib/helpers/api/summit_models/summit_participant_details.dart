import 'dart:convert';

import 'package:http/http.dart' as http;

class SummitParticipantDetails {
  //participant main
  final int participantId;

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
  });

  factory SummitParticipantDetails.fromJSON(Map<String, dynamic> data) {
    return SummitParticipantDetails(
      participantId: data['id_participant'],
      photo: data['photo'],
      fullName: data['full_name'],
      gender: data['gender'],
      nationality: data['nationality'],
      address: data['address'],
      occupation: data['occupation'],
      fieldOfStudy: data['field_of_study'],
      igAccount: data['id_account'],
      waNumber: data['wa_number'],
      institution: data['institution'],
      isVegetarian: data['is_vegetarian'],
      contactRelation: data['contact_relation'],
      talents: data['talents'],
      tshirtSize: data['tshirt_size'],
      diseaseHistory: data['disease_history'],
      emergencyContact: data['emergency_contact'],
      essay: data['essay'],
      experience: data['experience'],
      socialProjects: data['social_projects'],
      sourceAccountName: data['source_account_name'],
      knowProgramFrom: data['know_program_from'],
      achievements: data['achievements'],
      subtheme: data['subtheme'],
    );
  }

  static Future<SummitParticipantDetails> registerParticipant(
      Map<String, dynamic> participantData) async {
    String url = "http://192.168.1.9/ybbadminweb/api/participant";

    final response = await http.post(url, body: participantData);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      return SummitParticipantDetails.fromJSON(jsonData);
    } else {
      throw Exception('Unexpected error occured!');
    }
  }
}
