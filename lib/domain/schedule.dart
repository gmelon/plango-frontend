import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 1)
class Schedule {
  @HiveField(0)
  int id;
  @HiveField(1)
  String imageUrl;
  @HiveField(2)
  String storeName;
  @HiveField(3)
  String memo = "";
  @HiveField(4)
  String detailUrl;

  Schedule(this.id, this.imageUrl, this.storeName, this.detailUrl);

  void update(String imageUrl, String storeName, String detailUrl) {
    this.imageUrl = imageUrl;
    this.storeName = storeName;
    this.detailUrl = detailUrl;
  }
}
