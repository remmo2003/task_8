class VttList {
  VttList({this.langCode, this.langName, this.url});

  VttList.fromJson(dynamic json) {
    langCode = json['lang'] ?? json['langCode']; // الـ JSON بيستخدم 'lang'
    langName = json['text'] ?? json['langName']; // الـ JSON بيستخدم 'text'
    url = json['url'];
  }

  String? langCode;
  String? langName;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['langCode'] = langCode;
    map['langName'] = langName;
    map['url'] = url;
    return map;
  }
}
