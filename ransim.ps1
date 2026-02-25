[CmdletBinding(DefaultParameterSetName="Encrypt")]
param(
  [Parameter(ParameterSetName="Encrypt")]
  [switch]$Encrypt,
  
  [Parameter(ParameterSetName="Decrypt")]
  [switch]$Decrypt,
  
  [Parameter(ParameterSetName="Encrypt")]
  [int]$FileCount = 10,
  
  [Parameter(ParameterSetName="Encrypt")]
  [string]$OutputDir = "$env:USERPROFILE\Documents\RansimLab",
  
  [Parameter(ParameterSetName="Encrypt")]
  [string]$Ext = "ransim",
  
  [Parameter(ParameterSetName="Encrypt")]
  [int]$Threads = 4,
  
  [Parameter(ParameterSetName="Encrypt")]
  [switch]$ExistingMode,
  
  [Parameter(ParameterSetName="Encrypt")]
  [string]$SourcePath,
  
  [Parameter(ParameterSetName="Encrypt")]
  [switch]$Recurse,
  
  [Parameter(ParameterSetName="Encrypt")]
  [switch]$GenerateOnly,
  
  [Parameter(ParameterSetName="Decrypt")]
  [string]$KeyB64,
  
  [Parameter(ParameterSetName="Decrypt")]
  [string]$DecryptFolder,
  
  [Parameter(ParameterSetName="Decrypt")]
  [string]$DecryptExt = "ransim"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Script version
$ScriptVersion = "0.2"

if ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "This script requires PowerShell 7+" -ForegroundColor Red
  exit 1
}

function Show-Help {
  Write-Host "                                                "
  Write-Host "\u2588\u2588\u2588\u2588\u2588\u2588\u2557  \u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2557   \u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2557\u2588\u2588\u2588\u2557   \u2588\u2588\u2588\u2557" -ForegroundColor DarkYellow
  Write-Host "\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2557  \u2588\u2588\u2551\u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255d\u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2551" -ForegroundColor DarkYellow
  Write-Host "\u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2554\u2588\u2588\u2557 \u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2551\u2588\u2588\u2554\u2588\u2588\u2588\u2588\u2554\u2588\u2588\u2551" -ForegroundColor DarkYellow
  Write-Host "\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2551\u2588\u2588\u2551\u255a\u2588\u2588\u2557\u2588\u2588\u2551\u255a\u2550\u2550\u2550\u2550\u2588\u2588\u2551\u2588\u2588\u2551\u2588\u2588\u2551\u255a\u2588\u2588\u2554\u255d\u2588\u2588\u2551" -ForegroundColor DarkYellow
  Write-Host "\u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551 \u255a\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2551\u2588\u2588\u2551 \u255a\u2550\u255d \u2588\u2588\u2551" -ForegroundColor DarkYellow
  Write-Host "\u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u255d  \u255a\u2550\u2550\u2550\u255d\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u255d\u255a\u2550\u255d\u255a\u2550\u255d     \u255a\u2550\u255d" -ForegroundColor DarkYellow
  Write-Host ""
  Write-Host "RANSIM - Ransomware Simulation Tool v$ScriptVersion" -ForegroundColor Cyan
  Write-Host "=================================================" -ForegroundColor Cyan
  Write-Host ""
  Write-Host "USAGE:" -ForegroundColor Yellow
  Write-Host "  .\ransim.ps1 [options]" -ForegroundColor White
  Write-Host ""
  Write-Host "EXAMPLES:" -ForegroundColor Yellow
  Write-Host ""
  Write-Host "  1. GENERATE AND ENCRYPT test files (default):" -ForegroundColor Green
  Write-Host "     .\ransim.ps1 -FileCount 20 -Threads 8" -ForegroundColor White
  Write-Host ""
  Write-Host "  2. GENERATE ONLY test files (no encryption):" -ForegroundColor Green
  Write-Host "     .\ransim.ps1 -GenerateOnly -FileCount 50" -ForegroundColor White
  Write-Host ""
  Write-Host "  3. ENCRYPT EXISTING files:" -ForegroundColor Green
  Write-Host "     .\ransim.ps1 -ExistingMode -SourcePath `"C:\MyFiles`" -Recurse" -ForegroundColor White
  Write-Host ""
  Write-Host "  4. DECRYPT files:" -ForegroundColor Green
  Write-Host "     .\ransim.ps1 -Decrypt -DecryptFolder `"C:\ransim_test_date_time`" -KeyB64 `"your-base64-key`"" -ForegroundColor White
  Write-Host ""
  Write-Host "PARAMETERS:" -ForegroundColor Yellow
  Write-Host ""
  Write-Host "  ENCRYPTION MODE (default):" -ForegroundColor Cyan
  Write-Host "    -Encrypt               : Run encryption mode (default)" -ForegroundColor White
  Write-Host "    -FileCount <int>       : Number of files to generate (default: 10)" -ForegroundColor White
  Write-Host "    -OutputDir <path>      : Output folder (default: ~\Documents\RansimLab)" -ForegroundColor White
  Write-Host "    -Ext <string>          : Extension for encrypted files (default: ransim)" -ForegroundColor White
  Write-Host "    -Threads <int>          : Number of parallel threads (default: 4)" -ForegroundColor White
  Write-Host "    -GenerateOnly           : Only generate files, don't encrypt" -ForegroundColor White
  Write-Host ""
  Write-Host "  EXISTING FILES MODE:" -ForegroundColor Cyan
  Write-Host "    -ExistingMode           : Encrypt existing files instead of generating" -ForegroundColor White
  Write-Host "    -SourcePath <path>      : Path to folder with files to encrypt (required)" -ForegroundColor White
  Write-Host "    -Recurse                 : Include subfolders" -ForegroundColor White
  Write-Host ""
  Write-Host "  DECRYPTION MODE:" -ForegroundColor Cyan
  Write-Host "    -Decrypt                 : Run decryption mode" -ForegroundColor White
  Write-Host "    -DecryptFolder <path>    : Folder with encrypted files (required)" -ForegroundColor White
  Write-Host "    -KeyB64 <string>         : Decryption key in Base64 (required)" -ForegroundColor White
  Write-Host "    -DecryptExt <string>     : Extension of encrypted files (default: ransim)" -ForegroundColor White
  Write-Host ""
  Write-Host "  GENERAL:" -ForegroundColor Cyan
  Write-Host "    -Encrypt | -Decrypt      : Select mode (default: Encrypt)" -ForegroundColor White
  Write-Host ""
  Write-Host "NOTES:" -ForegroundColor Yellow
  Write-Host "  - Files are encrypted using AES-256-GCM" -ForegroundColor White
  Write-Host "  - Each encrypted file gets .[ext] added to filename" -ForegroundColor White
  Write-Host "  - README file with decryption key is saved to Desktop" -ForegroundColor White
  Write-Host ""
}

