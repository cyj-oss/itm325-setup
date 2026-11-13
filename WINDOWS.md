# Windows Setup

[Back to start](README.md)

Before starting, [prepare your Claude account](README.md#prepare-your-claude-account). This guide uses the **Claude Code terminal tool**; having the Claude desktop app does not confirm that the terminal tool is installed.

**Already completed setup?** [Check your course folder](#already-completed-setup).

## Step 1 Install VS Code

**Already installed?** Open your existing VS Code and continue to Step 2.

1. Open the [VS Code download page](https://code.visualstudio.com/download).
2. Choose the Windows **User Installer** for your computer. Most PCs use x64. A Windows ARM PC needs Arm64. If you are unsure, open Windows **Settings > System > About** and look at **System type**.
3. Open the downloaded installer and complete the installation. Use the standard location. Keep **Add to PATH** selected if that option appears. If the Copilot command option appears, choose **Don't add the copilot command**.
4. Open **Visual Studio Code**.

**Check:** The VS Code editor or welcome screen opens.

You do not need to sign in to GitHub now. You will connect it in the lesson on uploading your project.

## Step 2 Set up the course tools

Run this step once for the course, even if Claude Code is already installed. The helper keeps working installations and prepares Git, command locations, and your course folder.

1. Open **Windows PowerShell** from the Start menu. Choose the entry **without x86** and open it normally, not as administrator.
2. Copy the entire command below, paste it into PowerShell, and press **Enter**.

```powershell
& ([scriptblock]::Create((Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/cyj-oss/itm325-setup/main/setup-windows.ps1')))
```

3. Read the summary, type **Y**, and press Enter. Leave the window open. Review any permission or license prompt before accepting; if installation is blocked, contact your instructor or IT support.

**Check:** Wait for:

```text
READY FOR STEP 3
```

The helper creates `C:\webdev` on the C drive, or keeps it if it already exists. Check that the result shows **Course folder: C:\webdev**. Existing files are not moved or replaced.

If you see **SETUP STOPPED**, follow [Setup Help](TROUBLESHOOTING.md). Fix the issue before rerunning Step 2. Restart first if the installer requests it.

## Step 3 Connect and test

1. Save your work. Close **all VS Code windows** and the PowerShell window. Open VS Code again so it sees the new command locations.
2. Choose **File > Open Folder**. Open `C:\webdev`. If VS Code asks about trusting the folder, confirm only after checking that it is your own course folder.
3. If VS Code restores an old terminal, close that terminal with its **trash can** button. Choose **Terminal > New Terminal**, then select **PowerShell** from the dropdown beside the plus button if needed.
4. Run this command in that terminal.

```powershell
claude --version
```

**Check:** A version number followed by **Claude Code** appears. If the command is not recognized, use the quick fix below.

<details>
<summary>Quick fix: claude is not recognized</summary>

After Step 2 shows **READY FOR STEP 3**, run these two lines in the same PowerShell terminal. They add Claude's location to this terminal without reinstalling it.

```powershell
$env:Path = "$env:USERPROFILE\.local\bin;" + $env:Path
claude --version
```

If a Claude Code version appears, continue at item 5. If it still fails or returns in a new terminal, use [Windows command help](TROUBLESHOOTING.md#windows-command-help).

</details>

5. Start Claude Code.

```powershell
claude
```

6. If asked to sign in, choose **Claude account with a subscription** and use the account you prepared. Complete browser sign-in and return to VS Code. If already signed in, continue. Confirm folder access only for your course folder.
7. Send this in **Claude's message area**:

```text
Please reply with Ready for ITM 325. Do not create, edit, or delete any files. Do not run any commands.
```

**Done:** Claude replies inside VS Code. A version number alone does not confirm account access.

To exit Claude, press **Ctrl+C twice**. Run ordinary terminal commands after leaving Claude, not in its message area.

## Already completed setup

You do not need to reinstall VS Code, Git, or Claude Code, or rerun Step 2. If your course folder is already `C:\webdev`, continue with Step 3.

If it is `C:\Users\your-name\webdev`:

1. Save your work and close VS Code and Claude Code.
2. In **File Explorer**, enter `%USERPROFILE%` in the address bar and press Enter. Select the entire **webdev** folder and press **Ctrl+C**.
3. Enter `C:\` in the address bar and press Enter, then press **Ctrl+V**. Copy the folder itself so all project files, including hidden files, stay together. If `C:\webdev` already exists, do not merge or replace folders; ask your instructor before combining any work.
4. In VS Code, choose **File > Open Folder > C:\webdev**. Confirm your files are there, then follow Step 3 using this folder. Keep the original folder as a backup.

If Windows blocks the copy, contact your instructor or IT support.

[Need help?](TROUBLESHOOTING.md) · [Back to start](README.md)
