#!/bin/dash

# Test the tigger-add command.

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.
expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.
trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

tigger-init > "$actual_output" 2>&1

# edge case: add a b c, but c DNE
# then shouldn't add a or b
touch a b
tigger-add a b c > "$actual_output" 2>&1
echo "tigger-add: error: can not open 'c'" > "$expected_output"

if ! diff "$expected_output" "$actual_output" || test -f .tigger/index/a || test -f .tigger/index/b
then    
    echo "Failed test"
    exit 1
fi

# adding a single file
echo "line 1" > a
tigger-add a > "$actual_output" 2>&1

cat > "$expected_output" <<EOF
EOF

if ! diff "$expected_output" "$actual_output" || ! test -f .tigger/index/a
then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0