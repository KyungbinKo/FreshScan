// By 고경빈
#include <sqlite3.h>
#include <jni.h>
#include <stdio.h>
#include <stdlib.h>

// 데이터베이스 핸들러
sqlite3 *db;

// 데이터베이스 초기화 함수 (JNI)
JNIEXPORT jint JNICALL
Java_com_example_fcheck_Database_initDb(JNIEnv *env, jobject obj, jstring dbPath) {
    const char *path = (*env)->GetStringUTFChars(env, dbPath, 0);
    int result = sqlite3_open(path, &db);
    (*env)->ReleaseStringUTFChars(env, dbPath, path);
    return result == SQLITE_OK ? 0 : 1; // 0: 성공, 1: 실패
}

// 데이터베이스 종료 함수 (JNI)
JNIEXPORT void JNICALL
Java_com_example_fcheck_Database_closeDb(JNIEnv *env, jobject obj) {
if (db) {
sqlite3_close(db);
db = NULL;
}
}

// 데이터 추가 함수 (JNI)
JNIEXPORT jint JNICALL
Java_com_example_fcheck_Database_addItem(JNIEnv *env, jobject obj,
                                         jstring name, jstring purchaseDate, jstring expirationDate) {
    const char *sql = "INSERT INTO items (name, purchaseDate, expirationDate) VALUES (?, ?, ?)";
    sqlite3_stmt *stmt;
    const char *cName = (*env)->GetStringUTFChars(env, name, 0);
    const char *cPurchaseDate = (*env)->GetStringUTFChars(env, purchaseDate, 0);
    const char *cExpirationDate = (*env)->GetStringUTFChars(env, expirationDate, 0);

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        return 1; // SQL 준비 실패
    }

    sqlite3_bind_text(stmt, 1, cName, -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 2, cPurchaseDate, -1, SQLITE_STATIC);
    sqlite3_bind_text(stmt, 3, cExpirationDate, -1, SQLITE_STATIC);

    int rc = sqlite3_step(stmt);
    sqlite3_finalize(stmt);

    (*env)->ReleaseStringUTFChars(env, name, cName);
    (*env)->ReleaseStringUTFChars(env, purchaseDate, cPurchaseDate);
    (*env)->ReleaseStringUTFChars(env, expirationDate, cExpirationDate);

    return rc == SQLITE_DONE ? 0 : 1; // 0: 성공, 1: 실패
}

// 데이터 읽기 함수 (JNI)
JNIEXPORT jstring JNICALL
Java_com_example_fcheck_Database_fetchItems(JNIEnv *env, jobject obj) {
    const char *sql = "SELECT * FROM items";
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        return (*env)->NewStringUTF(env, "Error preparing SQL");
    }

    char buffer[1024] = {0}; // 데이터 읽기를 위한 버퍼
    int offset = 0;

    // 데이터를 하나씩 읽으면서 버퍼에 저장
    while (sqlite3_step(stmt) == SQLITE_ROW && offset < sizeof(buffer) - 1) {
        const char *name = (const char *)sqlite3_column_text(stmt, 1);
        const char *purchaseDate = (const char *)sqlite3_column_text(stmt, 2);
        const char *expirationDate = (const char *)sqlite3_column_text(stmt, 3);

        // NULL 체크 추가 및 데이터 읽기
        if (name && purchaseDate && expirationDate) {
            offset += snprintf(buffer + offset, sizeof(buffer) - offset,
                               "%s,%s,%s\n", name, purchaseDate, expirationDate);
        } else {
            // NULL 값이 있는 경우 오류 메시지 반환
            snprintf(buffer + offset, sizeof(buffer) - offset, "Error: One or more fields are NULL.\n");
            break;
        }
    }

    sqlite3_finalize(stmt);

    // 데이터가 없을 경우 처리
    if (offset == 0) {
        return (*env)->NewStringUTF(env, "No items found");
    }

    return (*env)->NewStringUTF(env, buffer);
}
