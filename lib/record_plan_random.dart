import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plango/main.dart';
import 'package:plango/repository/day_service.dart';
import 'domain/day.dart';
import 'domain/schedule.dart';
import 'lib/search_lib.dart';

RandomParameter randomParameter = RandomParameter();

class RecordPlanRandom extends StatefulWidget {
  Day day;
  Schedule? schedule;
  DayService dayService;

  RecordPlanRandom(this.day, this.schedule, this.dayService, {super.key});

  @override
  State<RecordPlanRandom> createState() => _RecordPlanRandomState();
}

class _RecordPlanRandomState extends State<RecordPlanRandom> {
  @override
  void initState() {
    randomParameter = RandomParameter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('랜덤 일정 추천'),
        ),
        body: RecordPlanRandomBody(
            widget.day, widget.schedule, widget.dayService),
      ),
    );
  }
}

class RecordPlanRandomBody extends StatefulWidget {
  Day day;
  Schedule? schedule;
  DayService dayService;

  RecordPlanRandomBody(this.day, this.schedule, this.dayService, {super.key});

  @override
  State<RecordPlanRandomBody> createState() => _RecordPlanRandomBodyState();
}

class _RecordPlanRandomBodyState extends State<RecordPlanRandomBody> {
  String placeStaticMapPath = "";
  SearchResult? searchResult = null;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        HeightSizedBox(0.05),
                        Text(
                          "추천 중심 주소 : ${randomParameter.address}\n\n추천 반경 : ${randomParameter.radius}km\n\n추천 카테고리 : ${randomParameter.categoryString}",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.0),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          HeightSizedBox(0.05),
          randomParameter.address.isEmpty
              // 1. 중심 주소 입력
              ? Column(
                  children: [
                    RandomParameterInput(1,
                        "랜덤 일정 추천은 입력한 주소를 기반으로 진행됩니다.\n\n먼저, 일정을 추천 받을 중심 주소를 검색해주세요."),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(elevation: 3.5),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddressSearchDialog();
                            });
                        setState(() {});
                      },
                      icon: Icon(CupertinoIcons.map, size: 15),
                      label: Text(
                        "중심 주소 검색",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(elevation: 3.5),
                      onPressed: () async {
                        SearchResult searchResult =
                            await SearchHelper.getCurrentLocationObject();
                        // 주소 검색 결과 입력
                        randomParameter.x = searchResult.x;
                        randomParameter.y = searchResult.y;
                        randomParameter.address = searchResult.roadAddressName;
                        setState(() {});
                      },
                      icon: Icon(CupertinoIcons.location, size: 15),
                      label: Text(
                        "현 위치 기반 검색",
                        style: TextStyle(fontSize: 13),
                      ),
                    )
                  ],
                )
              : randomParameter.radius == 0
                  // 2. 반경 입력
                  ? Column(
                      children: [
                        RandomParameterInput(
                            2, "다음으로, 선택한 주소를 중심으로\n일정을 추천받을 범위를 입력하세요."),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(elevation: 3.5),
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return RadiusSelectDialog();
                                });
                            setState(() {});
                          },
                          icon: Icon(Icons.map, size: 15),
                          label: Text(
                            "범위 입력",
                            style: TextStyle(fontSize: 13),
                          ),
                        )
                      ],
                    )
                  // 3. 카테고리 입력
                  : randomParameter.categoryString.isEmpty
                      ? Column(
                          children: [
                            RandomParameterInput(
                                3, "마지막으로, 추천받을 장소의 카테고리를 선택하세요."),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(elevation: 3.5),
                              onPressed: () async {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CategorySelectDialog();
                                    });
                                setState(() {});
                              },
                              icon: Icon(Icons.map, size: 15),
                              label: Text(
                                "카테고리 선택",
                                style: TextStyle(fontSize: 13),
                              ),
                            )
                          ],
                        )
                      // 실제 랜덤 추천 버튼
                      : Column(
                          children: [
                            searchResult != null
                                ? Column(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              searchResult!.placeName,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              searchResult!.roadAddressName,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      HeightSizedBox(0.02),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await SearchHelper.openWeb(
                                                searchResult!.placeUrl);
                                          },
                                          child: Image.file(
                                              File(placeStaticMapPath)),
                                        ),
                                      ),
                                      HeightSizedBox(0.01),
                                      Text("이미지 클릭 시 상세 페이지로 이동합니다."),
                                      HeightSizedBox(0.02),
                                    ],
                                  )
                                : Container(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                searchResult != null
                                    ? ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 3.5),
                                        onPressed: () async {
                                          // 이미지 불러오기
                                          String imageUrl = await SearchHelper
                                              .getImageOfStore(
                                                  searchResult!.placeName);

                                          // 일정 등록
                                          if (widget.schedule == null) {
                                            // 새로운 일정 등록
                                            widget.dayService
                                                .createScheduleAndDiary(
                                                    widget.day,
                                                    imageUrl,
                                                    searchResult!.placeName,
                                                    searchResult!.placeUrl);
                                          } else {
                                            widget.dayService.updateSchedule(
                                                widget.day,
                                                widget.schedule!.id,
                                                imageUrl,
                                                searchResult!.placeName,
                                                searchResult!.placeUrl);
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.check, size: 15),
                                        label: Text(
                                          "선택",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      )
                                    : Container(),
                                searchResult != null
                                    ? SizedBox(width: 10)
                                    : Container(),
                                ElevatedButton.icon(
                                  style:
                                      ElevatedButton.styleFrom(elevation: 3.5),
                                  onPressed: () async {
                                    // 1. 검색 후, 랜덤 추천
                                    // 2. 지도 이미지 검색 후 출력
                                    searchResult =
                                        await SearchHelper.getRandomPlace(
                                            randomParameter);
                                    placeStaticMapPath =
                                        await SearchHelper.getStaticMap(
                                            searchResult!.x, searchResult!.y);
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.map, size: 15),
                                  label: Text(
                                    searchResult == null
                                        ? "일정 추천 시작"
                                        : "다시 추천 받기",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
        ],
      )),
    );
  }
}

