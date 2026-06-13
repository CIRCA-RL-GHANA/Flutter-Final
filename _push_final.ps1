$git = 'C:\Program Files\Git\cmd\git.exe'
Set-Location 'C:\Users\Wisdom Amaniampong\Desktop\Code\thedep\thepg'
Write-Output "=== REMOTES ==="
& $git remote -v
Write-Output "=== STATUS ==="
& $git status --short
Write-Output "=== PUSH TO FINAL ==="
& $git push final main 2>&1
Write-Output "DONE"