# Check if no parameters or just -Encrypt with no other params
$showHelp = $false
if ($MyInvocation.BoundParameters.Count -eq 0) {
  # No parameters at all
  $showHelp = $true
} elseif ($Encrypt -and $MyInvocation.BoundParameters.Count -eq 1) {
  # Just -Encrypt with no other params
  $showHelp = $true
}

if ($showHelp) {
  Show-Help
  exit 0
}

function New-RandomBytes {
  param([int]$Count)
  [byte[]]$b = New-Object byte[] $Count
  [System.Security.Cryptography.RandomNumberGenerator]::Fill($b)
  return $b
}

function New-AesKey {
  return New-RandomBytes 32
}

function Protect-File {
  param(
    [byte[]]$Data,
    [byte[]]$Key
  )
  
  $nonce = New-RandomBytes 12
  $tag = New-Object byte[] 16
  $cipher = New-Object byte[] $Data.Length
  
  $aes = [System.Security.Cryptography.AesGcm]::new($Key)
  try {
    $aes.Encrypt($nonce, $Data, $cipher, $tag)
  }
  finally {
    $aes.Dispose()
  }
  
  $magic = [byte[]]@(0x52, 0x53, 0x49, 0x4D)
  $result = New-Object byte[] (4 + 1 + 12 + 16 + $cipher.Length)
  
  [Array]::Copy($magic, 0, $result, 0, 4)
  $result[4] = 12
  [Array]::Copy($nonce, 0, $result, 5, 12)
  [Array]::Copy($tag, 0, $result, 17, 16)
  [Array]::Copy($cipher, 0, $result, 33, $cipher.Length)
  
  return $result
}

