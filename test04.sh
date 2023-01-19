#!/bin/dash

# Test the tigger-rm command.

PATH="$PATH:$(pwd)"

# Create a temporary directory for the test.
test_dir="$(mktemp -d)"
cd "$test_dir" || exit 1

# Create some files to hold output.
expected_output="$(mktemp)"
actual_output="$(mktemp)"

# Remove the temporary directory when the test is done.
trap 'rm "$expected_output" "$actual_output" -rf "$test_dir"' INT HUP QUIT TERM EXIT

# add a b c, then remove a from index
tigger-init > "$actual_output" 2>&1
touch a b c
tigger-add a b c > "$actual_output" 2>&1
tigger-rm --cached b > "$actual_output" 2>&1

if test -f .tigger/index/b || ! test -f b
then    
    echo "Failed test"
    exit 1
fi

# change a, then rm
echo "changed a" > a
tigger-rm a > "$actual_output" 2>&1
cat > "$expected_output" <<EOF
tigger-rm: error: 'a' in index is different to both the working file and the repository
EOF

if ! diff "$expected_output" "$actual_output" 
then
    echo "Failed test"
    exit 1
fi

# with --force
tigger-rm --force a > "$actual_output" 2>&1

if test -f .tigger/index/a || test -f a
then    
    echo "Failed test"
    exit 1
fi

echo "Passed test"
exit 0