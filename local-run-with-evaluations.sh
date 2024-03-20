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

# Default values
experiment_name="local-run"
story_id="STORY-ID-NNNNN"

# Flow locations
standard_flow_01="${SCRIPT_PATH}/../src/flows/standard_flow_01"
evaluation_flow_01="${SCRIPT_PATH}/../src/flows/evaluation_flow_01"
evaluation_flow_02="${SCRIPT_PATH}/../src/flows/evaluation_flow_02"

# This path to dataset which is relative to flow's run.yml
data_path="../../../../data/tests/app-reference-dev-prompt.jsonl"


# If experiment_name is not provided as an argument, use the current git branch
if [ -z "$experiment_name" ]; then
  experiment_name=$(git rev-parse --abbrev-ref HEAD)
fi

# Run names
current_time="$(date +%Y%m%d%H%M%S)"
run_name_prefix="${story_id}_${experiment_name}_${current_time}"

standard_flow_run_name="${run_name_prefix}-standard_flow"
evaluation_flow_1_run_name="${run_name_prefix}-evaluation_flow_01"
evaluation_flow_2_run_name="${run_name_prefix}-evaluation_flow_02"

# Step 1: Create a run for Standard Flow
echo "Step 1: Standard Flow - $standard_flow_run_name"
pf run create --stream -n "$standard_flow_run_name" \
  -f "${standard_flow_01}/run.yml" \
  --data "$data_path"

# Step 2: Create a run for Evaluation Flow 1
echo "Step 2: Evaluation Flow 1 - $evaluation_flow_1_run_name"
pf run create --stream -n "$evaluation_flow_1_run_name" \
  -f "${evaluation_flow_01}/run.yml" \
  --data "$data_path" \
  # Reference to the standard flow from step 1
  --run "$standard_flow_run_name"

# Step 3: Create a run for Evaluation Flow 2
echo "Step 3: Evaluation Flow 2 - $evaluation_flow_2_run_name"
pf run create --stream -n "$evaluation_flow_2_run_name" \
  -f "${evaluation_flow_02}/run.yml" \
  --data "$data_path" \
    # Reference to the evaluation flow from step 2
  --run "$evaluation_flow_1_run_name"


# Write run names to current experiment file
tee "${SCRIPT_PATH}/../src/.current_experiment.json" <<EOF
{
  "name": "${experiment_name}",
  "flows": {
    "standard_flow_01": "${standard_flow_run_name}",
    "evaluation_flow_01": "${evaluation_flow_1_run_name}",
    "evaluation_flow_02": "${evaluation_flow_2_run_name}"
  }
}
EOF

echo "Done"