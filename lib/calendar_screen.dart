// calendar_screen.dart
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

  // 날짜별 이벤트 맵
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadExpirationDates();
  }

  // 유통기한 데이터를 불러와서 이벤트 맵에 저장
  Future<void> _loadExpirationDates() async {
    List<Map<String, dynamic>> expirationDates = await fetchExpirationDates();

    setState(() {
      _events = {};
      for (var item in expirationDates) {
        DateTime expirationDate = DateTime.parse(item['expirationDate']);
        if (_events[expirationDate] == null) {
          _events[expirationDate] = [];
        }
        _events[expirationDate]?.add(item['name']);
      }
    });
  }

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
