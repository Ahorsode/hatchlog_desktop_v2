#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <shlobj.h>
#include <string>
#include <vector>
#include <fstream>
#include <iostream>

#include "flutter_window.h"
#include "utils.h"

// Unique ID for your app mutex
const wchar_t* kAppMutexName = L"Global\\poultry_pms_desktop_mutex";

// Helper to get handoff file path
std::wstring GetHandoffFilePath() {
    wchar_t* localAppData = nullptr;
    if (SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, NULL, &localAppData) == S_OK) {
        std::wstring path = std::wstring(localAppData) + L"\\poultry_pms_handoff.txt";
        CoTaskMemFree(localAppData);
        return path;
    }
    return L"";
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  
  // 1. Check if already running
  HANDLE hMutex = CreateMutexW(NULL, TRUE, kAppMutexName);
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    // Already running!
    if (__argc > 1) {
      std::wstring cmd = __wargv[1];
      // Write to handoff file
      std::wofstream handoff(GetHandoffFilePath());
      if (handoff.is_open()) {
          handoff << cmd;
          handoff.close();
      }
    }
    // Wake up the original window if we can find it
    HWND hwnd = FindWindowW(NULL, L"Agri-ERP Desktop");
    if (hwnd) {
      ShowWindow(hwnd, SW_RESTORE);
      SetForegroundWindow(hwnd);
    }
    return EXIT_SUCCESS;
  }

  // Attach to console when present
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  
  if (!window.Create(L"Agri-ERP Desktop", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  if (hMutex) {
    ReleaseMutex(hMutex);
    CloseHandle(hMutex);
  }
  return EXIT_SUCCESS;
}
