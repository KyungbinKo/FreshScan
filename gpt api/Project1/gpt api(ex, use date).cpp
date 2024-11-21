#include <windows.h>
#include <winhttp.h>
#include <iostream>
#include <string>
#include <codecvt>

#pragma comment(lib, "winhttp.lib")

std::wstring ConvertToWString(const std::string& str) {
    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    return converter.from_bytes(str);
}

std::string ConvertToUTF8(const std::wstring& wstr) {
    std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
    return converter.to_bytes(wstr);
}

std::string ExtractContent(const std::string& response) {
    const std::string key = "\"content\": \"";
    size_t startPos = response.find(key);
    if (startPos != std::string::npos) {
        startPos += key.length();
        size_t endPos = response.find("\"", startPos);
        if (endPos != std::string::npos) {
            return response.substr(startPos, endPos - startPos);
        }
    }
    return "";
}

int main() {
    // Set console output to UTF-8
    SetConsoleOutputCP(CP_UTF8);

    const std::wstring apiKey = L"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";
    const std::wstring openAiEndpoint = L"api.openai.com";
    const std::wstring apiUrl = L"/v1/chat/completions";

    HINTERNET hSession = WinHttpOpen(L"ChatGPT API Client/1.0",
        WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
        WINHTTP_NO_PROXY_NAME,
        WINHTTP_NO_PROXY_BYPASS, 0);
    if (!hSession) {
        std::cerr << "Error opening session." << std::endl;
        return 1;
    }

    HINTERNET hConnect = WinHttpConnect(hSession, openAiEndpoint.c_str(), INTERNET_DEFAULT_HTTPS_PORT, 0);
    if (!hConnect) {
        std::cerr << "Error connecting to server." << std::endl;
        WinHttpCloseHandle(hSession);
        return 1;
    }

    HINTERNET hRequest = WinHttpOpenRequest(hConnect, L"POST", apiUrl.c_str(),
        NULL, WINHTTP_NO_REFERER,
        WINHTTP_DEFAULT_ACCEPT_TYPES,
        WINHTTP_FLAG_SECURE);
    if (!hRequest) {
        std::cerr << "Error opening request." << std::endl;
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    // JSON 요청 바디 구성
    std::string requestBody;


    requestBody = R"({"model": "gpt-4o", "messages": [{"role": "user", "content": "Search expiration date and use-by date of following groceries (yogurt, beef, bread, milk, butter). Template: {1.cheese: {expiration date: xxdays, use-by date: xxdays}, 2.beef: {expiration date: xxdays, use-by date: xxdays}, milk: {expiration date: xxdays, use-by date: xxdays}, source: {used official source or food safety authorities} Do not include any disclaimers, warnings, or general suggestions about where to look for more information. use by dates indicate when a product may no longer be safe to eat and normally they are longer than expiration date. Answer using Korean. If possible, base your answer only on official food safety sources such as FSA"}], "temperature": 0.3, "top_p": 0.5})";

    // 헤더 설정
    std::wstring headers = L"Content-Type: application/json\r\nAuthorization: Bearer " + apiKey;

    BOOL bResults = WinHttpSendRequest(hRequest,
        headers.c_str(),
        -1,
        (LPVOID)requestBody.c_str(),
        requestBody.length(),
        requestBody.length(),
        0);
    if (!bResults) {
        std::cerr << "Error sending request." << std::endl;
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    bResults = WinHttpReceiveResponse(hRequest, NULL);
    if (!bResults) {
        std::cerr << "Error receiving response." << std::endl;
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return 1;
    }

    // Read the response data
    DWORD dwSize = 0;
    DWORD dwDownloaded = 0;
    LPVOID lpOutBuffer = NULL;
    std::wstring responseW;

    do {
        dwSize = 0;
        if (!WinHttpQueryDataAvailable(hRequest, &dwSize)) {
            std::cerr << "Error querying data availability." << std::endl;
        }

        if (dwSize > 0) {
            lpOutBuffer = new char[dwSize + 1];
            if (!lpOutBuffer) {
                std::cerr << "Out of memory." << std::endl;
                dwSize = 0;
            }
            else {
                ZeroMemory(lpOutBuffer, dwSize + 1);

                if (WinHttpReadData(hRequest, (LPVOID)lpOutBuffer, dwSize, &dwDownloaded)) {
                    // Append data to wstring buffer after converting from multi-byte to wide-char
                    int len = MultiByteToWideChar(CP_UTF8, 0, (char*)lpOutBuffer, dwDownloaded, NULL, 0);
                    if (len > 0) {
                        wchar_t* wstr = new wchar_t[len + 1];
                        MultiByteToWideChar(CP_UTF8, 0, (char*)lpOutBuffer, dwDownloaded, wstr, len);
                        wstr[len] = L'\0';
                        responseW.append(wstr);
                        delete[] wstr;
                    }
                }
                else {
                    std::cerr << "Error reading data." << std::endl;
                }
                delete[] lpOutBuffer;
            }
        }
    } while (dwSize > 0);

    // Convert to UTF-8 and parse to extract "content"
    std::string responseUTF8 = ConvertToUTF8(responseW);
    std::string content = ExtractContent(responseUTF8);

    // Print the extracted content
    if (!content.empty()) {
        std::cout << "Parsed Content: " << content << std::endl;
    }
    else {
        std::cerr << "Content not found in response." << std::endl;
    }

    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);

    return 0;
}