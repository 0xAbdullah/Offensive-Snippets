type
  HANDLE* = int
  HWND* = HANDLE
  UINT* = uint32
  LPCSTR* = cstring

# https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/pop_bin.nim
proc MessageBox*(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 
  {.discardable, stdcall, dynlib: "user32", importc: "MessageBoxA".}

#[
  Checking for the presence of a debugger with FindWindow function.
  https://medium.com/@X3non_C0der/anti-debugging-techniques-eda1868e0503
  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowa
]#
proc FindWindowA*(lpClassName: LPCSTR, lpWindowName: LPCSTR): bool 
  {.discardable, stdcall, dynlib: "user32", importc: "FindWindowA".}


for debugger in ["ollyDbg", "x64dbg", "x32dbg", "IDA", "WindDbg", "Soft Ice"]:
  if FindWindowA(nil, debugger):
    MessageBox(0, "Debugger is present", "Debugger", 0)
