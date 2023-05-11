type
  HANDLE* = int
  HWND* = HANDLE
  UINT* = uint32
  LPCSTR* = cstring

# https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/pop_bin.nim
proc MessageBox*(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 
  {.discardable, stdcall, dynlib: "user32", importc: "MessageBoxA".}

# https://learn.microsoft.com/en-us/windows/win32/api/debugapi/nf-debugapi-isdebuggerpresent
#[
This code uses the IsDebuggerPresent function to check whether a debugger is currently attached to the program.
]#
proc IsDebuggerPresent*(): bool 
  {.discardable, stdcall, dynlib: "kernel32", importc: "IsDebuggerPresent".}

if IsDebuggerPresent():
  MessageBox(0, "Debugger is present", "Debugger", 0)
else:
  MessageBox(0, "Debugger is not present", "Debugger", 0)
