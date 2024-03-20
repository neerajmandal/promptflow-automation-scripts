#!/bin/bash
set -euE

# Set the SCRIPT_PATH variable to the directory where the current script is located.
# "$0" is a reference to the current script, "readlink -f" resolves its absolute file path,
# and "dirname" extracts the directory part of this path.
SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"

# Source the common.sh script located in the same directory as this script.
# Sourcing a script allows us to use its functions and variables in the current script.
. $SCRIPT_PATH/common.sh

# Load any declared variables from .env file at repo root
load_env_file "$SCRIPT_PATH/../.env"

# Setup the variables used for PromptFlow connections below
# Call to setup_pf_connection_variables function in common.sh
setup_pf_connection_variables

# create connection to openai
pf connection create -f "${SCRIPT_PATH}/../src/connections/azure_openai.template.yaml" \
  --set api_key="${AZURE_OPENAI_API_KEY}" \
  --set api_base="${AZURE_OPENAI_API_BASE}"

# create connection to azure search
pf connection create -f "${SCRIPT_PATH}/../src/connections/azure_ai_search.template.yaml" \
  --set api_key="${AZURE_SEARCH_KEY}" \
  --set api_base="${AZURE_SEARCH_ENDPOINT}"