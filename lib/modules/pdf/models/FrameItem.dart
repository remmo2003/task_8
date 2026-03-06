import 'AudioList.dart';

class FrameItem {
  FrameItem({
    this.page,
    this.name,
    this.url,
    this.startTime,
    this.duration,
    this.audioList,
  });

  FrameItem.fromJson(dynamic json) {
    page = json['page'];
    name = json['name'];
    url = json['url'];
    startTime = (json['startTime'] as num?)?.toDouble();
    duration = (json['duration'] as num?)?.toDouble();
    if (json['audioList'] != null) {
      audioList = [];
      json['audioList'].forEach((v) {
        audioList?.add(AudioList.fromJson(v));
      });
    }
  }

  int? page;
  String? name;
  String? url;
  double? startTime;
  double? duration;
  List<AudioList>? audioList;
}
