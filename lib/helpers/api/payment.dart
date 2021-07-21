import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:ybb/helpers/constants.dart';

import '../constants.dart';

class Payment {
  int paymentId;
  int paymentTypeId;
  String participantId;
  String bankName;
  String accountName;
  String paymentProof;
  DateTime paymentDate;
  int paymentStatus;
  int checkStatus;
  double amount;
  String paymentType;

  Payment({
    this.participantId,
    this.paymentId,
    this.paymentTypeId,
    this.bankName,
    this.accountName,
    this.paymentDate,
    this.paymentProof,
    this.paymentStatus,
    this.checkStatus,
    this.amount,
    this.paymentType,
  });

  factory Payment.fromJSON(Map<String, dynamic> data) {
    return Payment(
      participantId: data['id_participant'],
      paymentId: int.parse(data['id_payment']),
      paymentTypeId: int.parse(data['id_payment_type']),
      bankName: data['bank_name'],
      paymentDate: DateTime.parse(data['payment_date']),
      accountName: data['account_name'],
      paymentProof: data['payment_proof'],
      paymentType: data['payment_type'],
      amount: double.parse(data['amount']),
      paymentStatus: int.parse(data['payment_status']),
      checkStatus: int.parse(data['check_status']),
    );
  }

  static Future<List<Payment>> getPaymentStatus(
      String participantId, int paymentTypeId) async {
    String url = baseUrl +
        "/api/payment/?id_participant=" +
        participantId +
        "&id_payment_type=" +
        paymentTypeId.toString();
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> paymentTypeList =
          (jsonData as Map<String, dynamic>)['data'];

      List<Payment> paymentTypes = [];
      for (int i = 0; i < paymentTypeList.length; i++) {
        paymentTypes.add(Payment.fromJSON(paymentTypeList[i]));
      }

      return paymentTypes;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  static makePayment(Map<String, dynamic> data, File image) async {
    String url = baseUrl + "/api/payment";

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
    imageUploadRequest.fields['id_payment_type'] = data['id_payment_type'];
    imageUploadRequest.fields['account_name'] = data['account_name'];
    imageUploadRequest.fields['bank_name'] = data['bank_name'];
    imageUploadRequest.fields['amount'] = data['amount'];
    imageUploadRequest.fields['payment_date'] = data['payment_date'];

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        print("errrr: " + response.statusCode.toString());
        var responseData = await json.decode(json.encode(response.body));
        print(responseData);
        return responseData;
        //return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
