# Mac Setup

[Choose a different computer](README.md)

**Finish all 3 steps. Stop when Claude replies inside VS Code.**

Have your [Claude account](README.md#prepare-your-claude-account) ready. **GitHub sign-in comes later.**

## Step 1 Install VS Code

**Where: Your browser and Applications folder**

1. Open the [VS Code download page](https://code.visualstudio.com/download). Choose **Mac → Universal**.
2. Open the download and drag **Visual Studio Code.app** into **Applications**. If the download is a ZIP, expand it first, then move the app.
3. Open **Visual Studio Code from Applications**.

**Already installed?** Open your existing VS Code from Applications.

> **CHECK 1 — VS Code opens from Applications. Continue to Step 2.**

<details>
<summary>From Lesson 3.2 and only needed VS Code?</summary>

Once VS Code opens, continue with the extensions in the book.

[![Return to book — Lesson 3.2, Step 2](https://raw.githubusercontent.com/cyj-oss/itm325-vibecoding/main/return-to-book.svg)](https://cyj-oss.github.io/itm325-vibecoding/#lesson=3.2&step=1)

</details>

## Step 2 Set up the course tools

1. Press **Command+Space**, type **Terminal**, and press **Return**.
2. Paste this entire command into Terminal. Press **Return**.

> **Where to paste:** **Mac Terminal app** · opened with Command+Space

```bash
course_setup="$(/usr/bin/mktemp /tmp/itm325-setup.XXXXXX)" && /usr/bin/curl --fail --show-error --location --proto '=https' https://raw.githubusercontent.com/cyj-oss/itm325-setup/main/setup-mac.sh --output "$course_setup" && /bin/bash "$course_setup"
```

3. Read the summary. Type **Y**, press **Return**, and wait. No Mac password is needed; ask your instructor if one is requested.

> **CHECK 2 — READY FOR STEP 3 appears. Continue to Step 3.**
>
> Look for this message; do not type it. Setup creates **webdev** inside your **Mac home folder**.

**If you see SETUP STOPPED:** stop here and open [Setup Help](TROUBLESHOOTING.md).

<details>
<summary>What does this helper do? What if Claude Code is already installed?</summary>

It prepares Claude Code, its command location, and **~/webdev**. It keeps a working installation and existing files. Run it once for this course even if Claude Code is already installed.

If you already completed this course setup, go to Step 3.

</details>

## Step 3 Connect and test

### A. Open a fresh terminal in VS Code

1. Save your work. Quit VS Code with **Command+Q**, close Terminal, and reopen VS Code.
2. Choose **File → Open Folder → your home folder → webdev → Open**. Your home folder is named after your Mac user account. Confirm trust only for your own course folder.
3. Close any restored terminal with its **trash can** button. Choose **Terminal → New Terminal**. Use **Zsh**, or your usual **Bash** shell.

### B. Check Claude Code

Paste and press **Return**.

> **Where to paste:** VS Code terminal · **Zsh or Bash**

```bash
claude --version
```

> **CHECK — A version number and Claude Code appear. Continue to C.**
>
> Your version number may differ. You are not finished yet.

<details>
<summary>Error: command not found</summary>

After Step 2 shows **READY FOR STEP 3**, copy both lines together and run them:

> **Where to paste:** VS Code terminal · **Zsh or Bash**

```bash
export PATH="$HOME/.local/bin:$PATH"
claude --version
```

If a Claude Code version appears, continue to C. If it still fails or happens again in a new terminal, use [Mac command help](TROUBLESHOOTING.md#mac-command-help).

</details>

### C. Start Claude and sign in

Paste and press **Return**.

> **Where to paste:** VS Code terminal · **Zsh or Bash**

```bash
claude
```

Follow the prompts. Choose **Claude account with a subscription** if asked. Sign in with your prepared Claude account in the browser, then return to VS Code. Already signed in? Continue. Confirm folder access only for **webdev**.

### D. Get a reply

Paste and press **Return** to send.

> **Where to paste:** **Claude Code input** · in the VS Code terminal panel

```text
Please reply with Ready for ITM 325. Do not create, edit, or delete any files. Do not run any commands.
```

> **DONE — Claude replies inside VS Code.**
>
> Look for **Ready for ITM 325**. Extra words are fine.  
> **Stop here. Installation is complete.**

[![Return to book — Lesson 2.5, Step 1](https://raw.githubusercontent.com/cyj-oss/itm325-vibecoding/main/return-to-book.svg)](https://cyj-oss.github.io/itm325-vibecoding/#lesson=2.5&step=0)

If Claude cannot reply, open [Setup Help](TROUBLESHOOTING.md).

<details>
<summary>How do I exit Claude?</summary>

Press **Control+C twice**. Use Control, not Command. Run ordinary terminal commands after leaving Claude, not in its message area.

</details>

[Need help?](TROUBLESHOOTING.md) · [Back to start](README.md)