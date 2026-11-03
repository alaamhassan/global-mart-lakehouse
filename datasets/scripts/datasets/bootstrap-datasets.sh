# ------------------------------------------------------------------------------
# Script: bootstrap-datasets.sh
#
# Purpose:
#   - Apply datasetse
#   - Ensure correct resource ordering
#   - Run post-deployment smoke tests
#
# Usage:
#   ./datasets/scripts/datasets/bootstrap-datasets.sh
#
# Safe to re-run (idempotent)
# ------------------------------------------------------------------------------


# this is line is called a "shebang"
# It tells Linux:
# "Run this file using the bash shell"
# Using /usr/bin/env makes it portable across systems
#!/user/bin/env bash

# -e: Exit the script immeditely if ANY command fails (non-zero exit code)
# -u: Treat use of undefined variables as an error
# -o pipefail: If a pipeline fails, the whole pipeline fails
# Together, these make the scripte SAFE for infrastructure work
set -euo pipefail

# sourcing the environment variables in the ".storage.env"
# so we don't hardcode the names of the resources
source datasets/scripts/env/.datasets.env



# This defines a bash function named "apply"
# Functions let us resuse logic and avoid repetition (DRY principle)
apply(){

    # "local" means this variable exists ONLY inside this functions
    # "$1" is the first argument passed to the function
    local title="$1"

    # "$2" is the second argument
    # This is the base directory where the YAML files live
    local yaml_path="$2"

    # "shift" moves the positional parameters to the left
    # After "shift 2", "$@" now contains ONLY the YAML filenames
    # This allows the function to accept a variable number of files
    shift 2

    # print clear sections headers for readability in logs/CI output
    echo "======================================================"
    echo " Updating $title"
    echo "======================================================"

    # "$@" means: all remaining arguments (each preserved as a separate value)
    # We loop over each YAML files passed to the function
    for yaml_file in "$@"; do

        #Apply the kubernetes manifest
        # -n "$NAMESPACE" -> specifies which namespace (the quites"" is added, so that bash treats the variable as one single value)
        # apply -> idempotent (safe to run multiple times)
        # -f -> apply from file
        kubectl -n "$NAMESPACE" apply -f "$yaml_path/$yaml_file"

    done  
}

directory="datasets/manifests"

# -------------------------- Applying NameSpace & Configmap ---------------------------
apply "NameSpace & Configmaps" \
    "$directory/base" \
    "dataset-namespace.yaml" \
    "datasets-env.yaml" 

# -------------------------- Applying Secrets ---------------------------
apply "MinIO & MySQL Secrets" \
    "$directory/secrets" \
    ".brazilian-mssql-secret.yaml" 


# ------------------------------ Applying Brazilian DataSet ---------------------------------
apply "Brazilian DataSet" \
    "$directory/storage/brazilian" \
    "mssql-service.yaml" \
    "datasets-mssql.yaml" 


# -------------------------- SUCCESS MESSAGE ---------------------------
echo "======================================================"
echo " ✅ All resources applied successfully"
echo "======================================================"


# -------------------------- Waiting for datasets components to be READY" ---------------------------
echo "======================================================"
echo "⏳ Waiting for storage components to be READY"
echo "======================================================"
kubectl -n $NAMESPACE wait \
    --for=condition=ready \
    pod\
    -l app="$MSSQL_APP"\
    --timeout=180s
 
# -------------------------------RUNNING SMOKE TESTS----------------------
echo "=================================================================="
echo " Running Storage Smoke Tests"
echo "=================================================================="

# Always delete the job first so it be re-run safely
kubectl -n $NAMESPACE delete job datasets-smoke-test --ignore-not-found

# Apply the smoke test job
kubectl -n $NAMESPACE apply -f datasets/manifests/tools/datasets-smoke-test.yaml
# Wait for the job to complete (success or failure)
# runs ONLY if exit code == 0 (this why we invert the output so it run only in case of a failure (1(failure) when inverted became 0))
if ! kubectl -n $NAMESPACE wait \
    --for=condition=complete \
    job/datasets-smoke-test \
    --timeout=120s; then

echo "❌ Smoke tests FAILED"
echo "Fetching job logs..."
kubectl -n $NAMESPACE logs job/datasets-smoke-test
exit 1
fi

# -------------------------- SUCCESS MESSAGE ---------------------------
echo "======================================================"
echo "✅ Smoke tests PASSED"
echo "======================================================"



