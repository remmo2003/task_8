class Keyword {
  Keyword({
    this.id,
    this.word,
    this.youtubeLink,
    this.wikipediaLink,
    this.ekbLink,
    this.definition,
  });

  Keyword.fromJson(dynamic json) {
    id = json['id'];
    word = json['word'];
    youtubeLink = json['youtubeLink'];
    wikipediaLink = json['wikipediaLink'];
    ekbLink = json['ekbLink'];
    definition = json['definition'];
  }

  String? id;
  String? word;
  String? youtubeLink;
  String? wikipediaLink;
  String? ekbLink;
  String? definition;

  @override
  String toString() => word ?? '';
}
