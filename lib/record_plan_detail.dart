import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/domain/diary.dart';
import 'package:plango/domain/schedule.dart';
import 'package:plango/share_view/diary_detail_share_view.dart';
import 'package:plango/main.dart' as main;
import 'package:plango/record_plan.dart' as recordPlan;

import 'domain/day.dart';

// 이미지 등록 시 일기 보존을 위한 클래스
class TempDiaryBody {
  static String value = "";
}

class RecordPlanDetail extends StatelessWidget {
  Day today;
  Diary diary;
  Schedule schedule;

  RecordPlanDetail(this.today, this.diary, this.schedule, {super.key}) {
    // 로딩 시 기존 일기 로딩
    if (TempDiaryBody.value.isEmpty) {
      TempDiaryBody.value = diary.body;
    }
    diaryBodyTextController.text = TempDiaryBody.value;
  }

  TextEditingController diaryBodyTextController = TextEditingController();
  FocusNode diaryBodyFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          diaryBodyFocusNode.unfocus();
        },
        child: main.BackImageContainer(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      if (TempDiaryBody.value != diary.body) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text("수정 사항이 존재합니다."),
                                content: Text("정말 나가시겠습니까?"),
                                actions: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(Icons.close, size: 15),
                                    label: Text(
                                      "머무르기",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // temp 일기 객체 초기화
                                      TempDiaryBody.value = "";
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(Icons.check, size: 15),
                                    label: Text(
                                      "나가기",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else {
                        // temp 일기 객체 초기화
                        TempDiaryBody.value = "";
                        Navigator.pop(context, true);
                      }
                    }),
                title: Text("일기 작성"),
                actions: [
                  IconButton(
                      onPressed: () async {
                        // 캡처용 화면으로 이동(키도 같이 전달), 캡처 함수 호출
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return DiaryDetailShareView(today, diary, schedule);
                        }));
                      },
                      icon: Icon(CupertinoIcons.share))
                ]),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 30.0),
                      child: Text(
                        recordPlan.dayService.getFormattedDateString(today),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 5.0),
                      child: Text(
                        schedule.storeName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Center(
                        child: recordPlan.DiaryImageLoader(
                            today, diary, 0.85, 0.31)),
                    diary.imageUrl.isEmpty
                        ? SizedBox(height: 5.0)
                        : Container(),
                    diary.imageUrl.isEmpty
                        ? Center(child: Text('클릭하면 이미지를 등록할 수 있습니다.'))
                        : Container(),
                    SizedBox(height: 30.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextField(
                        onChanged: (value) {
                          TempDiaryBody.value = value;
                        },
                        controller: diaryBodyTextController,
                        focusNode: diaryBodyFocusNode,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration:
                            InputDecoration(hintText: "이곳을 눌러 일기를 작성해주세요."),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: [
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            recordPlan.dayService.updateDiaryBody(
                                today, diary.id, diaryBodyTextController.text);
                          },
                          icon: Icon(Icons.save, size: 15),
                          label: Text(
                            "저장",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        SizedBox(width: 30.0),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
