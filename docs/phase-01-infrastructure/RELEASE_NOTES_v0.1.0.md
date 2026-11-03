# Release Notes – v0.1.0

## File Purpose

Documents the exact scope, changes, and outcomes included in release v0.1.0.

## Phase 1: Infrastructure Foundation

**Release date:** 2026-02-07

---

## Scope

This release delivers the foundational Kubernetes infrastructure for the Global Mart Lakehouse.

### Included

* MinIO object storage (StatefulSet + PVC)
* MySQL for Hive Metastore backend (StatefulSet + PVC)
* Hive Metastore Deployment and Service
* Kubernetes Secrets for sensitive configuration
* Runtime smoke test Job for DNS and connectivity validation
* Centralized environment variables via ConfigMap
* Clean, production-style folder and naming conventions

### Explicitly Excluded

* Compute engines (Spark, Flink, Trino)
* Streaming platforms (Kafka)
* Workflow orchestration (Airflow)
* Helm and Kustomize
* Data ingestion and analytics workloads

---

## Validation Performed

* Bootstrap script runs cleanly
* All Pods reach `Running` state
* Smoke test Job passes
* PersistentVolumeClaims remain bound across restarts
* No hardcoded pod or service names in runtime logic
* Secrets are not committed to source control

---

## Repository Structure

* `manifests/base` → namespaces and base environment
* `manifests/storage` → MinIO and MySQL StatefulSets & Services
* `manifests/metastore` → Hive Metastore Deployment & Service
* `manifests/tools` → smoke test Job and debug utilities
* `scripts/` → bootstrap and cleanup scripts

---

## Outcome

Phase 1 establishes a **stable, persistent, enterprise-grade infrastructure foundation** upon which all future data workloads will be built.

---

## Next Release

**v0.2.0 – Phase 2**
Focus on persistence validation workflows and object storage usage, followed by compute layer introduction.
