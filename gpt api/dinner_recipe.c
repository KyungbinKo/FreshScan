#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <winhttp.h>
#include <stdio.h>
#include <string.h>

#pragma comment(lib, "winhttp.lib")

int main() {
    // 콘솔, 출력을 UTF-8로 설정
    SetConsoleCP(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);

    const wchar_t* apiKey = L"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";
    const wchar_t* openAiEndpoint = L"api.openai.com";
    const wchar_t* apiUrl = L"/v1/chat/completions";

    HINTERNET hSession = WinHttpOpen(L"ChatGPT API Client/1.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        WINHTTP_NO_PROXY_NAME,
        WINHTTP_NO_PROXY_BYPASS, 0);
    if (!hSession) {
        printf("Error opening session.\n");
        return 1;
    }

    HINTERNET hConnect = WinHttpConnect(hSession, openAiEndpoint, INTERNET_DEFAULT_HTTPS_PORT, 0);
    if (!hConnect) {
        printf("Error connecting to server.\n");
        WinHttpCloseHandle(hSession);
        return 1;
    }

    HINTERNET hRequest = WinHttpOpenRequest(hConnect, L"POST", apiUrl,
        NULL, WINHTTP_NO_REFERER,
        WINHTTP_DEFAULT_ACCEPT_TYPES,
        WINHTTP_FLAG_SECURE);
    if (!hRequest) {
        printf("Error opening request.\n");
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    // 입력 받기
    char ingredients[1024];
    fgets(ingredients, sizeof(ingredients), stdin);
    ingredients[strcspn(ingredients, "\n")] = 0;  // 개행 문자 제거

    // 멀티바이트 문자열을 유니코드 문자열로 변환
    wchar_t ingredientsW[1024];
    MultiByteToWideChar(CP_UTF8, 0, ingredients, -1, ingredientsW, sizeof(ingredientsW) / sizeof(wchar_t));

    // JSON 요청 바디 구성
    wchar_t requestBodyW[1024];
    swprintf(requestBodyW, sizeof(requestBodyW) / sizeof(wchar_t),
        L"{\"model\": \"gpt-4o\", \"messages\": [{\"role\": \"user\", \"content\": \"Recommend 3 dinner recipes using some of the following ingredients: %ls. Output language: Korean. The answer should follow only a set format. The format: {1. recipe name 2. recipe 3. required time: (required time)}.\"}], \"temperature\": 1.0, \"top_p\": 0.2, \"frequency_penalty\": 0.0}",
        ingredientsW);

    // UTF-8로 변환
    int utf8Len = WideCharToMultiByte(CP_UTF8, 0, requestBodyW, -1, NULL, 0, NULL, NULL);
    char* requestBody = (char*)malloc(utf8Len);
    if (!requestBody) {
        printf("Memory allocation error.\n");
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }
    WideCharToMultiByte(CP_UTF8, 0, requestBodyW, -1, requestBody, utf8Len, NULL, NULL);

    // 헤더 설정 수정
    wchar_t headers[1024];
    swprintf(headers, sizeof(headers) / sizeof(wchar_t), L"Content-Type: application/json\r\nAuthorization: Bearer %s", apiKey);

    BOOL bResults = WinHttpSendRequest(hRequest, headers, -1, (LPVOID)requestBody, utf8Len - 1, utf8Len - 1, 0);
    if (!bResults) {
        printf("Error sending request.\n");
        free(requestBody);
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    bResults = WinHttpReceiveResponse(hRequest, NULL);
    if (!bResults) {
        printf("Error receiving response.\n");
        free(requestBody);
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    // 응답 데이터 읽기
    DWORD dwSize = 0;
    DWORD dwDownloaded = 0;
    LPVOID lpOutBuffer = NULL;
    char response[4096] = "";

    do {
        dwSize = 0;
        if (!WinHttpQueryDataAvailable(hRequest, &dwSize)) {
            printf("Error querying data availability.\n");
        }

        if (dwSize > 0) {
            lpOutBuffer = malloc(dwSize + 1);
            if (!lpOutBuffer) {
                printf("Out of memory.\n");
                dwSize = 0;
            }
            else {
                ZeroMemory(lpOutBuffer, dwSize + 1);

                if (WinHttpReadData(hRequest, (LPVOID)lpOutBuffer, dwSize, &dwDownloaded)) {
                    strncat(response, (char*)lpOutBuffer, dwDownloaded);
                }
                else {
                    printf("Error reading data.\n");
                }
                free(lpOutBuffer);
            }
        }
    } while (dwSize > 0);

    // "content" 필드 추출
    char* contentStart = strstr(response, "\"content\": \"");
    if (contentStart) {
        contentStart += strlen("\"content\": \"");
        char* contentEnd = strstr(contentStart, "\"");
        if (contentEnd) {
            *contentEnd = '\0';
            printf("Content: %s\n", contentStart);
        }
        else {
            printf("Content field not properly terminated.\n");
        }
    }
    else {
        printf("Content field not found in response.\n");
    }

    // 메모리 해제 및 핸들 닫기
    free(requestBody);
    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    return 0;
}