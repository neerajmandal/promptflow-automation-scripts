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

# Get Azure access token for POST requests
ACCESS_TOKEN="$(az account get-access-token --query accessToken -o tsv)"
url_base_create_connection="https://ml.azure.com/api/${LOCATION}/flow/api/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP_NAME}/providers/Microsoft.MachineLearningServices/workspaces/${WORKSPACE_NAME}/Connections"

# Create Azure OpenAI connection
url_create_azure_open_ai_connection="${url_base_create_connection}/${AZURE_OPENAI_CONNECTION_NAME}?asyncCall=true"

echo "Creating Azure OpenAI connection with name: $AZURE_OPENAI_CONNECTION_NAME"

curl -s --request POST --fail \
  --url "$url_create_azure_open_ai_connection" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  -d @- <<EOF
{
  "connectionType": "AzureOpenAI",
  "configs": {
    "api_key": "$AZURE_OPENAI_API_KEY",
    "api_base": "$AZURE_OPENAI_API_BASE",
    "api_type": "azure",
    "api_version": "$API_VERSION",
    "resource_id": "/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP_NAME}/providers/Microsoft.CognitiveServices/accounts/${AZURE_OPEN_AI_RESOURCE_NAME}"
  }
}
EOF
echo -e "\n"

# Create Azure AI Search connection
url_create_azure_ai_search_connection="${url_base_create_connection}/${AZURE_AI_SEARCH_CONNECTION_NAME}?asyncCall=true"

echo "Creating Azure AI Search connection with name: $AZURE_AI_SEARCH_CONNECTION_NAME"

curl -s --request POST --fail \
  --url "$url_create_azure_ai_search_connection" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Content-Type: application/json' \
  -d @- <<EOF
{
  "connectionType": "CognitiveSearch",
  "configs": {
    "api_key": "$AZURE_SEARCH_KEY",
    "api_base": "$AZURE_SEARCH_ENDPOINT",
    "api_version": "2023-07-01-Preview"
  }
}
EOF
echo -e "\n"

echo "Done!"