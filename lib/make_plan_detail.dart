import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plango/main.dart';
import 'package:plango/repository/day_service.dart';
import 'domain/day.dart';
import 'domain/schedule.dart';
import 'lib/search_lib.dart';

class MakePlanDetail extends StatelessWidget {
  Day day;
  Schedule? schedule;
  DayService dayService;

  MakePlanDetail(this.day, this.schedule, this.dayService, {super.key});

  @override
  Widget build(BuildContext context) {
    return BackImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('장소 검색'),
        ),
        body: MakePlanDetailBody(day, schedule, dayService),
      ),
    );
  }
}

class MakePlanDetailBody extends StatefulWidget {
  Day day;
  Schedule? schedule;
  DayService dayService;

  MakePlanDetailBody(this.day, this.schedule, this.dayService, {super.key});

  @override
  State<MakePlanDetailBody> createState() => _MakePlanDetailBodyState();
}

class _MakePlanDetailBodyState extends State<MakePlanDetailBody> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  List<SearchResult> searchResultList = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocus,
                    decoration: InputDecoration(
                        hintText: "검색할 장소를 입력하세요.", labelText: "장소 검색"),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    searchResultList = await SearchHelper.searchAddress(
                        searchController.text, false);
                    searchFocus.unfocus();
                    setState(() {});
                  },
                  icon: Icon(Icons.search, size: 15),
                  label: Text(
                    "검색",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: searchResultList.length,
                  itemBuilder: (BuildContext context, int index) {
                    // 지도 검색 결과 출력
                    return Card(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.63,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      overflow: TextOverflow.fade,
                                      searchResultList[index].placeName,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        searchResultList[index].roadAddressName,
                                        overflow: TextOverflow.fade),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              SearchResult curSearchResult =
                                  searchResultList[index];
                              String imagePath =
                                  await SearchHelper.getStaticMap(
                                      curSearchResult.x, curSearchResult.y);
                              // ignore: use_build_context_synchronously
                              ImageDialog(
                                  widget.day,
                                  widget.schedule,
                                  curSearchResult,
                                  imagePath,
                                  widget.dayService,
                                  context);
                            },
                            child: Text(
                              "선택",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ));
                  }),
            ),
          ]),
        ),
      ),
    );
  }
}

Future<dynamic> ImageDialog(
    Day day,
    Schedule? schedule,
    SearchResult searchResult,
    String imagePath,
    DayService dayService,
    BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text("이 장소로 등록할까요?"),
          content: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.file(File(imagePath)),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "취소",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  // 이미지 불러오기
                  String imageUrl = await SearchHelper.getImageOfStore(
                      searchResult.placeName);

                  // 일정 등록
                  if (schedule == null) {
                    // 새로운 일정 등록
                    dayService.createScheduleAndDiary(day, imageUrl,
                        searchResult.placeName, searchResult.placeUrl);
                  } else {
                    dayService.updateSchedule(day, schedule.id, imageUrl,
                        searchResult.placeName, searchResult.placeUrl);
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "선택",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        );
      });
}
