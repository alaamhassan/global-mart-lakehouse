

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

# A variable holding the Kubernetes namespace
# Using a variable avoids hardcoding "storage" everywhere
# Together, these make the script SAFE for infrastructure work
NAMESPACE="datasets"


# This defines a bash function named "apply"
# Functions let us resuse logic and avoid repetition (DRY principle)
delete(){

    # "local" means this variable exists ONLY inside this functions
    # "$1" is the first argument passed to the function
    local title="$1"

    # "$2" is the second argument
    # This is the base directory where the YAML files live
    local resource_type="$2"

    # "shift" moves the positional parameters to the left
    # After "shift 2", "$@" now contains ONLY the YAML filenames
    # This allows the function to accept a variable number of files
    shift 2

    # print clear sections headers for readability in logs/CI output
    echo "======================================================"
    echo " Deleting $title"
    echo "======================================================"

    # "$@" means: all remaining arguments (each preserved as a separate value)
    # We loop over each YAML files passed to the function
    for yaml_resource in "$@"; do

        #Apply the kubernetes manifest
        # -n "$NAMESPACE" -> specifies which namespace (the quites"" is added, so that bash treats the variable as one single value)
        # delete 
        # -f -> apply from file
        kubectl -n "$NAMESPACE" delete "$resource_type" "$yaml_resource" --ignore-not-found

    done  
}


# -------------------------- DELETING BRAZILIAN MSSQL SECRET ---------------------------
delete "BRAZILIAN MSSQL SECRET" \
    "secret" \
    "brazilian-mssql-secret" 

# -------------------------- DELETING MSSQL SERVICE---------------------------
delete "MSSQL SERVICE" \
    "service" \
    "mssql-headless-service" 


# -------------------------- DELETING MSSQL-DATASETS STATEFULSET---------------------------
delete "DELETING MSSQL-DATASETS STATEFULSET"  \
    "statefulset" \
    "datasets-mssql" 

# -------------------------- DELETING PVC ---------------------------
delete "MinIO & MySQL PVCs"  \
    "pvc" \
    "brazilian-mssqldb-datasets-mssql-0" 

# -------------------------- DELETING CONFIGMAP & NAMESPACE ---------------------------
delete "DELETING CONFIGMAP" \
    "configmap" \
    "datasets-env" 

delete "DELETING NAMESPACE" \
"namespace" \
"dataset-namespace" 


# -------------------------- SUCCESS MESSAGE ---------------------------
echo "======================================================"
echo " ✅ All resources Deleted successfully"
echo "======================================================"




