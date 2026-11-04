# Setup Help

[Windows guide](WINDOWS.md) · [Mac guide](MAC.md)

Keep the error window open and find the matching message below.

| What you see | What to do |
| --- | --- |
| VS Code was not found | Finish Step 1. On Mac, move the app into Applications. Ask your instructor about a custom installation location. |
| A Windows Administrator or x86 warning | Open normal **Windows PowerShell**, without **x86** or **Run as administrator**. |
| Windows App Installer or winget is unavailable | Follow [Install Git manually on Windows](#install-git-manually-on-windows), then rerun Step 2. |
| Permission denied or installation blocked | Contact your instructor or IT support. Keep security software and managed restrictions in place. |
| Download error, 403, or a web page instead of an installer | Check your connection. If the error persists, send the exact message to your instructor. |
| No download progress | Keep the window open. After about 15 minutes without a visible change, capture the screen and ask for help before starting another installation. |
| The Claude app works, but the terminal command does not | This course uses the **Claude Code terminal tool**. Run Step 2 in your setup guide. |
| `claude` is not recognized or `command not found` | Use the Step 3 quick fix: [Windows](WINDOWS.md#step-3-connect-and-test) or [Mac](MAC.md#step-3-connect-and-test). Do not reinstall just because the command is missing. |
| A terminal warning says the environment is stale | When no command is running, close that terminal with its **trash can** button and choose **Terminal > New Terminal**. If Claude is still not found, use the quick fix above. |
| An existing installation does not start | Keep it in place and send the error to your instructor. |
| The course folder is a link, or a file named webdev already exists | Ask your instructor to choose another local folder. Keep existing files. |
| Claude sign-in fails | Use the account with Claude Code access and return to VS Code after browser sign-in. Ask for help before buying another subscription. |
| Claude opens but cannot reply | Send the error to your instructor. Check account access, usage limits, and your connection. |
| A terminal command is treated as a message to Claude | Press **Ctrl+C twice** to leave Claude, then run the command. On Mac, use Control. |

## Claude is not found after setup

VS Code can restore an old terminal with its previous command locations, even after you reopen the app. Close the old terminal with the **trash can** button, then open a new one. The panel's **X** button only hides it.

If the Step 3 quick fix does not solve the problem, check the installation directly below.

### Windows command help

In the VS Code **PowerShell** terminal, run:

```powershell
& "$env:USERPROFILE\.local\bin\claude.exe" --version
```

If a Claude Code version appears, the installation works. Use the Windows quick fix in Step 3 to continue in that terminal. If new terminals still cannot find Claude, save your work, restart Windows, and try a new VS Code terminal. If the problem remains, send the error to your instructor.

If the direct command fails, send its exact error to your instructor before reinstalling. An existing installation may use a different location.

### Mac command help

In the VS Code **Zsh or Bash** terminal, run:

```bash
"$HOME/.local/bin/claude" --version
```

If a Claude Code version appears, the installation works. Use the Mac quick fix in Step 3 to continue in that terminal. If the problem returns in new terminals, rerun Step 2 once to save the command location for your usual shell. The helper keeps a working installation. Then quit VS Code with **Command+Q**, reopen it, and create a new terminal in that same shell. If the problem remains, send the error to your instructor.

If the direct command fails, send its exact error to your instructor before reinstalling. An existing installation may use a different location.

## Install Git manually on Windows

Use this route if the helper cannot install Git. Complete VS Code Step 1 first.

1. Open the [Git for Windows download page](https://git-scm.com/install/windows).
2. Under **Standalone Installer**, choose **x64** or **ARM64** to match **Windows Settings > System > About > System type**.
3. Run the installer, review the license, and use the standard location.
4. For the default editor, select **Use Visual Studio Code as Git's default editor**.
5. For the initial branch name, choose **Override the default branch name for new repositories** and enter **main**.
6. For PATH, select **Git from the command line and also from 3rd-party software**. Keep the remaining defaults.
7. Finish installation and open a new normal PowerShell window.
8. Run:

```powershell
git --version
```

If **git version** appears, rerun [Windows Step 2](WINDOWS.md#step-2-set-up-the-course-tools). If installation is blocked, contact your instructor or IT support.

## What to send your instructor

Use the course help channel.

```text
My computer: Windows or Mac
My operating system version:
The step I was following: 1, 2, or 3
The last completed helper step:
The exact error message:
I have attached a screenshot of the error.
```

Remove unrelated personal information. Do not share passwords, login codes, API keys, or payment details, or post account information in public GitHub issues.

If a setup log is requested, use the location printed by the helper. Review it before sharing; it may include your username and local folder paths.

## Official help

- [Claude Code installation and login](https://code.claude.com/docs/en/troubleshoot-install)
- [VS Code on Windows](https://code.visualstudio.com/docs/setup/windows)
- [VS Code on Mac](https://code.visualstudio.com/docs/setup/mac)
