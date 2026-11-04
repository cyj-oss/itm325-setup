# Windows Setup

[Back to start](README.md)

Before starting, [prepare your Claude account](README.md#prepare-your-claude-account). This guide uses the **Claude Code terminal tool**; having the Claude desktop app does not confirm that the terminal tool is installed.

## Step 1 Install VS Code

**Already installed?** Open your existing VS Code and continue to Step 2.

1. Open the [VS Code download page](https://code.visualstudio.com/download).
2. Choose the Windows **User Installer** for your computer. Most PCs use x64. A Windows ARM PC needs Arm64. If you are unsure, open Windows **Settings > System > About** and look at **System type**.
3. Open the downloaded installer and complete the installation. Use the standard location. Keep **Add to PATH** selected if that option appears. If the Copilot command option appears, choose **Don't add the copilot command**.
4. Open **Visual Studio Code**.

**Check:** The VS Code editor or welcome screen opens.

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

Keep the **Course folder:** location printed by the helper. It reuses `C:\webdev` if present; otherwise it creates `webdev` inside your Windows user folder.

If you see **SETUP STOPPED**, follow [Setup Help](TROUBLESHOOTING.md). Fix the issue before rerunning Step 2. Restart first if the installer requests it.

## Step 3 Connect and test

If you have already completed the course setup, start here.

1. Save your work. Close **all VS Code windows** and the PowerShell window. Open VS Code again so it sees the new command locations.
2. Choose **File > Open Folder**. Open the exact course folder printed by the helper. If VS Code asks about trusting the folder, confirm only after checking that it is your own course folder.
3. Choose **Terminal > New Terminal**. The terminal should be **PowerShell**. If another terminal appears, use the dropdown beside the plus button to open PowerShell.
4. Run this command in that terminal.

```powershell
claude --version
```

**Check:** A version number followed by **Claude Code** appears. If the command is not recognized, stop and use [Troubleshooting](TROUBLESHOOTING.md).

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

[Need help?](TROUBLESHOOTING.md) · [Back to start](README.md)
