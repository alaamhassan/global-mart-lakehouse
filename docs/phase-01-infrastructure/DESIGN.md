# Phase 1 – Infrastructure Design

## File Purpose

Explains the architectural decisions and rationale behind Phase 1.

## 1. Purpose

Phase 1 builds the **foundational infrastructure layer** for the Global Mart Lakehouse.

This phase ensures that all future data workloads run on a **stable, persistent, and well-understood Kubernetes platform**.

---

## 2. High-Level Goals

* Run entirely on Kubernetes
* Persist data beyond pod lifecycles
* Use production-grade Kubernetes primitives
* Follow clean naming and folder conventions
* Maximize learning without unnecessary complexity

---

## 3. Scope

### Included

* Kubernetes namespace and base environment
* MinIO (object storage)
* MySQL (Hive Metastore backend)
* Hive Metastore service
* Persistent storage (PVCs)
* Health probes and runtime smoke tests

### Explicitly Excluded

* Compute engines (Spark, Flink, Trino)
* Streaming systems (Kafka)
* Orchestration (Airflow)
* Helm and Kustomize (planned later phases)
* Data ingestion and analytics

---

## 4. Architecture Overview

### Storage Layer

* MinIO provides S3-compatible object storage
* Deployed as a StatefulSet for stable identity
* PersistentVolumeClaims ensure durability

### Metadata Layer

* MySQL stores Hive Metastore metadata
* StatefulSet + PVC ensure metadata persistence

### Metadata Service

* Hive Metastore exposes table definitions
* Acts as a shared metadata layer for future compute engines

---

## 5. Reliability & Health

* **Readiness probes** control traffic flow
* **Liveness probes** detect broken containers
* **Smoke test Jobs** validate DNS and service connectivity

---

## 6. Learning Objectives

### Kubernetes

* StatefulSet vs Deployment
* Headless Services and stable DNS
* PersistentVolumeClaims
* Jobs for one-time validation

### Storage & Persistence

* Pod lifecycle vs data lifecycle
* Why persistence must be explicitly tested

### Containers & Docker

* Building a custom Docker image (Hive Metastore)
* Container startup behavior and entrypoints


### Linux & Automation

* Shell scripting for infrastructure automation
* Safe scripting practices (`set -euo pipefail`)

### Enterprise Practices

* Infrastructure as Code
* Clean repository structure
* Documentation as a first-class artifact


---

## 7. Definition of Done

Phase 1 is complete when:

* All components deploy cleanly
* Data survives pod restarts
* DNS resolves reliably
* Smoke tests pass
* Secrets are not committed
* Documentation explains design decisions

---

## 8. Rationale

This phase mirrors real enterprise data platform practices:

> Strong foundations first, complexity later.

Skipping this phase leads to fragile systems and shallow understanding.

---

## 9. Next Phase

**Phase 2** will focus on **explicit persistence validation and object storage usage**, followed by the introduction of compute engines.
