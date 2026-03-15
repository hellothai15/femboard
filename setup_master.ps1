# Femboard - Master Setup Script
# Runs all phases in sequence to build the complete project with git history
$ErrorActionPreference = "Stop"
$projectDir = "c:\Users\aruch\Work\temp\clash\femboard"

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Femboard Project Setup 🌸" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Run each phase
Write-Host "[1/6] Setting up initial project structure..." -ForegroundColor Cyan
& "$projectDir\setup_phase1.ps1"
Write-Host ""

Write-Host "[2/6] Adding cute theme and styling..." -ForegroundColor Cyan
& "$projectDir\setup_phase2.ps1"
Write-Host ""

Write-Host "[3/6] Building board system..." -ForegroundColor Cyan
& "$projectDir\setup_phase3.ps1"
Write-Host ""

Write-Host "[4/6] Adding user authentication..." -ForegroundColor Cyan
& "$projectDir\setup_phase4.ps1"
Write-Host ""

Write-Host "[5/6] Adding user profiles..." -ForegroundColor Cyan
& "$projectDir\setup_phase5.ps1"
Write-Host ""

Write-Host "[6/6] Responsive design and final merge..." -ForegroundColor Cyan
& "$projectDir\setup_phase6.ps1"
Write-Host ""

# Clean up setup scripts
Write-Host "Cleaning up setup scripts..." -ForegroundColor Yellow
Remove-Item "$projectDir\setup_phase1.ps1" -Force
Remove-Item "$projectDir\setup_phase2.ps1" -Force
Remove-Item "$projectDir\setup_phase3.ps1" -Force
Remove-Item "$projectDir\setup_phase4.ps1" -Force
Remove-Item "$projectDir\setup_phase5.ps1" -Force
Remove-Item "$projectDir\setup_phase6.ps1" -Force
Remove-Item "$projectDir\setup_master.ps1" -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Femboard setup complete! 🌸💖✨" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Project created at: $projectDir" -ForegroundColor White
Write-Host "You can now push this to GitHub!" -ForegroundColor White
