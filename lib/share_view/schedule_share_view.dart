import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/domain/day.dart';
import 'package:plango/domain/schedule.dart';
import 'package:plango/main.dart';
import 'package:plango/repository/day_service.dart';
import 'package:plango/share_view/share_helper.dart';
import 'package:provider/provider.dart';

late DayService dayService;
List<TextEditingController> memoControllers = [];
GlobalKey scheduleKey = GlobalKey();

class ScheduleShareView extends StatelessWidget {
  Day today;
  ScheduleShareView(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return Scaffold(
          body: ScheduleShareViewBody(today),
        );
      },
    );
  }
}

class ScheduleShareViewBody extends StatelessWidget {
  Day today;
  ScheduleShareViewBody(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    // DayService에서 불러온 오늘에 해당하는 Day 객체

    return Center(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: Colors.grey[50]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RepaintBoundary(
                  key: scheduleKey,
                  child: BackImageContainer(child: Center(
                    child: Builder(builder: (context) {
                      List<RecordCard> cardList = [];
                      for (int index = 0;
                          index < today.scheduleList.length;
                          index++) {
                        memoControllers.insert(index, TextEditingController());
                        cardList.add(RecordCard(
                            today, today.scheduleList[index], index));
                      }
                      return Column(
                        children: cardList,
                      );
                    }),
                  )),
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
                          ShareHelper.saveAndShareImage(scheduleKey);
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
  Schedule schedule;
  int index;

  RecordCard(this.today, this.schedule, this.index, {super.key}) {
    // 기존 메모 불러오기
    memoControllers[index].text = today.findScheduleById(schedule.id).memo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 3.5,
        child: Padding(
          padding: EdgeInsets.only(top: 14.0, bottom: 14.0, left: 8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
            SizedBox(width: 5),
            ScheduleImage(today, schedule, 0.32, 0.11),
            SizedBox(width: 13.0),
            // 계획 제목 시작
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Text(
                        // schedule - store name
                        overflow: TextOverflow.fade,
                        schedule.storeName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // todo 메모 기능
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextField(
                    maxLines: null,
                    controller: memoControllers[index],
                    decoration: InputDecoration(
                        hintText: "간단 메모", border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class ScheduleImage extends StatelessWidget {
  Day today;
  Schedule schedule;
  double width;
  double height;

  ScheduleImage(this.today, this.schedule, this.width, this.height,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        // 이미지 url 없을 경우 기본 이미지 출력
        schedule.imageUrl == ""
            ? 'http://www.mth.co.kr/wp-content/uploads/2014/12/default-placeholder.png'
            : schedule.imageUrl,
        width: MediaQuery.of(context).size.width * width,
        height: MediaQuery.of(context).size.height * height,
        fit: BoxFit.cover,
      ),
    );
  }
}
