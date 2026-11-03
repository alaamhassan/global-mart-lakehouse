

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
NAMESPACE="storage"


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
    echo " DELETING $title"
    echo "======================================================"

    # "$@" means: all remaining arguments (each preserved as a separate value)
    # We loop over each YAML files passed to the function
    for yaml_resource in "$@"; do

        #Apply the kubernetes manifest
        # -n "$NAMESPACE" -> specifies which namespace (the quites"" is added, so that bash treats the variable as one single value)
        # delete 
        # -f -> apply from file
        kubectl -n "$NAMESPACE" delete "$resource_type" "$yaml_resource"

    done  
}


# -------------------------- DELETING MinIO & MySQL Secrets ---------------------------
delete "MinIO & MySQL Secrets" \
    "secret" \
    "minio-secret" \
    "mysql-secret" 

# -------------------------- HIVE METASTORE & MinIO & MySQL SERVICES---------------------------
delete "HIVE METASTORE & MinIO & MySQL SERVICES" \
    "service" \
    "hive-metastore-service" \
    "mysql-hms-headless" \
    "minio-headless"

# -------------------------- DELETING HIVE METASTORE CONFIMAP---------------------------
delete "Hive Metastore Configmap"  \
    "configmap" \
    "hive-site-config" 


# -------------------------- DELETING HIVE METASTORE DEPLOYMENT---------------------------
delete "Hive Metastore Deployment" \
    "deploy" \
    "hive-metastore"

# -------------------------- DELETING MinIO & MySQL STATEFULSET---------------------------
delete "MinIO & MySQL StatefulSets"  \
    "statefulset" \
    "mysql-hms" \
    "minio"

# -------------------------- DELETING MinIO & MySQL STATEFULSET---------------------------
delete "MinIO & MySQL PVCs"  \
    "pvc" \
    "minio-storage-minio-0" \
    "mysql-storage-mysql-hms-0"

# -------------------------- Deleting Global Mart Env Configmap ---------------------------
delete "Global Mart Env" \
    "configmap" \
    "storage-env" 


# -------------------------- SUCCESS MESSAGE ---------------------------
echo "======================================================"
echo " ✅ All resources Deleted successfully"
echo "======================================================"




