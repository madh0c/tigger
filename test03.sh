#!/bin/dash

# Test the tigger-log command.

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.
expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.
trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# when repo is missing
tigger-log > "$actual_output" 2>&1 
echo "tigger-log: error: tigger repository directory .tigger not found" > "$expected_output"

if ! diff "$expected_output" "$actual_output" 
then
    echo "Failed test"
    exit 1
fi

# when there are no commits
tigger-init > "$actual_output" 2>&1
touch a b
tigger-add a b > "$actual_output" 2>&1

tigger-log > "$actual_output" 2>&1 
cat > "$expected_output" <<EOF
EOF

if ! diff "$expected_output" "$actual_output" 
then
    echo "Failed test"
    exit 1
fi

# commit 
tigger-commit -m "first commit" > "$actual_output" 2>&1
tigger-log > "$actual_output" 2>&1 

echo "0 first commit" > "$expected_output"
if ! diff "$expected_output" "$actual_output" 
then
    echo "Failed test"
    exit 1
fi

# commit again
touch c
tigger-add c > "$actual_output" 2>&1
tigger-commit -m "second commit" > "$actual_output" 2>&1
tigger-log > "$actual_output" 2>&1 

echo "1 second commit" > "$expected_output"
echo "0 first commit" >> "$expected_output"

if ! diff "$expected_output" "$actual_output" 
then
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0