# Local, isolated tests. No downloads, installations, user PATH edits, or real Git settings.
$ErrorActionPreference = 'Stop'
$helperFile = Join-Path $PSScriptRoot 'setup-windows.ps1'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('itm325-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null
$testCount = 0

function Assert-True($Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
    $script:testCount++
    Write-Host "PASS: $Message"
}

function Assert-Throws([scriptblock]$Action, [string]$Message) {
    $caught = $false
    try { & $Action } catch { $caught = $true }
    Assert-True $caught $Message
}

function Result-Code($Output) {
    $codes = @($Output | Where-Object { $_ -is [int] })
    if ($codes.Count -ne 1) { throw 'The helper did not return exactly one numeric result.' }
    return $codes[0]
}

$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile($helperFile, [ref]$tokens, [ref]$parseErrors) | Out-Null
Assert-True ($parseErrors.Count -eq 0) 'PowerShell parser accepts the helper'
. $helperFile

Assert-True ((Merge-PathEntry 'C:\Tools' 'C:\New') -eq 'C:\Tools;C:\New') 'PATH append preserves existing entries'
Assert-True ((Merge-PathEntry 'C:\Tools;C:\New\' 'c:\new') -eq 'C:\Tools;C:\New\') 'PATH comparison ignores case and trailing slash'
Assert-True ((Merge-PathEntry '' 'C:\New') -eq 'C:\New') 'Empty PATH has no leading empty search entry'
$variablePath = '%USERPROFILE%\.local\bin'
Assert-True ((Merge-PathEntry $variablePath "$env:USERPROFILE\.local\bin") -eq $variablePath) 'PATH detects existing environment-variable form'

$collision = Join-Path $testRoot 'webdev-file'
[IO.File]::WriteAllText($collision, 'student work')
Assert-Throws { Assert-CourseFolder $collision } 'A file collision stops setup'
Assert-True ([IO.File]::ReadAllText($collision) -eq 'student work') 'A collision leaves student data intact'

$script:gitValues = @{'core.editor'='existing-editor'; 'init.defaultBranch'='existing-branch'}
$script:gitWrites = @()
function Fake-Git {
    if ($args[0] -ne 'config') { throw 'Unexpected fake Git command' }
    if ($args[1] -eq '--get') {
        if ($script:gitValues.ContainsKey($args[2])) { $global:LASTEXITCODE = 0; $script:gitValues[$args[2]] }
        else { $global:LASTEXITCODE = 1 }
    } else {
        $script:gitWrites += ($args[2] + '=' + $args[3])
        $global:LASTEXITCODE = 0
    }
}
Set-MissingGitDefaults 'Fake-Git'
Assert-True ($script:gitWrites.Count -eq 0) 'Existing Git preferences are preserved'
$script:gitValues = @{}
Set-MissingGitDefaults 'Fake-Git'
Assert-True ($script:gitWrites -contains 'core.editor=code --wait') 'Missing editor is configured'
Assert-True ($script:gitWrites -contains 'init.defaultBranch=main') 'Missing branch default is configured'
function Broken-Git { $global:LASTEXITCODE = 128 }
Assert-Throws { Set-MissingGitDefaults 'Broken-Git' } 'Git configuration errors stop setup'

# Simulate localized WinGet output without downloading or installing Git.
$script:wingetEnglishOption = $true
$script:wingetExitStatus = 0
$script:wingetArguments = @()
$script:localizedOutput = [string][char]0xCC3E + [char]0xC74C + ' Git'
function Fake-Winget {
    if ($args -contains '--help') {
        if ($script:wingetEnglishOption) { '--output-locale <language>' } else { '--disable-interactivity' }
        Set-Variable -Name LASTEXITCODE -Value 0 -Scope 1
        return
    }
    $script:wingetArguments = @($args)
    if ($args -contains '--output-locale') { 'Git installation completed.' }
    else { $script:localizedOutput }
    Set-Variable -Name LASTEXITCODE -Value $script:wingetExitStatus -Scope 1
}
function Get-Command { [pscustomobject]@{ Source = 'Fake-Winget' } }
try {
    Install-CourseGit $testRoot
    Assert-True ($script:wingetArguments -contains '--output-locale' -and $script:wingetArguments -contains 'en-US') 'Modern WinGet uses English for this command only'
    Assert-True ($script:wingetArguments -notcontains '--disable-interactivity') 'Visible English agreement prompts remain available'
    $script:wingetEnglishOption = $false
    $out = @(Install-CourseGit $testRoot 6>&1)
    Assert-True (($out -join "`n") -notmatch [regex]::Escape($script:localizedOutput)) 'Legacy WinGet does not print localized output on screen'
    $detailLog = Get-ChildItem -LiteralPath $testRoot -Filter 'git-install-*.txt' | Select-Object -First 1
    Assert-True ((Get-Content -LiteralPath $detailLog.FullName -Raw) -match [regex]::Escape($script:localizedOutput)) 'Original installer details remain available in a local log'
    Assert-True ($script:wingetArguments -contains '--disable-interactivity') 'Legacy WinGet cannot wait for a hidden prompt'
    Assert-True (($script:wingetArguments -join ' ') -notmatch '--accept-.*agreements|--ignore-security-hash') 'Agreements and installer hash checks are not bypassed'
    $script:wingetExitStatus = 5
    Assert-Throws { Install-CourseGit $testRoot } 'Legacy installer failure stops setup'
    $script:wingetEnglishOption = $true
    Assert-Throws { Install-CourseGit $testRoot } 'English installer failure stops setup'
} finally { Remove-Item Function:\Get-Command }

# Mock the operating system boundary to test orchestration without changing this machine.
. $helperFile
function Assert-WindowsEnvironment { }
function Find-VSCode { return $null }
$out = @(Invoke-CourseSetup -CheckOnly 6>&1)
Assert-True ((Result-Code $out) -eq 1) 'Missing VS Code stops before installation'
Assert-True (($out -join "`n") -notmatch 'READY FOR STEP 3') 'Failure never displays the ready banner'

function Find-VSCode { return 'C:\Fake VS Code\Code.exe' }
function Find-Git { return $null }
function Find-Claude { return $null }
function Get-CourseFolder { return (Join-Path $testRoot 'not-created') }
$out = @(Invoke-CourseSetup -CheckOnly 6>&1)
Assert-True ((Result-Code $out) -eq 2) 'Check-only reports missing tools as incomplete'
Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot 'not-created'))) 'Check-only does not create a project folder'
function Read-Host { return '' }
$out = @(Invoke-CourseSetup 6>&1)
Assert-True ((Result-Code $out) -eq 3) 'Declining the prompt cancels setup'
Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot 'not-created'))) 'Cancellation does not create a project folder'

