#!/bin/dash

# Test the tigger-init command.

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.
expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.
trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# init when root is empty
tigger-init > "$actual_output" 2>&1

if ! test -d .tigger
then
    echo "Failed test"
    exit 1
fi

# init when .tigger exists
tigger-init > "$actual_output" 2>&1
echo "tigger-init: error: .tigger already exists" > "$expected_output"

if ! diff "$expected_output" "$actual_output" 
then
    echo "Failed test"
    exit 1
fi


echo "Passed test"
exit 0