#!/bin/bash
# Hook: SubagentStop for tf-generator
# Runs validation after infrastructure generation

if [ -d "infrastructure" ]; then
  cd infrastructure && terraform fmt -recursive && terraform validate
fi

exit 0
