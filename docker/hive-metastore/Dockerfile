# IMPORTANT: every instruction in the Dockerfile creates one immutable(can't be changed after creation) layer
# only instructions that modify the filesystem creates layers.
FROM apache/hive:4.0.0

# Switch to root (image uses non-root by default)
# beacause: only root can install packages, can write safely to system directories
# this is metadata only, so doesn't create a layer
USER root

ENV MYSQL_CONNECTOR_VERSION=8.3.0


# Install curl (image is Debain-based)
# RUN: execuate a command at image build time
# apt-get: Debain package manager, update: Download latest package index
# command1 $$ comand2: run command2 only if command1 succeed
# -y: answer yes automatically (always use it in Docker builds as docker builds are non-interactive so without -y it will hangs forever)
# curl: package name
# rm: remove files
# -r: recursive (directories)
# -f: fore (no confirmation)
# /var/lib/apt/lists/ : where apt stores package index
# why remove it?: apt-get update downloads index files, after install they are no longer needed (keeping them will make the image bigger)
#Download MySQL JDBC driver into Hive lib directory

RUN apt-get update && \
    apt-get install -y \
        curl \
        gettext &&\
    rm -rf /var/lib/apt/lists/* && \
    curl -fL \
    https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_CONNECTOR_VERSION}/mysql-connector-j-${MYSQL_CONNECTOR_VERSION}.jar \
    -o /opt/hive/lib/mysql-connector-j.jar && \
    chown -R hive:hive /opt/hive/lib/mysql-connector-j.jar

# Switch back to hive user (security best practice)
USER hive




# Instruction	    Creates Layer?	    Why
# FROM	            ✅	                Base filesystem
# RUN	            ✅	                Modifies filesystem
# COPY / ADD	    ✅	                Adds files
# ENV	            ❌	                Metadata only
# USER	            ❌	                Metadata only
# WORKDIR	        ❌	                Metadata only
# CMD / ENTRYPOINT	❌	                Runtime config
#-------------------------------------------------------------------------------------
# At OS level
# A filesystem is simply: The structured way an operating system stores and retrieves files on disk
#-------------------------------------------------------------------------------------
# Key rule (this is fundamental):
#     If Docker cannot detect a filesystem diff, it does not create a layer
#-------------------------------------------------------------------------------------
# Golden rule:
#     Changing ownership after copying a file duplicates it
#-------------------------------------------------------------------------------------
# There are TWO kinds of “metadata”:
#     1️⃣ Image metadata (Docker metadata)
#     Stored outside the filesystem.
#     Examples:

#         ENV
#         USER
#         WORKDIR
#         EXPOSE
#         CMD

#     * These do NOT touch files on disk
#     * They are instructions in the image manifest, not filesystem changes

#     2️⃣ Filesystem metadata (Linux filesystem metadata)
#     Stored inside the filesystem.  
#     Examples:
    
#         File owner (chown)     
#         Permissions (chmod)     
#         File contents      
#         File timestamps
    
#     * These DO change filesystem state
#     * Docker MUST record them in a layer  
#     chown belongs to this category.
#-------------------------------------------------------------------------------------
# Key sentence (memorize this):
#     Docker layers track filesystem changes, not image configuration changes.


# 1️⃣ What do we mean by “manifests”?
# Short definition
# A manifest is a description file that tells a system:
# what exists and how to run it


# Not the data itself — the instructions about the data.
# 🔹 In Docker, there are two different “manifests” people refer to
# 🅐 Image manifest (Docker / OCI manifest)
# This is inside the image, invisible unless you inspect it.

# It contains:

# Which layers make up the image

# What ENV variables exist

# Which USER to run as

# ENTRYPOINT / CMD

# Exposed ports

# Architecture (amd64, arm64)

# 📌 This is where ENV and USER are stored
# 📌 This is why they don’t create filesystem layers

# You can see it with:

#     docker inspect globalmart/hive-metastore:4.0.0-mysql
    
    
#     Mentally:
    
#     Image
#      ├── Manifest (JSON metadata)
#      └── Layers (filesystem snapshots)


#      🅑 Kubernetes manifests (YAML files)

#      These are the YAML files you write:
     
#      kind: Deployment
#      kind: Service
#      kind: ConfigMap
     
     
#      They tell Kubernetes:
     
#      Which image to run
     
#      How many replicas
     
#      Which ports
     
#      Which env vars
     
#      Which volumes
     
#      📌 These do not contain software
#      📌 They reference images, they don’t build them
