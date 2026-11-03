# ------------------------------------------------------------------------------
# Script: bootstrap-storage.sh
#
# Purpose:
#   - Apply core storage & metastore infrastructure
#   - Ensure correct resource ordering
#   - Run post-deployment smoke tests
#
# Usage:
#   bash infrastructure/scripts/storage/bootstrap_storage.sh
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
source infrastructure/scripts/storage/env/.storage.env


# A variable holding the Kubernetes namespace
# Using a variable avoids hardcoding "storage" everywhere
# Together, these make the script SAFE for infrastructure work
NAMESPACE="storage"


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
# -------------------------- Applying Configmap ---------------------------
apply "Applying Global Mart Env" \
    "infrastructure/manifests/base" \
    "storage-env.yaml" 

# -------------------------- Applying Secrets ---------------------------
apply "Applying MinIO & MySQL Secrets" \
    "infrastructure/manifests/secrets" \
    ".minio-secret.yaml" \
    ".mysql-secret.yaml" 

# -------------------------- HIVE METASTORE ---------------------------
apply "Applying Hive Metastore" \
    "infrastructure/manifests/metastore/hive" \
    "hive-configmap.yaml" \
    "hive-metastore-service.yaml" \
    "hive-metastore-deployment.yaml"


# ------------------------------ MINIO ---------------------------------
apply "Applying MINIO" \
    "infrastructure/manifests/storage/minio" \
    "minio-service.yaml" \
    "minio-statefulset.yaml"


# ------------------------------- MYSQL --------------------------------
apply "Applying MYSQL" \
    "infrastructure/manifests/storage/mysql" \
    "mysql-service.yaml" \
    "mysql-statefulset.yaml"

# -------------------------- SUCCESS MESSAGE ---------------------------
echo "======================================================"
echo " ✅ All resources applied successfully"
echo "======================================================"


# -------------------------- Waiting for storage components to be READY" ---------------------------
echo "======================================================"
echo "⏳ Waiting for storage components to be READY"
echo "======================================================"
kubectl -n storage wait \
    --for=condition=ready \
    pod\
    -l app="$MYSQL_APP"\
    --timeout=180s

kubectl -n storage wait \
    --for=condition=ready \
    pod\
    -l app="$MINIO_APP"\
    --timeout=180s    
# -------------------------------RUNNING SMOKE TESTS----------------------
echo "=================================================================="
echo " Running Storage Smoke Tests"
echo "=================================================================="

# Always delete the job first so it be re-run safely
kubectl -n storage delete job storage-smoke-test --ignore-not-found

# Apply the smoke test job
kubectl -n storage apply -f infrastructure/manifests/tools/storage-smoke-test.yaml

# Wait for the job to complete (success or failure)
# runs ONLY if exit code == 0 (this why we invert the output so it run only in case of a failure (1(failure) when inverted became 0))
if ! kubectl -n storage wait \
    --for=condition=complete \
    job/storage-smoke-test \
    --timeout=120s; then

echo "❌ Smoke tests FAILED"
echo "Fetching job logs..."
kubectl -n storage logs job/storage-smoke-test
exit 1
fi

# -------------------------- SUCCESS MESSAGE ---------------------------
echo "======================================================"
echo "✅ Smoke tests PASSED"
echo "======================================================"



