#!/bin/bash

# Check if the terraform files are formatted correctly
terraform fmt -check -recursive

# Check if the terraform files are formatted correctly
terraform fmt -check -recursive
if [ $? -eq 0 ]; then
    echo "Terraform files are formatted correctly"
else

    # Print the terraform files that are not formatted correctly
    terraform fmt -recursive -diff -check

    echo "ERROR: Terraform files are not formatted correctly"
    
    # Exit with a non-zero status code
    exit 1
fi