function Unprotect-File {
  param(
    [byte[]]$Data,
    [byte[]]$Key
  )
  
  $magic = [byte[]]@(0x52, 0x53, 0x49, 0x4D)
  for ($i = 0; $i -lt 4; $i++) {
    if ($Data[$i] -ne $magic[$i]) {
      throw "Invalid file format"
    }
  }
  
  $nonceLen = $Data[4]
  if ($nonceLen -ne 12) { throw "Unsupported nonce length" }
  
  $nonce = New-Object byte[] 12
  $tag = New-Object byte[] 16
  $cipherLen = $Data.Length - 33
  
  [Array]::Copy($Data, 5, $nonce, 0, 12)
  [Array]::Copy($Data, 17, $tag, 0, 16)
  
  $cipher = New-Object byte[] $cipherLen
  [Array]::Copy($Data, 33, $cipher, 0, $cipherLen)
  
  $plain = New-Object byte[] $cipherLen
  $aes = [System.Security.Cryptography.AesGcm]::new($Key)
  try {
    $aes.Decrypt($nonce, $cipher, $tag, $plain)
  }
  finally {
    $aes.Dispose()
  }
  
  return $plain
}

function Write-README {
  param(
    [string]$Path,
    [string]$Folder,
    [string]$Key,
    [string]$Ext,
    [int]$FileCount
  )
  
  $content = @"
===========================================
RANSIM - Ransomware Simulation (v$ScriptVersion)
===========================================

This is a BENIGN ransomware simulation for testing purposes.
This is NOT a real attack.

DATE: $(Get-Date)
FOLDER: $Folder
ENCRYPTED FILES: $FileCount
EXTENSION: .$Ext

===========================================
DECRYPTION KEY (Base64):
===========================================

$Key

===========================================
DECRYPTION INSTRUCTIONS:
===========================================

.\ransim.ps1 -Decrypt -DecryptFolder "$Folder" -KeyB64 "$Key" -DecryptExt "$Ext"

===========================================
"@
  
  Set-Content -Path $Path -Value $content -Encoding UTF8
  return $Path
}

Write-Host ""
Write-Host "\u2588\u2588\u2588\u2588\u2588\u2588\u2557  \u2588\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2557   \u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2557\u2588\u2588\u2588\u2557   \u2588\u2588\u2588\u2557" -ForegroundColor DarkYellow
Write-Host "\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2588\u2588\u2557  \u2588\u2588\u2551\u2588\u2588\u2554\u2550\u2550\u2550\u2550\u255d\u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2557 \u2588\u2588\u2588\u2588\u2551" -ForegroundColor DarkYellow
Write-Host "\u2588\u2588\u2588\u2588\u2588\u2588\u2554\u255d\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2554\u2588\u2588\u2557 \u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2557\u2588\u2588\u2551\u2588\u2588\u2554\u2588\u2588\u2588\u2588\u2554\u2588\u2588\u2551" -ForegroundColor DarkYellow
Write-Host "\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2557\u2588\u2588\u2554\u2550\u2550\u2588\u2588\u2551\u2588\u2588\u2551\u255a\u2588\u2588\u2557\u2588\u2588\u2551\u255a\u2550\u2550\u2550\u2550\u2588\u2588\u2551\u2588\u2588\u2551\u2588\u2588\u2551\u255a\u2588\u2588\u2554\u255d\u2588\u2588\u2551" -ForegroundColor DarkYellow
Write-Host "\u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551  \u2588\u2588\u2551\u2588\u2588\u2551 \u255a\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2588\u2588\u2588\u2588\u2588\u2551\u2588\u2588\u2551\u2588\u2588\u2551 \u255a\u2550\u255d \u2588\u2588\u2551" -ForegroundColor DarkYellow
Write-Host "\u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u255d  \u255a\u2550\u255d\u255a\u2550\u255d  \u255a\u2550\u2550\u2550\u255d\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u255d\u255a\u2550\u255d\u255a\u2550\u255d     \u255a\u2550\u255d" -ForegroundColor DarkYellow
Write-Host "Ransomware Simulation Tool v$ScriptVersion" -ForegroundColor DarkYellow
Write-Host ""

