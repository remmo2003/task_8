import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/Pdfresponse.dart';

class PdfViewModel {
  static Future<Pdfresponse> loadPdfDetails() async {
    String filepath = "assets/files/PDFSample.json";
    String jsonString = await rootBundle.loadString(filepath);
    var jsonData = json.decode(jsonString);
    return Pdfresponse.fromJson(jsonData);
  }
}

final pdfViewModel = PdfViewModel();
