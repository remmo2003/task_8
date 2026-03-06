import 'Data.dart';

class AvailableLanguages {
  AvailableLanguages({
    this.data,
    this.frameUrls,
    this.frameList,
    this.languageCode,
    this.isEdited,
  });

  AvailableLanguages.fromJson(dynamic json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['frameUrls'] != null) {
      frameUrls = [];
      json['frameUrls'].forEach((v) {
        frameUrls?.add(AvailableLanguages.fromJson(v));
      });
    }
    if (json['frameList'] != null) {
      frameList = [];
      json['frameList'].forEach((v) {
        frameList?.add(AvailableLanguages.fromJson(v));
      });
    }
    languageCode = json['languageCode'];
    isEdited = json['isEdited'];
  }
  Data? data;
  List<dynamic>? frameUrls;
  List<dynamic>? frameList;
  String? languageCode;
  bool? isEdited;
  @override
  String toString() {
    return languageCode ?? '';
  }

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   if (data != null) {
  //     map['data'] = data.toJson();
  //   }
  //   if (frameUrls != null) {
  //     map['frameUrls'] = frameUrls.map((v) => v.toJson()).toList();
  //   }
  //   if (frameList != null) {
  //     map['frameList'] = frameList.map((v) => v.toJson()).toList();
  //   }
  //   map['languageCode'] = languageCode;
  //   map['isEdited'] = isEdited;
  //   return map;
  // }
}
