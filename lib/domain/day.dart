import 'package:hive/hive.dart';
import 'package:plango/domain/schedule.dart';

import 'diary.dart';

part 'day.g.dart';

@HiveType(typeId: 2)
class Day {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  List<Schedule> scheduleList = [];
  @HiveField(2)
  List<Diary> diaryList = [];
  @HiveField(3)
  int lastUsedId = 0;

  Day(this.date);

  int getNextId() {
    lastUsedId = lastUsedId + 1;
    return lastUsedId;
  }

  Schedule findScheduleById(int id) {
    var itr = scheduleList.iterator;
    while (itr.moveNext()) {
      Schedule current = itr.current;
      if (current.id == id) {
        return current;
      }
    }
    throw Exception("$id에 해당하는 Schedule이 존재하지 않습니다.");
  }

  Diary findDiaryById(int id) {
    var itr = diaryList.iterator;
    while (itr.moveNext()) {
      Diary current = itr.current;
      if (current.id == id) {
        return current;
      }
    }
    throw Exception("$id에 해당하는 Diary가 존재하지 않습니다.");
  }
}
