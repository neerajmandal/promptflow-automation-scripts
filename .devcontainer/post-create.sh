#!/bin/env bash
set -eux

# Install CLI tooling for extensions
npm install -g @devcontainers/cli
npm install -g markdownlint-cli @prantlf/jsonlint markdown-link-check

# setup conda environment
if [ -f /workspaces/*/environment.yml ]; then
  umask 0002
  /opt/conda/bin/conda env create -n "$CONDA_ENV_NAME" -f /workspaces/*/environment.yml
fi

# Initialize conda helpers in user's ~/.bashrc
conda init