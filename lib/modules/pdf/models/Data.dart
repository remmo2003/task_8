class Data {
  Data({this.transcript, this.summary25, this.summary50, this.keywords});

  Data.fromJson(dynamic json) {
    transcript = json['transcript'];
    summary25 = json['summary25'];
    summary50 = json['summary50'];
    if (json['keywords'] != null) {
      keywords = [];
      json['keywords'].forEach((v) {
        keywords?.add(Data.fromJson(v));
      });
    }
  }
  String? transcript;
  String? summary25;
  String? summary50;
  List<dynamic>? keywords;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['transcript'] = transcript;
    map['summary25'] = summary25;
    map['summary50'] = summary50;
    if (keywords != null) {
      map['keywords'] = keywords?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
