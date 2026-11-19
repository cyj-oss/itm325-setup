# Windows Setup

[Choose a different computer](README.md)

**Finish all 3 steps. Stop when Claude replies inside VS Code.**

Have your [Claude account](README.md#prepare-your-claude-account) ready. **GitHub sign-in comes later.**

## Step 1 Install VS Code

**Where: Your browser and the downloaded installer**

1. Open the [VS Code download page](https://code.visualstudio.com/download). Choose **Windows → User Installer → x64** for most PCs. For an ARM PC, choose **Arm64**.
2. Run the installer. Keep **Add to PATH** selected if shown.
3. Open **Visual Studio Code**.

**Already installed?** Open your existing VS Code.

> **CHECK 1 — VS Code is open. Continue to Step 2.**

<details>
<summary>Not sure which download or installer options to choose?</summary>

Check **Windows Settings → System → About → System type** for x64 or ARM. Use the standard installation location. If a Copilot command option appears, choose **Don't add the copilot command**.

</details>

## Step 2 Set up the course tools

**Where: Windows PowerShell, opened from the Start menu**

1. Search for **Windows PowerShell** and open it normally. Choose **without x86** and **without Run as administrator**. Use PowerShell, **not Command Prompt**.
2. Paste this entire command into PowerShell. Press **Enter**.

```powershell
& ([scriptblock]::Create((Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/cyj-oss/itm325-setup/main/setup-windows.ps1')))
```

3. Read the summary. Type **Y**, press **Enter**, and wait. Review any installation permission or license prompt before accepting.

> **CHECK 2 — Find both results on your screen:**
>
> **READY FOR STEP 3**  
> **Course folder: C:\webdev**
>
> **Then continue to Step 3.** Look for these messages; do not type them.

**If you see SETUP STOPPED:** stop here and open [Setup Help](TROUBLESHOOTING.md). Restart first if the installer requests it.

<details>
<summary>What does this helper do? What if tools are already installed?</summary>

It prepares Git, Claude Code, command locations, and **C:\webdev**. It keeps working installations and existing files. Run it once for this course even if Claude Code is already installed.

If you already completed this course setup, go to Step 3. If you used an older course folder, see [folder help](#already-completed-setup) first.

</details>

## Step 3 Connect and test

### A. Open a fresh terminal in VS Code

1. Save your work. Close **all VS Code windows** and PowerShell. Reopen VS Code.
2. Choose **File → Open Folder** and open **C:\webdev**. If asked about trust, confirm only for your own course folder.
3. If an old terminal appears, close it with its **trash can** button. Choose **Terminal → New Terminal**. Select **PowerShell** from the dropdown beside **+** if needed.

### B. Check Claude Code

**VS Code PowerShell terminal — paste and press Enter:**

```powershell
claude --version
```

> **CHECK — A version number and Claude Code appear. Continue to C.**
>
> Your version number may differ. You are not finished yet.

<details>
<summary>Error: claude is not recognized</summary>

After Step 2 shows **READY FOR STEP 3**, run these lines in the same PowerShell terminal:

```powershell
$env:Path = "$env:USERPROFILE\.local\bin;" + $env:Path
claude --version
```

If a Claude Code version appears, continue to C. If it still fails or happens again in a new terminal, use [Windows command help](TROUBLESHOOTING.md#windows-command-help).

</details>

### C. Start Claude and sign in

**Same VS Code PowerShell terminal — paste and press Enter:**

```powershell
claude
```

Follow the prompts. Choose **Claude account with a subscription** if asked. Sign in with your prepared Claude account in the browser, then return to VS Code. Already signed in? Continue. Confirm folder access only for **C:\webdev**.

### D. Get a reply

**Claude's message area in VS Code — paste and press Enter:**

```text
Please reply with Ready for ITM 325. Do not create, edit, or delete any files. Do not run any commands.
```

> **DONE — Claude replies inside VS Code.**
>
> Look for **Ready for ITM 325**. Extra words are fine.  
> **Stop here. Installation is complete.**

If Claude cannot reply, open [Setup Help](TROUBLESHOOTING.md).

<details>
<summary>How do I exit Claude?</summary>

Press **Ctrl+C twice**. Run ordinary terminal commands after leaving Claude, not in its message area.

</details>

## Already completed setup

<details>
<summary>My old course folder is under C:\Users\my-name\webdev</summary>

You do not need to reinstall the tools or rerun Step 2. If your course folder is already **C:\webdev**, use Step 3.

If it is **C:\Users\your-name\webdev**:

1. Save your work and close VS Code and Claude Code.
2. In **File Explorer**, enter **%USERPROFILE%** in the address bar and press Enter. Select the entire **webdev** folder and press **Ctrl+C**.
3. Enter **C:\** in the address bar, press Enter, and press **Ctrl+V**. Copy the entire folder so hidden files stay together. If **C:\webdev** already exists, do not merge or replace folders; ask your instructor before combining work.
4. In VS Code, open **C:\webdev**. Confirm your files are there, then follow Step 3. Keep the original folder as a backup.

If Windows blocks the copy, contact your instructor or IT support.

</details>

[Need help?](TROUBLESHOOTING.md) · [Back to start](README.md)
