#!/bin/bash
# Isolated tests. Child shells use a temporary home; the real user's files are untouched.
set -e
set -o pipefail
test_dir=$(cd "$(dirname "$0")" && pwd)
source "$test_dir/setup-mac.sh"
test_root=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/itm325-tests.XXXXXX")
test_count=0
pass() { test_count=$((test_count + 1)); printf 'PASS: %s\n' "$1"; }
assert_equal() { [ "$1" = "$2" ] || { printf 'FAIL: %s\n' "$3"; exit 1; }; pass "$3"; }
must_fail() { if "$@" > "$test_root/expected-error.txt" 2>&1; then printf 'FAIL: expected a stop\n'; exit 1; fi; }

/bin/bash -n "$test_dir/setup-mac.sh"
pass 'Bash parser accepts the helper'
mkdir -p "$test_root/user with spaces" "$test_root/logs"
profile="$test_root/user with spaces/.zshrc"
printf 'export STUDENT_SETTING=keep\n' > "$profile"
ensure_native_path "$profile" "$test_root/logs"
grep -q 'STUDENT_SETTING=keep' "$profile"
pass 'Existing shell configuration is preserved'
first_checksum=$(cksum < "$profile")
ensure_native_path "$profile" "$test_root/logs"
assert_equal "$(cksum < "$profile")" "$first_checksum" 'Repeated setup does not duplicate the PATH line'
assert_equal "$(find "$test_root/logs" -type f | wc -l | tr -d ' ')" '1' 'Only the first profile change creates a backup'
assert_equal "$(choose_profile "$test_root/user with spaces" /bin/zsh)" "$profile" 'Zsh uses the user zshrc'
printf '# preserve\n' > "$test_root/user with spaces/.profile"
assert_equal "$(choose_profile "$test_root/user with spaces" /bin/bash)" "$test_root/user with spaces/.profile" 'Bash preserves an existing profile selection'
printf '# preserve\n' > "$test_root/user with spaces/.bash_login"
assert_equal "$(choose_profile "$test_root/user with spaces" /bin/bash)" "$test_root/user with spaces/.bash_login" 'Bash follows startup file precedence'
must_fail choose_profile "$test_root/user with spaces" /bin/fish
pass 'An unsupported shell stops with guidance'
must_fail choose_profile "$test_root/user with spaces" /bin/zsh /custom-zsh
pass 'A custom Zsh configuration stops for manual help'
ln -s "$profile" "$test_root/linked-profile"
must_fail ensure_native_path "$test_root/linked-profile" "$test_root/logs"
pass 'A linked settings file is not modified'
printf 'student work\n' > "$test_root/collision"
must_fail assert_course_folder "$test_root/collision"
assert_equal "$(cat "$test_root/collision")" 'student work' 'A file collision preserves student data'
ln -s "$test_root/user with spaces" "$test_root/linked-project"
must_fail assert_course_folder "$test_root/linked-project"
pass 'A linked course folder stops for manual help'

fake_claude="$test_root/fake-claude"
printf '#!/bin/bash\nprintf "2.1.0 (Claude Code)\\n"\n' > "$fake_claude"
chmod +x "$fake_claude"
project="$test_root/course folder"
mkdir -p "$project"
printf 'keep this work\n' > "$project/student-work.txt"
SETUP_LOG="$test_root/fake-setup.log"
install_claude() { fail 'Existing Claude must not be reinstalled'; return 1; }
run_install_steps "$fake_claude" "$profile" "$test_root/logs" "$project" > "$test_root/success.txt"
grep -q '^READY FOR STEP 3$' "$test_root/success.txt"
pass 'Existing healthy Claude completes without installation'
assert_equal "$(cat "$project/student-work.txt")" 'keep this work' 'Existing project files are preserved'
assert_equal "$(find "$project" -name '.itm325-write-check.*' | wc -l | tr -d ' ')" '0' 'Temporary write probe is cleaned up'
must_fail run_install_steps '' "$profile" "$test_root/logs" "$project"
if grep -q '^READY FOR STEP 3$' "$test_root/expected-error.txt"; then printf 'FAIL: success after failure\n'; exit 1; fi
pass 'Installation failure cannot report success'
printf '#!/bin/bash\nprintf "unrelated command\\n"\n' > "$fake_claude"
must_fail run_install_steps "$fake_claude" "$profile" "$test_root/logs" "$project"
pass 'A conflicting claude command is rejected'
printf '#!/bin/bash\nexit 42\n' > "$fake_claude"
must_fail run_install_steps "$fake_claude" "$profile" "$test_root/logs" "$project"
pass 'An installed but broken Claude stops setup'

