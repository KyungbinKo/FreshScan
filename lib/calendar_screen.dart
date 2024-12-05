// By 고경빈, 한창호

// calendar_screen.dart
import 'package:flutter/material.dart'; // Flutter UI 관련 패키지
import 'package:table_calendar/table_calendar.dart'; // TableCalendar 패키지
import 'database_functions.dart'; // 데이터베이스 관련 함수 파일

// 캘린더 화면 위젯 정의
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState(); // 상태 클래스 생성
}

// 캘린더 상태 클래스
class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now(); // 현재 포커스된 날짜 (초기값: 오늘)
  DateTime? _selectedDay; // 사용자가 선택한 날짜 (초기값: null)

  Map<DateTime, List<String>> _events = {}; // 날짜별 이벤트 데이터 저장

  @override
  void initState() {
    super.initState(); // 부모 클래스의 초기화 호출
    _loadExpirationDates(); // 유통기한 데이터를 로드하는 함수 호출
  }

  // 데이터베이스에서 유통기한 데이터를 가져와 _events 맵에 저장
  Future<void> _loadExpirationDates() async {
    List<Map<String, dynamic>> expirationDates = await fetchExpirationDates(); // 유통기한 데이터 가져오기

    setState(() {
      _events = {}; // 기존 이벤트 초기화
      for (var item in expirationDates) { // 데이터베이스에서 가져온 각 항목 반복
        DateTime expirationDate = DateTime.parse(item['expirationDate']); // 유통기한 날짜 파싱
        if (_events[expirationDate] == null) { // 해당 날짜에 이벤트가 없으면
          _events[expirationDate] = []; // 빈 리스트로 초기화
        }
        _events[expirationDate]?.add(item['name']); // 날짜에 해당하는 아이템 이름 추가
      }
    });
  }

  // 특정 날짜에 해당하는 이벤트 리스트 반환
  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? []; // 이벤트가 없으면 빈 리스트 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // 화면 구조를 정의하는 Scaffold 위젯
      appBar: AppBar(
        title: Text('유통기한 캘린더'), // 화면 상단 제목
        centerTitle: false, // 제목을 왼쪽 정렬
      ),
      body: Column( // 세로로 위젯을 배치
        children: [
          TableCalendar( // 캘린더 위젯
            focusedDay: _focusedDay, // 현재 포커스된 날짜
            firstDay: DateTime(2020), // 캘린더 시작 날짜
            lastDay: DateTime(2030), // 캘린더 종료 날짜
            daysOfWeekHeight: 30, // 요일 높이 조정
            eventLoader: _getEventsForDay, // 날짜별 이벤트 로더 설정
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day); // 선택된 날짜와 같은지 확인
            },
            onDaySelected: (selectedDay, focusedDay) { // 날짜 선택 시 호출
              setState(() {
                _selectedDay = selectedDay; // 선택된 날짜 업데이트
                _focusedDay = focusedDay; // 포커스 날짜 업데이트
              });
            },
            headerStyle: HeaderStyle( // 캘린더 헤더 스타일
              formatButtonVisible: false, // 날짜 형식 버튼 숨기기
              titleCentered: true, // 제목 중앙 정렬
            ),
            calendarStyle: CalendarStyle( // 캘린더 날짜 스타일
              selectedDecoration: BoxDecoration( // 선택된 날짜 스타일
                color: Colors.blue, // 파란색 배경
                shape: BoxShape.circle, // 원형 모양
              ),
              todayDecoration: BoxDecoration( // 오늘 날짜 스타일
                color: Colors.orange, // 주황색 배경
                shape: BoxShape.circle, // 원형 모양
              ),
              markerDecoration: BoxDecoration( // 이벤트 마커 스타일
                color: Colors.green, // 녹색 배경
                shape: BoxShape.circle, // 원형 모양
              ),
            ),
          ),
          const SizedBox(height: 16), // 캘린더와 리스트뷰 사이 간격
          Expanded( // 남은 공간에 이벤트 리스트뷰 배치
            child: _selectedDay == null // 선택된 날짜가 없으면
                ? Center(child: Text('Select a date to see events')) // 안내 메시지 표시
                : ListView( // 선택된 날짜의 이벤트 리스트뷰
              children: _getEventsForDay(_selectedDay!).map((event) { // 각 이벤트 반복
                return ListTile( // 이벤트 항목 표시
                  title: Text(event), // 이벤트 이름
                  leading: Icon(Icons.event), // 이벤트 아이콘
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
