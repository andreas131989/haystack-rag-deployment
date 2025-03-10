# Haystack RAG Deployment

This repository provides a **Kubernetes-based**, **cloud-agnostic**, **on-premise** deployment solution for the Haystack Retrieval-Augmented Generation (RAG) application. It is designed for production-like environments, deploying all components (Frontend, Backend and OpenSearch) as Kubernetes workloads using manifests and a Helm chart.

---

## Table of Contents

- [Overview](#overview)
- [Assumptions](#assumptions)
- [Pre-installation Requirements](#pre-installation-requirements)
- [Deployment Steps](#deployment-steps)
  - [Adjust Hosts File](#adjust-hosts-file)
  - [Build Source Images](#build-source-images)
  - [Build Docker Image](#build-docker-image)
  - [Run the Deployment Container](#run-the-deployment-container)
  - [Access the Application](#access-the-application)
- [Verification Steps](#verification-steps)
- [Additional Considerations](#additional-considerations)
  - [Airgapped Deployment](#airgapped-deployment)
  - [Integration with Alternative Password Stores](#integration-with-alternative-password-stores)
  - [Monitoring and Logging Integration](#monitoring-and-logging-integration)
- [Conclusion](#conclusion)

---

## Overview

This deployment solution packages the Haystack RAG application into a production-grade Kubernetes environment. It leverages Kubernetes to deploy components (Frontend, Backend, OpenSearch, etc.) as workloads (Deployments, Services, ConfigMaps, Secrets, and Ingress). A Helm chart packages Kubernetes manifests with configurable `values.yaml`. Networking and ingress are configured via **Traefik** to expose frontend and API endpoints accessible via a custom hostname (`rag.local`).

---

## Assumptions and decisions
- In a production environment, we would use a load balancer to expose traefik to the outside. Since this is supposed to run locally, we are using nodePort services, which is deemed ok for the purpose of this exercise. 
- The helm release is the one being automatically deployed on k3s.
- It was chosen to containerize the whole exercise to ensure minimal dependencies with host systems.
- K3s was chosen as a production grade but still minimal kubernetes distro.

---

## Prerequisites

You will need to have the following prerequisites completed. Optionally, you can use either `prerequisites-unix.sh` or `prerequisites-windows.ps1` depending on your operating system to verify or complete the setup.

- Docker installed and running.
- `make` installed (for building source images).
- Ability to modify the local hosts file.

---

## Deployment Steps

### Adjust Hosts File

Edit your hosts file:
- Linux/Mac: `/etc/hosts`
- Windows: `C:\Windows\System32\drivers\etc\hosts`

Add the following line:

```bash
127.0.0.1 rag.local
```

### Build Source Images

Execute:

```bash
make build
```

### Build Docker Image

Execute:

```bash
docker build -t haystack-deployment .
```

### Run the Deployment Container

Execute:

```bash
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/config:/app/config" \
  haystack-deployment
```

### Access the Application

Open your browser at:

```
http://rag.local:32090/ 
```

You will be able to upload a document and use the query functionality. 

>**IMPORTANT:** You will need to add a valid openAI key in values.yaml:
```bash
openaiApiKey: "ssj-test-project"
```

---

## Verification Steps

- **Check Docker container status:**

```bash
docker ps
```

- **Access frontend in browser:**

```bash
http://rag.local:32090/
```

- **Test Traefik Gateway health endpoint:**

```bash
curl http://rag.local:32091/ping
```

*Expect a 'OK' response.*

- **Review deployment logs for errors:**

```bash
docker logs <container-id>
```

*Replace `<container-id>` with your actual container ID.*

### Verifying the deployment functionality in k3s cluster ###
Once the deployment inside the container is finished, you will be able to interact with the k3s cluster. Look for this log line:
```bash
[2025-03-09 19:33:36] Deployment complete! You can now interact with your cluster.
```

You can check then the logs for the backend, frontend, traefix and opensearch pods to ensure they are healthy.

Firstly, you can run `kubectl get pods` which, if all works as expected, should show you all pods running:
```bash
$ kubectl get pods -w
NAME                                             READY   STATUS    RESTARTS   AGE
haystack-rag-backend-indexing-586d5b7877-gmqzb   1/1     Running   0          2m14s
haystack-rag-backend-query-59d5ddbbf7-ch8bv      1/1     Running   0          2m14s
haystack-rag-frontend-6f6c6d7cd9-8nffc           1/1     Running   0          2m14s
haystack-rag-gateway-api-gw-dbbb66f96-w7rt9      1/1     Running   0          2m14s
haystack-rag-search-opensearch-0                 1/1     Running   0          2m14s
```

Then, you can check the logs of each pod and look for HTTP 200 OK status:
```bash
kubectl logs <pod-name>
```

If you exit the container and want to enter again, just run:
```bash
docker exec -it <container-id> bash
```

---

## Additional Considerations

### Airgapped Deployment

- Guidance for deploying in offline environments.

### Integration with Alternative Password Stores

- Instructions for using external secret/password management tools.

### Monitoring and Logging Integration

- Recommendations for integrating monitoring/logging solutions like **Prometheus**, **Grafana**, or the **Elastic Stack**.

---
