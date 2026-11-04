# Mac Setup

[Back to start](README.md)

Before starting, [prepare your Claude account](README.md#prepare-your-claude-account). This guide uses the **Claude Code terminal tool**; having the Claude desktop app does not confirm that the terminal tool is installed.

## Step 1 Install VS Code

**Already installed?** Open VS Code from Applications and continue to Step 2.

1. Open the [VS Code download page](https://code.visualstudio.com/download).
2. Choose **Mac**. The **Universal** download works on both Apple silicon and Intel Macs.
3. Open the downloaded file. With the current `.dmg` installer, drag **Visual Studio Code.app** into **Applications**. If you downloaded a ZIP archive, expand it and move the app into Applications.
4. Open **Visual Studio Code** from Applications.

**Check:** The VS Code editor or welcome screen opens from Applications.

## Step 2 Set up the course tools

Run this step once for the course, even if Claude Code is already installed. The helper keeps working installations and prepares the command location and your course folder.

1. Press **Command+Space**, type **Terminal**, and press Return.
2. Copy the entire command below, paste it into Terminal, and press **Return**.

```bash
course_setup="$(/usr/bin/mktemp /tmp/itm325-setup.XXXXXX)" && /usr/bin/curl --fail --show-error --location --proto '=https' https://raw.githubusercontent.com/cyj-oss/itm325-setup/main/setup-mac.sh --output "$course_setup" && /bin/bash "$course_setup"
```

3. Read the summary, type **Y**, and press Return. Leave the window open. The helper does not need `sudo` or your Mac password; stop and ask your instructor if a password is requested.

**Check:** Wait for:

```text
READY FOR STEP 3
```

Your course folder is **`~/webdev`**: the `webdev` folder inside your Mac home folder.

If you see **SETUP STOPPED**, follow [Setup Help](TROUBLESHOOTING.md). Fix the issue before rerunning Step 2.

## Step 3 Connect and test

If you have already completed the course setup, start here.

1. Save your work. Quit VS Code with **Command+Q** and close Terminal. Open VS Code again.
2. Choose **File > Open Folder**. In the folder selection window, press **Command+Shift+G**, enter **`~/webdev`**, press Return, and open that folder. If VS Code asks about trusting the folder, confirm only after checking that it is your own course folder.
3. Choose **Terminal > New Terminal**. Use **Zsh**, the standard Mac shell. If you normally use Bash instead, select Bash from the terminal dropdown.
4. Run this command in that terminal.

```bash
claude --version
```

**Check:** A version number followed by **Claude Code** appears. If you see **command not found**, stop and use [Troubleshooting](TROUBLESHOOTING.md).

5. Start Claude Code.

```bash
claude
```

6. If asked to sign in, choose **Claude account with a subscription** and use the account you prepared. Complete browser sign-in and return to VS Code. If already signed in, continue. Confirm folder access only for your course folder.
7. Send this in **Claude's message area**:

```text
Please reply with Ready for ITM 325. Do not create, edit, or delete any files. Do not run any commands.
```

**Done:** Claude replies inside VS Code. A version number alone does not confirm account access.

To exit Claude, press **Control+C twice**. Use Control, not Command. Run ordinary terminal commands after leaving Claude, not in its message area.

[Need help?](TROUBLESHOOTING.md) · [Back to start](README.md)
