#!/bin/bash
# Hook: PostToolUse for Write/Edit operations
# Validates Terraform files after editing

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE" == *.tf ]]; then
  terraform fmt -check "$FILE" 2>/dev/null || echo "terraform fmt needed"
fi

exit 0
