import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:plango/domain/day.dart';
import 'package:plango/repository/day_service.dart';
import 'package:plango/today.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

late DayService dayService;

void main() async {
  await Hive.initFlutter;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => DayService()),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayService>(
      builder: (context, _dayService, child) {
        dayService = _dayService;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // 캘린더 국제화를 위한 정보들
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('ko', 'KR'),
          ],
          theme: ThemeData(
            primarySwatch: Colors.brown,
          ),
          home: const Main(),
        );
      },
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Day? selectedDayObject = null;

  @override
  Widget build(BuildContext context) {
    return BackImageContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            '플랭고',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              TableCalendar(
                // 오늘 & 선택 날짜의 마커 color 변경
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(150, 121, 85, 72),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.brown,
                    shape: BoxShape.circle,
                  ),
                ),
                locale: 'ko_KR',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: _focusedDay,
                availableCalendarFormats: {CalendarFormat.month: 'Month'},
                // calendar events
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;

                    // dayService에서 day 객체 찾아오기 (nullable)
                    selectedDayObject = dayService.findDay(_selectedDay);
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  // 해당 날짜에 Schedule 정보가 하나 이상 존재하면 이벤트 표시
                  if (dayService.findDay(day)?.scheduleList != null &&
                      dayService.findDay(day)!.scheduleList.isNotEmpty) {
                    return List.filled(1, "");
                  }
                  return List.empty();
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이날의 일정 : ${selectedDayObject != null ? selectedDayObject!.scheduleList.length : '0'}개',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // 선택한 날짜에 해당하는 Day 객체가 존재하지 않는 경우 새롭게 생성
                        // ignore: prefer_conditional_assignment
                        if (selectedDayObject == null) {
                          selectedDayObject =
                              dayService.createDay(_selectedDay);
                        }
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Today(selectedDayObject!)));
                        // 계획, 기록 탭 초기화
                        SelectedTabIndex.value = 0;
                        setState(() {});
                      },
                      icon: Icon(CupertinoIcons.pen, size: 15),
                      label: Text(
                        "계획 및 기록",
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackImageContainer extends Container {
  BackImageContainer({super.key, super.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/background.jpg"), fit: BoxFit.cover),
      ),
      child: child,
    );
  }
}
