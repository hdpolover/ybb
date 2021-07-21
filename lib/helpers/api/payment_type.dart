import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';

class PaymentType {
  int paymentTypeId;
  int summitId;
  String description;
  DateTime startDate;
  DateTime endDate;
  String type;

  PaymentType({
    this.summitId,
    this.paymentTypeId,
    this.description,
    this.startDate,
    this.endDate,
    this.type,
  });

  factory PaymentType.fromJSON(Map<String, dynamic> data) {
    return PaymentType(
      summitId: int.parse(data['id_summit']),
      description: data['description'],
      startDate: DateTime.parse(data['start_date']),
      endDate: DateTime.parse(data['end_date']),
      paymentTypeId: int.parse(data['id_payment_type']),
      type: data['type'],
    );
  }

  static Future<List<PaymentType>> getPaymentTypes() async {
    String url = baseUrl + "/api/payment_type";

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> paymentTypeList =
          (jsonData as Map<String, dynamic>)['data'];

      List<PaymentType> paymentTypes = [];
      for (int i = 0; i < paymentTypeList.length; i++) {
        paymentTypes.add(PaymentType.fromJSON(paymentTypeList[i]));
      }

      return paymentTypes;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }
}
