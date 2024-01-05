#!/usr/bin/env bash

# Make sure Poetry is in the path
export PATH="/home/ubuntu/.local/bin:$PATH"

# Activate Python environment
. ~/venv/bin/activate

# Set-up ssh keys
eval "$(ssh-agent)"
ssh-add ~/.ssh/nectar_vm
