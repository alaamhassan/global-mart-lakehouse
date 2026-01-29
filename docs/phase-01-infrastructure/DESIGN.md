# Phase 1 – Infrastructure Design

## 1. Purpose

Phase 1 builds the **foundational infrastructure layer** for the Global Mart Lakehouse.

This phase ensures that all future data workloads run on a **stable, persistent, and well‑understood platform**.

---

## 2. High‑Level Goals

* Run entirely on Kubernetes
* Persist data beyond pod lifecycles
* Use production‑grade Kubernetes primitives
* Follow clean naming and folder conventions
* Maximize learning without unnecessary complexity

---

## 3. Scope

### Included

* Kubernetes cluster deployment
* MinIO (object storage)
* MySQL (Hive Metastore backend)
* Hive Metastore service
* Persistent storage (PVCs)
* Health probes and smoke tests

### Explicitly Excluded

* Compute engines (Spark, Flink, Trino)
* Streaming systems (Kafka)
* Orchestration (Airflow)
* Helm and Kustomize (planned later)
* Data ingestion and analytics

---

## 4. Architecture Overview

### Storage Layer

* MinIO as S3‑compatible object storage
* StatefulSet ensures stable identity
* PVCs guarantee data persistence

### Metadata Layer

* MySQL stores Hive Metastore metadata
* StatefulSet + PVC ensures durability

### Metadata Service

* Hive Metastore exposes table definitions
* Enables future engines to share metadata

---

## 5. Reliability & Health

* **Readiness Probes** control traffic flow
* **Liveness Probes** detect broken containers
* **Smoke Test Jobs** validate cluster wiring

---

## 6. Learning Objectives

### Kubernetes

* StatefulSet vs Deployment
* Headless Services and DNS
* PersistentVolumeClaims
* Jobs for one‑time validation

### Storage & Persistence

* Pod lifecycle vs data lifecycle
* Why persistence must be tested

### Linux & Containers

* Container startup behavior
* Shell scripting for automation

### Enterprise Practices

* Infrastructure as Code
* Clean repository structure
* Documentation as a first‑class artifact

---

## 7. Definition of Done

Phase 1 is complete when:

* All components deploy cleanly
* Data survives pod restarts
* DNS works reliably
* Smoke tests pass
* Secrets are not committed
* Documentation explains design choices

---

## 8. Rationale

This phase mirrors real enterprise data platform practices:

> Strong foundations first, complexity later.

Skipping this phase leads to fragile systems and shallow understanding.

---

## 9. Next Phase

Phase 2 will focus on **manual and automated validation of data persistence**, followed by compute layer introduction.
