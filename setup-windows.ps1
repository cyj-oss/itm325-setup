# ITM 325 setup helper. Run as your normal Windows account.
# Source: https://github.com/cyj-oss/itm325-setup
[CmdletBinding()]
param([switch]$CheckOnly)

function Write-Step([string]$Text) {
    Write-Host "`n$Text" -ForegroundColor Cyan
}

function Get-FirstFile([string[]]$Candidates) {
    foreach ($candidate in $Candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return [IO.Path]::GetFullPath($candidate)
        }
    }
    return $null
}

function Find-VSCode {
    Get-FirstFile @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe",
        "$env:ProgramFiles\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
    )
}

function Find-Git {
    $found = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    $fromPath = if ($found) { $found.Source } else { $null }
    Get-FirstFile @($fromPath, "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
        "$env:ProgramFiles\Git\cmd\git.exe", "${env:ProgramFiles(x86)}\Git\cmd\git.exe")
}

function Find-Claude {
    # Prefer what the student's terminal already runs. Do not replace another installation.
    $found = Get-Command claude.exe,claude.cmd -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    $fromPath = if ($found) { $found.Source } else { $null }
    Get-FirstFile @($fromPath, "$env:USERPROFILE\.local\bin\claude.exe")
}

function Get-ToolVersion([string]$File) {
    if (-not $File) { return $null }
    $result = @(& $File --version 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "The installed program did not start: $File. Please ask your instructor before reinstalling it." }
    return ($result -join ' ').Trim()
}

function Merge-PathEntry([AllowNull()][string]$Existing, [string]$Entry) {
    $normal = [Environment]::ExpandEnvironmentVariables($Entry).Trim().Trim('"').TrimEnd('\')
    foreach ($part in ($Existing -split ';')) {
        $other = [Environment]::ExpandEnvironmentVariables($part).Trim().Trim('"').TrimEnd('\')
        if ([string]::Equals($normal, $other, [StringComparison]::OrdinalIgnoreCase)) { return $Existing }
    }
    if ([string]::IsNullOrWhiteSpace($Existing)) { return $Entry }
    return $Existing.TrimEnd(';') + ';' + $Entry
}

function Add-UserPath([string]$Entry, [string]$BackupDirectory) {
    $old = [Environment]::GetEnvironmentVariable('Path', 'User')
    $updated = Merge-PathEntry $old $Entry
    if ($updated -ne $old) {
        $backup = Join-Path $BackupDirectory 'user-path-before-setup.json'
        if (-not (Test-Path -LiteralPath $backup)) {
            @{ Path = $old } | ConvertTo-Json | Set-Content -LiteralPath $backup -Encoding UTF8
        }
        [Environment]::SetEnvironmentVariable('Path', $updated, 'User')
    }
    $env:Path = Merge-PathEntry $env:Path $Entry
}

function Set-MissingGitDefaults([string]$Git) {
    foreach ($item in @(@('init.defaultBranch', 'main'), @('core.editor', 'code --wait'))) {
        $existing = @(& $Git config --get $item[0] 2>&1)
        $status = $LASTEXITCODE
        if ($status -eq 1) {
            & $Git config --global $item[0] $item[1] | Out-Host
            if ($LASTEXITCODE -ne 0) { throw 'Could not save Git settings. Ask your instructor for help.' }
        } elseif ($status -ne 0) {
            throw 'Git could not read its existing settings. Ask your instructor for help.'
        }
    }
}

function Get-CourseFolder {
    # Reuse an existing course folder; otherwise stay inside the user account.
    if (Test-Path -LiteralPath 'C:\webdev' -PathType Container) { return 'C:\webdev' }
    return Join-Path $env:USERPROFILE 'webdev'
}

function Assert-CourseFolder([string]$Folder) {
    if (Test-Path -LiteralPath $Folder) {
        $item = Get-Item -LiteralPath $Folder -Force
        if (-not $item.PSIsContainer) { throw "A file already uses the course folder name: $Folder. Ask your instructor for help." }
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "The course folder is a shortcut or redirected folder: $Folder. Ask your instructor to choose a local project folder."
        }
    }
}

function Install-CourseGit([string]$LogDirectory) {
    $winget = Get-Command winget.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $winget) {
        throw 'Windows App Installer (winget) is unavailable. Open Setup Help and follow Install Git manually on Windows, then run this helper again. Do not install another package manager.'
    }
    Write-Host 'Downloading and installing Git. This may take several minutes.'
    Write-Host 'Review any Windows permission prompt before continuing.'
    # The explicit package and source avoid ambiguous matches. Hash checks remain enabled.
    # Do not accept agreements on the student's behalf or change Windows execution policy.
    $installArguments = @('install', '--id', 'Git.Git', '--exact', '--source', 'winget', '--silent', '--no-upgrade', '--custom', '/o:EditorOption=VisualStudioCode /o:DefaultBranchOption=main')
    $helpText = @(& $winget.Source install --help 2>&1) -join "`n"
    if ($helpText -match '--output-locale\b') {
        # Newer WinGet versions can translate their interface for this invocation only.
        $installArguments += @('--output-locale', 'en-US')
        & $winget.Source @installArguments | Out-Host
        $installStatus = $LASTEXITCODE
    } else {
        # Older versions follow Windows' language. Keep those details in a local log
        # and show English progress here. Never hide a prompt waiting for an answer.
        $details = Join-Path $LogDirectory ('git-install-' + [guid]::NewGuid().ToString('N') + '.txt')
        Write-Host "Git installation details: $details"
        $installArguments += '--disable-interactivity'
        $savedPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            $LASTEXITCODE = 1
            & $winget.Source @installArguments 2>&1 | Out-File -LiteralPath $details -Encoding UTF8
            $installStatus = $LASTEXITCODE
        } finally { $ErrorActionPreference = $savedPreference }
    }
    if ($installStatus -ne 0) {
        throw "Git installation did not finish (exit code $installStatus). Open Setup Help, follow Install Git manually on Windows, and rerun this helper. If an agreement needs your review, complete it in the manual installer."
    }
}

