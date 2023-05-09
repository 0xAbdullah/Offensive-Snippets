type
  HANDLE* = int
  HWND* = HANDLE
  UINT* = uint32
  LPCSTR* = cstring
  BOOL* = int32

# https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/pop_bin.nim
proc MessageBox*(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 
  {.discardable, stdcall, dynlib: "user32", importc: "MessageBoxA".}

proc CheckRemoteDebuggerPresent*(hProcess: HANDLE,  pbDebuggerPresent: var BOOL): BOOL
  {.stdcall, dynlib: "kernel32", importc: "CheckRemoteDebuggerPresent".}

proc GetCurrentProcess*(): HANDLE {.stdcall, dynlib: "kernel32", importc: "GetCurrentProcess".}


var hProcess: HANDLE = GetCurrentProcess()
const FALSE* = 0
var debuggerPresent: BOOL = FALSE

if bool(CheckRemoteDebuggerPresent(hProcess, debuggerPresent)):
  if bool(debuggerPresent):
    MessageBox(0, "Debugger is present", "Debugger", 0)
  else:
    MessageBox(0, "Debugger is not present", "Debugger", 0)
else:
  MessageBox(0, "Failed to check for debugging", "Debugger", 0)
