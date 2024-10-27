
#!/bin/bash

# Directory to start the search from
search_dir=$1

# Patterns to search for in .tf files
tf_patterns=("password=" "secret=" "key=" "cert=" "token=" "credentials=")

# Function to search for patterns in a .tf file
search_tf_file() {
    local file="$1"
    for pattern in "${tf_patterns[@]}"; do
        if grep -qi "$pattern" "$file"; then
            echo "::warning file=$file::Possible secret found in $file"
        fi
    done
}

# Function to check for the existence of sensitive files
check_sensitive_files() {
    local file="$1"
    if [[ "$file" =~ \.(env|tfstate|tfvars)$ ]]; then
        echo "Sensitive file found: $file"
        exit 1
    fi
}

# Recursively search for .tf, .env, .tfstate, and .tfvars files and check them
find "$search_dir" -type f \( -name "*.tf" -o -name "*.env" -o -name "*.tfstate" -o -name "*.tfvars" \) -exec bash -c '
    if [[ "$0" =~ \.tf$ ]]; then
        search_tf_file "$0"
    else
        check_sensitive_files "$0"
    fi
' {} \;
