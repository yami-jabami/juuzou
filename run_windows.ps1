powershell.exe -Command "Get-Content resources.txt"|ForEach-Object {docker run --platform linux/amd64 -d  alpine/bombardier -c 300 -d 60000h -l $_ }
