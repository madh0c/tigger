#!/bin/dash

# Test the tigger-commit command.

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.
expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.
trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# add files, commit once
tigger-init > "$actual_output" 2>&1
touch a b
tigger-add a b > "$actual_output" 2>&1
tigger-commit -m "first commit" > "$actual_output" 2>&1
echo "Committed as commit 0" > "$expected_output"

if ! diff "$expected_output" "$actual_output" || ! test -d .tigger/0 || ! test -f .tigger/0/a || ! test -f .tigger/0/b
then
    echo "Failed test"
    exit 1
fi

# -a flag
echo "changes" > a
echo "changes" > b

tigger-commit -a -m "second commit" > "$actual_output" 2>&1
echo "Committed as commit 1" > "$expected_output"

if ! diff "$expected_output" "$actual_output" || ! diff .tigger/1/a a >/dev/null
then
    echo "Failed test"
    exit 1
fi

# commit again after no changes
tigger-commit -m "attempted third commit" > "$actual_output" 2>&1
echo "nothing to commit" > "$expected_output"

if ! diff "$expected_output" "$actual_output" || test -d .tigger/2
then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0