import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:plango/main.dart';
import 'package:plango/make_plan.dart';
import 'package:plango/record_plan.dart';
import 'package:plango/repository/day_service.dart';
import 'package:plango/share_view/diary_share_view.dart';
import 'package:plango/share_view/schedule_share_view.dart';
import 'package:provider/provider.dart';

import 'domain/day.dart';

late DayService dayService;

// 기본 설정 탭
class SelectedTabIndex {
  static int value = 0;
}

class Today extends StatefulWidget {
  Day today;
  Today(this.today, {super.key});

  @override
  State<StatefulWidget> createState() => _Today();
}

class _Today extends State<Today> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return BackImageContainer(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('오늘의 계획과 기록'),
              actions: [
                IconButton(
                    onPressed: () async {
                      // 캡처용 화면으로 이동
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        if (SelectedTabIndex.value == 0) {
                          return ScheduleShareView(widget.today);
                        } else {
                          return DiaryShareView(widget.today);
                        }
                      }));
                    },
                    icon: Icon(CupertinoIcons.share))
              ],
            ),
            body: SafeArea(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayService.getFormattedDateString(widget.today),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        FlutterToggleTab(
                          width: 40,
                          borderRadius: 15,
                          selectedIndex: SelectedTabIndex.value,
                          selectedTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          unSelectedTextStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          labels: ["계획", "기록"],
                          selectedLabelIndex: (index) {
                            setState(() {
                              SelectedTabIndex.value = index;
                            });
                          },
                          marginSelected:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        ),
                      ]),
                ),
                SelectedTabIndex.value == 0
                    ? MakePlan(widget.today)
                    : RecordPlan(widget.today),
              ]),
            ),
          ),
        );
      },
    );
  }
}
