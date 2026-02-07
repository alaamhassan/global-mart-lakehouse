# Phase 1 – Infrastructure Foundation

## File Purpose

Describes what Phase 1 delivers and how the infrastructure can be validated.


## Overview

Phase 1 establishes the foundational Kubernetes infrastructure for the **Global Mart Lakehouse** project.

The focus of this phase is **infrastructure correctness, persistence, and stability**, not data processing or analytics.

📘 For detailed goals, scope boundaries, and architectural rationale, see:
- **[Design Document](./DESIGN.md)**
- **[Release Notes v0.1.0](./RELEASE_NOTES_v0.1.0.md)**

---

## Components Deployed

### Storage Layer

* **MinIO** deployed as a StatefulSet
* Persistent storage via PVCs
* Headless Service for stable DNS

### Metadata Layer

* **MySQL** deployed as a StatefulSet
* Persistent storage for Hive Metastore metadata
* Headless Service for stable identity

### Hive Metastore

* Deployed as a Kubernetes Deployment
* Uses MySQL for metadata persistence
* Uses MinIO as the storage backend

---

## Key Architectural Decisions

* Stateful workloads use **StatefulSets**, not Deployments
* Data persistence is handled via **PersistentVolumeClaims**
* **Headless Services** provide stable DNS identities
* Configuration and secrets are externalized
* Infrastructure is defined entirely as code (IaC)

---

## Validation Performed

* Pods restart without data loss
* PVCs remain bound across restarts
* DNS resolution works between components
* Smoke test Jobs validate basic connectivity

---

## Phase Outcome

By the end of Phase 1:

* Infrastructure is stable and persistent
* Core platform services are ready for compute engines
* The system mirrors real enterprise data platform foundations

---

## Next Phase

**Phase 2:** Persistence validation and object storage usage
