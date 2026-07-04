$file = "build\web\main.dart.js"

if (-not (Test-Path $file)) {
    Write-Error "main.dart.js not found — did the build succeed?"
    exit 1
}

Write-Host "Reading main.dart.js..." -ForegroundColor Cyan
$content = Get-Content $file -Raw

# Fix 1: font name table entries  A.d("Font Name", ("https://fonts.gstatic..."))
$before = [regex]::Matches($content, 'fonts\.gstatic\.com|fonts\.googleapis\.com').Count
$content = $content -replace '\("https://fonts\.(gstatic\.com/s/|googleapis\.com/)[^"]*"\)', '("/assets/fonts/sans.ttf")'
Write-Host "Font table entries replaced." -ForegroundColor Green

# Fix 2: fontFallbackBaseUrl base URL string
$content = $content -replace '"https://fonts\.gstatic\.com/s/"', '""'
Write-Host "fontFallbackBaseUrl cleared." -ForegroundColor Green

# Fix 3: any leftover bare https://fonts.gstatic / googleapis URLs (not already caught)
$content = $content -replace '"https://fonts\.gstatic\.com[^"]*"', '""'
$content = $content -replace '"https://fonts\.googleapis\.com[^"]*"', '""'
Write-Host "Remaining stray font URLs cleared." -ForegroundColor Green

Write-Host "Writing patched file..." -ForegroundColor Cyan
Set-Content -Path $file -Value $content -NoNewline

# Verify
$remaining = (Select-String -Path $file -Pattern "fonts\.gstatic\.com|fonts\.googleapis\.com").Count
if ($remaining -gt 0) {
    Write-Warning "$remaining Google Font references still remain — check manually."
} else {
    Write-Host "All Google Font references removed successfully!" -ForegroundColor Green
}

# Verify asset exists
if (Test-Path "build\web\assets\fonts\sans.ttf") {
    Write-Host "sans.ttf asset found OK." -ForegroundColor Green
} else {
    Write-Warning "build\web\assets\fonts\sans.ttf not found — add it to pubspec.yaml assets!"
}