# Exercise real macOS Zsh and Bash startup with a stale PATH, without installing Claude.
test_user="$test_root/user with spaces"
native_claude="$test_user/.local/bin/claude"
mkdir -p "$test_user/.local/bin"
printf '#!/bin/bash\nprintf "2.1.0 (Claude Code)\\n"\n' > "$native_claude"
chmod +x "$native_claude"
isolated_shell() {
    local shell_path="$1"
    shift
    /usr/bin/env -i HOME="$test_user" ZDOTDIR="$test_user" \
        PATH='/usr/bin:/bin:/usr/sbin:/sbin' SHELL="$shell_path" "$shell_path" "$@"
}
assert_equal "$(isolated_shell /bin/bash --noprofile --norc -c 'source "$1/setup-mac.sh"; find_claude' _ "$test_dir")" \
    "$native_claude" 'An installed native Claude is found even when PATH is stale'
printf 'export BASH_STUDENT_SETTING=keep\n' > "$test_user/.bashrc"
isolated_shell /bin/bash --noprofile --norc -c \
    'source "$1/setup-mac.sh"; ensure_shell_paths "$(choose_profile "$HOME" /bin/bash)" "$2/logs"' _ "$test_dir" "$test_root"
grep -q 'BASH_STUDENT_SETTING=keep' "$test_user/.bashrc"
pass 'Preparing non-login Bash preserves existing bashrc settings'
assert_equal "$(isolated_shell /bin/zsh -d -i -c 'claude --version')" \
    '2.1.0 (Claude Code)' 'A fresh Zsh terminal reads the saved command location'
assert_equal "$(isolated_shell /bin/bash --login -c 'claude --version')" \
    '2.1.0 (Claude Code)' 'A fresh login Bash terminal reads the saved command location'
assert_equal "$(isolated_shell /bin/bash --noprofile -i -c 'claude --version' 2>/dev/null)" \
    '2.1.0 (Claude Code)' 'A fresh non-login Bash terminal reads the saved command location'
repair_command='if command -v claude >/dev/null 2>&1; then exit 1; fi; export PATH="$HOME/.local/bin:$PATH"; claude --version'
assert_equal "$(isolated_shell /bin/bash --noprofile --norc -c "$repair_command")" \
    '2.1.0 (Claude Code)' 'The guide quick fix repairs a stale Bash session'
assert_equal "$(isolated_shell /bin/zsh -d -f -c "$repair_command")" \
    '2.1.0 (Claude Code)' 'The guide quick fix repairs a stale Zsh session'

# Exercise actual macOS plist parsing against isolated app bundles.
make_vscode_fixture() {
    local app="$1" executable="$2" bundle_id="${3:-com.microsoft.VSCode}"
    mkdir -p "$app/Contents/MacOS"
    cat > "$app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>$bundle_id</string>
<key>CFBundleExecutable</key><string>$executable</string>
</dict></plist>
EOF
    printf '#!/bin/bash\nexit 0\n' > "$app/Contents/MacOS/$executable"
    chmod +x "$app/Contents/MacOS/$executable"
}

code_app="$test_root/Apps with spaces/Visual Studio Code.app"
make_vscode_fixture "$code_app" Code
is_vscode_app "$code_app"
pass 'VS Code with a Code executable is detected'
if [ -x "$code_app/Contents/MacOS/Electron" ]; then exit 1; fi
pass 'Detection does not require a file named Electron'

electron_app="$test_root/Older VS Code.app"
make_vscode_fixture "$electron_app" Electron
is_vscode_app "$electron_app"
pass 'VS Code with an Electron executable is still detected'

other_app="$test_root/Other editor.app"
make_vscode_fixture "$other_app" Code com.example.other
must_fail is_vscode_app "$other_app"
pass 'An unrelated app is not accepted as VS Code'

missing_app="$test_root/Missing executable.app"
mkdir -p "$missing_app/Contents/MacOS"
cp "$code_app/Contents/Info.plist" "$missing_app/Contents/Info.plist"
must_fail is_vscode_app "$missing_app"
pass 'An app with a missing executable is rejected'

blocked_app="$test_root/Non executable.app"
make_vscode_fixture "$blocked_app" Code
chmod -x "$blocked_app/Contents/MacOS/Code"
must_fail is_vscode_app "$blocked_app"
pass 'An app with a non-executable file is rejected'

must_fail is_vscode_app "$test_root/Not installed.app"
pass 'An absent app is rejected'

/usr/libexec/PlistBuddy -c 'Delete :CFBundleExecutable' "$missing_app/Contents/Info.plist"
must_fail is_vscode_app "$missing_app"
pass 'An app with missing executable metadata is rejected'
/usr/libexec/PlistBuddy -c 'Add :CFBundleExecutable string ../Code' "$missing_app/Contents/Info.plist"
must_fail is_vscode_app "$missing_app"
pass 'Executable metadata cannot point outside the MacOS directory'

printf '\nAll %s Mac checks passed. No software was installed.\n' "$test_count"
printf 'Test artifacts: %s\n' "$test_root"
