import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/domain/day.dart';
import 'package:plango/domain/diary.dart';
import 'package:plango/domain/schedule.dart';
import 'package:plango/main.dart';
import 'package:plango/record_plan.dart';
import 'package:plango/repository/day_service.dart';
import 'package:plango/share_view/share_helper.dart';
import 'package:provider/provider.dart';

late DayService dayService;
TextEditingController diaryBodyTextController = TextEditingController();
GlobalKey diaryDetailKey = GlobalKey();

class DiaryDetailShareView extends StatelessWidget {
  Day today;
  Diary diary;
  Schedule schedule;
  DiaryDetailShareView(this.today, this.diary, this.schedule, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return Scaffold(
          body: DiaryDetailShareViewBody(today, diary, schedule),
        );
      },
    );
  }
}

class DiaryDetailShareViewBody extends StatelessWidget {
  Day today;
  Diary diary;
  Schedule schedule;
  DiaryDetailShareViewBody(this.today, this.diary, this.schedule, {super.key}) {
    diaryBodyTextController.text = diary.body;
  }

  @override
  Widget build(BuildContext context) {
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
                  key: diaryDetailKey,
                  child: BackImageContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 30.0),
                          child: Text(
                            dayService.getFormattedDateString(today),
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
                        diary.imageUrl.isNotEmpty
                            ? Column(
                                children: [
                                  SizedBox(height: 15.0),
                                  Center(
                                      child: DiaryImageLoader(
                                          today, diary, 0.85, 0.31)),
                                ],
                              )
                            : Container(),
                        SizedBox(height: 30.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextField(
                            decoration:
                                InputDecoration(border: InputBorder.none),
                            controller: diaryBodyTextController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                        ),
                        SizedBox(height: 30),
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
                          ShareHelper.saveAndShareImage(diaryDetailKey);
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