function Find-Git { return 'fake-git' }
function Find-Claude { return 'fake-claude' }
function Get-ToolVersion([string]$File) {
    if ($File -eq 'fake-git') { return 'git version 2.50.0' }
    return '2.1.0 (Claude Code)'
}
$project = Join-Path $testRoot 'project with spaces'
New-Item -ItemType Directory -Path $project | Out-Null
$sentinel = Join-Path $project 'student-work.txt'
[IO.File]::WriteAllText($sentinel, 'keep this work')
function Get-CourseFolder { return $project }
$out = @(Invoke-CourseSetup -CheckOnly 6>&1)
Assert-True ((Result-Code $out) -eq 0) 'Check-only recognizes existing tools and folder'

# Install paths and settings are spies. Only our temporary test project can be written.
function Read-Host { return 'Y' }
function Get-SetupLogDirectory { return (Join-Path $testRoot 'logs') }
function Start-Transcript { }
function Stop-Transcript { }
$script:pathWrites = @()
function Add-UserPath([string]$Entry, [string]$BackupDirectory) { $script:pathWrites += $Entry }
function Set-MissingGitDefaults([string]$Git) { }
function Install-CourseGit { throw 'Existing Git must not be reinstalled' }
function Install-CourseClaude { throw 'Existing Claude must not be reinstalled' }
$out = @(Invoke-CourseSetup 6>&1)
Assert-True ((Result-Code $out) -eq 0) 'Existing healthy tools complete without reinstalling'
Assert-True (($out -join "`n") -match 'READY FOR STEP 3') 'Ready banner appears after successful checks'
Assert-True ([IO.File]::ReadAllText($sentinel) -eq 'keep this work') 'Successful setup preserves student files'
Assert-True (@(Get-ChildItem -LiteralPath $project -Filter '.itm325-write-check-*' -Force).Count -eq 0) 'Folder write probe is cleaned up'

function Find-Claude { return $null }
function Install-CourseClaude { throw 'Simulated download failure' }
$out = @(Invoke-CourseSetup 6>&1)
Assert-True ((Result-Code $out) -eq 1) 'A Claude download failure stops setup'
Assert-True (($out -join "`n") -notmatch 'READY FOR STEP 3') 'Download failure cannot report success'

function Find-Claude { return 'fake-claude' }
function Get-ToolVersion([string]$File) {
    if ($File -eq 'fake-git') { return 'git version 2.50.0' }
    return 'An unrelated command'
}
$out = @(Invoke-CourseSetup -CheckOnly 6>&1)
Assert-True ((Result-Code $out) -eq 1) 'A conflicting claude command is rejected'

Write-Host "`nAll $testCount Windows checks passed. No software was installed."
Write-Host "Test artifacts: $testRoot"# The fake commands deliberately set nonzero native exit codes in failure tests.
# Do not let the CI shell treat that leftover test state as the suite result.
$global:LASTEXITCODE = 0
