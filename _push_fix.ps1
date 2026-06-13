$git = 'C:\Program Files\Git\cmd\git.exe'
Set-Location 'C:\Users\Wisdom Amaniampong\Desktop\Code\thedep\thepg'
Write-Output ("PWD=" + (Get-Location))
& $git log --oneline -3
& $git push origin main 2>&1
Write-Output "PUSH_DONE"