class RandomParameterInput extends StatefulWidget {
  int stepCount;
  String bodyMsg;

  RandomParameterInput(this.stepCount, this.bodyMsg, {super.key});

  @override
  State<RandomParameterInput> createState() => _RandomParameterInputState();
}

class _RandomParameterInputState extends State<RandomParameterInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Step ${widget.stepCount}",
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        HeightSizedBox(0.02),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            textAlign: TextAlign.center,
            widget.bodyMsg,
            style: TextStyle(fontSize: 17),
          ),
        ),
        HeightSizedBox(0.01),
      ],
    );
  }
}

class AddressSearchDialog extends StatefulWidget {
  AddressSearchDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  TextEditingController searchController = TextEditingController();
  List<SearchResult> searchResultList = [];
  FocusNode searchFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
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
                        searchFocus.unfocus();
                        searchResultList = await SearchHelper.searchAddress(
                            searchController.text, true);
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
                SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
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
                                    width: MediaQuery.of(context).size.width *
                                        0.37,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          overflow: TextOverflow.fade,
                                          searchResultList[index].placeName,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            overflow: TextOverflow.fade,
                                            searchResultList[index]
                                                .roadAddressName),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  // 주소 검색 결과 입력
                                  randomParameter.x = searchResultList[index].x;
                                  randomParameter.y = searchResultList[index].y;
                                  randomParameter.address =
                                      searchResultList[index].roadAddressName;
                                  setState(() {});
                                  Navigator.of(context).pop();
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RadiusSelectDialog extends StatefulWidget {
  RadiusSelectDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<RadiusSelectDialog> createState() => _RadiusSelectDialogState();
}

class _RadiusSelectDialogState extends State<RadiusSelectDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.07,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      style: TextStyle(color: Colors.black),
                      items: [for (var i = 1; i <= 20; i += 1) i]
                          .map<DropdownMenuItem<String>>((int value) {
                        return DropdownMenuItem<String>(
                          value: value.toString(),
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      hint: Text(
                        // 선택한 범위 표시
                        randomParameter.radius == 0
                            ? "범위(km)"
                            : "${randomParameter.radius.toString()}km",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onChanged: (String? value) {
                        if (value != null) {
                          randomParameter.radius = int.parse(value);
                        }
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.search, size: 15),
                      label: Text(
                        "선택",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySelectDialog extends StatefulWidget {
  CategorySelectDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<CategorySelectDialog> createState() => _CategorySelectDialogState();
}

class _CategorySelectDialogState extends State<CategorySelectDialog> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> category = {
      '식당': 'FD6',
      '카페': 'CE7',
      '관광명소': 'AT4',
      '문화시설': 'CT1',
    };
    return AlertDialog(
      scrollable: true,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.07,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      style: TextStyle(color: Colors.black),
                      items: category.keys
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: Text(
                        // 선택한 카테고리 표시
                        randomParameter.categoryString.isEmpty
                            ? "카테고리"
                            : randomParameter.categoryString,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onChanged: (String? value) {
                        if (value != null) {
                          randomParameter.categoryString = value;
                          randomParameter.categoryGroupCode = category[value]!;
                        }
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.search, size: 15),
                      label: Text(
                        "선택",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeightSizedBox extends StatelessWidget {
  double height;
  HeightSizedBox(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).size.height * height);
  }
}

class RandomParameter {
  // 검색 중심 좌표
  String x = "";
  String y = "";
  String address = "";

  // 검색 반경
  int radius = 0;

  // 검색 카테고리
  String categoryGroupCode = "";
  String categoryString = "";

  // 랜덤 검색 결과 총 item 개수
  int itemCount = 0;
}
