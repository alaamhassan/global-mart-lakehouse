# Secrets Management

This directory contains Kubernetes Secret manifests required by the platform.

## Important Notes

- Secret files are **not committed to Git**
- All secret YAML files are ignored via `.gitignore`
- Only template or example files may be committed (if needed)

## Expected Secrets

The following secrets are required at runtime:

- `hive-secret.yaml` – Hive Metastore database credentials
- `mysql-secret.yaml` – MySQL root and application credentials
- `minio-secret.yaml` – MinIO access and secret keys

## How to Create Secrets

Secrets must be created manually or via a secure mechanism:

### Option 1: Create from literals
```bash 
    kubectl -n storage create secret generic <name>\
  --from-literal=KEY=value 
```

### Option 2: Apply a local YAML file
```bash
  kubectl -n storage apply -f <secret-file>.yaml
```
