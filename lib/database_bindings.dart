// By 고경빈

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// C 라이브러리 로드
final DynamicLibrary dbLib = DynamicLibrary.open('libdatabase.so');

// C 함수 정의

// 데이터베이스 초기화 함수
typedef InitDbNative = Int32 Function(Pointer<Utf8> dbPath);
typedef InitDb = int Function(Pointer<Utf8> dbPath);

// 데이터베이스 종료 함수
typedef CloseDbNative = Void Function();
typedef CloseDb = void Function();

// 데이터 추가 함수
typedef AddItemNative = Int32 Function(
    Pointer<Utf8> name, Pointer<Utf8> purchaseDate, Pointer<Utf8> expirationDate);
typedef AddItem = int Function(
    Pointer<Utf8> name, Pointer<Utf8> purchaseDate, Pointer<Utf8> expirationDate);

// 데이터 가져오기 함수
typedef FetchItemsNative = Pointer<Utf8> Function();
typedef FetchItems = Pointer<Utf8> Function();

// C 함수와 연결
final InitDb initDb = dbLib
    .lookup<NativeFunction<InitDbNative>>('Java_com_example_fcheck_Database_initDb')
    .asFunction();

final CloseDb closeDb = dbLib
    .lookup<NativeFunction<CloseDbNative>>('Java_com_example_fcheck_Database_closeDb')
    .asFunction();

final AddItem addItem = dbLib
    .lookup<NativeFunction<AddItemNative>>('Java_com_example_fcheck_Database_addItem')
    .asFunction();

final FetchItems fetchItems = dbLib
    .lookup<NativeFunction<FetchItemsNative>>('Java_com_example_fcheck_Database_fetchItems')
    .asFunction();
