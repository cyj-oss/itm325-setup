#!/bin/bash
# ITM 325 setup helper. Compatible with the Bash 3.2 shipped with macOS.
# Source: https://github.com/cyj-oss/itm325-setup

fail() {
    printf '\nSETUP STOPPED\n%s\n' "$1" >&2
    printf 'Keep this window open. Capture the error and the last completed step for your instructor.\n' >&2
    [ -z "${SETUP_LOG:-}" ] || printf 'Local setup log: %s\n' "$SETUP_LOG" >&2
    printf 'Help: https://github.com/cyj-oss/itm325-setup/blob/main/TROUBLESHOOTING.md\n' >&2
    return 1
}

step() { printf '\n%s\n' "$1"; }

is_vscode_app() {
    local app="$1" plist bundle_id executable
    plist="$app/Contents/Info.plist"
    [ -f "$plist" ] || return 1
    bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$plist" 2>/dev/null) || return 1
    [ "$bundle_id" = 'com.microsoft.VSCode' ] || return 1
    # Read the executable name from the app, rather than assuming Electron or Code.
    executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$plist" 2>/dev/null) || return 1
    case "$executable" in ''|.|..|*/*) return 1 ;; esac
    [ -f "$app/Contents/MacOS/$executable" ] && [ -x "$app/Contents/MacOS/$executable" ]
}

find_vscode() {
    local app
    for app in '/Applications/Visual Studio Code.app' "$HOME/Applications/Visual Studio Code.app"; do
        if is_vscode_app "$app"; then printf '%s\n' "$app"; return 0; fi
    done
    return 1
}

find_claude() {
    local found
    found=$(command -v claude 2>/dev/null) || found=''
    if [ -n "$found" ] && [ -f "$found" ] && [ -x "$found" ]; then printf '%s\n' "$found"; return 0; fi
    if [ -x "$HOME/.local/bin/claude" ]; then printf '%s\n' "$HOME/.local/bin/claude"; return 0; fi
    return 1
}

choose_profile() {
    local user_root="${1:-$HOME}" user_shell="${2:-${SHELL:-/bin/zsh}}" zsh_root="${3:-${ZDOTDIR:-}}"
    case "$user_shell" in
        */zsh)
            if [ -n "$zsh_root" ] && [ "$zsh_root" != "$user_root" ]; then
                fail 'A custom Zsh configuration location is active. Ask your instructor to check the PATH setting.'; return 1
            fi
            printf '%s\n' "$user_root/.zshrc" ;;
        */bash)
            if [ -f "$user_root/.bash_profile" ]; then printf '%s\n' "$user_root/.bash_profile"
            elif [ -f "$user_root/.bash_login" ]; then printf '%s\n' "$user_root/.bash_login"
            elif [ -f "$user_root/.profile" ]; then printf '%s\n' "$user_root/.profile"
            else printf '%s\n' "$user_root/.bash_profile"; fi ;;
        *) fail 'This helper supports the default Zsh shell and Bash. Ask your instructor for help with your terminal settings.'; return 1 ;;
    esac
}

ensure_native_path() {
    local profile="$1" log_dir="$2" path_line
    path_line='export PATH="$HOME/.local/bin:$PATH"'
    if [ -L "$profile" ]; then fail 'Your shell settings file is a link. Ask your instructor before changing it.'; return 1; fi
    if [ -e "$profile" ] && { [ ! -f "$profile" ] || [ ! -w "$profile" ]; }; then
        fail 'Your shell settings file is not writable. Do not use sudo. Ask your instructor.'; return 1
    fi
    if [ -f "$profile" ] && /usr/bin/grep -Fqx "$path_line" "$profile"; then return 0; fi
    if [ -f "$profile" ]; then
        /bin/cp -p "$profile" "$log_dir/$(basename "$profile").before-$(date +%Y%m%d-%H%M%S)-$$" || return 1
    fi
    # Append only. Do not source a student's configuration file inside this helper.
    printf '\n# ITM 325 Claude Code command location\n%s\n' "$path_line" >> "$profile" || return 1
}

