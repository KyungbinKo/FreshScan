// calender_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'database_functions.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 캘린더 컨트롤러 및 이벤트 데이터
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 날짜별 이벤트 맵 // 추후 서버에서 불러오는 형식으로 바꿔야 함
  final Map<DateTime, List<String>> _events = {
    DateTime(2024, 11, 20): ['예시1', '예시2'],
    DateTime(2024, 11, 21): ['예시3', '예시4'],
    DateTime(2024, 11, 22): ['예시5'],
  };


  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('유통기한 캘린더'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            daysOfWeekHeight: 30,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Keep focused on the new day
              });
            },
            headerStyle: HeaderStyle( // 요일 한글화
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                switch(day.weekday){
                  case 1:
                    return Center(child: Text('월'),);
                  case 2:
                    return Center(child: Text('화'),);
                  case 3:
                    return Center(child: Text('수'),);
                  case 4:
                    return Center(child: Text('목'),);
                  case 5:
                    return Center(child: Text('금'),);
                  case 6:
                    return Center(child: Text('토'),);
                  case 7:
                    return Center(child: Text('일',style: TextStyle(color: Colors.red),),);
                }
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text('Select a date to see events'))
                : ListView(
              children: _getEventsForDay(_selectedDay!).map((event) {
                return ListTile(
                  title: Text(event),
                  leading: Icon(Icons.event),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}