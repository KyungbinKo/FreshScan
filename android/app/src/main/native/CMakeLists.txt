cmake_minimum_required(VERSION 3.4.1)

# SQLite 관련 파일 추가
add_library(sqlite3 STATIC sqlite3.c)

# 사용자 정의 C 파일 추가
add_library(database SHARED database.c)

# Include libraries needed for JNI
find_library(
        log-lib
        log
)
# SQLite와 연결
target_include_directories(database PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(database sqlite3 log)