if ($Encrypt -or (-not $Decrypt)) {
  
  if ($ExistingMode) {
    if (-not $SourcePath) {
      Write-Host "Error: In Existing mode you must provide -SourcePath" -ForegroundColor Red
      exit 1
    }
    
    if (-not (Test-Path $SourcePath)) {
      Write-Host "Error: Path does not exist: $SourcePath" -ForegroundColor Red
      exit 1
    }
    
    Write-Host "Mode: Encrypting existing files" -ForegroundColor Green
    Write-Host "Folder: $SourcePath"
    Write-Host "Extension: .$Ext"
    Write-Host "Threads: $Threads"
    Write-Host ""
    
    $getParams = @{
      Path = $SourcePath
      File = $true
    }
    if ($Recurse) {
      $getParams.Recurse = $true
    }
    
    $files = Get-ChildItem @getParams | Where-Object {
      $_.Extension -notmatch "\.$Ext$" -and
      $_.Name -notlike "*.tmp" -and
      $_.Name -notlike "*.log"
    }
    
    if ($files.Count -eq 0) {
      Write-Host "No files found to encrypt" -ForegroundColor Yellow
      exit 0
    }
    
    Write-Host "Files found: $($files.Count)" -ForegroundColor Cyan
    
    $key = New-AesKey
    $keyB64 = [Convert]::ToBase64String($key)
    
    $files | ForEach-Object -Parallel {
      $file = $_
      $key = $using:key
      $ext = $using:Ext
      
      function New-RandomBytes {
        param([int]$Count)
        [byte[]]$b = New-Object byte[] $Count
        [System.Security.Cryptography.RandomNumberGenerator]::Fill($b)
        return $b
      }
      
      function Protect-File {
        param(
          [byte[]]$Data,
          [byte[]]$Key
        )
        
        $nonce = New-RandomBytes 12
        $tag = New-Object byte[] 16
        $cipher = New-Object byte[] $Data.Length
        
        $aes = [System.Security.Cryptography.AesGcm]::new($Key)
        try {
          $aes.Encrypt($nonce, $Data, $cipher, $tag)
        }
        finally {
          $aes.Dispose()
        }
        
        $magic = [byte[]]@(0x52, 0x53, 0x49, 0x4D)
        $result = New-Object byte[] (4 + 1 + 12 + 16 + $cipher.Length)
        
        [Array]::Copy($magic, 0, $result, 0, 4)
        $result[4] = 12
        [Array]::Copy($nonce, 0, $result, 5, 12)
        [Array]::Copy($tag, 0, $result, 17, 16)
        [Array]::Copy($cipher, 0, $result, 33, $cipher.Length)
        
        return $result
      }
      
      try {
        $data = [System.IO.File]::ReadAllBytes($file.FullName)
        $encrypted = Protect-File -Data $data -Key $key
        $encPath = "$($file.FullName).$ext"
        [System.IO.File]::WriteAllBytes($encPath, $encrypted)
        Remove-Item -Path $file.FullName -Force
        Write-Host "[OK] $($file.Name) -> $($file.Name).$ext" -ForegroundColor Green
      }
      catch {
        Write-Host "[ERROR] $($file.Name): $_" -ForegroundColor Red
      }
    } -ThrottleLimit $Threads
    
    $encryptedCount = (Get-ChildItem -Path $SourcePath -Recurse -File -Filter "*.$Ext").Count
    
    $desktop = [Environment]::GetFolderPath("Desktop")
    $readmePath = Join-Path $desktop "README_RANSIM_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Write-README -Path $readmePath -Folder $SourcePath -Key $keyB64 -Ext $Ext -FileCount $encryptedCount
    
    Write-Host ""
    Write-Host "Encryption completed!" -ForegroundColor DarkYellow
    Write-Host "Encrypted files: $encryptedCount" -ForegroundColor DarkYellow
    Write-Host "README: $readmePath" -ForegroundColor DarkYellow
    Write-Host "Key: $keyB64" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Decrypt command:" -ForegroundColor Cyan
    Write-Host ".\ransim.ps1 -Decrypt -DecryptFolder `"$SourcePath`" -KeyB64 `"$keyB64`" -DecryptExt `"$Ext`"" -ForegroundColor Yellow
  }
  else {
    if ($GenerateOnly) {
      Write-Host "Mode: Generating test files ONLY (no encryption)" -ForegroundColor Green
    } else {
      Write-Host "Mode: Generating and encrypting test files" -ForegroundColor Green
    }
    Write-Host "File count: $FileCount"
    Write-Host "Output folder: $OutputDir"
    if (-not $GenerateOnly) {
      Write-Host "Extension: .$Ext"
    }
    Write-Host "Threads: $Threads"
    Write-Host ""
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $workDir = Join-Path $OutputDir "ransim_test_$timestamp"
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    
    $subdirs = @($workDir)
    for ($i = 1; $i -le 8; $i++) {
      $subdir = Join-Path $workDir "data_$i"
      New-Item -ItemType Directory -Path $subdir -Force | Out-Null
      $subdirs += $subdir
    }
    
    Write-Host "Created folder: $workDir"
    Write-Host "Created subfolders: $($subdirs.Count)"
    
    $key = $null
    $keyB64 = $null
    if (-not $GenerateOnly) {
      $key = New-AesKey
      $keyB64 = [Convert]::ToBase64String($key)
    }
    
    $fileTypes = @("txt", "docx", "xlsx")
    
    1..$FileCount | ForEach-Object -Parallel {
      $index = $_
      $subdirs = $using:subdirs
      $fileTypes = $using:fileTypes
      $key = $using:key
      $ext = $using:Ext
      $workDir = $using:workDir
      $generateOnly = $using:GenerateOnly
      
      function New-RandomBytes {
        param([int]$Count)
        [byte[]]$b = New-Object byte[] $Count
        [System.Security.Cryptography.RandomNumberGenerator]::Fill($b)
        return $b
      }
      
      function Protect-File {
        param(
          [byte[]]$Data,
          [byte[]]$Key
        )
        
        $nonce = New-RandomBytes 12
        $tag = New-Object byte[] 16
        $cipher = New-Object byte[] $Data.Length
        
        $aes = [System.Security.Cryptography.AesGcm]::new($Key)
        try {
          $aes.Encrypt($nonce, $Data, $cipher, $tag)
        }
        finally {
          $aes.Dispose()
        }
        
        $magic = [byte[]]@(0x52, 0x53, 0x49, 0x4D)
        $result = New-Object byte[] (4 + 1 + 12 + 16 + $cipher.Length)
        
        [Array]::Copy($magic, 0, $result, 0, 4)
        $result[4] = 12
        [Array]::Copy($nonce, 0, $result, 5, 12)
        [Array]::Copy($tag, 0, $result, 17, 16)
        [Array]::Copy($cipher, 0, $result, 33, $cipher.Length)
        
        return $result
      }
      
      try {
        $rng = [System.Random]::new()
        $dir = $subdirs[$rng.Next(0, $subdirs.Count)]
        $type = $fileTypes[$rng.Next(0, $fileTypes.Count)]
        
        $fileName = "$([Guid]::NewGuid().ToString('N')).$type"
        $filePath = Join-Path $dir $fileName
        
        $size = $rng.Next(4096, 65536)
        $data = New-RandomBytes $size
        $header = [System.Text.Encoding]::UTF8.GetBytes("RANSIM-TEST:$index`n")
        [Array]::Copy($header, 0, $data, 0, [Math]::Min($header.Length, $data.Length))
        
        [System.IO.File]::WriteAllBytes($filePath, $data)
        
        if (-not $generateOnly) {
          $encrypted = Protect-File -Data $data -Key $key
          $encPath = "$filePath.$ext"
          [System.IO.File]::WriteAllBytes($encPath, $encrypted)
          Remove-Item -Path $filePath -Force
          Write-Host "[$index] $fileName -> $fileName.$ext" -ForegroundColor Green
        } else {
          Write-Host "[$index] Created: $fileName" -ForegroundColor Green
        }
      }
      catch {
        Write-Host "[ERROR $index] $_" -ForegroundColor Red
      }
    } -ThrottleLimit $Threads
    
    if ($generateOnly) {
      $fileCount = (Get-ChildItem -Path $workDir -Recurse -File).Count
      Write-Host ""
      Write-Host "File generation completed!" -ForegroundColor DarkYellow
      Write-Host "Folder: $workDir" -ForegroundColor DarkYellow
      Write-Host "Files created: $fileCount" -ForegroundColor DarkYellow
      Write-Host ""
      Write-Host "To encrypt these files later:" -ForegroundColor Cyan
      Write-Host ".\ransim.ps1 -Encrypt -ExistingMode -SourcePath `"$workDir`" -Recurse -Ext `"$Ext`" -Threads $Threads" -ForegroundColor Yellow
    } else {
      $encryptedCount = (Get-ChildItem -Path $workDir -Recurse -File -Filter "*.$Ext").Count
      
      $desktop = [Environment]::GetFolderPath("Desktop")
      $readmePath = Join-Path $desktop "README_RANSIM_$timestamp.txt"
      Write-README -Path $readmePath -Folder $workDir -Key $keyB64 -Ext $Ext -FileCount $encryptedCount
      
      Write-Host ""
      Write-Host "Encryption completed!" -ForegroundColor DarkYellow
      Write-Host "Folder: $workDir" -ForegroundColor DarkYellow
      Write-Host "Encrypted files: $encryptedCount" -ForegroundColor DarkYellow
      Write-Host "README: $readmePath" -ForegroundColor DarkYellow
      Write-Host "Key: $keyB64" -ForegroundColor DarkYellow
      Write-Host ""
      Write-Host "Decrypt command:" -ForegroundColor Cyan
      Write-Host ".\ransim.ps1 -Decrypt -DecryptFolder `"$workDir`" -KeyB64 `"$keyB64`" -DecryptExt `"$Ext`"" -ForegroundColor Yellow
    }
  }
  
  exit 0
}

