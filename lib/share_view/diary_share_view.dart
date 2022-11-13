import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/domain/day.dart';
import 'package:plango/domain/diary.dart';
import 'package:plango/main.dart';
import 'package:plango/repository/day_service.dart';
import 'package:plango/share_view/share_helper.dart';
import 'package:provider/provider.dart';

late DayService dayService;
GlobalKey diaryKey = GlobalKey();

class DiaryShareView extends StatelessWidget {
  Day today;
  DiaryShareView(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return Scaffold(
          // appBar: AppBar(title: Text('일기 캡처')),
          body: DiaryShareViewBody(today),
        );
      },
    );
  }
}

class DiaryShareViewBody extends StatelessWidget {
  Day today;
  DiaryShareViewBody(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    // DayService에서 불러온 오늘에 해당하는 Day 객체

    return Center(
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[50]),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RepaintBoundary(
                  key: diaryKey,
                  child: BackImageContainer(
                    child: Column(
                      children: [
                        today.diaryList.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    '아직 오늘의 계획이 없습니다!\n일정 계획 후 기록해주세요 :)',
                                    style:
                                        TextStyle(fontSize: 15.5, height: 1.4),
                                  ),
                                ),
                              )
                            : Builder(builder: (context) {
                                List<RecordCard> cardList = [];
                                for (int index = 0;
                                    index < today.diaryList.length;
                                    index++) {
                                  cardList.add(RecordCard(
                                      today, today.diaryList[index], index));
                                }
                                return Column(
                                  children: cardList,
                                );
                              })
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      alignment: Alignment.center,
                      height: 45,
                      width: 45,
                      child: TextButton(
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      alignment: Alignment.center,
                      height: 45,
                      width: 45,
                      child: TextButton(
                        child: Icon(
                          CupertinoIcons.camera,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ShareHelper.saveAndShareImage(diaryKey);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                // diary - hash tags
                diary.hashtag.isNotEmpty
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.47,
                        child: Text(
                          overflow: TextOverflow.fade,
                          diary.hashtag.join(' '),
                        ))
                    : Container(),
              ],
            ),
          ]),
        ),
      ),
    );
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
