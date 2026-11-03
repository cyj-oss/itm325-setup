# Setup Help

[Windows guide](WINDOWS.md) · [Mac guide](MAC.md)

If setup stops, keep the window open. Note the last completed step and the exact error. A different screen does not always mean you did something wrong.

| What you see | What to do next |
| --- | --- |
| VS Code was not found | Finish Step 1 and open VS Code once. On Mac, move it into Applications. Ask your instructor if it is installed somewhere else. |
| A Windows Administrator or x86 warning | Close that window. Open **Windows PowerShell** normally, without **x86** and without **Run as administrator**. |
| Windows App Installer or winget is unavailable | Follow [Install Git manually on Windows](#install-git-manually-on-windows) below, then rerun Step 2. |
| Permission denied or installation blocked | Stop and contact your instructor or IT support. Do not turn off security software or change school-managed restrictions. |
| A download error, 403, or a web page instead of an installer | Check your connection. If it persists, share the exact message with your instructor. The network or account location may restrict the download. |
| The download seems quiet | Some installer downloads do not show progress. Keep the window open. If there is no visible change for about 15 minutes, capture the screen and ask for help before starting a second installation. |
| `claude` is not recognized or `command not found` | Save work and fully quit **all** VS Code windows. Reopen VS Code and create a new terminal. Confirm PowerShell on Windows, or the same Zsh/Bash shell used during Mac setup. If it still fails, rerun Step 2 once. If the error remains, keep the message and contact your instructor; do not keep reinstalling. |
| An existing installation does not start | Keep it in place and send the error to your instructor. The helper stops instead of deleting or replacing it. |
| The course folder is a link, or a file named webdev already exists | Ask your instructor to choose another local project folder. Do not delete existing work. |
| Claude starts but sign-in fails | Confirm you used the same account that has course access. Return to VS Code after browser authorization. Do not buy another subscription to fix an unexplained error. |
| Claude starts but cannot respond | Keep the error. Account access, usage limits, or a network issue may be responsible. Installation alone does not verify access. |
| A terminal command is treated as a message to Claude | Press **Ctrl+C twice** to leave Claude, then run the terminal command. On Mac, use Control, not Command. |

## Install Git manually on Windows

Use this route only when the Windows helper says Git could not be installed automatically. Finish the VS Code installation first.

1. Open the [official Git for Windows download page](https://git-scm.com/install/windows).
2. Under **Standalone Installer**, choose **x64** for an x64 PC or **ARM64** for an ARM PC. To check, open **Windows Settings > System > About > System type**.
3. Open the downloaded installer. Review its license and use the standard installation location.
4. When asked for the default editor, select **Use Visual Studio Code as Git's default editor**.
5. When asked for the initial branch name, choose **Override the default branch name for new repositories** and enter **main**.
6. For the PATH option, select **Git from the command line and also from 3rd-party software**. Leave the other options at their defaults unless your computer's administrator tells you otherwise.
7. Complete the installation. If a release-notes page opens, you can close it. Close PowerShell and open a new normal PowerShell window.
8. Confirm that Git starts.

```powershell
git --version
```

A result beginning with **git version** confirms that Git can run. Return to [Windows Step 2](WINDOWS.md#step-2-set-up-the-course-tools) and run the helper again. It will detect Git and continue with Claude Code. If Windows asks for approval that you cannot provide, contact your instructor or IT support.

## What to send your instructor

Send this through the course's normal help channel. Do not post account details in a public GitHub issue.

```text
My computer: Windows or Mac
My operating system version:
The step I was following: 1, 2, or 3
The last completed helper step:
The exact error message:
I have attached a screenshot of the error.
```

Crop or cover unrelated personal information. Never send passwords, login codes, API keys, or payment details.

If your instructor needs a setup log, the helper prints its location. On Windows it is inside `%LOCALAPPDATA%\ITM325\setup-logs`. On Mac it is inside `~/Library/Logs/ITM325`. These logs stay on your computer. Review them before sharing; they may contain your Windows or Mac username and local folder paths. Login and Claude messages happen after logging has ended.

## Official help

- [Claude Code installation and login troubleshooting](https://code.claude.com/docs/en/troubleshoot-install)
- [VS Code on Windows](https://code.visualstudio.com/docs/setup/windows)
- [VS Code on Mac](https://code.visualstudio.com/docs/setup/mac)
