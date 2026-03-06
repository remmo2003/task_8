import 'AudioList.dart';
import 'AvailableLanguages.dart';
import 'VttList.dart';
import 'FrameItem.dart';
import 'Keyword.dart';

class Pdfresponse {
  Pdfresponse({
    this.keywords,

    this.id,
    this.audioList,
    this.vttList,
    this.availableLanguages,
    this.frameList,
    this.pagesCount,
    this.title,
    this.language,
    this.contentType,
    this.domainName,
    this.subDomainName,
  });

  Pdfresponse.fromJson(dynamic json) {
    if (json['keywords'] != null) {
      keywords = [];
      json['keywords'].forEach((v) {
        keywords?.add(Keyword.fromJson(v));
      });
    }
    id = json['_id'];
    if (json['audioList'] != null) {
      audioList = [];
      json['audioList'].forEach((v) {
        audioList?.add(AudioList.fromJson(v));
      });
    }
    if (json['vttList'] != null) {
      vttList = [];
      json['vttList'].forEach((v) {
        vttList?.add(VttList.fromJson(v));
      });
    }
    if (json['availableLanguages'] != null) {
      availableLanguages = [];
      json['availableLanguages'].forEach((v) {
        availableLanguages?.add(AvailableLanguages.fromJson(v));
      });
    }
    if (json['frameList'] != null) {
      frameList = [];
      json['frameList'].forEach((v) {
        frameList?.add(FrameItem.fromJson(v));
      });
    }
    pagesCount = json['pagesCount'];
    title = json['title'];
    language = json['language'];
    contentType = json['contentType'];
    domainName = json['domainName'];
    subDomainName = json['subDomainName'];
  }

  List<Keyword>? keywords;
  String? id;
  List<AudioList>? audioList;
  List<VttList>? vttList;
  List<AvailableLanguages>? availableLanguages;
  List<FrameItem>? frameList;
  int? pagesCount;
  String? title;
  String? language;
  String? contentType;
  String? domainName;
  String? subDomainName;
}