function Install-CourseClaude([string]$ScratchDirectory) {
    $installer = Join-Path $ScratchDirectory 'claude-official-install.ps1'
    # Download the vendor installer to a private per-run folder. Never execute a partial download.
    $oldProtocol = [Net.ServicePointManager]::SecurityProtocol
    try {
        [Net.ServicePointManager]::SecurityProtocol = $oldProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -UseBasicParsing -Uri 'https://claude.ai/install.ps1' -OutFile $installer -TimeoutSec 90
    } finally { [Net.ServicePointManager]::SecurityProtocol = $oldProtocol }
    $body = [IO.File]::ReadAllText($installer)
    if ($body.Length -lt 100 -or $body.TrimStart().StartsWith('<')) {
        throw 'The Claude download was not an installation script. A network filter may have returned a web page. Stop and ask your instructor.'
    }
    Write-Host 'Installing Claude Code from Anthropic. The download can be quiet for several minutes.'
    $hostProgram = Join-Path $PSHOME 'powershell.exe'
    if (-not (Test-Path -LiteralPath $hostProgram)) { $hostProgram = Join-Path $PSHOME 'pwsh.exe' }
    # Isolate the official installer so its exit statement cannot skip our final checks.
    # The vendor documents the scriptblock form and the stable channel.
    $quoted = $installer.Replace("'", "''")
    $command = "& ([scriptblock]::Create([IO.File]::ReadAllText('$quoted'))) stable"
    & $hostProgram -NoProfile -Command $command | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Claude Code installation failed. See the message above and the troubleshooting guide.' }
}

function Assert-WindowsEnvironment {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'This helper is for Windows. Use the Mac guide on a Mac.' }
    if (-not [Environment]::Is64BitOperatingSystem -or -not [Environment]::Is64BitProcess) {
        throw 'Open Windows PowerShell without the x86 label. This course requires 64-bit Windows.'
    }
    if ([Environment]::OSVersion.Version.Build -lt 17763) { throw 'This Windows version is too old for Claude Code. Ask your instructor before proceeding.' }
    if ($PSVersionTable.PSVersion -lt [version]'5.1') { throw 'Use Windows PowerShell 5.1 or PowerShell 7.' }
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Close this Administrator window. Open a normal PowerShell window and run the helper there.'
    }
}

function Get-SetupLogDirectory { return Join-Path $env:LOCALAPPDATA 'ITM325\setup-logs' }

