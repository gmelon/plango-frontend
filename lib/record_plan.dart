import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/domain/diary.dart';
import 'package:plango/record_plan_detail.dart';
import 'package:plango/repository/day_service.dart';
import 'package:provider/provider.dart';

import 'domain/day.dart';

late DayService dayService;

class RecordPlan extends StatelessWidget {
  Day today;
  RecordPlan(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return RecordBody(today);
      },
    );
  }
}

class RecordBody extends StatelessWidget {
  Day today;
  RecordBody(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    // DayService에서 불러온 오늘에 해당하는 Day 객체

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.73,
            child: today.diaryList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      textAlign: TextAlign.center,
                      '아직 오늘의 계획이 없습니다!\n일정 계획 후 기록해주세요 :)',
                      style: TextStyle(fontSize: 15.5, height: 1.4),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: today.diaryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      // 오늘 (Day)의 일기 아이템을 하나씩 전달
                      return RecordCard(today, today.diaryList[index], index);
                    }),
          )
        ],
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  Day today;
  Diary diary;
  int index;

  RecordCard(this.today, this.diary, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 3.5,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: VerticalDivider(
                      indent: 10,
                      color: Color.fromARGB(255, 192, 192, 192),
                      thickness: 1,
                      width: 5,
                    ),
                  )
                ],
              ),
            ),
            diary.imageUrl != ""
                ? DiaryImageLoader(today, diary, 0.32, 0.11)
                : DefaultImage(today, diary.id, 0.32, 0.11),
            SizedBox(width: 13.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.47,
                  child: Text(
                    // schedule - store name
                    overflow: TextOverflow.fade,
                    today.findScheduleById(diary.id).storeName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 6.0),
                // diary - hash tags
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.47,
                    child: Text(
                      overflow: TextOverflow.fade,
                      diary.hashtag.isEmpty
                          ? '해시태그를 추가해보세요!'
                          : diary.hashtag.join(' '),
                    )),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      alignment: Alignment.center,
                      height: 36,
                      width: 36,
                      child: TextButton(
                        child: Icon(
                          CupertinoIcons.number,
                          size: 17,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // 해시태그 수정 Dialog 표시
                          hashTagDialog(context);
                        },
                      ),
                    ),
                    SizedBox(width: 6.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      alignment: Alignment.center,
                      height: 36,
                      width: 36,
                      child: TextButton(
                        child: Icon(
                          CupertinoIcons.book_fill,
                          size: 17,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          // 일기 작성 페이지
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecordPlanDetail(
                                      today,
                                      diary,
                                      today.findScheduleById(diary.id))));
                          // 일기 임시 저장 클래스 value 초기화
                          TempDiaryBody.value = "";
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<dynamic> hashTagDialog(BuildContext context) {
    TextEditingController hashTagController = TextEditingController();
    FocusNode hashtagFocus = FocusNode();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text("해시태그 수정"),
            content: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: diary.hashtag.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              dayService.removeDiaryHashTag(today, diary.id,
                                  diary.hashtag.elementAt(index));
                            },
                          ),
                          // 출력 시엔 # 제거
                          title: Text(diary.hashtag.elementAt(index)),
                        );
                      }),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hashTagController,
                        focusNode: hashtagFocus,
                        decoration: InputDecoration(
                            hintText: "새로운 해시태그 입력", labelText: "#"),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        hashtagFocus.unfocus();
                        dayService.addDiaryHashTag(
                            today, diary.id, "#${hashTagController.text}");
                        hashTagController.text = "";
                      },
                      icon: Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close, size: 15),
                  label: Text(
                    "닫기",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class DiaryImageLoader extends StatelessWidget {
  DiaryImageLoader(
    this.today,
    this.diary,
    this.width,
    this.height, {
    super.key,
  });

  Day today;
  Diary diary;
  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dayService.loadDiaryImage(today, diary.id),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return DefaultImage(today, diary.id, width, height);
        } else if (snapshot.hasError) {
          return DefaultImage(today, diary.id, width, height);
        } else {
          return GestureDetector(
            onTap: () => dayService.saveDiaryImage(today, diary.id),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.memory(
                snapshot.data,
                width: MediaQuery.of(context).size.width * width,
                height: MediaQuery.of(context).size.height * height,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }
}

class DefaultImage extends StatelessWidget {
  Day today;
  int diaryId;
  double width;
  double height;

  DefaultImage(
    this.today,
    this.diaryId,
    this.width,
    this.height, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => dayService.saveDiaryImage(today, diaryId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          // default image
          'http://www.mth.co.kr/wp-content/uploads/2014/12/default-placeholder.png',
          width: MediaQuery.of(context).size.width * width,
          height: MediaQuery.of(context).size.height * height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
