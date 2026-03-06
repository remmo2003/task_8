import 'package:flutter/material.dart';
import 'package:task_8/core/resources/ap_constant.dart';
import 'models/AudioList.dart';
import 'models/AvailableLanguages.dart';
import 'models/VttList.dart';
import 'models/FrameItem.dart';
import 'models/Keyword.dart';
import 'models/Data.dart';
import 'models/Pdfresponse.dart';
import 'pdfviewmodel.dart';

class PdfProvider extends ChangeNotifier {
  List<Keyword>? keywords = [];
  List<AudioList>? audioList = [];
  List<VttList>? vttList = [];
  List<AvailableLanguages>? availableLanguages = [];
  List<FrameItem>? frameList = [];
  List<String> languageCodes = [];
  List<String>? subtitlelangcode = [];
  bool isLoading = false;
  String? selectedvalue;
  Data? selecteddata;
  int currentSlideIndex = 0;

  FrameItem? get currentSlide => (frameList != null && frameList!.isNotEmpty)
      ? frameList![currentSlideIndex]
      : null;

  int get totalSlides => frameList?.length ?? 0;

  void nextSlide() {
    if (currentSlideIndex < totalSlides - 1) {
      currentSlideIndex++;
      notifyListeners();
    }
  }

  void previousSlide() {
    if (currentSlideIndex > 0) {
      currentSlideIndex--;
      notifyListeners();
    }
  }

  void goToSlide(int index) {
    if (index >= 0 && index < totalSlides) {
      currentSlideIndex = index;
      notifyListeners();
    }
  }

  String removeHtmlTags(String html) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return html.replaceAll(exp, '').trim();
  }

  String? defaultSelectedValue() {
    for (int i = 0; i < availableLanguages!.length; i++) {
      if (AppConstants.defult_language == availableLanguages![i].languageCode) {
        String? transcript = availableLanguages?[i].data?.transcript;
        return transcript != null ? removeHtmlTags(transcript) : null;
      }
    }
    return null;
  }

  Data? selectData(int index) {
    selecteddata = availableLanguages![index].data;
    notifyListeners();
    return selecteddata;
  }

  void selected(String value) {
    if (value == "summary25") {
      selectedvalue = selecteddata!.summary25!;
    } else if (value == "summary50") {
      selectedvalue = selecteddata!.summary50!;
    } else if (value == "transcript") {
      selectedvalue = removeHtmlTags(selecteddata!.transcript!);
    }
    notifyListeners();
  }

  String? defaultLanguage() {
    return AppConstants.defult_language;
  }

  Future<void> fetchPdfData() async {
    isLoading = true;
    notifyListeners();
    Pdfresponse response = await PdfViewModel.loadPdfDetails();
    isLoading = false;
    keywords = response.keywords ?? [];
    audioList = response.audioList ?? [];
    vttList = response.vttList ?? [];
    availableLanguages = response.availableLanguages ?? [];
    frameList = response.frameList ?? [];
    languageCodes =
        availableLanguages?.map((e) => e.languageCode.toString()).toList() ??
        [];
    subtitlelangcode =
        vttList?.map((e) => e.langCode.toString()).toList() ?? [];
    notifyListeners();
  }
}
