$configPath = "C:\Users\Serhii\Downloads\eng\MRS-BOOKS\Speakout_3rd_b1_SB\files\editor\files\config.js"
$sourceVideoDir = "C:\Users\Serhii\Downloads\eng\Speakout_Third_edition_B1_Videos\Speakout_Third_edition_B1_Videos"
$outputDir = "C:\Users\Serhii\Downloads\eng\MRS-BOOKS\Speakout_3rd_b1_SB\files\editor\files\extfile"

if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }

Write-Host "Reading config for videos..." -ForegroundColor Cyan
$configContent = Get-Content -Path $configPath -Raw -Encoding UTF8

$pattern = '"name"\s*:\s*"([^"]+\.mp4)"[^}]*?"videoName"\s*:\s*"([^"]+\.mp4)"'
$matches = [System.Text.RegularExpressions.Regex]::Matches($configContent, $pattern)

Write-Host "Found video entries: $($matches.Count)" -ForegroundColor Green

$successCount = 0
$notFoundCount = 0

foreach ($match in $matches) {
    $originalName = $match.Groups[1].Value.Trim()
    $hashName = $match.Groups[2].Value.Trim()
    
    # щем исходное видео в папке с видео
    $sourceFile = Get-ChildItem -Path $sourceVideoDir -Filter $originalName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($sourceFile) {
        $destinationPath = Join-Path $outputDir $hashName
        Copy-Item -Path $sourceFile.FullName -Destination $destinationPath -Force
        Write-Host "[OK] Video: $originalName -> $hashName" -ForegroundColor Yellow
        $successCount++
    } else {
        Write-Host "[MISSING] Video: $originalName" -ForegroundColor Red
        $notFoundCount++
    }
}

Write-Host "`nDone!" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor Green
Write-Host "Not found: $notFoundCount" -ForegroundColor $(if($notFoundCount -gt 0){"Red"}else{"Green"})