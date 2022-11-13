import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/domain/day.dart';
import 'package:plango/make_plan_detail.dart';
import 'package:plango/record_plan_random.dart';
import 'package:plango/repository/day_service.dart';
import 'package:provider/provider.dart';

import 'domain/schedule.dart';
import 'lib/search_lib.dart';

late DayService dayService;

// 메모 관련
List<FocusNode> memoFocuses = [];
List<TextEditingController> memoControllers = [];

class MakePlan extends StatelessWidget {
  Day today;

  MakePlan(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return MakePlanBody(today);
      },
    );
  }
}

class MakePlanBody extends StatelessWidget {
  Day today;
  MakePlanBody(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        for (int i = 0; i < memoFocuses.length; i++) {
          memoFocuses[i].unfocus();
        }
      },
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.73,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: today.scheduleList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    // 포커스 노드 생성
                    memoFocuses.insert(index, FocusNode());
                    // 메모 컨트롤러 생성
                    memoControllers.insert(index, TextEditingController());
                    // 오늘 (Day)의 Schedule 아이템을 하나씩 전달
                    if (index == today.scheduleList.length) {
                      // 마지막 새로운 계획 Card
                      return NewPlanButton(today);
                    } else {
                      return RecordCard(
                          today, today.scheduleList[index], index);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class NewPlanButton extends StatelessWidget {
  Day today;
  NewPlanButton(this.today, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(elevation: 3.5),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          // 새로운 계획, Schedule은 null로 전달
                          builder: (context) =>
                              MakePlanDetail(today, null, dayService)));
                },
                icon: Icon(Icons.add, size: 15),
                label: Text(
                  "새로운 계획",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(elevation: 3.5),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          // 새로운 계획, Schedule은 null로 전달
                          builder: (context) =>
                              RecordPlanRandom(today, null, dayService)));
                },
                icon: Icon(Icons.add, size: 15),
                label: Text(
                  "랜덤",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
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
                      width: MediaQuery.of(context).size.width * 0.28,
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
                          CupertinoIcons.link,
                          size: 15,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          // 일정 자세히 보기 이벤트
                          await SearchHelper.openWeb(schedule.detailUrl);
                        },
                      ),
                    ),
                    PopupMenuButton(
                        onSelected: (value) => {
                              if (value == 1)
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MakePlanDetail(
                                              today, schedule, dayService)))
                                }
                              else if (value == 2)
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecordPlanRandom(
                                                  today, schedule, dayService)))
                                }
                              else
                                // 삭제
                                {
                                  dayService.deleteScheduleAndDiary(
                                      today, schedule.id)
                                }
                            },
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                // 일정 수정 이벤트
                                child: Text("수정"),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text("랜덤 추천"),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Text("삭제"),
                              ),
                            ])
                  ],
                ),
                // todo 메모 기능
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Focus(
                    focusNode: memoFocuses[index],
                    onFocusChange: (hasFocus) {
                      // focus out 시 메모 저장
                      if (!hasFocus) {
                        dayService.updateScheduleMemo(
                            today, schedule.id, memoControllers[index].text);
                      }
                    },
                    child: TextField(
                      maxLines: null,
                      controller: memoControllers[index],
                      decoration: InputDecoration(hintText: "간단 메모"),
                    ),
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
