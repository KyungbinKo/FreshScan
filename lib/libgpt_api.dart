import 'dart:ffi';
import 'package:ffi/ffi.dart';

class GPTAPI {
  final DynamicLibrary _lib;

  GPTAPI(this._lib);

  // C 함수 호출을 위한 Dart 함수 정의
  // 예시: C 함수가 "get_breakfast_recipes"라는 함수로 결과를 반환한다고 가정
  // C 함수의 반환값을 받는 함수 예시
  Pointer<Utf8> getBreakfastRecipes() {
    final getRecipes = _lib.lookupFunction<
        Pointer<Utf8> Function(),
        Pointer<Utf8> Function()>('get_breakfast_recipes');
    return getRecipes();
  }
}
