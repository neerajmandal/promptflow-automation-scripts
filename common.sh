#!/bin/bash
# common.sh: common functions and helpers for other scripts
set -euE

function error_trap {
  echo
  echo "*** script failed to execute to completion ***"
  echo "An error occurred on line $1 of the script."
  echo "Exit status of the last command was $2"
}

trap 'error_trap $LINENO $?' ERR

# Load environment variables from specified file (or .env), if exists
load_env_file() {
  env_file="${1:-.env}"
  if [ -f "$env_file" ]; then
    export $(cat "$env_file" | sed 's/#.*//g' | xargs)
  fi
}

# Obtains a secret from keyvault using the provided secret name
get_secret() {
  secret_name="$1"
  echo "Retrieving $secret_name from key vault..." >&2
  secret_value=$(az keyvault secret show --subscription "$AZURE_SUBSCRIPTION_ID" -n "$secret_name" --vault-name "$KEYVAULT_NAME" --query value -o tsv)

  if [ $? -ne 0 ]; then
    echo "Failed to retrieve $secret_name from keyvault" >&2
    exit 1
  fi

  echo $secret_value
}

# Populates the configuration entries required to create PromptFlow connections
setup_pf_connection_variables() {
  # Use the dev keyvault unless otherwise specified
  AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-"<subscription_id>"}"
  KEYVAULT_NAME="${KEYVAULT_NAME:-"<keyvault_name>"}"
  # Retrieve from key vault via get_secret() function, if not exported locally
  AZURE_SEARCH_KEY="${AZURE_SEARCH_KEY:-$(get_secret "azure-search-key")}"
  AZURE_SEARCH_ENDPOINT="${AZURE_SEARCH_ENDPOINT:-$(get_secret "azure-search-endpoint")}"
  AZURE_OPENAI_API_KEY="${AZURE_OPENAI_API_KEY:-$(get_secret "openai-api-key")}"
  AZURE_OPENAI_API_BASE="${AZURE_OPENAI_API_BASE:-$(get_secret "openai-endpoint")}"
}