ensure_shell_paths() {
    local profile="$1" log_dir="$2"
    ensure_native_path "$profile" "$log_dir" || return 1
    # VS Code can start Bash as a login or a non-login interactive shell.
    # Keep the existing login profile and also cover non-login Bash terminals.
    case "$profile" in
        "$HOME/.bash_profile"|"$HOME/.bash_login"|"$HOME/.profile")
            ensure_native_path "$HOME/.bashrc" "$log_dir" || return 1 ;;
    esac
}

assert_course_folder() {
    local folder="$1"
    if [ -L "$folder" ]; then fail 'The webdev folder is a link. Ask your instructor to choose a local course folder.'; return 1; fi
    if [ -e "$folder" ] && [ ! -d "$folder" ]; then fail 'A file already uses the name webdev in your home folder. Ask your instructor for help.'; return 1; fi
}

install_claude() {
    local scratch installer
    scratch=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/itm325.XXXXXX") || return 1
    installer="$scratch/claude-official-install.sh"
    printf 'Downloading the official Claude Code installer.\n'
    /usr/bin/curl --fail --show-error --location --proto '=https' --tlsv1.2 \
        --connect-timeout 20 --max-time 180 --retry 2 \
        'https://claude.ai/install.sh' --output "$installer" || {
            fail 'The download failed. Check the message above and your internet connection.'; return 1;
        }
    if [ ! -s "$installer" ] || ! /usr/bin/head -n 1 "$installer" | /usr/bin/grep -q '^#!'; then
        fail 'The download was not an installation script. A network filter may have returned a web page.'; return 1
    fi
    printf 'Installing Claude Code. The download can be quiet for several minutes.\n'
    /bin/bash "$installer" stable || { fail 'Claude Code installation failed. See the message above.'; return 1; }
}

run_install_steps() {
    local claude="$1" profile="$2" log_dir="$3" folder="$4" version probe
    step '[2 of 4] Preparing Claude Code'
    if [ -z "$claude" ]; then
        install_claude || return 1
        claude=$(find_claude) || { fail 'The installer ended, but Claude Code was not found. Do not continue to Step 3.'; return 1; }
    fi
    version=$("$claude" --version 2>&1) || { fail "The installed Claude Code did not start. $version"; return 1; }
    case "$version" in *'Claude Code'*) ;; *) fail 'The claude command did not identify itself as Claude Code. Ask your instructor.'; return 1 ;; esac
    printf 'OK: %s\n' "$version"

    step '[3 of 4] Checking the command location'
    if [ "$claude" = "$HOME/.local/bin/claude" ]; then
        ensure_shell_paths "$profile" "$log_dir" || { fail 'Could not save the command location. Ask your instructor.'; return 1; }
    else
        printf 'Keeping your existing Claude installation and its command location.\n'
    fi
    printf 'OK: Command location checked. Reopen VS Code before Step 3.\n'

    step '[4 of 4] Preparing your course folder'
    assert_course_folder "$folder" || return 1
    /bin/mkdir -p "$folder" || { fail 'Could not create your course folder.'; return 1; }
    probe=$(/usr/bin/mktemp "$folder/.itm325-write-check.XXXXXX") || { fail 'The course folder is not writable.'; return 1; }
    /bin/rm -f "$probe" || return 1
    printf 'OK: Course folder: %s\n' "$folder"
    printf '\nREADY FOR STEP 3\n'
    printf 'Save your work, quit VS Code with Command Q, close Terminal, then reopen VS Code.\n'
    printf 'Use the trash can to close any restored terminal before opening a new one.\n'
    printf 'Choose File > Open Folder. Press Command Shift G, enter ~/webdev, and open it.\n'
    printf 'Choose Terminal > New Terminal. Use Zsh or Bash, matching your normal Terminal shell.\n'
    printf 'Run: claude --version\nThen run: claude\n'
    printf 'If claude is not found, use the quick fix in Step 3 of the Mac guide. Do not reinstall.\n'
    printf 'Follow Step 3 in the Mac guide to sign in and confirm a response.\n'
    printf 'This result verifies the installation, not your account access or a Claude response.\n'
    printf 'Local setup log: %s\n' "$SETUP_LOG"
}

