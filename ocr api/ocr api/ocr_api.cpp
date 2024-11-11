#include <windows.h>
#include <winhttp.h>
#include <iostream>

#pragma comment(lib, "winhttp.lib")

int main() {
    HINTERNET hSession = WinHttpOpen(L"A WinHTTP Example Program/1.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        WINHTTP_NO_PROXY_NAME,
        WINHTTP_NO_PROXY_BYPASS, 0);

    if (hSession) {
        HINTERNET hConnect = WinHttpConnect(hSession, L"naveropenapi.apigw.ntruss.com",
            INTERNET_DEFAULT_HTTPS_PORT, 0);

        if (hConnect) {
            HINTERNET hRequest = WinHttpOpenRequest(hConnect, L"POST", L"/ocr/v1/recognize",
                NULL, WINHTTP_NO_REFERER,
                WINHTTP_DEFAULT_ACCEPT_TYPES,
                WINHTTP_FLAG_SECURE);

            if (hRequest) {
                // 요청 헤더 설정
                WinHttpAddRequestHeaders(hRequest, L"Content-Type: application/json", -1, WINHTTP_ADDREQ_FLAG_ADD);
                WinHttpAddRequestHeaders(hRequest, L"X-OCR-SECRET: Q2hGamNTQU1FQ1BZdlpDV3FneUtPbG5FdVBpcHBwSkw=", -1, WINHTTP_ADDREQ_FLAG_ADD);

                // 요청 바디 설정 (JSON 데이터)
                const char* postData = R"({
                    "version" : "V2",
                    "requestId" : "1234",
                    "timestamp" : 0,
                    "lang" : "ko",
                    "images" : [
                {
                    "format": "jpeg",
                    "name" : "demo_2",
                    "url" : "https://storage.cloud.google.com/ocr_scan_images/text.jpeg"
                }
                    ] ,
                    "enableTableDetection": false
                })";
                DWORD postDataLength = strlen(postData);

                // 요청 보내기
                BOOL bResults = WinHttpSendRequest(hRequest,
                    WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                    (LPVOID)postData, postDataLength,
                    postDataLength, 0);

                if (bResults) {
                    if (WinHttpReceiveResponse(hRequest, NULL)) {
                        DWORD dwSize = 0;
                        DWORD dwDownloaded = 0;
                        LPSTR pszOutBuffer;

                        // 사용 가능한 데이터 크기를 확인합니다.
                        do {
                            dwSize = 0;
                            if (WinHttpQueryDataAvailable(hRequest, &dwSize)) {
                                pszOutBuffer = new char[dwSize + 1];
                                if (pszOutBuffer) {
                                    ZeroMemory(pszOutBuffer, dwSize + 1);

                                    if (WinHttpReadData(hRequest, (LPVOID)pszOutBuffer, dwSize, &dwDownloaded)) {
                                        // 응답 데이터를 출력하거나 저장합니다.
                                        std::cout << pszOutBuffer << std::endl;
                                    }
                                    delete[] pszOutBuffer;
                                }
                            }
                        } while (dwSize > 0);
                    }
                    else {
                        std::cerr << "응답 수신 실패" << std::endl;
                    }
                }
                else {
                    std::cerr << "요청 실패" << std::endl;
                }

                WinHttpCloseHandle(hRequest);
            }

            WinHttpCloseHandle(hConnect);
        }

        WinHttpCloseHandle(hSession);
    }

    return 0;
}



