$git = 'C:\Program Files\Git\cmd\git.exe'
Set-Location 'C:\Users\Wisdom Amaniampong\Desktop\Code\thedep\thepg'
& $git add lib/features/go/screens/go_tab_detail_screen.dart
& $git add lib/features/live/widgets/live_widgets.dart
& $git add lib/features/qualchat/screens/qualchat_nudges_screen.dart
& $git status
& $git commit -m "fix: repair _showEditTabSheet scope, AppRoutes import, and _NudgeSettingsSheet class"
& $git push final main 2>&1
Write-Output "PUSH_DONE"
