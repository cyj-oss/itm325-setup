#!/bin/bash
# Isolated function tests. No real downloads, installation, HOME changes, or profile edits.
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
printf '\nAll %s Mac checks passed. No software was installed.\n' "$test_count"
printf 'Test artifacts: %s\n' "$test_root"
