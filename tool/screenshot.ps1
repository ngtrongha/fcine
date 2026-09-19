<# 
.SYNOPSIS
    Chụp screenshot tự động cho F-Cine (Mobile + Desktop)

.DESCRIPTION
    Chạy integration test để chụp ảnh màn hình của các trang chính:
    - Home, Search, Detail, Player, Library, Settings
    - Cả mobile và desktop (nếu chạy trên Windows/macOS/Linux)

.USAGE
    .\tool\screenshot.ps1
    .\tool\screenshot.ps1 -Platform mobile
    .\tool\screenshot.ps1 -Platform desktop
#>

param(
    [ValidateSet('mobile', 'desktop', 'all')]
    [string]$Platform = 'all',
    
    [string]$Device = 'windows',
    
    [switch]$Headless
)

Write-Host "🎬 F-Cine Screenshot Tool" -ForegroundColor Cyan
Write-Host "Platform: $Platform | Device: $Device" -ForegroundColor Gray

# Kiểm tra dependencies
if (-not (Test-Path "integration_test\screenshot_test.dart")) {
    Write-Error "❌ Không tìm thấy integration_test\screenshot_test.dart"
    exit 1
}

# Tạo thư mục screenshots
$ssDir = "docs\screenshots"
if (-not (Test-Path $ssDir)) {
    New-Item -ItemType Directory -Path $ssDir -Force | Out-Null
    Write-Host "📁 Created $ssDir" -ForegroundColor Green
}

# Cài dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# Chạy test theo platform
$testArgs = @()
switch ($Platform) {
    'mobile' { $testArgs += 'integration_test/screenshot_test.dart' }
    'desktop' { 
        if ($Device -eq 'windows') { $testArgs += '-d', 'windows' }
        elseif ($Device -eq 'macos') { $testArgs += '-d', 'macos' }
        elseif ($Device -eq 'linux') { $testArgs += '-d', 'linux' }
        $testArgs += 'integration_test/screenshot_test.dart'
    }
    'all' {
        # Mobile first (web hoặc device)
        Write-Host "`n📱 Capturing MOBILE screenshots..." -ForegroundColor Cyan
        flutter test integration_test/screenshot_test.dart --name "Capture all screens"
        
        # Desktop (nếu trên desktop OS)
        if ($IsWindows -or $IsMacOS -or $IsLinux) {
            Write-Host "`n🖥️ Capturing DESKTOP screenshots..." -ForegroundColor Cyan
            flutter test integration_test/screenshot_test.dart --name "Capture desktop screens" -d $Device
        }
        Write-Host "`n✅ Done! Check $ssDir" -ForegroundColor Green
        exit 0
    }
}

if ($testArgs.Count -gt 0) {
    Write-Host "🚀 Running: flutter test $($testArgs -join ' ')" -ForegroundColor Yellow
    flutter test @testArgs
}

Write-Host "`n✅ Screenshots saved to $ssDir" -ForegroundColor Green
Write-Host "Files:" -ForegroundColor Gray
Get-ChildItem $ssDir | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }