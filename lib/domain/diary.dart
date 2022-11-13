import 'package:hive/hive.dart';

part 'diary.g.dart';

@HiveType(typeId: 0)
class Diary {
  @HiveField(0)
  int id;
  @HiveField(1)
  String imageUrl = "";
  @HiveField(2)
  String body = "";
  @HiveField(3)
  List<String> hashtag = [];

  Diary(this.id);

  void updateImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  void updateBody(String body) {
    this.body = body;
  }

  void addHashTag(String hashTag) {
    hashtag.add(hashTag);
  }

  void removeHashTag(String hashTag) {
    hashtag.remove(hashTag);
  }

  void updateHashTag(String oldHashTag, String newHashTag) {
    removeHashTag(oldHashTag);
    addHashTag(newHashTag);
  }
}