main() {
    set -o pipefail
    local check_only=0 os_version major vscode claude profile folder answer log_dir result version
    case "${1:-}" in --check) check_only=1 ;; '') ;; *) printf 'Usage: bash setup-mac.sh [--check]\n'; return 1 ;; esac
    printf 'ITM 325 | Mac setup\n'
    [ "$(uname -s)" = 'Darwin' ] || { fail 'This helper is for a Mac. Use the Windows guide on Windows.'; return 1; }
    [ "$(id -u)" -ne 0 ] || { fail 'Run this helper from your normal account, without sudo.'; return 1; }
    os_version=$(/usr/bin/sw_vers -productVersion) || return 1
    major=${os_version%%.*}
    case "$major" in ''|*[!0-9]*) fail 'Could not read your macOS version.'; return 1 ;; esac
    [ "$major" -ge 13 ] || { fail 'Claude Code needs macOS 13 or later. VS Code may need a newer supported macOS version. Ask your instructor.'; return 1; }
    case "$(uname -m)" in arm64|x86_64) ;; *) fail 'This Mac architecture is not supported by the helper.'; return 1 ;; esac
    step '[1 of 4] Checking VS Code and existing tools'
    vscode=$(find_vscode) || { fail 'Move VS Code into Applications and open it once before running Step 2.'; return 1; }
    printf 'OK: VS Code found.\n'
    profile=$(choose_profile) || return 1
    folder="$HOME/webdev"
    assert_course_folder "$folder" || return 1
    claude=$(find_claude) || claude=''
    if [ -n "$claude" ]; then
        version=$("$claude" --version 2>&1) || { fail 'Your existing Claude installation did not start. Ask your instructor before reinstalling.'; return 1; }
        case "$version" in *'Claude Code'*) ;; *) fail 'The claude command did not identify itself as Claude Code. Ask your instructor.'; return 1 ;; esac
        printf '%s\n' "$version"
    else printf 'Claude Code: not installed yet.\n'; fi
    if [ "$check_only" -eq 1 ]; then
        printf 'Course folder: %s\nCheck only. No installation or settings changes were made.\n' "$folder"
        [ -n "$claude" ] && [ -d "$folder" ] || return 2
        printf 'Tools found. Sign-in and a live response still need to be checked in VS Code.\n'
        return 0
    fi
    printf '\nThis helper installs missing Claude Code, adds its command location to your shell\n'
    printf 'settings when needed, and prepares ~/webdev. It keeps existing working installations.\n'
    printf 'It does not install Homebrew or Xcode, sign in, purchase a plan, or send a Claude prompt.\n'
    printf 'Type Y to continue, or press Return to stop: '
    if ! read -r answer < /dev/tty; then fail 'Open Terminal and run the helper there so you can answer its prompt.'; return 1; fi
    case "$answer" in y|Y|yes|YES|Yes) ;; *) printf 'Stopped. No setup changes were made.\n'; return 3 ;; esac
    log_dir="$HOME/Library/Logs/ITM325"
    /bin/mkdir -p "$log_dir" || { fail 'Could not create a local setup log.'; return 1; }
    SETUP_LOG="$log_dir/setup-$(date +%Y%m%d-%H%M%S)-$$.txt"
    run_install_steps "$claude" "$profile" "$log_dir" "$folder" 2>&1 | /usr/bin/tee "$SETUP_LOG"
    result=${PIPESTATUS[0]}
    return "$result"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
    exit $?
fi
