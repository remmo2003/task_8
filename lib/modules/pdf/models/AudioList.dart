class AudioList {
  AudioList({this.langCode, this.url, this.langName, this.duration});

  AudioList.fromJson(dynamic json) {
    langCode = json['langCode'];
    url = json['url'];
    langName = json['langName'];
    duration = (json['duration'] as num?)?.toDouble();
  }
  String? langCode;
  String? url;
  String? langName;
  double? duration;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['langCode'] = langCode;
    map['url'] = url;
    map['langName'] = langName;
    map['duration'] = duration;
    return map;
  }

  @override
  String toString() {
    return langCode ?? '';
  }
}
