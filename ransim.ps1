cls
#Banner
Write-Host "                                                "
Write-Host "██████╗  █████╗ ███╗   ██╗███████╗██╗███╗   ███╗" -ForegroundColor DarkYellow
Write-Host "██╔══██╗██╔══██╗████╗  ██║██╔════╝██║████╗ ████║" -ForegroundColor DarkYellow
Write-Host "██████╔╝███████║██╔██╗ ██║███████╗██║██╔████╔██║" -ForegroundColor DarkYellow
Write-Host "██╔══██╗██╔══██║██║╚██╗██║╚════██║██║██║╚██╔╝██║" -ForegroundColor DarkYellow
Write-Host "██║  ██║██║  ██║██║ ╚████║███████║██║██║ ╚═╝ ██║" -ForegroundColor DarkYellow
Write-Host "╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝╚═╝     ╚═╝" -ForegroundColor DarkYellow
Write-Host "Ransomware simulation from 0ut3r.space          " -ForegroundColor DarkYellow
Write-Host "                                                "
Write-Host "-----------Simulation no.1 start----------------" -ForegroundColor Green
Write-Host "                                                "
Write-Host "Create 1k txt files and mass change extension   " -ForegroundColor Green
Write-Host "from txt to ransim                              " -ForegroundColor Green
Write-Host "                                                "
#Test folder location
$Folder1 = 'C:\ransim1\'
Write-Output "Checking if test folder $Folder1 exist"
#Test to see if folder [$Folder1]  exists
if (Test-Path -Path $Folder1) {
#Path exists. Cleanup.
Write-Output "Test folder exist, cleanup folder"
GCI $Folder1 | Remove-Item -Force
} else {
#Path doesn't exist. Creating new one!
Write-Output "No test folder, creating one"
    mkdir $Folder1 | Out-Null
}
#Create 1000 files with text "RansomwareTest" inside
Write-Output "Creating 1k test txt files with test content"
1..1000 | ForEach-Object {
    Out-File -InputObject 'RansomwareTest' -FilePath $Folder1\TestTextFile$_.txt
}
#Change file extension
cd $Folder1
Write-Output "Replace extension from .txt to .ransim"
dir *.txt | rename-item -newname {  $_.name  -replace ".txt",".ransim" }
Write-Host "                                                "
Write-Host "Ransomware simulation 1 complete                " -ForegroundColor DarkYellow
Write-Host "                                                "
Write-Host "-----------Simulation no.2 start----------------" -ForegroundColor Green
Write-Host "                                                "
Write-Host "Create 1k files, change ext and modify file     " -ForegroundColor Green
Write-Host "                                                "
#Test folder location
$Folder2 = "C:\ransim2\"
Write-Output "Checking if test folder $Folder2 exist"
#Test to see if folder [$Folder2]  exists
if (Test-Path -Path $Folder2) {
#Path exists. Cleanup.
Write-Output "Test folder exist, cleanup folder"
GCI $Folder2 | Remove-Item -Force
} else {
#Path doesn't exist. Creating new one!
Write-Output "No test folder, creating one"
    mkdir $Folder2 | Out-Null
}
Write-Output "Creating 1k test txt files with test content"
1..1000 | % { $Path = $Folder2 + $_ + ".txt"; "RansomwareTest" | Out-File $Path | Out-Null }
Write-Output "Replace extension from .txt to .ransim and modify file content"
1..1000 | % { $Path = $Folder2 + $_ + ".txt"; $NewPath = $Path + ".ransim"; "- encrypted -" | Out-File -Append $Path; Rename-Item -Path $Path -NewName $NewPath }
Write-Host "                                                "
Write-Host "Ransomware simulation 2 complete                " -ForegroundColor DarkYellow
Write-Host "                                                "
cd ..