function Invoke-CourseSetup([switch]$CheckOnly) {
    $savedErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    $transcribing = $false
    $log = $null
    try {
        Write-Host 'ITM 325 | Windows setup' -ForegroundColor Cyan
        Assert-WindowsEnvironment

        Write-Step '[1 of 4] Checking VS Code and existing tools'
        $vscode = Find-VSCode
        if (-not $vscode) { throw 'VS Code was not found in a standard installation location. Complete Step 1 first. For a portable or custom installation, ask your instructor.' }
        Write-Host 'OK: VS Code found.'
        $git = Find-Git
        $claude = Find-Claude
        $folder = Get-CourseFolder
        Assert-CourseFolder $folder
        if ($git) {
            $gitVersion = Get-ToolVersion $git
            if ($gitVersion -notmatch '^git version ') { throw 'The Git version check returned an unexpected result.' }
            Write-Host ('Git: ' + $gitVersion)
        } else { Write-Host 'Git: not installed yet.' }
        if ($claude) {
            $claudeVersion = Get-ToolVersion $claude
            if ($claudeVersion -notmatch 'Claude Code') { throw 'The claude command did not identify itself as Claude Code. Ask your instructor.' }
            Write-Host ('Claude Code: ' + $claudeVersion)
        } else { Write-Host 'Claude Code: not installed yet.' }
        if ($CheckOnly) {
            Write-Host "Course folder: $folder"
            Write-Host 'Check only. No installation or settings changes were made.'
            if (-not $git -or -not $claude -or -not (Test-Path -LiteralPath $folder -PathType Container)) { return 2 }
            Write-Host 'Tools found. Sign-in and a live response still need to be checked in VS Code.'
            return 0
        }

        Write-Host "`nThis helper will install missing Git and Claude Code tools, add their command folders"
        Write-Host 'to your user PATH, set missing Git editor/branch defaults, and prepare the course folder.'
        Write-Host 'It keeps existing working installations and existing Git settings.'
        Write-Host 'It does not sign in, purchase a plan, or send a Claude prompt.'
        $answer = Read-Host 'Type Y to continue, or press Enter to stop'
        if ($answer -notmatch '^(?i)y(es)?$') { Write-Host 'Stopped. No setup changes were made.'; return 3 }

        $logDirectory = Get-SetupLogDirectory
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
        $runId = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
        $log = Join-Path $logDirectory "setup-$runId.txt"
        Start-Transcript -LiteralPath $log | Out-Null
        $transcribing = $true
        $scratch = Join-Path ([IO.Path]::GetTempPath()) ('itm325-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $scratch | Out-Null

        Write-Step '[2 of 4] Preparing Git'
        if (-not $git) { Install-CourseGit $logDirectory; $git = Find-Git }
        if (-not $git) { throw 'Git was not found after installation. Restart Windows if the installer requested it, then rerun the helper.' }
        $gitVersion = Get-ToolVersion $git
        if ($gitVersion -notmatch '^git version ') { throw 'The Git version check returned an unexpected result.' }
        Add-UserPath (Split-Path -Parent $git) $logDirectory
        Add-UserPath (Join-Path (Split-Path -Parent $vscode) 'bin') $logDirectory
        Set-MissingGitDefaults $git
        Write-Host "OK: $gitVersion"

        Write-Step '[3 of 4] Preparing Claude Code'
        if (-not $claude) { Install-CourseClaude $scratch; $claude = Find-Claude }
        if (-not $claude) { throw 'The Claude installer ended, but Claude Code was not found. Do not continue to Step 3. Ask your instructor.' }
        $claudeVersion = Get-ToolVersion $claude
        if ($claudeVersion -notmatch 'Claude Code') { throw 'The claude command did not identify itself as Claude Code. Ask your instructor to check the existing installation.' }
        Add-UserPath (Split-Path -Parent $claude) $logDirectory
        Write-Host "OK: $claudeVersion"

        Write-Step '[4 of 4] Preparing your course folder'
        Assert-CourseFolder $folder
        if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
        $probe = Join-Path $folder ('.itm325-write-check-' + [guid]::NewGuid().ToString('N'))
        try { [IO.File]::WriteAllText($probe, 'write check') }
        finally { if (Test-Path -LiteralPath $probe -PathType Leaf) { Remove-Item -LiteralPath $probe } }
        Write-Host "OK: Course folder: $folder"
        Write-Host "`nREADY FOR STEP 3" -ForegroundColor Green
        Write-Host 'Save any open work, close ALL VS Code and PowerShell windows, then reopen VS Code.'
        Write-Host 'Use the trash can to close any restored terminal before opening a new one.'
        Write-Host "Choose File > Open Folder and select: $folder"
        Write-Host 'Choose Terminal > New Terminal. Use PowerShell. Run: claude --version'
        Write-Host 'Then run: claude'
        Write-Host 'If claude is not recognized, use the quick fix in Step 3 of the Windows guide. Do not reinstall.'
        Write-Host 'Follow Step 3 in the Windows guide to sign in and confirm a response.'
        Write-Host 'This result verifies the installation, not your account access or a Claude response.'
        Write-Host "Local setup log: $log"
        return 0
    } catch {
        Write-Host "`nSETUP STOPPED" -ForegroundColor Yellow
        Write-Host $_.Exception.Message
        Write-Host 'Keep this window open. Capture the error and the last completed step for your instructor.'
        if ($log) { Write-Host "Local setup log: $log" }
        Write-Host 'Help: https://github.com/cyj-oss/itm325-setup/blob/main/TROUBLESHOOTING.md'
        return 1
    } finally {
        if ($transcribing) { Stop-Transcript | Out-Null }
        $ErrorActionPreference = $savedErrorPreference
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    $setupResult = Invoke-CourseSetup -CheckOnly:$CheckOnly
    $global:LASTEXITCODE = [int]$setupResult
}