if ($Decrypt) {
  
  if (-not $DecryptFolder) {
    Write-Host "Error: You must provide -DecryptFolder" -ForegroundColor Red
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  .\ransim.ps1 -Decrypt -DecryptFolder `"C:\ransim_test_20260225_123456`" -KeyB64 `"your-base64-key`" -DecryptExt `"ransim`"" -ForegroundColor Yellow
    exit 1
  }
  
  if (-not $KeyB64) {
    Write-Host "Error: You must provide -KeyB64" -ForegroundColor Red
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  .\ransim.ps1 -Decrypt -DecryptFolder `"C:\ransim_test_20260225_123456`" -KeyB64 `"your-base64-key`" -DecryptExt `"ransim`"" -ForegroundColor Yellow
    exit 1
  }
  
  if (-not (Test-Path $DecryptFolder)) {
    Write-Host "Error: Folder does not exist: $DecryptFolder" -ForegroundColor Red
    exit 1
  }
  
  Write-Host ""
  Write-Host "Mode: Decrypting files" -ForegroundColor Green
  Write-Host "Folder: $DecryptFolder"
  Write-Host "Extension: .$DecryptExt"
  Write-Host ""
  
  try {
    $key = [Convert]::FromBase64String($KeyB64)
    if ($key.Length -ne 32) {
      Write-Host "Error: Invalid key length (expected 32 bytes, got $($key.Length))" -ForegroundColor Red
      exit 1
    }
    Write-Host "Key loaded successfully (32 bytes)" -ForegroundColor Green
  }
  catch {
    Write-Host "Error: Invalid Base64 key: $_" -ForegroundColor Red
    exit 1
  }
  
  Write-Host "Searching for files with extension .$DecryptExt in $DecryptFolder..." -ForegroundColor Gray
  $encryptedFiles = Get-ChildItem -Path $DecryptFolder -Recurse -File -Filter "*.$DecryptExt"
  
  if ($encryptedFiles.Count -eq 0) {
    Write-Host "No files found with extension .$DecryptExt" -ForegroundColor Yellow
    exit 0
  }
  
  Write-Host "Files to decrypt found: $($encryptedFiles.Count)" -ForegroundColor Cyan
  Write-Host ""
  
  $restored = 0
  $failed = 0
  
  foreach ($file in $encryptedFiles) {
    try {
      Write-Host "Processing: $($file.Name)" -ForegroundColor Gray
      
      $encrypted = [System.IO.File]::ReadAllBytes($file.FullName)
      $decrypted = Unprotect-File -Data $encrypted -Key $key
      
      $outPath = $file.FullName.Substring(0, $file.FullName.Length - ($DecryptExt.Length + 1))
      $tmpPath = "$outPath.tmp"
      
      [System.IO.File]::WriteAllBytes($tmpPath, $decrypted)
      
      if (Test-Path $outPath) {
        Remove-Item -Path $outPath -Force
      }
      
      Move-Item -Path $tmpPath -Destination $outPath -Force
      Remove-Item -Path $file.FullName -Force
      
      $restored++
      Write-Host "  -> OK: $(Split-Path $outPath -Leaf)" -ForegroundColor Green
    }
    catch {
      $failed++
      Write-Host "  -> ERROR: $_" -ForegroundColor Red
    }
  }
  
  Write-Host ""
  Write-Host "Decryption completed!" -ForegroundColor DarkYellow
  Write-Host "Restored: $restored" -ForegroundColor DarkYellow
  Write-Host "Failed: $failed" -ForegroundColor DarkYellow
  
  exit 0
}
