#!/bin/bash
# Hook: PreToolUse for Bash commands
# Validates Bash commands before execution for security

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block dangerous commands if needed
# Add validation logic here

exit 0
