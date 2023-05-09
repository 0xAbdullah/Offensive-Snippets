type
  HANDLE* = int
  HWND* = HANDLE
  UINT* = uint32
  LPCSTR* = cstring

# https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/pop_bin.nim
proc MessageBox*(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 
  {.discardable, stdcall, dynlib: "user32", importc: "MessageBoxA".}

proc IsDebuggerPresent*(): bool 
  {.discardable, stdcall, dynlib: "kernel32", importc: "IsDebuggerPresent".}

if IsDebuggerPresent():
  MessageBox(0, "Debugger is present", "Debugger", 0)
else:
  MessageBox(0, "Debugger is not present", "Debugger", 0)
