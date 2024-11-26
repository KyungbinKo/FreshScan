#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <winhttp.h>
#include <stdio.h>
#include <string.h>
#include <wchar.h>

#pragma comment(lib, "winhttp.lib")

void ConvertToUTF8(const wchar_t* wstr, char* utf8str, int utf8str_size) {
    WideCharToMultiByte(CP_UTF8, 0, wstr, -1, utf8str, utf8str_size, NULL, NULL);
}

const char* ExtractContent(const char* response) {
    const char* key = "\"content\": \"";
    const char* startPos = strstr(response, key);
    if (startPos) {
        startPos += strlen(key);
        const char* endPos = strchr(startPos, '\"');
        if (endPos) {
            static char content[4096];
            strncpy(content, startPos, endPos - startPos);
            content[endPos - startPos] = '\0';
            return content;
        }
    }
    return "";
}

int main() {
    // 콘솔 출력을 UTF-8로 설정
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

    // JSON 요청 바디 구성
    const char* requestBody =
        "{\"model\": \"gpt-4o\",\"messages\": [{\"role\": \"user\",\"content\": \"Let me know Expiration days and Often good after of {Kirkland greek yogurt, beef, bread,  Seoul Milk butter, cheese} following instruction:\\nInstruction:\\n- Dates are based on Korea.\\n- Unit: days\\n- store Expiration days in {expiration}\\n- store Often good after in {Often good after + expiration}\\noutput format:\\nExpiration: {expiration}\\nOften good after: {Often good after}\"}],\"temperature\": 0.0,\"top_p\": 1.0, \"frequency_penalty\": 0.0}";

    // 헤더 설정
    wchar_t headers[1024];
    swprintf(headers, sizeof(headers) / sizeof(wchar_t), L"Content-Type: application/json\r\nAuthorization: Bearer %s", apiKey);

    BOOL bResults = WinHttpSendRequest(hRequest,
        headers,
        -1,
        (LPVOID)requestBody,
        strlen(requestBody),
        strlen(requestBody),
        0);
    if (!bResults) {
        printf("Error sending request.\n");
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    bResults = WinHttpReceiveResponse(hRequest, NULL);
    if (!bResults) {
        printf("Error receiving response.\n");
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

    // "content" 필드 추출 및 출력
    const char* content = ExtractContent(response);
    if (strlen(content) > 0) {
        printf("Parsed Content: %s\n", content);
    }
    else {
        printf("Content not found in response.\n");
    }

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    return 0;
}

