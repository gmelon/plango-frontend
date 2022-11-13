import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plango/domain/day.dart';
import 'package:plango/domain/diary.dart';
import 'package:plango/domain/schedule.dart';
import 'package:table_calendar/table_calendar.dart';

class DayService extends ChangeNotifier {
  late Box box;

  DayService() {
    // box = _init();
  }

  // Future<Box> _init() async {
  //   // 영속 저장을 위한 Hive 객체
  //   Hive.registerAdapter(DayAdapter());
  //   Hive.registerAdapter(DiaryAdapter());
  //   Hive.registerAdapter(ScheduleAdapter());

  //   return await Hive.openBox<Day>('day');
  // }

  // Box get initializationDone => box;

  List<Day> dayList = [];

  // Day
  Day createDay(DateTime selectedDay) {
    Day newDay = Day(selectedDay);
    dayList.add(newDay);
    notifyListeners();

    return newDay;
  }

  Day? findToday() {
    var itr = dayList.iterator;
    while (itr.moveNext()) {
      Day current = itr.current;
      if (isSameDay(current.date, DateTime.now())) {
        return current;
      }
    }
    return null;
  }

  Day? findDay(DateTime givenDay) {
    var itr = dayList.iterator;
    while (itr.moveNext()) {
      Day current = itr.current;
      if (isSameDay(current.date, givenDay)) {
        return current;
      }
    }
    return null;
  }

  void createScheduleAndDiary(
      Day today, String imageUrl, String storeName, String detailUrl) {
    int nextId = today.getNextId();

    // schedule 추가
    Schedule schedule = Schedule(nextId, imageUrl, storeName, detailUrl);
    today.scheduleList.add(schedule);

    // schedule의 fk와 대응되는 diary 추가
    Diary diary = Diary(nextId);
    today.diaryList.add(diary);

    // notify
    notifyListeners();
  }

  String getFormattedDateString(Day day) {
    return DateFormat('yyyy년 MM월 dd일').format(day.date);
  }

  void deleteScheduleAndDiary(Day today, int id) {
    // Schedule 삭제
    today.scheduleList.remove(today.findScheduleById(id));
    // Diary 삭제
    today.diaryList.remove(today.findDiaryById(id));
    notifyListeners();
  }

  // Schedule (전체 정보) 수정
  void updateSchedule(
      Day today, int id, String imageUrl, String storeName, String detailUrl) {
    Schedule schedule = today.findScheduleById(id);

    schedule.update(imageUrl, storeName, detailUrl);
    notifyListeners();
  }

  void updateScheduleMemo(Day today, int id, String memo) {
    Schedule schedule = today.findScheduleById(id);
    schedule.memo = memo;
    notifyListeners();
  }

  // Diary 사진 수정
  void saveDiaryImage(Day today, int id) async {
    // load image from gallery
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File imageFile = File(image!.path);

    // generate path and save path to Diary object
    var dir = await getApplicationDocumentsDirectory();
    String imagePath = "${dir.path}/${today.date}-$id";
    updateDiaryImage(today, id, imagePath);

    // convert image to bytes array
    Uint8List imageBytes = await imageFile.readAsBytes();

    // save base64 to storage
    File(imagePath).writeAsBytes(imageBytes);
    notifyListeners();
  }

  Future<Uint8List> loadDiaryImage(Day today, int id) async {
    Diary diary = today.findDiaryById(id);
    String imagePath = diary.imageUrl;

    return await File(imagePath).readAsBytes();
  }

  void updateDiaryImage(Day today, int id, String imageUrl) {
    Diary diary = today.findDiaryById(id);

    diary.updateImageUrl(imageUrl);
    notifyListeners();
  }

  // Diary 본문 수정
  void updateDiaryBody(Day today, int id, String body) {
    Diary diary = today.findDiaryById(id);

    diary.updateBody(body);
    notifyListeners();
  }

  // HashTag 추가, 변경, 삭제
  void addDiaryHashTag(Day today, int id, String hashTag) {
    Diary diary = today.findDiaryById(id);

    diary.addHashTag(hashTag);
    notifyListeners();
  }

  void removeDiaryHashTag(Day today, int id, String hashTag) {
    Diary diary = today.findDiaryById(id);

    diary.removeHashTag(hashTag);
    notifyListeners();
  }

  void updateHashTag(Day today, int id, String oldOne, String newOne) {
    Diary diary = today.findDiaryById(id);

    diary.updateHashTag(oldOne, newOne);
    notifyListeners();
  }
}
