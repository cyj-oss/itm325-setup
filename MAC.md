# Mac Setup

[Back to computer selection](README.md)

Follow these three steps in order. You will finish with Claude Code responding inside VS Code. Before you begin, sign in at [claude.ai](https://claude.ai/) and confirm that your account has Claude Code access through a Pro or higher subscription or an eligible organization plan. Use that same account in Step 3. If you need account help, see [Prepare your Claude account](README.md#prepare-your-claude-account).

## Step 1 Install VS Code

1. Open the [official VS Code download page](https://code.visualstudio.com/download).
2. Choose **Mac**. The **Universal** download works on both Apple silicon and Intel Macs.
3. Open the downloaded file. With the current `.dmg` installer, drag **Visual Studio Code.app** into **Applications**. If you downloaded a ZIP archive, expand it and move the app into Applications.
4. Open **Visual Studio Code** from Applications. You may skip optional account sign-in, customization, and extension suggestions.

**Check before moving on:** VS Code opens to its editor or welcome screen. It should be in Applications, not running from the download or a mounted installer window.

## Step 2 Set up the course tools

1. Press **Command+Space**, type **Terminal**, and press Return.
2. Copy the entire command below, paste it into Terminal, and press **Return**.

```bash
course_setup="$(/usr/bin/mktemp /tmp/itm325-setup.XXXXXX)" && /usr/bin/curl --fail --show-error --location --proto '=https' https://raw.githubusercontent.com/cyj-oss/itm325-setup/main/setup-mac.sh --output "$course_setup" && /bin/bash "$course_setup"
```

3. Read the setup summary. Type **Y** and press Return to continue. Leave the window open while the helper works. It installs missing Claude Code, prepares its command location, and creates your course folder. It does not need `sudo` or your Mac password. If a password is requested unexpectedly, stop and ask your instructor.

**Wait for this exact result:**

```text
READY FOR STEP 3
```

The course folder is **`~/webdev`**. The tilde means your Mac home folder. Existing files in that folder remain in place.

If you see **SETUP STOPPED**, do not continue yet. Read the reason and use [Troubleshooting](TROUBLESHOOTING.md). After fixing the issue, you can run the same command again; the helper checks existing installations first.

## Step 3 Connect and test

1. Save your work. Quit VS Code with **Command+Q** and close Terminal. Open VS Code again.
2. Choose **File > Open Folder**. In the folder selection window, press **Command+Shift+G**, enter **`~/webdev`**, press Return, and open that folder. If VS Code asks about trusting the folder, confirm only after checking that it is your own course folder.
3. Choose **Terminal > New Terminal**. Use **Zsh**, the standard Mac shell. If you normally use Bash instead, select Bash from the terminal dropdown.
4. Run this command in that terminal.

```bash
claude --version
```

**Check:** A version number followed by **Claude Code** appears. The version number may change as the software updates. If you see **command not found**, stop and use [Troubleshooting](TROUBLESHOOTING.md).

5. Start Claude Code.

```bash
claude
```

6. Follow the first-run prompts. If asked, choose the option for a **Claude account with a subscription**, then sign in through the browser using your course account. Return to VS Code when sign-in finishes. Review any folder-access prompt and confirm only for your course folder. The order and wording of these screens may change.
7. In **Claude's message area**, send this message.

```text
Please reply with Ready for ITM 325. Do not create, edit, or delete any files. Do not run any commands.
```

**You are done when:** VS Code is open, your course folder is open, Claude is signed in, and Claude replies to your message. The reply may contain extra words. A version number alone does not confirm account access.

To exit Claude, press **Control+C twice**. Use Control, not Command. Run ordinary terminal commands after leaving Claude, not in its message area.

[Need help?](TROUBLESHOOTING.md) · [Back to start](README.md)
