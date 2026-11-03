# Instructor Notes

## Scope

This repository supports the first recording lesson: install VS Code, prepare Claude Code, sign in, and get a response inside the VS Code terminal. It follows the guidebook's terminal workflow. It does not install the separate Claude Code extension, ESLint, Prettier, Node.js, Python, Homebrew, or Xcode. Those are not required for this lesson's completion check.

The helper is original course code. It borrows the general idea of a guided setup from [JuiceIt](https://github.com/chunw4h/juiceit); its source was not copied. The guidebook screenshots are supplied course material.

## Student flow and recording

Show the README first, then the relevant Windows or Mac guide. Explain the purpose of each tool, pause for each installation step, and demonstrate the final response check. Students follow only their operating system's path.

| Recording segment | Printed guidebook pages | Completion check |
| --- | --- | --- |
| Account preparation | 12 to 14 | The student has the course account and access plan. |
| Step 1, VS Code | 27 to 28 | VS Code opens. |
| Step 2, Windows helper | 14 to 20, 23 | READY FOR STEP 3 and a course folder location. |
| Step 2, Mac helper | 21 to 23 | READY FOR STEP 3 and a course folder location. |
| Step 3, connection and test | 23 to 24, 30 to 31 | Claude responds inside VS Code. |

The existing DOCX remains the detailed reference. This repository changes the installation delivery, not the later coding workflow. Existing recording slides have not been revised to demonstrate this helper yet.

## Implementation choices

- VS Code is installed manually from Microsoft and opened once first. Windows User Setup is recommended. Mac supports Applications or the user's Applications folder.
- Windows installs missing Git through the explicit `Git.Git` package in the `winget` source. It does not install or repair winget. If it is unavailable, students use the guidebook's Git procedure and rerun the helper. Permission and agreement prompts remain visible; hash checks stay enabled.
- Existing Git settings are preserved. Missing default branch and editor settings become `main` and `code --wait`. Student name and email are deferred to the Git lesson, not fabricated or copied from placeholders.
- Current Claude documentation treats Git as optional for basic native Windows use. It is included here to match later course work and the guidebook. Mac Git setup is deferred to the Git lesson.
- Missing Claude Code is installed using Anthropic's native installer with the `stable` channel. Existing working installations are kept, including their existing update channel. This does not pin every student to the same version.
- Windows adds only missing entries to **User PATH**, preserving its existing value and keeping a local backup before the first change. It does not change PowerShell execution policy or system PATH. It refuses to run in an elevated PowerShell window.
- Mac appends the native command location to the active default Zsh or Bash startup file, with a backup when the file already exists. It does not replace or source the student's settings. Custom shells, a detected custom ZDOTDIR, linked settings files, or nonwritable files require instructor assistance.
- Windows reuses `C:\webdev` if it exists; otherwise it uses `%USERPROFILE%\webdev`. Mac uses `~/webdev`. This avoids creating a new folder at the Windows drive root when the student lacks permission. Existing files are preserved. Linked/redirected course folders are rejected for manual review.
- Setup logs stay local and end before login. The helper never requests account credentials or sends diagnostic data.
- No OS protection is disabled. No subscription, terms acceptance, folder trust, or Claude permission prompt is answered automatically by this helper.

## Checks before assigning the guide

Code-level checks and mocked tests are useful, but **a fresh installation on both operating systems is still required before class distribution**. Running tests on a development machine is not a Windows/Mac installation pilot.

- [ ] Windows x64, fresh normal user account, VS Code User Setup, Git missing, Claude missing.
- [ ] Windows with Git and Claude already installed: existing settings and projects remain intact.
- [ ] Windows without winget: clear stop message and successful manual Git fallback.
- [ ] A supported Apple silicon Mac, VS Code in Applications, Claude missing.
- [ ] A supported Intel Mac if the class uses one.
- [ ] A Windows ARM PC if the class uses one.
- [ ] A username containing spaces; existing webdev folder containing student files.
- [ ] Run each helper a second time: no duplicated path lines, no reinstall of working tools.
- [ ] Quit and reopen VS Code. Verify `claude --version` in a new terminal, then sign in and receive a response.
- [ ] Stop or disconnect during a download: no success banner; rerunning recovers or produces an actionable error.
- [ ] Confirm account access and classroom network access using a student-like account.

For a diagnostic pass without installation or settings changes, run the Windows helper with `-CheckOnly` or the Mac helper with `--check`. A tools-found result is not a login test. Exit results are 0 for tools/folder present or completed setup, 1 for error, 2 for an incomplete check-only result, and 3 for a cancelled setup. Windows leaves the interactive terminal open and sets `$LASTEXITCODE`.

After the pilot, record the tested OS and app versions here, then freeze the tested helper revision for the recording. The initial copy commands point to `main`, so changing that branch changes what students run. Replace `main` in both student commands with a tested immutable commit ID before a class rollout. Keep the readable guide links on `main` if desired.

## Maintenance

Review the official install pages before each class offering. Recheck changes to authentication screens, OS requirements, download names, Git package availability, and native installation behavior. Keep the two operating-system guides at three student-facing steps.

Local backups and temporary installer files are deliberately retained for diagnosis. There is no automatic uninstaller or reset command that could remove an existing development environment. Discuss any cleanup individually.

## Sources

Reviewed on November 2, 2026.

- [Claude Code setup, system requirements, accounts, and stable installation](https://code.claude.com/docs/en/setup)
- [Claude Code command location and troubleshooting](https://code.claude.com/docs/en/troubleshoot-install)
- [Claude Code in VS Code and standalone CLI requirements](https://code.claude.com/docs/en/vs-code)
- [VS Code on Windows](https://code.visualstudio.com/docs/setup/windows)
- [VS Code on Mac](https://code.visualstudio.com/docs/setup/mac)
- [Git for Windows download options](https://git-scm.com/install/windows)
- [Git for Windows unattended installer options](https://gitforwindows.org/silent-or-unattended-installation.html)
- [Microsoft winget install command](https://learn.microsoft.com/en-us/windows/package-manager/winget/install)
